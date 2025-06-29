For this claning we would be using postgresql. this script is used to create a table for analyzing Amazon sales data. the illustrations here is to help us trace our sales data effectively by storing relevant information such as order ID, date, product details, pricing, quantity sold, total sales amount, customer information, payment method, and order status.

-- Drop the table if it already exists to avoid errors on creation

DROP TABLE IF EXISTS public."AmaSales";

create a table for analyzing Amazon sales data.

-- This script creates a table named "AmaSales" with various columns to store sales data.

CREATE TABLE public."AmaSales"
(
    "Order_Id" text NOT NULL,
    "Date" date,
    "Product" text,
    "Category" text,
    "Price" integer,
    "Quantity" integer,
    "Total_Sales" integer,
    "Customer_Name" text,
    "Customer_Location" text,
    "Payment_Method" text,
    "Status" text,
    PRIMARY KEY ("Order_Id")
);

-- Set the owner of the table to the user 'postgres'
-- This ensures that the user has the necessary permissions to manage the table.
ALTER TABLE IF EXISTS public."AmaSales"
    OWNER to postgres;

-- The table is now ready for use, and you can insert data into it as needed.
-- You can use the following command to insert data into the table

-- INSERT INTO public."AmaSales" ("Order_Id", "Date", "Product", "Category", "Price", "Quantity", "Total_Sales", "Customer_Name", "Customer_Location", "Payment_Method", "Status") for me i would be using a csv file to import data into the table.


--to see table structure and data, you can run:
SELECT * FROM public."AmaSales"
ORDER BY "Order_Id" ASC 
limit 10;

-- This will display the first 10 rows of the "AmaSales" table, allowing you to verify that the table has been created correctly and is ready for data insertion.   
-- You can also check the table structure using:   

SELECT column_name, data_type       
FROM information_schema.columns
WHERE table_name = 'AmaSales';

-- This will show you the column names and their data types in the "AmaSales" table.    
-- You can now proceed to insert data into the "AmaSales" table using SQL commands or by importing data from a CSV file.

-- -- -------------------------------------------------------------------------------------------------------------         
this creates a table for analyzing Amazon sales data. The table includes columns for order ID, date, product details, pricing, quantity sold, total sales amount, customer information, payment method, and order status.
-- -- --------------------------------------Feature Engineering--------------------------------------------------------------   
-- -- month name
--  
SELECT 
    "Date",
    TO_CHAR("Date", 'Month') AS month_name
FROM "AmaSales";

-- -- create month name column

ALTER TABLE public."AmaSales" ADD COLUMN month_name VARCHAR(20);

-- -- insert data into month name column
UPDATE public."AmaSales"
SET month_name = TO_CHAR("Date", 'Month');

-- -- -------------------------------------------------------------------------------------------------------------
-- -- day of the week
SELECT 
    "Date",
    TO_CHAR("Date", 'Day') AS day_of_week from "AmaSales";

-- -- create day of the week column         
ALTER TABLE public."AmaSales" ADD COLUMN day_of_week VARCHAR(20);

-- -- insert data into day of the week column
UPDATE public."AmaSales"
SET day_of_week = TO_CHAR("Date", 'Day');

-- -- ------------------------------------------------------------------------------------------------------------- 
-- -- year
SELECT 
    "Date",
    EXTRACT(YEAR FROM "Date") AS year from "AmaSales";

-- -- create day of the week column         
ALTER TABLE public."AmaSales" ADD COLUMN YEAR VARCHAR(20);

-- -- insert data into day of the week column
UPDATE public."AmaSales"
SET YEAR = TO_CHAR("Date", 'YYYY');
-- -- -------------------------------------------------------------------------------------------------------------
-- -- quarter 
SELECT 
    "Date",
    EXTRACT(QUARTER FROM "Date") AS quarter from "AmaSales";
-- -- create quarter column
ALTER TABLE public."AmaSales" ADD COLUMN quarter INTEGER;
-- -- insert data into quarter column
UPDATE public."AmaSales"
SET quarter = EXTRACT(QUARTER FROM "Date");
-- -- --------------------------------------Data Cleaning--------------------------------------------------------------
-- -- Remove duplicates. to be sure that we dont have duplicates, we will be using the ctid column, which is a system column in PostgreSQL that uniquely identifies rows in a table.

