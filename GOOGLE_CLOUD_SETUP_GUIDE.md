# Google Cloud Console API セキュリティ設定ガイド

**プロジェクト**: あしむけれん (Respectful Direction Tracker)
**セキュリティレイヤー**: Layer 2 - Google Cloud Console Restrictions（最重要）
**タスク**: T-D1.1.4 ～ T-D1.1.7

---

## 🎯 概要

このガイドでは、Google Maps APIキーを保護するための**最も重要なセキュリティ対策**であるGoogle Cloud Console上の制限設定を行います。

**なぜLayer 2が最重要なのか？**
- APIキーはAPK/IPAから抽出可能（避けられない現実）
- Google Cloud Console制限により、盗まれたAPIキーの悪用を防止
- Uber、Airbnbなど主要モバイルアプリと同じ業界標準の手法

---

## 📋 前提条件

- Google Cloud Consoleアカウント（すでにGoogle Maps APIキーを取得済み）
- アプリID:
  - **Android**: `jp.codesmith.ashimukeren`
  - **iOS**: `jp.codesmith.ashimukeren`

---

## ⚠️ 重要：Android/iOS別々のAPIキーを使用

### なぜ2つのAPIキーが必要か？

Google Cloud ConsoleのAPIキーは、**1つのプラットフォームにのみ制限できます**。

- ❌ 1つのAPIキーに「Androidアプリ」**と**「iOSアプリ」の制限を同時設定は**不可能**
- ✅ **解決策**: Android用とiOS用で**別々のAPIキー**を作成（推奨）

### APIキー構成

このガイドでは、**2つのAPIキー**を作成・設定します：

#### 1. APIキー（Android用）- 既存のキーを使用
- **APIキー**: `[既存のAndroid用APIキー]` (例: AIzaSyA...)
- **制限**: Androidアプリのみ
- **パッケージ名**: `jp.codesmith.ashimukeren`
- **SHA-1**: `[keytoolコマンドで取得したSHA-1フィンガープリント]`
- **使用API**: Maps SDK for Android, Geocoding API
- **設定ファイル**: `android/local.properties`

#### 2. APIキー（iOS用）- 新規作成が必要
- **APIキー**: `[新規作成したiOS用APIキー]` (例: AIzaSyB...)
- **制限**: iOSアプリのみ
- **バンドルID**: `jp.codesmith.ashimukeren`
- **使用API**: Maps SDK for iOS, Geocoding API
- **設定ファイル**: `ios/Flutter/Secrets.xcconfig`

### メリット
- ✅ **最高のセキュリティ**: 各プラットフォームで厳格に制限
- ✅ **独立管理**: Android/iOSで別々にクォータ・請求を管理可能
- ✅ **トラブルシューティングが容易**: どちらのプラットフォームで問題が起きているか分かりやすい

---

## タスク1: Google Maps API制限設定（T-D1.1.4）

### ステップ1: Google Cloud Consoleにログイン

1. https://console.cloud.google.com/ にアクセス
2. プロジェクトを選択（Google Maps APIを有効にしたプロジェクト）

### ステップ2: APIキーの設定ページに移動

1. 左側メニュー → **「APIとサービス」** → **「認証情報」**
2. 「認証情報」ページで、使用中のAPIキーをクリック
   - 名前: `Google Maps API Key` または類似の名前
   - キー文字列: `[あなたのAndroid用APIキー]` (AIzaSy...で始まる文字列)

### ステップ3: アプリケーションの制限を設定

**重要**: このセクションでAPIキーを特定のアプリに制限します。

#### Android制限

1. **「アプリケーションの制限」** セクションで **「Androidアプリ」** を選択
2. **「項目を追加」** をクリック
3. 以下を入力：
   - **パッケージ名**: `jp.codesmith.ashimukeren`
   - **SHA-1証明書フィンガープリント**: （次のタスクT-D1.1.5で取得）
4. **「完了」** をクリック

#### iOS制限（iOSアプリ公開時）

1. **「アプリケーションの制限」** セクションで **「iOSアプリ」** を選択（Androidと併用可能）
2. **「項目を追加」** をクリック
3. **バンドルID**: `jp.codesmith.ashimukeren` を入力
4. **「完了」** をクリック

