import streamlit as st
import sqlite3
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from math import pi

# Page configuration
st.set_page_config(layout="wide")

# Function to get the image in base64 for background
def add_bg_from_url(url):
    st.markdown(f"""
         <style>
         .stApp {{
             background-image: url("{url}");
             background-size: cover;
         }}
         </style>
         """, unsafe_allow_html=True)

# image URL
image_url = 'https://revistaadega.uol.com.br/media/evolucao_do_vinho_tinto.jpeg'
add_bg_from_url(image_url)

st.markdown("""
<style>
.title {
    font-size:30px !important;
    color: #000000; 
    font-weight: bold; 
}
</style>
""", unsafe_allow_html=True)

st.markdown("""
<style>
.text-box {
    background-color: rgba(255, 255, 255, 0.8); 
    border-radius: 10px;  
    padding: 10px;  
    margin: 10px 0;  
    font-size:16px !important;
    color: #000000; 
}
</style>
""", unsafe_allow_html=True)


# Function to execute SQL query
def run_query(query):
    conn = sqlite3.connect('db/vivino.db')
    df = pd.read_sql_query(query, conn)
    conn.close()
    return df

#QUESTION 1
def increse_sales_wines(rating_min, minimum_rating):
    query = f'''SELECT 
                DISTINCT vintages.name, 
                vintages.ratings_average, 
                vintages.ratings_count, 
                vintages.price_euros AS price
                FROM vintages
                WHERE vintages.ratings_average >= {rating_min} AND vintages.ratings_count >= {minimum_rating}
                ORDER BY vintages.ratings_average DESC;
            '''
    return run_query(query)


def increse_sales_wines_old(rating_min, minimum_rating):
    query = f'''
    SELECT DISTINCT wines.name, vintages.ratings_average, vintages.ratings_count
    FROM wines
    JOIN vintages ON wines.id = vintages.wine_id
    JOIN vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id
    JOIN toplists ON vintage_toplists_rankings.top_list_id = toplists.id
        WHERE vintages.ratings_average > {rating_min} AND vintages.ratings_count > {minimum_rating}
    ORDER BY vintages.ratings_count DESC;
    '''
    return run_query(query)

#QUESTION 2
def countrys_sell_wines(average_rating_min= 0, minimum_rating = 0):
    query = f'''
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
        GROUP BY countries.name
        HAVING total_ratings_count >= {minimum_rating} AND average_rating >= {average_rating_min}
        ORDER BY number_of_wines DESC;
    '''
    return run_query(query)

#QUESTION 3
def wineries(rating_min=4.2, rating_count=5):
    query = f'''
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
    GROUP BY
        winery_name
    HAVING
        rating_count >= {rating_count} and average_rating >= {rating_min}
    ORDER BY
        average_rank ASC, average_rating DESC, rating_count DESC;
    '''
    return run_query(query)

#QUESTION 4
def keywords_wines(keywords=('coffee', 'toast', 'green apple', 'cream', 'citrus'),maching_keywords=5, minimum_rating=10):
    query = f'''
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
            keywords.name IN {keywords}
        GROUP BY 
            wines.name
        HAVING
            Count_MatchedKeywords = {maching_keywords} AND
            RatingsCount >= {minimum_rating}
        ORDER BY  
            Count_MatchedKeywords DESC,
            RatingsCount DESC;
        '''
    return run_query(query)

#QUESTION 5
def get_best_wines(rating_min, grape, price_range, rank_min, minimum_rating):
    query = f'''
        SELECT 
        vintages.name AS wine_name,
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
        WHERE vintages.ratings_count >= {minimum_rating} AND vintages.price_euros BETWEEN {price_range[0]} AND {price_range[1]}
        AND grapes.name = '{grape}'
        GROUP BY wines.id
        HAVING AVG(vintages.ratings_average) >= {rating_min} AND AVG(vintage_toplists_rankings.rank) <= {rank_min}
        ORDER BY average_rank ASC, total_ratings_count DESC, average_rating DESC
    '''
    return run_query(query)

#QUESTION 6

def best_grapes(limit=3):
    query = f'''
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
    LIMIT {limit};
    '''
    return run_query(query)

