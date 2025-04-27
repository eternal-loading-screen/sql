/* ASSIGNMENT 2 */
-- https://github.com/eternal-loading-screen/sql/blob/assignment-one/02_activities/assignments/Assignment2.md

-- https://github.com/eternal-loading-screen/sql/blob/assignment-one/01_materials/slides/slides_04.pdf

-- https://github.com/UofT-DSI/onboarding/blob/main/onboarding_documents/submissions.md

/* SECTION 2 */

-- COALESCE
/* 1. Our favourite manager wants a detailed long list of products, but is afraid of tables! 
We tell them, no problem! We can produce a list with all of the appropriate details. 

Using the following syntax you create our super cool and not at all needy manager a list:

SELECT 
product_name || ', ' || product_size|| ' (' || product_qty_type || ')'
FROM product

But wait! The product table has some bad data (a few NULL values). 
Find the NULLs and then using COALESCE, replace the NULL with a 
blank for the first problem, and 'unit' for the second problem. 

HINT: keep the syntax the same, but edited the correct components with the string. 
The `||` values concatenate the columns into strings. 
Edit the appropriate columns -- you're making two edits -- and the NULL rows will be fixed. 
All the other rows will remain the same.) */

-- But does not use COALESCE
SELECT 
product_name || ', ' || product_size|| ' (' || product_qty_type || ')' as details
FROM product
WHERE details is not null

-- Using COALESCE
SELECT 
 COALESCE( (product_name || ', ' || product_size|| ' (' || product_qty_type || ')' ), 'Missing data') as details
FROM product
-- Optional filter
-- WHERE details <> 'Missing data'


--Windowed Functions
/* 1. Write a query that selects from the customer_purchases table and numbers each customer’s  
visits to the farmer’s market (labeling each market date with a different number). 
Each customer’s first visit is labeled 1, second visit is labeled 2, etc. 

You can either display all rows in the customer_purchases table, with the counter changing on
each new market date for each customer, or select only the unique market dates per customer 
(without purchase details) and number those visits. 
HINT: One of these approaches uses ROW_NUMBER() and one uses DENSE_RANK(). */

SELECT *
,ROW_NUMBER() OVER( PARTITION BY  market_date, customer_id 
ORDER BY market_date , transaction_time ASC ) as counter
FROM 
customer_purchases




/* 2. Reverse the numbering of the query from a part so each customer’s most recent visit is labeled 1, 
then write another query that uses this one as a subquery (or temp table) and filters the results to 
only the customer’s most recent visit. */

SELECT *
FROM 
(
    -- Subquery that sorts the data and applys a counter
    SELECT *
    ,ROW_NUMBER() OVER( PARTITION BY  customer_id, market_date
    ORDER BY market_date , transaction_time DESC ) as counter
    FROM 
    customer_purchases
)
WHERE 
counter = 1

/* 3. Using a COUNT() window function, include a value along with each row of the 
customer_purchases table that indicates how many different times that customer has purchased that product_id. */

SELECT *
,count(customer_id ) OVER (PARTITION BY customer_id , product_id) as Count_Window
FROM 
customer_purchases

-- SELECT *
-- ,count(customer_id , product_id) OVER (PARTITION BY customer_id , product_id) as Count_Window
-- FROM 
-- customer_purchases


-- String manipulations
/* 1. Some product names in the product table have descriptions like "Jar" or "Organic". 
These are separated from the product name with a hyphen. 
Create a column using SUBSTR (and a couple of other commands) that captures these, but is otherwise NULL. 
Remove any trailing or leading whitespaces. Don't just use a case statement for each product! 

| product_name               | description |
|----------------------------|-------------|
| Habanero Peppers - Organic | Organic     |

Hint: you might need to use INSTR(product_name,'-') to find the hyphens. INSTR will help split the column. */

SELECT *
-- find the position of hyphen
,INSTR(product_name,'-') as hyphen_position
,INSTR(UPPER(product_name),'ORGANIC') as organic_position
,INSTR(UPPER(product_name),'JAR') as jar_position
-- get string
-- ,SUBSTR ( product_name , 1, 
--     INSTR(product_name,'-') ) as product_name_to_hyphen
-- ,SUBSTR ( product_name , -1, 
--     INSTR(product_name,'-') ) as product_name_to_hyphen2
-- ,SUBSTR ( product_name , -1, 
--     INSTR(product_name,'-')+10 ) as product_name_to_hyphen3
-- ,SUBSTR ( product_name , -1, 
--     INSTR(product_name,'-')+10 ) as product_name_to_hyphen4       	
-- ,SUBSTR ( product_name , 1, 
--     INSTR(product_name,'-')+10 ) as product_name_to_hyphen5
-- ,SUBSTR ( product_name , 
--     INSTR(product_name,'-'),10 ) as product_name_to_hyphen6
-- ,SUBSTR ( product_name , 
--     INSTR(product_name,'-')+2,10 ) as product_name_to_hyphen7
,CASE WHEN 	INSTR(product_name,'-') >1 then 
	SUBSTR ( product_name , 
		INSTR(product_name,'-')+2,10 )
	else '' end as description	
