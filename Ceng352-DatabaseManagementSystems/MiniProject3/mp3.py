from customer import Customer

import psycopg2

from config import read_config
from messages import *

POSTGRESQL_CONFIG_FILE_NAME = "database.cfg"

"""
    Connects to PostgreSQL database and returns connection object.
"""


def connect_to_db():
    db_conn_params = read_config(filename=POSTGRESQL_CONFIG_FILE_NAME, section="postgresql")
    conn = psycopg2.connect(**db_conn_params)
    conn.autocommit = False
    return conn


"""
    Splits given command string by spaces and trims each token.
    Returns token list.
"""


def tokenize_command(command):
    tokens = command.split(" ")
    return [t.strip() for t in tokens]


"""
    Prints list of available commands of the software.
"""


def help():
    # prints the choices for commands and parameters
    print("\n*** Please enter one of the following commands ***")
    print("> help")
    print("> sign_up <email> <password> <first_name> <last_name> <plan_id>")
    print("> sign_in <email> <password>")
    print("> sign_out")
    print("> show_plans")
    print("> show_subscription")
    print("> subscribe <plan_id>")
    print("> watched_movies <movie_id_1> <movie_id_2> <movie_id_3> ... <movie_id_n>")
    print("> search_for_movies <keyword_1> <keyword_2> <keyword_3> ... <keyword_n>")
    print("> suggest_movies")
    print("> quit")


"""
    Saves customer with given details.
    - Return type is a tuple, 1st element is a boolean and 2nd element is the response message from messages.py.
    - If the operation is successful, commit changes and return tuple (True, CMD_EXECUTION_SUCCESS).
    - If any exception occurs; rollback, do nothing on the database and return tuple (False, CMD_EXECUTION_FAILED).
"""


def sign_up(conn, email, password, first_name, last_name, plan_id):
    # TODO: Implement this function
    cursor = conn.cursor()
    try:
        cursor.execute("select * from customer where customer.email = %s",(email,))
        row = cursor.fetchone()
        if row:
            conn.rollback()
            return False, CMD_EXECUTION_FAILED
        cursor.execute("select * from plan where plan.plan_id = %s", (plan_id,))
        row = cursor.fetchone()
        if not row:
            conn.rollback()
            return False, CMD_EXECUTION_FAILED
        cursor.execute("insert into Customer(email, password, first_name, last_name, session_count, plan_id) values (%s, %s, %s, %s, 0, %s)", (email, password, first_name, last_name, plan_id,))
        conn.commit()
        return True, CMD_EXECUTION_SUCCESS

    except:
        conn.rollback()
        return False, CMD_EXECUTION_FAILED

"""
    Retrieves customer information if email and password is correct and customer's session_count < max_parallel_sessions.
    - Return type is a tuple, 1st element is a customer object and 2nd element is the response message from messages.py.
    - If email or password is wrong, return tuple (None, USER_SIGNIN_FAILED).
    - If session_count < max_parallel_sessions, commit changes (increment session_count) and return tuple (customer, CMD_EXECUTION_SUCCESS).
    - If session_count >= max_parallel_sessions, return tuple (None, USER_ALL_SESSIONS_ARE_USED).
    - If any exception occurs; rollback, do nothing on the database and return tuple (None, USER_SIGNIN_FAILED).
"""


def sign_in(conn, email, password):
    # TODO: Implement this function
    cursor = conn.cursor()
    try:
        cursor.execute("select * from customer where customer.email = %s and customer.password = %s",(email, password, ))
        customer = cursor.fetchone()
        if not customer:
            conn.rollback()
            return None, USER_SIGNIN_FAILED
        cursor.execute("select plan.max_parallel_sessions from plan, customer where customer.email = %s and customer.plan_id = plan.plan_id",(email, ))
        max_session_count = cursor.fetchone()
        if customer[5] >= max_session_count[0]:
            conn.rollback()
            return None, USER_ALL_SESSIONS_ARE_USED
        cursor.execute("update customer set session_count = (session_count+1) where email = %s",(email,))
        conn.commit()
        result = customer[3] + " " + customer[4] + " (" + customer[1] + ")"
        return result, CMD_EXECUTION_SUCCESS
    except:
        conn.rollback()
        return None, USER_SIGNIN_FAILED

"""
    Signs out from given customer's account.
    - Return type is a tuple, 1st element is a boolean and 2nd element is the response message from messages.py.
    - Decrement session_count of the customer in the database.
    - If the operation is successful, commit changes and return tuple (True, CMD_EXECUTION_SUCCESS).
    - If any exception occurs; rollback, do nothing on the database and return tuple (False, CMD_EXECUTION_FAILED).
"""


