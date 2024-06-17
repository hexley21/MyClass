CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE SCHEMA IF NOT EXISTS client;
CREATE SCHEMA IF NOT EXISTS class;

CREATE TYPE ROLE AS ENUM ('ADMIN', 'OWNER', 'TEACHER', 'STUDENT');
CREATE TYPE CURRENCY AS ENUM ('USD', 'EUR', 'GEL');

CREATE TABLE IF NOT EXISTS client.user(
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
    email VARCHAR(255) UNIQUE CHECK(EMAIL ~ '^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|.(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$') NOT NULL,
    firstname VARCHAR(50) CHECK(FIRSTNAME ~ '^[a-z]{2,}$') NOT NULL,
    lastname VARCHAR(50) CHECK(LASTNAME ~ '^[a-z]{2,}$') NOT NULL,
    phone VARCHAR(25) CHECK(PHONE ~ '^[0-9]*$'),
    hash VARCHAR(128) NOT NULL CHECK(LENGTH(hash) = 128),
    role ROLE NOT NULL,
    user_status BOOLEAN DEFAULT FALSE NOT NULL
);

CREATE TABLE IF NOT EXISTS client.owner(
    id UUID REFERENCES client.user(id) ON DELETE CASCADE NOT NULL,
    owner_name VARCHAR(50) CHECK(owner_name ~ '^(?!\s)(?!.*\s$)(?=.*[a-zA-Z0-9])[a-zA-Z0-9 ''~?!]{2,}$') NOT NULL,
    PRIMARY KEY(id)
);

CREATE TABLE IF NOT EXISTS class.subject(
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
    owner_id UUID REFERENCES client.user(id) ON DELETE CASCADE NOT NULL,
    code VARCHAR(32) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    syllabus TEXT NOT NULL,
    price NUMERIC(10, 4) CHECK (price > 1 OR price = 0) DEFAULT 0 NOT NULL,
    currency CURRENCY NOT NULL,
    min_grade NUMERIC(5, 2) CHECK (min_grade >= 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS class.group(
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
    subject_id UUID REFERENCES class.subject(id) ON DELETE CASCADE NOT NULL,
    teacher_id UUID REFERENCES client.user(id) ON DELETE CASCADE NOT NULL,
    capacity INTEGER CHECK (capacity > 0 AND capacity < 100) NOT NULL
);

CREATE TABLE IF NOT EXISTS class.lesson(
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
    subject_id UUID REFERENCES class.subject(id) ON DELETE CASCADE NOT NULL,
    name VARCHAR(255) CHECK(LENGTH(name) > 0) NOT NULL,
    date DATE NOT NULL,
    description TEXT,
    attachments TEXT
);

CREATE TABLE IF NOT EXISTS class.quiz(
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
    subject_id UUID REFERENCES class.subject(id) ON DELETE CASCADE NOT NULL,
    max_grade NUMERIC(5, 2) CHECK(max_grade > 0) NOT NULL,
    min_percentage INTEGER CHECK (min_percentage >= 0 AND min_percentage <= 100) NOT NULL,
    date DATE NOT NULL,
    deadline DATE CHECK (deadline > date)
);

CREATE TABLE IF NOT EXISTS class.attendance(
    lesson_id UUID REFERENCES class.lesson(id) ON DELETE CASCADE NOT NULL,
    student_id UUID REFERENCES client.user(id) ON DELETE CASCADE NOT NULL,
    PRIMARY KEY(lesson_id, student_id)
);

CREATE TABLE IF NOT EXISTS class.grade(
    quiz_id UUID REFERENCES class.quiz(id) ON DELETE CASCADE NOT NULL,
    subject_id UUID REFERENCES class.subject(id) ON DELETE CASCADE NOT NULL,
    student_id UUID REFERENCES client.user(id) ON DELETE CASCADE NOT NULL,
    teacher_id UUID REFERENCES client.user(id) ON DELETE SET NULL,
    grade NUMERIC(5, 2) CHECK (grade >= 0) DEFAULT 0 NOT NULL,
    PRIMARY KEY(quiz_id, subject_id, student_id, teacher_id)
);