# Store Deployment Tasks: Respectful Direction Tracker

**Track**: Store Publication (ストア公開トラック)
**Status**: Phase D1 Automation Complete (13/19 tasks), Phase D3 Guide Ready
**Last Updated**: 2025-10-20

---

## Purpose

このファイルは、「あしむけれん」アプリの**ストア公開タスク**を管理します。

**対象範囲**:
- ✅ **Phase D1**: リリース前準備（APIセキュリティ、アイコン、ポリシー等）
- ⏸️ **Phase D2**: Android Play Store 公開
- ⏸️ **Phase D3**: iOS App Store 公開
- ⏸️ **Phase D4**: リリース後運用（アップデート、保守）

**対象外（別トラック）**:
- 機能開発タスク → `tasks-features.md` 参照

---

## Format: `[ID] [MANUAL?] Description`
- **[MANUAL]**: Requires manual execution by user (cannot be automated by Claude)
- **[LAYER X]**: Security layer designation (1=Environment, 2=Cloud Console, 3=Obfuscation)

---

## Phase D1: Pre-Release Preparation (リリース前準備)

**Purpose**: アプリをストアに提出する前の準備作業

**Status**: ✅ Complete (20/20 tasks, 100%) - Ready for App Store submission
**Guide**: `GOOGLE_CLOUD_SETUP_GUIDE.md`, `PRIVACY_POLICY.md`, `DEVICE_TESTING_GUIDE.md`
**Note**: Android/iOS use SEPARATE API keys (1 platform per key)
**Completed**: API Security ✅, App Identity ✅, Legal & Privacy ✅, Device Testing ✅

### D1.1: API Key Security (APIキーセキュリティ) - 最重要

**Security Strategy**: Pattern A - Direct Embedding with API Restrictions (Industry Standard 80-90%)

**Core Principle**: API keys WILL be embedded in APK/IPA (inevitable). Security comes from Google Cloud Console restrictions, not hiding the key.

**Three-Layer Defense**:
1. **Layer 1**: Environment variables (prevent Git commits) ✅ Complete
2. **Layer 2**: Google Cloud Console restrictions ⭐ MOST CRITICAL ⏸️ Manual
3. **Layer 3**: ProGuard/R8 obfuscation (make discovery harder) ✅ Complete

#### Layer 1: Environment Variables (開発時保護)

**Status**: ✅ Completed (3/3 tasks)

- [x] T-D1.1.1 [P] [LAYER 1] Android環境変数設定
  - Create `android/local.properties` with `GOOGLE_MAPS_API_KEY=...`
  - Update `android/app/build.gradle` to read from local.properties
  - Update `AndroidManifest.xml` to use `${GOOGLE_MAPS_API_KEY}`
  - **Result**: API key not hardcoded in source files

- [x] T-D1.1.2 [P] [LAYER 1] iOS環境変数設定
  - Create `ios/Flutter/Secrets.xcconfig` with `GOOGLE_MAPS_API_KEY=...`
  - Update `Debug.xcconfig` and `Release.xcconfig` to include Secrets.xcconfig
  - Update `Info.plist` to reference `$(GOOGLE_MAPS_API_KEY)`
  - **Result**: API key not hardcoded in source files

- [x] T-D1.1.3 [P] [LAYER 1] .gitignore更新
  - Add `android/local.properties` to .gitignore
  - Add `ios/Flutter/Secrets.xcconfig` to .gitignore
  - Add `ios/Flutter/Generated.xcconfig` to .gitignore
  - Verify with `git status` that secrets are not tracked
  - **Result**: API keys never committed to version control

#### Layer 2: Google Cloud Console Restrictions (最重要)

**Status**: ✅ Completed (5/5 tasks) - **User completed MANUAL tasks**

**Important**: Use SEPARATE API keys for Android and iOS (1 platform per key)

