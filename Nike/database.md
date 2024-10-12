## Database link:

postgresql://Student2:cQDO8rxaN4sG@ep-noisy-flower-846766.us-east-2.aws.neon.tech/Nike?sslmode=require

## 🧱 Database overview:
 
#### 🧱 Customers:

| columns                          | description                       |
|----------------------------------|-----------------------------------|
| Customer_id (text) (primary key) | Unique identifier of the customer |
| state (text)                     | State where customer is located   |
| fav_tennis_player (text)         | Customer’s favorite tennis player |
| age_group (text)                 | Age group                         |

#### 🧱 orders:

| columns                       | description                                            |
|-------------------------------|--------------------------------------------------------|
| order_id (text) (primary key) | Unique identifier of the order                         |
| user_id (text)                | Unique identifier of the customer purchasing the order |
| status (text)                 | Current status of the order                            |
| gender (text)                 | Gender of the customer purchasing the order            |
| created_at (date)             | Date of when the order got created                     |
| shipped_at (date)             | Date of when the order got shipped                     |
| delivered_at (date)           | Date of when the order got delivered                   |
| returned_at (date)            | Date of when the order got returned                    |

#### 🧱 order_items:

| columns                            | description                                           |
|------------------------------------|-------------------------------------------------------|
| order_item_id (text) (primary key) | Unique identifier of the order item                   |
| order_id (text)                    | Unique identifier of the order                        |
| product_id (text)                  | Unique identifier of the product                      |
| created_at (date)                  | Date of when the order item got created               |
| shipped_at (date)                  | Date of when the order item got returned              |
| delivered_at (date)                | Date of when the order item got shipped               |
| returned_at (date)                 | Date of when the order item got delivered             |
| sale_price (float)                 | The sales price of the product part of the order item |

#### 🧱 products:

| columns                         | description                                      |
|---------------------------------|--------------------------------------------------|
| product_id (text) (primary key) | Unique identifier of the product                 |
| cost (float)                    | The cost price of the product                    |
| category (text)                 | The category that the product is part of         |
| product_name (text)             | Name of the product                              |
| retail_price (text)             | Retail price of the product without discount     |
| sku (text)                      | Stock keeping unit code for inventory management |
| distribution_center_id (text)   | Unique identifier of the distribution center     |

#### 🧱 distribution_centers:

| columns                                     | description                                   |
|---------------------------------------------|-----------------------------------------------|
| distribution_center_id (text) (primary key) | Unique identifier of the distribution center  |
| name (text)                                 | Name of the distribution center               |
| latitude (float)                            | Latitude of the distribution center location  |
| longitude (float)                           | Longitude of the distribution center location |

order_items_vintage contains order items from a separate Nike Vintage business unit. The products and orders records associated with the Nike Vintage order items are available in the products and orders tables.

#### 🧱 order_items_vintage:

| columns                            | description                                           |
|------------------------------------|-------------------------------------------------------|
| order_item_id (text) (primary key) | Unique identifier of the order item                   |
| order_id (text)                    | Unique identifier of the order                        |
| product_id (text)                  | Unique identifier of the product                      |
| created_at (date)                  | Date of when the order item got created               |
| shipped_at (date)                  | Date of when the order item got returned              |
| delivered_at (date)                | Date of when the order item got shipped               |
| returned_at (date)                 | Date of when the order item got delivered             |
| sale_price (float)                 | The sales price of the product part of the order item |
