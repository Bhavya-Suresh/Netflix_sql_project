---- 18 Business Problems & Solutions
--1. Count the number of Movies vs TV Shows

select type, count(*) as Total_Content from netflix
group by type

--2. Find the most common rating for movies and TV shows

select type, rating, count(*) as total,
	rank() over (partition by type order by count(*) desc) as ranks into #temp
	from netflix
	group by type, rating

select type, rating from #temp
where ranks = 1

drop table #temp

--3. List all movies released in a specific year (e.g., 2020)

select * from netflix
where type = 'Movie' and release_year = 2020

-- 4. Identify the longest movie

select * from netflix
where type = 'Movie' and 
duration = (select max(duration) from netflix)

-- 5. Find content added in the last 5 years

select * from netflix
where CAST(date_added AS DATE) >= DATEADD(YEAR, -5, GETDATE())

-- 6. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select * from netflix
where director like '%Rajiv Chilaka%'

-- 7. List all TV shows with more than 5 seasons

select * from netflix
where type = 'TV Show' and 
CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5

/* 8.Find each year and the average numbers of content release by India on netflix. 
return top 5 year with highest avg content release*/

WITH IndiaContent AS (
	Select release_year, COUNT(*) AS ContentCount
    From Netflix
    Where country LIKE '%India%'  
    Group by release_year
),YearlyAverage AS (
    Select release_year, AVG(ContentCount) OVER () AS AvgContentRelease
    From IndiaContent)

Select top 5 release_year, AvgContentRelease
From YearlyAverage
Order by AvgContentRelease desc

-- 9. List all movies that are documentaries

select * from netflix
where type = 'Movie' and listed_in like '%documentaries%'

-- 10. Find all content without a director

select * from netflix
where director is null

-- 11. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select * from netflix
where cast like '%Salman Khan%'
	and release_year >= YEAR(GETDATE()) - 10

/*
Question 12:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

Select 
    CASE 
    WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
    ELSE 'Good'
	END AS Category,
	COUNT(*) AS ContentCount
FROM Netflix
GROUP BY 
    CASE 
    WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
    ELSE 'Good'
    END

-- 13. How many TV shows have been released in each year

Select release_year, COUNT(*) AS TVShowCount
from Netflix
where type = 'TV Show'
Group by release_year
ORDER BY release_year desc

-- 14. List all movies that are longer than 2 hours.

Select title, duration
from Netflix
where type = 'Movie' AND CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 120
order by duration desc

--15. Which rating is the most common across all content types?

Select rating, COUNT(*) AS RatingCount
from Netflix
Group by rating
ORDER BY RatingCount DESC

--16. List all family-friendly content (e.g., rated 'G' or 'PG')

Select title, type, rating
from Netflix
where rating IN ('G', 'PG', 'PG-13')

--17. Which director has the most titles on Netflix?

Select director, COUNT(*) AS TitleCount
from Netflix
where director IS NOT NULL
Group by director
ORDER BY TitleCount DESC

--18. What percentage of the content is TV shows compared to movies?

Select type, COUNT(*) * 100.0 / (Select COUNT(*) from Netflix) AS Percentage
from Netflix
Group by type