-- This query will delete duplicate rows based on the specified columns, keeping only the first occurrence of each duplicate.   
DELETE FROM public."AmaSales"
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM public."AmaSales"
    GROUP BY "Order_Id", "Date", "Product", "Category", "Price", "Quantity", "Total_Sales", "Customer_Name", "Customer_Location", "Payment_Method", "Status"
);

-- -- -------------------------------------------------------------------------------------------------------------
-- -- --------------------------------------Data Validation--------------------------------------------------------------
-- -- Check for null values in the table
SELECT 
    COUNT(*) AS total_rows,
    COUNT("Order_Id") AS non_null_order_id,
    COUNT("Date") AS non_null_date,
    COUNT("Product") AS non_null_product,
    COUNT("Category") AS non_null_category,
    COUNT("Price") AS non_null_price,
    COUNT("Quantity") AS non_null_quantity,
    COUNT("Total_Sales") AS non_null_total_sales,
    COUNT("Customer_Name") AS non_null_customer_name,
    COUNT("Customer_Location") AS non_null_customer_location,
    COUNT("Payment_Method") AS non_null_payment_method,
    COUNT("Status") AS non_null_status
FROM public."AmaSales";
-- This query will give you a count of total rows and non-null values for each column in the "AmaSales" table, helping you identify any columns with null values.

-- -- -------------------------------------------------------------------------------------------------------------
-- -- --------------------------------------Data Transformation--------------------------------------------------------------
-- -- Convert the "Price" and "Total_Sales" columns to numeric data type if they are not already
ALTER TABLE public."AmaSales"
    ALTER COLUMN "Price" TYPE numeric USING "Price"::numeric,
    ALTER COLUMN "Total_Sales" TYPE numeric USING "Total_Sales"::numeric;
-- This query will change the data type of the "Price" and "Total_Sales" columns to numeric, allowing for better calculations and aggregations.

-- -- -------------------------------------------------------------------------------------------------------------
-- -- --------------------------------------Data Aggregation--------------------------------------------------------------
-- -- Aggregate sales data by month and category
SELECT 
    TO_CHAR("Date", 'Month') AS month_name,
    "Category",
    SUM("Total_Sales") AS total_sales_amount,
    AVG("Price") AS average_price,
    SUM("Quantity") AS total_quantity_sold  
FROM public."AmaSales"
GROUP BY 
    TO_CHAR("Date", 'Month'), 
    "Category"
ORDER BY
    TO_CHAR("Date", 'Month'), 
    "Category";
-- This query will aggregate the sales data by month and category, providing insights into total sales, average price, and total quantity sold for each category in each month.

-- -- -------------------------------------------------------------------------------------------------------------
EDA
we can now perform exploratory data analysis (EDA) on the "AmaSales" table to gain insights into the sales data. understanding the data distribution, trends, and patterns can help in making informed business decisions. Here are the steps i used to Exploratory Data analysis on the "AmaSales" table:

-- 1. Check the total number of sales records
SELECT COUNT(*) AS total_sales_records  
FROM public."AmaSales";
-- 2. Get the total sales amount
SELECT SUM("Total_Sales") AS total_sales_amount
FROM public."AmaSales";
-- 3. Get the average price of products sold    
SELECT AVG("Price") AS average_price
FROM public."AmaSales"; 
-- 4. Get the total quantity sold by product category
SELECT "Category", SUM("Quantity") AS total_quantity_sold   
FROM public."AmaSales"
GROUP BY "Category"
ORDER BY total_quantity_sold DESC;
-- 5. Get the total sales amount by month
SELECT 
    TO_CHAR("Date", 'Month') AS month_name, 
    EXTRACT(MONTH FROM "Date") AS month_number,
    SUM("Total_Sales") AS total_sales_amount
FROM public."AmaSales"
GROUP BY 
    TO_CHAR("Date", 'Month'), 
    EXTRACT(MONTH FROM "Date")
ORDER BY 
    EXTRACT(MONTH FROM "Date");
-- 6. Get the total sales amount by payment method
SELECT 
    "Payment_Method", 
    SUM("Total_Sales") AS total_sales_amount
