USE HealthcareDB;
GO


--Retrieve all Patients born after January 1, 1980 who reside in 'New York' or 'Boston', ordered by LastName ascending.


SELECT PatientID,
       FirstName,
       LastName,
       DOB,
       Gender,
       City,
       RegistrationDate
FROM dbo.Patients
WHERE DOB > '1980-01-01'
  AND City IN ('New York', 'Boston')
ORDER BY LastName ASC;
GO

--Calculate the total number of Appointments and the total BillingAmount generated per Facility. Filter out facilities with total billing under $5,000 using HAVING
-- Assumes Appointments.FacilityID exists and Facilities.FacilityName exists. Adjust schema/column names if different.

SELECT FacilityID,
       f.FacilityName,
       COUNT(a.AppointmentID) AS TotalAppointments,
       SUM(a.BillingAmount)    AS TotalBillingAmount
FROM dbo.Appointments AS a
LEFT JOIN dbo.Facilities  AS f ON FacilityID = f.FacilityID
GROUP BY FacilityID, f.FacilityName
HAVING SUM(a.BillingAmount) >= 5000;
GO


--Retrieve all Patients whose FirstName starts with the letter 'J' and who registered during the calendar year 2023, ordered by RegistrationDate descending.

Select PatientID,
       FirstName,
       Lastname,
       DOB
       from Patients
       Where FirstName LIKE 'J%'
       and RegistrationDate BETWEEN '2023-01-01' and '2023-12-31'
       order by RegistrationDate DESC;
       GO


--Calculate the total number of appointments, the count of completed appointments (Status = 'Completed'), and the average billing amount for all appointments across the database.


SELECT COUNT(AppointmentID) AS TOTALAPPOINTMENT,
       SUM(CASE WHEN 'Status'= 'Completed' Then 1 else 0 end ) AS CompletedApp,
       AVG(BillingAmount) as AvgBillingAmount
       from Appointments

--Display AppointmentID, Patient Full Name, Physician Full Name, Specialty, and AppointmentDate by joining Patients, Physicians, and Appointments.

Select 
        a.AppointmentID,
     CONCAT(p.firstname,  '  ' , p.lastname) as patientname,
     CONCAT(h.firstname, '   ' , h.lastname) as fullphysicianname,
     h.Specialty,
      a.AppointmentDate
      from Appointments as a 
      inner join Patients as p on  a.PatientID = p.PatientID
      inner join Physicians as h on  a.PhysicianID = h.PhysicianID;
      go


      --List all Patients who have NEVER booked an appointment. Display PatientID, FirstName, LastName, and RegistrationDate.

      Select 
       a.PatientID,
       a.Firstname,
       a.Lastname,
       a.RegistrationDate,
       p.AppointmentDate
       from Patients as a 
       left join Appointments as p on a.PatientID = p.PatientID
       Where a.PatientID is null ;
       go


       --Retrieve all Prescriptions by joining Prescriptions, Appointments, Patients, and Physicians. Display Patient Full Name, Physician Full Name, MedicationName, and Cost.


       Select 
        CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
        CONCAT(ph.FirstName, ' ', ph.LastName) AS PhysicianName,
        pr.MedicationName,
        pr.Cost
       FROM Prescriptions pr
       INNER JOIN Appointments a ON pr.AppointmentID = a.AppointmentID
       INNER JOIN Patients p ON a.PatientID = p.PatientID
       INNER JOIN Physicians ph ON a.PhysicianID = ph.PhysicianID;
       GO




       --Find all pairs of Physicians who work in the same Facility. Display Physician 1 Name, Physician 2 Name, and FacilityID (ensure no duplicate or self-matching pairs).


       Select 
       CONCAT(P1.firstname , '  ' , p1.lastname) as physiciansAname,
       CONCAT(p2.firstname, '   '  , p2.lastname) as pyhsiciansBname,
       p1.facilityid
       from Physicians as p1
       inner join Physicians as p2 on p1.FacilityID = p2.FacilityID
       where p1.PhysicianID < p2.PhysicianID;
       go

       ---Find all Prescriptions where the Cost is strictly higher than the overall average prescription cost across the entire database.

       Select
         PrescriptionID,
         MedicationName,
         Dosage
         from Prescriptions
         Where Cost > (Select AVG(COST) FROM Prescriptions);
         go


         --Retrieve all Physicians who have treated at least one patient with a diagnosis of 'Hypertension' in the Appointments table without using an INNER JOIN.

         Select 
         PhysicianID,
         CONCAT(p.firstname , '  ' , p.lastname) as physicianfullname
         from Physicians as p
         Where Exists(
         Select 1
          from Appointments as a 
          where a.PhysicianID = p.PhysicianID
          and  Diagnosis = 'Hypertension')



          --Retrieve the FirstName, LastName, and Specialty of all Physicians who have conducted appointments at facilities
          --located in either 'New York' or 'San Francisco' using a subquery with the IN operator.

          Select 
          Firstname,
          Lastname,
          Specialty
          from Physicians
          Where FacilityID in (
          Select FacilityID
          from Facilities
          Where City IN(  'New York','San Francisco' )
          )


   --Write a CTE named PatientSpend that calculates total prescription costs per patient. In the main query, return patients whose total prescription spend exceeds $1,000.


          WITH PatientSpend AS (
          Select 
               PrescriptionID,
               SUM(COST) AS TotalCost
               FROM Prescriptions
               GROUP BY  PrescriptionID
               )
               Select PrescriptionID,TotalCost
               from PatientSpend
               WHERE TotalCost>1000;
               GO





 --Create a unified activity stream combining Appointments (Type = 'Appointment') and Prescriptions (Type = 'Prescription') for a specific PatientID, ordered chronologically by EventDate.


 -- Define the target patient parameter
    

