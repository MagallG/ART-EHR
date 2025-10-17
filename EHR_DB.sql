-- Creating the database
CREATE database IF NOT EXISTS ART_ehr;
ALTER DATABASE ART_ehr;
MODIFY FILE(NAME = ART_ehr, SIZE = 30MB);

ALTER DATABASE ART_ehr;
MODIFY FILE(NAME = ART_ehr, FILEGROWTH = 300MB);

-- Creating tables

-- Patients information table

CREATE table IF NOT EXISTS Patient_Records(
  Patient_ID varchar(10) NOT NULL PRIMARY KEY,
  Sur_name varchar(50) NOT NULL,
  Other_names varchar(70) NULL,
  Gender varchar(1) NOT NULL CHECK(Gender IN ('M','F')),
  DOB date NOT NULL,
  Nationality varchar(12) CHECK(Nationality IN ('National', 'Non-national')) NOT NULL,
  Address varchar(100) NULL, -- UI will show how this should be entered.
  Contact varchar(10) NULL,
  NIN varchar(14) NULL,
  NOK varchar(50) NULL,
  NOK_Contact varchar(9),
  Date_Registered date,
-- Constraints
  CHECK (Patient_ID REGEXP '^[0-9]{3}/[A-Z]{3}/[0-9]{2}$'), -- ID should be of the form '000/XYZ/00'
  CHECK (NIN REGEXP '^[A-Z]{2}[0-9]{8}[A-Z]{4}$'), -- NIN should be of the form 'CM87521457MEMP'
  CHECK (Contact REGEXP '^[0-9]{10}$'),
  CHECK (NOK_Contact REGEXP '^[0-9]{10}$'));

-- Patient Records table
CREATE table IF NOT EXISTS Med_details(
  Patient_ID varchar(10),
  First_Regimen varchar(11) NOT NULL,
  Current_Regimen varchar(11),
  Allergies varchar(100),
  TPT_STatus varchar(20) CHECK(TPT_STatus in ('Completed', 'On TPT', 'Not started'))
-- Constraints
  FOREIGN KEY (Patient_ID) REFERENCES Patient_Records(Patient_ID),
  CHECK (First_Regimen REGEXP '^[A-Z]{3}/[0-9]{1}[A-Z]{2}/[A-Z]{3}$'),
  CHECK (Current_Regimen REGEXP '^[A-Z]{3}/[0-9]{1}[A-Z]{2}/[A-Z]{3}$'));


-- Visit Information table
CREATE table IF NOT EXISTS Visit_Info(
  Visit_ID integer AUTO_INCREMENT = 10001 PRIMARY KEY,
  Date_of_Visit date DEFAULT current_date,
  Appointment_Kept varchar(3) CHECK(Appointment_Kept IN ('Yes', 'No')) NOT NULL,
  If_no_Last_Appt date,
  Adherence varchar(10) CHECK(Adherence IN ('Very Poor', 'Poor', 'Good', 'Very Good')),
  Drug_Sideeffects varchar(100) NULL,
  TB_Status varchar(10) CHECK(TB_Status IN ('Symptonous', 'Non Symptonous') NULL,
  TB_Symptoms varchar(50),
  TB_test_ordered  varchar(3)CHECK(TB_test_ordered IN ('Yes', 'No')) NULL,
  TPT_given Varchar(3) CHECK(TPT_given IN ('Yes', 'No') NULL,
  TPT_Start_Date date NULL,
  TPT_REGIMEN Varchar(30), -- .............
  TPT_MMD integer,
  Send_to_Lab Varchar(3) CHECK(Send_to_Lab IN ('Yes', 'No')) NOT,
  Test_Ordered
  ARV_Dispensed
  ARV_Regimen
  Days_Dispensed
  Clinicians_notes
  Counselling_Needed?
  Reason_for_counselling

);

-- Laboratory Information table
-- Counselling Information table
-- Staff Information table
-- Pharmacy
-- Views

describe Med_details;
