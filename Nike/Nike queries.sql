/* Question #1: 
What are the top customers by the total amount of revenue (aggregate of the sales price)
for the Nike Official and Nike Vintage business units combined?

Include the customer id, the total revenue, and the number of order items
each customer has purchased. 

Only include orders that have not been cancelled or returned. */

WITH combined_table AS (
  
    SELECT *
    FROM order_items
  
  UNION
  
    SELECT *
    FROM order_items_vintage
)

SELECT
			ct.user_id AS customer_id,
      SUM(sale_price) AS total_revenue,
      COUNT(order_item_id) AS item_purchased
      
FROM combined_table AS ct
    JOIN orders AS o
    ON o.order_id = ct.order_id
    
WHERE status NOT IN ('Cancelled', 'Returned')

GROUP BY 1

ORDER BY 2 DESC;



------------------------------------------------------------------------------------------------
/*Question #2: 
Combine the order item data from Nike Official and Nike Vintage, and segment customers into three segments.
(1) Customers that only purchased a single product; 
(2) Customers that purchased more than 1 product; 
(3) “Missing Data” (if none of these conditions match)

How many customers and how much revenue (aggregate of the sales price) falls in each segment?

Only include orders that have not been cancelled or returned.
To make you think: what type of data could fall under the third bucket?*/

WITH combined_table AS(
  
    SELECT *
    FROM order_items
  
  UNION
  
    SELECT *
    FROM order_items_vintage
),

purchase_cnt_table AS (
  
  SELECT
      ct.user_id,
      COUNT(DISTINCT ct.product_id) AS item_purchased
  
  FROM combined_table AS ct
      LEFT JOIN orders AS o
      ON o.order_id = ct.order_id
  
  WHERE status NOT IN ('Returned', 'Cancelled')
  
  GROUP BY 1
)


SELECT
    CASE
        WHEN item_purchased = 1 THEN 'Single Item'
        WHEN item_purchased > 1 THEN 'Multi Items'
        ELSE 'Missing Data'
    END AS user_segment,
    COUNT(DISTINCT ct.user_id) AS users,
    SUM(ct.sale_price) AS total_revenue
      
FROM combined_table AS ct
    LEFT JOIN purchase_cnt_table AS pc
    USING (user_id)
    LEFT JOIN orders AS o
    ON o.order_id = ct.order_id
    
WHERE status NOT IN ('Cancelled', 'Returned')

GROUP BY 1

ORDER BY 2 DESC;



------------------------------------------------------------------------------------------------
/* Question #3: 
The Nike Official leadership team is keen to understand what % of the total revenue per state
is coming from the Nike Official business.

Create list that shows the total revenue (aggregate of the sales price) per state, the revenue
generated from Nike Official, and the % of the Nike Official revenue compared to the total revenue
for every state.

Only include orders that have not been cancelled or returned and order the table to show the
state with the highest amount of revenue first, even is there is no information available
about the state. */

WITH combined_table AS(
  
    SELECT
          *,
          'Nike Official' AS department

    FROM order_items
  
  UNION
  
    SELECT
          *,
          'Nike Vintage' AS department

    FROM order_items_vintage
)


SELECT
			state,
      SUM(ct.sale_price) FILTER(WHERE department = 'Nike Official') AS nike_official_total_sale,
      100.0 * (SUM(ct.sale_price) FILTER(WHERE department = 'Nike Official')) / SUM(ct.sale_price)
      		AS nike_official_sale_pct
      
FROM combined_table AS ct
    JOIN orders AS o
    USING (order_id)
    LEFT JOIN customers AS c
    ON c.customer_id = ct.user_id
    
WHERE status NOT IN ('Cancelled', 'Returned')

GROUP BY 1

ORDER BY 2 DESC;



------------------------------------------------------------------------------------------------
/* Question #4: 
Create an overview of the orders by state. Summarize for each customer the number of orders
that have status of Complete, or Canceled (Returned or Cancelled).

Exclude all orders that are still in progress (Processing or Shipped) and only include
orders for customers that have a state available. */

SELECT
    state,
    COUNT(order_id) AS total_orders,
    COUNT(order_id) FILTER(WHERE status = 'Complete') AS completed_orders,
    COUNT(order_id) FILTER (WHERE status IN ('Cancelled', 'Returned')) AS cancelled_orders
      
FROM customers AS c
    INNER JOIN orders AS o
    ON c.customer_id = o.user_id
    
WHERE status NOT IN ('Processing','Shipped')

GROUP BY 1

ORDER BY 1;



------------------------------------------------------------------------------------------------
/* Question 5:
Create a rolling sum that rolls up the number of order items for
each product name for the Nike Official business ordered by product name.

Include the order items where the product name is available. */