def sign_out(conn, customer):
    # TODO: Implement this function
    cursor = conn.cursor()
    try:
        email = tokenize_command(customer)[2][1:-1]
        cursor.execute("update customer set session_count = (session_count-1) where email = %s",(email,))
        conn.commit()
        return True, CMD_EXECUTION_SUCCESS
    except:
        conn.rollback()
        return False, CMD_EXECUTION_FAILED

"""
    Quits from program.
    - Return type is a tuple, 1st element is a boolean and 2nd element is the response message from messages.py.
    - Remember to sign authenticated user out first.
    - If the operation is successful, commit changes and return tuple (True, CMD_EXECUTION_SUCCESS).
    - If any exception occurs; rollback, do nothing on the database and return tuple (False, CMD_EXECUTION_FAILED).
"""


def quit(conn, customer):
    # TODO: Implement this function
    cursor = conn.cursor()
    try:
        cursor.execute("select * from customer where customer.session_count > 0")
        for cust in cursor:
            customer_arr = cust[3] + " " + cust[4] + " (" + cust[1] + ")"
            session_count = cust[5]
            while session_count:
                sign_out(conn, customer_arr)
                session_count = session_count - 1
        conn.commit()
        return True, CMD_EXECUTION_SUCCESS
    except:
        conn.rollback()
        return False, CMD_EXECUTION_FAILED


"""
    Retrieves all available plans and prints them.
    - Return type is a tuple, 1st element is a boolean and 2nd element is the response message from messages.py.
    - If the operation is successful; print available plans and return tuple (True, CMD_EXECUTION_SUCCESS).
    - If any exception occurs; return tuple (False, CMD_EXECUTION_FAILED).

    Output should be like:
    #|Name|Resolution|Max Sessions|Monthly Fee
    1|Basic|720P|2|30
    2|Advanced|1080P|4|50
    3|Premium|4K|10|90
"""


def show_plans(conn):
    # TODO: Implement this function
    cursor = conn.cursor()
    try:
        cursor.execute("select * from plan")
        print("#|Name|Resolution|Max Sessions|Monthly Fee")
        for row in cursor:
            result = str(row[0])+"|"+str(row[1])+"|"+str(row[2])+"|"+str(row[3])+"|"+str(row[4])
            print(result)
        conn.commit()
        return True, CMD_EXECUTION_SUCCESS
    except:
        conn.rollback()
        return False, CMD_EXECUTION_FAILED

"""
    Retrieves authenticated user's plan and prints it. 
    - Return type is a tuple, 1st element is a boolean and 2nd element is the response message from messages.py.
    - If the operation is successful; print the authenticated customer's plan and return tuple (True, CMD_EXECUTION_SUCCESS).
    - If any exception occurs; return tuple (False, CMD_EXECUTION_FAILED).

    Output should be like:
    #|Name|Resolution|Max Sessions|Monthly Fee
    1|Basic|720P|2|30
"""


def show_subscription(conn, customer):
    # TODO: Implement this function
    cursor = conn.cursor()
    try:
        email = tokenize_command(customer)[2][1:-1]
        cursor.execute("select p.plan_id, p.plan_name, p.resolution, p.max_parallel_sessions, p.monthly_fee from customer c, plan p where c.email = %s and c.plan_id = p.plan_id",(email,))
        print("#|Name|Resolution|Max Sessions|Monthly Fee")
        row = cursor.fetchone()
        result = str(row[0])+"|"+str(row[1])+"|"+str(row[2])+"|"+str(row[3])+"|"+str(row[4])
        print(result)
        conn.commit()
        return True, CMD_EXECUTION_SUCCESS
    except:
        conn.rollback()
        return False, CMD_EXECUTION_FAILED

"""
    Insert customer-movie relationships to Watched table if not exists in Watched table.
    - Return type is a tuple, 1st element is a boolean and 2nd element is the response message from messages.py.
    - If a customer-movie relationship already exists, do nothing on the database and return (True, CMD_EXECUTION_SUCCESS).
    - If the operation is successful, commit changes and return tuple (True, CMD_EXECUTION_SUCCESS).
    - If any one of the movie ids is incorrect; rollback, do nothing on the database and return tuple (False, CMD_EXECUTION_FAILED).
    - If any exception occurs; rollback, do nothing on the database and return tuple (False, CMD_EXECUTION_FAILED).
"""