def best_wines_grapes(name='Sangiovese',rating_min=4.5,minimum_rating=0):
    query = f'''
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
        HAVING AVG(vintages.ratings_average) >= {rating_min} AND grape_name = '{name}' AND total_ratings_count >= {minimum_rating}
        ORDER BY rank ASC,total_ratings_count DESC, average_rating DESC ;
        '''
    return run_query(query)




page = st.sidebar.radio('Menu', ['Sales Strategy', 'Market Prioritization', 'Winery Awards', 'Keyword Identification', 'Grape Selection', 'Country Leaderboard', 'VIP Recommendations'])

if page == 'Sales Strategy':

    st.markdown('<div class="title">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp Wines to Increase Sales </div>', unsafe_allow_html=True)
    st.text('')
    st.markdown("""
    <div class="text-box">
    This screen can showcase a curated list of 10 wines chosen for their high ratings and popularity.<br>ss
    By leveraging data on customer preferences and sales trends, it recommends wines that are likely to appeal to a broad audience, thus increasing sales potential.
    </div>
    """, unsafe_allow_html=True)
    st.text('')


    col1, col2 = st.columns([3, 2])
    rating_min = st.sidebar.slider('Minimum Rating', min_value=4.0, max_value=5.0, value=4.5, step=0.1)
    minimum_rating = st.sidebar.slider('Minimum Ratings Count', 0, 5000, 0)
    increse_sales = increse_sales_wines(rating_min,minimum_rating)
    with col1:
        st.dataframe(increse_sales)
    with col2:
        plt.figure(figsize=(12, 8))
        scatter = plt.scatter(increse_sales['ratings_count'], increse_sales['ratings_average'], s=increse_sales['ratings_count']/50, c=increse_sales['price'], cmap='RdYlBu', alpha=0.7, edgecolors='black', linewidth=0.5)
        plt.colorbar(scatter, label='Price (€)')
        plt.title('Wines: Rating Average vs Rating Count (Color by Price)', fontsize=15)
        plt.xlabel('Rating Count', fontsize=12)
        plt.ylabel('Rating Average', fontsize=12)
        plt.grid(True, linestyle='--', linewidth=0.5, alpha=0.5)
        plt.tight_layout()
        
        # Mostrar o gráfico no Streamlit
        st.pyplot(plt)

if page == 'Market Prioritization':

    st.markdown('<div class="title">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp Where to Invest Our Limited Marketing Budget?</div>', unsafe_allow_html=True)
    st.text('')
    st.markdown("""
    <div class="text-box">
    Here, users can visualize which countries offer the most promising markets for wine sales, based on the analysis of wine ratings, market size, and average prices.<br>
    It helps in making an informed decision on where to focus marketing efforts for the best return on investment.
    </div>
    """, unsafe_allow_html=True)
    st.text('')



    col1, col2 = st.columns([3, 2])
    rating_min = st.sidebar.slider('Minimum Avarage Rating', min_value=0.1, max_value=5.0, value=0.1, step=0.1)
    minimum_rating = st.sidebar.slider('Minimum Avarage Ratings Count', 0, 5000, 0)
    countries_wines = countrys_sell_wines(rating_min,minimum_rating)

    with col1:
        st.dataframe(countries_wines)
    with col2:
        if not countries_wines.empty:
            # Gerando o gráfico de barras
            plt.figure(figsize=(12,8))
            plt.bar(countries_wines['country_name'], countries_wines['number_of_wines'], color='skyblue')
            plt.xlabel('Countries', fontsize=14)
            plt.ylabel('Number of Wines', fontsize=14)
            plt.title('number of Wines for Country', fontsize=16)
            plt.xticks(rotation=45)
            plt.tight_layout()
            
            # Mostrando o gráfico no Streamlit
            st.pyplot(plt)
        else:
            st.error("No wines found with the specified criteria.")

if page == 'Winery Awards':
    st.markdown('<div class="title">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp Awards to the Best Wineries</div>', unsafe_allow_html=True)
    st.text('')
    st.markdown("""
    <div class="text-box">
        This section highlights top wineries deserving of awards, based on their contributions to wine quality and innovation. 
        It assesses factors like average wine ratings, popularity, and awards received, presenting a rationale for each selected winery.
    </div>
    """, unsafe_allow_html=True)
    st.text('')


    col1, col2 = st.columns([3, 2])
    rating_min = st.sidebar.slider('Minimum Avarage Rating', min_value=4.0, max_value=5.0, value=4.8, step=0.1)
    minimum_rating = st.sidebar.slider('How Many Wines Have Some Award ?', 1,6,1)
    with col1:
        st.dataframe(wineries(rating_min,minimum_rating))

