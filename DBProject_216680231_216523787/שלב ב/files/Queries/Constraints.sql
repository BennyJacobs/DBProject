ALTER TABLE PAYMENT
ADD CONSTRAINT chk_payment_method 
CHECK (Payment_Method IN ('Credit Card', 'Cash', 'Bank Transfer', 'Check', 'Bit', 'Apple Pay', 'PayPal'));

ALTER TABLE CUSTOMER
ADD CONSTRAINT chk_customer_email_format 
CHECK (Email LIKE '%@%');

ALTER TABLE EMPLOYEE
ADD CONSTRAINT chk_employee_hire_date 
CHECK (EXTRACT(YEAR FROM Hire_Date) >= 2010);