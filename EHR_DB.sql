--- Database for HIV/AIDs clinic
--- Compatible with Microsoft SQL Server 2017 onwards

-----------------------------------------DATABASE SCHEMA --------------------------------------------
-----------------------------------------------------------------------------------------------------

-------- Creating the database
CREATE database ART_ehr;
ALTER DATABASE ART_ehr
MODIFY FILE(NAME = ART_ehr, SIZE = 30MB);

ALTER DATABASE ART_ehr
MODIFY FILE(NAME = ART_ehr, FILEGROWTH = 3000MB)


------- Creating tables 

-- Patients information table
CREATE table Patient_Records(
  Patient_ID varchar(10) NOT NULL PRIMARY KEY,
  Sur_name varchar(50) NOT NULL,
  Other_name varchar(70) NULL,
  Gender varchar(1) NOT NULL CHECK(Gender IN ('M','F')),
  DOB date NOT NULL,
  Nationality varchar(12) CHECK(Nationality IN ('National', 'Non-national')) NOT NULL,
  Address varchar(100) NULL, -- UI will show how this should be entered.
  Contact varchar(10) NULL,
  NIN varchar(14) NULL, -- Only if Nationality is 'National'
  NOK varchar(50) NULL,
  NOK_Contact varchar(9),
  Date_Registered date DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  CHECK (Patient_ID LIKE '[0-9][0-9][0-9]/[A-Z][A-Z][A-Z]/[0-9][0-9]'), -- ID should be of the form '000/XYZ/00'
  CHECK (NIN LIKE '[A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z][A-Z][A-Z][A-Z]'), -- NIN should be of the form 'CM87521457MEMP'
  CHECK (Contact LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
  CHECK (NOK_Contact LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);

-- Patient Medical history
-------- To be filled immediately after the patient has been registered.
CREATE table Med_history(
  Patient_ID varchar(10),
  Recency_results varchar(10) CHECK(Recency_results IN ('Recent', 'Not Recent')),
  First_VL_date date,
  First_VL_Results int,
  First_CD4_count int,
  Last_VL_visit date,
  Last_VL_Results int,
  First_ART_Regimen varchar(11),
  Current_ART_Regimen varchar(11),
  Allergies varchar(100),
  TPT_Status varchar(3) CHECK(TPT_Status IN ('Complete', 'On TPT', 'Not Started')),
  TPT_Start_Date date, --- Only appears when TPT_Status is chosen as 'Complete' or 'On TPT'
  TPT_Completeion_date date, --- Only appears when TPT_Status is chosen as 'Complete'
  TPT_regimen varchar(20), --- Only appears when TPT_Status is chosen as 'Complete' or 'On TPT'
  
  -- Constraints
  FOREIGN KEY (Patient_ID) REFERENCES Patient_Records(Patient_ID),
  CHECK (First_ART_Regimen like '[A-Z][A-Z][A-Z]/[0-9][A-Z][A-Z]/[A-Z][A-Z][A-Z]'),
  CHECK (First_ART_Regimen like '[A-Z][A-Z][A-Z]/[0-9][A-Z][A-Z]/[A-Z][A-Z][A-Z]')
);

-- Staff Information table
------------------ to have a default, be able to add and update users, and linked to login. To start the UI, a user has
create table Staff(
	Staff_ID varchar(6) PRIMARY KEY,
	Surname varchar(50) NOT NULL,
	other_name varchar(50) NOT NULL,
	Username varchar(50) NOT NULL,
	loginPassword varchar(50) not null,
	Department varchar(50) CHECK(Department IN ('Records','ART', 'Counselling', 'Lab', 'Maternity', 'OPD', 'Ward')) NOT NULL,
  
  -- Constraints 
  CHECK (Staff_ID LIKE '[A-Z][A-Z][A-Z][0-9][0-9][0-9]')  -- Staff ids to be of the format 'LAB001', 'OPD111', 'MAT001' and 'WRD001'
);

-- Visit Information table
CREATE table Visit_Info(
  Patient_ID varchar(10),
  Staff_ID varchar(6) PRIMARY KEY, -- Auto entered from login details
  Date_of_Visit date DEFAULT CURRENT_TIMESTAMP,
  Appointment varchar(3) CHECK(Appointment IN ('YES','NO')),
  Last_Scheduled_Appointment date NULL,
  ART_Adherence varchar(9) CHECK(ART_Adherence in ('VERY POOR','POOR', 'GOOD', 'VERY GOOD')),
  ARV_sideEffects varchar(100) NULL,
  TPT_Given varchar(3) CHECK(TPT_Given IN ('YES','NO')), --If TPT Status in Med_history table is either 'On TPT'or 'Not Started'
  TPT_regimen_Given varchar(20),
  Refilled varchar(3) CHECK(Refilled IN ('YES','NO')),
  MMD_given int,
  Due_for_bleeding  varchar(3) CHECK(Due_for_bleeding IN ('YES','NO')),
  Bleeding_needed varchar(20) CHECK(Bleeding_needed IN ('Recency', 'Viral Load', 'CD4')),
  Bleeding_note varchar(20) CHECK(Bleeding_note IN ('Bled', 'Sent to lab', 'Not Bled')),
  Councelling_note varchar(20) CHECK(Councelling_note IN ('Needed', 'Not needed')),
  Clinical_notes varchar(150),
  
  -- Constraints
  FOREIGN KEY (Patient_ID) REFERENCES Patient_Records(Patient_ID),
  FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID)
);

-- Laboratory Information table
CREATE table Labs(
  Lab_No INT IDENTITY(1001, 1) primary key,
  Patient_ID varchar(10),
  Test_Ordered varchar(20) CHECK(Test_Ordered IN ('Recency', 'Viral Load', 'CD4')),
  Sample_taken varchar(3) CHECK(Sample_taken IN ('Yes', 'No')),
  Result float,
  Reason_not_bled varchar(100) NULL,
  
  -- Constraints
  FOREIGN KEY (Patient_ID) REFERENCES Patient_Records(Patient_ID)
);

-- Counselling Information table
CREATE table Counselling(
  Councel_no INT IDENTITY(1001, 1) PRIMARY KEY,
  Patient_ID varchar(10),
  Reason_fr_cnsl varchar(100) NOT NULL,
  Councelling_done varchar(3) CHECK(Councelling_done IN ('Yes', 'No')),
  Outcome_if_Yes varchar(100),
  Reason_if_No varchar(100),
  Next_Appointment date,
  
   -- Constraints
  FOREIGN KEY (Patient_ID) REFERENCES Patient_Records(Patient_ID)
);

---------------------- VIEWS and ANALYSIS ----------------------
------------------------------ VIEWS ----------------------------
-----------------------------------------------------------------
-- 1. Patient Demographics Overview
	-- Quick demographic listing with computed age.
CREATE VIEW vw_Patient_Demographics AS
SELECT 
    Patient_ID,
    CONCAT(Sur_name, ' ', Other_name) AS Full_Name,
    Gender,
    DATEDIFF(YEAR, DOB, GETDATE()) AS Age,
    Nationality,
    Contact,
    Date_Registered
FROM Patient_Records;

-- 2. Patient Treatment Progress Summary----------
	-- Monitor viral load progress and treatment suppression.
CREATE VIEW vw_Patient_Treatment_Summary AS
SELECT 
    p.Patient_ID,
    CONCAT(p.Sur_name, ' ', p.Other_name) AS Full_Name,
    m.First_VL_Results,
    m.Last_VL_Results,
    m.First_ART_Regimen,
    m.Current_ART_Regimen,
    m.TPT_Status,
    DATEDIFF(DAY, m.First_VL_date, m.Last_VL_visit) AS Days_Between_VL,
    CASE 
        WHEN m.Last_VL_Results <= 1000 THEN 'Suppressed'
        ELSE 'Not Suppressed'
    END AS VL_Status
FROM Med_history m
JOIN Patient_Records p ON m.Patient_ID = p.Patient_ID;

-- 3. Visit and Adherence Monitoring
	-- See adherence patterns, refill status, and counseling needs.
CREATE VIEW vw_Visit_Adherence AS
SELECT 
    v.Patient_ID,
    CONCAT(p.Sur_name, ' ', p.Other_name) AS Full_Name,
    v.Date_of_Visit,
    v.ART_Adherence,
    v.Refilled,
    v.Appointment,
    v.MMD_given,
    v.Councelling_note
FROM Visit_Info v
JOIN Patient_Records p ON v.Patient_ID = p.Patient_ID;

-- 4. Lab Test Tracking
	-- Track all lab tests, results, and pending samples.
CREATE VIEW vw_Lab_Tests AS
SELECT 
    l.Lab_No,
    p.Patient_ID,
    CONCAT(p.Sur_name, ' ', p.Other_name) AS Full_Name,
    l.Test_Ordered,
    l.Sample_taken,
    l.Result,
    l.Reason_not_bled
FROM Labs l
JOIN Patient_Records p ON l.Patient_ID = p.Patient_ID;

-- 5. Viral load monthly
CREATE VIEW vw_Monthly_VL_Suppression AS
SELECT 
    FORMAT(m.Last_VL_visit, 'yyyy-MM') AS Month,
    COUNT(*) AS Total_Tested,
    SUM(CASE WHEN m.Last_VL_Results <= 1000 THEN 1 ELSE 0 END) AS Suppressed,
    CAST(SUM(CASE WHEN m.Last_VL_Results <= 1000 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Percent_Suppressed
FROM Med_history m
WHERE m.Last_VL_visit IS NOT NULL
GROUP BY FORMAT(m.Last_VL_visit, 'yyyy-MM');

-- 6. Monthly TPT Completion 
CREATE VIEW vw_Monthly_TPT_Completion AS
SELECT 
    FORMAT(m.TPT_Completeion_date, 'yyyy-MM') AS Month,
    COUNT(*) AS Total_Completed
FROM Med_history m
WHERE m.TPT_Status = 'Complete'
GROUP BY FORMAT(m.TPT_Completeion_date, 'yyyy-MM');

-- 7. Monthly Clinic Visits 
CREATE VIEW vw_Monthly_Visits AS
SELECT 
    FORMAT(Date_of_Visit, 'yyyy-MM') AS Month,
    COUNT(*) AS Total_Visits,
    SUM(CASE WHEN Appointment = 'NO' THEN 1 ELSE 0 END) AS Missed_Appointments
FROM Visit_Info
GROUP BY FORMAT(Date_of_Visit, 'yyyy-MM')
;

-- 8. Counselling Follow-up
	-- Track reasons for counseling and outcomes.
CREATE VIEW vw_Counselling_Summary AS
SELECT 
    c.Councel_no,
    p.Patient_ID,
    CONCAT(p.Sur_name, ' ', p.Other_name) AS Full_Name,
    c.Reason_fr_cnsl,
    c.Councelling_done,
    c.Outcome_if_Yes,
    c.Reason_if_No,
    c.Next_Appointment
FROM Counselling c
JOIN Patient_Records p ON c.Patient_ID = p.Patient_ID;

-- 9. Integrated Patient Summary
	-- For SQL daashboard
CREATE VIEW vw_Full_Patient_Profile AS
SELECT 
    p.Patient_ID,
    CONCAT(p.Sur_name, ' ', p.Other_name) AS Full_Name,
    p.Gender,
    DATEDIFF(YEAR, p.DOB, GETDATE()) AS Age,
    m.Current_ART_Regimen,
    m.Last_VL_Results,
    v.ART_Adherence,
    v.Refilled,
    c.Reason_fr_cnsl,
    c.Councelling_done,
    l.Test_Ordered,
    l.Result
FROM Patient_Records p
LEFT JOIN Med_history m ON p.Patient_ID = m.Patient_ID
LEFT JOIN Visit_Info v ON p.Patient_ID = v.Patient_ID
LEFT JOIN Counselling c ON p.Patient_ID = c.Patient_ID
LEFT JOIN Labs l ON p.Patient_ID = l.Patient_ID;


------------------------------ Analytical Queries ---------------
-----------------------------------------------------------------
-- 1.Patient gender distribution
SELECT Gender, COUNT(*) AS Total
FROM Patient_Records
GROUP BY Gender;

-- 2. Age group breakdown
SELECT 
    CASE 
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) BETWEEN 0 AND 17 THEN 'Child'
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) BETWEEN 18 AND 35 THEN 'Youth'
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) BETWEEN 36 AND 59 THEN 'Adult'
        ELSE 'Elderly'
    END AS Age_Group,
    COUNT(*) AS Total
