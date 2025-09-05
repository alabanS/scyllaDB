#!/bin/bash

# Скрипт выполнения миграций базы данных
set -e

echo "📦 Выполнение миграций ScyllaDB..."
echo "==================================="

# Проверяем, запущен ли кластер
if ! docker ps | grep -q "scylla-node1"; then
    echo "❌ Кластер не запущен. Запустите сначала: ./scripts/init_cluster.sh"
    exit 1
fi

MIGRATIONS_DIR="./migrations"
NODE_IP="10.5.0.2"

# Проверяем существование директории с миграциями
if [ ! -d "$MIGRATIONS_DIR" ]; then
    echo "❌ Директория миграций не найдена: $MIGRATIONS_DIR"
    exit 1
fi

echo "🔍 Поиск файлов миграций в $MIGRATIONS_DIR..."

# Получаем список файлов миграций в правильном порядке
MIGRATION_FILES=$(ls $MIGRATIONS_DIR/*.cql | sort)

if [ -z "$MIGRATION_FILES" ]; then
    echo "❌ Файлы миграций не найдены"
    exit 1
fi

echo "📋 Найдены файлы миграций:"
for file in $MIGRATION_FILES; do
    echo "   - $(basename $file)"
done

echo ""
echo "🚀 Начинаем выполнение миграций..."

for migration_file in $MIGRATION_FILES; do
    filename=$(basename $migration_file)
    echo ""
    echo "📝 Выполняем: $filename"
    echo "-----------------------------------"
    
    # Копируем файл в контейнер
    docker cp "$migration_file" scylla-node1:/tmp/
    
    # Выполняем миграцию
    if docker exec -it scylla-node1 cqlsh $NODE_IP -f "/tmp/$filename"; then
        echo "✅ $filename выполнен успешно"
    else
        echo "❌ Ошибка при выполнении $filename"
        exit 1
    fi
    
    # Удаляем временный файл
    docker exec scylla-node1 rm -f "/tmp/$filename"
done

echo ""
echo "🎉 Все миграции выполнены успешно!"
echo ""
echo "🧪 Запускаем тестовые запросы для проверки..."

# Выполняем тестовый запрос для проверки
if docker exec -it scylla-node1 cqlsh $NODE_IP -e "
USE ecommerce;
SELECT 'Таблицы созданы: ' as status, COUNT(*) as table_count 
FROM system_schema.tables 
WHERE keyspace_name = 'ecommerce';" 2>/dev/null; then
    echo "✅ База данных и таблицы созданы успешно"
else
    echo "❌ Ошибка при проверке базы данных"
    exit 1
fi

echo ""
echo "📊 Проверяем данные..."
docker exec -it scylla-node1 cqlsh $NODE_IP -e "
USE ecommerce;
SELECT 'Товаров в базе: ' as info, COUNT(*) as total_products FROM product_by_id;" 2>/dev/null || true

echo ""
echo "✅ Миграции завершены! Кластер готов к работе."