SELECT 
    'Appointment' AS ActivityType,
    AppointmentID AS EventID,
    PatientID,
    AppointmentDate AS EventDate,
    Status AS EventStatus,
    CAST(BillingAmount AS DECIMAL(10,2)) AS Cost
FROM Appointments
WHERE PatientID = 1

UNION ALL 

SELECT 
    'Prescription' AS ActivityType,
    p.PrescriptionID AS EventID,
    a.PatientID,
    p.PrescriptionDate AS EventDate,
    CONCAT(p.MedicationName, ' - ', p.Dosage) AS EventStatus, -- Reused this column for Medication details
    CAST(p.Cost AS DECIMAL(10,2)) AS Cost
FROM Prescriptions AS p
INNER JOIN Appointments AS a ON a.AppointmentID = p.AppointmentID
WHERE a.PatientID = 1 

ORDER BY EventDate;




--Build two chained CTEs: the first calculates total billing amount and appointment count per patient; the second classifies patients into risk tiers ('High Spend', 'Moderate Spend', 'Low Spend')
--. Output PatientID, TotalBilling, and SpendTier.



With first_cte as (Select 
PatientID,
COUNT(AppointmentID) as AppointmentCount,
SUM(BillingAmount) TotalBilling 
from Appointments
GROUP BY patientID
),
  second_cte as (

 Select 
 PatientID,
 Diagnosis,
 BillingAmount,
 CASE 
   when BillingAmount < 500 then 'Low Spend'
   When BillingAmount Between 500 and 1000 Then 'Moderate Spend'
   When BillingAmount > 1000 then 'High Spend'
   end as SpenTier 
   from Appointments
   )

   Select 
 first_cte.Patientid,
 first_cte.AppointmentCount,
 first_cte.TotalBilling ,
 second_cte.Diagnosis,
 second_cte.SpenTier 
 from first_cte
 join second_cte on first_cte.PatientID = second_cte.PatientID






 --Write a recursive CTE to traverse a parent-child facility structure, generating a hierarchical path string and depth level for each facility or department

 -- 0. Ensure the ParentFacilityID column exists in your Facilities table
