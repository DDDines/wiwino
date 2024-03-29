SELECT 
    DISTINCT (vintages.name) AS wine_name,
    wineries.name AS winery_name
FROM 
    vintages
JOIN 
    wineries ON vintages.name LIKE '%' || wineries.name || '%'

    winery_name == "Tignanello"








SELECT
    wineries.id as id_wineries,
    SUBSTR(vintages.name, 1, LENGTH(vintages.name) - LENGTH(wineries.name) - 5) as winery_name,
    vintages.ratings_avarage as rating,
FROM
    wineries,
    vintages
JOIN
    vintages ON wineries.id = vintages.wine_id
JOIN
    wines ON vintages.wine_id = wines.id

order by wineries.id




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





CREATE TABLE wineries_fixed (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);




UPDATE wineries_fixed
SET 
    wineries.id,
    SUBSTR(vintages.name, 1, LENGTH(vintages.name) - LENGTH(wineries.name) - 5) 
FROM 
    vintages
JOIN wineries ON vintages.wine_id = wines.id
JOIN wines ON vintages.wine_id = wines.id
GROUP BY winery_id;




SELECT wineries_fixed.name, AVG(vintages.ratings_average) AS average_rating
FROM wineries_fixed
JOIN wines ON wineries_fixed.id = wines.winery_id
JOIN vintages ON wines.id = vintages.wine_id
GROUP BY wineries_fixed.name
ORDER BY average_rating DESC;




DROP TABLE IF EXISTS wineries_fixed;




