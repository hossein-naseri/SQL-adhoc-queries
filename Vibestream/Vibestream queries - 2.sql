/* Question #1:

Vibestream is designed for users to share brief updates about how they are feeling,
as such the platform enforces a character limit of 25. How many posts are
exactly 25 characters long? */


SELECT COUNT(*) AS char_limit_posts

FROM posts

WHERE LENGTH(content) = 25;



--------------------------------------------------------------------------------
/* Question #2:

Users JamesTiger8285 and RobertMermaid7605 are Vibestream’s most active posters.

Find the difference in the number of posts these two users made on each day that
at least one of them made a post. Return dates where the absolute value
of the difference between posts made is greater than 2 (i.e dates where
JamesTiger8285 made at least 3 more posts than RobertMermaid7605 or vice versa). */


WITH users_post_count AS (
  
  SELECT
  		post_date,
  		COUNT(post_id) FILTER(WHERE user_name = 'JamesTiger8285') AS JamesTiger8285_posts,
  		COUNT(post_id) FILTER(WHERE user_name = 'RobertMermaid7605') AS RobertMermaid7605_posts
  
  FROM posts
  		JOIN users
  		USING(user_id)
  
  WHERE user_name = 'RobertMermaid7605'
  		OR user_name = 'JamesTiger8285'
  
  GROUP BY post_date
)


SELECT
		post_date

FROM users_post_count

WHERE ABS(JamesTiger8285_posts - RobertMermaid7605_posts) > 2

ORDER BY post_date;



--------------------------------------------------------------------------------
/* Question #3: 
Most users have relatively low engagement and few connections.
User WilliamEagle6815, for example, has only 2 followers.

Network Analysts would say this user has two **1-step path** relationships.
Having 2 followers doesn’t mean WilliamEagle6815 is isolated, however.
Through his followers, he is indirectly connected to the larger Vibestream network.

Consider all users up to 3 steps away from this user:

- 1-step path (X → WilliamEagle6815)
- 2-step path (Y → X → WilliamEagle6815)
- 3-step path (Z → Y → X → WilliamEagle6815)

Write a query to find follower_id of all users within 4 steps of WilliamEagle6815.
Order by follower_id and return the top 10 records. */


WITH follower_steps AS (
  
  SELECT
      first_step.follower_id AS first_step_follower,
      second_step.follower_id AS second_step_follower,
      third_step.follower_id AS third_step_follower,
      fourth_step.follower_id AS fourth_step_follower

  FROM follows AS first_step
      JOIN users
      ON users.user_id = first_step.followee_id
      JOIN follows AS second_step
      ON first_step.follower_id = second_step.followee_id
      JOIN follows AS third_step
      ON second_step.follower_id = third_step.followee_id
      JOIN follows AS fourth_step
      ON third_step.follower_id = fourth_step.followee_id

  WHERE user_name = 'WilliamEagle6815'
)


SELECT DISTINCT first_step_follower AS follower_id
FROM follower_steps

UNION

SELECT DISTINCT second_step_follower
FROM follower_steps

UNION

SELECT DISTINCT third_step_follower
FROM follower_steps

UNION

SELECT DISTINCT fourth_step_follower
FROM follower_steps

ORDER BY follower_id

LIMIT 10;



--------------------------------------------------------------------------------
/* Question #4: 
Return top posters for 2023-11-30 and 2023-12-01. A top poster is a user who
has the most OR second most number of posts in a given day.
Include the number of posts in the result and order the result by post_date
and user_id. */


WITH ranking_table AS (

  SELECT
      post_date,
      user_id,
      DENSE_RANK() OVER(PARTITION BY post_date ORDER BY COUNT(post_id) DESC) AS rank_,
      COUNT(post_id) AS posts

  FROM posts

  WHERE post_date IN('2023-11-30', '2023-12-01')

  GROUP BY 1,2
)


SELECT
		post_date,
    user_id,
    posts
    
FROM ranking_table

WHERE rank_ IN(1,2)

ORDER BY 1,2;
