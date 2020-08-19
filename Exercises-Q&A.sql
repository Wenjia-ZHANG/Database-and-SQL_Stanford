-- 1. Find the titles of all movies directed by Steven Spielberg.

select title
from Movie
where director = 'Steven Spielberg'

-- 2. Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.

select distinct year
from Movie
where mID IN(SELECT mID FROM Rating where stars = 4 or stars = 5)
order by year

SELECT DISTINCT year
FROM Movie, Rating
WHERE Movie.mId = Rating.mId AND stars IN (4, 5)
ORDER BY year;

SELECT DISTINCT year
FROM Movie
INNER JOIN Rating ON Movie.mId = Rating.mId
WHERE stars IN (4, 5)
ORDER BY year;

SELECT DISTINCT year
FROM Movie
INNER JOIN Rating USING(mId)
WHERE stars IN (4, 5)
ORDER BY year;

SELECT DISTINCT year
FROM Movie NATURAL JOIN Rating
WHERE stars IN (4, 5)
ORDER BY year;


-- 3. Find the titles of all movies that have no ratings. 

select title
from Movie
where mID NOT IN (SELECT mID from Rating)

SELECT title
FROM Movie
WHERE mId NOT IN (SELECT mID FROM Rating);


-- 4. Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date. 

select name
from Reviewer
where rID in (select rID FROM Rating where ratingDate IS NULL)

SELECT name
FROM Reviewer
INNER JOIN Rating USING(rId)
WHERE ratingDate IS NULL;


-- 5. Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. 

SELECT name as 'reviewer name', title as 'movie title', stars, ratingDate
from Movie m, Reviewer rv, Rating rt
where m.mID = rt.mID AND rv.rID = rt.rID
order by name, title, stars

SELECT name, title, stars, ratingDate
FROM Movie, Rating, Reviewer
WHERE Movie.mId = Rating.mId AND Reviewer.rId = Rating.rId
ORDER BY name, title, stars;

SELECT name, title, stars, ratingDate
FROM Movie
INNER JOIN Rating ON Movie.mId = Rating.mId
INNER JOIN Reviewer ON Reviewer.rId = Rating.rId
ORDER BY name, title, stars;

SELECT name, title, stars, ratingDate
FROM Movie
INNER JOIN Rating USING(mId)
INNER JOIN Reviewer USING(rId)
ORDER BY name, title, stars;

SELECT name, title, stars, ratingDate
FROM Movie NATURAL JOIN Rating NATURAL JOIN Reviewer
ORDER BY name, title, stars;


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
 
SELECT name, title
FROM Movie
INNER JOIN Rating R1 USING(mId)
INNER JOIN Rating R2 USING(rId)
INNER JOIN Reviewer USING(rId)
WHERE R1.mId = R2.mId AND R1.ratingDate < R2.ratingDate AND R1.stars < R2.stars;

SELECT name, title
FROM Movie
INNER JOIN Rating R1 USING(mId)
INNER JOIN Rating R2 USING(rId, mId)
INNER JOIN Reviewer USING(rId)
WHERE R1.ratingDate < R2.ratingDate AND R1.stars < R2.stars;


-- 7. For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title. 

select title, max(stars)
from Movie m, Rating r
where r.mID = m.mID
group by title

SELECT title, MAX(stars)
FROM Movie
INNER JOIN Rating USING(mId)
GROUP BY mId
ORDER BY title;


-- 8. For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title. 

select title, max(stars)-min(stars) as 'rating spread'
from Movie m
join Rating r
on m.mID = r.mID
GROUP BY title
order by max(stars)-min(stars) desc

SELECT title, (MAX(stars) - MIN(stars)) AS rating_spread
FROM Movie
INNER JOIN Rating USING(mId)
GROUP BY mId
ORDER BY rating_spread DESC, title;


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

SELECT AVG(Before1980.avg) - AVG(After1980.avg)
FROM (
  SELECT AVG(stars) AS avg
  FROM Movie
  INNER JOIN Rating USING(mId)
  WHERE year < 1980
  GROUP BY mId
) AS Before1980, (
  SELECT AVG(stars) AS avg
  FROM Movie
  INNER JOIN Rating USING(mId)
  WHERE year > 1980
  GROUP BY mId
) AS After1980;
