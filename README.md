# lazyblock

Генератор и список фильтров [uBlock Origin](https://github.com/gorhill/uBlock),
устойчивых к редизайну и обфускациям.

## Как импортировать

Должно быть предустановлено браузерное расширение — блокировщик рекламы
[uBlock Origin](https://addons.mozilla.org/addon/ublock-origin/).

В настройках uBlock Origin во вкладке «Filter lists» нужно в самом низу нажать
на «Import...» и вставить туда следующий URL:
```
https://github.com/sunvis0r/lazyblock/releases/latest/download/cosmetic_filters.txt
```

Нажмите на синюю кнопку «Apply changes» и дождитесь, как на экране появится
«☑️ lazyblock».

Готово! Фильтры импортированы.

### Не работает?

Убедитесь, что опция «Parse and enforce cosmetic filters» вверху вкладки
«Filter lists» включена.

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
