SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

-- PROJECT TASKS

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn,book_title,category, rental_price,status,author,publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address='708 Oak St'
WHERE member_id='C103';

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS125' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id='IS125';

--Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * from issued_status 
WHERE issued_emp_id='E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT issued_member_id,COUNT(*) FROM issued_status 
GROUP BY 1 HAVING COUNT(*)>1;

-- CREATE TABLE AS SELECT STATEMENT
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE books_issued_count AS
SELECT b.isbn,b.book_title, COUNT(ist.issued_id) AS issue_count FROM
issued_status AS ist JOIN
books AS b 
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
SELECT * FROM  books_issued_count

-- Task 7. Retrieve All Books in a DIFFERENT Category:
SELECT * FROM books
WHERE category = 'Classic';

--Task 8: Find Total Rental Income by Category:
SELECT b.category,SUM(b.rental_price),count(*) as issued_count
FROM books AS b 
JOIN issued_status as ist ON
ist.issued_book_isbn= b.isbn
GROUP BY 1

INSERT INTO members VALUES ('C112','James','112 Pine St','2025-05-06');
INSERT INTO members VALUES ('C113','William','123 oAK St','2025-05-21');

-- TASK 9 List Members Who Registered in last 180 days:
SELECT * FROM members WHERE reg_date >= CURRENT_DATE - INTERVAL '180 DAYS';

--TASK10 List Employees with Their Branch Manager's Name and their branch details:
SELECT e.emp_id,e.emp_name,e.position,e.salary,
       b.branch_id, b.branch_address,
	   e1.emp_name AS MANAGER 
	   FROM employees AS e Join branch as b 
	   ON e.branch_id= b.branch_id
	   JOIN employees as e1
	   ON b.manager_id= e1.emp_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;

------------------------------------------------------------
-- ADVANCE QUERIES

-- TASK 13 Identify Members with Overdue Books. Write a query to identify members who have overdue books (assume a 450-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
-- issued_status==members==books==return_status
-- filter books that are returned
-- overdue if > 450 days

SELECT CURRENT_DATE

SELECT 
ist.issued_member_id,m.member_name,b.book_title, ist.issued_date,
rs.return_date, CURRENT_DATE- ist.issued_date AS overdue_days
FROM issued_status AS ist
JOIN members AS m ON m.member_id= ist.issued_member_id
JOIN books AS b ON b.isbn= ist.issued_book_isbn
LEFT JOIN return_status AS rs ON rs.issued_id= ist.issued_id
WHERE rs.return_date IS NULL AND (CURRENT_DATE- ist.issued_date)>450
ORDER BY 1;

--Task 14: Update Book Status on Return.Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
SELECT * FROM books;
SELECT *FROM issued_status;
-- TESTING CODE

SELECT * FROM issued_status WHERE issued_book_isbn='978-0-330-25864-8';
SELECT * FROM books WHERE isbn='978-0-330-25864-8';
SELECT * FROM return_status WHERE  issued_id='IS140';
UPDATE books SET status='no'WHERE isbn='978-0-330-25864-8';

-- ONCE RETURNED
INSERT INTO return_status(return_id,issued_id,return_date) VALUES
('RS125','IS140',CURRENT_DATE);
SELECT * FROM return_status WHERE  issued_id='IS140';
UPDATE books SET status='yes' WHERE isbn='978-0-330-25864-8';

--STORE PROCEDURE
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id varchar(10),p_issued_id varchar(30))
LANGUAGE plpgsql
AS $$
DECLARE
v_isbn varchar(20);
v_book_name varchar(40);

BEGIN
INSERt INTO return_status(return_id,issued_id,return_date)
VALUES(p_return_id,p_issued_id,CURRENT_DATE);

SELECT issued_book_isbn, issued_book_name INTO v_isbn,v_book_name FROM issued_status
WHERE issued_id=p_issued_id;

UPDATE books SET status='yes'
WHERE isbn= v_isbn; 

RAISE NOTICE 'THANK YOU FOR RETURNING THE BOOK:%',v_book_name;

END
$$


CALL add_return_records('RS138','IS135')

-- CHECKING