**注意**: 現時点ではAndroidのみ設定し、iOS App Store公開時に追加してください。

### ステップ4: API制限を設定（最重要）

**重要**: 必要なAPIのみに制限します。これにより、APIキーが盗まれても他のサービスで悪用されません。

1. **「API の制限」** セクションで **「キーを制限」** を選択
2. **「APIを選択」** ドロップダウンから以下の **3つのみ** チェック：
   - ✅ **Maps SDK for Android**
   - ✅ **Maps SDK for iOS**
   - ✅ **Geocoding API**

3. **以下のAPIは明示的にチェックを外す**（セキュリティ上重要）：
   - ❌ **Places API** - 不使用
   - ❌ **Directions API** - 不使用
   - ❌ **Distance Matrix API** - 不使用
   - ❌ **Geolocation API** - 不使用
   - ❌ **Roads API** - 不使用
   - ❌ **Street View Static API** - 不使用
   - ❌ **Time Zone API** - 不使用
   - ❌ **Maps JavaScript API** - 不使用（Webアプリ用）
   - ❌ **Maps Static API** - 不使用
   - ❌ **Maps Embed API** - 不使用
   - ❌ **その他すべてのGoogle Maps Platform API** - 不使用

4. **「保存」** をクリック

**注意**:
- 「キーを制限しない」は絶対に選択しないでください
- 将来的に新しいAPIを追加する場合も、最小限の権限のみを付与してください

### ✅ 完了確認

- 「アプリケーションの制限」が「Androidアプリ」または「iOSアプリ」に設定されている
- 「API の制限」が「キーを制限」に設定され、3つのAPIのみ有効
- 画面上部に「APIキーが更新されました」と表示される

**結果**: 盗まれたAPIキーは、`jp.codesmith.ashimukeren`以外のアプリから使用不可能になります。

---

## タスク2: SHA-1証明書フィンガープリント登録（T-D1.1.5）

### ステップ1: Debug証明書のSHA-1を取得

開発・テスト用のSHA-1を取得します。

```bash
# macOS/Linux
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android | grep SHA1

# Windows
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" ^
  -alias androiddebugkey -storepass android -keypass android | findstr SHA1
```

**出力例**:
```
SHA1: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0
```

### ステップ2: Release証明書のSHA-1を取得

**注意**: リリース署名鍵（T-D2.1で作成）が必要です。Play Store公開前に実施してください。

```bash
# リリース鍵のSHA-1取得（パスワードが必要）
keytool -list -v -keystore ~/ashimukeren-release-key.jks \
  -alias ashimukeren -storepass <あなたのパスワード> | grep SHA1
```

**出力例**:
```
SHA1: Z9:Y8:X7:W6:V5:U4:T3:S2:R1:Q0:P9:O8:N7:M6:L5:K4:J3:I2:H1:G0
```

### ステップ3: Google Cloud ConsoleにSHA-1を登録

1. https://console.cloud.google.com/ → 「APIとサービス」 → 「認証情報」
2. 使用中のAPIキーをクリック
3. **「アプリケーションの制限」** セクション → **「Androidアプリ」**
4. すでに登録されている `jp.codesmith.ashimukeren` の **「編集」** をクリック
5. **「SHA-1証明書フィンガープリント」** フィールドに以下を追加：
   - Debug SHA-1: `A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0`（例）
   - Release SHA-1: `Z9:Y8:X7:W6:V5:U4:T3:S2:R1:Q0:P9:O8:N7:M6:L5:K4:J3:I2:H1:G0`（例）
6. **「完了」** をクリック
7. **「保存」** をクリック

### ✅ 完了確認

- Debug SHA-1とRelease SHA-1の両方が登録されている
- アプリは正しい証明書で署名されていないとAPIを使用できない

**結果**: 不正なアプリ（正しい証明書で署名されていない）はAPIキーを使用できません。

---

## タスク3: API使用量監視・請求アラート設定（T-D1.1.6）

### ステップ1: 請求先アカウントを確認

1. https://console.cloud.google.com/ → 左側メニュー → **「お支払い」**
2. プロジェクトに請求先アカウントがリンクされていることを確認
3. リンクされていない場合、新しい請求先アカウントを作成

### ステップ2: 予算とアラートを作成