FROM product;


/* 2. Filter the query to show any product_size value that contain a number with REGEXP. */

SELECT *
FROM product
WHERE product_size REGEXP '[0-9]';

-- UNION
/* 1. Using a UNION, write a query that displays the market dates with the highest and lowest total sales.

HINT: There are a possibly a few ways to do this query, but if you're struggling, try the following: 
1) Create a CTE/Temp Table to find sales values grouped dates; 
2) Create another CTE/Temp table with a rank windowed function on the previous query to create 
"best day" and "worst day"; 
3) Query the second temp table twice, once for the best day, once for the worst day, 
with a UNION binding them. */


-- Create a temp table
-- Drop table if the code has already been run
-- Drop tables if they exist
DROP TABLE IF EXISTS temp.daily_sales;
DROP TABLE IF EXISTS temp.max_sales;
DROP TABLE IF EXISTS temp.min_sales;

-- Create the temp table
CREATE TEMP TABLE temp.daily_sales AS 
    SELECT
    market_date
    ,SUM(quantity * cost_to_customer_per_qty) AS Sales
    ,RANK() OVER (ORDER BY SUM(quantity * cost_to_customer_per_qty) ASC) AS sales_min_rank
    ,RANK() OVER (ORDER BY SUM(quantity * cost_to_customer_per_qty) DESC) AS sales_max_rank
    FROM 
        customer_purchases
    GROUP BY 
    market_date
;

-- Min Sales
CREATE TEMP TABLE temp.min_sales AS 
    SELECT 
    *, 
    RANK() OVER (ORDER BY sales ASC) AS sales_min_rank
    FROM 
    temp.daily_sales
    WHERE sales_min_rank = 1
;


-- Max Sales
CREATE TEMP TABLE temp.max_sales AS 
    SELECT 
    *, 
    RANK() OVER (ORDER BY sales DESC) AS sales_max_rank
    FROM 
    temp.daily_sales
    WHERE 
    sales_max_rank = 1
;

-- Combine tables

SELECT *
FROM temp.min_sales

UNION ALL 

SELECT *
FROM temp.max_sales


-- More Efficient method but has no UNION

DROP TABLE IF EXISTS temp.daily_sales;
-- Can remove these 2 drop tables - was used in the UNION version of code
DROP TABLE IF EXISTS temp.max_sales;
DROP TABLE IF EXISTS temp.min_sales;

-- Create the temp table
CREATE TEMP TABLE temp.daily_sales AS 
    SELECT
    market_date
    ,SUM(quantity * cost_to_customer_per_qty) AS Sales
    ,RANK() OVER (ORDER BY SUM(quantity * cost_to_customer_per_qty) ASC) AS sales_min_rank
    ,RANK() OVER (ORDER BY SUM(quantity * cost_to_customer_per_qty) DESC) AS sales_max_rank
    FROM 
        customer_purchases
    GROUP BY 
    market_date
;

SELECT *
from temp.daily_sales
WHERE sales_min_rank = 1
or sales_max_rank = 1


-------------------------------------------------------------------------------
---------------------
---------------------
/* SECTION 3 */

-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */

-- Apparently looking for 5 * rows
-- Unique # of Vendors - 8 
SELECT 
DISTINCT 
 product_id
 ,vendor_id
 ,original_price
 FROM 
vendor_inventory;

-- Unique # of customers - 26
SELECT 
DISTINCT 
 customer_id
 FROM 
customer;

-- Sum up revenue, and rendor rows = 8 * 26 = 208

SELECT 
vendor_id
,product_id
,sum( original_price * quantity ) as revenue
 FROM 
vendor_inventory
GROUP BY 
vendor_id
,product_id


-- Answer:
-- All combinations of products and customers

SELECT 
p.product_name
,v.vendor_id
,v.vendor_name
,original_price
,revenue

FROM (

    SELECT 
    DISTINCT
    product_id
    ,vendor_id
    ,original_price
    -- Assuming quantity is 5
    ,original_price * 5 as revenue
    ,customer_id
    FROM 
    vendor_inventory
    CROSS JOIN 
    customer
) as r
-- Using LEFT JOIN because if for whatever reason the record does not exist on 
-- the product or vendor table, we do not "filter" the data out
-- basically not hide the bad data
LEFT JOIN product p
ON p.product_id = r.product_id

LEFT JOIN vendor v
ON v.vendor_ID = r.vendor_id ;


-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */

--assuming you want a new table
CREATE TABLE product_units as

SELECT 
    *
    ,DATETIME('now') as snapshot_timestamp
FROM 
    product
WHERE 
    product_qty_type = 'unit'
;

/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */

