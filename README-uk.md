[简体中文](README-zh.md) | [日本語](README-ja.md) | [うちなーぐち](README-ryu.md) | [English](README.md) | [Беларуская](README-be.md) | [Русский](README-ru.md)

<p align="center">
<img width="300" src="./assets/icon/logo.png" alt="Miru 看板娘"/>
</p>

<h1 align="center">
Miru App
</h1>

<p align="center">Безкоштовна багатофункціональна програма з відкритим вихідним кодом, що підтримує відео, комікси та новели, завдяки розширенням. Працює на Android, Windows, Web.</p>

<h1 align="center">

[![GitHub release (with filter)](https://img.shields.io/github/v/release/miru-project/miru-app)](https://github.com/miru-project/miru-app/releases/latest)
[![License](https://img.shields.io/github/license/miru-project/miru-app)](https://github.com/miru-project/miru-app/blob/main/LICENSE)
[![Stars](https://img.shields.io/github/stars/miru-project/miru-app)](https://github.com/miru-project/miru-app/stargazers)
[![GitHub all releases](https://img.shields.io/github/downloads/miru-project/miru-app/total)](https://github.com/miru-project/miru-app/releases/latest)

</h1>

![screenshot](assets/screenshot/screenshot.webp)

## Особливості

- Підтримка `windows` та `android`
- Дружня підтримка написання розширень, журнал налагодження
- Для написання розширень використовується мова JavaScript, що полегшує розробку
- Підтримка користувальницьких репозиторіїв розширень
- Офіційний репозиторій розширень надає джерела відео, які можна використовувати без написання будь-яких розширень
- Підтримка онлайн-перегляду кількох джерел відео, коміксів та новел, реалізуючи уніфікацію кількох платформ
- Уніфікація мови дизайну користувача інтерфейсу системи
- Автоматичне отримання метаданих TMDB

## Список завдань

- [x] BT торент
- [ ] Покращені інструменти налагодження
- [ ] Синхронізація даних
- [ ] Автоматичний пошук субтитрів

## Встановлення

Ви можете перейти до [Release](https://github.com/miru-project/miru-app/releases/latest) , щоб завантажити останню версію інсталяційного пакета або зібрати самостійно наступним методом

## Збірка

### Встановлення Flutter

Будь ласка, зверніться до [Flutter Official Documentation](https://flutter.dev/docs/get-started/install)

### Встановлення залежностей

```bash
flutter pub get
```

### Запуск

```bash
flutter run
```

### Збірка під потрібну платформу

Android

```bash
flutter build apk
```

Windows

```bash
flutter build windows
```

## Про Linux

В даний час Linux не може запустити quickjs через проблеми із залежностями, тому на даний момент він не підтримується


## Участь у розробці

Участь у розробці будь-якого роду вітається, включаючи, але не обмежуючись:

- Внесення пропозицій
- Звіт про знайдені помилки та недоліки
- Зміна коду
- Написання документації


## Додаткові посилання

Telegram: https://t.me/MiruChat

Telegram channel: https://t.me/MiruChannel
