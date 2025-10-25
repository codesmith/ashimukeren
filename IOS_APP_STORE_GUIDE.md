# iOS App Store公開ガイド

**プロジェクト**: あしむけれん (Respectful Direction Tracker)
**Phase**: D3 - iOS App Store Release
**目的**: Apple App Storeへのアプリ公開

---

## 🎯 概要

このガイドでは、FlutterアプリをiOS App Storeに公開するための全手順を解説します。Apple Developer Programへの登録からApp Store Connectでの審査提出までをカバーします。

---

## 📋 前提条件

### 必須要件

- [ ] **Mac（macOS）**: Xcodeが動作する環境
- [ ] **Xcode**: 最新版インストール済み（App Storeからダウンロード）
- [ ] **Apple ID**: 有効なApple IDアカウント
- [ ] **クレジットカード**: Apple Developer Program登録用（$99/年）
- [ ] **Phase D1完了**: プライバシーポリシー、アイコン、アプリ名設定済み

### プロジェクト情報

- **アプリ名**: あしむけれん
- **Bundle ID**: `jp.codesmith.ashimukeren`
- **バージョン**: 1.0.0
- **ビルド番号**: 1

---

## Phase D3.1: Apple Developer Setup

### タスク1: Apple Developer Program 登録（T-D3.1.1）

#### ステップ1: Apple Developer Programに申し込む

1. https://developer.apple.com/programs/ にアクセス
2. **「Enroll」** ボタンをクリック
3. Apple IDでサインイン（または新規作成）
4. 登録タイプを選択：
   - **Individual（個人）**: 個人開発者（推奨）
   - **Organization（組織）**: 法人・団体
5. 個人情報を入力：
   - 氏名（英語表記）
   - 住所（英語表記）
   - 電話番号
6. 利用規約に同意
7. **年会費 $99（約14,000円）** の支払い
   - クレジットカード決済
   - 日本円で約14,000円（為替レートにより変動）
8. 登録完了メールを待つ（通常24-48時間以内）

#### ステップ2: Apple Developer Portal アクセス確認

1. https://developer.apple.com/account/ にアクセス
2. **「Certificates, Identifiers & Profiles」** が表示されることを確認
3. Apple Developer Program登録完了

**⏱️ 所要時間**: 登録申請: 15分、承認待ち: 24-48時間

---

### タスク2: App ID 作成（T-D3.1.2）

#### ステップ1: Apple Developer Portalで App ID 作成

1. https://developer.apple.com/account/ にアクセス
2. **「Certificates, Identifiers & Profiles」** をクリック
3. 左側メニュー → **「Identifiers」** をクリック
4. 右上の **「+」** ボタンをクリック
5. **「App IDs」** を選択 → **「Continue」**
6. **「App」** を選択 → **「Continue」**
7. 以下を入力：
   - **Description**: `Respectful Direction Tracker`
   - **Bundle ID**: `jp.codesmith.ashimukeren` （Explicitを選択）
   - **Capabilities**: 以下をチェック
     - ✅ **Associated Domains**（オプション）
     - ✅ **Maps**（Google Maps使用のため）
8. **「Continue」** → **「Register」**

#### ステップ2: 確認

- https://developer.apple.com/account/resources/identifiers/list で `jp.codesmith.ashimukeren` が表示される

**⏱️ 所要時間**: 5分

---

## Phase D3.2: Provisioning & Signing

### タスク3: Distribution Certificate 作成（T-D3.2.1）

#### ステップ1: Xcodeで証明書を作成

1. Xcode起動
2. メニューバー → **Xcode** → **Settings...** (または **Preferences**)
3. **「Accounts」** タブをクリック
4. 左下の **「+」** ボタン → **「Add Apple ID...」**
5. Apple IDとパスワードを入力してサインイン
6. Apple IDを選択 → 右側の **「Manage Certificates...」** をクリック
7. 左下の **「+」** ボタン → **「Apple Distribution」** を選択
8. 証明書が作成される（自動的にキーチェーンに保存）
9. **「Done」** をクリック

#### ステップ2: 証明書の確認

1. Apple Developer Portal: https://developer.apple.com/account/resources/certificates/list
2. **「Apple Distribution」** 証明書が表示される（有効期限: 1年）

**⏱️ 所要時間**: 3分

---

### タスク4: Provisioning Profile 作成（T-D3.2.2）

#### ステップ1: App Store用 Provisioning Profile 作成

