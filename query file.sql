select * from new_table;
-- 15 problem statements   
-- 1. Count the no. of movies and tv shows
 select count(type) from new_table where type='Movie';
 select count(type) from new_table where type='TV Show';
 
 -- 2 Most common rating for Movies and TV Show 
 
 select type,rating,(count(rating)) from new_table group by type,rating order by (count(rating)) desc;
 -- The most common rating is TV-MA

-- 3 List All movies released in a specific year 
select * from new_table;
select title from new_table where release_year='2020' and type='Movie';

-- 4 Find top 5 countries with the most content on netflix 
select country from new_table;
SELECT 
    TRIM(JSON_UNQUOTE(jt.new_country)) AS new_country,
    COUNT(nt.show_id) AS content_released
FROM 
    new_table AS nt,
    JSON_TABLE(
        CONCAT('["', REPLACE(nt.country, ',', '","'), '"]'),
        '$[*]' COLUMNS (new_country JSON PATH '$')
    ) AS jt
GROUP BY jt.new_country
ORDER BY content_released DESC
LIMIT 5;

-- 5 Identify the longest movie 
select * from new_table;
select title as longest_movie from new_table 
	where type='Movie'
    and 
    duration=(select max(duration) from new_table);

-- 6 Find content added in the last 5 year 

SELECT *
FROM new_table
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);

-- 7 Find all the movies/tv shows by rajiv chilaka 
select title from new_table where director like '%Rajiv Chilaka%';

-- 8 List all tv shows which have more than 5 seasons 
select * from new_table;
SELECT title AS tv_show
FROM new_table
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1)as UNSIGNED) > 5;


-- 9 Count the number of content items in each genre 
select * from new_table;
select listed_in,count(title) from new_table 
group by listed_in;

SELECT 
    genre AS listed_genre,
    COUNT(title) AS title_count
FROM 
    new_table,
    JSON_TABLE(
        CONCAT('["', REPLACE(listed_in, ',', '","'), '"]'),
        '$[*]' COLUMNS (genre VARCHAR(255) PATH '$')
    ) jt
GROUP BY listed_genre;

-- 10 for each year and the avg numbers of content released by India on netflix 
-- return top 5 year with the highest avg content released 

select * from new_table;
SELECT release_year, AVG(count_show) AS avg_show_count
FROM (
    SELECT release_year, COUNT(show_id) AS count_show
    FROM new_table
    WHERE country like '%India%'
    GROUP BY release_year
) AS year_counts
GROUP BY release_year
order by count_show desc
limit 5;


-- 11 list all movies that are documentries 
select * from new_table;
select title as movies from new_table 
where listed_in like '%Documentaries%';

-- 12 find content without director 
SELECT * 
FROM new_table
WHERE director IS NULL;

-- 13 in how many movies salman khan acted in last 10 years
select * from new_table;
SELECT COUNT(*) AS no_of_movies_acted
FROM new_table
WHERE cast LIKE '%Salman Khan%'
  AND DATEDIFF(CURRENT_DATE(), STR_TO_DATE(date_added, '%Y-%m-%d')) < 10;

-- 14 find actors who have appeared in the highest num of movies produced in india 
select * from new_table;
SELECT 
    actors AS listed_actors,
    count(show_id) as movies_done
FROM 
    new_table,
    JSON_TABLE(
        CONCAT('["', REPLACE(cast, ',', '","'), '"]'),
        '$[*]' COLUMNS (actors VARCHAR(255) PATH '$')
    ) jt
    where country='India'
    and type='Movie'
group by listed_actors
order by count(show_id) desc
limit 5;


-- 15 Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM new_table
) AS categorized_content
GROUP BY category;
