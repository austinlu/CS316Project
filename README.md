Pollugraphics
=============

Peggy Li, Austin Lu, Lawrence Lin


Setup instructions
------------------

1. Make sure you have pulled the latest changes from https://github.com/austinlu/CS316Project (or retrieved the latest changes on your local machine, i.e. laptop, and copied them to your VM). 

	Do NOT change the directory structure or rename any files or directories unless you are sure that is safe to do so. There may be issues running the setup script or using django if certain files or directories are renamed or moved.

2. In django/mysite/settings.py, edit DATABASES by adding your username and password for the local Postgres server. Make sure host is set to 'localhost'.

3. In the django/ directory, run:

	./setup.sh

	This script should create a new Postgres database called pollugraphics and create tables in the database with schemas based on the django models. It will then load the clean datasets from CSV files located in the data/ directory. 

4. That's all! Open your browser and visit http://HOSTNAME/django/pollugraphics to confirm that django is working. 

	Note: the exact URL may vary based on your server setup, such as where your project directory is located. For example, mine (Peggy's) is actually at: http://dukedb-pl59.cloudapp.net/CS316Project/django/pollugraphics/


Description of files
--------------------

The top level project directory CS316Project/ should contain the following subdirectories:

* data - clean data files in CSV format and setup.sql for creating database tables without django (not used)
* Data Cleaning - original data files and scripts used for cleaning the data
* django - self-explanatory :)
* Samples - sample data, queries, and output from Milestone 1
* Test Production - SQL test queries and output using production data

Technology Stack (Platform)
---------------------------

* Database: PostgreSQL
* Back-end: Python (using Django)
* Front-end: HTML, CSS (with Boostrap), JavaScript

