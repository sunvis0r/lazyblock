# lazyblock

Генератор косметических фильтров для [uBlock Origin](https://github.com/gorhill/uBlock).

## Зависимости

Для запуска требуются следующие предустановленные программы:
* [yq](https://github.com/mikefarah/yq) — парсер и процессор YAML
* [jq](https://github.com/jqlang/jq) — парсер и процессор JSON

## Добавление сайтов

Сайты можно добавлять как в существующий файл [data.yaml](./data/data.yaml),
так и создавать свои собственные YAML-файлы в дирнетории [data](./data).

## Запуск

Запустить генератор: [generate.cmd](./generate.cmd)