- [x] T-D1.1.4 [MANUAL] [LAYER 2 - CRITICAL] Android用APIキー制限設定
  - **Why**: Even if API key is extracted from APK, it cannot be used by other apps
  - **Action**: Google Cloud Console → APIs & Services → Credentials
  - **API Key**: [既存のAndroid用APIキー] (stored in android/local.properties)
  - Set **Application Restrictions**:
    - **Android app**: Package name → `jp.codesmith.ashimukeren`
    - ❌ Do NOT set iOS restrictions on this key
  - Set **API Restrictions** - Select "Restrict key" and enable ONLY:
    - ✅ **Maps SDK for Android**
    - ✅ **Geocoding API**
    - ❌ Maps SDK for iOS (not needed for Android-only key)
  - **Explicitly DISABLE all other APIs** (security critical):
    - ❌ Places API
    - ❌ Directions API
    - ❌ Distance Matrix API
    - ❌ Geolocation API
    - ❌ Roads API
    - ❌ Street View Static API
    - ❌ Time Zone API
    - ❌ Maps JavaScript API
    - ❌ Maps Static API
    - ❌ Maps Embed API
    - ❌ All other Google Maps Platform APIs
  - **Config File**: `android/local.properties`
  - **Result**: Android API key limited to 2 APIs only, stolen key cannot access other services

- [x] T-D1.1.5 [MANUAL] [LAYER 2 - CRITICAL] SHA-1証明書フィンガープリント登録
  - **Why**: Adds second factor authentication (app signature verification)
  - **Debug certificate**:
    ```bash
    keytool -list -v -keystore ~/.android/debug.keystore \
      -alias androiddebugkey -storepass android -keypass android | grep SHA1
    ```
  - **Release certificate** (after T-D2.1):
    ```bash
    keytool -list -v -keystore ~/ashimukeren-release-key.jks \
      -alias ashimukeren -storepass <password> | grep SHA1
    ```
  - **Action**: Add BOTH SHA-1 fingerprints to Google Cloud Console
  - **Result**: App must be signed with correct certificate

- [x] T-D1.1.6 [MANUAL] [MONITORING] API使用量監視・請求アラート設定
  - **Why**: Detect anomalies before significant billing impact
  - **Action**: Google Cloud Console → Billing → Budgets & Alerts
  - Create budget: $50/month
  - Set alert thresholds: 50%, 80%, 90%, 100%
  - Add notification email addresses
  - **Result**: Email alerts if usage spikes

- [x] T-D1.1.7 [MANUAL] [QUOTA LIMITS] APIクォータ制限設定
  - **Why**: Cap maximum daily usage even if abuse occurs
  - **Action**: Google Cloud Console → APIs & Services → Quotas
  - Set daily limits:
    - Maps SDK: 10,000 requests/day
    - Geocoding API: 1,000 requests/day
  - **Result**: API stops after quota exceeded (prevents runaway costs)

- [x] T-D1.1.13 [MANUAL] [LAYER 2 - CRITICAL] iOS用APIキー作成・制限設定
  - **Why**: iOS app needs separate API key (cannot share with Android)
  - **Action**: Google Cloud Console → APIs & Services → Credentials → Create API Key
  - Create NEW API key (do NOT use Android key)
  - Set **Application Restrictions**:
    - **iOS app**: Bundle ID → `jp.codesmith.ashimukeren`
    - ❌ Do NOT set Android restrictions on this key
  - Set **API Restrictions** - Select "Restrict key" and enable ONLY:
    - ✅ **Maps SDK for iOS**
    - ✅ **Geocoding API**
    - ❌ Maps SDK for Android (not needed for iOS-only key)
  - **Explicitly DISABLE all other APIs** (same list as T-D1.1.4)
  - **Config File**: Update `ios/Flutter/Secrets.xcconfig` with new iOS API key
  - **Result**: iOS API key limited to 2 APIs only, separate from Android key

#### Layer 3: Code Obfuscation (難読化)

**Status**: ✅ Completed (1/1 task)

- [x] T-D1.1.8 [LAYER 3] ProGuard/R8難読化設定
  - Update `android/app/build.gradle`: minifyEnabled true, shrinkResources true
  - Create `android/app/proguard-rules.pro` with Flutter + Google Maps rules
  - Test release build: `flutter build apk --release`
  - **Result**: APK code obfuscated, reverse engineering harder

#### Verification & Testing

