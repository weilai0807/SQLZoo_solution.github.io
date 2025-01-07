/* 1. There are three issues that include the words "index" and "Oracle". Find the call_date for each of them 

+---------------------+----------+
| call_date           | call_ref |
+---------------------+----------+
| 2017-08-12 16:00:00 |     1308 |
| 2017-08-16 14:54:00 |     1697 |
| 2017-08-16 19:12:00 |     1731 |
+---------------------+----------+ */

SELECT DATE_FORMAT(call_date,'%Y-%m-%d %H:%i:%s') call_date, call_ref 
  FROM Issue
WHERE Detail LIKE '%index%' 
  AND DETAIL LIKE '%Oracle%';


/* 2. Samantha Hall made three calls on 2017-08-14. Show the date and time for each

+---------------------+------------+-----------+
| call_date           | first_name | last_name |
+---------------------+------------+-----------+
| 2017-08-14 10:10:00 | Samantha   | Hall      |
| 2017-08-14 10:49:00 | Samantha   | Hall      |
| 2017-08-14 18:18:00 | Samantha   | Hall      |
+---------------------+------------+-----------+ */

SELECT DATE_FORMAT(call_date,'%Y-%m-%d %H:%i:%s') call_date, first_name, last_name
  FROM Issue JOIN Caller ON Issue.Caller_id = Caller.Caller_id
WHERE First_name='Samantha' 
  AND Last_name='Hall' 
  AND Date(call_date) = '2017-08-14'

  
/* 3. There are 500 calls in the system (roughly). Write a query that shows the number that have each status.

+--------+--------+
| status | Volume |
+--------+--------+
| Closed |    486 |
| Open   |     10 |
+--------+--------+ */

SELECT status, Count(*) volume
  FROM Issue
GROUP BY status
ORDER BY volume DESC


/* 4. Calls are not normally assigned to a manager but it does happen. How many calls have been assigned to staff who are at Manager Level?

+------+
| mlcc |
+------+
|   51 |
+------+ */

SELECT COUNT(*) mlcc
  FROM Issue JOIN Staff ON Assigned_to = Staff_code
  JOIN Level ON Staff.Level_code = Level.Level_code
WHERE Manager = 'Y'


/* 5. Show the manager for each shift. Your output should include the shift date and type; also the first and last name of the manager.

+------------+------------+------------+-----------+
| Shift_date | Shift_type | first_name | last_name |
+------------+------------+------------+-----------+
| 2017-08-12 | Early      | Logan      | Butler    |
| 2017-08-12 | Late       | Ava        | Ellis     |
| 2017-08-13 | Early      | Ava        | Ellis     |
| 2017-08-13 | Late       | Ava        | Ellis     |
| 2017-08-14 | Early      | Logan      | Butler    |
| 2017-08-14 | Late       | Logan      | Butler    |
| 2017-08-15 | Early      | Logan      | Butler    |
| 2017-08-15 | Late       | Logan      | Butler    |
| 2017-08-16 | Early      | Logan      | Butler    |
| 2017-08-16 | Late       | Logan      | Butler    |
+------------+------------+------------+-----------+ */

SELECT DATE_FORMAT(Shift_date, '%Y-%m-%d') Shift_date, Shift_type, first_name, last_name
  FROM Shift JOIN Staff ON Manager = Staff_code
WHERE Level_code > 3
ORDER BY Shift_date, Shift_type;

/* 6. List the Company name and the number of calls for those companies with more than 18 calls.

+------------------+----+
| Company_name     | cc |
+------------------+----+
| Gimmick Inc.     | 22 |
| Hamming Services | 19 |
| High and Co.     | 20 |
+------------------+----+ */

SELECT Customer.Company_name, COUNT(*) AS cc
  FROM Customer JOIN Caller ON Customer.Company_ref=Caller.Company_ref
  JOIN Issue ON Caller.Caller_id=Issue.Caller_id
GROUP BY Company_name
Having cc > 18


/* 7. Find the callers who have never made a call. Show first name and last name

+------------+-----------+
| first_name | last_name |
+------------+-----------+
| David      | Jackson   |
| Ethan      | Phillips  |
+------------+-----------+ */

SELECT First_name, Last_name
  FROM Caller LEFT JOIN Issue ON Caller.Caller_id = Issue.Caller_id
WHERE Issue.Caller_id IS Null

  
/* 8. For each customer show: Company name, contact name, number of calls where the number of calls is fewer than 5

+--------------------+------------+-----------+----+
| Company_name       | first_name | last_name | nc |
+--------------------+------------+-----------+----+
| Pitiable Shipping  | Ethan      | McConnell |  4 |
| Rajab Group        | Emily      | Cooper    |  4 |
| Somebody Logistics | Ethan      | Phillips  |  2 |
+--------------------+------------+-----------+----+ */

SELECT cu.company_name,ca2.first_name,ca2.last_name,COUNT(*) AS nc
  FROM Customer cu INNER JOIN Caller ca ON ca.company_ref = cu.company_ref 
  INNER JOIN Issue i ON i.caller_id = ca.caller_id
  INNER JOIN Caller ca2 ON ca2.caller_id = cu.contact_id
GROUP BY cu.company_name,ca2.first_name,ca2.last_name
HAVING nc < 5


/* 9. For each shift show the number of staff assigned. 
Beware that some roles may be NULL and that the same person might have been assigned to multiple roles (The roles are 'Manager', 'Operator', 'Engineer1', 'Engineer2').

+------------+------------+----+
| Shift_date | Shift_type | cw |
+------------+------------+----+
| 2017-08-12 | Early      |  4 |
| 2017-08-12 | Late       |  4 |
| 2017-08-13 | Early      |  3 |
| 2017-08-13 | Late       |  2 |
| 2017-08-14 | Early      |  4 |
| 2017-08-14 | Late       |  4 |
| 2017-08-15 | Early      |  4 |
| 2017-08-15 | Late       |  4 |
| 2017-08-16 | Early      |  4 |
| 2017-08-16 | Late       |  4 |
+------------+------------+----+ */

SELECT DATE_FORMAT(a.Shift_date, '%Y-%m-%d') as Shift_date, a.Shift_type, COUNT(DISTINCT role) AS cw
  FROM (
        SELECT Shift_date, Shift_type, Manager AS role FROM Shift
      UNION ALL
        SELECT Shift_date, Shift_type, Operator AS role FROM Shift
      UNION ALL
        SELECT Shift_date, Shift_type, Engineer1 AS role FROM Shift
      UNION ALL SELECT Shift_date, Shift_type, Engineer2 AS role FROM Shift
  ) AS a
GROUP BY Shift_date, Shift_type


/* 10. Caller 'Harry' claims that the operator who took his most recent call was abusive and insulting. Find out who took the call (full name) and when. 
 
+------------+-----------+---------------------+
| first_name | last_name | call_date           |
+------------+-----------+---------------------+
| Emily      | Best      | 2017-08-16 10:25:00 |
+------------+-----------+---------------------+ */

SELECT Staff.First_name, Staff.Last_name, DATE_FORMAT(Issue.call_date, '%Y-%m-%d %H:%i:%s') as call_date
  FROM Staff JOIN Issue ON Staff.Staff_code = Issue.Taken_by
  JOIN Caller ON Issue.Caller_id = Caller.Caller_id
WHERE Caller.First_name = 'Harry'
ORDER BY call_date DESC
LIMIT 1;
