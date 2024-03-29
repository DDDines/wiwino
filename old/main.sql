/*markdown
QUESTION 1 - We want to highlight 10 wines to increase our sales. Which ones should we choose and why?

You should choose these wines because they are the wines with the best ratings and with the most ratings, that is, they are the most popular and well-rated wines.





SELECT DISTINCT wines.name, vintages.ratings_average, vintages.ratings_count
FROM wines
JOIN vintages ON wines.id = vintages.wine_id
JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
JOIN toplists ON vintage_toplists_rankings.top_list_id = toplists.id
WHERE vintages.ratings_average > 4.5
ORDER BY vintages.ratings_count DESC
LIMIT 10;

/*markdown
QUESTION 2 - We have a limited marketing budget for this year. Which country should we prioritise and why? 

we should focus on italy and france because they are the countries with the most amount of wines with the best ratings.
*/

SELECT countries.name AS country_name, COUNT(DISTINCT wines.id) AS number_of_wines, AVG(vintages.ratings_average) AS average_rating
FROM wines
JOIN vintages ON wines.id = vintages.wine_id
JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
JOIN toplists ON vintage_toplists_rankings.top_list_id = toplists.id
JOIN regions ON wines.region_id = regions.id
JOIN countries ON regions.country_code = countries.code
WHERE vintages.ratings_average > 4.5
GROUP BY countries.name
ORDER BY number_of_wines DESC;

/*markdown
QUESTION 3 - We would like to give awards to the best wineries. Come up with 3 relevant ones. Which wineries should we choose and why?


These wineries exhibit consistent high-quality production, significant popularity among consumers as reflected by the number of ratings, and recognition within the wine industry through their rankings in vintage toplist.




   SELECT
        CASE
            WHEN LENGTH(vintages.name) - LENGTH(wineries.name) - 5 = 0 THEN wineries.name
            ELSE SUBSTR(vintages.name, 1, LENGTH(vintages.name) - LENGTH(wineries.name) - 5)
        END as winery_name,
        AVG(vintages.ratings_average) as average_rating,
        count(*) as rating_count,
        SUM(vintages.ratings_count) as rating_sum,
        AVG(vintage_toplists_rankings.rank) as rank
    FROM
        wineries
    JOIN
        vintages ON wineries.id = vintages.wine_id
    JOIN
        wines ON vintages.wine_id = wines.id
    JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
    WHERE vintages.ratings_average >= 4.0 AND rating_count <= 10
    GROUP BY winery_name
    ORDER BY  rank ASC,average_rating DESC,rating_count DESC,rating_count ASC;

    SELECT
        CASE
            WHEN LENGTH(vintages.name) - LENGTH(wineries.name) - 5 = 0 THEN wineries.name
            ELSE SUBSTR(vintages.name, 1, LENGTH(vintages.name) - LENGTH(wineries.name) - 5)
        END as winery_name,
        AVG(vintages.ratings_average) as average_rating,
        count(*) as rating_count,
        SUM(vintages.ratings_count) as rating_sum,
        AVG(vintage_toplists_rankings.rank) as rank
    FROM
        wineries
    JOIN
        vintages ON wineries.id = vintages.wine_id
    JOIN
        wines ON vintages.wine_id = wines.id
    JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
    WHERE vintages.ratings_average >= {rating_min}, rating_count <= {rating_count}
    GROUP BY winery_name
    ORDER BY  rank ASC,average_rating DESC,rating_count DESC,rating_count ASC;

SELECT
    CASE
        WHEN LENGTH(vintages.name) - LENGTH(REPLACE(vintages.name, wineries.name, '')) = 5
        THEN wineries.name
        ELSE SUBSTR(vintages.name, 1, LENGTH(vintages.name) - LENGTH(REPLACE(vintages.name, wineries.name, '')) - 5)
    END as winery_name,
    AVG(vintages.ratings_average) as average_rating,
    COUNT(vintages.id) as rating_count,
    SUM(vintages.ratings_count) as rating_sum,
    AVG(vintage_toplists_rankings.rank) as average_rank
FROM
    wineries
JOIN
    vintages ON wineries.id = vintages.wine_id
JOIN
    vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
WHERE
    vintages.ratings_average >= 4.0 
GROUP BY
    winery_name
HAVING
    rating_count < 2
ORDER BY
    average_rank ASC, average_rating DESC, rating_count DESC;




SELECT
    wineries.id as id_wineries,
    CASE
        WHEN LENGTH(vintages.name) - LENGTH(wineries.name) - 5 = 0 THEN wineries.name
        ELSE SUBSTR(vintages.name, 1, LENGTH(vintages.name) - LENGTH(wineries.name) - 5)
    END as winery_name,
    AVG(vintages.ratings_average) as average_rating,
    count(*) as rating_count,
    SUM(vintages.ratings_count) as rating_sum,
    AVG(vintage_toplists_rankings.rank) as rank
FROM
    wineries
JOIN
    vintages ON wineries.id = vintages.wine_id
JOIN
    wines ON vintages.wine_id = wines.id
JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
GROUP BY winery_name
ORDER BY  rank ASC,average_rating DESC,rating_count DESC,rating_count ASC
LIMIT 3;

/*markdown
QUESTION 4 - We detected that a big cluster of customers likes a specific combination of tastes. We identified a few keywords that match these tastes: _coffee_, _toast_, _green apple_, _cream_, and _citrus_ (note that these keywords are case sensitive ⚠️). We would like you to find all the wines that are related to these keywords. Check that **at least 10 users confirm those keywords**, to ensure the accuracy of the selection. Additionally, identify an appropriate group name for this cluster.
*/

