## OpenMapTiles [![Build Status](https://travis-ci.org/openmaptiles/openmaptiles.svg?branch=master)](https://travis-ci.org/openmaptiles/openmaptiles)

OpenMapTiles is an extensible and open tile schema based on the OpenStreetMap. It is used to generate vector tiles for online zoomable maps. The project is about creating a beautiful basemaps with general layers that contain topographic information. More information [openmaptiles.org](http://openmaptiles.org/) and [openmaptiles.com](http://openmaptiles.com/).

We encourage you to collaborate, reuse and adapt existing layers and add your own layers or use our approach for your own vector tile project. Feel free to fork the repo and experiment. The repository is built on top of the [openmaptiles/openmaptiles-tools](https://github.com/openmaptiles/openmaptiles-tools) to simplify vector tile creation.

- :link: Discuss at the #openmaptiles channel at [OSM Slack](https://osmus-slack.herokuapp.com/)
- :link: Docs https://openmaptiles.org/docs
- :link: Schema https://openmaptiles.org/schema
- :link: Production package: https://openmaptiles.com/production-package/
- :link: Hosting https://www.maptiler.com/cloud/
- :link: Create own layer https://github.com/openmaptiles/skiing

## Styles

You can start from several GL styles supporting the OpenMapTiles vector schema.

:link: [Learn how to create Mapbox GL styles with Maputnik and OpenMapTiles](http://openmaptiles.org/docs/style/maputnik/).


- [OSM Bright](https://github.com/openmaptiles/osm-bright-gl-style)
- [Positron](https://github.com/openmaptiles/positron-gl-style)
- [Dark Matter](https://github.com/openmaptiles/dark-matter-gl-style)
- [Klokantech Basic](https://github.com/openmaptiles/klokantech-basic-gl-style)
- [Klokantech 3D](https://github.com/openmaptiles/klokantech-3d-gl-style)
- [Fiord Color](https://github.com/openmaptiles/fiord-color-gl-style)
- [Toner](https://github.com/openmaptiles/toner-gl-style)

We also ported over our favorite old raster styles (TM2).

:link: [Learn how to create TM2 styles with Mapbox Studio Classic and OpenMapTiles](http://openmaptiles.org/docs/style/mapbox-studio-classic/).

- [Light](https://github.com/openmaptiles/mapbox-studio-light.tm2/)
- [Dark](https://github.com/openmaptiles/mapbox-studio-dark.tm2/)
- [OSM Bright](https://github.com/openmaptiles/mapbox-studio-osm-bright.tm2/)
- [Pencil](https://github.com/openmaptiles/mapbox-studio-pencil.tm2/)
- [Woodcut](https://github.com/openmaptiles/mapbox-studio-woodcut.tm2/)
- [Pirates](https://github.com/openmaptiles/mapbox-studio-pirates.tm2/)
- [Wheatpaste](https://github.com/openmaptiles/mapbox-studio-wheatpaste.tm2/)

## Schema

OpenMapTiles consists out of a collection of documented and self contained layers you can modify and adapt.
Together the layers make up the OpenMapTiles tileset.

:link: [Study the vector tile schema](http://openmaptiles.org/schema)

- [aeroway](https://openmaptiles.org/schema/#aeroway)
- [boundary](https://openmaptiles.org/schema/#boundary)
- [building](https://openmaptiles.org/schema/#building)
- [housenumber](https://openmaptiles.org/schema/#housenumber)
- [landcover](https://openmaptiles.org/schema/#landcover)
- [landuse](https://openmaptiles.org/schema/#landuse)
- [mountain_peak](https://openmaptiles.org/schema/#mountain_peak)
- [park](https://openmaptiles.org/schema/#park)
- [place](https://openmaptiles.org/schema/#place)
- [poi](https://openmaptiles.org/schema/#poi)
- [transportation](https://openmaptiles.org/schema/#transportation)
- [transportation_name](https://openmaptiles.org/schema/#transportation_name)
- [water](https://openmaptiles.org/schema/#water)
- [water_name](https://openmaptiles.org/schema/#water_name)
- [waterway](https://openmaptiles.org/schema/#waterway)

## Develop

To work on OpenMapTiles you need Docker.

- Install [Docker](https://docs.docker.com/engine/installation/). Minimum version is 1.12.3+.
- Install [Docker Compose](https://docs.docker.com/compose/install/). Minimum version is 1.7.1+.

### Build

Build the tileset.

```bash
git clone git@github.com:openmaptiles/openmaptiles.git
cd openmaptiles
# Build the imposm mapping, the tm2source project and collect all SQL scripts
make
```

You can execute the following manual steps (for better understanding)
or use the provided `quickstart.sh` script.

```
./quickstart.sh
```

### Prepare the Database

Now start up the database container.

```bash
docker-compose up -d postgres
```

Import external data from [OpenStreetMapData](http://openstreetmapdata.com/), [Natural Earth](http://www.naturalearthdata.com/) and  [OpenStreetMap Lake Labels](https://github.com/lukasmartinelli/osm-lakelines).

```bash
docker-compose run import-water
docker-compose run import-natural-earth
docker-compose run import-lakelines
docker-compose run import-osmborder
```

[Download OpenStreetMap data extracts](http://download.geofabrik.de/) and store the PBF file in the `./data` directory.

```bash
cd data
wget http://download.geofabrik.de/europe/albania-latest.osm.pbf
```

[Import OpenStreetMap data](https://github.com/openmaptiles/import-osm) with the mapping rules from
`build/mapping.yaml` (which has been created by `make`).

```bash
docker-compose run import-osm
```

### Work on Layers

Each time you modify layer SQL code run `make` and `make import-sql`.

```
make clean && make && make import-sql
```

Now you are ready to **generate the vector tiles**. Using environment variables
you can limit the bounding box and zoom levels of what you want to generate (`docker-compose.yml`).

```
docker-compose run generate-vectortiles
```

## Cлияние mbtiles

### Сборка Docker Image
```
cd merge-mbtiles
docker build -t merge-mbtiles .
```

### Запуск процесса слияния mbtiles

Перед запуском необходимо разместить файлы *.mbtiles в текущем каталоге (например,```/data```).
При запуске docker необходимо заменить ```[path/to/mbtiles]``` на путь к файлам и передать его в качестве значений переменных среды 
```SRC_MBTILES``` и ```DST_MBTILES```.

```
mkdir data
cd data
docker run --rm -v $(pwd)/data:/data -e SRC_MBTILES="/data/source" -e DST_MBTILES="/data/dest" merge-mbtiles
```

Таким образом, в результате работы скрипта файл ```DST_MBTILES``` будет включать в себя данные ```SRC_MBTILES```.

### Запуск TileServer GL с пользовательской конфигурацией стилей


Сервер запускается в Docker с указанием имени файла конфигурации в качестве атрибута (например, ```config.json```)

```
docker run --rm -it -v $(pwd):/data -p 8080:80 klokantech/tileserver-gl -c config.json
```

### Файл конфигурации

Описание формата файла конфигурации:
https://github.com/klokantech/tileserver-gl/blob/master/docs/config.rst
---
В файле конфигурации необходимо указать корректные пути к корневому каталогу, шрифтам, стилям и картам.

Пример:
```
"paths": {
    "root": "/data",
    "fonts": "fonts",
    "styles": "styles",
    "mbtiles": "mbtiles"
}
```
---
Пример применения нового стиля (Dark Matter):

Обратите внимание, что стили карт для использования с TileServer GL загружаются из ветки ```gh-pages```.

Перейти в каталог, указанный для атрибута ```styles``` и выполнить:
```
git clone -b gh-pages https://github.com/openmaptiles/dark-matter-gl-style.git
cd dark-matter-gl-style
```

Убедиться в наличии файла ```style-local.json```. Также в каталоге могут опционально располагаться файлы спрайтов, необходимые для отображения стиля (sprite*.json и sprite*.png).
Далее добавить в ```config.json``` идентификатор("dark-matter"), путь к файлу стилей и границы отображения .

Пример:
```
"styles": {
    "dark-matter": {
          "style": "dark-matter-gl-style/style-local.json",
          "tilejson": {
            "bounds": [-180,-85.0511,180,85.0511]
          }
     }
}
```
---

Добавление шрифтов для использования с TileServer GL происходит аналогично добавлению стилей.

В рабочем каталоге выполнить:
```
git clone -b gh-pages https://github.com/openmaptiles/fonts.git
mv fonts/* [path/to/fonts/]
```
где ```[path/to/fonts/]``` - путь к шрифтам, используемый с Tileserver GL.


---
Для отображения карты на сервере необходимо указать путь к файлу mbtiles в атрибуте ```data```:
```
"data": {
    "v3": {
      "mbtiles": "russia.mbtiles"
    }
}
```

## Further Steps

To customize your own tileset and styles see the [customization](CUSTOMIZATION.md).

## License

All code in this repository is under the [BSD license](./LICENSE.md) and the cartography decisions encoded in the schema and SQL are licensed under [CC-BY](./LICENSE.md).

Products or services using maps derived from OpenMapTiles schema need to visibly credit "OpenMapTiles.org" or reference "OpenMapTiles" with a link to http://openmaptiles.org/. Exceptions to attribution requirement can be granted on request.

For a browsable electronic map based on OpenMapTiles and OpenStreetMap data, the
credit should appear in the corner of the map. For example:

[© OpenMapTiles](http://openmaptiles.org/) [© OpenStreetMap contributors](http://www.openstreetmap.org/copyright)

For printed and static maps a similar attribution should be made in a textual
description near the image, in the same fashion as if you cite a photograph.
