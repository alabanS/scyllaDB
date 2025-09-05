# ScyllaDB: современная распределённая NoSQL-база данных

## История и происхождение

ScyllaDB появилась в 2015 году как переписанная с нуля версия Apache Cassandra на языке C++ (вместо Java).
Основатели (израильские инженеры Avi Kivity и Dor Laor) известны также разработкой гипервизора KVM. Их идея заключалась в том, чтобы взять сильные стороны Cassandra (распределённость, отказоустойчивость, линейное масштабирование), но устранить её слабые стороны — высокую латентность, трудности с «паузами GC» и ограниченную производительность.

С самого начала ScyllaDB позиционировалась как «Cassandra-совместимая, но гораздо быстрее». Совместимость достигается на уровне протоколов (CQL — Cassandra Query Language и драйверы).

---

## Архитектура и технология

В основе ScyllaDB лежат несколько принципов:

1. Язык C++ и фреймворк Seastar
   Вместо JVM и garbage collector используется C++ с асинхронным фреймворком Seastar. Это убирает «стоп-the-world» паузы и позволяет более эффективно использовать ресурсы.

2. Shared-nothing архитектура
   Каждый узел полностью автономен, данные распределяются по кластеру через шардирование.
   Более того, внутри узла данные разбиваются на shards (обычно по количеству аппаратных потоков CPU), и каждый поток работает со своим набором данных, исключая блокировки.

3. Масштабируемость и распределённость
   ScyllaDB — horizontally scalable: при добавлении узлов в кластер производительность почти линейно растёт.

4. Совместимость с Cassandra API
   Можно использовать те же драйверы, схемы и запросы, что и для Cassandra. Это позволяет мигрировать без переписывания приложений.

---

## Преимущества перед реляционными СУБД (например, PostgreSQL)

### Проблема с PostgreSQL 

* PostgreSQL отлично работает для транзакционных систем, но при больших объёмах (сотни миллионов строк, особенно при сложных индексах и запросах) начинает «тормозить»: растёт время отклика, нагрузка на диск и память.
* Масштабирование PostgreSQL горизонтально очень сложно (нужны шардирование вручную или сторонние решения типа Citus).

### Что даёт ScyllaDB:

* Горизонтальное масштабирование: можно держать сотни миллионов и миллиарды записей, просто добавляя узлы.
* Высокая пропускная способность: ScyllaDB в бенчмарках обрабатывает миллионы операций в секунду на кластере.
* Низкая латентность: десятки миллисекунд на чтение/запись даже при огромной нагрузке.
* Автоматическое распределение данных: не нужно вручную думать о шардах.
* Always-on модель: система изначально рассчитана на кластеры с отказоустойчивостью, в отличие от единого PostgreSQL сервера.

### Минусы по сравнению с PostgreSQL:

* Нет полноценной поддержки JOIN, транзакций в стиле ACID (есть только ограниченные lightweight transactions).
* Ограниченный язык запросов: CQL похож на SQL, но сильно урезан.
* Сложность администрирования и архитектуры: для OLTP-сценариев иногда избыточно.

---

## Отличия от Cassandra

Хотя ScyllaDB полностью совместима с Cassandra API, есть важные различия:

| Характеристика     | Cassandra                            | ScyllaDB                                |
| ------------------ | ------------------------------------ | --------------------------------------- |
| Язык реализации    | Java (JVM)                           | C++ (Seastar)                           |
| Управление памятью | GC (паузы, задержки)                 | Без GC, ручное управление               |
| Производительность | Низкая латентность хуже предсказуема | Более низкая латентность и стабильность |
| Использование CPU  | Неэффективное, блокировки            | CPU-pinning, sharding без блокировок    |
| Масштабирование    | Хорошее                              | Линейное и более предсказуемое          |
| Эксплуатация       | Требует тюнинга JVM                  | Более «коробочное» решение              |

---

## Масштабирование и репликация

ScyllaDB использует распределённую модель хранения:

1. Шардирование данных
   Данные автоматически разбиваются по ключам (partition key) и распределяются между узлами кластера.
   Каждый узел хранит свой сегмент данных.

2. Репликация

   * Можно настроить количество реплик (обычно RF=3).
   * Реплики размещаются по разным датацентрам или узлам.
   * Поддерживаются стратегии: SimpleStrategy, NetworkTopologyStrategy.

