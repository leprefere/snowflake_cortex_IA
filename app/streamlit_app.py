import streamlit as st
from snowflake.snowpark.context import get_active_session
import re


session = get_active_session()

st.set_page_config(page_title="Coffee Shop AI", layout="wide")
st.title(" Coffee Shop AI Analyst")

#  ANALYST

question = st.text_input(" Pose une question (Analytics)")

if question:

    prompt = f"""
You are a Snowflake SQL expert.

Generate ONLY a valid SQL query.

Database: COFFEE_SHOP_DB

Tables:
customers(customer_id, full_name, city, created_at)
products(product_id, name, category_id, price, is_available)
categories(category_id, category_name)
orders(order_id, customer_id, order_date)
order_items(order_item_id, order_id, product_id, quantity, unit_price)

Rules:
- Revenue = SUM(quantity * unit_price)
- Always use correct joins
- Return ONLY SQL

Question:
{question}
"""

    cortex_query = f"""
        SELECT SNOWFLAKE.CORTEX.COMPLETE(
            'mistral-large',
            $$ {prompt} $$
        ) AS response
    """

    try:
        result = session.sql(cortex_query).collect()
        generated_sql = result[0]['RESPONSE']

        generated_sql = re.sub(r"```sql|```", "", generated_sql).strip()

        st.subheader("SQL généré")
        st.code(generated_sql)

        if generated_sql.upper().startswith("SELECT"):
            df = session.sql(generated_sql).to_pandas()
            st.subheader(" Résultat")
            st.dataframe(df)
        else:
            st.error("SQL invalide")
            st.write(generated_sql)

    except Exception as e:
        st.error(e)


#  SEARCH

search_query = st.text_input(" Search products:")

if search_query:

    df = session.sql(f"""
        SELECT *
        FROM TABLE(
            coffee_shop_search(query => '{search_query}')
        )
    """).to_pandas()

    st.subheader(" Results")
    st.dataframe(df)

#  EVALUATION


rows = session.sql("SELECT * FROM evaluation_dataset").collect()

total = 0
correct = 0
errors = 0

for row in rows:

    question = row["QUESTION"]
    expected_sql = row["EXPECTED_SQL"]

    total += 1

    prompt = f"""
You are a senior Snowflake SQL expert.

Generate ONLY valid SQL that runs successfully.

 CRITICAL RULES:
- Use ONLY tables and columns provided below
- NEVER invent column names
- NEVER rename fields
- If a column does not exist, do NOT use it
- Return ONLY SQL (no explanation)

Database: COFFEE_SHOP_DB

Tables schema (STRICT):
customers(customer_id, full_name, city, created_at)
products(product_id, name, category_id, price, is_available)
categories(category_id, category_name)
orders(order_id, customer_id, order_date)
order_items(order_item_id, order_id, product_id, quantity, unit_price)

Business rules:
- Revenue = SUM(quantity * unit_price)
- Top selling = SUM(quantity * unit_price)
- Always use correct JOINs
- Always GROUP BY non-aggregated columns

Question:
{question}
"""




    cortex_query = f"""
        SELECT SNOWFLAKE.CORTEX.COMPLETE(
            'mistral-large',
            $$ {prompt} $$
        ) AS response
    """

    try:
        result = session.sql(cortex_query).collect()
        generated_sql = result[0]['RESPONSE']

        generated_sql = re.sub(r"```sql|```", "", generated_sql).strip()

        try:
            df_generated = session.sql(generated_sql).to_pandas()
            df_expected = session.sql(expected_sql).to_pandas()

            if df_generated.sort_values(df_generated.columns.tolist()).equals(
                df_expected.sort_values(df_expected.columns.tolist())
            ):
                score = " Correct result"
                correct += 1
            else:
                score = " Different result"
                errors += 1

        except Exception as e:
            score = " SQL Execution Error"
            errors += 1

    except Exception as e:
        score = " Cortex Error"
        errors += 1

    st.write("### Question")
    st.write(question)

    st.write("### Generated SQL")
    st.code(generated_sql)

    st.write("### Expected SQL")
    st.code(expected_sql)

    st.write("### Score")
    st.write(score)




accuracy = (correct / total) * 100 if total > 0 else 0

st.write("##  Global Evaluation")
st.write(f"Total tests: {total}")
st.write(f"Correct: {correct}")
st.write(f"Errors: {errors}")
st.write(f"Accuracy: {accuracy:.2f}%")

if accuracy > 80:
    st.success(" Model is performing well")
else:
    st.warning(" Model needs improvement")
