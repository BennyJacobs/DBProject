-- בלוק 1: צילום מצב התחלתי
SELECT COUNT(*) AS Old_Closed_Tickets_To_Delete
FROM MAINTENANCE_TICKET
WHERE Ticket_Status = 'Closed'
  AND 2024 - EXTRACT(YEAR FROM Open_Date) >= 2;

-- בלוק 2: התחלת תרחיש
BEGIN;

-- בלוק 3: ביצוע המחיקה
DELETE FROM MAINTENANCE_TICKET
WHERE Ticket_Status = 'Closed'
  AND 2024 - EXTRACT(YEAR FROM Open_Date) >= 2;
  
SELECT COUNT(*) AS Old_Closed_Tickets_To_Delete
FROM MAINTENANCE_TICKET
WHERE Ticket_Status = 'Closed'
  AND 2024 - EXTRACT(YEAR FROM Open_Date) >= 2;

-- בלוק 4: בחר את הפעולה הרצויה (מחק את המקפים מהשורה הרלוונטית)
-- ROLLBACK;
-- COMMIT;
SELECT COUNT(*) AS Old_Closed_Tickets_To_Delete
FROM MAINTENANCE_TICKET
WHERE Ticket_Status = 'Closed'
  AND 2024 - EXTRACT(YEAR FROM Open_Date) >= 2;
