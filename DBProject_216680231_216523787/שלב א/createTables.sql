-- ==========================================
-- FILE: createTables.sql
-- PURPOSE: Create 11 database tables with appropriate data types and constraints.
-- ==========================================

-- 1. CUSTOMER Table
-- Dictionary: Stores customer and subscriber contact details.
CREATE TABLE CUSTOMER
(
  Customer_ID INT NOT NULL,
  First_Name VARCHAR(50) NOT NULL,
  Last_Name VARCHAR(50) NOT NULL,
  Phone_Number VARCHAR(20) NOT NULL,
  Email VARCHAR(100) NOT NULL,
  PRIMARY KEY (Customer_ID),
  UNIQUE (Phone_Number),
  UNIQUE (Email)
);

-- 2. SUBSCRIPTION Table
-- Dictionary: Records customer subscription contracts. Includes start and expiration dates.
CREATE TABLE SUBSCRIPTION
(
  Contract_Number INT NOT NULL,
  Purchase_Date DATE NOT NULL,
  Expiration_Date DATE NOT NULL,
  Total_Cost NUMERIC(10,2) NOT NULL,
  Customer_ID INT NOT NULL,
  PRIMARY KEY (Contract_Number),
  FOREIGN KEY (Customer_ID) REFERENCES CUSTOMER(Customer_ID),
  CONSTRAINT chk_dates CHECK (Expiration_Date >= Purchase_Date),
  CONSTRAINT chk_cost CHECK (Total_Cost >= 0)
);

-- 3. PAYMENT Table
-- Dictionary: Receipts and actual payments made for subscriptions.
CREATE TABLE PAYMENT
(
  Receipt_Number INT NOT NULL,
  Payment_Amount NUMERIC(10,2) NOT NULL,
  Payment_Date DATE NOT NULL,
  Payment_Method VARCHAR(50) NOT NULL,
  Contract_Number INT NOT NULL,
  PRIMARY KEY (Receipt_Number),
  FOREIGN KEY (Contract_Number) REFERENCES SUBSCRIPTION(Contract_Number),
  CONSTRAINT chk_amount CHECK (Payment_Amount > 0)
);

-- 4. FACILITY_ZONE Table
-- Dictionary: Manages activity zones and studio halls within the club.
CREATE TABLE FACILITY_ZONE
(
  Zone_Code VARCHAR(20) NOT NULL,
  Zone_Name VARCHAR(100) NOT NULL,
  Max_Capacity INT NOT NULL,
  Area_Sqm NUMERIC(8,2) NOT NULL,
  PRIMARY KEY (Zone_Code),
  CONSTRAINT chk_capacity CHECK (Max_Capacity > 0),
  CONSTRAINT chk_area CHECK (Area_Sqm > 0)
);

-- 5. FITNESS_MACHINE Table
-- Dictionary: Inventory of physical gym equipment and their assigned zones.
CREATE TABLE FITNESS_MACHINE
(
  Serial_Number VARCHAR(50) NOT NULL,
  Manufacturer VARCHAR(100) NOT NULL,
  Model VARCHAR(100) NOT NULL,
  Machine_Status VARCHAR(50) NOT NULL,
  Purchase_Date DATE NOT NULL,
  Zone_Code VARCHAR(20) NOT NULL, 
  PRIMARY KEY (Serial_Number),
  FOREIGN KEY (Zone_Code) REFERENCES FACILITY_ZONE(Zone_Code),
  CONSTRAINT chk_machine_status CHECK (Machine_Status IN ('Active', 'In Repair', 'Out of Order'))
);

-- 6. SPARE_PART Table
-- Dictionary: Inventory of spare parts used for machine maintenance.
CREATE TABLE SPARE_PART
(
  Part_Number VARCHAR(50) NOT NULL,
  Part_Description VARCHAR(200) NOT NULL,
  Stock_Quantity INT NOT NULL,
  Reorder_Level INT NOT NULL,
  PRIMARY KEY (Part_Number),
  CONSTRAINT chk_stock CHECK (Stock_Quantity >= 0),
  CONSTRAINT chk_reorder CHECK (Reorder_Level >= 0)
);

-- 7. SUPPLIER Table
-- Dictionary: External companies providing equipment, spare parts, and maintenance services.
CREATE TABLE SUPPLIER
(
  Supplier_ID INT NOT NULL,
  Company_Name VARCHAR(100) NOT NULL,
  Contact_Person VARCHAR(100) NOT NULL,
  Phone_Number VARCHAR(20) NOT NULL,
  Email VARCHAR(100) NOT NULL,
  PRIMARY KEY (Supplier_ID)
);

-- 8. MAINTENANCE_TICKET Table
-- Dictionary: Log of service calls, issues, and repairs for fitness machines.
CREATE TABLE MAINTENANCE_TICKET
(
  Ticket_Number INT NOT NULL,
  Open_Date DATE NOT NULL,
  Issue_Description VARCHAR(500) NOT NULL,
  Ticket_Status VARCHAR(50) NOT NULL,
  Serial_Number VARCHAR(50) NOT NULL, 
  Supplier_ID INT NOT NULL,
  PRIMARY KEY (Ticket_Number),
  FOREIGN KEY (Serial_Number) REFERENCES FITNESS_MACHINE(Serial_Number),
  FOREIGN KEY (Supplier_ID) REFERENCES SUPPLIER(Supplier_ID),
  CONSTRAINT chk_ticket_status CHECK (Ticket_Status IN ('Open', 'In Progress', 'Closed'))
);

-- 9. EMPLOYEE Table
-- Dictionary: Operations and logistics staff members.
CREATE TABLE EMPLOYEE
(
  Employee_ID INT NOT NULL,
  First_Name VARCHAR(50) NOT NULL,
  Last_Name VARCHAR(50) NOT NULL,
  Job_Title VARCHAR(100) NOT NULL,
  Hire_Date DATE NOT NULL,
  PRIMARY KEY (Employee_ID)
);

-- 10. PURCHASE_ORDER Table
-- Dictionary: Orders placed by employees to suppliers for spare parts.
CREATE TABLE PURCHASE_ORDER
(
  Order_Number INT NOT NULL,
  Order_Date DATE NOT NULL,
  Supplier_ID INT NOT NULL,
  Employee_ID INT NOT NULL,
  PRIMARY KEY (Order_Number),
  FOREIGN KEY (Supplier_ID) REFERENCES SUPPLIER(Supplier_ID),
  FOREIGN KEY (Employee_ID) REFERENCES EMPLOYEE(Employee_ID)
);

-- 11. ORDER_ITEM Table
-- Dictionary: Associative entity linking purchase orders to specific spare parts and quantities.
CREATE TABLE ORDER_ITEM
(
  Ordered_Quantity INT NOT NULL,
  Order_Number INT NOT NULL,
  Part_Number VARCHAR(50) NOT NULL, 
  PRIMARY KEY (Order_Number, Part_Number),
  FOREIGN KEY (Order_Number) REFERENCES PURCHASE_ORDER(Order_Number),
  FOREIGN KEY (Part_Number) REFERENCES SPARE_PART(Part_Number),
  CONSTRAINT chk_quantity CHECK (Ordered_Quantity > 0)
);