FROM Patient_Records
GROUP BY 
    CASE 
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) BETWEEN 0 AND 17 THEN 'Child'
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) BETWEEN 18 AND 35 THEN 'Youth'
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) BETWEEN 36 AND 59 THEN 'Adult'
        ELSE 'Elderly'
    END;
-- 3. ART regimen performance
SELECT 
    Current_ART_Regimen,
    AVG(Last_VL_Results) AS Avg_VL_Result,
    SUM(CASE WHEN Last_VL_Results <= 1000 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Percent_Suppressed
FROM Med_history
GROUP BY Current_ART_Regimen;

-- 4. Visit frequency by staff 
SELECT 
    s.Staff_ID,
    CONCAT(s.Surname, ' ', s.other_name) AS Staff_Name,
    s.Department,
    COUNT(v.Patient_ID) AS Patients_Attended
FROM Visit_Info v
JOIN Staff s ON v.Staff_ID = s.Staff_ID
GROUP BY s.Staff_ID, s.Surname, s.other_name, s.Department
ORDER BY Patients_Attended DESC;

-- 5. Lab test distribution
SELECT 
    Test_Ordered,
    COUNT(*) AS Total_Tests,
    AVG(Result) AS Average_Result
FROM Labs
GROUP BY Test_Ordered;

-- 6. Missed appointments tracking
SELECT 
    Patient_ID,
    COUNT(*) AS Missed_Appointments
FROM Visit_Info
WHERE Appointment = 'NO'
GROUP BY Patient_ID;

-- 7. New patients monthly
CREATE VIEW vw_Monthly_New_Patients AS
SELECT 
    FORMAT(Date_Registered, 'yyyy-MM') AS Month,
    COUNT(*) AS Total_New_Patients
FROM Patient_Records
GROUP BY FORMAT(Date_Registered, 'yyyy-MM');


------------------------ END ------------------------
--- NOTE: Views and data analysis to be added upon testing
--- to ease data extraction.

INSERT INTO Staff (Staff_ID, Surname, other_name, Username, loginPassword, Department)
VALUES ('REC001', 'Default', 'Admin', 'admin', 'admin123', 'Records');