SELECT 
    wines.name AS WineName,
    SUM(vintages.ratings_count) AS RatingsCount,
    GROUP_CONCAT(DISTINCT keywords.name) AS MatchedKeywords,
    COUNT(DISTINCT keywords.name) AS Count_MatchedKeywords
FROM 
    wines 
JOIN 
    vintages ON wines.id = vintages.wine_id
JOIN 
    keywords_wine ON wines.id = keywords_wine.wine_id
JOIN 
    keywords ON keywords_wine.keyword_id = keywords.id
WHERE 
    keywords.name IN ('coffee', 'toast', 'green apple', 'cream', 'citrus')
GROUP BY 
    wines.name
HAVING
    Count_MatchedKeywords = 5
ORDER BY  
    Count_MatchedKeywords DESC,
    RatingsCount DESC;




/*markdown
QUESTION 5 - We would like to select wines that are easy to find all over the world. **Find the top 3 most common `grape`s all over the world** and **for each grape, give us the the 5 best rated wines**.
*/

SELECT
    g.name AS grape_name,
    COUNT(mug.country_code) as country_count,    
    SUM(mug.wines_count) as total_wines_count
FROM 
    most_used_grapes_per_country mug
JOIN grapes g ON mug.grape_id = g.id
GROUP BY 
    g.name
ORDER BY
    total_wines_count DESC, country_count DESC
LIMIT 3;

SELECT 
    vintages.name AS wine_name,
    grapes.name AS grape_name,
    AVG(vintages.ratings_average) AS average_rating,
    SUM(vintages.ratings_count) AS total_ratings_count,
    AVG(vintage_toplists_rankings.rank) as rank
FROM wines
JOIN vintages ON wines.id = vintages.wine_id
JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
JOIN toplists ON vintage_toplists_rankings.top_list_id = toplists.id
JOIN regions ON wines.region_id = regions.id
JOIN most_used_grapes_per_country ON regions.country_code = most_used_grapes_per_country.country_code
JOIN grapes ON most_used_grapes_per_country.grape_id = grapes.id
GROUP BY wines.name, grapes.name, regions.name
HAVING AVG(vintages.ratings_average) > 4.5 AND grape_name = 'Sangiovese'
ORDER BY rank ASC,total_ratings_count DESC, average_rating DESC
LIMIT 5;

/*markdown
QUESTION 6 - We would like to create a country leaderboard. Come up with a visual that shows the **average wine rating for each `country`**. Do the same for the `vintages`.
*/

