-- Основная таблица по ID продукта
CREATE TABLE product_by_id (
    product_id uuid PRIMARY KEY,
    sku text,
    title text,
    category text,
    price decimal,
    brand text,
    rating decimal
);

-- Таблица для поиска по бренду
CREATE TABLE products_by_brand (
    brand text,
    product_id uuid,
    title text,
    price decimal,
    category text,
    rating decimal,
    sku text,
    PRIMARY KEY (brand, product_id)
);

-- Таблица для поиска по категории
CREATE TABLE products_by_category (
    category text,
    product_id uuid,
    title text,
    price decimal,
    brand text,
    rating decimal,
    sku text,
    PRIMARY KEY (category, product_id)
);

-- Таблица-счетчик для агрегаций
CREATE TABLE product_count_by_category (
    category text PRIMARY KEY,
    count counter
);