1. https://developer.apple.com/account/resources/profiles/list にアクセス
2. 右上の **「+」** ボタンをクリック
3. **「App Store」** を選択 → **「Continue」**
4. **App ID**: `jp.codesmith.ashimukeren` を選択 → **「Continue」**
5. **Certificate**: 先ほど作成した **Apple Distribution** 証明書を選択 → **「Continue」**
6. **Provisioning Profile Name**: `Ashimukeren App Store` と入力
7. **「Generate」** をクリック
8. **「Download」** をクリックしてダウンロード
9. ダウンロードしたファイル（`.mobileprovision`）をダブルクリックしてインストール

#### ステップ2: 確認

- Xcodeで自動的にProvisioning Profileが認識される

**⏱️ 所要時間**: 5分

---

### タスク5: Xcode署名設定（T-D3.2.3）

#### ステップ1: Xcodeプロジェクトを開く

```bash
cd /Users/beishima/StudioProjects/ashimukeren
open ios/Runner.xcworkspace
```

**注意**: `Runner.xcodeproj` ではなく **`Runner.xcworkspace`** を開いてください（CocoaPods使用のため）。

#### ステップ2: Signing & Capabilities設定

1. 左側のプロジェクトナビゲーターで **「Runner」** プロジェクトをクリック
2. 中央の **「TARGETS」** セクションで **「Runner」** を選択
3. **「Signing & Capabilities」** タブをクリック
4. 以下を設定：

   **Debug（デバッグ用）**:
   - ✅ **Automatically manage signing** をチェック
   - **Team**: Apple Developer Programのチームを選択
   - **Bundle Identifier**: `jp.codesmith.ashimukeren` （自動入力される）
   - **Provisioning Profile**: Development（自動選択）

   **Release（リリース用）**:
   - ✅ **Automatically manage signing** をチェック（推奨）
   - **Team**: Apple Developer Programのチームを選択
   - **Bundle Identifier**: `jp.codesmith.ashimukeren` （自動入力される）
   - **Provisioning Profile**: App Store（自動選択）

5. エラーがないことを確認（紫色の警告が表示されない）

#### ステップ3: Info.plist確認

1. 左側のプロジェクトナビゲーターで **「Runner」** → **「Info.plist」** を開く
2. 以下を確認：
   - **CFBundleDisplayName**: `あしむけれん`
   - **CFBundleIdentifier**: `$(PRODUCT_BUNDLE_IDENTIFIER)`
   - **CFBundleShortVersionString**: `$(FLUTTER_BUILD_NAME)` → 1.0.0
   - **CFBundleVersion**: `$(FLUTTER_BUILD_NUMBER)` → 1

**⏱️ 所要時間**: 10分

---

## Phase D3.3: Archive Build

### タスク6: Archive ビルド作成（T-D3.3.1）

#### ステップ1: ビルド前の準備

```bash
cd /Users/beishima/StudioProjects/ashimukeren

# 1. Flutter依存関係を更新
flutter pub get

# 2. Podを更新（iOS依存関係）
cd ios
pod install
cd ..

# 3. Flutterクリーンビルド
flutter clean
```

#### ステップ2: Xcodeで Archive ビルド

1. Xcodeで `ios/Runner.xcworkspace` を開く
2. 上部のツールバーで以下を確認：
   - **スキーム**: **Runner** を選択
   - **デバイス**: **Any iOS Device (arm64)** を選択（シミュレータではなく実機デバイス）
3. メニューバー → **Product** → **Clean Build Folder** (Option + Shift + Command + K)
4. メニューバー → **Product** → **Archive** (Command + B ではなく Archive)
5. ビルド開始（5-15分）
   - 初回は時間がかかる場合があります
   - ビルドログで進行状況を確認

#### ステップ3: Archive 成功確認

1. ビルド完了後、**Organizer** ウィンドウが自動的に開く
2. 左側メニュー → **Archives** タブ
3. **Runner** の下に日付・時刻付きでArchiveが表示される
4. Archiveをクリックして詳細を確認：
   - **Version**: 1.0.0
   - **Build**: 1
   - **Size**: 約40-60 MB

#### トラブルシューティング

**問題1: "Signing for "Runner" requires a development team"**
- **解決**: Signing & Capabilitiesで Team を選択

**問題2: "No profiles for 'jp.codesmith.ashimukeren' were found"**
- **解決**: Apple Developer PortalでProvisioning Profileを作成してダウンロード

**問題3: ビルドエラー（CocoaPods関連）**
```bash
cd ios
pod deintegrate
pod install
cd ..
# 再度 Archive
```

**⏱️ 所要時間**: 15-30分

---

### タスク7: App Store Connect アップロード（T-D3.3.2）