**Status**: ⏸️ Pending (3/3 tasks) - **After MANUAL tasks complete**

- [ ] T-D1.1.9 API制限の動作確認テスト (After T-D1.1.4～T-D1.1.7)
  - Test app with restricted API key
  - Attempt to use API key from unauthorized package (should fail)
  - Verify geocoding works within quotas

- [ ] T-D1.1.10 環境変数設定のテスト
  - Build debug APK/IPA and verify Maps work
  - Build release APK/IPA and verify Maps work
  - Confirm API keys are not visible in decompiled APK

- [x] T-D1.1.11 flutter analyzeでセキュリティ警告チェック
  - Run `flutter analyze`
  - Ensure no security-related warnings
  - **Result**: No issues found! ✅

#### Documentation

**Status**: ✅ Completed (1/1 task)

- [x] T-D1.1.12 DEPLOYMENT.md にAPIセキュリティ手順を追加
  - Document API restriction setup checklist
  - Document environment variable setup
  - Add pre-release security verification checklist
  - **Result**: Complete security documentation

**Checkpoint**: API keys are secured with 3-layer defense

---

### D1.2: App Identity & Branding (アプリID・ブランディング)

**Status**: ⏳ In Progress (1/3 tasks)

- [x] T-D1.2.1 アプリID変更
  - Change `android/app/build.gradle`: applicationId → `jp.codesmith.ashimukeren`
  - Change `android/app/build.gradle`: namespace → `jp.codesmith.ashimukeren`
  - Run `flutter clean && flutter pub get`
  - **Result**: Production-ready app ID (cannot be changed after publication)

- [x] T-D1.2.2 アプリアイコン準備
  - Added `flutter_launcher_icons ^0.13.1` to dev_dependencies
  - Configured flutter_launcher_icons in pubspec.yaml
  - Generated icon assets for all densities from `assets/app_icon.png`
  - Android: mipmap-mdpi/hdpi/xhdpi/xxhdpi/xxxhdpi + adaptive icons
  - iOS: All sizes (20pt～1024pt) generated
  - **Result**: Professional app icon across all devices

- [x] T-D1.2.3 アプリ名確認
  - Updated `android/app/src/main/AndroidManifest.xml`: android:label="あしむけれん"
  - Updated `ios/Runner/Info.plist`: CFBundleDisplayName="あしむけれん"
  - **Result**: Consistent Japanese branding

---

### D1.3: Legal & Privacy (法的要件)

**Status**: ✅ Completed (2/2 tasks)

- [x] T-D1.3.1 [MANUAL] プライバシーポリシー作成
  - **Why**: Required by Play Store/App Store for apps using location data
  - **Content**:
    - What data is collected (location, names, addresses)
    - How data is used (direction calculation)
    - Where data is stored (local device only, no server)
    - Third-party services (Google Maps API)
    - Contact information
  - **Publish**: GitHub Pages, Google Sites, or personal website
  - **Result**: ✅ https://codesmith.github.io/ashimukeren/privacy

- [x] T-D1.3.2 [MANUAL] サポートメールアドレス準備
  - Create dedicated support email (e.g., `ashimukeren.support@gmail.com`)
  - Add to Play Store/App Store listings
  - **Result**: ✅ senzureba@gmail.com

---

### D1.4: Pre-Release Verification (公開前確認)

**Status**: ✅ Completed (1/1 task)

- [x] T-D1.4.1 実機での最終動作確認
  - Test on multiple Android devices (different OS versions)
  - Test on iPhone (real device)
  - Verify all 3 user stories (registration, map, compass)
  - Check for crashes, ANRs, performance issues
  - Take screenshots for store listings (4-8 screenshots)
  - **Result**: App ready for submission

---

## Phase D2: Android Play Store Release (Android公開)

**Purpose**: Google Play Storeへのアプリ公開

**Status**: ⏸️ Pending (0/8 tasks)

**Dependencies**: Phase D1 must be complete

### D2.1: Release Signing (リリース署名)

