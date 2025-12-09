# lazyblock

Список наиболее полезных фильтров [uBlock Origin](https://github.com/gorhill/uBlock).

## Использование

В настройках uBlock Origin во вкладке «Filter lists» нужно в самом низу нажать
на «Import...» и вставить туда следующий URL:
```
https://github.com/sunvis0r/lazyblock/releases/latest/download/cosmetic_filters.txt
```

(Убедитесь, что опция «Parse and enforce cosmetic filters» вверху данной вкладки
включена.)

Также, для оперативного обновления устаревших селекторов на исправленные,
включите параметр «Auto-update filter lists».

## Сборка

### Зависимости

Для использования генератора фильтров требуются следующие предустановленные
программы:
* [yq](https://github.com/mikefarah/yq) — парсер и процессор YAML
* [jq](https://github.com/jqlang/jq) — парсер и процессор JSON
Обе эти программы должны быть доступны в окружении (т.е. в переменной `PATH`).

### Добавление фильтров

Сайты можно добавлять как в существующий файл [data.yaml](./data/data.yaml),
так и создавать свои собственные YAML-файлы в диретории [data](./data).

### Запуск

Запустить генератор: [generate.cmd](./generate.cmd)

## Contributing

Ветки:
* `main` — стабильная ветка релизов.

Теги:
* `unstable` — последняя нестабильная сборка.
