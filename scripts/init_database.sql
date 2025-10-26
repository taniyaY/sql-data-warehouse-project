/* 
=========================================================
CREATE Database And Schemas;
=========================================================
Purpose:
	This script create a new database after checking if 
	it already exists. 
	If database exists, it drop and recreate the new database.
	In addition, it also creates three schemas within 
	the database: 'bronze', 'silver' and 'gold.' 

Warning
	Running the given script will drop the existing database
	if it exists. This will permanently delete all the data
	in the database so proceed with caution and ensure to have 
	proper backups before running the query.
*/

USE master;
GO

-- DROP and Recreate the 'DataWarehouse' Database
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN 
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

-- CREATE 'DataWarehouse' Database
CREATE DATABASE DataWarehouse;
GO

-- USE DataWarehouse
USE DataWarehouse;
GO

-- CREATE Schemas: 'bronze', 'silver', 'gold'
CREATE SCHEMA bronze; 
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
