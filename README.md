# Xizmat Mobile

Приложение маркетплейса услуг, написанное на Flutter. В проекте используется `Provider` для управления состоянием и собственные API-сервисы для взаимодействия с бэкендом.

## Архитектура

```
lib/
  providers/     провайдеры состояния (auth, favorites, services)
  screens/       экраны приложения
  services/      работа с API и хранилищем
  utils/         вспомогательные утилиты
  widgets/       переиспользуемые виджеты
```

- **screens/** содержит модули по функциональности: авторизация, поиск, услуги, объявления и т.д.
- **services/api** делится на файлы с методами для каждого раздела API.
- **widgets/filters** – отдельные компоненты для фильтрации контента.

## Ключевые компоненты

- `universal_search_screen.dart` – единый экран поиска услуг и объявлений.
- `universal_item_card.dart` – универсальная карточка элемента в выдаче.
- `favorites_provider.dart` и `favorites_screen.dart` – управление избранным и его отображение.
- `universal_filter_bottom_sheet.dart` и связанные секции фильтров.

## Реализованный функционал

- Авторизация (тестовый номер 0000/пароль 0000).
- Добавление услуг и объявлений (списание монет при продвижении).
- Поиск объявлений и поиск специалистов.
- Избранное и отзывы на услуги и объявления.
- Покупка контактов за монеты.

## Известные проблемы и TODO

- Некоторые экраны ещё содержат заглушки или требуют доработки.
- В каталоге `assets/icons` нет файлов – строка подключения удалена из `pubspec.yaml`.
- Большие экраны постепенно выносятся на отдельные виджеты для упрощения поддержки.

## Запуск

```bash
flutter pub get
flutter run
```

MVP уже работает, но проект продолжает активно развиваться.