SELECT
    DISTINCT product_name,
    COUNT(order_item_id) OVER(ORDER BY product_name)
      
FROM order_items
    INNER JOIN products
    USING(product_id)

ORDER BY 1;



------------------------------------------------------------------------------------------------
/* Question #6:
What is the order item completion rate
(number of completed order items divided by total number of order items) for each of the products
(across Nike Official and Nike Vintage) by product name?

Show the products only where the product name is available and show the products
with highest completion rate first in the table. */

WITH all_orders AS (
  
    SELECT *
    FROM order_items
  
  UNION
  
    SELECT *
    FROM order_items_vintage
)


SELECT
    product_name,
    1.0 * SUM(CASE WHEN delivered_at IS NOT NULL
        AND returned_at IS NULL THEN 1 ELSE 0 END)
        / COUNT(*) AS completion_rate
          
FROM products AS p
    JOIN all_orders AS a
    USING(product_id)
    
GROUP BY 1

ORDER BY 2 DESC;



------------------------------------------------------------------------------------------------
/* Question #7: 
Your manager heard a rumour that there is a difference in
order item completion rates per age group. Can you look into this?
What the order item completion rate (number of completed order items
divided by total number of order items) by age group? */

WITH all_orders AS (
  
    SELECT *
    FROM order_items
  
  UNION
  
    SELECT *
    FROM order_items_vintage
)


SELECT
    COALESCE(age_group,'Unknown') AS age_group,
    1.0 * SUM(CASE WHEN delivered_at IS NOT NULL
        AND returned_at IS NULL THEN 1 ELSE 0 END) / COUNT(*)
        AS completion_rate
        
FROM customers AS c
    RIGHT JOIN all_orders AS a
    ON c.customer_id = a.user_id
    
GROUP BY 1

ORDER BY 2 DESC;



------------------------------------------------------------------------------------------------
/* Question #8:
Calculate the order item completion rate on two levels of granularity: 
(1) The completion rate by age group;
(2) The completion rate by age group and product name.

Create a table that includes the following columns: age group,
order item completion rate by age group, product name,
and order item completion rate by age group and product name.

Only include customers for who the age group is available. */

WITH all_orders AS (
  
    SELECT *
    FROM order_items
  
  UNION
  
    SELECT *
    FROM order_items_vintage
),

age_group_completion AS (
  
  SELECT
    age_group,
    1.0 * SUM(CASE WHEN delivered_at IS NOT NULL
        AND returned_at IS NULL THEN 1 ELSE 0 END)
        / COUNT(*) AS completion_rate_by_age
  
FROM customers AS c
    INNER JOIN all_orders AS a
    ON c.customer_id = a.user_id
  
GROUP BY 1
)


SELECT
    c.age_group,
    completion_rate_by_age,
    product_name,
    1.0 * SUM(CASE WHEN delivered_at IS NOT NULL
        AND returned_at IS NULL THEN 1 ELSE 0 END)
        / COUNT(*) AS completion_rate_by_age_prod
        
FROM age_group_completion AS agc
    INNER JOIN customers AS c
    USING(age_group)
    INNER JOIN all_orders AS ao
    ON c.customer_id = ao.user_id
    INNER JOIN products
    USING(product_id)
    
GROUP BY 1,2,3

ORDER BY 1,3;



------------------------------------------------------------------------------------------------
/* Question #9: 
What are the unique states values available in the customer data?
Count the number of customers associated to each state. */

SELECT
    state,
    COUNT(DISTINCT customer_id)
  
FROM customers

GROUP BY state;



------------------------------------------------------------------------------------------------
/* Question #10: 
It looks like the state data is not 100% clean and your manager
already one issue:
(1) We have a value called “US State” which doesn’t make sense.

After a careful investigation your manager concluded that the “US State”
customers should be assigned to California.

What is the total number of orders that have been completed for every state?
Only include orders for which customer data is available. */

SELECT
    REPLACE(state,'US State','California') AS state,
    COUNT(order_items.order_id) AS total_orders
    
FROM customers
    INNER JOIN order_items
    ON customers.customer_id = order_items.user_id
    INNER JOIN orders
    USING(order_id)
    
WHERE status = 'Complete'

GROUP BY 1;



------------------------------------------------------------------------------------------------
/* Question #11:
What is the total number of orders, number of Nike Official orders,
and number of Nike Vintage orders that are completed by every state?

If customer data is missing, you can assign the records to ‘Missing Data’. */

SELECT
    COALESCE(REPLACE(state,'US State','California'),'Missing Data') AS state,
    COUNT(o.order_id) AS total_orders,
    COUNT(oi.order_id) AS total_order_official,
    COUNT(oiv.order_id) AS total_order_vintage
    