3. Consistency model (уровни согласованности)
   Можно балансировать между скоростью и надёжностью:

   * ONE (быстро, но риск потерять данные при сбое узла),
   * QUORUM (золотая середина),
   * ALL (надёжно, но медленнее).

4. Масштабирование (scale-out)
   При добавлении нового узла кластер автоматически перераспределяет данные (rebalancing).
   В отличие от PostgreSQL, нет необходимости вручную резать таблицы на шарды.

---

## Пример: 300 млн карточек товара

* В PostgreSQL:

  * Индексы разрастаются до десятков гигабайт.
  * Запросы JOIN и ORDER BY становятся узким местом.
  * Нужен вертикальный масштаб (дорогой сервер).

* В ScyllaDB:

  * Данные распределяются по кластеру из, скажем, 6 узлов.
  * Запросы по ключу работают одинаково быстро, независимо от размера таблицы.
  * Масштабируемость почти линейная: если нагрузка выросла в 2 раза, просто добавляем ещё 2 узла.

---

## Плюсы и минусы ScyllaDB

### Плюсы:

* Высокая производительность (миллионы операций/сек).
* Низкая и предсказуемая латентность.
* Горизонтальное масштабирование.
* Совместимость с Cassandra API.
* Оптимальное использование «железа» (CPU, память, SSD, NVMe).

### Минусы:

* Нет полноценного SQL (ограниченный CQL).
* Нет сложных транзакций и связей (JOIN, foreign keys).
* Требует перестройки модели данных (денормализация).
* Для аналитики может понадобиться отдельный движок (Spark, Presto, ScyllaDB Alternator для совместимости с DynamoDB API).

---

## Когда выбирать ScyllaDB

Подходит:

* Сотни миллионов/миллиарды записей.
* Высокая нагрузка на чтение/запись (e-commerce каталоги, IoT-события, телеметрия, логи).
* Сценарии, где нужна скорость и горизонтальная масштабируемость.

Не подходит:

* Сложные транзакции и связи (OLTP-сценарии банков, ERP).
* BI и аналитика без внешнего инструмента.

---

# Пример реализации хранения карточек товара в ScyllaDB (\~300 млн)

# Краткая идея

Привести полный практический план и архитектурная схема для хранения \~300 млн карточек товара в ScyllaDB, с реальными цифрами, примером схемы (CQL), рекомендациями по репликации/консистенции, миграции из PostgreSQL и расчётом ёмкости/узлов. Я сделал расчёты и дал варианты (консервативные и экономные).

---

# 1) Оценка объёма хранения

Возьмём 300 000 000 карточек. Оценим размер одной карточки (без больших изображений) нa 0.5 KB — 5 KB (варианты). Я посчитал объёмы и с учётом репликации RF=3.

* 0.5 KB / запись

  * raw ≈ 143 GB
  * с RF=3 ≈ 429 GB

* 1 KB / запись (реалистичный для метаданных)

  * raw ≈ 286 GB
  * с RF=3 ≈ 858 GB

* 2 KB / запись

  * raw ≈ 572 GB
  * с RF=3 ≈ 1.72 TB

* 5 KB / запись

  * raw ≈ 1.43 TB
  * с RF=3 ≈ 4.29 TB

(все числа округлены; я включил расчёты с учётом RF=3 и дал диапазон).
Рекомендую добавить headroom 30–50% на SSTable/Compaction/tombstones/индексы/будущий рост. (см. пример расчётов в разделе «Хардуэр»).

> Источники по рекомендациям по объёму и соотношению storage/memory, аппаратным требованиям Scylla — в документации ScyllaDB. ([enterprise.docs.scylladb.com][2], [scylladb.com][3])

---

# 2) Рекомендации по аппаратной конфигурации и числу узлов

Scylla эффективно использует многоядерные CPU и NVMe. Общие практики:

* Минимум для production — 3 узла (чтобы RF=3 имело смысл). Для производительности/отказоустойчивости лучше 6+ узлов. ([scylladb.com][3])
* CPU: минимум 16 физических ядер на узел; Scylla использует модель «shard-per-core».
* RAM: ориентир — 128–256 GB RAM на узел; Scylla даёт рекомендации по соотношению storage\:memory ≈ 30:1 как верхняя граница. ([enterprise.docs.scylladb.com][2])
* Диск: NVMe SSD (предпочтительно), RAID0 для SAS/ SATA (если NVMe нет).
* Сеть: 10 GbE минимум; 25/40 GbE — лучше при больших кластерах.

