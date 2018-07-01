/* all information from cd.facilities table */
SELECT *
FROM cd.facilities;

/* only facility names and costs */
SELECT name, membercost
FROM cd.facilities;

/* facilities that charge a fee to members */
SELECT *
FROM cd.facilities
WHERE membercost > 0;

/*facilities that charge a fee to members, 
and fee is less than 1/50th of the monthly maintenance cost*/
SELECT facid, name, membercost, monthlymaintenance
FROM cd.facilities
WHERE membercost > 0
AND membercost * 50 < monthlymaintenance;

/* facilities with the word 'Tennis' in their name */
SELECT *
FROM cd.facilities
WHERE name LIKE '%Tennis%';

/* facilities with ID 1 and 5 */
SELECT *
FROM cd.facilities
WHERE facid IN (1, 5);

/* facilities labelled as 'cheap' or 'expensive' depending on 
if their monthly maintenance cost is more than $100 */
SELECT name,
	CASE WHEN monthlymaintenance > 100 THEN 'expensive'
	ELSE 'cheap'
	END AS cost
FROM cd.facilities;

/* members who joined after the start of September 2012 */
SELECT memid, surname, firstname, joindate
FROM cd.members
WHERE joindate >= '2012-09-01';

/* ordered list of the first 10 surnames in the members table */
SELECT DISTINCT surname
FROM cd.members
ORDER BY surname
LIMIT 10;

/* signup date of your last member */
SELECT MAX(joindate)
FROM cd.members;

/* first and last name of the last member(s) who signed up */
SELECT firstname, surname, joindate
FROM cd.members
WHERE joindate = (SELECT MAX(joindate)
				  FROM cd.members);