#### ステップ1: Organizerから配布

1. Xcodeの **Organizer** ウィンドウで作成したArchiveを選択
2. 右側の **「Distribute App」** ボタンをクリック
3. 配布方法を選択：
   - ✅ **「App Store Connect」** を選択 → **「Next」**
4. アップロードオプション:
   - ✅ **「Upload」** を選択 → **「Next」**
5. App Store Connect 配布オプション:
   - ✅ **「Automatically manage signing」**（推奨）
   - ✅ **「Upload your app's symbols to receive symbolicated reports from Apple」**
   - **「Next」**
6. 署名証明書の再確認:
   - Xcodeが自動的に適切な証明書を選択
   - **「Next」**
7. Review content:
   - アプリ情報を確認
   - **「Upload」** をクリック
8. アップロード進行状況（5-20分）
   - 進行状況バーが表示される
9. アップロード完了:
   - **「Done」** をクリック

#### ステップ2: App Store Connect で処理完了を待つ

1. https://appstoreconnect.apple.com/ にアクセス
2. **「My Apps」** をクリック（後で作成）
3. アップロードしたビルドが処理中と表示される（10-30分）
4. メール通知を待つ:
   - 件名: **"Your app has been processed"**
   - ビルドがApp Store Connectで利用可能になる

**⏱️ 所要時間**: アップロード: 10-20分、処理: 10-30分

---

## Phase D3.4: App Store Connect Setup

### タスク8: App Store Connect でアプリ作成（T-D3.4.1）

#### ステップ1: App Store Connectにサインイン

1. https://appstoreconnect.apple.com/ にアクセス
2. Apple IDでサインイン（Apple Developer Programのアカウント）

#### ステップ2: 新しいアプリを作成

1. **「My Apps」** をクリック
2. 左上の **「+」** ボタン → **「New App」** をクリック
3. 以下を入力：

   - **Platforms**: ✅ **iOS** のみチェック
   - **Name**: `あしむけれん`
   - **Primary Language**: **Japanese (Japan) - 日本語（日本）**
   - **Bundle ID**: `jp.codesmith.ashimukeren` を選択（ドロップダウン）
   - **SKU**: `ashimukeren-001` （任意の一意な識別子、変更不可）
   - **User Access**: **Full Access**（デフォルト）

4. **「Create」** をクリック

#### ステップ3: アプリ作成完了

- App Store Connectで「あしむけれん」アプリが作成される
- 次にストア掲載情報を入力

**⏱️ 所要時間**: 5分

---

### タスク9: ストア掲載情報入力（T-D3.4.2）

#### ステップ1: App Information（アプリ情報）

1. App Store Connectで「あしむけれん」を開く
2. 左側メニュー → **「App Information」**
3. 以下を入力：

   **General Information**:
   - **Name**: `あしむけれん` （自動入力済み）
   - **Subtitle**: `足を向けられない人の方角を確認` （30文字以内）
   - **Category**: **Utilities**（ユーティリティ）
   - **Secondary Category**: **Lifestyle**（オプション）

   **Privacy**:
   - **Privacy Policy URL**: （Phase D1で作成したプライバシーポリシーのURL）
     - 例: `https://yourname.github.io/ashimukeren/privacy`

4. **「Save」** をクリック

---

#### ステップ2: Pricing and Availability（価格と配信状況）

1. 左側メニュー → **「Pricing and Availability」**
2. 以下を設定：

   **Price**:
   - **Price**: **Free（無料）**

   **Availability**:
   - **All Countries and Regions** を選択（または特定の国を選択）
   - 日本のみ配信する場合: **Japan** のみチェック

3. **「Save」** をクリック

---

#### ステップ3: App Privacy（アプリのプライバシー）

1. 左側メニュー → **「App Privacy」**
2. **「Get Started」** をクリック
3. **Data Collection**（データ収集）に回答：

   **質問1: Does your app collect data?**
   - **Yes** を選択

4. **「Next」** をクリック

5. **Data Types**（収集データの種類）を追加：

   **Location（位置情報）**:
   - **「+」** → **Location** → **「Precise Location」** を選択
   - **Usage**: **App Functionality**（アプリ機能のため）
   - **Linked to User**: **No**（ユーザーに紐づかない）
   - **Used for Tracking**: **No**（トラッキングに使用しない）
   - **「Next」** → **「Save」**

   **User Content（ユーザーコンテンツ）**:
   - **「+」** → **User Content** → **「Other User Content」** を選択
   - **Usage**: **App Functionality**（名前・住所登録のため）
   - **Linked to User**: **No**
   - **Used for Tracking**: **No**
   - **「Next」** → **「Save」**

