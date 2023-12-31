[简体中文](README-zh.md) | [日本語](README-ja.md) | [うちなーぐち](README-ryu.md) | [English](README.md) | [Беларуская](README-be.md) | [Українська](README-uk.md)

<p align="center">
<img width="300" src="./assets/icon/logo.png" alt="Miru 看板娘"/>
</p>

<h1 align="center">
Miru App
</h1>

<p align="center">Бесплатное многофункциональное приложение с открытым исходным кодом, поддерживающее видео, комиксы и новеллы, благодаря расширениям. Работает на Android, Windows, Web.</p>

<h1 align="center">

[![GitHub release (with filter)](https://img.shields.io/github/v/release/miru-project/miru-app)](https://github.com/miru-project/miru-app/releases/latest)
[![License](https://img.shields.io/github/license/miru-project/miru-app)](https://github.com/miru-project/miru-app/blob/main/LICENSE)
[![Stars](https://img.shields.io/github/stars/miru-project/miru-app)](https://github.com/miru-project/miru-app/stargazers)
[![GitHub all releases](https://img.shields.io/github/downloads/miru-project/miru-app/total)](https://github.com/miru-project/miru-app/releases/latest)

</h1>

![screenshot](assets/screenshot/screenshot.webp)

## Особенности

- Поддержка `windows` и `android`
- Дружественная поддержка написания расширений, журнал отладки
- Для написания расширений используется язык JavaScript, что облегчает разработку
- Поддержка пользовательских репозиториев расширений
- Официальный репозиторий расширений предоставляет источники видео, которые можно использовать без написания каких-либо расширений
- Поддержка онлайн-просмотра нескольких источников видео, комиксов и новелл, реализуя унификацию нескольких платформ
- Унификация языка дизайна пользовательского интерфейса системы
- Автоматическое получение метаданных TMDB

## Список задач

- [x] BT торрент
- [ ] Улучшенные инструменты отладки
- [ ] Синхронизация данных
- [ ] Автоматический поиск субтитров

## Установка

Вы можете перейти в [Release](https://github.com/miru-project/miru-app/releases/latest) , чтобы скачать последнюю версию установочного пакета или собрать самостоятельно следующим методом

## Сборка

### Установка Flutter

Пожалуйста, обратитесь к [Flutter Official Documentation](https://flutter.dev/docs/get-started/install)

### Установка зависимостей

```bash
flutter pub get
```

### Запуск

```bash
flutter run
```

### Сборка под нужную платформу

Android

```bash
flutter build apk
```

Windows

```bash
flutter build windows
```

## Про Linux

В настоящее время Linux не может запустить quickjs из-за проблем с зависимостями, поэтому на данный момент он не поддерживается

## Участие в разработке

Участие в разработке любого рода приветствуется, включая, но не ограничиваясь:

- Внесение предложений
- Отчёт о найденных ошибках и недочётах
- Изменение кода
- Написание документации


## Дополнительные ссылки

Telegram: https://t.me/MiruChat

Telegram channel: https://t.me/MiruChannel
