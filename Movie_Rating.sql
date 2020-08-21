/* ---- database intro. ------
You've started a new movie-rating website, and you've been collecting data on reviewers' ratings of various movies. There's not much data yet, but you can still try out some interesting queries.
（View database at: https://courses.edx.org/asset-v1:StanfordOnline+SOE.YDB-SQL0001+2T2020+type@asset+block/moviedata.html
  specific records are appended below）
Here's the schema:

Movie ( mID, title, year, director )
English: There is a movie with ID number mID, a title, a release year, and a director.

Reviewer ( rID, name )
English: The reviewer with ID number rID has a certain name.

Rating ( rID, mID, stars, ratingDate )
English: The reviewer rID gave the movie mID a number of stars rating (1-5) on a certain ratingDate.
*/

-- 1. Find the titles of all movies directed by Steven Spielberg.

select title
from Movie
where director = 'Steven Spielberg'

-- 2. Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.

select distinct year
from Movie
where mID IN(SELECT mID FROM Rating where stars = 4 or stars = 5)
order by year

-- 3. Find the titles of all movies that have no ratings.

select title
from Movie
where mID NOT IN (SELECT mID from Rating)

-- 4. Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date.

select name
from Reviewer
where rID in (select rID FROM Rating where ratingDate IS NULL)

-- 5. Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars.

SELECT name as 'reviewer name', title as 'movie title', stars, ratingDate
from Movie m, Reviewer rv, Rating rt
where m.mID = rt.mID AND rv.rID = rt.rID
order by name, title, stars

-- 6. For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie.

select distinct rv.name, m.title
from Movie m, Rating r, Reviewer rv
WHERE rv.rID in(
	select r1.rID
	from Rating r1, Rating r2
	where r1.ratingDate > r2.ratingDate and r1.stars > r2.stars and r1.rID = r2.rID AND r1.mID = r2.mID)
	and m.mID in(
	select r1.mID
	from Rating r1, Rating r2
	where r1.ratingDate > r2.ratingDate and r1.stars > r2.stars and r1.rID = r2.rID AND r1.mID = r2.mID)

-- 7. For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title.

select title, max(stars)
from Movie m, Rating r
where r.mID = m.mID
group by title

-- 8. For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title.

select title, max(stars)-min(stars) as 'rating spread'
from Movie m
join Rating r
on m.mID = r.mID
GROUP BY title
order by max(stars)-min(stars) desc

-- 9. Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.)

select avg(bf.avg) - avg(af.avg)
from (select avg(stars) as avg
from Rating r1
inner join Movie m1
on r1.mID = m1.mID
where m1.year < 1980
GROUP BY r1.mID) bf,
(select avg(stars) as avg
from Rating r1
inner join Movie m1
on r1.mID = m1.mID
where m1.year > 1980
GROUP BY r1.mID) af

-- 10. Find the names of all reviewers who rated Gone with the Wind.

select name
from Reviewer
where rID IN (SELECT rID
			  FROM Rating
			  WHERE mID = (SELECT mID FROM Movie WHERE title = 'Gone with the Wind'))

-- 11. For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars.

SELECT name, title, stars
FROM Reviewer rv, Rating rt, Movie m
WHERE rt.rID = rv.rID AND rt.mID = m.mID AND m.director = rv.name

-- 12. Return all reviewer names and movie names together in a single list, alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".)

SELECT DISTINCT name
FROM Reviewer
UNION
SELECT DISTINCT title
FROM Movie
ORDER BY name, title

-- 13. Find the titles of all movies not reviewed by Chris Jackson.

SELECT title
FROM Movie
WHERE mID NOT IN (SELECT mID 
				  FROM Rating 
				  WHERE rID = (SELECT rID
							   FROM Reviewer
							   WHERE name = 'Chris Jackson'))

-- 14. For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order.

