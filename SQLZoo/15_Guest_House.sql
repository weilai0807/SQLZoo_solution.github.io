/* 1. Guest 1183. Give the booking_date and the number of nights for guest 1183.

+--------------+--------+
| booking_date | nights |
+--------------+--------+
| 2016-11-27   |      5 |
+--------------+--------+ */

SELECT DATE_FORMAT(booking_date, '%Y-%m-%d') AS booking_date, nights
FROM booking b JOIN guest g ON b.guest_id = g.id
WHERE booking_date = '2016-11-27' AND g.id = 1183


/* 2. When do they get here? List the arrival time and the first and last names for all guests due to arrive on 2016-11-05, order the output by time of arrival. 

+--------------+------------+-----------+
| arrival_time | first_name | last_name |
+--------------+------------+-----------+
| 14:00        | Lisa       | Nandy     |
| 15:00        | Jack       | Dromey    |
| 16:00        | Mr Andrew  | Tyrie     |
| 21:00        | James      | Heappey   |
| 22:00        | Justin     | Tomlinson |
+--------------+------------+-----------+ */

SELECT arrival_time, first_name, last_name
FROM booking b JOIN guest g ON b.guest_id = g.id
WHERE booking_date = '2016-11-05'
ORDER BY arrival_time


/* 3. Look up daily rates. Give the daily rate that should be paid for bookings with ids 5152, 5165, 5154 and 5295. Include booking id, room type, number of occupants and the amount.

+------------+---------------------+-----------+--------+
| booking_id | room_type_requested | occupants | amount |
+------------+---------------------+-----------+--------+
|       5152 | double              |         2 |  72.00 |
|       5154 | double              |         1 |  56.00 |
|       5295 | family              |         3 |  84.00 |
+------------+---------------------+-----------+--------+ */

SELECT booking_id, room_type_requested, occupants, amount
FROM booking JOIN rate ON room_type_requested = room_type
WHERE booking_id IN (5152, 5165, 5154, 5295)
AND occupants = occupancy

  
/* 4. Who’s in 101? Find who is staying in room 101 on 2016-12-03, include first name, last name and address. 

+------------+-----------+-------------+
| first_name | last_name | address     |
+------------+-----------+-------------+
| Graham     | Evans     | Weaver Vale |
+------------+-----------+-------------+ */

SELECT first_name, last_name, address
FROM booking b JOIN guest g ON b.guest_id = g.id
WHERE room_no = 101 AND booking_date = '2016-12-03'


/* 5. How many bookings, how many nights? For guests 1185 and 1270 show the number of bookings made and the total number of nights. 
Your output should include the guest id and the total number of bookings and the total number of nights.

+----------+---------------+-------------+
| guest_id | COUNT(nights) | SUM(nights) |
+----------+---------------+-------------+
|     1185 |             3 |           8 |
|     1270 |             2 |           3 |
+----------+---------------+-------------+ */

SELECT guest_id, COUNT(nights), SUM(nights)
FROM booking
WHERE guest_id IN (1185, 1270)
GROUP BY guest_id

  
/* 6. Ruth Cadbury. Show the total amount payable by guest Ruth Cadbury for her room bookings. You should JOIN to the rate table using room_type_requested and occupants.

+--------------------+
| SUM(nights*amount) |
+--------------------+
|             552.00 |
+--------------------+ */

SELECT SUM(nights*amount)
FROM booking b JOIN guest g ON b.guest_id = g.id
JOIN rate r ON b.room_type_requested = r.room_type
WHERE (first_name = 'RUTH' AND last_name = 'Cadbury')
AND occupants = occupancy

  
/* 7. Including Extras. Calculate the total bill for booking 5346 including extras.

+-------------+
| SUM(amount) |
+-------------+
|      118.56 |
+-------------+ */

WITH temp1 AS (
SELECT SUM(nights*amount) AS bill
FROM booking b JOIN rate r ON b.room_type_requested = r.room_type
WHERE b.booking_id = 5346 AND occupants = occupancy
), temp2 AS (
SELECT SUM(amount) AS extra
FROM booking b JOIN extra e ON b.booking_id = e.booking_id
WHERE b.booking_id = 5346
)
SELECT (SELECT bill from temp1) + (SELECT extra FROM temp2) AS total_bill;


/* 8. Edinburgh Residents. For every guest who has the word “Edinburgh” in their address show the total number of nights booked. 
Be sure to include 0 for those guests who have never had a booking. Show last name, first name, address and number of nights. Order by last name then first name.

+-----------+------------+---------------------------+--------+
| last_name | first_name | address                   | nights |
+-----------+------------+---------------------------+--------+
| Brock     | Deidre     | Edinburgh North and Leith |      0 |
| Cherry    | Joanna     | Edinburgh South West      |      0 |
| Murray    | Ian        | Edinburgh South           |     13 |
| Sheppard  | Tommy      | Edinburgh East            |      0 |
| Thomson   | Michelle   | Edinburgh West            |      3 |
+-----------+------------+---------------------------+--------+ */