6. **「Publish」** をクリック

---

#### ステップ4: Version Information（バージョン情報）

1. 左側メニュー → **「iOS App」** → **「1.0 Prepare for Submission」**
2. 以下を入力：

   **Screenshots**（スクリーンショット）:
   - **iPhone 6.7" Display**（iPhone 16 Plus用、必須）:
     - 最低1枚、最大10枚
     - サイズ: 1320 x 2868 px（縦向き）
     - 推奨: 5枚（登録一覧、新規登録、地図、コンパス緑、コンパス赤）
   - ドラッグ&ドロップでアップロード

   **Promotional Text**（プロモーションテキスト、オプション）:
   - 170文字以内
   - 例: 「敬意を払うべき人の方角を確認し、失礼のない方向で休むことができます。」

   **Description**（説明文、必須）:
   - 4000文字以内
   - 以下のテンプレートを使用：

```
「あしむけれん」は、敬意を払うべき人の方角を確認し、失礼のない方向で休むためのアプリです。

【主な機能】
・登録機能: 敬意を払うべき人の名前と住所を登録
・地図表示: Google Maps上で登録した人の位置を確認
・コンパス機能: 方角をリアルタイムで確認し、警告を表示

【使い方】
1. 敬意を払うべき人の名前と住所を登録します
2. 地図画面で位置を確認できます
3. コンパス画面でスマホを水平に持ち、方角を確認します
4. 登録した人の方向を向くと、画面が赤くなり警告が表示されます
5. 安全な方向では画面が緑色になります

【プライバシー】
・すべてのデータはデバイス内にのみ保存されます
・外部サーバーへのデータ送信は一切行いません
・位置情報はアプリ使用中のみ取得します

【対応デバイス】
・iPhone（iOS 15以上推奨）
・コンパス機能: 実機のみ対応（シミュレータでは動作しません）
```

   **Keywords**（キーワード、必須）:
   - 100文字以内、カンマ区切り
   - 例: `コンパス,方角,敬意,方向,位置情報,地図,マナー`

   **Support URL**（サポートURL、必須）:
   - プライバシーポリシーと同じURLでも可
   - 例: `https://yourname.github.io/ashimukeren/support`

   **Marketing URL**（マーケティングURL、オプション）:
   - 空白でも可

3. **「Save」** をクリック

---

#### ステップ5: Build（ビルド選択）

1. **「Build」** セクションで **「+ Select a build before you submit your app」** をクリック
2. App Store Connectで処理完了したビルド（1.0.0 (1)）を選択
3. **「Done」** をクリック

---

#### ステップ6: General App Information（一般アプリ情報）

1. **「General App Information」** セクション:

   - **App Icon**: 自動的に表示される（ビルドから）
   - **Version**: 1.0.0（自動入力）
   - **Copyright**: `© 2025 [あなたの名前]`
   - **Routing App Coverage File**: 不要（スキップ）

2. **「Save」** をクリック

---

#### ステップ7: App Review Information（App Review情報）

1. **「App Review Information」** セクション:

   - **Sign-in required**: **No**（ログイン不要）
   - **Contact Information**:
     - **First Name**: [あなたの名]
     - **Last Name**: [あなたの姓]
     - **Phone Number**: [あなたの電話番号]
     - **Email Address**: [あなたのメールアドレス]
   - **Notes**（審査員向けメモ、オプション）:

```
このアプリは位置情報とコンパスセンサーを使用します。
コンパス機能を確認するには、実機デバイスを水平に持ってください。

テスト手順:
1. 新規登録画面で名前と住所を入力（例: 東京都渋谷区渋谷1-1-1）
2. 地図画面で赤いピンを確認
3. コンパス画面でデバイスを水平に持つ
4. デバイスの向きを変えて、色の変化（赤/緑）を確認
```

2. **「Save」** をクリック

---

#### ステップ8: Version Release（バージョンリリース）

1. **「Version Release」** セクション:
   - **Automatically release this version**: 審査承認後に自動公開
   - または **Manually release this version**: 手動で公開タイミングを選択

2. **「Save」** をクリック

**⏱️ 所要時間**: 30-60分

---

## Phase D3.5: Submission

### タスク10: 審査提出（T-D3.5.1）

#### ステップ1: 最終確認

