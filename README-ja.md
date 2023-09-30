[简体中文](README-zh.md) | [English](README.md) | [うちなーぐち](README-ryu.md) | [Русский](README-ru.md) | [Беларуская](README-be.md) | [Українська](README-uk.md)

<p align="center">
<img width="300" src="./assets/icon/logo.png" alt="Miru 看板娘"/>
</p>

<h1 align="center">
Miru App
</h1>

<p align="center">動画、漫画、小説の拡張ソースをサポートし、Android、Windows、Webに対応した無料のオープンソースの多機能アプリケーション。</p>

<h1 align="center">

[![GitHub release (with filter)](https://img.shields.io/github/v/release/miru-project/miru-app)](https://github.com/miru-project/miru-app/releases/latest)
[![License](https://img.shields.io/github/license/miru-project/miru-app)](https://github.com/miru-project/miru-app/blob/main/LICENSE)
[![Stars](https://img.shields.io/github/stars/miru-project/miru-app)](https://github.com/miru-project/miru-app/stargazers)
[![GitHub all releases](https://img.shields.io/github/downloads/miru-project/miru-app/total)](https://github.com/miru-project/miru-app/releases/latest)

</h1>

![screenshot](assets/screenshot/screenshot.webp)

## 特徴

- `windows`と`android`をサポート
- フレンドリーな拡張機能の作成をサポート、デバッグログ
- 拡張機能はJavaScriptを使用しており、開発が簡単です
- カスタム拡張リポジトリのサポート
- 公式の拡張機能リポジトリがビデオフィードを提供しているので、それを使うために拡張機能を書く必要はありません
- 動画、漫画、小説などの複数ソースのストリーミングをサポートし、複数プラットフォームの統合を実現
- システムUIのデザイン言語を統一
- TMDBメタデータ情報を自動的に取得

## Todo

- [x] BTトレント
- [ ] より良いデバッグツール
- [ ] データの同期
- [ ] 字幕の自動検索

## インストール

そのためには、[ここから](https://github.com/miru-project/miru-app/releases/latest)最新版のインストールパッケージをダウンロードするか、以下の方法でご自身でビルドしてください 

## 構築

### Flutterをインストールする

こちらを参照 [Flutter公式ドキュメント](https://flutter.dev/docs/get-started/install)

### 依存関係をインストールする

```bash
flutter pub get
```

### 動かす

```bash
flutter run
```

### パック

Android

```bash
flutter build apk
```

Windows

```bash
flutter build windows
```

## Linuxについて

現時点ではLinuxでは依存関係の問題によりquickjsを起動できないため、当面の間サポート対象外となります。


## 貢献

以下を含む、あらゆる種類の貢献を歓迎します。

- 提案
- バグやフィードバック
- コード
- 文書作成


## コミュニケーション

Telegram：https://t.me/MiruChat

Telegramチャンネル：https://t.me/MiruChannel
