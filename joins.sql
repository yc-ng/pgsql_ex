/* start times for bookings by members named David Farrell */
SELECT bk.starttime
  FROM cd.bookings AS bk
    INNER JOIN cd.members AS mb
	   	    ON bk.memid = mb.memid
 WHERE mb.surname = 'Farrell'
   AND mb.firstname = 'David';

/* start times for bookings for tennis courts on 2012-09-21 */
SELECT bk.starttime AS start,
       fac.name
  FROM cd.facilities AS fac
	INNER JOIN cd.bookings AS bk
	        ON fac.facid = bk.facid
WHERE fac.name LIKE 'Tennis Court%'
  AND bk.starttime >= '2012-09-21'
  AND bk.starttime < '2012-09-22'
ORDER BY start;

/* all members who have recommended another member */
SELECT DISTINCT m2.firstname, 
       m2.surname
  FROM cd.members AS m1
	INNER JOIN cd.members AS m2
	        ON m1.recommendedby = m2.memid
ORDER BY m2.surname, m2.firstname;

/* all members, including the individual who recommended them (if any) */
SELECT mem.firstname AS memfname,
	   mem.surname AS memsname,
	   rec.firstname AS recfname,
	   rec.surname AS recsname
  FROM cd.members AS mem
	LEFT JOIN cd.members AS rec
	       ON mem.recommendedby = rec.memid
ORDER BY memsname, memfname;

/* all members who have used a tennis court,
names formatted as a single column */
SELECT DISTINCT m.firstname || ' ' || m.surname AS member,
	   f.name AS facility
  FROM cd.members AS m
	INNER JOIN cd.bookings AS b
	     USING (memid)
	
	INNER JOIN cd.facilities AS f
	     USING (facid)
	
 WHERE f.name LIKE 'Tennis Court%' 
ORDER BY member;

/* bookings on 2012-09-14 which cost the member/guest more than $30 */
SELECT m.firstname || ' ' || m.surname AS member,
	   f.name AS facility,
	   CASE WHEN b.memid = 0
	   		THEN b.slots * f.guestcost
			ELSE b.slots * f.membercost
	   END AS cost
  FROM cd.members AS m
	INNER JOIN cd.bookings AS b
	USING (memid)
	
	INNER JOIN cd.facilities AS f
	USING (facid)

 WHERE ((b.memid = 0 AND b.slots * f.guestcost > 30)
    	OR (b.memid <> 0 AND b.slots * f.membercost > 30))
   AND b.starttime >= '2012-09-14'
   AND b.starttime < '2012-09-15'
			
ORDER BY cost DESC;

/* all members, including the individual who recommended them
(using subquery) */
SELECT DISTINCT
	mem.firstname || ' ' || mem.surname AS member,
	(SELECT rec.firstname || ' ' || rec.surname AS recommender
	   FROM cd.members AS rec
	  WHERE rec.memid = mem.recommendedby)
FROM cd.members AS mem
ORDER BY member;

/* bookings on 2012-09-14 which cost the member/guest more than $30 
(using subquery) */
SELECT mem.firstname || ' ' || mem.surname AS member,
	   exp.facility,
	   exp.cost
FROM cd.members AS mem,

	(SELECT bk.memid AS memid,
	 		bk.starttime AS starttime,
	 		fac.name AS facility,
	 		CASE WHEN bk.memid = 0
				 THEN bk.slots * fac.guestcost
				 ELSE bk.slots * fac.membercost
			   END AS cost
	   FROM cd.bookings AS bk,
	   	    cd.facilities AS fac
	  WHERE bk.facid = fac.facid 
		AND ((bk.memid = 0 AND bk.slots * fac.guestcost > 30)
			  OR (bk.memid <> 0 AND bk.slots * fac.membercost > 30)) )
		 AS exp
			  
 WHERE exp.memid = mem.memid
   AND exp.starttime >= '2012-09-14'
   AND exp.starttime < '2012-09-15'

ORDER BY cost DESC;