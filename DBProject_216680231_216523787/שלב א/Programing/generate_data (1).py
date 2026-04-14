import csv
import random
from datetime import datetime, timedelta
from faker import Faker

fake = Faker()

NUM_BASE_RECORDS = 510
NUM_MASSIVE_RECORDS = 20000


def random_date(start_year=2020, end_year=2023):
    start = datetime(start_year, 1, 1)
    end = datetime(end_year, 12, 31)
    return start + timedelta(seconds=random.randint(0, int((end - start).total_seconds())))


print("Generating 20,000 CSV records for SUBSCRIPTION and PAYMENT...")

with open('subscriptions.csv', 'w', newline='', encoding='utf-8') as f_sub, \
        open('payments.csv', 'w', newline='', encoding='utf-8') as f_pay:
    sub_writer = csv.writer(f_sub)
    pay_writer = csv.writer(f_pay)

    sub_writer.writerow(['contract_number', 'purchase_date', 'expiration_date', 'total_cost', 'customer_id'])
    pay_writer.writerow(['receipt_number', 'payment_amount', 'payment_date', 'payment_method', 'contract_number'])

    for i in range(1, NUM_MASSIVE_RECORDS + 1):
        contract_number = i
        customer_id = random.randint(1, NUM_BASE_RECORDS)
        purch_date = random_date()
        exp_date = purch_date + timedelta(days=random.choice([30, 90, 365]))
        total_cost = round(random.uniform(100.0, 3000.0), 2)

        sub_writer.writerow(
            [contract_number, purch_date.strftime('%Y-%m-%d'), exp_date.strftime('%Y-%m-%d'), total_cost, customer_id])

        receipt_number = i
        payment_amount = total_cost
        payment_date = purch_date + timedelta(days=random.randint(0, 5))
        payment_method = random.choice(['Credit Card', 'Cash', 'Bank Transfer', 'PayPal'])

        pay_writer.writerow(
            [receipt_number, payment_amount, payment_date.strftime('%Y-%m-%d'), payment_method, contract_number])

print("Generating insertTables.sql with literal INSERT commands...")

with open('insertTables.sql', 'w', encoding='utf-8') as f_sql:
    f_sql.write("-- ==========================================\n")
    f_sql.write("-- FILE: insertTables.sql\n")
    f_sql.write("-- Contains literal INSERT statements (Method 1)\n")
    f_sql.write("-- ==========================================\n\n")

    # פה התיקון: שומרים את המספרים הסידוריים ברשימה
    generated_serials = []

    # 1. FITNESS_MACHINE (510 rows)
    f_sql.write("-- INSERTING 510 FITNESS MACHINES\n")
    for i in range(1, NUM_BASE_RECORDS + 1):
        serial = f"SN-{fake.bothify(text='????-####')}-{i}"
        generated_serials.append(serial)  # הוספה לרשימה
        manuf = random.choice(['TechnoGym', 'LifeFitness', 'Matrix', 'Precor', 'HammerStrength'])
        model = f"Model {fake.word().capitalize()}"
        status = random.choice(['Active', 'In Repair', 'Out of Order'])
        purch_date = random_date(2015, 2023).strftime('%Y-%m-%d')
        zone_code = f"Z-{random.randint(1, NUM_BASE_RECORDS)}"

        f_sql.write(
            f"INSERT INTO FITNESS_MACHINE (Serial_Number, Manufacturer, Model, Machine_Status, Purchase_Date, Zone_Code) VALUES ('{serial}', '{manuf}', '{model}', '{status}', '{purch_date}', '{zone_code}');\n")

    f_sql.write("\n")

    # 2. MAINTENANCE_TICKET (510 rows)
    f_sql.write("-- INSERTING 510 MAINTENANCE TICKETS\n")
    for i in range(1, NUM_BASE_RECORDS + 1):
        ticket_num = i
        open_date = random_date(2022, 2024).strftime('%Y-%m-%d')
        issue = random.choice(['Broken cable', 'Screen not working', 'Strange noise from motor', 'Torn padding'])
        status = random.choice(['Open', 'In Progress', 'Closed'])
        # פה התיקון השני: בוחרים מספר סידורי רק מתוך הרשימה שכבר יצרנו
        serial = random.choice(generated_serials)
        supplier_id = random.randint(1, NUM_BASE_RECORDS)

        f_sql.write(
            f"INSERT INTO MAINTENANCE_TICKET (Ticket_Number, Open_Date, Issue_Description, Ticket_Status, Serial_Number, Supplier_ID) VALUES ({ticket_num}, '{open_date}', '{issue}', '{status}', '{serial}', {supplier_id});\n")

    f_sql.write("\n")

    # 3. PURCHASE_ORDER (510 rows)
    f_sql.write("-- INSERTING 510 PURCHASE ORDERS\n")
    for i in range(1, NUM_BASE_RECORDS + 1):
        order_num = i
        order_date = random_date(2023, 2024).strftime('%Y-%m-%d')
        supplier_id = random.randint(1, NUM_BASE_RECORDS)
        employee_id = random.randint(1, NUM_BASE_RECORDS)

        f_sql.write(
            f"INSERT INTO PURCHASE_ORDER (Order_Number, Order_Date, Supplier_ID, Employee_ID) VALUES ({order_num}, '{order_date}', {supplier_id}, {employee_id});\n")

    f_sql.write("\n")

    # 4. ORDER_ITEM (510 rows)
    f_sql.write("-- INSERTING 510 ORDER ITEMS\n")
    for i in range(1, NUM_BASE_RECORDS + 1):
        order_num = i
        part_num = f"P-{random.randint(1, NUM_BASE_RECORDS)}"
        qty = random.randint(1, 50)

        f_sql.write(
            f"INSERT INTO ORDER_ITEM (Ordered_Quantity, Order_Number, Part_Number) VALUES ({qty}, {order_num}, '{part_num}');\n")

print("Finished successfully!")