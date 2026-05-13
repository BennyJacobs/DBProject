-- בלוק 1: סריקה לפני 
EXPLAIN ANALYZE SELECT * FROM SUBSCRIPTION WHERE Customer_ID = 1;

-- בלוק 2: יצירת האינדקס
CREATE INDEX idx_sub_customer ON SUBSCRIPTION(Customer_ID);

EXPLAIN ANALYZE SELECT * FROM SUBSCRIPTION WHERE Customer_ID = 1;


-- בלוק 1: סריקה לפני 
EXPLAIN ANALYZE SELECT MAX(Expiration_Date) FROM SUBSCRIPTION;

-- בלוק 2: יצירת האינדקס
CREATE INDEX idx_sub_expiration ON SUBSCRIPTION(Expiration_Date);

EXPLAIN ANALYZE SELECT MAX(Expiration_Date) FROM SUBSCRIPTION;


-- בלוק 1: סריקה לפני 
EXPLAIN ANALYZE SELECT * FROM PAYMENT WHERE Contract_Number = 1;

-- בלוק 2: יצירת האינדקס
CREATE INDEX idx_payment_contract ON PAYMENT(Contract_Number);

EXPLAIN ANALYZE SELECT * FROM PAYMENT WHERE Contract_Number = 1;