1. **「お支払い」** メニュー → **「予算とアラート」**
2. **「予算を作成」** をクリック
3. 以下を入力：
   - **予算名**: `あしむけれん API Usage Budget`
   - **プロジェクト**: 現在のプロジェクトを選択
   - **予算額**: `5000 JPY/月`（約$50/月）
   - **アラートしきい値**:
     - 50%（2500円） → メール通知
     - 80%（4000円） → メール通知
     - 90%（4500円） → メール通知
     - 100%（5000円） → メール通知
4. **「通知チャネル」**:
   - メールアドレスを追加（あなたのメールアドレス）
   - 複数のメールアドレスを追加可能
5. **「完了」** をクリック

### ステップ3: メール通知の確認

1. 設定したメールアドレスに確認メールが届く
2. メール内のリンクをクリックして通知を有効化

### ✅ 完了確認

- 予算が作成され、4つのしきい値（50%, 80%, 90%, 100%）が設定されている
- メール通知が有効化されている

**結果**: API使用量が予算を超えると、メールで通知されます（不正使用の早期検出）。

---

## タスク4: APIクォータ制限設定（T-D1.1.7）

### ステップ1: APIクォータページに移動

1. https://console.cloud.google.com/ → 左側メニュー → **「APIとサービス」** → **「クォータ」**
2. または https://console.cloud.google.com/apis/api/maps-backend.googleapis.com/quotas

### ステップ2: Maps SDK for Androidのクォータを設定

1. **「サービス」** ドロップダウン → **「Maps SDK for Android」** を選択
2. **「クォータ」** リストから以下を探す：
   - `Map loads per day`（1日あたりの地図読み込み回数）
3. チェックボックスを選択 → **「割り当て量を編集」** をクリック
4. **「新しい割り当て量」**: `10000` リクエスト/日
5. **「保存」** をクリック

### ステップ3: Geocoding APIのクォータを設定

1. **「サービス」** ドロップダウン → **「Geocoding API」** を選択
2. **「クォータ」** リストから以下を探す：
   - `Requests per day`（1日あたりのリクエスト数）
3. チェックボックスを選択 → **「割り当て量を編集」** をクリック
4. **「新しい割り当て量」**: `1000` リクエスト/日
5. **「保存」** をクリック

### ステップ4: Maps SDK for iOSのクォータを設定（iOS公開時）

1. **「サービス」** ドロップダウン → **「Maps SDK for iOS」** を選択
2. 同様に `Map loads per day` を `10000` に設定

### ✅ 完了確認

- Maps SDK for Android: 10,000リクエスト/日
- Geocoding API: 1,000リクエスト/日
- Maps SDK for iOS: 10,000リクエスト/日（iOS公開時）

**結果**: クォータを超えるとAPIが停止し、悪用による高額請求を防止します。

---

## タスク5: iOS用APIキーの作成（T-D1.1.13）

### なぜ新しいAPIキーが必要か？

タスク1で設定した既存のAPIキーは**Android専用**です。iOSアプリ用には**別のAPIキー**が必要です。

### ステップ1: 新しいAPIキーを作成

1. https://console.cloud.google.com/ → **「APIとサービス」** → **「認証情報」**
2. **「認証情報を作成」** ボタンをクリック
3. **「APIキー」** を選択
4. 新しいAPIキーが生成される（例: `AIzaSyB...`）
5. APIキーをコピー（後で使用）

### ステップ2: iOS用の制限を設定

1. 生成されたAPIキーの **「キーを制限」** ボタンをクリック
2. **名前**: `Google Maps API Key (iOS)` と入力

3. **アプリケーションの制限**:
   - **「iOSアプリ」** を選択
   - **「項目を追加」** をクリック
   - **バンドルID**: `jp.codesmith.ashimukeren` を入力
   - **「完了」** をクリック

4. **API の制限** - 「キーを制限」を選択:
   - ✅ **Maps SDK for iOS**
   - ✅ **Geocoding API**
   - ❌ その他すべてのAPIは無効化

5. **「保存」** をクリック

### ステップ3: iOS設定ファイルに登録

1. ローカルマシンで `ios/Flutter/Secrets.xcconfig` を開く
2. 以下の行を修正：

**変更前**:
```
GOOGLE_MAPS_API_KEY=[既存のAndroid用APIキー]
```

