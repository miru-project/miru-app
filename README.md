[简体中文](README-zh.md) | [日本語](README-ja.md) | [うちなーぐち](README-ryu.md) | [Русский](README-ru.md) | [Беларуская](README-be.md) | [Українська](README-uk.md)

<p align="center">
<img width="300" src="./assets/icon/logo.png" alt="Miru 看板娘"/>
</p>

<h1 align="center">
Miru App
</h1>

<p align="center">Free and open source Multi-functional application that supports video, comics, novels extended source for Android, Windows, Web.</p>

<h1 align="center">

[![GitHub release (with filter)](https://img.shields.io/github/v/release/miru-project/miru-app)](https://github.com/miru-project/miru-app/releases/latest)
[![License](https://img.shields.io/github/license/miru-project/miru-app)](https://github.com/miru-project/miru-app/blob/main/LICENSE)
[![Stars](https://img.shields.io/github/stars/miru-project/miru-app)](https://github.com/miru-project/miru-app/stargazers)
[![GitHub all releases](https://img.shields.io/github/downloads/miru-project/miru-app/total)](https://github.com/miru-project/miru-app/releases/latest)

</h1>

![screenshot](assets/screenshot/screenshot.webp)

## Features

- Support for `windows`,`android`
- Friendly extension writing support, debug log
- The extension uses the JavaScript language, and the development is simple
- Support for a custom extension repository
- The official extension repository provides video sources, which can be used without writing any extensions
- Support online viewing of multiple sources of videos, comics, and novels, realizing the unification of multiple platforms
- Unify the design language of the system UI
- Automatically fetch TMDB metadata information
- Support for AniList tracking
- Support for Proxy Server Protocols (HTTP, SOCKS4, SOCKS5)

## Todo

- [x] BT torrent
- [x] Better debugging tools
- [ ] Data synchronization
- [ ] Automatically search for subtitles

## Installing

You can go to [Release](https://github.com/miru-project/miru-app/releases/latest) to download the latest version of the installation package from the page, or build it yourself by the following method 

## Building

### Install Flutter

Please refer to the [Flutter Official Documentation](https://flutter.dev/docs/get-started/install).

### Install dependencies

```bash
flutter pub get
```

### Run

```bash
flutter run
```

### Build for the right platform

Android

```bash
flutter build apk
```

Windows

```bash
flutter build windows
```

## About Linux

At present, Linux cannot start quickjs due to dependency problems, so it is not supported for the time being


## Contribution

Contributions of any kind are welcome, including but not limited to:

- make a suggestion
- bug feedback
- code contribution
- document writing


## Additional links

Telegram: https://t.me/MiruChat

Telegram channel: https://t.me/MiruChannel
