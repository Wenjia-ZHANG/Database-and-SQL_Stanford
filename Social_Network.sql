/* ---- database intro. ------
Students at your hometown high school have decided to organize their social network using databases. So far, they have collected information about sixteen students in four grades, 9-12. Here's the schema:
（View database at: https://courses.edx.org/asset-v1:StanfordOnline+SOE.YDB-SQL0001+2T2020+type@asset+block/socialdata.html
  specific records are appended below）
Highschooler ( ID, name, grade )
English: There is a high school student with unique ID and a given first name in a certain grade.

Friend ( ID1, ID2 )
English: The student with ID1 is friends with the student with ID2. Friendship is mutual, so if (123, 456) is in the Friend table, so is (456, 123).

Likes ( ID1, ID2 )
English: The student with ID1 likes the student with ID2. Liking someone is not necessarily mutual, so if (123, 456) is in the Likes table, there is no guarantee that (456, 123) is also present.
*/

-- 1. Find the names of all students who are friends with someone named Gabriel.

SELECT name
FROM Highschooler
WHERE ID IN(SELECT ID1 FROM Friend WHERE ID2 IN (SELECT ID FROM Highschooler WHERE name = 'Gabriel'))

-- 2. For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like.

SELECT h.name, h.grade, hl.name, hl.grade
FROM Highschooler h LEFT JOIN Likes l ON h.ID = l.ID1
LEFT JOIN Highschooler hl ON l.ID2 = hl.ID
WHERE H.grade-hl.grade >= 2

-- 3. For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order.

SELECT h1.name, h1.grade, h2.name, h2.grade
FROM (SELECT l1.ID1 AS ID1, l1.ID2 AS ID2 FROM Likes l1, Likes l2 WHERE l1.ID1 = l2.ID2 AND l1.ID2 = l2.ID1 ) l 
LEFT JOIN Highschooler h1 ON l.ID1 = h1.ID
LEFT JOIN Highschooler h2 ON l.ID2 = h2.ID
WHERE h1.name < h2.name
ORDER BY h1.name, h2.name

-- 4. Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade.

SELECT name, grade
FROM Highschooler
WHERE ID NOT IN (SELECT ID1 FROM Likes UNION SELECT ID2 FROM Likes)
ORDER BY grade, name

-- 5. For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades.

SELECT a.name, a.grade, b.name, b.grade
FROM (SELECT ID1, ID2 FROM Likes WHERE ID2 NOT IN (SELECT DISTINCT ID1 FROM Likes)) l
LEFT JOIN Highschooler a ON l.ID1 = a.ID
LEFT JOIN Highschooler b ON l.ID2 = b.ID

-- 6. Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade.

SELECT h1.name, h1.grade
FROM Friend f 
LEFT JOIN Highschooler h1 ON h1.ID = f.ID1
LEFT JOIN Highschooler h2 ON h2.ID = f.ID2
GROUP BY h1.name, h1.grade
HAVING COUNT(DISTINCT h2.grade) = 1 AND h1.grade = h2.grade
ORDER BY h1.grade, h1.grade

-- 7. For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C.

SELECT DISTINCT H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
FROM Highschooler H1, Highschooler H2, Highschooler H3, Likes L, Friend F1, Friend F2
WHERE (H1.ID = L.ID1 AND H2.ID = L.ID2) 
AND H2.ID NOT IN (
  SELECT ID2
  FROM Friend
  WHERE ID1 = H1.ID
) 
AND (H1.ID = F1.ID1 AND H3.ID = F1.ID2) 
AND (H2.ID = F2.ID1 AND H3.ID = F2.ID2)

-- 8. Find the difference between the number of students in the school and the number of different first names.

SELECT COUNT(DISTINCT ID)-COUNT(DISTINCT name)
FROM Highschooler

-- 9. Find the name and grade of all students who are liked by more than one other student.

SELECT name, grade
FROM Highschooler
WHERE ID IN (
	SELECT ID2 FROM Likes
	GROUP BY ID2
	HAVING COUNT(DISTINCT ID1) > 1)

-- 10. For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C.

SELECT h1.name, h1.grade, h2.name, h2.grade, h3.name, h3.grade
FROM (SELECT l1.ID1 AS A, l1.ID2 AS B, l2.ID2 AS C FROM Likes l1 LEFT JOIN Likes l2 ON l1.ID2 = l2.ID1 WHERE l1.ID1 <> l2.ID2)l
LEFT JOIN Highschooler h1 ON A = h1.ID
LEFT JOIN Highschooler h2 ON B = h2.ID
LEFT JOIN Highschooler h3 ON C = h3.ID

