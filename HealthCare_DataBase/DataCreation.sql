use master
;
go

create database HealthcareDB

on primary
(
 name = 'HealthcareDB',
 size = 30 MB,
 FileGrowth = 10 MB,
 maxsize = unlimited, 
 filename = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQL2025\MSSQL\DATA\HealthcareDB.mdf'
 )

 log on 

(

name = 'HealthcareDB_log',
size = 7 MB,
filegrowth = 10%,
maxsize = 25 MB,
filename =  'C:\Program Files\Microsoft SQL Server\MSSQL17.SQL2025\MSSQL\DATA\HealthcareDB.ldf'
)
;
go