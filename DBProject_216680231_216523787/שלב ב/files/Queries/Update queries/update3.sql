-- בלוק 1: צילום מצב התחלתי
SELECT Part_Number, Reorder_Level
FROM SPARE_PART
WHERE Part_Number IN (
    SELECT OI.Part_Number
    FROM ORDER_ITEM OI
    JOIN PURCHASE_ORDER PO ON OI.Order_Number = PO.Order_Number
    WHERE EXTRACT(YEAR FROM PO.Order_Date) = 2024
    GROUP BY OI.Part_Number
    HAVING SUM(OI.Ordered_Quantity) > 5
)
LIMIT 5;

-- בלוק 2: התחלת תרחיש
BEGIN;

-- בלוק 3: ביצוע העדכון
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
SELECT Part_Number, Reorder_Level
FROM SPARE_PART
WHERE Part_Number IN (
    SELECT OI.Part_Number
    FROM ORDER_ITEM OI
    JOIN PURCHASE_ORDER PO ON OI.Order_Number = PO.Order_Number
    WHERE EXTRACT(YEAR FROM PO.Order_Date) = 2024
    GROUP BY OI.Part_Number
    HAVING SUM(OI.Ordered_Quantity) > 5
)
LIMIT 5;
-- בלוק 4: בחר את הפעולה הרצויה (מחק את המקפים מהשורה הרלוונטית)
-- ROLLBACK;
-- COMMIT;
SELECT Part_Number, Reorder_Level
FROM SPARE_PART
WHERE Part_Number IN (
    SELECT OI.Part_Number
    FROM ORDER_ITEM OI
    JOIN PURCHASE_ORDER PO ON OI.Order_Number = PO.Order_Number
    WHERE EXTRACT(YEAR FROM PO.Order_Date) = 2024
    GROUP BY OI.Part_Number
    HAVING SUM(OI.Ordered_Quantity) > 5
)
LIMIT 5;