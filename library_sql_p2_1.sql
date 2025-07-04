-- LIBRABY MANAGEMENT PROJECT

-- CREATING BRANCH TABLE
DROP TABLE IF EXISTS branch;

CREATE TABLE branch (
branch_id varchar(10) PRIMARY KEY,
manager_id varchar(10),
branch_address varchar(50),
contact_no varchar(10)
)
ALTER TABLE branch
ALTER COLUMN contact_no TYPE VARCHAR(20);

DROP TABLE IF EXISTS employees;
CREATE TABLE employees(
emp_id varchar(10) PRIMARY KEY,
emp_name varchar(25),
position varchar(15),
salary INT,
branch_id varchar(25) --FK
)

DROP TABLE IF EXISTS books;
Create table books(
isbn VARCHAR(20) PRIMARY KEY,
book_title VARCHAR(75),
category VARCHAR(10),
rental_price FLOAT,
status VARCHAR(15),
author VARCHAR(35),
publisher VARCHAR(55)
);
ALTER TABLE books
ALTER COLUMN category TYPE VARCHAR(20);

DROP TABLE IF EXISTS members;
CREATE TABLE members(
member_id VARCHAR(20) PRIMARY KEY,
member_name VARCHAR(25),
member_address VARCHAR(75),
reg_date DATE
);

DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status(
issued_id VARCHAR(15) PRIMARY KEY,
issued_member_id VARCHAR(10), -- FK
issued_book_name VARCHAR(75),
issued_date DATE,
issued_book_isbn VARCHAR(25), --FK
issued_emp_id VARCHAR(10)
);

DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status(
return_id VARCHAR(10) PRIMARY KEY,
issued_id VARCHAR(10),
return_book_name VARCHAR(75),
return_date DATE,
return_book_isbn VARCHAR(20)
);

-- FOREIGN KEY
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employee
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