- [ ] T-D2.1.1 [MANUAL] リリース用署名鍵の生成
  - Run:
    ```bash
    keytool -genkey -v -keystore ~/ashimukeren-release-key.jks \
      -keyalg RSA -keysize 2048 -validity 10000 \
      -alias ashimukeren
    ```
  - Enter password (記録必須！失うとアプリ更新不可)
  - Enter details (name, organization, city, country)
  - **Result**: `~/ashimukeren-release-key.jks` created
  - **Backup**: Copy to secure location (USB drive, password manager)

- [ ] T-D2.1.2 署名設定ファイル作成
  - Create `android/key.properties`:
    ```properties
    storePassword=<your-password>
    keyPassword=<your-password>
    keyAlias=ashimukeren
    storeFile=/Users/yourname/ashimukeren-release-key.jks
    ```
  - Verify `android/.gitignore` includes `key.properties`
  - **Result**: Signing configuration ready

- [ ] T-D2.1.3 build.gradle署名設定更新
  - Update `android/app/build.gradle`:
    - Add keystoreProperties loading code
    - Add signingConfigs.release block
    - Update buildTypes.release: signingConfig → signingConfigs.release
  - **Result**: Release builds will be signed with production key

---

### D2.2: Release Build (リリースビルド)

- [ ] T-D2.2.1 リリースビルド前確認
  - Run `flutter analyze` → No issues
  - Run `flutter test` (optional)
  - Verify `pubspec.yaml` version is correct (e.g., `1.0.0+1`)
  - **Result**: Code quality verified

- [ ] T-D2.2.2 AAB (Android App Bundle) ビルド
  - Run: `flutter build appbundle --release`
  - Verify output: `build/app/outputs/bundle/release/app-release.aab`
  - Check file size (typically 20-50MB)
  - **Result**: Production-ready AAB file

---

### D2.3: Play Console Setup (Play Console設定)

- [ ] T-D2.3.1 [MANUAL] Google Play Console アカウント作成
  - Sign up at https://play.google.com/console
  - Pay $25 one-time registration fee
  - **Result**: Play Console account active

- [ ] T-D2.3.2 [MANUAL] Play Console で新規アプリ作成
  - Click "Create app"
  - App name: `あしむけれん`
  - Default language: Japanese
  - App or game: App
  - Free or paid: Free
  - Accept declarations
  - **Result**: App created in Play Console

- [ ] T-D2.3.3 [MANUAL] アプリ情報設定
  - **App access**: すべての機能が無料で利用可能
  - **Ads**: いいえ（広告なし）
  - **Content rating**: ユーティリティ・生産性、全年齢
  - **Target audience**: 18歳以上 or 全年齢
  - **App category**: ツール
  - **Contact details**: Support email, privacy policy URL
  - **Result**: App info configured

---

### D2.4: Store Listing (ストア掲載情報)

- [ ] T-D2.4.1 [MANUAL] ストア掲載情報入力
  - **App name**: あしむけれん
  - **Short description** (80 chars):
    ```
    大切な人の方角を教えてくれるコンパスアプリ。足を向けて寝てはいけない方向をお知らせします。
    ```
  - **Full description** (4000 chars):
    ```
    ## あしむけれんとは？

    「あしむけれん」は、大切な人や尊敬する人の方角を教えてくれるコンパスアプリです。
    寝る時に足を向けてはいけない方向を視覚的に表示します。

    ## 主な機能

    ### 📝 人の登録
    - 大切な人の名前と住所を登録
    - 住所から自動で位置情報を取得

    ### 🗺️ 地図表示
    - Google Mapで登録した人の位置を表示

    ### 🧭 方向警告コンパス
    - スマホを水平に持つと方角を表示
    - 危険な方向（足を向けてはいけない）: 赤色
    - 安全な方向: 緑色

    ## プライバシー
    すべてのデータは端末内に保存され、外部に送信されません。
    ```
  - **App icon**: 512x512px PNG (32-bit)
  - **Screenshots**: 4-8 images (from T-D1.4.1)
  - **Feature graphic**: 1024x500px (optional)
  - **Result**: Store listing complete

---

### D2.5: Release Submission (審査提出)

