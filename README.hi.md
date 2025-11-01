**English** | [简体中文](README-zh.md) | [日本語](README-ja.md) | [うちなーぐच](README-ryu.md) | [Русский](README-ru.md) | [Беларуская](README-be.md) | [Українська](README-uk.md) | [हिन्दी](README.hi.md)

<div align="center">
  <img width="300" src="./assets/icon/logo.png" alt="Miru 看板娘"/>
</div>

<h1 align="center">Miru ऐप</h1>

<p align="center">एक फ्री और ओपन-सोर्स ऐप जो Android, Windows और Web पर वीडियो, कॉमिक्स और नॉवेल चला सकता है।</p>

<div align="center">

[![GitHub release (with filter)](https://img.shields.io/github/v/release/miru-project/miru-app)](https://github.com/miru-project/miru-app/releases/latest)
[![License](https://img.shields.io/github/license/miru-project/miru-app)](https://github.com/miru-project/miru-app/blob/main/LICENSE)
[![Stars](https://img.shields.io/github/stars/miru-project/miru-app)](https://github.com/miru-project/miru-app/stargazers)
[![GitHub all releases](https://img.shields.io/github/downloads/miru-project/miru-app/total)](https://github.com/miru-project/miru-app/releases/latest)

</div>

![screenshot](assets/screenshot/screenshot.webp)

## फ़ीचर्स

- `windows` और `android` दोनों पर चलता है।
- एक्सटेंशन लिखने में आसान, डीबग लॉग के साथ।
- एक्सटेंशन JavaScript में लिखे जाते हैं, इसलिए डेवलपमेंट आसान है।
- आप खुद की एक्सटेंशन रिपॉजिटरी (repository) भी इस्तेमाल कर सकते हैं।
- हमारी तरफ से एक रिपॉजिटरी है जिससे आप सीधे वीडियो सोर्स इस्तेमाल कर सकते हैं, बिना कोई एक्सटेंशन लिखे।
- एक ही जगह पर कई सोर्स से वीडियो, कॉमिक्स और नॉवेल ऑनलाइन देखें।
- सभी डिवाइस पर एक जैसा, सिंपल डिज़ाइन।
- TMDB से जानकारी (जैसे पोस्टर, रेटिंग) अपने आप ले लेता है।
- AniList ट्रैकिंग को सपोर्ट करता है।
- प्रॉक्सी सर्वर (HTTP, SOCKS4, SOCKS5) को सपोर्ट करता है।

## अभी क्या बाकी है? (Todo)

- [x] BT टोरेंट
- [x] बेहतर डीबगिंग टूल्स
- [ ] डेटा सिंक (Data sync)
- [ ] सबटाइटल अपने आप खोजना

## इंस्टॉल कैसे करें

आप [Release](https://github.com/miru-project/miru-app/releases/latest) पेज से लेटेस्ट वर्शन डाउनलोड कर सकते हैं, या नीचे दिए गए तरीके से खुद बिल्ड कर सकते हैं।

## बिल्ड कैसे करें

### Flutter इंस्टॉल करें

इसके लिए [Flutter की ऑफिशियल साइट](https://flutter.dev/docs/get-started/install) देखें।

### Dependencies इंस्टॉल करें

```bash
flutter pub get
```
रन करें

```Bash

flutter run
```
अपने प्लेटफॉर्म के लिए बिल्ड करें

Android
```Bash

flutter build apk
```
Windows
```Bash

flutter build windows
```
## Linux के बारे में

अभी, Linux पर कुछ दिक्कतों (dependency problems) की वजह से quickjs नहीं चल पाता, इसलिए यह सपोर्टेड नहीं है।

## योगदान (Contribution)

आप किसी भी तरह से योगदान दे सकते हैं, जैसे:

- सुझाव देना

- बग (Bug) बताना

- कोड में मदद करना

- डॉक्यूमेंट लिखना

## दूसरे लिंक्स

Telegram: https://t.me/MiruChat