def watched_movies(conn, customer, movie_ids):
    # TODO: Implement this function
    cursor = conn.cursor()
    try:
        email = tokenize_command(customer)[2][1:-1]
        cursor.execute("select customer_id from customer c where c.email = %s",(email,))
        customer_id = cursor.fetchone()
        for movie_id in movie_ids:
            cursor.execute("select * from movies m where m.movie_id = %s",(movie_id,))
            row = cursor.fetchone()
            if not row:
                conn.rollback()
                return False, CMD_EXECUTION_FAILED
            cursor.execute("select * from watched w where w.customer_id = %s and w.movie_id = %s",(customer_id, movie_id,))
            row = cursor.fetchone()
            if not row:
                cursor.execute("insert into watched(customer_id, movie_id) values (%s, %s)",(customer_id, movie_id))
        conn.commit()
        return True, CMD_EXECUTION_SUCCESS
    except:
        conn.rollback()
        return False, CMD_EXECUTION_FAILED


"""
    Subscribe authenticated customer to new plan.
    - Return type is a tuple, 1st element is a customer object and 2nd element is the response message from messages.py.
    - If target plan does not exist on the database, return tuple (None, SUBSCRIBE_PLAN_NOT_FOUND).
    - If the new plan's max_parallel_sessions < current plan's max_parallel_sessions, return tuple (None, SUBSCRIBE_MAX_PARALLEL_SESSIONS_UNAVAILABLE).
    - If the operation is successful, commit changes and return tuple (customer, CMD_EXECUTION_SUCCESS).
    - If any exception occurs; rollback, do nothing on the database and return tuple (None, CMD_EXECUTION_FAILED).
"""


def subscribe(conn, customer, plan_id):
    # TODO: Implement this function
    cursor = conn.cursor()
    try:
        cursor.execute("select * from plan p where P.plan_id = %s",(plan_id,))
        new_plan = cursor.fetchone()
        if not new_plan:
            conn.rollback()
            return None, SUBSCRIBE_PLAN_NOT_FOUND
        email = tokenize_command(customer)[2][1:-1]
        cursor.execute("select p.plan_id, p.plan_name, p.resolution, p.max_parallel_sessions, p.monthly_fee from customer c, plan p where c.email = %s and c.plan_id = p.plan_id",(email,))
        old_plan = cursor.fetchone()
        if int(new_plan[3]) < int(old_plan[3]):
            conn.rollback()
            return None, SUBSCRIBE_MAX_PARALLEL_SESSIONS_UNAVAILABLE
        cursor.execute("update customer set plan_id = %s where email = %s",(plan_id, email,))
        conn.commit()
        return customer, CMD_EXECUTION_SUCCESS
    except:
        conn.rollback()
        return False, CMD_EXECUTION_FAILED

"""
    Searches for movies with given search_text.
    - Return type is a tuple, 1st element is a boolean and 2nd element is the response message from messages.py.
    - Print all movies whose titles contain given search_text IN CASE-INSENSITIVE MANNER.
    - If the operation is successful; print movies found and return tuple (True, CMD_EXECUTION_SUCCESS).
    - If any exception occurs; return tuple (False, CMD_EXECUTION_FAILED).

    Output should be like:
    Id|Title|Year|Rating|Votes|Watched
    "tt0147505"|"Sinbad: The Battle of the Dark Knights"|1998|2.2|149|0
    "tt0468569"|"The Dark Knight"|2008|9.0|2021237|1
    "tt1345836"|"The Dark Knight Rises"|2012|8.4|1362116|0
    "tt3153806"|"Masterpiece: Frank Millers The Dark Knight Returns"|2013|7.8|28|0
    "tt4430982"|"Batman: The Dark Knight Beyond"|0|0.0|0|0
    "tt4494606"|"The Dark Knight: Not So Serious"|2009|0.0|0|0
    "tt4498364"|"The Dark Knight: Knightfall - Part One"|2014|0.0|0|0
    "tt4504426"|"The Dark Knight: Knightfall - Part Two"|2014|0.0|0|0
    "tt4504908"|"The Dark Knight: Knightfall - Part Three"|2014|0.0|0|0
    "tt4653714"|"The Dark Knight Falls"|2015|5.4|8|0
    "tt6274696"|"The Dark Knight Returns: An Epic Fan Film"|2016|6.7|38|0
"""


