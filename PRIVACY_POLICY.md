# プライバシーポリシー / Privacy Policy

**アプリ名**: あしむけれん (Respectful Direction Tracker)
**最終更新日**: 2025-10-20
**提供者**: Takaomi Yonejima

---

## 1. はじめに

本プライバシーポリシーは、「あしむけれん」アプリ（以下「本アプリ」）における個人情報の取り扱いについて説明するものです。本アプリをご利用いただく際は、本ポリシーに同意いただいたものとみなします。

---

## 2. 収集する情報

本アプリは、以下の情報を収集します：

### 2.1 位置情報（GPS座標）
- **目的**: ユーザーの現在位置から登録された人物の方角を計算するため
- **取得方法**: デバイスのGPSセンサーを使用
- **精度**: 高精度（ACCESS_FINE_LOCATION）
- **使用頻度**: アプリ使用中のみ（バックグラウンドでは収集しません）

### 2.2 センサーデータ
- **磁気センサー（コンパス）**: デバイスの向きを検出するため
- **加速度センサー**: デバイスが水平かどうかを判定するため
- **使用頻度**: コンパス画面使用時のみ

### 2.3 ユーザー入力データ
- **登録された人物の名前**: ユーザーが入力
- **登録された人物の住所**: ユーザーが入力
- **住所の地理座標（緯度・経度）**: Google Geocoding APIを使用して住所から自動変換

---

## 3. 情報の保存場所

### 3.1 ローカルストレージ
- すべてのデータは **デバイス内のローカルデータベース（SQLite）** に保存されます
- **外部サーバーへの送信は一切行いません**
- データはアプリをアンインストールすると完全に削除されます

### 3.2 クラウドバックアップ
- iOSの「iCloud バックアップ」またはAndroidの「Google ドライブ バックアップ」が有効な場合、アプリデータがバックアップに含まれる可能性があります
- これらのバックアップは各プラットフォームのプライバシーポリシーに従います

---

## 4. 情報の利用目的

収集した情報は、以下の目的でのみ使用されます：

1. **方角計算機能**: ユーザーの現在位置と登録された人物の位置から、方向を計算し表示する
2. **地図表示機能**: Google Maps上に登録された人物の位置を表示する
3. **コンパス警告機能**: 登録された人物の方向を向いている場合に警告を表示する

**広告配信、マーケティング、第三者への販売には一切使用しません。**

---

## 5. 第三者サービスの利用

本アプリは、以下の第三者サービスを利用します：

### 5.1 Google Maps Platform
- **使用API**:
  - Google Maps SDK for Android/iOS（地図表示）
  - Google Geocoding API（住所→座標変換）
- **送信データ**:
  - ユーザーの現在位置（地図表示用）
  - 登録された住所（座標変換用）
- **プライバシーポリシー**: [Google Maps Platform Terms of Service](https://cloud.google.com/maps-platform/terms)
- **注意**: Google Maps APIは、利用状況を匿名で収集する場合があります

### 5.2 その他の第三者サービス
- 本アプリは、Google Maps以外の第三者サービスを使用していません
- 分析ツール（Google Analytics、Firebase等）は使用していません

---

## 6. 情報の共有

本アプリは、以下の場合を除き、ユーザーの情報を第三者と共有することはありません：

1. **法的要請**: 法律、規制、または法的手続きに基づく場合
2. **ユーザーの同意**: ユーザーが明示的に同意した場合

---

## 7. データセキュリティ

本アプリは、以下のセキュリティ対策を実施しています：

1. **ローカルストレージ**: データはデバイス内に暗号化されたSQLiteデータベースとして保存
2. **API制限**: Google Maps APIキーは、特定のアプリケーションIDおよび証明書フィンガープリントで制限
3. **コード難読化**: リリース版APK/IPAはProGuard/R8により難読化

---

## 8. ユーザーの権利

ユーザーには、以下の権利があります：

1. **アクセス権**: アプリ内で登録データを閲覧可能
2. **削除権**: アプリ内で登録データを削除可能
3. **完全削除権**: アプリをアンインストールすることで、すべてのデータを完全に削除可能

---

## 9. 子供のプライバシー

本アプリは、13歳未満の子供を対象としていません。13歳未満の子供から故意に個人情報を収集することはありません。

---

## 10. プライバシーポリシーの変更

本プライバシーポリシーは、必要に応じて更新されることがあります。変更があった場合は、本ページに最新版を掲載し、「最終更新日」を更新します。

---

## 11. お問い合わせ

本プライバシーポリシーに関するご質問やご不明な点がございましたら、以下の連絡先までお問い合わせください：

**サポートメールアドレス**: senzureba@gmail.com

---

## Privacy Policy (English)

**App Name**: Respectful Direction Tracker (あしむけれん)
**Last Updated**: 2025-10-20
**Developer**: [Your Name/Organization]

### 1. Introduction
This Privacy Policy explains how the "Respectful Direction Tracker" app (the "App") handles personal information.

### 2. Information We Collect
- **Location Data (GPS)**: Used to calculate directions to registered people
- **Sensor Data**: Compass (magnetometer) and accelerometer for orientation detection
- **User Input**: Names and addresses of registered people, converted to coordinates via Google Geocoding API

### 3. Data Storage
- All data is stored **locally on your device** in a SQLite database
- **No data is sent to external servers**
- Data is deleted when you uninstall the app

### 4. How We Use Information
- Calculate directions from your location to registered people
- Display locations on Google Maps
- Show warnings when pointing toward registered people
- **NOT used for advertising, marketing, or third-party sales**

### 5. Third-Party Services
- **Google Maps Platform**: Used for maps and geocoding (see [Google Maps Privacy Policy](https://cloud.google.com/maps-platform/terms))
- No analytics tools (e.g., Google Analytics, Firebase) are used

### 6. Data Sharing
We do not share your information with third parties except:
- When required by law
- With your explicit consent

### 7. Data Security
- Local encrypted SQLite database
- API keys restricted by app ID and certificate fingerprint
- Code obfuscation (ProGuard/R8) in release builds

### 8. Your Rights
- View your data in the app
- Delete your data in the app
- Completely remove all data by uninstalling the app

### 9. Children's Privacy
The App is not intended for children under 13. We do not knowingly collect personal information from children under 13.

### 10. Changes to This Policy
We may update this Privacy Policy from time to time. Changes will be posted on this page with an updated "Last Updated" date.

### 11. Contact Us
For questions about this Privacy Policy, please contact:

**Support Email**: [Your Support Email]
**Contact**: [Your Contact Information]

---

**Generated for App Store and Google Play Store compliance.**