import sqlite3 
import matplotlib.pyplot as plt

conn = sqlite3.connect('db/vivino.db')
print("Opened database successfully")

avg_country_rating_query = """
SELECT 
    countries.name AS country_name, 
    AVG(vintages.ratings_average) AS avg_country_rating
FROM countries
JOIN regions ON countries.code = regions.country_code
JOIN wines ON regions.id = wines.region_id
JOIN vintages ON wines.id = vintages.wine_id
GROUP BY countries.name
ORDER BY avg_country_rating DESC;
"""

# Execute the first query
cursor = conn.cursor()
cursor.execute(avg_country_rating_query)
country_avg_ratings = cursor.fetchall()

# Prepare the data for plotting
country_names = [row[0] for row in country_avg_ratings]
country_ratings = [row[1] for row in country_avg_ratings]

# Plotting the average rating by country
plt.figure(figsize=(10, 8))
plt.barh(country_names, country_ratings, color='skyblue')
plt.xlabel('Average Rating')
plt.title('Average Wine Rating by Country')
plt.gca().invert_yaxis()  # Invert the y-axis to show the highest rating at the top
plt.tight_layout()
plt.show()







import sqlite3
import matplotlib.pyplot as plt

vintage_avg_rating_query = '''
SELECT 
    vintages.year AS vintage_year, 
    AVG(vintages.ratings_average) AS avg_rating
FROM 
    vintages
GROUP BY 
    vintages.year
ORDER BY 
    vintage_year;
'''

conn = sqlite3.connect('db/vivino.db')
print("Opened database successfully")

cursor = conn.cursor()
print("Cursor created successfully")

cursor.execute(vintage_avg_rating_query)
vintage_avg_ratings = cursor.fetchall()
print(cursor.fetchall())


# Plot for average rating by vintage by year and average rating
vintage_years = [row[0] for row in vintage_avg_ratings]
vintage_ratings = [row[1] for row in vintage_avg_ratings]

plt.figure(figsize=(15, 5))
plt.plot(vintage_years, vintage_ratings, marker='o', color='coral')
plt.xlabel('Year')
plt.ylabel('Average Rating')
plt.title('Average Vintage Rating Over Years')
plt.grid(True)
plt.tight_layout()
plt.show()


/*markdown
QUESTION 7 - One of our VIP clients likes _Cabernet Sauvignon_ and would like our top 5 recommendations. Which wines would you recommend to him?
*/

SELECT 
    v.name AS wine_name,
    g.name AS grape_name,
    v.ratings_average AS average_rating,
    v.ratings_count AS total_ratings_count,
    AVG(vtr.rank) as average_rank
FROM 
    vintages v
JOIN vintage_toplists_rankings vtr ON v.id = vtr.vintage_id
JOIN grapes g ON v.name LIKE '%' || g.name || '%'
WHERE 
    g.name in ('Merlot')
GROUP BY 
    v.name, g.name
ORDER BY 
    v.ratings_count DESC, 
    v.ratings_average DESC, 
    average_rank ASC
LIMIT 5;

SELECT 
    v.name AS wine_name,
    (SELECT g.name FROM grapes g WHERE v.name LIKE '%' || g.name || '%') AS grape_name,
    v.ratings_average AS average_rating,
    v.ratings_count AS total_ratings_count
FROM 
    vintages v
WHERE 
    EXISTS (SELECT 1 FROM grapes g WHERE v.name LIKE '%' || g.name || '%') AND
    grape_name in ('Merlot','Cabernet Sauvignon')
ORDER BY 
     v.ratings_count DESC, v.ratings_average DESC;

