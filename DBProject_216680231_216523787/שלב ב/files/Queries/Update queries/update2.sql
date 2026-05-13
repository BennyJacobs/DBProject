-- בלוק 1: צילום מצב התחלתי
SELECT Machine_Status, COUNT(*) AS Total_Machines
FROM FITNESS_MACHINE
GROUP BY Machine_Status;

-- בלוק 2: התחלת תרחיש
BEGIN;

-- בלוק 3: ביצוע העדכון
UPDATE FITNESS_MACHINE
SET Machine_Status = 'Out of Order'
WHERE Serial_Number IN (
    SELECT Serial_Number
    FROM MAINTENANCE_TICKET
    WHERE Ticket_Status = 'Open' 
      AND '2024-12-31' - Open_Date > 14
);
SELECT Machine_Status, COUNT(*) AS Total_Machines
FROM FITNESS_MACHINE
GROUP BY Machine_Status;
-- בלוק 4: בחר את הפעולה הרצויה (מחק את המקפים מהשורה הרלוונטית)
-- ROLLBACK;
-- COMMIT;
SELECT Machine_Status, COUNT(*) AS Total_Machines
FROM FITNESS_MACHINE
GROUP BY Machine_Status;