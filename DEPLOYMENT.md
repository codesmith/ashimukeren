# Deployment Guide - あしむけれん

このドキュメントでは、「あしむけれん」アプリを各種アプリストアに公開する手順を説明します。

## 目次

- [前提条件](#前提条件)
- [Android (Google Play Store)](#android-google-play-store)
- [iOS (App Store)](#ios-app-store)
- [トラブルシューティング](#トラブルシューティング)
- [チェックリスト](#チェックリスト)

---

## 前提条件

### 必要なアカウント

- **Google Play Console アカウント**（Android用）
  - 初回登録料: $25（1回限り）
  - URL: https://play.google.com/console

- **Apple Developer Program**（iOS用）
  - 年会費: $99/年
  - URL: https://developer.apple.com/programs/

### 必要なツール

- Flutter SDK（3.5.4以上）
- Java Development Kit (JDK 8以上)
- Android Studio または Android SDK（Android用）
- Xcode（iOS用、macOSのみ）

### 法的要件

- **プライバシーポリシー** - 必須（位置情報を使用するため）
- **利用規約**（推奨）
- **サポート用メールアドレス** - 必須

---

## Android (Google Play Store)

### 📖 重要: APIキーセキュリティの理解（必読）

**このアプリのセキュリティ戦略**: パターンA - 直接埋め込み + API制限（業界標準80-90%）

#### ✅ 理解すべき現実

**Q: APIキーは完全に隠せますか？**
A: **いいえ、不可能です。**

- APIキーは**APK/IPAバイナリに埋め込まれます**（AndroidManifest.xml、Info.plist）
- デコンパイルすればAPIキーは見えます
- **これは避けられません**（すべてのモバイルアプリが同じ）

**Google公式の見解**:
> "クライアントデバイスは侵害されているものとして扱うべき。APIキーはバイナリコードのどこかに存在し、知識のある人から守ることは不可能。ただし、攻撃を難しくすることは可能。"

#### 🛡️ 3層防御戦略

このアプリは以下の3層で保護します：

**【第1層】開発時の保護** - Gitコミット防止
- 環境変数でAPIキーを管理（`android/local.properties`、`ios/Flutter/Secrets.xcconfig`）
- `.gitignore`で除外し、GitHubへの誤アップロードを防止
- **目的**: 運用ミス防止（セキュリティではなく、ベストプラクティス）

**【第2層】Google Cloud Console制限** ⭐ **最重要**
- **パッケージ名制限**: `jp.codesmith.ashimukeren` のみ許可
- **SHA-1証明書制限**: リリース鍵の指紋のみ許可
- **API制限**: Maps SDK + Geocoding API のみ許可
- **クォータ制限**: 1日10,000リクエストまで
- **請求アラート**: 月$50で通知

**→ 結果**: APIキーが盗まれても、**他のアプリから使えない**、**他のAPIでは使えない**、**大量悪用できない**

**【第3層】コード難読化**（Android）
- ProGuard/R8でAPKを難読化
- APIキーの発見を困難にする（完全ではない）

#### 💰 なぜバックエンドプロキシを使わないのか？

**代替案（Pattern B）**: モバイルアプリ → 自社サーバー → Google Maps API

**採用しない理由**:
- ✗ サーバー運用コスト（月$10-50+）
- ✗ レイテンシ増加（UX悪化）
- ✗ 実装・保守の複雑さ
- ✓ 銀行など超高セキュリティアプリ向け（10-20%のみ採用）

**結論**: 個人アプリには過剰。Pattern Aで十分。

#### ✅ 受け入れるトレードオフ

- ✅ **受容**: APIキーがAPKに埋め込まれる（避けられない）
- ✅ **緩和**: Google制限により、盗まれても実害なし
- ✅ **監視**: 使用量アラートで異常検知

**安心してください**: Uber、Airbnb、ほとんどの地図アプリが同じ方法です。

---

### ステップ1: アプリIDの変更

✅ **完了済み**: `jp.codesmith.ashimukeren`

現在のアプリIDは既に変更済みです。

**重要**: アプリIDは公開後に変更できません！慎重に選んでください。

#### 推奨形式

```
jp.yourname.ashimukeren
または
com.yourname.ashimukeren
または
dev.ashimukeren.app
```

**注意**:
- `com.example.*` は避ける（開発用）
- 他人のドメインは使わない
- ドメインの実際の所有は不要

#### 変更手順

1. **android/app/build.gradle** を編集:

```gradle
android {
    namespace = "jp.yourname.ashimukeren"  // 変更
    // ...
    defaultConfig {
        applicationId = "jp.yourname.ashimukeren"  // 変更
        // ...
    }
}
```

2. **Android Manifestの確認**:

`android/app/src/main/AndroidManifest.xml` に `package` 属性がある場合は、同じIDに変更します。

3. **動作確認**:

```bash
flutter clean
flutter pub get
flutter run -d <your-android-device>
```

---

### ステップ2: リリース用署名鍵の生成

アプリに署名するための鍵を作成します。

#### 鍵の生成

```bash
keytool -genkey -v -keystore ~/ashimukeren-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias ashimukeren
```

#### 入力項目

1. **キーストアパスワード**: 安全なパスワードを設定（例: 16文字以上）
2. **パスワード再入力**: 同じパスワード
3. **名前**: あなたの名前
4. **組織単位**: 空欄でOK（Enterキー）
5. **組織名**: 空欄でOK（Enterキー）
6. **市区町村**: 例: Tokyo
7. **都道府県**: 例: Tokyo
8. **国コード**: JP
9. **確認**: yes
10. **鍵パスワード**: Enterキー（キーストアと同じパスワード使用）

#### 重要: 鍵の保管

**絶対に失わないでください！**
- この鍵を失うと、アプリを更新できなくなります
- パスワードも必ず記録してください
- 安全な場所にバックアップしてください（USBドライブ、パスワード管理ツールなど）

```bash
# バックアップ例
cp ~/ashimukeren-release-key.jks ~/Dropbox/secure/
```

---

### ステップ3: 署名設定の追加

#### 3-1. key.properties ファイルの作成

`android/key.properties` を作成:

```properties
storePassword=<ステップ2で設定したパスワード>
keyPassword=<ステップ2で設定したパスワード>
keyAlias=ashimukeren
storeFile=/Users/yourname/ashimukeren-release-key.jks
```

**重要**: このファイルは **Gitにコミットしない** でください！

#### 3-2. .gitignore の確認

`android/.gitignore` に以下が含まれているか確認:

```
key.properties
*.jks
```

なければ追加してください。

#### 3-3. build.gradle の更新

`android/app/build.gradle` を以下のように編集:

```gradle
// ファイルの先頭に追加（plugins の前）
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

plugins {
    // ...
}

android {
    // ...

    // signingConfigs を buildTypes の前に追加
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            // 以下の行を変更
            signingConfig signingConfigs.release  // debug → release に変更
        }
    }
}
```

---

### ステップ4: アプリアイコンの準備

#### 現在のアイコンの確認

```bash
ls -la android/app/src/main/res/mipmap-*/
```

#### アイコンの要件

- **最低限**: 512x512px の高解像度アイコン
- **推奨**: 各解像度用のアイコンを用意
  - mipmap-mdpi: 48x48px
  - mipmap-hdpi: 72x72px
  - mipmap-xhdpi: 96x96px
  - mipmap-xxhdpi: 144x144px
  - mipmap-xxxhdpi: 192x192px

#### アイコン生成ツール（オプション）

オンラインツールを使うと便利です:
- https://icon.kitchen/
- https://romannurik.github.io/AndroidAssetStudio/

または Flutter パッケージ:

```yaml
# pubspec.yaml の dev_dependencies に追加
flutter_launcher_icons: ^0.13.1

# 設定を追加
flutter_icons:
  android: true
  image_path: "assets/icon/app_icon.png"
```

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

---

### ステップ5: リリースビルドの作成

#### 5-1. ビルド前の確認

```bash
# 静的解析
flutter analyze

# テスト実行（オプション）
flutter test
```

#### 5-2. AAB (Android App Bundle) のビルド

```bash
flutter build appbundle --release
```

#### 5-3. ビルド成果物の確認

```bash
ls -lh build/app/outputs/bundle/release/app-release.aab
```

ファイルサイズが表示されればOKです（通常 20-50MB程度）。

#### トラブルシューティング

**エラー: 署名設定が見つからない**
- `android/key.properties` が正しく作成されているか確認
- パスが正しいか確認（`storeFile` のパス）

**エラー: パスワードが間違っている**
- `key.properties` のパスワードを確認
- keytoolで生成時のパスワードと一致しているか確認

---

### ステップ6: プライバシーポリシーの作成

位置情報を使用するため、プライバシーポリシーが必須です。

#### 必須項目

1. **収集する情報**
   - 位置情報（現在地）
   - 登録した人の名前と住所
   - デバイスのセンサー情報（コンパス、加速度計）

2. **利用目的**
   - コンパス機能で方角を表示するため
   - 登録した人の方向を計算するため

3. **データの保存場所**
   - すべてデバイス内のローカルデータベースに保存
   - 外部サーバーへの送信は一切なし

4. **第三者提供**
   - なし（すべてローカル処理）

5. **連絡先**
   - サポート用メールアドレス

#### プライバシーポリシーの公開

以下のいずれかで公開が必要です：
- GitHub Pages
- 個人ブログ
- Google Sites（無料）
- その他Webホスティング

**例**: `https://yourname.github.io/ashimukeren/privacy-policy.html`

---

### ステップ7: Google Play Console でアプリ登録

#### 7-1. Play Console にアクセス

https://play.google.com/console

#### 7-2. 新しいアプリを作成

1. 「アプリを作成」をクリック
2. **アプリ名**: `あしむけれん`
3. **デフォルト言語**: 日本語
4. **アプリまたはゲーム**: アプリ
5. **無料または有料**: 無料
6. 宣言事項にチェック
7. 「アプリを作成」をクリック

#### 7-3. アプリのセットアップ

##### (1) アプリのアクセス権

- すべての機能が無料で利用可能
- 制限や特別なアクセス要件なし

##### (2) 広告

- このアプリに広告が含まれていますか？ → **いいえ**

##### (3) コンテンツレーティング

1. 「アンケートを開始」をクリック
2. **カテゴリ**: ユーティリティ・生産性
3. 質問に回答（暴力・性的コンテンツなし）
4. レーティングを取得

##### (4) ターゲットユーザーと配信

1. **ターゲット年齢**: 18歳以上（または全年齢）
2. **ストア掲載の詳細**: いいえ（子ども向けではない）
3. **地域**: 日本（または全世界）

##### (5) アプリのカテゴリ

- **カテゴリ**: ツール
- **タグ**: ライフスタイル、ナビゲーション

##### (6) 連絡先の詳細

- **メールアドレス**: サポート用メールアドレス
- **ウェブサイト**（オプション）: あれば記入
- **電話番号**（オプション）

##### (7) プライバシーポリシー

- **プライバシーポリシーのURL**: ステップ6で作成したURL

#### 7-4. ストア掲載情報

##### アプリ名とアイコン

- **アプリ名**: `あしむけれん`
- **簡単な説明**（80文字以内）:
  ```
  大切な人の方角を教えてくれるコンパスアプリ。足を向けて寝てはいけない方向をお知らせします。
  ```

- **詳しい説明**（4000文字以内）:
  ```
  ## あしむけれんとは？

  「あしむけれん」は、大切な人や尊敬する人の方角を教えてくれるコンパスアプリです。
  寝る時に足を向けてはいけない方向を視覚的に表示します。

  ## 主な機能

  ### 📝 人の登録
  - 大切な人の名前と住所を登録
  - 住所から自動で位置情報（緯度・経度）を取得
  - 登録した人の一覧表示と削除機能

  ### 🗺️ 地図表示
  - Google Mapで登録した人の位置を表示
  - 赤いピンで場所を視覚化
  - 地図のズーム・移動に対応

  ### 🧭 方向警告コンパス
  - スマホを水平に持つと、登録した人の方角を表示
  - 危険な方向（足を向けてはいけない方向）を向くと画面が赤色に
  - 安全な方向を向くと画面が緑色に
  - リアルタイムで方角を検出

  ## こんな方におすすめ

  - 親御さんやお世話になった恩師の方角を意識したい方
  - 日本の伝統的な礼儀を大切にしたい方
  - 寝る時の方角を気にされる方

  ## プライバシー

  すべてのデータは端末内に保存され、外部に送信されることはありません。

  ## 必要な権限

  - 位置情報: コンパス機能で現在地から方角を計算するため
  - センサー: コンパスと傾き検出のため
  ```

- **アプリアイコン**: 512x512px（PNG形式、32ビット）

##### スクリーンショット

**最低2枚、推奨4-8枚**

撮影例:
1. 登録一覧画面（人が登録されている状態）
2. 新規登録画面（入力フォーム）
3. 地図画面（赤いピンが表示されている状態）
4. コンパス画面（緑色 - 安全）
5. コンパス画面（赤色 - 警告）

要件:
- サイズ: 16:9または9:16のアスペクト比
- 最小幅: 320dp
- 最大幅: 3840dp
- 形式: PNG または JPEG

##### フィーチャーグラフィック

- サイズ: 1024x500px
- 形式: PNG または JPEG
- Play Storeのトップに表示される横長画像

#### 7-5. リリースの作成

##### (1) 本番リリース

1. 左メニュー「本番」をクリック
2. 「新しいリリースを作成」をクリック
3. AABファイルをアップロード:
   ```
   build/app/outputs/bundle/release/app-release.aab
   ```
4. **リリース名**: `1.0.0 (1)` または `初回リリース`
5. **リリースノート** (日本語):
   ```
   初回リリース

   - 大切な人の名前と住所を登録
   - Google Mapで登録した場所を表示
   - コンパスで方角を警告表示
   ```
6. 「確認」→「本番環境にロールアウト」

##### (2) 審査

- Google の審査（通常 1-3日）
- 承認されると Play Store に公開されます

---

### ステップ8: アップデート手順

アプリを更新する場合:

#### 1. バージョン番号の更新

`pubspec.yaml`:
```yaml
version: 1.0.1+2  # 1.0.0+1 から更新
```

- `1.0.1`: versionName（ユーザーに表示される）
- `+2`: versionCode（Androidの内部管理番号、必ず増加）

#### 2. ビルド

```bash
flutter build appbundle --release
```

#### 3. Play Console でアップロード

1. 「本番」→「新しいリリースを作成」
2. 新しいAABファイルをアップロード
3. リリースノートを記入
4. 「確認」→「本番環境にロールアウト」

---

## iOS (App Store)

**TODO**: iOS版の公開手順は今後追加予定

基本的な流れ:
1. Apple Developer Program への登録（$99/年）
2. App ID の作成
3. Provisioning Profile の設定
4. Xcode での署名設定
5. App Store Connect でアプリ登録
6. Archive ビルドの作成
7. TestFlight でテスト（オプション）
8. 審査提出

---

## トラブルシューティング

### ビルドエラー

#### エラー: "Execution failed for task ':app:signReleaseBundle'"

**原因**: 署名設定が正しくない

**解決策**:
1. `android/key.properties` の内容を確認
2. パスワードが正しいか確認
3. `storeFile` のパスが正しいか確認

```bash
# 鍵ファイルの存在確認
ls -la ~/ashimukeren-release-key.jks
```

#### エラー: "AAPT: error: resource android:attr/lStar not found"

**原因**: compileSdk のバージョンが古い

**解決策**: `android/app/build.gradle` を確認:
```gradle
android {
    compileSdk = 34  // 33以上に設定
}
```

### Play Console エラー

#### エラー: "パッケージ名が既に使用されています"

**原因**: 他の開発者が同じアプリIDを使用している

**解決策**: ステップ1でアプリIDを変更してください

#### エラー: "署名が一致しません"

**原因**: 以前と異なる鍵で署名している

**解決策**:
- 初回公開時: 問題なし、そのまま進める
- 更新時: 必ず同じ鍵を使用してください

### デバッグ方法

#### AABファイルの内容確認

```bash
# bundletool をインストール
brew install bundletool

# AABの内容確認
bundletool dump manifest --bundle=build/app/outputs/bundle/release/app-release.aab

# APKとして抽出（テスト用）
bundletool build-apks \
  --bundle=build/app/outputs/bundle/release/app-release.aab \
  --output=test.apks \
  --mode=universal

# APKをインストール
unzip test.apks -d test_apk
adb install test_apk/universal.apk
```

---

## チェックリスト

### 公開前チェックリスト

#### コード品質
- [ ] `flutter analyze` でエラーなし
- [ ] `flutter test` が通る（オプション）
- [ ] 実機でテスト済み（Android実機）

#### 設定
- [ ] アプリIDを `com.example.*` から変更済み
- [ ] バージョン番号が正しい（pubspec.yaml）
- [ ] 署名鍵を作成済み
- [ ] `android/key.properties` を作成済み
- [ ] `android/key.properties` を .gitignore に追加済み
- [ ] アプリアイコンが設定済み

#### セキュリティ（Phase 9 - API Security）⭐ 重要

**Layer 1: Source Control Protection**
- [ ] `android/local.properties` を作成（GOOGLE_MAPS_API_KEY設定）
- [ ] `ios/Flutter/Secrets.xcconfig` を作成（GOOGLE_MAPS_API_KEY設定）
- [ ] `.gitignore` にシークレットファイルを追加
- [ ] `git status` でシークレットファイルが追跡されていないことを確認

**Layer 2: Google Cloud Console Restrictions** ⭐ 最重要
- [ ] **Application Restrictions**を設定
  - [ ] Android: パッケージ名 `jp.codesmith.ashimukeren`
  - [ ] iOS: バンドルID `jp.codesmith.ashimukeren`
- [ ] **SHA-1証明書フィンガープリント**を登録
  - [ ] Debug証明書のSHA-1を追加（開発用）
  - [ ] Release証明書のSHA-1を追加（本番用）
- [ ] **API Restrictions**を設定
  - [ ] Maps SDK for Android のみ許可
  - [ ] Maps SDK for iOS のみ許可
  - [ ] Geocoding API のみ許可
  - [ ] 「キーを制限しない」は選択しない
- [ ] **Quota Limits**を設定
  - [ ] Maps SDK: 10,000 requests/day
  - [ ] Geocoding API: 1,000 requests/day
- [ ] **Billing Alerts**を設定
  - [ ] 予算: $50/month
  - [ ] アラート閾値: 50%, 80%, 90%, 100%
  - [ ] 通知メールアドレス設定

**Layer 3: Code Obfuscation**
- [ ] ProGuard/R8設定を有効化（android/app/build.gradle）
- [ ] proguard-rules.pro を設定（Flutter + Google Maps用）
- [ ] リリースビルドでテスト: `flutter build apk --release`

**Security Verification**
- [ ] 制限されたAPIキーでアプリが正常動作することを確認
- [ ] 不正なパッケージ名からAPIキーが使えないことを確認（オプション）
- [ ] リリースAPKをデコンパイルしてもAPIキーが難読化されていることを確認（オプション）

#### ストア掲載
- [ ] プライバシーポリシーを公開済み
- [ ] アプリ名（あしむけれん）
- [ ] 簡単な説明（80文字以内）
- [ ] 詳しい説明
- [ ] スクリーンショット（最低2枚）
- [ ] フィーチャーグラフィック（1024x500px）
- [ ] アプリアイコン（512x512px）
- [ ] サポート用メールアドレス

#### ビルド
- [ ] AABファイルの作成成功
- [ ] ファイルサイズが妥当（通常50MB以下）

#### Play Console
- [ ] アプリの作成完了
- [ ] アプリのアクセス権設定
- [ ] コンテンツレーティング取得
- [ ] ターゲットユーザー設定
- [ ] ストア掲載情報の入力
- [ ] AABファイルのアップロード
- [ ] リリースノートの記入

### アップデート時チェックリスト

- [ ] バージョン番号を更新（versionCode必ず+1）
- [ ] 変更内容をリリースノートに記載
- [ ] `flutter analyze` でエラーなし
- [ ] 新機能を実機でテスト
- [ ] 同じ署名鍵を使用

---

## 参考リンク

### 公式ドキュメント

- [Flutter: Build and release an Android app](https://docs.flutter.dev/deployment/android)
- [Google Play Console](https://play.google.com/console)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)

### ツール

- [Icon Kitchen](https://icon.kitchen/) - アイコン生成
- [App Privacy Policy Generator](https://app-privacy-policy-generator.nisrulz.com/) - プライバシーポリシー生成

---

**最終更新**: 2025-10-19
**対象バージョン**: 1.0.0+1