SELECT grapes.name from grapes

    SELECT 
            vintages.name AS wine_name,
            grapes.name AS grape_name,
            AVG(vintages.ratings_average) AS average_rating,
            SUM(vintages.ratings_count) AS total_ratings_count,
            AVG(vintage_toplists_rankings.rank) as rank
        FROM wines
        JOIN vintages ON wines.id = vintages.wine_id
        JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
        JOIN toplists ON vintage_toplists_rankings.top_list_id = toplists.id
        JOIN regions ON wines.region_id = regions.id
        JOIN most_used_grapes_per_country ON regions.country_code = most_used_grapes_per_country.country_code
        JOIN grapes ON most_used_grapes_per_country.grape_id = grapes.id
        GROUP BY wines.name, grapes.name, regions.name
        ORDER BY rank ASC,total_ratings_count DESC, average_rating DESC;

SELECT 
  vintages.name AS wine_name,
  AVG(vintages.price_euros) AS average_price_euros,
  AVG(vintages.ratings_average) AS average_rating,
  SUM(vintages.ratings_count) AS total_ratings_count,
  AVG(vintage_toplists_rankings.rank) as average_rank,
  (SELECT g.name FROM grapes g WHERE vintages.name LIKE '%' || g.name || '%') AS grape_name
FROM wines
JOIN vintages ON wines.id = vintages.wine_id
JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
JOIN toplists ON vintage_toplists_rankings.top_list_id = toplists.id
JOIN regions ON wines.region_id = regions.id
JOIN most_used_grapes_per_country ON regions.country_code = most_used_grapes_per_country.country_code
JOIN grapes ON most_used_grapes_per_country.grape_id = grapes.id
GROUP BY wines.name, grapes.name, regions.name
HAVING average_price_euros BETWEEN 20 AND 2500 
AND average_rank <= 25
AND average_rating >= 4.5
AND grape_name = 'Cabernet Sauvignon'
AND EXISTS (SELECT 1 FROM grapes g WHERE vintages.name LIKE '%' || g.name || '%')
ORDER BY average_rank ASC, total_ratings_count DESC, average_rating DESC


SELECT 
    countries.name AS country_name, 
    COUNT(vintages.name) AS number_of_wines, 
    SUM(vintages.ratings_count) AS total_ratings_count, 
    AVG(vintages.ratings_average) AS average_rating
FROM vintages
JOIN wines ON vintages.wine_id = wines.id
JOIN regions ON wines.region_id = regions.id
JOIN countries ON regions.country_code = countries.code
JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
JOIN toplists ON vintage_toplists_rankings.top_list_id = toplists.id
WHERE vintages.ratings_average >= 4 AND vintages.ratings_count >= 100
GROUP BY countries.name
ORDER BY number_of_wines DESC;


SELECT 
    countries.name AS country_name, 
    COUNT(vintages.id) AS number_of_wines, 
    SUM(CASE WHEN vintages.ratings_count IS NULL OR vintages.ratings_count = 0 THEN 1 ELSE vintages.ratings_count END) AS total_ratings_count, 
    AVG(vintages.ratings_average) AS average_rating
FROM vintages
JOIN wines ON vintages.wine_id = wines.id
JOIN regions ON wines.region_id = regions.id
JOIN countries ON regions.country_code = countries.code
LEFT JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
LEFT JOIN toplists ON vintage_toplists_rankings.top_list_id = toplists.id
WHERE vintages.ratings_count >= 0
GROUP BY countries.name
HAVING average_rating >= 0
ORDER BY number_of_wines DESC;


SELECT 
    countries.name AS country_name, 
    COUNT(vintages.id) AS number_of_wines, 
    SUM(CASE WHEN vintages.ratings_count IS NULL OR vintages.ratings_count = 0 THEN 1 ELSE vintages.ratings_count END) AS total_ratings_count, 
    AVG(vintages.ratings_average) AS average_rating,
    AVG(vintages.price_euros) AS average_price
FROM vintages
JOIN wines ON vintages.wine_id = wines.id
JOIN regions ON wines.region_id = regions.id
JOIN countries ON regions.country_code = countries.code
LEFT JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
LEFT JOIN toplists ON vintage_toplists_rankings.top_list_id = toplists.id
WHERE vintages.ratings_count >= 0
GROUP BY countries.name
HAVING average_rating >= 0 AND average_price >= 0
ORDER BY number_of_wines DESC;
