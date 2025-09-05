-- Создаем keyspace с репликацией RF=3
CREATE KEYSPACE IF NOT EXISTS ecommerce WITH replication = {
    'class': 'SimpleStrategy',
    'replication_factor': 3
};

USE ecommerce;