Пример конфигурации для среднего варианта (1 KB/строка, 300M):

* Требуется \~0.86 TB (RF=3) + 50% headroom ≈ 1.3 TB данных на кластере (все копии вместе).
* С учётом производительности и равномерного распределения, рекомендую кластер 6 узлов, каждый с NVMe 2–4 TB, 16–32 cores, 128–256 GB RAM. Это даёт:

  * хорошее распараллеливание,
  * низкую нагрузку на каждый узел,
  * запас на рост и операции compaction.
    Эти рекомендации соответствуют best practices и обучающим материалам Scylla. ([ScyllaDB University][4], [scylladb.com][3])

---

# 3) Модель данных — как хранить карточки товара (пример CQL)

В Scylla (как и в Cassandra) проектируем модель под access patterns. Для карточек товара обычно важны операции:

* чтение карточки по product\_id (очень частое)
* поиск/скан по категории (часто)
* фильтры / сортировки — по возможности заранее денормализуем.

## Вариант A — быстрый lookup по product\_id (рекомендуемый для OLTP)
CREATE KEYSPACE ecommerce WITH replication = {
  'class': 'NetworkTopologyStrategy', 'DC1': 3
};

CREATE TABLE product_by_id (
  product_id uuid,
  sku text,
  title text,
  category text,
  price decimal,
  attrs map<text, text>,
  updated_at timestamp,
  PRIMARY KEY ((product_id))
);

* Партия: product_id — уникальная партиция (обычно одна карточка = одна партиция). Это даёт быстрый read-one по ключу и не даёт «больших партиций».

## Вариант B — поддержать быстрые сканы по категории (bucketed partitions)

Для категорий с очень большим количеством товаров — не делаем одну большую партицию. Разбиваем на «бакеты».
CREATE TABLE products_by_category (
  category text,
  bucket int,
  product_id uuid,
  title text,
  price decimal,
  PRIMARY KEY ((category, bucket), product_id)
) WITH CLUSTERING ORDER BY (product_id ASC);

* bucket = вычисляемое значение (например hash(category, product\_id) % 64) — число бакетов выбирается по ожидаемому объёму категории. Это убирает «hot partitions» и делает выборки по категории параллельными.

### Примечания по моделированию

* Избегай ALLOW FILTERING — дорогая операция.
* JOIN в Scylla нет — данные нужно денормализовать (копировать) в нужные таблицы.
* Если нужны сложные аналитические запросы — держим OLAP-реплику в ClickHouse / Druid / Elastic / Redshift и т.д.

(Рекомендации по партициям и bucket-ам подробно описаны в практиках Scylla). ([scylladb.com][1])

---

# 4) Репликация и уровень согласованности (consistency)

* Replication Factor (RF): обычно 3 для одного DC; если есть несколько датацентров — используем NetworkTopologyStrategy и указываем RF для каждого DC. ([docs.scylladb.com][5])
* Consistency Level (CL):

  * ONE — самая быстрая, минимальная надёжность.
  * QUORUM — сбалансированная опция (для RF=3 — запись/чтение должны подтвердить 2 ноды). Часто выбирается для большинства операций. ([enterprise.docs.scylladb.com][6], [ScyllaDB University][7])
  * LOCAL_QUORUM, LOCAL_ONE — полезны при мультIDC-распределении.

Рекомендация: для e-commerce каталога, где потеря одного обновления нежелательна, но нужна скорость — QUORUM для записи/чтения (или LOCAL_QUORUM при geo-DC).

---

# 5) Compaction, tombstones, TTL — что важно

* Scylla поддерживает STCS (Size-Tiered), LCS (Leveled) и TWCS (TimeWindow) — выбор зависит от характера нагрузки (read-heavy vs time-series vs delete-heavy). ([docs.scylladb.com][8], [enterprise.docs.scylladb.com][9])
* При частых удалениях/TTL образуются tombstones — надо планировать: TWCS плохо обрабатывает массовые явные удаления; для delete-heavy лучше STCS и аккуратно проектировать TTL/удаления. ([forum.scylladb.com][10])
* Планируй мониторинг больших партиций и tombstones; не даем партициям вырасти слишком большими.