1. App Store Connectで「あしむけれん」の **「1.0 Prepare for Submission」** ページを開く
2. すべてのセクションにチェックマーク（✓）が表示されていることを確認：
   - ✅ Screenshots
   - ✅ Description
   - ✅ Keywords
   - ✅ Support URL
   - ✅ Build
   - ✅ App Review Information
   - ✅ Version Release
   - ✅ App Privacy

#### ステップ2: 審査に提出

1. 右上の **「Add for Review」** ボタンをクリック
2. Export Compliance（輸出コンプライアンス）に回答：

   **質問: Does your app use encryption?**
   - **No**（暗号化を使用しない）
     - HTTPS通信（Google Maps API）は該当しない

3. **「Submit」** ボタンをクリック
4. 確認ダイアログ → **「Submit」**

#### ステップ3: 審査待ち

1. ステータスが **「Waiting for Review」** に変わる
2. メール通知が届く:
   - 件名: **"Your submission was received"**
3. 審査開始後:
   - ステータス: **「In Review」**
   - 審査期間: 通常1-7日（平均24-48時間）
4. 審査結果メール:
   - **承認**: **"Your app status is Ready for Sale"**
   - **拒否**: **"Your app status is Rejected"**（修正が必要）

#### ステップ4: 公開完了（承認後）

1. 審査承認後、自動的に（または手動で）App Storeに公開
2. App Storeで「あしむけれん」が検索可能になる（数時間後）
3. App Store URL:
   - https://apps.apple.com/app/id[App ID番号]
   - App Store Connectで確認可能

**⏱️ 所要時間**: 審査: 1-7日

---

## 🎉 完了！

### iOS App Store公開完了チェックリスト

- [ ] D3.1.1: Apple Developer Program 登録完了（$99/年）
- [ ] D3.1.2: App ID 作成完了（`jp.codesmith.ashimukeren`）
- [ ] D3.2.1: Distribution Certificate 作成完了
- [ ] D3.2.2: Provisioning Profile 作成完了
- [ ] D3.2.3: Xcode署名設定完了
- [ ] D3.3.1: Archive ビルド作成完了
- [ ] D3.3.2: App Store Connect アップロード完了
- [ ] D3.4.1: App Store Connect アプリ作成完了
- [ ] D3.4.2: ストア掲載情報入力完了（スクリーンショット5枚、説明文、プライバシー）
- [ ] D3.5.1: 審査提出完了 → 審査承認待ち

### 公開後の運用

**D4.1: バージョン管理**:
- バグ修正・機能追加時: `pubspec.yaml` の version を更新（例: 1.0.1+2）
- 再度 Archive → アップロード → 審査提出

**D4.2: ユーザーレビュー対応**:
- App Store Connectでレビューを確認
- ポジティブなレビューには感謝、ネガティブなレビューには誠実に対応

**D4.3: クラッシュレポート確認**:
- App Store Connect → Analytics → Crashes
- クラッシュログを確認して修正

**D4.4: API使用量監視**:
- Google Cloud Console → Billing → Usage
- 予算アラートを確認（GOOGLE_CLOUD_SETUP_GUIDE.md参照）

---

## 📞 トラブルシューティング

### 問題1: "Your Apple ID is not yet ready for use"

**原因**: Apple Developer Program登録処理中

**解決策**: 24-48時間待つ

---

### 問題2: Archive時に "Signing for "Runner" requires a development team"

**原因**: Xcodeで Team が選択されていない

**解決策**:
1. Xcode → Runner → Signing & Capabilities
2. Team を選択

---

### 問題3: アップロード時に "Invalid Swift Support"

**原因**: Swiftライブラリの不整合

**解決策**:
```bash
cd ios
rm -rf Pods
pod install
cd ..
# 再度 Archive
```

---

### 問題4: 審査拒否（Rejection）

**よくある理由**:
1. **クラッシュ**: 審査員のテスト中にアプリがクラッシュ
   - **解決**: DEVICE_TESTING_GUIDE.md で全テストケースを実施
2. **プライバシーポリシー不備**: 位置情報の利用目的が不明確
   - **解決**: PRIVACY_POLICY.md を詳細化してWeb公開
3. **機能が動作しない**: コンパスが動作しない（シミュレータでテスト）
   - **解決**: 審査員向けメモに「実機でテストしてください」と明記

**再審査**:
1. 問題を修正
2. 新しいビルドをアップロード（必要に応じて）
3. App Store Connectで **「Resubmit」** をクリック

---

## 📚 参考リンク

- [Apple Developer Program](https://developer.apple.com/programs/)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

**作成日**: 2025-10-20
**対応Phase**: D3 - iOS App Store Release
**次のステップ**: Phase D4 - Post-Release Maintenance

