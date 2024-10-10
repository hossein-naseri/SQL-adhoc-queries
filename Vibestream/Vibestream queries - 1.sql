/* Task:

Return top 10 users in all these categories (return everything as 1 table):
a. Users with the most posts on the platform
b. Users with the most followers
c. Users with the most likes received (from other users and not themselves)
d. Users with the most likes given */
----------------------------------------------------------------------------------

--Seting up the general titles for the table
(SELECT
    NULL AS row_,
    'USERS WITH THE MOST POSTS' AS user_names, -- Title for the first sub-table
    NULL AS total_count
)


UNION ALL


-- 1st sub-table:
-- Users with the most posts on the platform
(SELECT
    ROW_NUMBER() OVER(ORDER BY COUNT(post_id) DESC) AS row_,
    user_name,
    COUNT(post_id) AS total_posts

FROM posts
    JOIN users
    USING(user_id)

GROUP BY user_name

ORDER BY total_posts DESC

LIMIT 10
)




UNION ALL




------------- Divider between subtables -------------
(SELECT
    NULL,
    NULL,
    NULL
)


UNION ALL


-- 2nd sub-table's title
(SELECT
    NULL,
    'USERS WITH THE MOST FOLLOWERS',
    NULL
)


UNION ALL


-- 2nd sub-table:
-- Users with the most followers
(SELECT
		ROW_NUMBER() OVER(ORDER BY COUNT(follower_id) DESC) AS row_,
 		user_name,
 		COUNT(follower_id) AS total_followers
    
FROM follows
    JOIN users
    ON users.user_id = follows.followee_id

GROUP BY user_name

ORDER BY total_followers DESC

LIMIT 10
)




UNION ALL




------------- Divider between subtables -------------
(SELECT
    NULL,
    NULL,
    NULL
)


UNION ALL


-- 3rd sub-table's title
(SELECT
    NULL,
    'USERS WITH THE MOST LIKES RECEIVED',
    NULL
)


UNION ALL


-- 4th sub-table:
-- Users with the most likes received
(SELECT
		ROW_NUMBER() OVER(ORDER BY COUNT(like_id) DESC) AS row_,
		user_name,
		COUNT(like_id) AS total_likes_received
    
FROM posts
		JOIN users
    USING(user_id)
    JOIN likes
    USING(post_id)  -- Joining on post_id instead of user_id will return all the likes that a post received
    
WHERE likes.user_id != posts.user_id

GROUP BY user_name

ORDER BY total_likes_received DESC

LIMIT 10)




UNION ALL




------------- Divider between subtables -------------
(SELECT
    NULL,
    NULL,
    NULL
)


UNION ALL


-- Title for the third subtable
(SELECT
    NULL,
    'USERS WITH THE MOST LIKES GIVEN',
    NULL
)


UNION ALL


-- 3rd sub-table:
-- Users with the most likes given
(SELECT
		ROW_NUMBER() OVER(ORDER BY COUNT(like_id) DESC) AS row_,
    user_name,
    COUNT(like_id) AS total_likes_given
    
FROM users
		JOIN likes
    USING(user_id)  -- Joining on user_id will return all likes given by a user
    
GROUP BY user_name

ORDER BY total_likes_given DESC

LIMIT 10
)
;