---

# 6) Конкретная архитектурная схема (пример для твоего случая: 300M карточек)

1. Кластер: DC1 — 6 узлов, RF=3 (каждая запись хранится на 3 узлах).
2. Hardware (пример): каждый узел — 16-32 physical cores, 128–256 GB RAM, NVMe 2–4 TB, сеть 25 GbE. ([scylladb.com][3], [enterprise.docs.scylladb.com][2])
3. Таблицы:

   * product_by_id (primary fast lookup)
   * products_by_category((category,bucket), product_id) (для списков по кат.)
   * Доп. таблицы для популярных сортировок/фильтров (денормализованные).
4. Compaction: STCS по умолчанию; для read-heavy таблиц — LCS; для time-series — TWCS (но для карточек товара — STCS/LCS обычно OK). ([enterprise.docs.scylladb.com][9])
5. Consistency: QUORUM (чтение+запись) или LOCAL_QUORUM (при multi-DC). ([ScyllaDB University][7])
6. Кэширование: доп. CDN/кеши на уровне приложения (Redis) для горячих карточек — разумно, но Scylla сама по себе очень быстра.

---

# 7) Миграция из PostgreSQL — пошагово

Для миграции большого объёма (300M) — использовать потоковую или пакетную миграцию, не пытаться делать COPY в один шаг.

План миграции:

1. Проектирование модели данных в Scylla (см. раздел 3) — подготовь денормализацию.
2. Подготовка кластера Scylla — поднять тестовый кластер (3–6 узлов), настроить replication strategy. ([scylladb.com][3])
3. Экспорт/трансформация:

   * Вариант A: использовать Scylla Migrator (Spark-based) — особенно когда исходная БД — Cassandra / CQL или DynamoDB; Spark-модуль позволяет трансформировать и загружать в Scylla параллельно. ([GitHub][11], [enterprise.docs.scylladb.com][12])
   * Вариант B: экспорт из Postgres в CSV/Parquet -> использовать Spark + Scylla Spark Connector (или написать batch-loader), параллельно писать в Scylla. ([GitHub][13], [enterprise.docs.scylladb.com][12])
   * Вариант C (для Cassandra → Scylla): sstableloader / scylla sstableloader. Для миграции из Postgres чаще Spark-путь предпочтительнее. ([cassandra.link][14], [Apache Cassandra][15])
4. Dual-write (опционально): настроить приложение на параллельную запись в Postgres и Scylla, чтобы постепенно переключать чтения.
5. Валидация: сравнить хеши/счётчики/рандомные выборки; Scylla-migrator имеет валидатор.

([Medium][16], [GitHub][11])
6. Cutover: переключить чтения (и затем отключить записи в Postgres).
7. Cleanup: удалить устаревшие данные, настроить бэкапы.

---

# 8) Практические советы / подводные камни

* Не проектируй под SQL-джойны: нужно денормализовать.
* Избегать больших партиций: ограничивать размер партиции (в байтах или числом строк), используем bucket-ы. ([scylladb.com][1])
* Тщательно подумать о tombstones / mass deletes: массовые удаления создают проблемы. Планируем TTL и удаление аккуратно. ([forum.scylladb.com][10])
* Мониторинг: обязательно поставить Scylla Monitoring Stack (Prometheus/Grafana) и следить за latencies, pending tasks, compaction, tombstones.
* Тестирование нагрузки: нагрузочные тесты (jepsen/yardstick) перед cutover.

---

# 9) Примерный бюджет-ориентированный сценарий (быстро)

* Если средний размер карточки ≈ 1 KB, RF=3, с запасом — \~**1.3 TB** итоговых копий → можно разместить на 3–4 NVMe-узлах по ёмкости, но для нагрузки/производительности рекомендую 6 узлов (баланс throughput и отказоустойчивость). ([scylladb.com][3])
* Если карточки тяжелее (2–5 KB) — планируй 6–12 узлов или более (в зависимости от SSD объёма).

---

# 10) Примеры CQL + подсказки (коротко)

product\_by\_id (одна запись/партиция):
CREATE TABLE product_by_id (
  product_id uuid PRIMARY KEY,
  sku text,
  title text,
  description text,
  attrs map<text,text>,
  price decimal,
  in_stock boolean,
  updated_at timestamp
);

