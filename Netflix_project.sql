drop table if exists Netflix
create table Netflix
(
	show_id	varchar(20),
	type varchar(20)	,
	title varchar(250),
	director varchar(250),
	casts varchar(1500),
	country	varchar(150),
	date_added varchar(100),
	release_year int,
	rating	varchar(30),
	duration varchar(20),
	listed_in varchar(30),
	description varchar(300)
);


-- 1. Count the number of Movies vs TV Shows
select type, count(*) as total from Netflix
group by type;



-- 2. Find the most common rating for movies and TV shows
select
type,
rating
from

(select type, rating, count(*), 
rank() over(partition by type order by count(*) desc) as ranking
from Netflix
group by type, rating) as t1
where ranking = 1
;



-- 3. List all movies released in a specific year (e.g., 2020)
select type, release_year, count(*) from Netflix
group by type, release_year
order by 2;



-- 4. Find the top 5 countries with the most content on Netflix
select  unnest(string_to_array(country, ',')) as countries, 
count(show_id) as total from Netflix
group by  country
order by total desc;



--5. Identify the longest movie
select * from Netflix
where type = 'Movie'
AND duration = (select MAX(duration) from Netflix);



--6. Find content added in the last 5 years
select *
from Netflix
where
to_date(date_added, 'Month, DD, YYYY') >= current_date- interval '5 years'



--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from Netflix
where director ILIKE '%Rajiv Chilaka%';



--8. List all TV shows with more than 5 seasons
select 
	* 
from Netflix
where 
	type = 'TV Shows' 
	AND
	SPLIT_PART(duration, ' ',1)::numeric > 5



--9. Count the number of content items in each genre
select unnest(string_to_array(listed_in, ',')) as genre, 
count(show_id) as total_count
from Netflix
group by genre
order by total_count desc;



--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;



--11. List all movies that are documentaries
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';



--12. Find all content without a director
SELECT * 
FROM netflix
WHERE director IS NULL;



--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;



--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;





15.
--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;






