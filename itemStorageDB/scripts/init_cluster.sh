#!/bin/bash

# Скрипт инициализации ScyllaDB кластера
set -e

echo "🚀 Инициализация ScyllaDB 3-Node кластера..."
echo "=============================================="

# Проверяем, установлен ли Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен. Пожалуйста, установите Docker сначала."
    exit 1
fi

# Проверяем, установлен ли Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose не установлен. Пожалуйста, установите Docker Compose."
    exit 1
fi

# Создаем сеть если не существует
if ! docker network inspect scylla-net &> /dev/null; then
    echo "🌐 Создаем сеть scylla-net..."
    docker network create --driver=bridge --subnet=10.5.0.0/16 scylla-net
    echo "✅ Сеть создана успешно"
else
    echo "ℹ️ Сеть scylla-net уже существует"
fi

# Останавливаем существующие контейнеры если они запущены
echo "🛑 Останавливаем существующие контейнеры..."
docker-compose down 2>/dev/null || true

# Запускаем кластер
echo "🐳 Запускаем контейнеры..."
docker-compose up -d

echo "⏳ Ожидаем инициализации кластера (это может занять 2-3 минуты)..."

# Ждем пока узлы станут доступны
for i in {1..30}; do
    if docker exec scylla-node1 nodetool status &> /dev/null; then
        echo "✅ Узлы начали запускаться..."
        break
    fi
    echo -n "."
    sleep 6
done

echo ""
echo "📊 Проверяем статус кластера..."
docker exec -it scylla-node1 nodetool status

echo ""
echo "🎉 Кластер ScyllaDB успешно запущен!"
echo ""
echo "📝 Полезные команды:"
echo "   Подключиться к узлу 1: docker exec -it scylla-node1 cqlsh 10.5.0.2"
echo "   Просмотреть логи:      docker-compose logs"
echo "   Остановить кластер:    docker-compose down"
echo ""
echo "📊 Порты доступа:"
echo "   Node 1: CQL - 9042, Monitoring - 19042"
echo "   Node 2: CQL - 9043, Monitoring - 19043" 
echo "   Node 3: CQL - 9044, Monitoring - 19044"
echo ""
echo "Для применения миграций выполните: ./scripts/run_migrations.sh"
