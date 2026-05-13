-- בלוק 1: צילום מצב התחלתי
SELECT S.Contract_Number, S.Expiration_Date
FROM SUBSCRIPTION S
WHERE EXTRACT(YEAR FROM S.Purchase_Date) = 2023
  AND S.Contract_Number IN (
      SELECT Contract_Number 
      FROM PAYMENT 
      GROUP BY Contract_Number 
      HAVING SUM(Payment_Amount) > 2000
  )
LIMIT 3;

-- בלוק 2: התחלת תרחיש
BEGIN;

-- בלוק 3: ביצוע העדכון
UPDATE SUBSCRIPTION
SET Expiration_Date = Expiration_Date + INTERVAL '1 month'
WHERE EXTRACT(YEAR FROM Purchase_Date) = 2023
  AND Contract_Number IN (
      SELECT Contract_Number 
      FROM PAYMENT 
      GROUP BY Contract_Number 
      HAVING SUM(Payment_Amount) > 2000
  );
  
SELECT S.Contract_Number, S.Expiration_Date
FROM SUBSCRIPTION S
WHERE EXTRACT(YEAR FROM S.Purchase_Date) = 2023
  AND S.Contract_Number IN (
      SELECT Contract_Number 
      FROM PAYMENT 
      GROUP BY Contract_Number 
      HAVING SUM(Payment_Amount) > 2000
  )
LIMIT 3;
-- בלוק 4: ביטול העדכון
-- ROLLBACK; COMMIT;

SELECT S.Contract_Number, S.Expiration_Date
FROM SUBSCRIPTION S
WHERE EXTRACT(YEAR FROM S.Purchase_Date) = 2023
  AND S.Contract_Number IN (
      SELECT Contract_Number 
      FROM PAYMENT 
      GROUP BY Contract_Number 
      HAVING SUM(Payment_Amount) > 2000
  )
LIMIT 3;