def search_for_movies(conn, customer, search_text):
    # TODO: Implement this function
    cursor = conn.cursor()
    try:
        email = tokenize_command(customer)[2][1:-1]
        cursor.execute("select customer_id from customer c where c.email = %s",(email,))
        customer_id = cursor.fetchone()
        result_txt = "%"
        for txt in search_text:
            result_txt += txt + "%"
        cursor.execute("select * from movies m where m.title ilike %s order by m.movie_id",(result_txt,))
        print("Id|Title|Year|Rating|Votes|Watched")
        movies = cursor.fetchall()
        for movie in movies:
            cursor.execute("select * from watched w where w.customer_id = %s and w.movie_id = %s",(customer_id, movie[0],))
            is_watched = cursor.fetchone()
            if not is_watched:
                print(str(movie[0])+"|"+str(movie[1])+"|"+str(movie[2])+"|"+"{0:0.1f}".format(movie[3])+"|"+str(movie[4]) + "|0")
            else:
                print(str(movie[0])+"|"+str(movie[1])+"|"+str(movie[2])+"|"+"{0:0.1f}".format(movie[3])+"|"+str(movie[4]) + "|1")
        conn.commit()
        return True, CMD_EXECUTION_SUCCESS
    except:
        conn.rollback()
        return False, CMD_EXECUTION_FAILED

"""
    Suggests combination of these movies:
        1- Find customer's genres. For each genre, find movies with most number of votes among the movies that the customer didn't watch.

        2- Find top 10 movies with most number of votes and highest rating, such that these movies are released 
           after 2010 ( [2010, today) ) and the customer didn't watch these movies.
           (descending order for votes, descending order for rating)

        3- Find top 10 movies with votes higher than the average number of votes of movies that the customer watched.
           Disregard the movies that the customer didn't watch.
           (descending order for votes)

    - Return type is a tuple, 1st element is a boolean and 2nd element is the response message from messages.py.    
    - Output format and return format are same with search_for_movies.
    - Order these movies by their movie id, in ascending order at the end.
    - If the operation is successful; print movies suggested and return tuple (True, CMD_EXECUTION_SUCCESS).
    - If any exception occurs; return tuple (False, CMD_EXECUTION_FAILED).
"""


def suggest_movies(conn, customer):
    # TODO: Implement this function
    cursor = conn.cursor()
    try:
        email = tokenize_command(customer)[2][1:-1]
        cursor.execute("select customer_id from customer c where c.email = %s",(email,))
        customer_id = cursor.fetchone()
        cursor.execute("select distinct m.movie_id, m.title, m.movie_year, m.rating, m.votes from (select g.genre_name, max(m.votes) as v from (select * from movies m where m.movie_id not in (select w.movie_id from watched w where w.customer_id = %s)) as m, genres g where g.movie_id = m.movie_id group by g.genre_name) as n1, movies m, genres g2, (select g.genre_name from watched w, genres g where w.customer_id = %s and g.movie_id = w.movie_id) as n2 where m.votes = n1.v and g2.movie_id = m.movie_id and g2.genre_name = n1.genre_name and n2.genre_name = n1.genre_name", (customer_id, customer_id, ))
        step1_movies = cursor.fetchall()
        cursor.execute("select distinct m.movie_id, m.title, m.movie_year, m.rating, m.votes from (select * from movies m where m.movie_id not in (select w.movie_id from watched w where w.customer_id = %s)) as m where m.movie_year >= 2010 order by m.votes desc, m.rating desc limit 10", (customer_id, ))
        step2_movies = cursor.fetchall()
        cursor.execute("select distinct m.movie_id, m.title, m.movie_year, m.rating, m.votes from (select * from movies m where m.movie_id not in (select w.movie_id from watched w where w.customer_id = %s)) as m, (select avg(m.votes) as av from movies m, watched w where w.customer_id = %s and w.movie_id = m.movie_id) as n where m.votes > n.av order by m.votes desc limit 10",(customer_id, customer_id, ))
        step3_movies = cursor.fetchall()

        all_movies = []
        print("Id|Title|Year|Rating|Votes")
        for movie in step1_movies:
            all_movies.append(movie)
        for movie in step2_movies:
            if movie not in all_movies:
                all_movies.append(movie)
        for movie in step3_movies:
            if movie not in all_movies:
                all_movies.append(movie)
                
        all_movies = sorted(all_movies)

        for movie in all_movies:
            print(str(movie[0])+"|"+str(movie[1])+"|"+str(movie[2])+"|"+"{0:0.1f}".format(movie[3])+"|"+str(movie[4]))
        conn.commit()
        return True, CMD_EXECUTION_SUCCESS
    except:
        conn.rollback()
        return False, CMD_EXECUTION_FAILED
