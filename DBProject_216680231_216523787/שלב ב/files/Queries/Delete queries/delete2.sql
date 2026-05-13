-- בלוק 1: צילום מצב התחלתי
SELECT COUNT(*) AS Zero_Quantity_Items
FROM ORDER_ITEM
WHERE Ordered_Quantity = 0;

-- בלוק 2: התחלת תרחיש
BEGIN;

-- בלוק 3: ביצוע המחיקה
DELETE FROM ORDER_ITEM
WHERE Ordered_Quantity = 0;

SELECT COUNT(*) AS Zero_Quantity_Items
FROM ORDER_ITEM
WHERE Ordered_Quantity = 0;

-- בלוק 4: בחר את הפעולה הרצויה (מחק את המקפים מהשורה הרלוונטית)
-- ROLLBACK;
-- COMMIT;
SELECT COUNT(*) AS Zero_Quantity_Items
FROM ORDER_ITEM
WHERE Ordered_Quantity = 0;
