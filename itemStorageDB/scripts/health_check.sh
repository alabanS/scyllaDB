#!/bin/bash

# Скрипт проверки здоровья кластера
set -e

echo "🏥 Проверка здоровья ScyllaDB кластера..."
echo "=========================================="

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция проверки узла
check_node() {
    local node_name=$1
    local node_ip=$2
    local cql_port=$3
    
    echo -n "🔍 Проверяем $node_name ($node_ip)... "
    
    # Проверяем, запущен ли контейнер
    if ! docker ps | grep -q "$node_name"; then
        echo -e "${RED}❌ ОСТАНОВЛЕН${NC}"
        return 1
    fi
    
    # Проверяем доступность CQL
    if docker exec $node_name cqlsh $node_ip -e "DESC KEYSPACES" &> /dev/null; then
        echo -e "${GREEN}✅ CQL ДОСТУПЕН${NC}"
    else
        echo -e "${RED}❌ CQL НЕДОСТУПЕН${NC}"
        return 1
    fi
    
    # Проверяем статус узла через nodetool
    local status=$(docker exec $node_name nodetool status | grep $node_ip | awk '{print $1}')
    if [ "$status" = "UN" ]; then
        echo -e "   📊 Статус: ${GREEN}UP/NORMAL${NC}"
    else
        echo -e "   📊 Статус: ${RED}$status${NC}"
    fi
    
    return 0
}

# Проверяем все узлы
echo ""
echo "📋 Проверка узлов кластера:"
echo "---------------------------"

check_node "scylla-node1" "10.5.0.2" "9042"
check_node "scylla-node2" "10.5.0.3" "9043" 
check_node "scylla-node3" "10.5.0.4" "9044"

echo ""
echo "📊 Проверка состояния кластера..."
echo "--------------------------------"

# Проверяем статус кластера
if docker exec scylla-node1 nodetool status &> /dev/null; then
    echo -e "${GREEN}✅ Кластер отвечает на запросы${NC}"
    
    # Показываем краткий статус
    echo ""
    echo "🌐 Статус кластера:"
    docker exec scylla-node1 nodetool status | grep -E "UN|DN|UJ|UL" | awk '{print "   " $1 " " $2 " - " $7}'
else
    echo -e "${RED}❌ Кластер не отвечает${NC}"
    exit 1
fi

echo ""
echo "🗃️ Проверка базы данных..."
echo "-------------------------"

# Проверяем существование keyspace
if docker exec -it scylla-node1 cqlsh 10.5.0.2 -e "DESC KEYSPACES" | grep -q "ecommerce"; then
    echo -e "${GREEN}✅ Keyspace 'ecommerce' существует${NC}"
    
    # Проверяем таблицы
    table_count=$(docker exec -it scylla-node1 cqlsh 10.5.0.2 -e "USE ecommerce; DESC TABLES;" | wc -l)
    echo -e "   📊 Таблиц в ecommerce: $((table_count - 2))"
    
    # Проверяем количество данных
    echo ""
    echo "📈 Статистика данных:"
    docker exec -it scylla-node1 cqlsh 10.5.0.2 -e "
    USE ecommerce;
    SELECT 'Товаров всего: ' as info, COUNT(*) as count FROM product_by_id;
    " 2>/dev/null | grep -v "rows)" | grep -v "---" | grep -v "^$" || echo "   ℹ️ Данные еще не загружены"
    
else
    echo -e "${YELLOW}⚠️ Keyspace 'ecommerce' не существует (запустите миграции)${NC}"
fi

echo ""
echo "🌐 Проверка сетевых портов..."
echo "---------------------------"

# Проверяем открытые порты
check_port() {
    local port=$1
    local service=$2
    if nc -z localhost $port 2>/dev/null; then
        echo -e "   ✅ Порт $port ($service): ${GREEN}ОТКРЫТ${NC}"
    else
        echo -e "   ❌ Порт $port ($service): ${RED}ЗАКРЫТ${NC}"
    fi
}

check_port 9042 "CQL Node 1"
check_port 9043 "CQL Node 2"
check_port 9044 "CQL Node 3"
check_port 19042 "Monitoring Node 1"
check_port 19043 "Monitoring Node 2"
check_port 19044 "Monitoring Node 3"

echo ""
echo "📋 Итоговый отчет:"
echo "-----------------"

# Проверяем общее состояние
if docker ps | grep -c "scylla-node" | grep -q "3"; then
    echo -e "${GREEN}✅ Все 3 узла запущены${NC}"
else
    running_nodes=$(docker ps | grep -c "scylla-node")
    echo -e "${YELLOW}⚠️ Запущено узлов: $running_nodes/3${NC}"
fi

echo ""
echo "🎯 Рекомендации:"
if ! docker ps | grep -q "scylla-node1"; then
    echo "   💡 Запустите кластер: ./scripts/init_cluster.sh"
elif ! docker exec -it scylla-node1 cqlsh 10.5.0.2 -e "DESC KEYSPACES" | grep -q "ecommerce"; then
    echo "   💡 Выполните миграции: ./scripts/run_migrations.sh"
else
    echo "   💡 Кластер в отличном состоянии!"
fi

echo ""
echo "✅ Проверка здоровья завершена!"
