--SQL project -librart management system
use library_project_db
select*from books
select*from branch
select*from employees
select*from issued_status
where issued_id='IS135'
select*from members
select*from return_status
where issued_id='IS135'


/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/
-- issued_status==members==books==return_status
--filter books which is returned
--overdue>30

use library_project_db


	select iss.issued_member_id,
		   m.member_name,
		   bk.book_title,
		   iss.issued_date,
		   --rs.return_date,
		   datediff(day,issued_date,getdate()) as overdue_days
	from issued_status as iss
	join members as m
	on m.member_id=iss.issued_member_id
	join books as bk
	on bk.isbn=iss.issued_book_isbn
	left join return_status as rs
	on rs.issued_id=iss.issued_id
	where rs.return_date is null and datediff(day,issued_date,getdate())>30
	order by iss.issued_member_id

/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table 
to "Yes" when they are returned (based on entries in the return_status table).
*/

	select * from issued_status
	where issued_book_isbn='978-0-451-52994-2';

select*from books
where isbn='978-0-451-52994-2'

update books
set status='no'
where isbn='978-0-451-52994-2'

select*from return_status
where issued_id='IS135'

--
insert into return_status(return_id,issued_id,return_date,book_quality)
values ('RS125', 'IS130', getdate(),'Good' )
select*from return_status
where issued_id='IS130'

update books
set status='yes'
where isbn='978-0-451-52994-2'

--store procedures
drop procedure return_records
create procedure return_records (@p_return_id varchar(10),
                                 @p_issued_id varchar(10),
                                 @p_book_quality varchar(15))

as
begin
     declare @v_isbn varchar(50);
	 declare @v_book_name varchar(80);
      --all your logic and code
	  --inserting into returns based on users input
	 insert into return_status(return_id,issued_id,return_date,book_quality)
     values (@p_return_id, @p_issued_id, getdate(), @p_book_quality );

	 select @v_isbn= issued_book_isbn,@v_book_name=issued_book_name
	 from issued_status
	 where issued_id=@p_issued_id	
	 
	 update books
     set status='yes'
     where isbn=@v_isbn;

	 print 'Thank you for returning: %' + @v_book_name;	
     
end;


--Testing functions
--calling a function
exec return_records @p_return_id='RS135',@p_issued_id='IS135',@p_book_quality='Good';

drop procedure return_records
delete
from return_status
where return_id='RS135'
select*
from return_status

select*
from issued_status
where issued_id='IS135'

select*
from books
where isbn='978-0-330-25864-8'

update books
set status='No'
where isbn='978-0-330-25864-8'

select*
from return_status	


where isbn='978-0-330-25864-8'

select*
from issued_status
where issued_book_isbn='978-0-330-25864-8'
--is140
--calling a function
exec return_records @p_return_id='RS140',@p_issued_id='IS140',@p_book_quality='Damaged';

delete
from return_status
where return_id='RS140'


/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/

select*from books

select b.branch_id,
	   b.manager_id,
	   count(iss.issued_id) as total_books_issued,
	   count(rs.return_id)as total_books_returned,
	   sum(bk.rental_price) as total_revenue
	   into bank_performance
from issued_status as iss
join employees as e
on e.emp_id=iss.issued_emp_id
join branch as b
on b.branch_id=e.branch_id
left join return_status as rs
on rs.issued_id=iss.issued_id
join books as bk
on bk.isbn=iss.issued_book_isbn
group by b.branch_id,b.manager_id

select*from bank_performance

/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
containing members who have issued at least one book in the last 6 months.
*/

select* into active_members
from members
where member_id in(select 
                       distinct issued_member_id
                   from issued_status
                   where issued_date>dateadd(month,-6,GETDATE()))

select *
from active_members


/*
Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/

use library_project_db


select*
from issued_status
select * from employees



select top 3 
	   e.emp_name,
	   iss.issued_emp_id,
       e.branch_id,
       count(iss.issued_id) as total_books_issued
from issued_status as iss
join employees as e
on e.emp_id=iss.issued_emp_id
group by iss.issued_emp_id,e.branch_id,e.emp_name
order by count(iss.issued_id) desc

/*
Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system.
Description: Write a stored procedure that updates the status of a book in the library based on its issuance.
The procedure should function as follows: The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes'). If the book is available,
it should be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'),
the procedure should return an error message indicating that the book is currently not available.
*/
drop procedure issue_book
create procedure issue_book (@p_issued_id varchar(10),
                            @p_issued_member_id varchar(30),
                            @p_issued_book_isbn varchar(50),
	                        @p_issued_emp_id varchar(10))
							 
as
begin
     declare @v_status varchar(10)
      --all your logic and code
	  --checking if books is available'yes'
     select @v_status=status
	 from books
	 where isbn=@p_issued_book_isbn
	
		 

	 if @v_status='yes'
	 begin
	     insert into issued_status(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
	     values(@p_issued_id,@p_issued_member_id,getdate(),@p_issued_book_isbn,@p_issued_emp_id)

		 

		 update books
         set status='no'
         where isbn=@p_issued_book_isbn

	     print('Book record added succesfully for book isbn : %'+ @p_issued_book_isbn)
	  end

      else
	  begin
      
	     
		print('Sorry book is not available: %'+ @p_issued_book_isbn)
	  
	  end
	  
end;


select * from books
where isbn='978-0-553-29698-2'

--'978-0-553-29698-2'-yes current status
--'978-0-375-41398-8'-no current status

select * FROM issued_status




exec issue_book @p_issued_id='IS155',
                @p_issued_member_id='C108' ,
                @p_issued_book_isbn='978-0-553-29698-2',
	            @p_issued_emp_id='E104'

exec issue_book @p_issued_id='IS156',
                @p_issued_member_id='C109' ,
                @p_issued_book_isbn='978-0-375-41398-8',
	            @p_issued_emp_id='E105'