FROM public."AmaSales"
GROUP BY "Payment_Method"
ORDER BY total_sales_amount DESC;
-- 7. Get the total sales amount by customer location
SELECT 
    "Customer_Location", 
    SUM("Total_Sales") AS total_sales_amount    
FROM public."AmaSales"
GROUP BY "Customer_Location"
ORDER BY total_sales_amount DESC;
-- 8. Get the total sales amount by order status
SELECT 
    "Status", 
    SUM("Total_Sales") AS total_sales_amount
FROM public."AmaSales"
GROUP BY "Status"
ORDER BY total_sales_amount DESC;
-- 9. Get the top 5 products by total sales amount
SELECT 
    "Product", 
    SUM("Total_Sales") AS total_sales_amount
FROM public."AmaSales"
GROUP BY "Product"
ORDER BY total_sales_amount DESC
LIMIT 5;    
-- 10. Get the total sales amount by year
SELECT 
    EXTRACT(YEAR FROM "Date") AS year, 
    SUM("Total_Sales") AS total_sales_amount
FROM public."AmaSales"
GROUP BY year
ORDER BY year DESC;
-- 11. Get the total sales amount by quarter
SELECT 
    EXTRACT(QUARTER FROM "Date") AS quarter, 
    SUM("Total_Sales") AS total_sales_amount
FROM public."AmaSales"
GROUP BY quarter
ORDER BY quarter DESC;
-- Get the average quantity sold by product
SELECT 
    "Product", 
    AVG("Quantity") AS average_quantity_sold
FROM public."AmaSales"
GROUP BY "Product"  
ORDER BY average_quantity_sold DESC;
-- Get the total sales amount by day of the week
SELECT 
    TO_CHAR("Date", 'FMDay') AS day_of_week, 
    SUM("Total_Sales") AS total_sales_amount
FROM public."AmaSales"
GROUP BY TO_CHAR("Date", 'FMDay')
ORDER BY 
    CASE TO_CHAR("Date", 'FMDay')
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;

--get the highest location with the highest sales
SELECT 
    "Customer_Location", 
    SUM("Total_Sales") AS total_sales_amount    
FROM public."AmaSales"
GROUP BY "Customer_Location"
ORDER BY total_sales_amount DESC
LIMIT 3;

-- Get the highest sales by customer 
SELECT 
    "Customer_Name", 
    SUM("Total_Sales") AS total_sales_amount
FROM public."AmaSales"
GROUP BY "Customer_Name"
ORDER BY total_sales_amount DESC
LIMIT 3;
-- Get the average total sales amount by month
SELECT 
    TO_CHAR("Date", 'Month') AS month_name, 
    AVG("Total_Sales") AS average_total_sales
FROM public."AmaSales"
GROUP BY TO_CHAR("Date", 'Month')
ORDER BY 
    CASE TO_CHAR("Date", 'Month')
        WHEN 'January' THEN 1
        WHEN 'February' THEN 2
        WHEN 'March' THEN 3
        WHEN 'April' THEN 4
        WHEN 'May' THEN 5
        WHEN 'June' THEN 6
        WHEN 'July' THEN 7
        WHEN 'August' THEN 8
        WHEN 'September' THEN 9
        WHEN 'October' THEN 10
        WHEN 'November' THEN 11
        WHEN 'December' THEN 12
    END;

-- Get the average total sales amount by year
SELECT 
    EXTRACT(YEAR FROM "Date") AS year, 
    AVG("Total_Sales") AS average_total_sales   
FROM public."AmaSales"
GROUP BY year
ORDER BY year DESC;
-- Get the average total sales amount by quarter
SELECT 
    EXTRACT(QUARTER FROM "Date") AS quarter, 
    AVG("Total_Sales") AS average_total_sales
FROM public."AmaSales"
GROUP BY quarter
ORDER BY quarter DESC;

this will be the end of the exploratory data analysis (EDA) on the "AmaSales" table. The queries provided will help you gain insights into the sales data, including total sales, average prices, sales by category, month, payment method, customer location, order status, and more.
-- You can further customize these queries based on your specific analysis needs.
-- we would visualize the results using tools like Power BI, to create charts and graphs for better understanding.
-- This will help in identifying trends, patterns, and anomalies in the sales data.
-- You can also export the results to CSV or Excel for further analysis or reporting.
-- -- ------------------------------------------------------------------------------------------------------------- 