-- 11. Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades.

SELECT h.name, h.grade
FROM Highschooler h
WHERE h.grade NOT IN(
SELECT h2.grade FROM Friend f1
LEFT JOIN Highschooler h1 ON f1.ID1 = h1.ID
LEFT JOIN Highschooler h2 ON f1.ID2 = h2.ID
WHERE h1.ID = h.ID				  
)

-- 12. What is the average number of friends per student? (Your result should be just one number.)

SELECT AVG(num)
FROM (SELECT COUNT(ID2) AS num FROM Friend GROUP BY ID1)

-- 13. Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend.

SELECT COUNT(Cassandra_friend)
FROM (SELECT f1.ID2 AS Cassandra_friend
		FROM Friend f1
		WHERE f1.ID1 = (SELECT h1.ID FROM Highschooler h1 WHERE h1.name = 'Cassandra')
	UNION
		SELECT f2.ID2 AS Cassandra_friend
		FROM Friend f2
		WHERE f2.ID1 IN (SELECT f3.ID2 FROM Friend f3
				WHERE f3.ID1 = (SELECT h1.ID FROM Highschooler h1 WHERE h1.name = 'Cassandra'))
	AND f2.ID2 <> (SELECT h1.ID FROM Highschooler h1 WHERE h1.name = 'Cassandra'))

-- 14. Find the name and grade of the student(s) with the greatest number of friends.

SELECT name, grade
FROM Highschooler
WHERE ID IN(
SELECT f2.ID1 FROM Friend f2 GROUP BY f2.ID1 HAVING COUNT(DISTINCT f2.ID2) =
(SELECT MAX(number) FROM (SELECT COUNT(DISTINCT f1.ID2) AS number FROM Friend f1 GROUP BY f1.ID1)))

-- 15. It's time for the seniors to graduate. Remove all 12th graders from Highschooler.

DELETE FROM Highschooler WHERE grade = 12

-- 16. If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple.

DELETE FROM Likes
WHERE ID1 NOT IN (SELECT l2.ID2 FROM Likes l2 WHERE l2.ID1 = Likes.ID2)
AND ID2 IN (SELECT f.ID2 FROM Friend f WHERE f.ID1 = Likes.ID1)

-- 17. For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. Do not add duplicate friendships, friendships that already exist, or friendships with oneself. (This one is a bit challenging; congratulations if you get it right.)

INSERT INTO Friend
SELECT DISTINCT f1.ID1, f3.ID2 FROM Friend f1, Friend f3
WHERE f1.ID1 NOT IN (SELECT f2.ID1 FROM Friend f2 WHERE f2.ID2 = f3.ID2)
AND f1.ID2 = f3.ID1
AND f1.ID1 <> f3.ID2	  
	  -- , SELECT * FROM Friend f1 WHERE f1.ID1 NOT IN (SELECT f2.ID2 FROM Friend f2 WHERE f2.ID1 = f1.ID2))
-- f1.ID1 is A, f1.ID2 & f2.ID1 is B, (SELECT f2.ID2 FROM Friend f2 WHERE f2.ID1 = f1.ID2) is B's friends
---SELECT * FROM Friend f1 WHERE f1.ID1 NOT IN (SELECT f2.ID2 FROM Friend f2 WHERE f2.ID1 = f1.ID2)



---------- database ------------
/*
Highschooler
ID	name	grade
1510	Jordan	9
1689	Gabriel	9
1381	Tiffany	9
1709	Cassandra	9
1101	Haley	10
1782	Andrew	10
1468	Kris	10
1641	Brittany	10
1247	Alexis	11
1316	Austin	11
1911	Gabriel	11
1501	Jessica	11
1304	Jordan	12
1025	John	12
1934	Kyle	12
1661	Logan	12

Friend
ID1	ID2
1510	1381
1510	1689
1689	1709
1381	1247
1709	1247
1689	1782
1782	1468
1782	1316
1782	1304
1468	1101
1468	1641
1101	1641
1247	1911
1247	1501
1911	1501
1501	1934
1316	1934
1934	1304
1304	1661
1661	1025
1381	1510
1689	1510
1709	1689
1247	1381
1247	1709
1782	1689
1468	1782
1316	1782
1304	1782
1101	1468
1641	1468
1641	1101
1911	1247
1501	1247
1501	1911
1934	1501
1934	1316
1304	1934
1661	1304
1025	1661

Likes
ID1	ID2
1689	1709
1709	1689
1782	1709
1911	1247
1247	1468
1641	1468
1316	1304
1501	1934
1934	1501
1025	1101
*/