if page == 'Keyword Identification':

    st.markdown('<div class="title">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp Find the Perfect Wines for Customers with Specific Tastes</div>', unsafe_allow_html=True)
    st.text('')
    st.markdown("""
    <div class="text-box">
            Tailored to discover wines that align with specific customer taste profiles identified by keywords like coffee, toast, green apple, cream, and citrus. 
            It validates selections with user ratings and reviews, ensuring accuracy in matching the specified tastes.
    </div>
    """, unsafe_allow_html=True)
    st.text('')


    col1, col2 = st.columns([3, 2])
    with col1:
        minimum_rating = st.sidebar.slider('Minimum Ratings Count', 1, 5000, 10)
        maches_keyword = st.sidebar.slider('Number of maches keywords', 1, 10, 5)        
        selected_options = st.sidebar.multiselect('Escolha os aromas:',run_query('SELECT name FROM keywords'),('coffee', 'toast', 'green apple', 'cream', 'citrus') )
        selected_options = tuple(selected_options)
        
        if selected_options:
            option = st.dataframe(keywords_wines(selected_options,maches_keyword,minimum_rating))
            if not option:
                st.error("No wines found with the specified criteria.")
        else:
            st.dataframe(keywords_wines())


if page == 'Grape Selection':
    st.markdown('<div class="title">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp Top Grapes and Their Best-Rated Bottles</div>', unsafe_allow_html=True)
    st.sidebar.text("")
    st.sidebar.text('Grapes Options:')
    qnt_grapes = st.sidebar.slider('Number of Grapes', 1, 10, 3)
    st.sidebar.text("")
    st.sidebar.text("")
    st.sidebar.text('Wines Options:')
    rating_min = st.sidebar.slider('Minimum Rating', min_value=4.0, max_value=5.0, value=4.5, step=0.1)
    minimum_rating = st.sidebar.slider('Minimum Ratings Count', 0, 5000, 0)

    col1, col2 = st.columns([3, 3])
    with col1:
        st.markdown("""
        <div class="text-box">
                    Focuses on identifying the most common grapes worldwide and selecting the top-rated wines made from these grapes.<br>
                    It facilitates global wine selection, ensuring the recommended wines are accessible to a wide audience.
        </div>
        """, unsafe_allow_html=True)
        st.text("")
        st.text("")
        st.text("")
        st.text("")
        st.text("")
        st.text("")
        st.text("")
        st.text("")
        st.text("")
        st.text("")
        st.text("")
        st.text("")
        st.text("")
        st.text("")
        st.text("")

        st.dataframe(best_grapes(qnt_grapes))
    with col2:
        g = best_grapes()
        grapes = g['grape_name'].tolist()

        if g.empty:
            st.error("No grapes found with the specified criteria.")
        else:  
            for grape in grapes:
                st.dataframe(best_wines_grapes(grape,rating_min,minimum_rating))