/*markdown

    SELECT DISTINCT wines.name, 
    vintages.ratings_average, vintages.ratings_count,AVG(vintages.price_euros) AS average_price
    FROM wines
    JOIN vintages ON wines.id = vintages.wine_id
    JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
    JOIN toplists ON vintage_toplists_rankings.top_list_id = toplists.id
        WHERE vintages.ratings_average > 0 AND vintages.ratings_count > 0
    ORDER BY vintages.ratings_count DESC;

SELECT
    wines.name AS WineName,
    COUNT(DISTINCT keywords_wine.keyword_id) AS MatchedKeywords,
    countries.users_count AS UsersCount
FROM
    wines
INNER JOIN keywords_wine ON wines.id = keywords_wine.wine_id
INNER JOIN keywords ON keywords_wine.keyword_id = keywords.id
INNER JOIN regions ON wines.region_id = regions.id
INNER JOIN countries ON regions.country_code = countries.code
WHERE
    keywords.name IN ('coffee', 'toast', 'green apple', 'cream', 'citrus')
    AND countries.users_count > 10
GROUP BY
    wines.id
HAVING
    MatchedKeywords = 5 





SELECT 
    wines.name AS WineName,
    SUM(vintages.ratings_count) AS RatingsCount,
    COUNT(DISTINCT keywords.name) AS MatchedKeywords,
    CONCAT(keywords.name) as keywords
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
ORDER BY  MatchedKeywords DESC, RatingsCount DESC





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
    RatingsCount = 5
ORDER BY  
    Count_MatchedKeywords DESC,
    RatingsCount DESC;




SELECT g.name, COUNT(*) as count
FROM grapes g
JOIN most_used_grapes_per_country mugpc ON g.id = mugpc.grape_id
GROUP BY g.name
ORDER BY count DESC
LIMIT 3;




SELECT w.name, AVG(v.ratings_average) as average_rating, COUNT(v.ratings_count) as rating_count
FROM wines w
JOIN vintages v ON w.id = v.wine_id
JOIN most_used_grapes_per_country mugpc ON w.region_id = mugpc.country_code
JOIN grapes g ON mugpc.grape_id = g.id
WHERE g.name = ?
GROUP BY w.name
ORDER BY average_rating DESC, rating_count DESC
LIMIT 5;

SELECT w.name, AVG(v.ratings_average) as average_rating, COUNT(v.ratings_count) as rating_count
FROM wines w
JOIN vintages v ON w.id = v.wine_id
JOIN most_used_grapes_per_country mugpc ON w.region_id = mugpc.country_code
JOIN grapes g ON mugpc.grape_id = g.id
WHERE g.name = 'Cabernet Sauvignon'
GROUP BY w.name
ORDER BY average_rating DESC, rating_count DESC
LIMIT 5;




SELECT 
    wines.id, 
    wines.name, 
    GROUP_CONCAT(DISTINCT grapes.name) as grape_names
FROM wines
JOIN vintages ON wines.id = vintages.wine_id
JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
JOIN toplists ON vintage_toplists_rankings.top_list_id = toplists.id
JOIN regions ON wines.region_id = regions.id
JOIN most_used_grapes_per_country ON regions.country_code = most_used_grapes_per_country.country_code
JOIN grapes ON most_used_grapes_per_country.grape_id = grapes.id
GROUP BY wines.id;





SELECT 
    grapes.name AS grape_name, 
    COUNT(grapes.name) AS count
FROM wines
JOIN vintages ON wines.id = vintages.wine_id
JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
JOIN toplists ON vintage_toplists_rankings.top_list_id = toplists.id
JOIN regions ON wines.region_id = regions.id
JOIN most_used_grapes_per_country ON regions.country_code = most_used_grapes_per_country.country_code
JOIN grapes ON most_used_grapes_per_country.grape_id = grapes.id
GROUP BY grapes.name
ORDER BY count DESC
;




SELECT 
    grapes.name AS grape_name, 
    vintages.name AS wine_name, 
    AVG(vintages.ratings_average) AS average_rating,
    COUNT(vintages.ratings_count) AS rating_count
FROM grapes
JOIN most_used_grapes_per_country ON grapes.id = most_used_grapes_per_country.grape_id
JOIN regions ON most_used_grapes_per_country.country_code = regions.country_code
JOIN wines ON regions.id = wines.region_id
JOIN vintages ON wines.id = vintages.wine_id
WHERE grapes.name IN ('Sangiovese')
GROUP BY wines.name, grapes.name
HAVING average_rating > 4.5
ORDER BY rating_count DESC, average_rating DESC
LIMIT 5;

SELECT 
    grapes.name AS grape_name, 
    vintages.name AS wine_name, 
    AVG(vintages.ratings_average) AS average_rating,
    COUNT(vintages.ratings_count) AS rating_count
FROM grapes
JOIN most_used_grapes_per_country ON grapes.id = most_used_grapes_per_country.grape_id
JOIN regions ON most_used_grapes_per_country.country_code = regions.country_code
JOIN wines ON regions.id = wines.region_id
JOIN vintages ON wines.id = vintages.wine_id
WHERE grapes.name IN ('Sangiovese')
GROUP BY wines.name, grapes.name
HAVING average_rating > 4.5
ORDER BY rating_count DESC, average_rating DESC
LIMIT 5;

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
HAVING AVG(vintages.ratings_average) > 4.5 AND grape_name = 'Cabernet Sauvignon'
ORDER BY rank ASC,total_ratings_count DESC, average_rating DESC
;

SELECT 
    vintages.year AS vintage_year, 
    AVG(vintages.ratings_average) AS avg_rating
FROM 
    vintages
GROUP BY 
    vintages.year
ORDER BY 
    vintage_year;

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
HAVING AVG(vintages.ratings_average) > 4.5 AND grape_name = 'Merlot'
ORDER BY rank ASC,total_ratings_count DESC, average_rating DESC
LIMIT 5;




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
HAVING AVG(vintages.ratings_average) > 4.5 AND grape_name = 'Chardonnay'
ORDER BY rank ASC,total_ratings_count DESC, average_rating DESC
LIMIT 5;

SELECT 
    countries.name AS country_name, 
    AVG(vintages.ratings_average) AS avg_country_rating
FROM countries
JOIN regions ON countries.code = regions.country_code
JOIN wines ON regions.id = wines.region_id
JOIN vintages ON wines.id = vintages.wine_id
GROUP BY countries.name
ORDER BY avg_country_rating DESC;

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
HAVING AVG(vintages.ratings_average) > 4.5 AND wine_name = 'Scarecrow Cabernet Sauvignon 2015'
ORDER BY rank ASC,total_ratings_count DESC, average_rating DESC
LIMIT 5;


SELECT 
    vintages.year AS vintage_year, 
    AVG(vintages.ratings_average) AS avg_vintage_rating
FROM vintages
GROUP BY vintages.year
ORDER BY vintage_year;

SELECT 
    grapes.name AS grape_name, 
    COUNT(grapes.name) AS count
FROM wines
JOIN vintages ON wines.id = vintages.wine_id
JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
JOIN toplists ON vintage_toplists_rankings.top_list_id = toplists.id
JOIN regions ON wines.region_id = regions.id
JOIN most_used_grapes_per_country ON regions.country_code = most_used_grapes_per_country.country_code
JOIN grapes ON most_used_grapes_per_country.grape_id = grapes.id
GROUP BY grapes.name
ORDER BY count DESC
;




        SELECT 
        wines.name AS wine_name,
        AVG(vintages.price_euros) AS average_price_euros,
        AVG(vintages.ratings_average) AS average_rating,
        SUM(vintages.ratings_count) AS total_ratings_count,
        AVG(vintage_toplists_rankings.rank) as average_rank,
        grapes.name AS grape_name
        FROM wines
        JOIN vintages ON wines.id = vintages.wine_id
        JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
        JOIN toplists ON vintage_toplists_rankings.top_list_id = toplists.id
        JOIN regions ON wines.region_id = regions.id
        JOIN most_used_grapes_per_country ON regions.country_code = most_used_grapes_per_country.country_code
        JOIN grapes ON most_used_grapes_per_country.grape_id = grapes.id
        GROUP BY wines.id
        ORDER BY total_ratings_count DESC, average_rating DESC, average_rank ASC
        LIMIT 10

SELECT 
    vintages.name AS wine_name,
    grapes.name AS grape_name,
    AVG(vintages.ratings_average) AS average_rating,
    SUM(vintages.ratings_count) AS total_ratings_count,
    AVG(vintages.price_euros) AS price_euros,  -- Adicionado o preço médio
    AVG(vintage_toplists_rankings.rank) as rank
FROM wines
JOIN vintages ON wines.id = vintages.wine_id
JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
JOIN toplists ON vintage_toplists_rankings.top_list_id = toplists.id
JOIN regions ON wines.region_id = regions.id
JOIN most_used_grapes_per_country ON regions.country_code = most_used_grapes_per_country.country_code
JOIN grapes ON most_used_grapes_per_country.grape_id = grapes.id
GROUP BY wines.name, grapes.name, regions.name, vintages.price_euros  -- Agrupado também pelo preço
HAVING AVG(vintages.ratings_average) > 4.5 AND grape_name = 'Sangiovese'
ORDER BY rank ASC, total_ratings_count DESC, average_rating DESC
LIMIT 5




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
LIMIT 5

SELECT 
    vintages.*,
    wines.*,
    regions.*,
    countries.*,
    grapes.*,
    toplists.*,
    vintage_toplists_rankings.*,
    most_used_grapes_per_country.*
FROM 
    vintages
JOIN 
    wines ON vintages.wine_id = wines.id
JOIN 
    regions ON wines.region_id = regions.id
JOIN 
    countries ON regions.country_code = countries.code
JOIN 
    most_used_grapes_per_country ON countries.code = most_used_grapes_per_country.country_code
JOIN 
    grapes ON most_used_grapes_per_country.grape_id = grapes.id
LEFT JOIN 
    vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
LEFT JOIN 
    toplists ON vintage_toplists_rankings.top_list_id = toplists.id;





SELECT 
    vintages.name AS wine_name,
    substr(vintages.name, 0, instr(vintages.name, 'Sauvignon')) AS grape_name_extracted,
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
GROUP BY wines.name, regions.name
HAVING AVG(vintages.ratings_average) > 4.5 AND wine_name = 'Scarecrow Cabernet Sauvignon 2015'
ORDER BY rank ASC, total_ratings_count DESC, average_rating DESC
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
    grape_name = 'Cabernet Sauvignon'
ORDER BY 
     v.ratings_count DESC, v.ratings_average DESC
LIMIT 5;




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
    g.name = 'Cabernet Sauvignon'
GROUP BY 
    v.name, g.name
ORDER BY 
    v.ratings_count DESC, 
    v.ratings_average DESC, 
    average_rank ASC





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
HAVING AVG(vintages.ratings_average) > 4.5 AND grape_name = 'Cabernet Sauvignon'
ORDER BY rank ASC,total_ratings_count DESC, average_rating DESC
LIMIT 5;

SELECT
    grape_id,
    COUNT(country_code) as count,    
    wines_count 
FROM 
    most_used_grapes_per_country
GROUP BY 
    grape_id
ORDER BY
    wines_count DESC,count DESC




SELECT
    g.name AS grape_name,
    COUNT(mug.country_code) as country_count,    
    mug.wines_count as total_wines_count
FROM 
    most_used_grapes_per_country mug
JOIN grapes g ON mug.grape_id = g.id
GROUP BY 
    g.name
ORDER BY
    country_count DESC,total_wines_count DESC
LIMIT 3
;

    SELECT DISTINCT wines.name, vintages.ratings_average, vintages.ratings_count
    FROM wines
    JOIN vintages ON wines.id = vintages.wine_id
    JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
    JOIN toplists ON vintage_toplists_rankings.top_list_id = toplists.id
    WHERE vintages.ratings_average > 4.5
    ORDER BY vintages.ratings_count DESC
    LIMIT 10;