SELECT * from books WHERE isbn='978-0-7432-4722-5';
SELECT * from issued_status WHERE issued_book_isbn='978-0-7432-4722-5';
SELECT * from return_status WHERE issued_id='IS133';
-- BOOK IS NOT RETURNED
UPDATE books SET status='no'WHERE isbn='978-0-7432-4722-5';

CALL add_return_records('RS139','IS133');

-- Branch Performance Report 
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM books;

CREATE TABLE brach_reports AS
SELECT b.branch_id, b.manager_id,SUM(bk.rental_price) AS total_revenue,
COUNT(ist.issued_id) as books_issued, COUNT(rs.return_id) as books_returned
FROM
issued_status AS ist JOIN employeeS as e
ON ist.issued_emp_id= e.emp_id
JOIN branch AS b 
ON b.branch_id= e.branch_id
LEFT JOIN  return_status AS rs
ON rs.issued_id=ist.issued_id
JOIN books AS bk 
ON bk.isbn= ist.issued_book_isbn
GROUP BY 1,2
ORDER BY 1;

--  CTAS: Create a Table of Active Members. Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

DROP TABLE IF EXISTS active_members;
CREATE TABLE active_members AS
SELECT m.member_id AS member_id,m.member_name AS member_name FROM members AS m JOIN issued_status AS ist
on ist.issued_member_id= m.member_id
WHERE issued_date > CURRENT_DATE -INTERVAL '60 DAYS' 
GROUP BY 1,2 
HAVING COUNT(*)>1;

SELECT * FROM active_members;

--or

CREATE TABLE active_members
DROP TABLE IF EXISTS active_members;
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '2 month'
                    )
;

SELECT * FROM active_members;

-- Task 17: Find Employees with the Most Book Issues Processed. Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2

/*TASK 18 Stored Procedure Objective: 
Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). If the book is available,
it should be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), 
the procedure should return an error message indicating that the book is currently not available.*/

SELECT * FROM books;
SELECT * FROM issued_status;

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id varchar(10),p_issued_member_id varchar(30),p_issued_book_isbn varchar(30),p_issued_emp_id varchar(10))
LANGUAGE plpgsql
AS $$

DECLARE
v_status varchar(10);
BEGIN
     SELECT status INTO v_status FROM books
	 WHERE isbn=p_issued_book_isbn;

	 IF v_status='yes'
	 THEN 
	 INSERT INTO issued_status(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
     VALUES(p_issued_id,p_issued_member_id, CURRENT_DATE,p_issued_book_isbn,p_issued_emp_id );

	 UPDATE books SET status='no'
     WHERE isbn= p_issued_book_isbn;

     RAISE NOTICE 'book records added successfully for Book isbn:%',p_issued_book_isbn;
	 
	 ELSE
	 RAISE NOTICE 'sorry to inform the book you have requested is unavailable. Book isbn:%',p_issued_book_isbn;
     END IF;
END
$$

CALL issue_book('IS155','C108','978-0-525-47535-5','E104');
SELECT * FROM books WHERE isbn='978-0-525-47535-5';
SELECT * FROM issued_status WHERE issued_book_isbn='978-0-525-47535-5';

/* Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
The table should include: The number of overdue books. 
The total fines, with each day's fine calculated at $0.50. 
The number of books issued by each member.
The resulting table should show: Member ID Number of overdue books Total fines
*/
CREATE TABLE overdue_books AS
SELECT m.member_id AS member_id,m.member_name AS member_name, COUNT(ist.issued_id) FILTER (WHERE ist.issued_id IS NOT NULL) AS total_books_issued,
SUM((CURRENT_DATE - ist.issued_date - 30) * 0.50) AS total_fines
FROM
members AS  m JOIN issued_status AS ist 
ON m.member_id= ist.issued_member_id
JOIN books AS bk
ON bk.isbn= ist.issued_book_isbn
LEFT JOIN return_status AS rs
ON rs.issued_id= ist.issued_id 
WHERE return_date IS NULL
AND  CURRENT_DATE - ist.issued_date > 30
GROUP BY 1;

SELECT * FROM overdue_books;

