USE pensionsDB;
CREATE TABLE Employers (
    EmployerID INT IDENTITY(1,1) PRIMARY KEY,
    EmployerName VARCHAR(100) NOT NULL,
    EmployerKraPIN VARCHAR(50) UNIQUE NOT NULL, -- Tax ID Number
    ContactPerson VARCHAR(100),
    ContactEmail VARCHAR(100) UNIQUE,
    ContactPhone VARCHAR(20),
    Address VARCHAR(255)
);

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

CREATE TABLE Contributions (
    ContributionID INT IDENTITY(1,1) PRIMARY KEY,
    MemberID INT NOT NULL,
    EmployerID INT,
    ContributionDate DATE NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    PaymentMethod VARCHAR(50) NOT NULL, CHECK (PaymentMethod IN ('Mpesa', 'Bank-transfer', 'employers remmitance')),
    CONSTRAINT fk_contribution_member FOREIGN KEY (MemberID) REFERENCES Members(MemberID) ON DELETE CASCADE,
    CONSTRAINT fk_contribution_employer FOREIGN KEY (EmployerID) REFERENCES Employers(EmployerID) ON DELETE SET NULL
);

CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    MemberID INT NOT NULL,
    PaymentDate DATE NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    PaymentType VARCHAR(50) NOT NULL, CHECK (PaymentType IN ('Retirement', 'Dependants pay')),
    ProcessedBy VARCHAR(100),
    CONSTRAINT fk_payment_member FOREIGN KEY (MemberID) REFERENCES Members(MemberID) ON DELETE CASCADE
);

CREATE TABLE Dependents (
    DependentID INT IDENTITY(1,1) PRIMARY KEY,
    MemberID INT NOT NULL,
    DependentName VARCHAR(100) NOT NULL,
    Relationship VARCHAR(50),
    DateOfBirth DATE,
    CONSTRAINT fk_dependent_member FOREIGN KEY (MemberID) REFERENCES Members(MemberID) ON DELETE CASCADE
);