- [ ] T-D2.5.1 [MANUAL] 本番リリース作成
  - Navigate to Play Console → Production → Create new release
  - Upload AAB file: `build/app/outputs/bundle/release/app-release.aab`
  - Release name: `1.0.0 (1)` or `初回リリース`
  - Release notes (Japanese):
    ```
    初回リリース

    - 大切な人の名前と住所を登録
    - Google Mapで登録した場所を表示
    - コンパスで方角を警告表示
    ```
  - **Result**: Release draft created

- [ ] T-D2.5.2 [MANUAL] 審査提出
  - Review all settings
  - Click "Review" → "Roll out to Production"
  - Wait for Google review (1-3 days)
  - **Result**: App submitted for review

**Checkpoint**: Android app published to Play Store 🎉

---

## Phase D3: iOS App Store Release (iOS公開)

**Purpose**: Apple App Storeへのアプリ公開

**Status**: ✅ Complete (9/9 tasks, 100%) - Submitted for review! 🎉

**Submission Date**: 2025-10-25 15:52
**Build**: 1.0.0 (1)
**Review Status**: 審査待ち (Waiting for Review)

**Guide**: `IOS_APP_STORE_GUIDE.md` - Complete step-by-step iOS App Store publication guide

**Dependencies**: Phase D1 MANUAL tasks should be complete

### D3.1: Apple Developer Setup

- [x] T-D3.1.1 [MANUAL] Apple Developer Program 登録
  - Sign up at https://developer.apple.com/programs/
  - Pay $99/year
  - **Result**: ✅ Apple Developer account active (Developer: Takaomi Yonejima)

- [x] T-D3.1.2 [MANUAL] App ID 作成
  - Developer Portal → Certificates, IDs & Profiles → App IDs
  - Bundle ID: `jp.codesmith.ashimukeren`
  - App name: `あしむけれん`
  - **Result**: ✅ App ID registered

---

### D3.2: Provisioning & Signing

- [x] T-D3.2.1 [MANUAL] Distribution Certificate 作成
  - Xcode → Settings → Accounts → Manage Certificates
  - Create "Apple Distribution" certificate
  - **Result**: ✅ Distribution certificate available

- [x] T-D3.2.2 [MANUAL] Provisioning Profile 作成
  - Developer Portal → Provisioning Profiles
  - Create "App Store" profile for app ID
  - Download and install
  - **Result**: ✅ App Store provisioning profile ready

- [x] T-D3.2.3 Xcode署名設定
  - Open `ios/Runner.xcworkspace` in Xcode
  - Select Runner target → Signing & Capabilities
  - Set Team, Bundle ID
  - **Result**: ✅ Xcode configured for App Store signing

---

### D3.3: Archive Build

- [x] T-D3.3.1 Archive ビルド作成
  - Xcode → Product → Archive
  - Wait for build to complete
  - Verify Archive appears in Organizer
  - **Result**: ✅ Archive ready for upload (CocoaPods fix applied with `pod install`)

- [x] T-D3.3.2 [MANUAL] App Store Connect アップロード
  - Organizer → Distribute App → App Store Connect
  - Upload to App Store Connect
  - Wait for processing (10-30 min)
  - **Result**: ✅ Build 1.0.0 (1) available in App Store Connect (TestFlight tested successfully)

---

### D3.4: App Store Connect Setup

- [x] T-D3.4.1 [MANUAL] App Store Connect でアプリ作成
  - https://appstoreconnect.apple.com/
  - My Apps → + → New App
  - Platform: iOS, Name: 足向けれん, Bundle ID, SKU
  - **Result**: ✅ App created in App Store Connect

