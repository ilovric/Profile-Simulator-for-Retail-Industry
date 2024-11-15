# Profile-Simulator-for-Retail-Industry

Project to simulate the creation of customer profiles and their ingestion into the marketing system.

1. Clone this repo
2. Make sure you have Docker installed and running on your computer.
3. Run `docker compose -f ".\compose-db.yml" up` to start database and execute `init.sql` script
4. Run `docker compose -f ".\compose-runner.yml" up` to start runner which creates profiles every 0 to 5 sec
4. Run `docker compose -f ".\compose-listner.yml" up` to start listener which will write JSON into results folder

**Note:**
Tested on Intel i5 CPU (amd64 architecture).
Each time a new profile is generated, an insert occurs into 5 different tables, which are related through foreign keys. 
An AFTER INSERT trigger has been created on each of the tables, which generates a JSON object based on the data in that table. Additionally, a message is enqueded to AQ in each trigger.

To access the Oracle database, use some of the tool (Oracle SQL Developer, SQL*Plus, TOAD etc). 
Connection string for access to database ihuser/ihuser@localhost:1521/FREEPDB1.
