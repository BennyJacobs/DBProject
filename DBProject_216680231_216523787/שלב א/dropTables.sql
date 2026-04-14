-- ==========================================
-- FILE: dropTables.sql
-- PURPOSE: Safely drop all tables in the correct reverse-dependency order.
-- EXPLANATION: Tables with Foreign Keys (Child tables) must be dropped BEFORE 
-- the tables they reference (Parent tables) to avoid constraint violations.
-- ==========================================

-- 1. Drop Associative and heavily dependent tables first
-- Dictionary: ORDER_ITEM depends on PURCHASE_ORDER and SPARE_PART
DROP TABLE IF EXISTS ORDER_ITEM CASCADE;

-- Dictionary: PURCHASE_ORDER depends on SUPPLIER and EMPLOYEE
DROP TABLE IF EXISTS PURCHASE_ORDER CASCADE;

-- Dictionary: MAINTENANCE_TICKET depends on FITNESS_MACHINE and SUPPLIER
DROP TABLE IF EXISTS MAINTENANCE_TICKET CASCADE;

-- Dictionary: PAYMENT depends on SUBSCRIPTION
DROP TABLE IF EXISTS PAYMENT CASCADE;

-- Dictionary: SUBSCRIPTION depends on CUSTOMER
DROP TABLE IF EXISTS SUBSCRIPTION CASCADE;

-- Dictionary: FITNESS_MACHINE depends on FACILITY_ZONE
DROP TABLE IF EXISTS FITNESS_MACHINE CASCADE;

-- 2. Drop Base tables (No Foreign Keys)
-- Dictionary: These tables do not rely on any other tables
DROP TABLE IF EXISTS SPARE_PART CASCADE;
DROP TABLE IF EXISTS EMPLOYEE CASCADE;
DROP TABLE IF EXISTS SUPPLIER CASCADE;
DROP TABLE IF EXISTS CUSTOMER CASCADE;
DROP TABLE IF EXISTS FACILITY_ZONE CASCADE;