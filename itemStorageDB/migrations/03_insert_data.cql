-- Электроника
BEGIN BATCH
INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'IPHONE13', 'iPhone 13', 'electronics', 999.99, 'Apple', 4.8);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Apple', now(), 'iPhone 13', 999.99, 'electronics', 4.8, 'IPHONE13');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('electronics', now(), 'iPhone 13', 999.99, 'Apple', 4.8, 'IPHONE13');

INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'MBP14', 'MacBook Pro 14"', 'electronics', 1999.99, 'Apple', 4.9);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Apple', now(), 'MacBook Pro 14"', 1999.99, 'electronics', 4.9, 'MBP14');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('electronics', now(), 'MacBook Pro 14"', 1999.99, 'Apple', 4.9, 'MBP14');

INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'SGS23', 'Galaxy S23', 'electronics', 899.99, 'Samsung', 4.7);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Samsung', now(), 'Galaxy S23', 899.99, 'electronics', 4.7, 'SGS23');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('electronics', now(), 'Galaxy S23', 899.99, 'Samsung', 4.7, 'SGS23');

INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'SGTAB8', 'Galaxy Tab S8', 'electronics', 699.99, 'Samsung', 4.6);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Samsung', now(), 'Galaxy Tab S8', 699.99, 'electronics', 4.6, 'SGTAB8');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('electronics', now(), 'Galaxy Tab S8', 699.99, 'Samsung', 4.6, 'SGTAB8');

INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'SONYWH', 'WH-1000XM5 Headphones', 'electronics', 349.99, 'Sony', 4.8);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Sony', now(), 'WH-1000XM5 Headphones', 349.99, 'electronics', 4.8, 'SONYWH');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('electronics', now(), 'WH-1000XM5 Headphones', 349.99, 'Sony', 4.8, 'SONYWH');

INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'SONYPS5', 'PlayStation 5', 'electronics', 499.99, 'Sony', 4.9);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Sony', now(), 'PlayStation 5', 499.99, 'electronics', 4.9, 'SONYPS5');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('electronics', now(), 'PlayStation 5', 499.99, 'Sony', 4.9, 'SONYPS5');
APPLY BATCH;

-- Одежда
BEGIN BATCH
INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'NIKEAIR', 'Nike Air Force 1', 'clothing', 119.99, 'Nike', 4.5);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Nike', now(), 'Nike Air Force 1', 119.99, 'clothing', 4.5, 'NIKEAIR');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('clothing', now(), 'Nike Air Force 1', 119.99, 'Nike', 4.5, 'NIKEAIR');

INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'NIKEDRI', 'Nike Dri-FIT T-Shirt', 'clothing', 29.99, 'Nike', 4.3);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Nike', now(), 'Nike Dri-FIT T-Shirt', 29.99, 'clothing', 4.3, 'NIKEDRI');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('clothing', now(), 'Nike Dri-FIT T-Shirt', 29.99, 'Nike', 4.3, 'NIKEDRI');

INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'ADIDASU', 'Adidas Ultraboost', 'clothing', 189.99, 'Adidas', 4.6);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Adidas', now(), 'Adidas Ultraboost', 189.99, 'clothing', 4.6, 'ADIDASU');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('clothing', now(), 'Adidas Ultraboost', 189.99, 'Adidas', 4.6, 'ADIDASU');

INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'ZARAJE', 'Zara Denim Jacket', 'clothing', 79.99, 'Zara', 4.2);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Zara', now(), 'Zara Denim Jacket', 79.99, 'clothing', 4.2, 'ZARAJE');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('clothing', now(), 'Zara Denim Jacket', 79.99, 'Zara', 4.2, 'ZARAJE');
APPLY BATCH;

-- Книги
BEGIN BATCH
INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'BOOK1984', '1984 by George Orwell', 'books', 12.99, 'Penguin', 4.8);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Penguin', now(), '1984 by George Orwell', 12.99, 'books', 4.8, 'BOOK1984');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('books', now(), '1984 by George Orwell', 12.99, 'Penguin', 4.8, 'BOOK1984');

INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'BOOKHP', 'Harry Potter Set', 'books', 59.99, 'Bloomsbury', 4.9);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Bloomsbury', now(), 'Harry Potter Set', 59.99, 'books', 4.9, 'BOOKHP');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('books', now(), 'Harry Potter Set', 59.99, 'Bloomsbury', 4.9, 'BOOKHP');

INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'BOOKSAPI', 'Sapiens by Yuval Noah Harari', 'books', 18.99, 'Harper', 4.7);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Harper', now(), 'Sapiens by Yuval Noah Harari', 18.99, 'books', 4.7, 'BOOKSAPI');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('books', now(), 'Sapiens by Yuval Noah Harari', 18.99, 'Harper', 4.7, 'BOOKSAPI');
APPLY BATCH;

-- Дом и кухня
BEGIN BATCH
INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'IKEABILLY', 'IKEA Billy Bookcase', 'home', 89.99, 'IKEA', 4.4);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('IKEA', now(), 'IKEA Billy Bookcase', 89.99, 'home', 4.4, 'IKEABILLY');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('home', now(), 'IKEA Billy Bookcase', 89.99, 'IKEA', 4.4, 'IKEABILLY');

INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'KITCHMIX', 'KitchenAid Stand Mixer', 'home', 299.99, 'KitchenAid', 4.8);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('KitchenAid', now(), 'KitchenAid Stand Mixer', 299.99, 'home', 4.8, 'KITCHMIX');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('home', now(), 'KitchenAid Stand Mixer', 299.99, 'KitchenAid', 4.8, 'KITCHMIX');

INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'PHILIPSAIR', 'Philips Airfryer', 'home', 149.99, 'Philips', 4.6);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Philips', now(), 'Philips Airfryer', 149.99, 'home', 4.6, 'PHILIPSAIR');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('home', now(), 'Philips Airfryer', 149.99, 'Philips', 4.6, 'PHILIPSAIR');
APPLY BATCH;

-- Спортивные товары
BEGIN BATCH
INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'YOGAMAT', 'Yoga Mat Premium', 'sports', 39.99, 'Lululemon', 4.5);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Lululemon', now(), 'Yoga Mat Premium', 39.99, 'sports', 4.5, 'YOGAMAT');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('sports', now(), 'Yoga Mat Premium', 39.99, 'Lululemon', 4.5, 'YOGAMAT');

INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'DUMBBELL', 'Adjustable Dumbbell Set', 'sports', 199.99, 'Bowflex', 4.7);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Bowflex', now(), 'Adjustable Dumbbell Set', 199.99, 'sports', 4.7, 'DUMBBELL');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('sports', now(), 'Adjustable Dumbbell Set', 199.99, 'Bowflex', 4.7, 'DUMBBELL');
APPLY BATCH;