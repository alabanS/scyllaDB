#!/bin/bash
echo " Инициализация ScyllaDB кластера..."

# Создаем сеть
docker network create --driver=bridge --subnet=10.5.0.0/16 scylla-net

# Запускаем контейнеры
docker-compose up -d

echo "Ожидаем инициализации кластера (180 секунд)..."
sleep 180

# Проверяем статус
echo "📊 Проверяем статус кластера..."
docker exec -it scylla-node1 nodetool status

echo "Кластер готов к работе!"
