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