WITH temp1 AS (
SELECT guest_id, SUM(nights) AS nights
FROM booking
GROUP BY guest_id),
temp2 AS (
SELECT id, first_name, last_name, address
FROM guest
)
SELECT temp2.last_name, temp2.first_name, temp2.address, COALESCE(temp1.nights,0) AS nights
FROM temp2 LEFT JOIN temp1 ON temp2.id = temp1.guest_id
WHERE temp2.address LIKE '%Edinburgh%'
ORDER BY temp2.last_name, temp2.first_name


/* 9. How busy are we? For each day of the week beginning 2016-11-25 show the number of bookings starting that day. 
Be sure to show all the days of the week in the correct order.

+------------+----------+
| i          | arrivals |
+------------+----------+
| 2016-11-25 |        7 |
| 2016-11-26 |        8 |
| 2016-11-27 |       12 |
| 2016-11-28 |        7 |
| 2016-11-29 |       13 |
| 2016-11-30 |        6 |
| 2016-12-01 |        7 |
+------------+----------+ */

SELECT DATE_FORMAT(booking_date, '%Y-%m-%d') AS i, COUNT(arrival_time) AS arrivals
FROM booking
WHERE DATE_FORMAT(booking_date, '%Y-%m-%d') BETWEEN '2016-11-25' AND '2016-12-01'
GROUP BY booking_date


/* 10. How many guests? Show the number of guests in the hotel on the night of 2016-11-21. Include all occupants who checked in that day but not those who checked out.

+----------------+
| SUM(occupants) |
+----------------+
|             39 |
+----------------+ */

WITH temp1 AS (
SELECT occupants, DATE_FORMAT(booking_date, '%Y-%m-%d') AS checkin, DATE_FORMAT(booking_date + nights, '%Y-%m-%d') AS checkout
FROM booking
WHERE DATE_FORMAT(booking_date, '%Y-%m-%d') <= '2016-11-21' AND DATE_FORMAT(booking_date + nights, '%Y-%m-%d') > '2016-11-21'
)
SELECT SUM(occupants)
FROM temp1


/* 11. Coincidence. Have two guests with the same surname ever stayed in the hotel on the evening? 
Show the last name and both first names. Do not include duplicates.

+-----------+------------+-------------+
| last_name | first_name | first_name  |
+-----------+------------+-------------+
| Davies    | Philip     | David T. C. |
| Evans     | Graham     | Mr Nigel    |
| Howarth   | Mr George  | Sir Gerald  |
| Jones     | Susan Elan | Mr Marcus   |
| Lewis     | Clive      | Dr Julian   |
| McDonnell | John       | Dr Alasdair |
+-----------+------------+-------------+ */

WITH temp1 AS(
SELECT DISTINCT a.last_name, a.first_name AS fn1, b.first_name AS fn2
FROM (SELECT * FROM booking b JOIN guest g ON b.guest_id = g.id) AS a CROSS JOIN
(SELECT * FROM booking b JOIN guest g ON b.guest_id = g.id) AS b
WHERE (a.last_name = b.last_name AND a.first_name != b.first_name) AND
(
((a.booking_date < DATE_ADD(b.booking_date, INTERVAL b.nights DAY)) AND a.booking_date >= b.booking_date) OR ((b.booking_date < DATE_ADD(a.booking_date, INTERVAL a.nights DAY)) AND b.booking_date >= a.booking_date)
)
), temp2 AS (
SELECT last_name, fn1, fn2,
MAX(fn1) OVER (PARTITION BY last_name) AS rnum
FROM temp1
ORDER BY last_name
)
SELECT last_name, fn1, fn2
FROM temp2
WHERE fn1 = rnum

  
/* 12. Check out per floor. The first digit of the room number indicates the floor – e.g. room 201 is on the 2nd floor. 
For each day of the week beginning 2016-11-14 show how many rooms are being vacated that day by floor number. Show all days in the correct order.

+------------+-----+-----+-----+
| i          | 1st | 2nd | 3rd |
+------------+-----+-----+-----+
| 2016-11-14 |   5 |   3 |   4 |
| 2016-11-15 |   6 |   4 |   1 |
| 2016-11-16 |   2 |   2 |   4 |
| 2016-11-17 |   5 |   3 |   6 |
| 2016-11-18 |   2 |   3 |   2 |
| 2016-11-19 |   5 |   5 |   1 |
| 2016-11-20 |   2 |   2 |   2 |
+------------+-----+-----+-----+ */

