CREATE DATABASE lesson4;

\c lesson4;


DROP TABLE IF EXISTS students;

CREATE TABLE students(
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(75) NOT NULL,
    "gender" CHAR(1) NOT NULL,
    "birth_date" DATE NOT NULL, 
    "region" VARCHAR(50) NOT NULL
);


----------------------------------------


INSERT INTO students ("name", "gender", "birth_date", "region")
VALUES
    ('John', 'M', '2001-01-01', 'Tashkent'),
    ('Jane', 'F', '2002-02-02', 'Urgench'),
    ('Bob', 'M', '2003-03-03', 'Buxoro'),
    ('Alice', 'F', '2004-04-04', 'Samarkand'),
    ('Charlie', 'M', '2005-05-05', 'Navoiy'),
    ('Diana', 'F', '2006-06-06', 'Nukus'),
    ('Ethan', 'M', '2007-07-07', 'Khiva'),
    ('Fiona', 'F', '2008-08-08', 'Samarqand'),
    ('George', 'M', '2009-09-09', 'Khiva'),
    ('Grace', 'F', '2010-10-10', 'Tashkent'),
    ('Harry', 'M', '2011-11-11', 'Urgench'),
    ('Isabella', 'F', '2012-12-12', 'Buxoro'),
    ('Jack', 'M', '2013-03-03', 'Samarkand'),
    ('Kate', 'F', '2014-04-04', 'Navoiy'),
    ('Liam', 'M', '2015-05-05', 'Nukus'),
    ('Mia', 'F', '2016-06-06', 'Khiva'),
    ('Noah', 'M', '2017-07-07', 'Samarqand'),
    ('Olivia', 'F', '2018-08-08', 'Khiva'),
    ('Owen', 'M', '2019-09-09', 'Tashkent'),
    ('Penelope', 'F', '2020-10-10', 'Urgench'),
    ('Quinn', 'M', '2021-11-11', 'Buxoro');


-----------------------------------------------------



DROP TABLE IF EXISTS courses;

CREATE TABLE courses(
    "id" SERIAL PRIMARY KEY,
    "title" VARCHAR(75) NOT NULL,
    "date" DATE DEFAULT CURRENT_DATE
);



INSERT INTO courses ("title", "date")
VALUES 
    ('NodeJS'),
    ('Python'),
    ('Pascal'),
    ('Delphi'),
    ('Java'),
    ('PHP'),
    ('C++'),
    ('C#'),
    ('C'),
    ('JavaScript'),
    ('SQL'),
    ('HTML'),
    ('React');








    ----------------------------------


    

























    SELECT * FROM students;