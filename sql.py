import random
import datetime

# --- Helper Functions ---
def random_date(start, end):
    """Return a random date between start and end (both datetime.date objects)."""
    delta = end - start
    random_days = random.randrange(delta.days)
    return start + datetime.timedelta(days=random_days)

def random_datetime(start, end):
    """Return a random datetime between start and end (both datetime objects)."""
    delta = end - start
    random_seconds = random.randrange(int(delta.total_seconds()))
    return start + datetime.timedelta(seconds=random_seconds)

def generate_phone():
    return "+2547" + "".join([str(random.randint(0,9)) for _ in range(8)])

def generate_unique(prefix, length, used_set):
    """Generate a unique code with a given prefix and numeric part of specified length."""
    while True:
        number = "".join([str(random.randint(0,9)) for _ in range(length)])
        code = f"{prefix}{number}"
        if code not in used_set:
            used_set.add(code)
            return code

# --- Data Sources ---
first_names = [
    "James", "John", "Peter", "Mary", "Grace", "Joseph", "Daniel", "Samuel",
    "Catherine", "Ann", "Lucy", "George", "Stephen", "Moses", "David", "Christine",
    "Paul", "Brian", "Oscar", "Victor", "Sarah", "Emily", "Rose", "Boniface", "Victor"
]
last_names = [
    "Kamau", "Wambui", "Mwangi", "Ochieng", "Odhiambo", "Njeri", "Kariuki", 
    "Mutiso", "Njoroge", "Ngugi", "Otieno", "Kiprotich", "Maina", "Karanja", "Kibet",
    "Muriuki", "Kilonzo", "Abebe", "Karanja", "Wairimu", "Chebet", "Mbugua", "Mwende"
]
cities = ["Nairobi", "Mombasa", "Kisumu", "Nakuru", "Thika", "Eldoret", "Kitale", "Kisii", "Machakos", "Meru", "Garissa", "Kitui"]

# --- Configuration ---
total_members = 410
# Approximately 35% must be eligible for pension (assumed eligible if >= 60 years as of 2025-04-03).
pension_count = round(0.35 * total_members)
non_pension_count = total_members - pension_count

# Date ranges:
# For pension eligible: age >= 60 as of 2025-04-03 → born on or before 1965-04-03.
pension_start = datetime.date(1940, 1, 1)
pension_end = datetime.date(1965, 4, 3)
# For non-pension (but at least 18 years old as of 2025-04-03): born after 1965-04-03 up to 2007-04-03.
non_pension_start = datetime.date(1965, 4, 4)
non_pension_end = datetime.date(2007, 4, 3)

# Registration datetime range:
reg_start = datetime.datetime(2024, 1, 1, 0, 0, 0)
reg_end = datetime.datetime(2025, 3, 31, 23, 59, 59)

employment_options = ["Employed", "Self-Employed", "Unemployed"]

# Sets to ensure uniqueness
used_emails = set()
used_kra = set()
used_nssf = set()

# --- Generate Member Records ---
records = []
# First generate pension eligible records.
for _ in range(pension_count):
    first = random.choice(first_names)
    last = random.choice(last_names)
    full_name = f"{first} {last}"
    
    dob = random_date(pension_start, pension_end)
    
    contact = generate_phone()
    
    # Create a unique email; use a random number to help uniqueness.
    while True:
        email_candidate = f"{first.lower()}{last.lower()}{random.randint(100,999)}@example.com"
        if email_candidate not in used_emails:
            used_emails.add(email_candidate)
            email = email_candidate
            break

    address = f"{random.choice(cities)}"
    
    nssf = generate_unique("NSSF", 9, used_nssf)
    kra = generate_unique("KRA", 6, used_kra)
    
    reg_date = random_datetime(reg_start, reg_end).strftime("'%Y-%m-%d %H:%M:%S'")
    
    employment = random.choice(employment_options)
    # Only assign EmployerID if Employed.
    employer_id = random.randint(1,20) if employment == "Employed" else "NULL"
    
    # Format DateOfBirth as YYYY-MM-DD
    dob_str = dob.strftime("'%Y-%m-%d'")
    
    record = f"('{full_name}', {dob_str}, '{contact}', '{email}', '{address}', '{nssf}', '{kra}', {reg_date}, '{employment}', {employer_id})"
    records.append(record)

# Then generate non-pension records.
for _ in range(non_pension_count):
    first = random.choice(first_names)
    last = random.choice(last_names)
    full_name = f"{first} {last}"
    
    dob = random_date(non_pension_start, non_pension_end)
    
    contact = generate_phone()
    
    while True:
        email_candidate = f"{first.lower()}{last.lower()}{random.randint(100,999)}@example.com"
        if email_candidate not in used_emails:
            used_emails.add(email_candidate)
            email = email_candidate
            break

    address = f"{random.choice(cities)}"
    
    nssf = generate_unique("NSSF", 9, used_nssf)
    kra = generate_unique("KRA", 6, used_kra)
    
    reg_date = random_datetime(reg_start, reg_end).strftime("'%Y-%m-%d %H:%M:%S'")
    
    employment = random.choice(employment_options)
    employer_id = random.randint(1,20) if employment == "Employed" else "NULL"
    
    dob_str = dob.strftime("'%Y-%m-%d'")
    
    record = f"('{full_name}', {dob_str}, '{contact}', '{email}', '{address}', '{nssf}', '{kra}', {reg_date}, '{employment}', {employer_id})"
    records.append(record)

# Shuffle the records so pension eligible and non-eligible are mixed.
random.shuffle(records)

# --- Build the SQL file content ---
create_table = """
CREATE TABLE Members (
    MemberID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    DateOfBirth DATE NOT NULL,
    ContactNumber VARCHAR(20),
    Email VARCHAR(100) UNIQUE,
    Address VARCHAR(255),
    NSSFCardNumber VARCHAR(50) UNIQUE,
    KRAPIN VARCHAR(50) UNIQUE,
    RegistrationDate DATETIME DEFAULT GETDATE(),
    EmploymentStatus VARCHAR(20) CHECK (EmploymentStatus IN ('Employed', 'Self-Employed', 'Unemployed')),
    EmployerID INT NULL, -- Only applicable if employed
    CONSTRAINT fk_member_employer FOREIGN KEY (EmployerID) REFERENCES Employers(EmployerID) ON DELETE SET NULL
);
"""

insert_header = "INSERT INTO Members (FullName, DateOfBirth, ContactNumber, Email, Address, NSSFCardNumber, KRAPIN, RegistrationDate, EmploymentStatus, EmployerID) VALUES"
insert_values = ",\n".join(records) + ";"

sql_content = create_table + "\n" + insert_header + "\n" + insert_values

# Save the generated SQL to a file.
output_file = "generated_members.sql"
with open(output_file, "w", encoding="utf-8") as f:
    f.write(sql_content)

print(f"SQL file with {total_members} members has been generated as {output_file}.")