**変更後**:
```
GOOGLE_MAPS_API_KEY=[新規作成したiOS用APIキー]
```

3. ファイルを保存

### ✅ 完了確認

- [ ] 新しいiOS用APIキーが作成された
- [ ] アプリケーションの制限が「iOSアプリ」に設定されている
- [ ] バンドルID `jp.codesmith.ashimukeren` が登録されている
- [ ] API制限が Maps SDK for iOS, Geocoding API のみに設定されている
- [ ] `ios/Flutter/Secrets.xcconfig` に新しいAPIキーが設定されている

**結果**: Android用とiOS用で別々のAPIキーが設定され、各プラットフォームで最高のセキュリティが実現されました。

---

## 🔐 セキュリティ完了チェックリスト

Phase D1の Layer 2 Security が完了したら、以下を確認してください：

### Google Cloud Console設定

- [ ] **T-D1.1.4**: Android用APIキーの制限設定
  - [ ] APIキー: `[あなたのAndroid用APIキー]`（Android専用）
  - [ ] アプリケーションの制限: Androidアプリ（`jp.codesmith.ashimukeren`）
  - [ ] API制限: Maps SDK for Android, Geocoding APIのみ有効

- [ ] **T-D1.1.13**: iOS用APIキーの作成・制限設定
  - [ ] 新しいAPIキーを作成（iOS専用）
  - [ ] アプリケーションの制限: iOSアプリ（`jp.codesmith.ashimukeren`）
  - [ ] API制限: Maps SDK for iOS, Geocoding APIのみ有効
  - [ ] `ios/Flutter/Secrets.xcconfig` に設定済み

- [ ] **T-D1.1.5**: SHA-1フィンガープリント
  - [ ] Debug SHA-1登録済み
  - [ ] Release SHA-1登録済み（Play Store公開前）

- [ ] **T-D1.1.6**: 請求アラート
  - [ ] 予算作成済み（5000円/月推奨）
  - [ ] アラートしきい値: 50%, 80%, 90%, 100%
  - [ ] メール通知有効化済み

- [ ] **T-D1.1.7**: クォータ制限
  - [ ] Maps SDK: 10,000リクエスト/日
  - [ ] Geocoding API: 1,000リクエスト/日

### 動作確認テスト

- [ ] **T-D1.1.9**: API制限の動作確認
  - [ ] アプリで地図表示が正常動作
  - [ ] 住所入力→位置情報取得が正常動作
  - [ ] 不正なアプリIDからのAPIアクセスが拒否される（テスト可能なら）

- [ ] **T-D1.1.10**: 環境変数設定のテスト
  - [ ] Debug APK/IPAでGoogle Maps動作
  - [ ] Release APK/IPAでGoogle Maps動作

- [ ] **T-D1.1.11**: flutter analyze
  - [ ] `flutter analyze` でセキュリティ警告なし

---

## 📞 トラブルシューティング

### 問題1: アプリで「API_KEY_INVALID」エラー

**原因**: API制限の設定ミス

**解決策**:
1. Google Cloud Consoleで「アプリケーションの制限」が正しいか確認
2. パッケージ名が `jp.codesmith.ashimukeren` になっているか確認
3. SHA-1が正しく登録されているか確認
4. API制限で必要なAPIが有効になっているか確認

### 問題2: 予算アラートが届かない

**原因**: メール通知が有効化されていない

**解決策**:
1. 「お支払い」→「予算とアラート」で予算を確認
2. 通知設定でメールアドレスが正しいか確認
3. メール確認リンクをクリックして通知を有効化

### 問題3: クォータ制限後にAPIが動作しない

**原因**: 1日のクォータ上限に達した

**解決策**:
1. 翌日（UTC午前0時）にクォータがリセットされるまで待つ
2. または、クォータを一時的に引き上げる（Google Cloud Consoleで編集）

---

## 📚 参考リンク

- [Google Maps Platform API Key Best Practices](https://developers.google.com/maps/api-security-best-practices)
- [Google Cloud Console](https://console.cloud.google.com/)
- [App Restrictions for API Keys](https://cloud.google.com/docs/authentication/api-keys#api_key_restrictions)

---

**完了日**: _______________________
**確認者**: _______________________

