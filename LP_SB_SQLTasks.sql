/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name AS Facility, membercost AS Cost
FROM Facilities
WHERE membercost > 0.0
ORDER BY membercost DESC

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(membercost = 0.0)
FROM Facilities;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid , name , membercost, monthlymaintenance
FROM Facilities
WHERE membercost > 0
AND membercost < ( monthlymaintenance * .20 )
ORDER BY membercost DESC

/*
Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid =1
UNION
SELECT *
FROM Facilities
WHERE facid = 5

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance > 100 THEN 'Expensive'
ELSE 'Cheap' END AS Cost
FROM Facilities;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT CONCAT(firstname, ' ', surname) AS Member_Name, MAX(joindate)
FROM Members
WHERE firstname NOT LIKE 'Guest%'


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT(CONCAT(m.surname, ', ', m.firstname)) AS Member_Name, b.memid, f.name AS Court
FROM Members as m
INNER JOIN Bookings as b
ON b.memid = m.memid

INNER JOIN Facilities as f
ON f.facid = b.facid
WHERE b.facid = 0 OR b.facid = 1
HAVING memid > 0
ORDER BY Member_Name ASC


/*Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name AS Facility, b.starttime AS Start_Time, CONCAT(m.firstname, ' ', m.surname) AS Member_Name,
CASE WHEN m.memid = 0 THEN 'Guest' 
ELSE 'Member' END AS Member_Type,

CASE WHEN m.memid = 0 AND ((b.slots * f.guestcost) > 30)  THEN (b.slots * f.guestcost) 
ELSE (b.slots * f.membercost) END AS Cost

FROM Members as m
INNER JOIN Bookings as b
ON m.memid = b.memid
INNER JOIN Facilities as f
ON b.facid = f.facid
WHERE b.starttime LIKE '2012-09-14%'
HAVING Cost > 30
ORDER BY Cost DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

---
SELECT sub.Facility,
       sub.Member_Name,
       sub.Cost

FROM (SELECT f.name AS Facility, CONCAT(m.firstname, ' ', m.surname) AS Member_Name,
      CASE WHEN b.memid = 0 THEN f.guestcost * b.slots 
      ELSE f.membercost *b.slots END AS Cost

      FROM (SELECT memid, facid, slots, starttime FROM Bookings) b 
      JOIN (SELECT memid, firstname, surname FROM Members) m
      JOIN (SELECT facid, name, guestcost, membercost FROM Facilities) f
      ON m.memid = b.memid AND f.facid = b.facid
      WHERE b.starttime > '2012-09-14' AND b.starttime < '2012-09-15') sub

WHERE sub.Cost > 30
ORDER BY Cost DESC

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT sub.Facility,
       sub.TotalRevenue
FROM (SELECT f.name AS Facility,
             SUM(CASE WHEN b.memid = 0 THEN f.guestcost * b.slots 
                 ELSE f.membercost * b.slots END) AS TotalRevenue
      
      FROM (SELECT memid, facid, slots FROM Bookings) AS b
      JOIN (SELECT name, facid, membercost, guestcost FROM Facilities) AS f
      ON f.facid = b.facid
      GROUP BY Facility) AS sub
WHERE sub.TotalRevenue < 1000
ORDER BY TotalRevenue DESC

----------------------
('Pool Table', 270)
('Snooker Table', 240)
('Table Tennis', 180)

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT CONCAT(m.surname, ', ', m.firstname) AS Member_Name, 
CONCAT(r.surname, ', ', r.firstname) AS Recommender_Name

FROM Members m

INNER JOIN Members r ON r.memid = m.recommendedby
WHERE m.recommendedby > 0

ORDER BY Member_Name ASC

----------------------

('Bader Florence', 'Stibbons Ponder')
('Baker Anne', 'Stibbons Ponder')
('Baker Timothy', 'Farrell Jemima')
('Boothe Tim', 'Rownam Tim')
('Butters Gerald', 'Smith Darren')
('Coplin Joan', 'Baker Timothy')
('Crumpet Erica', 'Smith Tracy')
('Dare Nancy', 'Joplette Janice')
('Genting Matthew', 'Butters Gerald')
('Hunt John', 'Purview Millicent')
('Jones David', 'Joplette Janice')
('Jones Douglas', 'Jones David')
('Joplette Janice', 'Smith Darren')
('Mackenzie Anna', 'Smith Darren')
('Owen Charles', 'Smith Darren')
('Pinker David', 'Farrell Jemima')
('Purview Millicent', 'Smith Tracy')
('Rumney Henrietta', 'Genting Matthew')
('Sarwin Ramnaresh', 'Bader Florence')
('Smith Jack', 'Smith Darren')
('Stibbons Ponder', 'Tracy Burton')
('Worthington-Smyth Henry', 'Smith Tracy')

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT f.name as Facility, SUM((b.slots * 30) / 60) AS TotalHours
FROM Facilities as f

INNER JOIN Bookings as b
ON f.facid = b.facid

WHERE b.memid > 0

GROUP BY Facility


-------------------------

('Badminton Court', 379)
('Massage Room 1', 442)
('Massage Room 2', 27)
('Pool Table', 66)
('Snooker Table', 430)
('Squash Court', 209)
('Table Tennis', 397)
('Tennis Court 1', 329)
('Tennis Court 2', 311)

-------------------------
/* Q13: Find the facilities usage by month, but not guests */

SELECT 
    strftime('%m', b.starttime) as Month, f.name AS Facility, SUM((b.slots * 30) / 60) AS TotalHoursUsed
FROM Bookings as b
INNER JOIN Facilities AS f
      ON f.facid = b.facid
WHERE memid != 0
GROUP BY Month, Facility

-------------------------

('07', 'Badminton Court', 59)
('07', 'Massage Room 1', 83)
('07', 'Massage Room 2', 4)
('07', 'Pool Table', 6)
('07', 'Snooker Table', 70)
('07', 'Squash Court', 25)
('07', 'Table Tennis', 49)
('07', 'Tennis Court 1', 68)
('07', 'Tennis Court 2', 41)
('08', 'Badminton Court', 143)
('08', 'Massage Room 1', 158)
('08', 'Massage Room 2', 9)
('08', 'Pool Table', 26)
('08', 'Snooker Table', 158)
('08', 'Squash Court', 92)
('08', 'Table Tennis', 148)
('08', 'Tennis Court 1', 115)
('08', 'Tennis Court 2', 120)
('09', 'Badminton Court', 177)
('09', 'Massage Room 1', 201)
('09', 'Massage Room 2', 14)
('09', 'Pool Table', 34)
('09', 'Snooker Table', 202)
('09', 'Squash Court', 92)
('09', 'Table Tennis', 200)
('09', 'Tennis Court 1', 146)
('09', 'Tennis Court 2', 150)