/*
=============================================================
Create Database
=============================================================
Script Purpose:
    This script initializes the 'DataWarehouse' database by dropping any existing
    instance and creating a fresh database for the project.

WARNING:
    Running this script will permanently delete the existing 'DataWarehouse'
    database and all of its contents. Ensure you have appropriate backups
    before executing this script.
*/

DROP DATABASE IF EXISTS DataWarehouse;

CREATE DATABASE DataWarehouse;

USE DataWarehouse;
