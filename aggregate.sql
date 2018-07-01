/* number of facilities */
SELECT COUNT(*)
FROM cd.facilities;

/* number of facilities that have a cost to guests of 10 or more */
SELECT COUNT(*)
FROM cd.facilities
WHERE guestcost >= 10;

/* number of recommendations by member ID */
SELECT recommendedby, 
	   COUNT(*) AS count
  FROM cd.members
 WHERE recommendedby IS NOT NULL
GROUP BY recommendedby
ORDER BY recommendedby;

/* total number of slots booked per facility */
SELECT bk.facid AS facid,
       SUM(bk.slots) AS "Total Slots"
  FROM cd.bookings AS bk
GROUP BY bk.facid
ORDER BY bk.facid;

/* total number of slots booked per facility in September 2012 */
SELECT facid,
	   SUM(slots) AS "Total Slots"
  FROM cd.bookings
 WHERE starttime >= '2012-09-01'
   AND starttime < '2012-10-01'
   
   GROUP BY facid
   ORDER BY "Total Slots";

/* number of slots booked per facility per month for 2012 */
SELECT facid,
	   EXTRACT(MONTH FROM starttime) AS month,
	   SUM(slots) AS "Total Slots"
  FROM cd.bookings
 WHERE EXTRACT(YEAR FROM starttime) = 2012

GROUP BY facid, month
ORDER BY facid, month;

/* number of members who have made at least one booking */
SELECT COUNT(DISTINCT memid)
  FROM cd.bookings;

/* facilities with more than 1000 slots booked */
SELECT facid,
	   SUM(slots) AS "Total Slots"
  FROM cd.bookings

GROUP BY facid
  HAVING SUM(slots) > 1000
ORDER BY facid;

/* facilities with total revenue */
SELECT name,
	   SUM(CASE WHEN bk.memid = 0
		   		THEN bk.slots * fac.guestcost
		   		ELSE bk.slots * fac.membercost
		   END) AS revenue
FROM cd.facilities AS fac
	INNER JOIN cd.bookings AS bk
	USING (facid)

/* facilities with total revenue less than 1000 */
SELECT name, revenue
  FROM (SELECT name,
			SUM(CASE WHEN bk.memid = 0
					  THEN bk.slots * fac.guestcost
					  ELSE bk.slots * fac.membercost
				END) AS revenue
	     FROM cd.facilities AS fac
			 INNER JOIN cd.bookings AS bk
			 USING (facid)
		  
	  	 GROUP BY fac.name) AS facrev
		 
 WHERE revenue < 1000
 
ORDER BY revenue;

/* facility id with the highest number of slots booked */
SELECT facid, 
	   SUM(slots) AS "Total Slots"
  FROM cd.bookings

GROUP BY facid
ORDER BY "Total Slots" DESC
   LIMIT 1

/* number of slots booked per facility per month for 2012
with subtotals for each facility and grand total */
SELECT facid,
	   EXTRACT(MONTH FROM starttime) AS month,
	   SUM(slots) AS slots
  FROM cd.bookings
 WHERE EXTRACT(YEAR FROM starttime) = '2012'
  
GROUP BY ROLLUP(facid, month)
ORDER BY facid, month;

/* number of hours booked per facility
1 slot = 0.5 hours */
SELECT bkg.facid,
	   fac.name,
	   SUM(slots * 0.50) AS hours
FROM cd.bookings AS bkg
	INNER JOIN cd.facilities AS fac
	ON bkg.facid = fac.facid

GROUP BY bkg.facid, fac.name
ORDER BY bkg.facid;

/* each member name, id, and their first booking after 2012-09-01 */
SELECT mem.surname,
	   mem.firstname,
	   mem.memid, 
	   MIN(starttime) AS starttime
FROM cd.bookings AS bkg
	INNER JOIN cd.members AS mem
	ON bkg.memid = mem.memid
WHERE bkg.starttime >= '2012-09-01'

GROUP BY mem.memid
ORDER BY mem.memid;

/* numbered list of members, ordered by join date */
SELECT ROW_NUMBER() OVER (ORDER BY joindate),
	   firstname,
	   surname
FROM cd.members;

/* facility id with the highest number of slots booked */
WITH slots AS (
  	SELECT facid,
		SUM(slots) AS total,
		RANK() OVER (ORDER BY SUM(slots) DESC)
	FROM cd.bookings
	GROUP BY facid
)
	
SELECT facid, total
FROM slots
WHERE rank = 1;

/* members with total number of hours booked 
(rounded to nearest ten hours) */
SELECT mem.firstname,
	mem.surname,
	ROUND(SUM(bkg.slots * 0.5), -1) AS hours,
	RANK() OVER (ORDER BY 
				 ROUND(SUM(bkg.slots * 0.5), -1) DESC) as rank

FROM cd.bookings AS bkg
	INNER JOIN cd.members AS mem
	ON mem.memid = bkg.memid

GROUP BY (mem.firstname, mem.surname)
ORDER BY rank, mem.surname, mem.firstname;

/* top three revenue generating facilities (including ties) */
WITH rev AS (
    SELECT fac.name AS name, 
        SUM(CASE WHEN bkg.memid = 0
                THEN bkg.slots * fac.guestcost
                ELSE bkg.slots * fac.membercost
                END) AS revenue  
    FROM cd.bookings AS bkg
        INNER JOIN cd.facilities AS fac
        ON bkg.facid = fac.facid

    GROUP BY fac.name
)

SELECT name, rank
FROM (SELECT name,
	  		 RANK() OVER (ORDER BY revenue DESC) AS rank
	  	FROM rev) AS sub
WHERE rank <=3
ORDER BY rank, name;

/* facilities grouped by high/average/low revenue */
WITH rev AS (
	SELECT fac.name AS name, 
  		   SUM(CASE WHEN bkg.memid = 0
			 		THEN bkg.slots * fac.guestcost
		 	 		ELSE bkg.slots * fac.membercost
		 	 		END) AS revenue  
	FROM cd.bookings AS bkg
	 	 INNER JOIN cd.facilities AS fac
		 ON bkg.facid = fac.facid

	GROUP BY fac.name
)

SELECT name,
	   CASE WHEN ntile = 1 THEN 'high'
	   		WHEN ntile = 2 THEN 'average'
			ELSE 'low'
			END AS revenue
FROM (SELECT name,
	   		 NTILE(3) OVER (ORDER BY revenue DESC) as ntile
  		FROM rev) AS sub

ORDER BY ntile, name;

/* amount of time each facility will take to repay cost of ownership */
-- WIP