SELECT DISTINCT Re1.name, Re2.name
FROM Rating R1, Rating R2, Reviewer Re1, Reviewer Re2
WHERE R1.mID = R2.mID
AND R1.rID = Re1.rID
AND R2.rID = Re2.rID
AND Re1.name < Re2.name
ORDER BY Re1.name, Re2.name

-- 15. For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars.

SELECT name, title, stars
FROM Movie m, Reviewer rv, Rating rt
WHERE m.mID = rt.mID AND rv.rID = rt.rID AND stars = (SELECT MIN(stars)
													  FROM Rating)
-- GROUP BY name, title

-- 16. List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order.

SELECT title, AVG(stars)
FROM Movie m, Rating rt
WHERE m.mID = rt.mID
GROUP BY title
ORDER BY AVG(stars) DESC, title

-- 17. Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.)

SELECT DISTINCT name
FROM Reviewer rv, Rating rt
WHERE rv.rID = rt.rID
GROUP BY name
HAVING COUNT(mID) >= 3

-- 18. Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.)

SELECT m1.title, m1.director
FROM Movie m1, Movie m2
WHERE m1.director = m2.director AND m1.mID <> m2.mID
ORDER BY m1.director, m1.title

-- 19. Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.)

SELECT title, (SELECT MAX(avg)FROM (SELECT mID, AVG(stars) AS 'avg' FROM Rating GROUP BY mID))
FROM (SELECT mID, MAX(avg) AS 'average rating'
	  FROM (SELECT mID, AVG(stars) AS 'avg' FROM Rating GROUP BY mID)) maxavg
LEFT JOIN Movie m
ON maxavg.mID = m.mID

-- 20. Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. (Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.)

SELECT m.title, AVG(r.stars) 
FROM Rating r, Movie m
WHERE m.mID = r.mID
GROUP BY r.mID
HAVING AVG(r.stars) = (SELECT MIN(avg) FROM (SELECT mID, AVG(stars) AS 'avg' FROM Rating GROUP BY mID))

-- 21. For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL.

SELECT director, title, score
FROM (SELECT mID, MAX(stars) AS score FROM Rating GROUP BY mID)max LEFT JOIN Movie m ON m.mID = max.mID
WHERE director NOT NULL
GROUP BY director

-- 22. Add the reviewer Roger Ebert to your database, with an rID of 209.

INSERT INTO Reviewer VALUES(209, 'Roger Ebert')

-- 23. For all movies that have an average rating of 4 stars or higher, add 25 to the release year. (Update the existing tuples; don't insert new tuples.)

UPDATE Movie SET year = year+25
WHERE mID IN (SELECT mID FROM Rating GROUP BY mID HAVING AVG(stars) >= 4)

-- 24. Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.

DELETE FROM Rating
WHERE mID IN (SELECT m.mID FROM Movie m WHERE year < 1970 OR year > 2000)
AND stars<4






--------------- database --------------
/*
Movie
mID	title	year	director
101	Gone with the Wind	1939	Victor Fleming
102	Star Wars	1977	George Lucas
103	The Sound of Music	1965	Robert Wise
104	E.T.	1982	Steven Spielberg
105	Titanic	1997	James Cameron
106	Snow White	1937	<null>
107	Avatar	2009	James Cameron
108	Raiders of the Lost Ark	1981	Steven Spielberg

Reviewer
rID	name
201	Sarah Martinez
202	Daniel Lewis
203	Brittany Harris
204	Mike Anderson
205	Chris Jackson
206	Elizabeth Thomas
207	James Cameron
208	Ashley White

Rating
rID	mID	stars	ratingDate
201	101	2	2011-01-22
201	101	4	2011-01-27
202	106	4	<null>
203	103	2	2011-01-20
203	108	4	2011-01-12
203	108	2	2011-01-30
204	101	3	2011-01-09
205	103	3	2011-01-27
205	104	2	2011-01-22
205	108	4	<null>
206	107	3	2011-01-15
206	106	5	2011-01-19
207	107	5	2011-01-20
208	104	3	2011-01-02
*/