-- (Run this once if you haven't added it yet)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Facilities') AND name = 'ParentFacilityID')
BEGIN
    ALTER TABLE Facilities ADD ParentFacilityID INT NULL FOREIGN KEY REFERENCES Facilities(FacilityID);
END
GO

With FacilityTree as (

Select 
FacilityID,
FacilityName,
ParentFacilityID,
0 as DepthLevel,
Cast(FacilityName as VARCHAR(MAX)) AS Fullpath
FROM Facilities
Where ParentFacilityID is Null 

Union All 

Select 
  Child.FacilityID,
  Child.facilityName,
  Child.ParentFacilityID,
  ParentTree.DepthLevel + 1,
  CAST(ParentTree.Fullpath + ' > ' + Child.FacilityName as varchar(Max))
  from Facilities Child
  inner join FacilityTree ParentTree on Child.ParentFacilityID = ParentTree.FacilityID
  )

  Select* from FacilityTree




  --Rank all appointments for each patient chronologically using ROW_NUMBER() OVER(PARTITION BY PatientID ORDER BY AppointmentDate ASC).

  Select
    Patientid,
  Appointmentid,
  AppointmentDate,
  ROW_NUMBER () Over ( Partition By PatientID Order By AppointmentDate asc) as AppointmentRank 
  from Appointments


  --Also rank physicians by total billing using DENSE_RANK().

 SELECT 
    a.AppointmentID,
    p.PhysicianID,
    p.FirstName,
    p.LastName,
    a.BillingAmount,
    DENSE_RANK() OVER (PARTITION BY p.PhysicianID ORDER BY a.BillingAmount ASC) AS BillingRank
FROM Physicians AS p
JOIN Appointments AS a ON a.PhysicianID = p.PhysicianID;



--Calculate a cumulative running total of BillingAmount per patient over time using SUM() OVER(...

Select
Patientid,
AppointmentDate, 
SUM(BillingAmount) Over (order by AppointmentID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_totaL
FROM Appointments




--LAG() to calculate the days elapsed since their previous appointment.
 
  Select 
   PatientID,
   AppointmentID,
   AppointmentDate,
   LAG(AppointmentDate,1) over (partition by PatientID ORDER BY AppointmentDate ASC) as PreviousAppointment,

   datediff( day ,
   LAG(AppointmentDate,1) over (partition by PatientID ORDER BY AppointmentDate ASC), Appointmentdate)
   as dayssincelastappointment

   from appointments



   ---Divide all appointments into 4 cost quartiles using NTILE(4) based on BillingAmount, and calculate a 
   --3-appointment moving average of BillingAmount per patient using AVG() OVER(PARTITION BY PatientID ORDER BY AppointmentDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  --).

  ---Divide all appointments into 4 cost quartiles using NTILE(4) based on BillingAmount, and calculate

  Select 
  Appointmentid,
  Patientid,
  Appointmentdate,
  BillingAmount,
  NTILE(4) over (order by  BillingAmount asc) as Quartile
  from Appointments
  


  --calculate a 3-appointment moving average of BillingAmount per patient 
  --using AVG() OVER(PARTITION BY PatientID ORDER BY AppointmentDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  
  Select 
  PatientID,
  AppointmentDate,
  BillingAmount,
  AVG(BillingAmount) over (Partition by PatientID 
  ORDER BY AppointmentDate 
  rows between 2 preceding and current row) as  MovingAvg3Appointments
  from Appointments




  --Use LEAD() OVER(PARTITION BY PatientID ORDER BY AppointmentDate)
  --to display each patient's appointment date alongside their next scheduled appointment date, calculating the gap in days between visits.

  SELECT 
  PatientID,
  AppointmentDate,
  LEAD(AppointmentDate)  OVER(PARTITION BY PatientID 
  ORDER BY AppointmentDate) 
  as nextAppointmentDate,

  DateDiff(
  DAY,
  AppointmentDate,
   LEAD(AppointmentDate) OVER (PARTITION BY PatientID 
   ORDER BY AppointmentDate)
   ) as Daysbetweenvisits
   from appointments;


  