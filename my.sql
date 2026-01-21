
--------------------------- HAUS WORK


CREATE DATABASE lesson4;

\ c lesson4;

DROP TABLE IF EXISTS students;

CREATE TABLE students (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(75) NOT NULL,
    "gender" CHAR(1) NOT NULL,
    "birth_date" DATE NOT NULL,
    "region" VARCHAR(50) NOT NULL,
    "date_of_registration" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO
    students ("name", "gender", "birth_date", "region")
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

CREATE TABLE courses (
    "id" SERIAL PRIMARY KEY,
    "title" VARCHAR(75) NOT NULL,
    "quantity_of_students" INTEGER DEFAULT 0,
    "date_of_creation" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO
    courses ("title")
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

--------------------------------------------
DROP TABLE IF EXISTS enrollments;

CREATE TABLE enrollments (
    "id" SERIAL PRIMARY KEY,
    "student_id" INT REFERENCES students(id) ON DELETE CASCADE ON UPDATE CASCADE,
    "course_id" INT REFERENCES courses(id) ON DELETE CASCADE ON UPDATE CASCADE,
    "date_of_enrollment" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO
    enrollments ("student_id", "course_id")
VALUES
    (1, 1),
    --------------------------------------------
    DROP TABLE IF EXISTS grades;

CREATE TABLE grades (
    "id" SERIAL PRIMARY KEY,
    "student_id" INT REFERENCES students(id) ON DELETE CASCADE ON UPDATE CASCADE,
    "course_id" INT REFERENCES courses(id) ON DELETE CASCADE ON UPDATE CASCADE,
    "grade" INT CHECK (
        "grade" BETWEEN 0
        AND 100
    ),
    "date_of_grade" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO
    grades ("student_id", "course_id", "grade")
SELECT
    student_id,
    course_id,
    (random() * 40 + 60) :: int AS grade
FROM
    (
        SELECT
            s.id AS student_id,
            c.id AS course_id,
            ROW_NUMBER() OVER (
                PARTITION BY s.id
                ORDER BY
                    random()
            ) AS rn
        FROM
            students s
            CROSS JOIN courses c
    ) t
WHERE
    rn <= 3;

SELECT
    *
FROM
    grades
ORDER BY
    "student_id";

SELECT
    *
FROM
    students;

----------------------  1 mission
CREATE
OR REPLACE FUNCTION calculate_age(birth_date DATE) 
RETURNS 
INTEGER AS $$ 
BEGIN 
RETURN EXTRACT(
    YEAR
    FROM
        AGE(CURRENT_DATE, birth_date)
);

END;

$$ LANGUAGE plpgsql;

SELECT
    "name",
    calculate_age("birth_date")
FROM
    students;

-------------------------------  2 mission\


DROP PROCEDURE IF EXISTS enroll_students(INTEGER, TEXT);

CREATE
OR REPLACE PROCEDURE enroll_students(
    course_id INTEGER,
    student_list JSONB
    ) 
LANGUAGE plpgsql
AS $$ 
BEGIN
INSERT INTO
    enrollments (student_id, course_id, date_of_enrollment)
SELECT  
    VALUE::INTEGER,
    course_id,
    CURRENT_TIMESTAMP
FROM
    jsonb_array_elements_text(student_list);
END;
$$;

CALL enroll_students (1, '[1, 2, 3, 4]');
CALL enroll_students (2, '[5, 6, 7, 8]');

SELECT
    *
FROM
    enrollments;

---------------------- 3 #



CREATE TABLE notifications (
    "id" SERIAL PRIMARY KEY,
    "student_id" INT REFERENCES students(id) ON DELETE CASCADE ON UPDATE CASCADE,
    "message" TEXT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



CREATE
OR REPLACE FUNCTION grade_update_notification_function()
RETURNS TRIGGER
AS $$
BEGIN
IF NEW.grade < OLD.grade THEN
INSERT INTO
    notifications ("student_id", "message")
VALUES
    (
        NEW.student_id,
        'Your grade has decreased to ' || NEW.grade || '💪'
    );
ELSIF NEW.grade > OLD.grade THEN
INSERT INTO
    notifications ("student_id", "message")
VALUES
    (
        NEW.student_id,
        'Your grade has increased to ' || NEW.grade || '💪'
    );
END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

------------ TRIGGER

CREATE TRIGGER grade_update_notification
AFTER UPDATE OF grade
ON grades
FOR EACH ROW
WHEN (OLD.grade IS DISTINCT FROM NEW.grade)
EXECUTE FUNCTION grade_update_notification_function();



UPDATE grades
SET grade = 90
WHERE student_id = 1 AND course_id = 5;

UPDATE grades
SET grade = 60
WHERE student_id = 1 AND course_id = 5;

SELECT * FROM notifications;


----------------------- 4 avg_grade

DROP FUNCTION IF EXISTS get_avg_grade;
CREATE 
    OR REPLACE FUNCTION get_avg_grade(my_id INTEGER)
    RETURNS
    NUMERIC AS $$
    DECLARE
        avg_grade NUMERIC;
    BEGIN
        SELECT AVG(grade)
        INTO avg_grade
        FROM grades
        WHERE student_id = my_id
        
        RETURN avg_grade
END;
$$ LANGUAGE plpgsql;

SELECT
    s.name,
    get_avg_grade(s.id) AS avg_grade
FROM
    students s;


SELECT
    s.name,
    get_avg_grade(s.id) AS avg_grade
FROM
    students s
    WHERE id = 7;

SELECT
    s.id,
    s.name,
    get_avg_grade(s.id) AS avg_grade
FROM
    students s
WHERE
    get_avg_grade(s.id) > 80
ORDER BY
    avg_grade DESC;


------------------------------------    5 % 

DROP FUNCTION IF EXISTS ban_duplicat_enrollments;

CREATE
 OR REPLACE FUNCTION ban_duplicat_enrollments()
 RETURNS TRIGGER
 LANGUAGE plpgsql
 AS $$ 
 BEGIN
      IF EXISTS(
        SELECT 1
        FROM enrollments
        WHERE student_id = NEW.student_id
        AND course_id = NEW.course_id
      ) THEN
        RAISE EXCEPTION 'student % is already enrolled in this course %', NEW.student_id, NEW.course_id;
      END IF;
RETURN NEW;
END;
$$;


-------------- trigger

CREATE TRIGGER check_duplicat_enrollments
BEFORE INSERT
ON enrollments
FOR EACH ROW
EXECUTE FUNCTION ban_duplicat_enrollments();



INSERT INTO enrollments(student_id, course_id)
VALUES (1, 1);  

INSERT INTO enrollments(student_id, course_id)
VALUES (7, 8);














-------------------------- dars
CREATE TABLE prodact (
    "id" SERIAL PRIMARY KEY,
    "title" VARCHAR(30) NOT NULL,
    "price" FlOAT NOT NULL,
    "quantity" SMALLINT NOT NULL,
    "details" JSONB NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO
    prodact ("title", "price", "quantity", "details")
VALUES
    (
        'Phone',
        10000,
        10,
        '{
        "brand": "Xiaomi",
        "model": "Redmi Note 9",
        "features": {"ports": ["USB", "Type-C"]}
        }' :: jsonb
    ),
    (
        'Tablet',
        15000,
        5,
        '{
        "brand": "Samsung",
        "model": "Galaxy S30 Ultra Max Pro Plus",
        "features": {"ports": ["USB", "Type-C"]}
        }' :: jsonb
    );

-------------
CREATE TABLE users (
    "id" SERIAL PRIMARY KEY,
    "username" VARCHAR NOT NULL,
    "birth_date" DATE NOT NULL
);

INSERT INTO
    users ("username", "birth_date")
VALUES
    ('John', '2001-01-01'),
    ('Jack', '2002-02-02'),
    ('James', '2003-03-03');

--------------- FUNCTION
CREATE
OR REPLACE FUNCTION calculate_ages (date_of_birth DATE) RETURNS INTEGER AS $ $ RETURN EXTRACT(
    YEAR
    FROM
        AGE(birth_date)
);

END;

$ $ LANGUAGE plpgsql;

SELECT
    username,
    calculate_ages(birth_date)
FROM
    users;

----------- PORCEDURE
CREATE
OR REPLACE PROCEDURE enroll_students (courseID INTEGER, studentList TEXT) LANGUAGE plpgsql AS $ $ DECLARE studentID INTEGER;

cur_cur CURSOR FOR
SELECT
    (jsonb_array_elements_text(studentList :: jsonb)) :: INTEGER;

BEGIN OPEN cur_cur;

LOOP FETCH cur_cur INTO studentID;

EXIT
WHEN NOT FOUND;

INSERT INTO
    enrollments (student_id, course_id, enrollments_date)
VALUES
    (studentID, courseID, CURRENT_TIMESTAMP);

END LOOP;

CLOSE cur_cur;

END;

$ $;

CALL enroll_students (1, '[1, 2, 3, 4]');

SELECT
    *
FROM
    enrollments;

CREATE TABLE course(
    "id" SERIAL PRIMARY KEY,
    "tile" VARCHAR(50) NOT NULL
);

INSERT INTO
    course ("tile")
VALUES
    ('NodeJS'),
    ('Python');

CREATE TABLE enrollments(
    "id" SERIAL PRIMARY KEY,
    "student_id" INTEGER NOT NULL,
    "course_id" INTEGER NOT NULL,
    "enrollment_date" DATE NOT NULL
);

CREATE TABLE students(
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(50) NOT NULL,
    "age" INTEGER NOT NULL
);

INSERT INTO
    students ("name", "age")
VALUES
    ('John', 20),
    ('Jane', 21),
    ('Bob', 22),
    ('Alice', 23),
    ('Charlie', 24),
    ('Diana', 25),
    ('Ethan', 26),
    ('Fiona', 27),
    ('George', 28),
    ('Grace', 29);

-------------------- TRIGGER
CREATE
OR REPLACE FUNCTION grade_update_notification_function()
RETURNS TRIGGER
AS $$
BEGIN
IF NEW.grade < OLD.grade THEN
INSERT INTO
    notifications ("student_id", "message", "created_at")
VALUES
    (
        NEW.student_id,
        "Your grade has decreased to " || NEW.grade,
        CURRENT_TIMESTAMP
    );

END IF;

RETURN NEW;

END;

$$ LANGUAGE plpgsql;

CREATE TRIGGER grade_update_notification
AFTER
UPDATE
    ON students FOR EACH ROW EXECUTE PROCEDURE grade_update_notification_function();