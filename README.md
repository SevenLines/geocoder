imposm-geocoder-database
========================

База данных для геокодирования русских адресов. Использует данные [http://download.geofabrik.de/](http://download.geofabrik.de/)
Развернув данный образ и подключившись к базе данных можно геокодировать адреса следующим образом.

```sql
SELECT geocode('Иркутск Лермонтова 100');
```

Получаем в ответ:

```
{"id" : 69126, "lon" : 104.259006087003, "lat" : 52.2612147957904}
```

Установка
---------

Создайте файл docker-compose.yml на основе прикрепленного шаблона

```
cp docker-compose.yml.sample docker-compose.yml
```

Отредактируйте по необходимости:

```
version: "3.0"
services:
  geocoderdb:
    build: .
    ports:
      - "8432:5432" # проброс порта
    environment:
      - OSM_PBF_URL=http://download.geofabrik.de/europe/monaco-latest.osm.pbf  # файл данных
      - POSTGRES_PASSWORD=12345 # пароль для подключения
      - POSTGRES_DB=osm_data # название базы данных
```

В качестве url данных используйте url с сайта [http://download.geofabrik.de/](http://download.geofabrik.de/), формат фала **osm.pbf**.

запустите контейнер

```
docker-compose up
```

При первом запуске, будет скачен файл с данными, а также проведена первичная настройка базы данных. Для больших файлов данных может занять достаточно продолжительное время.

*for better experience use SSD*

Описание остальных файлов
-------------------------

* **initdb.sql** -- файл содержит запросы для первичной настройки базы данных. Включает в себя расчет геометрических центров областей, определение пренадлежности зданий тем или иным городам/селам/и т.п. Также добавляет функцию make_tsvector которую необходимо использовать при геокодировании (см. пример выше), построение индексов.
* **mapping.yaml** -- файл определяет mapping данных osm.pbf в БД postgres утилитой imposm3 (см. [https://imposm.org/docs/imposm3/latest/mapping.html](https://imposm.org/docs/imposm3/latest/mapping.html))
* **thesaurus_russian_osm.ths** -- сокращения часто используемы в адресах, используется postgres
* **setup_osm_database.sh** -- скрипт запускаемой при первичном запуске образа, включает в себя запуск, создание расширения для БД, скачивание файла данных и его конвертирование в базу postgres, запуск скрипта initdb.sql