products\_by\_category (bucketed):
CREATE TABLE products_by_category (
  category text,
  bucket int,
  product_id uuid,
  title text,
  price decimal,
  PRIMARY KEY ((category, bucket), product_id)
);

Bucket вычисляется в приложении при записи: bucket = hash(category, product_id) % N_BUCKETS.

---

# 11) Краткое сравнение PostgreSQL → Scylla для моего сценария

* Postgres сильнее: сложные транзакции, JOIN, ad-hoc queries, сильная консистентность ACID.
* Scylla сильнее: масштабируемость, высокая QPS, низкая латентность при миллионах записей и распределённых нагрузках. Для каталога товара с 300M карточек, высокой частотой чтений и необходимостью линейного масштабирования — Scylla даёт явные преимущества. Есть компромиссы: нужно пересмотреть модель данных и отказаться от SQL-функционала, который ты использовал в Postgres.

---

# 12) Резюме шагов, с которыми я рекомендую начать прямо сейчас

1. Оценить средний размер карточки (собрать статистику по строчному объему в Postgres).
2. Поднять тестовый кластер Scylla (3–6 узлов) с NVMe/16–32 vCPU/128GB RAM.
3. Разработать CQL-схему (product\_by\_id + bucketed products\_by\_category).
4. Прототип миграции: экспорт 1–10% данных -> загрузить через Spark + scylla-spark-connector или Scylla Migrator и валидировать. 
5. Прогнать нагрузочные тесты (латентность, compaction, tombstones).
6. После валидации — rollout (dual-write → cutover).

---

Если хочешь, могу прямо сейчас:

* 1. Составить точную оценку числа узлов под твои реальные размеры карточек — для этого мне хватит средней/медианной величины одной карточки (в байтах), % изображений в БД (если хранятся) и QPS (чтения/записи).
* 2. Сгенерировать готовый plan-of-action для миграции (шаги, скрипты, пример config для Scylla Migrator / Spark).

Напиши: дать точный подсчёт узлов по реальным цифрам (размер карточки и QPS)?

[1]: https://www.scylladb.com/2024/11/05/making-effective-partitions-for-scylladb-data-modeling/?utm_source=chatgpt.com "Making Effective Partitions for ScyllaDB Data Modeling"
[2]: https://enterprise.docs.scylladb.com/stable/operating-scylla/procedures/tips/benchmark-tips.html?utm_source=chatgpt.com "Maximizing Scylla Performance | ScyllaDB Docs"
[3]: https://www.scylladb.com/2019/06/20/sizing-up-your-scylla-cluster/?utm_source=chatgpt.com "Sizing Up Your ScyllaDB Cluster"
[4]: https://university.scylladb.com/courses/scylla-operations/lessons/configuration-and-where-to-run-scylla/topic/configuration-and-where-to-run-scylla-hardware-storage-cores-and-number-of-nodes/?utm_source=chatgpt.

com "ScyllaDB Deployment Best Practices: Hardware, Storage, Cores and ..."
[5]: https://docs.scylladb.com/manual/stable/architecture/architecture-fault-tolerance.html?utm_source=chatgpt.com "ScyllaDB Architecture - Fault Tolerance"
[6]: https://enterprise.docs.scylladb.com/stable/architecture/console-CL-full-demo.html?utm_source=chatgpt.com "Consistency Level Console Demo | ScyllaDB Docs"
[7]: https://university.scylladb.com/courses/scylla-essentials-overview/lessons/high-availability/topic/consistency-level/?utm_source=chatgpt.com "Consistency Level - ScyllaDB University"
[8]: https://docs.scylladb.com/manual/stable/cql/compaction.html?utm_source=chatgpt.com "Compaction | ScyllaDB Docs"
[9]: https://enterprise.docs.scylladb.com/stable/architecture/compaction/compaction-strategies.html?utm_source=chatgpt.com "Choose a Compaction Strategy | ScyllaDB Docs"
[10]: https://forum.scylladb.com/t/compaction-strategy-best-for-deletion-of-a-large-number-of-records/2161/2?utm_source=chatgpt.com "Compaction strategy best for deletion of a large number of records"
[11]: https://github.com/scylladb/scylla-migrator?utm_source=chatgpt.com "scylladb/scylla-migrator - GitHub"
[12]: https://enterprise.docs.scylladb.com/stable/kb/scylla-and-spark-integration.html?utm_source=chatgpt.com "Scylla and Spark integration | ScyllaDB Docs"
[13]: https://github.com/scylladb/spark-scylladb-connector?utm_source=chatgpt.com "DataStax Spark Cassandra Connector (not official spark ... - GitHub"
[14]: https://cassandra.link/post/scylla-docs-apache-cassandra-to-scylla-migration-process/?utm_source=chatgpt.com "Scylla Docs - Apache Cassandra to Scylla Migration Process"
[15]: https://cassandra.apache.org/doc/latest/cassandra/managing/operating/bulk_loading.html?utm_source=chatgpt.com "Bulk Loading | Apache Cassandra Documentation"
[16]: https://medium.com/expedia-group-tech/inside-expedias-migration-to-scylladb-for-change-data-capture-706365c8e2cf?utm_source=chatgpt.com "Inside Expedia's Migration to ScyllaDB for Change Data Capture"

