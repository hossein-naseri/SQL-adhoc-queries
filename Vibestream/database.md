### Database link:

postgresql://Test:bQNxVzJL4g6u@ep-noisy-flower-846766.us-east-2.aws.neon.tech/vibestream?sslmode=require


![image](https://github.com/user-attachments/assets/f057c44c-7cf3-4fdc-afaa-ed940c4aa9d2)


## Data Dictionary
* users: user information
  * user_id: unique user ID (key, int)
  * user_name: user created display name (varchar)
* posts: short text messages posted to platform
  * post_id: unique post ID (key, int)
  * user_id: the user ID (foreign key, int)
  * content: text message content (text)
  * post_date: date message was posted (date)
* likes: “like” interactions
  * like_id: unique like ID (key, text)
  * post_id: post ID (foreign key, int)
  * user_id: user ID (foreign key, int)
* follows: follower - followee relationships
  * follower_id: user ID of follower
  * followee_id: user ID of followee (user being followed)
*  algo_update_failure: days with algorithm update system failure 
  * fail_date: (date)
* algo_update_success: days with algorithm update system success 
  * success_date: (date)
