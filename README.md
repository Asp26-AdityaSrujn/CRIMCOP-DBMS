# CRIMCOP-DBMS
Police Station Network and Criminal Records Management System — DBMS Project
An Operational Police Station Network and Criminal Records 
Management System built using MySQL and Java JDBC.

## Database
- MySQL database: `crimcop`
- 13 tables, 18 relationships
- Import: `mysql -u root -p crimcop < crimcop_dump.sql`

## Java Application
- File: `CRIMCOPApp.java`
- Requires: MySQL Connector/J JAR
- Add your credentials to `db.properties`

## Run
javac -cp .;mysql-connector-j-8.x.x.jar CRIMCOPApp.java
java  -cp .;mysql-connector-j-8.x.x.jar CRIMCOPApp

## Tech Stack
MySQL 8.0 | Java JDBC | MySQL Connector/J
