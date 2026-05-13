-- =====================================================================
-- GROUP 1: Regular SELECT Queries (Complex / Multi-table)
-- =====================================================================

-- ---------------------------------------------------------------------
-- Query 1: Annual Payment Champions
-- Purpose: Find the customer who made the highest single payment in 2023.
-- ---------------------------------------------------------------------
SELECT C.Customer_ID, C.First_Name, C.Last_Name, P.Payment_Date, P.Payment_Amount
FROM CUSTOMER C
JOIN SUBSCRIPTION S ON C.Customer_ID = S.Customer_ID
JOIN PAYMENT P ON S.Contract_Number = P.Contract_Number
WHERE P.Payment_Amount = (
    SELECT MAX(P2.Payment_Amount)
    FROM PAYMENT P2
    WHERE EXTRACT(YEAR FROM P2.Payment_Date) = 2023
) AND EXTRACT(YEAR FROM P.Payment_Date) = 2023;


-- ---------------------------------------------------------------------
-- Query 2: Zone Density Analysis
-- Purpose: Retrieve zones where the average space per person is less than 4.5 sqm, 
--          and there are at least 3 active machines.
-- ---------------------------------------------------------------------
SELECT 
    FZ.Zone_Name, 
    FZ.Max_Capacity, 
    FZ.Area_Sqm, 
    (FZ.Area_Sqm / FZ.Max_Capacity) AS Sqm_Per_Person,
    COUNT(FM.Serial_Number) AS Active_Machines_Count
FROM FACILITY_ZONE FZ
JOIN FITNESS_MACHINE FM ON FZ.Zone_Code = FM.Zone_Code
WHERE FM.Machine_Status = 'Active'
GROUP BY FZ.Zone_Code, FZ.Zone_Name, FZ.Max_Capacity, FZ.Area_Sqm
HAVING (FZ.Area_Sqm / FZ.Max_Capacity) < 4.5 
   AND COUNT(FM.Serial_Number) >= 3
ORDER BY Sqm_Per_Person ASC;


-- ---------------------------------------------------------------------
-- Query 3: Old Equipment Issue Tracking
-- Purpose: Identify manufacturers of equipment purchased before 2022 
--          that currently have open or in-progress service tickets.
-- ---------------------------------------------------------------------
SELECT FM.Manufacturer, COUNT(MT.Ticket_Number) AS Open_Tickets
FROM FITNESS_MACHINE FM
JOIN MAINTENANCE_TICKET MT ON FM.Serial_Number = MT.Serial_Number
WHERE EXTRACT(YEAR FROM FM.Purchase_Date) < 2022
  AND MT.Ticket_Status IN ('Open', 'In Progress')
GROUP BY FM.Manufacturer
ORDER BY Open_Tickets DESC;


-- ---------------------------------------------------------------------
-- Query 4: Employee Purchasing Performance Report
-- Purpose: Total items ordered by each employee in the last 6 months 
--          (only for employees who ordered more than 10 items in total).
-- ---------------------------------------------------------------------
SELECT 
    E.First_Name, 
    E.Last_Name, 
    COUNT(DISTINCT PO.Order_Number) AS Total_Orders,
    SUM(OI.Ordered_Quantity) AS Total_Items_Ordered
FROM EMPLOYEE E
JOIN PURCHASE_ORDER PO ON E.Employee_ID = PO.Employee_ID
JOIN ORDER_ITEM OI ON PO.Order_Number = OI.Order_Number
WHERE PO.Order_Date >= DATE '2024-12-31' - INTERVAL '6 months'
GROUP BY E.Employee_ID, E.First_Name, E.Last_Name
HAVING SUM(OI.Ordered_Quantity) > 10
ORDER BY Total_Items_Ordered DESC;


-- =====================================================================
-- GROUP 2: Efficiency Comparison Queries (Efficient vs. Less Efficient)
-- =====================================================================

-- ---------------------------------------------------------------------
-- Pair 1: Customer Subscription Status Comparison
-- Purpose: Identifies if the latest subscription is an upgrade, downgrade, 
--          no change, or a new customer compared to their previous one.
-- ---------------------------------------------------------------------

-- Method 1: Using Self-Join and Correlated Subqueries
SELECT 
    C.First_Name,
    C.Last_Name,
    S1.Total_Cost AS Current_Cost,
    S2.Total_Cost AS Previous_Cost,
    CASE 
        WHEN S2.Total_Cost IS NULL THEN 'New Customer'
        WHEN S1.Total_Cost > S2.Total_Cost THEN 'Upgrade'
        WHEN S1.Total_Cost < S2.Total_Cost THEN 'Downgrade'
        ELSE 'No Change'
    END AS Status_Indicator
