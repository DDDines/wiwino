import sqlite3 
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

# Establishing connection to the SQLite database
conn = sqlite3.connect('db/vivino.db')
print("Opened database successfully")


query = '''
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

cursor.execute(query)
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