if page == 'Country Leaderboard':
    st.markdown('<div class="title">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp Country Leaderboard</div>', unsafe_allow_html=True)
    st.text('')
    st.markdown("""
        <div class="text-box">
                Offers a visual representation of countries ranked by the average rating of their wines, providing insights into quality by country and vintage.<br>
                This helps in understanding global wine trends and identifying standout wine-producing countries.
        </div>
        """, unsafe_allow_html=True)

    col1, col2 = st.columns([3,3])
    with col1:
        st.text('')
        st.text('')
        st.text('')
        st.text('')
        country_avg_rating_query = f'''
        SELECT 
        countries.name AS country_name, 
        AVG(vintages.ratings_average) AS avg_country_rating
        FROM countries
        JOIN regions ON countries.code = regions.country_code
        JOIN wines ON regions.id = wines.region_id
        JOIN vintages ON wines.id = vintages.wine_id
        GROUP BY countries.name
        ORDER BY avg_country_rating DESC;
        '''
        countries = st.dataframe(run_query(country_avg_rating_query))
    
        st.text('')
        st.text('')
        st.text('')
        st.text('')
        st.text('')
        st.text('')
        st.text('')
        st.text('')
        st.text('')
        st.text('')
        st.text('')
        st.text('')
        
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
        vintages = st.dataframe(run_query(vintage_avg_rating_query))

    with col2:     
        # Preparação dos dados para o plot
        country_ratings_df = run_query(country_avg_rating_query)
        vintage_ratings_df = run_query(vintage_avg_rating_query)
        vintage_ratings_df['vintage_year'] = vintage_ratings_df['vintage_year'].replace('N.V.', 0).astype(int)

        # Gráfico da classificação média por país
        plt.figure(figsize=(10, 8))
        sns.barplot(x='avg_country_rating', y='country_name', data=country_ratings_df, palette='viridis')
        plt.xlabel('Average Rating')
        plt.title('Average Wine Rating by Country')
        st.pyplot(plt)  # Exibir o gráfico

        plt.figure(figsize=(10, 8))
        sns.lineplot(data=vintage_ratings_df[vintage_ratings_df['vintage_year'] >= 1800], x='vintage_year', y='avg_rating', marker='o', color='coral')
        plt.xlabel('Year')
        plt.ylabel('Average Rating')
        plt.title('Average Vintage Rating Over Years')
        plt.grid(True)
        st.pyplot(plt)  # Exibir o gráfico

        
if page == 'VIP Recommendations':

    col, col1, col2  = st.columns([1,4,1])

    rating_min = st.sidebar.slider('Minimum Rating', min_value=4.0, max_value=5.0, value=4.5, step=0.1)
    grape = st.sidebar.selectbox('Grape', options=['Cabernet Sauvignon', 'Merlot', 'Pinot Noir','Sangiovese', 'Malbec', 'Tempranillo', 'Chardonnay'])
    price_range = st.sidebar.slider('Price Range (€)', 20, 2500, (20, 2500))
    rank_min = st.sidebar.slider('Minimum Ranking', 1, 15, 15)
    minimum_rating = st.sidebar.slider('Minimum Rating Count', 1, 5000, 1)

    # Fetching data with applied filters
    best_wines_data = get_best_wines(rating_min, grape, price_range, rank_min, minimum_rating)

    num_samples = min(len(best_wines_data), 5)  # Retira 5 ou o número disponível de amostras
    selected_wines = best_wines_data.sample(n=num_samples)

    # Verificando se os dados foram encontrados
    if not best_wines_data.empty:
        # Displaying filtered data
        with col1:
            st.markdown('<div class="title">The Top Grapes Choices for Our VIP Customers</div>', unsafe_allow_html=True)
            st.markdown("""
            <div class="text-box">
                Satisfy the discerning palates of your VIP customers with our premium recommendations of Cabernet Sauvignon. <br>
                Discover the wines that stand out and impress even the most discerning wine connoisseurs.
            </div>
            """, unsafe_allow_html=True)
            st.dataframe(best_wines_data)

            if len(best_wines_data) > 5:
                selected_wines = best_wines_data.sample(n=5)

            # Normalizar os dados
            categories = ['average_price_euros', 'average_rating', 'total_ratings_count']  # Adicione mais categorias conforme necessário
            normalized_wines = (selected_wines[categories] - selected_wines[categories].min()) / (selected_wines[categories].max() - selected_wines[categories].min())

            # Número de variáveis
            N = len(categories)
            angles = [n / float(N) * 2 * pi for n in range(N)]
            angles += angles[:1]

            fig, ax = plt.subplots(figsize=(8, 8), subplot_kw=dict(polar=True))

            # Repetir o primeiro valor no final para fechar o círculo do radar chart
            for index, row in normalized_wines.iterrows():
                data = row.tolist()
                data += data[:1]
                ax.plot(angles, data, linewidth=1, linestyle='solid', label=selected_wines.loc[index, 'wine_name'])
                ax.fill(angles, data, alpha=0.25)

            # Adiciona os nomes das categorias
            ax.set_xticks(angles[:-1])
            ax.set_xticklabels(categories)

            plt.legend(loc='upper right', bbox_to_anchor=(0.1, 0.1))
            st.pyplot(fig)  # Exibir o gráfico no Streamlit
    else:
        st.error("No wines found with the specified criteria.")