FROM CUSTOMER C
JOIN SUBSCRIPTION S1 ON C.Customer_ID = S1.Customer_ID
LEFT JOIN SUBSCRIPTION S2 ON S1.Customer_ID = S2.Customer_ID 
    AND S2.Expiration_Date = (
        SELECT MAX(S3.Expiration_Date)
        FROM SUBSCRIPTION S3
        WHERE S3.Customer_ID = S1.Customer_ID 
          AND S3.Expiration_Date < S1.Expiration_Date
    )
WHERE S1.Expiration_Date = (
    SELECT MAX(S4.Expiration_Date) 
    FROM SUBSCRIPTION S4 
    WHERE S4.Customer_ID = S1.Customer_ID
);

-- Method 2: Using Window Functions (More efficient for modern SQL engines)
SELECT 
    First_Name,
    Last_Name,
    Current_Cost,
    Previous_Cost,
    CASE 
        WHEN Previous_Cost IS NULL THEN 'New Customer'
        WHEN Current_Cost > Previous_Cost THEN 'Upgrade'
        WHEN Current_Cost < Previous_Cost THEN 'Downgrade'
        ELSE 'No Change'
    END AS Status_Indicator
FROM (
    SELECT 
        C.First_Name,
        C.Last_Name,
        S.Total_Cost AS Current_Cost,
        LAG(S.Total_Cost) OVER (PARTITION BY S.Customer_ID ORDER BY S.Expiration_Date) AS Previous_Cost,
        ROW_NUMBER() OVER (PARTITION BY S.Customer_ID ORDER BY S.Expiration_Date DESC) AS rn
    FROM CUSTOMER C
    JOIN SUBSCRIPTION S ON C.Customer_ID = S.Customer_ID
) Sub
WHERE rn = 1;


-- ---------------------------------------------------------------------
-- Pair 2: Zones with multiple breakdowns
-- Purpose: Zones with more than 2 machines in repair, including a count of active machines.
-- ---------------------------------------------------------------------

-- Method 1: Using CASE inside SUM (Efficient - Single Pass scan over the machines table)
SELECT 
    FZ.Zone_Name,
    SUM(CASE WHEN FM.Machine_Status = 'In Repair' THEN 1 ELSE 0 END) AS Broken_Machines,
    SUM(CASE WHEN FM.Machine_Status = 'Active' THEN 1 ELSE 0 END) AS Active_Machines
FROM FACILITY_ZONE FZ
JOIN FITNESS_MACHINE FM ON FZ.Zone_Code = FM.Zone_Code
GROUP BY FZ.Zone_Code, FZ.Zone_Name
HAVING SUM(CASE WHEN FM.Machine_Status = 'In Repair' THEN 1 ELSE 0 END) > 2
ORDER BY Broken_Machines DESC;

-- Method 2: Using subqueries in SELECT (Less efficient - requires 3 separate scans per record)
SELECT 
    FZ.Zone_Name,
    (SELECT COUNT(*) FROM FITNESS_MACHINE FM1 WHERE FM1.Zone_Code = FZ.Zone_Code AND FM1.Machine_Status = 'In Repair') AS Broken_Machines,
    (SELECT COUNT(*) FROM FITNESS_MACHINE FM2 WHERE FM2.Zone_Code = FZ.Zone_Code AND FM2.Machine_Status = 'Active') AS Active_Machines
FROM FACILITY_ZONE FZ
WHERE (SELECT COUNT(*) FROM FITNESS_MACHINE FM3 WHERE FM3.Zone_Code = FZ.Zone_Code AND FM3.Machine_Status = 'In Repair') > 2
ORDER BY Broken_Machines DESC;


-- ---------------------------------------------------------------------
-- Pair 3: Suppliers for urgent restock
-- Purpose: Suppliers for parts that dropped below the reorder level and were already ordered this month.
-- ---------------------------------------------------------------------

-- Method 1: Using EXISTS (Efficient - Short-circuit evaluation, stops searching once a match is found)
SELECT S.Supplier_ID, S.Company_Name, S.Phone_Number
FROM SUPPLIER S
WHERE EXISTS (
    SELECT 1 
    FROM PURCHASE_ORDER PO
    JOIN ORDER_ITEM OI ON PO.Order_Number = OI.Order_Number
    JOIN SPARE_PART SP ON OI.Part_Number = SP.Part_Number
    WHERE PO.Supplier_ID = S.Supplier_ID
      AND SP.Stock_Quantity < SP.Reorder_Level
      AND EXTRACT(MONTH FROM PO.Order_Date) = 12
);

-- Method 2: Using DISTINCT and JOIN (Less efficient - fetches all rows, loads memory, then filters duplicates)
SELECT DISTINCT S.Supplier_ID, S.Company_Name, S.Phone_Number
FROM SUPPLIER S
JOIN PURCHASE_ORDER PO ON S.Supplier_ID = PO.Supplier_ID
JOIN ORDER_ITEM OI ON PO.Order_Number = OI.Order_Number
JOIN SPARE_PART SP ON OI.Part_Number = SP.Part_Number
WHERE SP.Stock_Quantity < SP.Reorder_Level
  AND EXTRACT(MONTH FROM PO.Order_Date) = 12
  AND EXTRACT(YEAR FROM PO.Order_Date) = 2024;


