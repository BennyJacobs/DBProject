-- בלוק 1: צילום מצב התחלתי
SELECT COUNT(*) AS Obsolete_Parts_Count 
FROM SPARE_PART
WHERE Stock_Quantity = 0 
  AND Reorder_Level = 0
  AND Part_Number NOT IN (SELECT DISTINCT Part_Number FROM ORDER_ITEM);

-- בלוק 2: התחלת תרחיש
BEGIN;

-- בלוק 3: ביצוע המחיקה
DELETE FROM SPARE_PART
WHERE Stock_Quantity = 0 
  AND Reorder_Level = 0
  AND Part_Number NOT IN (SELECT DISTINCT Part_Number FROM ORDER_ITEM);
  
SELECT COUNT(*) AS Obsolete_Parts_Count 
FROM SPARE_PART
WHERE Stock_Quantity = 0 
  AND Reorder_Level = 0
  AND Part_Number NOT IN (SELECT DISTINCT Part_Number FROM ORDER_ITEM);


-- בלוק 4: בחר את הפעולה הרצויה (מחק את המקפים מהשורה הרלוונטית)
-- ROLLBACK;
-- COMMIT;

SELECT COUNT(*) AS Obsolete_Parts_Count 
FROM SPARE_PART
WHERE Stock_Quantity = 0 
  AND Reorder_Level = 0
  AND Part_Number NOT IN (SELECT DISTINCT Part_Number FROM ORDER_ITEM);