WITH temp1 AS (
SELECT DATE_FORMAT((booking_date + INTERVAL nights DAY), "%Y-%m-%d") AS i, room_no, LEFT(room_no, 1) AS floor
FROM booking
), temp2 AS (
SELECT * FROM temp1
WHERE DATE_FORMAT(i, "%Y-%m-%d") BETWEEN "2016-11-14" AND "2016-11-20"
ORDER BY i
), temp3 AS (
SELECT *,
CASE WHEN floor = 1 THEN 1 ELSE 0 END AS 1st,
CASE WHEN floor = 2 THEN 1 ELSE 0 END AS 2nd,
CASE WHEN floor = 3 THEN 1 ELSE 0 END AS 3rd
FROM temp2
)
SELECT i, SUM(1st) AS 1st, SUM(2nd) AS 2nd, SUM(3rd) AS 3rd
FROM temp3
GROUP BY I


/* 13. Free rooms? List the rooms that are free on the day 25th Nov 2016.

+-----+
| id  |
+-----+
| 207 |
| 210 |
| 304 |
+-----+ */

WITH temp1 AS (
SELECT DISTINCT id
FROM room
), temp2 AS (
SELECT DISTINCT room_no
FROM booking
WHERE DATE_FORMAT(booking_date, '%Y-%m-%d') <= '2016-11-25' AND DATE_FORMAT((booking_date + INTERVAL nights DAY), '%Y-%m-%d') > '2016-11-25'
)
SELECT temp1.id
FROM temp1 LEFT JOIN temp2 ON temp1.id=temp2.room_no
WHERE temp2.room_no IS NULL


/* 14. Single room for three nights required. A customer wants a single room for three consecutive nights. Find the first available date in December 2016. 

+-----+------------+
| id  | MIN(i)     |
+-----+------------+
| 201 | 2016-12-11 |
+-----+------------+ */

WITH temp1 AS (
SELECT room_no, room_type_requested, nights, booking_date, (booking_date + INTERVAL nights DAY) AS departure 
FROM booking
WHERE room_type_requested = 'single'
), temp2 AS (
SELECT room_no, booking_date
FROM booking
WHERE room_type_requested = 'single'
), temp3 AS (
SELECT temp1.room_no, temp1.nights, MIN(temp1.booking_date) AS booking_date, temp1.departure, temp2.booking_date AS next_booking_date, (temp2.booking_date - temp1.booking_date - temp1.nights) AS gap
FROM temp1 LEFT JOIN temp2 ON temp1.booking_date < temp2.booking_date AND temp1.room_no = temp2.room_no
WHERE DATE_FORMAT(temp1.booking_date, '%M') = 'December'
GROUP BY temp1.room_no, temp1.booking_date
ORDER BY temp1.room_no, temp1.booking_date
), temp4 AS (
SELECT room_no 
FROM temp3
WHERE gap >= 3 /* Check if there is any single room has 3 days gap for booking */
)
SELECT room_no AS id, MAX(DATE_FORMAT(departure, '%Y-%m-%d')) AS i
FROM temp3
GROUP BY room_no
ORDER BY i
LIMIT 1


/* 15. Gross income by week. Money is collected from guests when they leave. 
For each Thursday in November and December 2016, show the total amount of money collected from the previous Friday to that day, inclusive.

+------------+---------------+
| Thursday   | weekly_income |
+------------+---------------+
| 2016-11-03 |          0.00 |
| 2016-11-10 |      12608.94 |
| 2016-11-17 |      13552.56 |
| 2016-11-24 |      12929.69 |
| 2016-12-01 |      11685.14 |
| 2016-12-08 |      13093.79 |
| 2016-12-15 |       8975.87 |
| 2016-12-22 |       1395.77 |
| 2016-12-29 |          0.00 |
| 2017-01-05 |          0.00 |
+------------+---------------+ */

WITH temp1 AS (
SELECT booking_id, SUM(amount) AS extras
FROM extra
GROUP BY booking_id
), temp2 AS (
SELECT b.booking_id, b.booking_date, b.nights, b.nights*r.amount AS income
FROM booking AS b JOIN rate AS r ON b.occupants=r.occupancy AND b.room_type_requested=r.room_type
), temp3 AS (
SELECT DATE_ADD(MAKEDATE(2016, 7), INTERVAL WEEK(DATE_ADD(temp2.booking_date, INTERVAL temp2.nights - 5 DAY), 0) WEEK) AS Thursday, SUM(temp2.income) + SUM(temp1.extras) AS weekly_income
FROM temp2 LEFT JOIN temp1 ON temp2.booking_id = temp1.booking_id
GROUP BY Thursday
)
SELECT DATE_FORMAT(Thursday, '%Y-%m-%d') AS Thursday, weekly_income
FROM temp3
ORDER BY Thursday