-- ---------------------------------------------------------------------
-- Pair 4: Employees dealing with problematic suppliers
-- Purpose: Employees who issued purchase orders to suppliers with open service tickets older than 7 days.
-- ---------------------------------------------------------------------

-- Method 1: Using CTE (Efficient - keeps an intermediate logical table in memory and performs an optimized JOIN)
WITH Problematic_Suppliers AS (
    SELECT DISTINCT Supplier_ID
    FROM MAINTENANCE_TICKET
    WHERE Ticket_Status = 'Open' 
      AND '2024-12-31' - Open_Date > 7
)
SELECT DISTINCT E.First_Name, E.Last_Name, E.Job_Title
FROM EMPLOYEE E
JOIN PURCHASE_ORDER PO ON E.Employee_ID = PO.Employee_ID
JOIN Problematic_Suppliers PS ON PO.Supplier_ID = PS.Supplier_ID;

-- Method 2: Using nested IN clauses (Less efficient - can create a heavy execution plan in some DB engines)
SELECT E.First_Name, E.Last_Name, E.Job_Title
FROM EMPLOYEE E
WHERE E.Employee_ID IN (
    SELECT PO.Employee_ID
    FROM PURCHASE_ORDER PO
    WHERE PO.Supplier_ID IN (
        SELECT MT.Supplier_ID
        FROM MAINTENANCE_TICKET MT
        WHERE MT.Ticket_Status = 'Open'
          AND MT.Open_Date < '2024-12-31' - INTERVAL '7 days'
    )
);


-- =====================================================================
-- GROUP 3: UPDATE Queries
-- =====================================================================

-- ---------------------------------------------------------------------
-- Update 1: VIP Customer Bonus
-- Purpose: Add one month to the expiration date of subscriptions purchased in 2023, 
--          where total payments exceed 2000.
-- ---------------------------------------------------------------------
UPDATE SUBSCRIPTION
SET Expiration_Date = Expiration_Date + INTERVAL '1 month'
WHERE EXTRACT(YEAR FROM Purchase_Date) = 2023
  AND Contract_Number IN (
      SELECT Contract_Number 
      FROM PAYMENT 
      GROUP BY Contract_Number 
      HAVING SUM(Payment_Amount) > 2000
  );


-- ---------------------------------------------------------------------
-- Update 2: Automatic Equipment Deactivation
-- Purpose: Change machine status to 'Out of Order' if it has an open service 
--          ticket that hasn't been handled for over 14 days.
-- ---------------------------------------------------------------------
UPDATE FITNESS_MACHINE
SET Machine_Status = 'Out of Order'
WHERE Serial_Number IN (
    SELECT Serial_Number
    FROM MAINTENANCE_TICKET
    WHERE Ticket_Status = 'Open' 
      AND '2024-12-31' - Open_Date > 14
);


-- ---------------------------------------------------------------------
-- Update 3: Supply Chain Optimization
-- Purpose: Increase the reorder level by 20% for spare parts ordered 
--          more than 5 times this year.
-- ---------------------------------------------------------------------
UPDATE SPARE_PART
SET Reorder_Level = ROUND(Reorder_Level * 1.2)
WHERE Part_Number IN (
    SELECT OI.Part_Number
    FROM ORDER_ITEM OI
    JOIN PURCHASE_ORDER PO ON OI.Order_Number = PO.Order_Number
    WHERE EXTRACT(YEAR FROM PO.Order_Date) = 2024
    GROUP BY OI.Part_Number
    HAVING SUM(OI.Ordered_Quantity) > 5
);


-- =====================================================================
-- GROUP 4: DELETE Queries
-- =====================================================================

-- ---------------------------------------------------------------------
-- Delete 1: Archive Service Tickets
-- Purpose: Delete closed service tickets that were opened more than two years ago.
-- ---------------------------------------------------------------------
DELETE FROM MAINTENANCE_TICKET
WHERE Ticket_Status = 'Closed'
  AND 2024 - EXTRACT(YEAR FROM Open_Date) >= 2;


-- ---------------------------------------------------------------------
-- Delete 2: Data Cleansing
-- Purpose: Delete purchase order items where the ordered quantity is 0 
--          (assumed to be mistakenly entered).
-- ---------------------------------------------------------------------
DELETE FROM ORDER_ITEM
WHERE Ordered_Quantity = 0;


-- ---------------------------------------------------------------------
-- Delete 3: Remove Obsolete Spare Parts
-- Purpose: Delete spare parts that have 0 stock, 0 reorder level, 
--          and have never been ordered before.
-- ---------------------------------------------------------------------
DELETE FROM SPARE_PART
WHERE Stock_Quantity = 0 
  AND Reorder_Level = 0
  AND Part_Number NOT IN (SELECT DISTINCT Part_Number FROM ORDER_ITEM);