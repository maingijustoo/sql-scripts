import random
from datetime import datetime

# Total number of members (assuming MemberIDs from 1 to 420)
num_members = 410

# Open file to write SQL statements
with open("contributions_data2.sql", "w") as f:
    for member_id in range(1, num_members + 1):
        # For demonstration, we simulate employment status with a simple scheme:
        # For example, assign status based on member_id mod 3:
        # 0 -> Unemployed, 1 -> Self-Employed, 2 -> Employed.
        status_selector = member_id % 3
        if status_selector == 0:
            # Unemployed: lowest contribution, Bank Transfer
            amount = round(random.uniform(100, 1500), 2)
            payment_method = 'Mpesa'
            employer_id = "NULL"
        elif status_selector == 1:
            # Self-Employed: moderate contribution, randomly choose between M-Pesa and Bank Transfer
            amount = round(random.uniform(500, 5000), 2)
            payment_method = random.choice(['Mpesa', 'Bank-transfer'])
            employer_id = "NULL"
        else:
            # Employed: highest contribution, Employer Remittance, valid EmployerID
            amount = round(random.uniform(5000, 25000), 2)
            payment_method = 'employers remmitance'
            # Assign EmployerID as (MemberID mod 20) + 1 to simulate valid employer reference (since you have 20 employers)
            employer_id = (member_id % 20) + 1
        
        # Format the INSERT statement. GETDATE() is used to set the contribution date.
        # Note: For SQL Server, numeric values and NULL do not need quotes.
        if employer_id == "NULL":
            employer_str = "NULL"
        else:
            employer_str = str(employer_id)
        
        insert_stmt = (
            f"INSERT INTO Contributions (MemberID, EmployerID, ContributionDate, Amount, PaymentMethod) "
            f"VALUES ({member_id}, {employer_str}, GETDATE(), {amount}, '{payment_method}');"
        )
        f.write(insert_stmt + "\n")