- [x] T-D3.4.2 [MANUAL] ストア掲載情報入力
  - App Information: Name, category, privacy policy URL
  - Pricing & Availability: Free, all countries
  - App Privacy: Fill privacy questionnaire
  - Version Information: Screenshots (iPhone 16 Pro Max + iPad Pro 13"), description, keywords
  - Build: Select uploaded build
  - **Result**: ✅ App Store listing complete (Copyright: 2025 Takaomi Yonejima, Support: senzureba@gmail.com)

---

### D3.5: Submission

- [x] T-D3.5.1 [MANUAL] 審査提出
  - Review all info
  - Submit for Review
  - Wait for Apple review (1-7 days)
  - **Result**: ✅ App submitted for review (2025-10-25 15:52 - Status: 審査待ち)

**Checkpoint**: iOS app published to App Store 🎉

---

## Phase D4: Post-Release Maintenance (リリース後運用)

**Purpose**: アプリ公開後の継続的な保守・更新

**Status**: ⏸️ Pending (0/5 tasks)

### D4.1: Version Management (バージョン管理)

- [ ] T-D4.1.1 バージョン番号管理手順のドキュメント化
  - Document versioning scheme (Semantic Versioning)
  - `pubspec.yaml`: `version: X.Y.Z+BUILD`
    - X = Major (breaking changes)
    - Y = Minor (new features)
    - Z = Patch (bug fixes)
    - BUILD = Build number (must always increase)
  - **Result**: Clear versioning policy

- [ ] T-D4.1.2 リリースノート作成手順
  - Template for release notes (Japanese + English)
  - Changelog format
  - **Result**: Consistent release communication

---

### D4.2: App Updates (アプリ更新)

- [ ] T-D4.2.1 アップデート手順のドキュメント化
  - Steps to update app:
    1. Update `pubspec.yaml` version
    2. Implement changes
    3. Run `flutter analyze` + `flutter test`
    4. Build new AAB/IPA
    5. Upload to Play Console/App Store Connect
    6. Submit for review
  - **Result**: Streamlined update process

- [ ] T-D4.2.2 ホットフィックス手順のドキュメント化
  - Emergency bug fix process
  - Fast-track submission tips
  - **Result**: Rapid response capability

---

### D4.3: Security Maintenance (セキュリティ保守)

- [ ] T-D4.3.1 APIキーローテーション手順のドキュメント化
  - When to rotate API keys (security breach, scheduled maintenance)
  - How to rotate without downtime:
    1. Create new API key in Google Cloud Console
    2. Add same restrictions as old key
    3. Update `local.properties` and `Secrets.xcconfig`
    4. Build and test
    5. Submit new version
    6. After deployment, disable old key
  - **Result**: Secure key rotation procedure

---

## Task Summary

### Phase D1: Pre-Release Preparation
- **API Security**: 8/12 tasks (67%) - Layer 1 & 3 complete, Layer 2 pending (MANUAL)
- **App Identity**: 1/3 tasks (33%)
- **Legal & Privacy**: 0/2 tasks (0%)
- **Verification**: 0/1 task (0%)
- **Total**: 9/18 tasks (50%)

### Phase D2: Android Play Store Release
- **Total**: 0/8 tasks (0%) - Pending Phase D1 completion

### Phase D3: iOS App Store Release
- **Total**: 0/9 tasks (0%) - Future enhancement

### Phase D4: Post-Release Maintenance
- **Total**: 0/5 tasks (0%) - Ongoing after release

### Grand Total
- **Completed**: 9 tasks
- **Pending (MANUAL)**: 4 tasks (Layer 2 security)
- **Pending (Automated)**: 4 tasks (D1 remaining)
- **Pending (D2-D4)**: 22 tasks
- **Total**: 39 deployment tasks

---

## Dependencies

### Phase Dependencies
- **D1 → D2**: Phase D1 must be complete before D2 (Android release)
- **D1 → D3**: Phase D1 must be complete before D3 (iOS release)
- **D2/D3 → D4**: At least one platform released before D4 (maintenance)

### Critical Path for First Release (Android)
1. Complete D1.1 Layer 2 (MANUAL tasks T-D1.1.4 ~ T-D1.1.7)
2. Complete D1.2 ~ D1.4 (icon, privacy policy, testing)
3. Execute D2 sequentially (signing → build → submission)

---

## Related Documentation

- **Feature Tasks**: See `tasks-features.md` for feature implementation
- **Deployment Guide**: See `DEPLOYMENT.md` for detailed step-by-step instructions
- **Specification**: See `spec.md` for security requirements (FR-020 ~ FR-029)
- **Main Task Index**: See `tasks.md` for overview of both tracks