INSERT INTO 
product_units (
product_id
,product_name
,product_size
,product_category_id
,product_qty_type
,snapshot_timestamp
)

VALUES (7, 'Apple Pie', '"10"', 3, 'unit', '2020-02-20')



-- --- OLD Code > misunderstood question
-- INSERT INTO 
-- product_units (
-- product_id
-- ,product_name
-- ,product_size
-- ,product_category_id
-- ,product_qty_type
-- , snapshot_timestamp
-- )
--     SELECT 
--     product_id
--     ,product_name
--     ,product_size
--     ,product_category_id
--     ,product_qty_type
--     -- Gets the current date time / when the code was run
--     -- ,CURRENT_TIMESTAMP as  snapshot_timestamp
--     ,DATETIME('now') as  snapshot_timestamp
--     FROM product 
-- WHERE 
-- product_qty_type = 'unit'
-- ;



-- DELETE
/* 1. Delete the older record for the whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/


-- Specifying the table
DELETE FROM product_units

-- deleting the record I created because technically it is the older record by date
WHERE 
-- makes sure it has the right ID
product_id = 7
AND 
-- Based on the date I artificially created
-- But if we had to remove the other record, we would filter by the snapshot_timestamp = whenever the code was run
snapshot_timestamp = '2020-02-20' ;




-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */

-- During Saturday's office hours, what was important was that we attempt this question and show our work: ¯\_(ツ)_/¯

-- Part A)
ALTER TABLE product_units
ADD current_quantity INT;

-- Part B)
-- Find the quantity

-- Hint: First, determine how to get the "last" quantity per product. 
-- Finds the last quantity per product
SELECT *
FROM 
(
    -- Subquery that sorts the data and applys a counter
    -- then filters the data
    -- during office hours: looking for the latest transaction
    SELECT *
    ,ROW_NUMBER() OVER( PARTITION BY  vendor_id, product_id
    ORDER BY market_date  DESC ) as counter
    FROM 
    vendor_inventory
)
WHERE 
counter = 1

-- Part C)
-- Hint: Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
-- I guess we have to coalesce in case people don't have sales?

-- Assuming that since the field was newly created, and presumably null we want to populate it with 0
SELECT 
COALESCE( quantity, 0 ) as current_quantity
FROM 
(
    -- Subquery that sorts the data and applys a counter
    -- then filters the data
    -- during office hours: looking for the latest transaction
    SELECT *
    ,ROW_NUMBER() OVER( PARTITION BY  vendor_id, product_id
    ORDER BY market_date  DESC ) as counter
    FROM 
    vendor_inventory
) ref_table
WHERE 
counter = 1


-- Part D)
-- Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
-- Assuming you are trying to take the data from the vendor inventory table and "append" it to the product_unit table

UPDATE product_units
SET current_quantity
= 
-- assuming we want to take the data from product_inventory to update product_units
    (SELECT 
    -- We need to limit the output to 1 field
    COALESCE( quantity, 0 ) as current_quantity
    FROM 
    (
        -- Subquery that sorts the data and applys a counter
        -- then filters the data
        -- during office hours: looking for the latest transaction
        SELECT *
        ,ROW_NUMBER() OVER( PARTITION BY  vendor_id, product_id
        ORDER BY market_date  DESC ) as counter
        FROM 
        vendor_inventory
    ) ref_table
    WHERE 
    counter = 1)

WHERE current_quantity is null 


--- All together in 1 section

ALTER TABLE product_units
ADD current_quantity INT;

UPDATE product_units
SET current_quantity
= 
-- assuming we want to take the data from product_inventory to update product_units
    (SELECT 
    -- We need to limit the output to 1 field
    COALESCE( quantity, 0 ) as current_quantity
    FROM 
    (
        -- Subquery that sorts the data and applys a counter
        -- then filters the data
        -- during office hours: looking for the latest transaction
        SELECT *
        ,ROW_NUMBER() OVER( PARTITION BY  vendor_id, product_id
        ORDER BY market_date  DESC ) as counter
        FROM 
        vendor_inventory
    ) ref_table
    WHERE 
    counter = 1)

WHERE current_quantity is null 



--- OLD Code
-- Initially assumed you wanted to set the current_quantity field to equal another random value

-- UPDATE product_units
-- SET current_quantity
-- = 10
-- WHERE current_quantity = 0 




---------------------------------------
--- OLD CODE
-- Need to look for a number in product size, but ignore inches or "

    -- SELECT 
    -- product_id
    -- ,product_name
    -- ,product_size
    -- ,product_category_id
    -- ,product_qty_type
    -- ,INSTR( product_size ,'"') as double_quote_finder
    -- ,product_size  REGEXP '[0-9]'  as number_finder
    -- ,product_size  REGEXP '[^0-9]' AS non_number_finder
    -- FROM product 



-- SELECT 
-- product_id
-- ,quantity
-- ,max(market_date)
-- FROM 
-- vendor_inventory
-- GROUP BY 1,2