FROM orders AS o
    LEFT JOIN order_items AS oi
    USING(order_id)
    LEFT JOIN order_items_vintage AS oiv
    ON o.order_id = oiv.order_id
    LEFT JOIN customers AS c
    ON o.user_id = c.customer_id
    
WHERE status = 'Complete'

GROUP BY 1

ORDER BY 1;



------------------------------------------------------------------------------------------------
/* Question #12:
Reuse the query you created in question 3 and add the revenue
(aggregate of the sales price) to your table: 
(1) Total revenue for the all orders (not just the completed!) */

WITH completed_orders AS (
  
  SELECT
      COALESCE(REPLACE(state,'US State','California'),'Missing Data') AS state,
      COUNT(o.order_id) AS total_orders,
      COUNT(oi.order_id) AS total_order_official,
      COUNT(oiv.order_id) AS total_order_vintage
  
  FROM orders AS o
      LEFT JOIN order_items AS oi
      		USING(order_id)
      LEFT JOIN order_items_vintage AS oiv
      		ON o.order_id = oiv.order_id
      LEFT JOIN customers AS c
      		ON o.user_id = c.customer_id
      WHERE status = 'Complete'
  
  GROUP BY 1
),

full_orders AS(
  
  SELECT * FROM order_items
  
  UNION
  
  SELECT * FROM order_items_vintage
),

total_revenue_table AS(
  
  SELECT
      COALESCE(REPLACE(state,'US State','California'),'Missing Data') AS state,
      SUM(sale_price) AS total_revenue
  
  FROM full_orders
      LEFT JOIN customers
      ON full_orders.user_id = customers.customer_id
  
  GROUP BY 1
)


SELECT
    total_revenue_table.state,
    total_orders,
    total_order_official,
    total_order_vintage,
    total_revenue
      
FROM total_revenue_table
    INNER JOIN completed_orders
    USING(state)

ORDER BY 1;



------------------------------------------------------------------------------------------------
/* Question #13:
Reuse the query of question 4 and add an additional metric to the table: 
(1) Number of order items that have been returned
(items where the return date is populated) */

SELECT
    COALESCE(REPLACE(state,'US State','California'),'Missing Data') AS state,
    COUNT(o.order_id) FILTER (WHERE status = 'Complete') AS total_orders,
    COUNT(oi.order_id) FILTER (WHERE status = 'Complete') AS total_order_official,
    COUNT(oiv.order_id) FILTER (WHERE status = 'Complete') AS total_order_vintage,
    SUM(COALESCE(oi.sale_price,0) + COALESCE(oiv.sale_price,0)) AS total_revenue,
    COUNT(oi.order_item_id) FILTER (WHERE status = 'Returned') + COUNT(oiv.order_item_id) FILTER (WHERE status = 'Returned') AS total_items_returned
      
FROM orders AS o
    FULL OUTER JOIN order_items AS oi
    		USING(order_id)
    FULL OUTER JOIN order_items_vintage AS oiv
    		ON o.order_id = oiv.order_id
    LEFT JOIN customers AS c
    		ON oi.user_id = c.customer_id OR oiv.user_id = c.customer_id

GROUP BY 1

ORDER BY 1



------------------------------------------------------------------------------------------------
/* Question #14:
When looking at the number of returned items by itself,
it is hard to understand what number of returned items is acceptable.
This is mainly caused by the fact that we don’t have a benchmark at the moment.

Because of that, it is valuable to add an additional metric that looks at
the percentage of returned order items divided by the total order items,
we can call this the return rate.

Reuse the query of question 5 and integrate the return rate into your table. */

SELECT
    COALESCE(REPLACE(state,'US State','California'),'Missing Data') AS state,
    COUNT(o.order_id) FILTER (WHERE status = 'Complete') AS total_orders,
    COUNT(oi.order_id) FILTER (WHERE status = 'Complete') AS total_order_official,
    COUNT(oiv.order_id) FILTER (WHERE status = 'Complete') AS total_order_vintage,
    SUM(COALESCE(oi.sale_price,0) + COALESCE(oiv.sale_price,0)) AS total_revenue,
    COUNT(oi.order_item_id) FILTER (WHERE status = 'Returned')
      + COUNT(oiv.order_item_id) FILTER (WHERE status = 'Returned') AS total_items_returned,
    AVG(CASE WHEN status = 'Returned' THEN 1 ELSE 0 END) AS return_rate
      
FROM orders AS o
    FULL OUTER JOIN order_items AS oi
     	 USING(order_id)
    FULL OUTER JOIN order_items_vintage AS oiv
    		ON o.order_id = oiv.order_id
    LEFT JOIN customers AS c
    		ON oi.user_id = c.customer_id OR oiv.user_id = c.customer_id

GROUP BY 1

ORDER BY 1;