Вот отличные и актуальные ресурсы, где можно углубиться в изучение ScyllaDB — от официальной документации и курсов до примеров, блогов и видео.

---

## Официальная документация и руководства

### 1. ScyllaDB Documentation (официальное руководство)

Полное руководство с разделами:

* «Getting Started», «Install», «Migrate to ScyllaDB», «Data Modeling», «Administration», и многое другое для разработки и эксплуатации.
* Отдельный раздел «Migrating from Cassandra», миграционные инструменты и best practices. ([docs.scylladb.com][1])

### 2. ScyllaDB Cloud Documentation

Специализированный материал по управляемому облачному сервису ScyllaDB Cloud, включая Quick Start и деплоймент в AWS/GCP/Azure. ([cloud.docs.scylladb.com][2])

---

## Краткий список ссылок:

| Ресурс                           | Что предлагает                                                                     |
| -------------------------------- | ---------------------------------------------------------------------------------- |
| ScyllaDB Documentation       | Официальное руководство и справочник ([docs.scylladb.com][1])                      |
| ScyllaDB Cloud Docs          | Для работы с облачной версией ScyllaDB ([cloud.docs.scylladb.com][2])              |
| ScyllaDB University          | Структурированные курсы с лабораториями и сертификатами ([ScyllaDB University][3]) |
| Tutorials & Example Projects | Практические приложения и примеры кода ([docs.scylladb.com][4])                    |
| Learn to Use ScyllaDB        | Форумы, вебинары, блог и другие материалы ([docs.scylladb.com][5])                 |
| YouTube: Quick Start         | Краткое введение для начинающих (6 мин) ([YouTube][6])                             |
| YouTube: NoSQL & ScyllaDB    | Основа и советы по использованию NoSQL и ScyllaDB ([YouTube][7])                   |
| ScyllaDB Video Library       | Демонстрации, архитектура, производительность ([resources.scylladb.com][8])        |
| Wikipedia (ScyllaDB page)    | История, арх-ка, факты, производительность ([Википедия][9])                        |

---

[1]: https://docs.scylladb.com/manual/stable/?utm_source=chatgpt.com "ScyllaDB Docs"

[2]: https://cloud.docs.scylladb.com/?utm_source=chatgpt.com "ScyllaDB Cloud Documentation | ScyllaDB Docs"
[3]: https://university.scylladb.com/?utm_source=chatgpt.com "ScyllaDB University | NoSQL Courses"
[4]: https://docs.scylladb.com/stable/get-started/develop-with-scylladb/tutorials-example-projects.html?utm_source=chatgpt.com "Tutorials and Example Projects | ScyllaDB Docs"
[5]: https://docs.scylladb.com/stable/get-started/learn-resources/?utm_source=chatgpt.com "Learn to Use ScyllaDB"
[6]: https://www.youtube.com/watch?v=cOlyquVuFJU&utm_source=chatgpt.com "What is ScyllaDB? A Quick Start Guide for Begineers #1 - YouTube"
[7]: https://www.youtube.com/watch?v=SOWdQNwFnSQ&utm_source=chatgpt.com "Getting Started with NoSQL, Using ScyllaDB [English] - YouTube"
[8]: https://resources.scylladb.com/videos?utm_source=chatgpt.com "Videos (YouTube) - ScyllaDB"
[9]: https://en.wikipedia.org/wiki/ScyllaDB?utm_source=chatgpt.com "ScyllaDB"
