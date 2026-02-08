# portfolio_app

ポートフォリオデータ（app_data.json）を Google Drive から取得して表示する Flutter アプリ。

## Google Sign-In（Android）の設定手順

### 前提

- すでに **Web クライアント**（`client_secret_xxx.json`）がある Google Cloud プロジェクトを使う。
- 初めてそのプロジェクトで OAuth クライアントを作る場合は、先に **「API とサービス」→「OAuth 同意画面」** でアプリ名・サポートメールを設定しておく（GCP が求める必須項目）。

---

### ステップ 1: デバッグ用 SHA-1 を取得する

ターミナルで実行する（Mac / Linux）:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
```

表示された **SHA1:** の値（`AA:BB:CC:...` 形式）をコピーする。  
初回は「キーストアが存在しません」と出る場合があるが、その前に `flutter run` を 1 回実行すると `~/.android/debug.keystore` が作られる。

---

### ステップ 2: Google Cloud Console で Android 用クライアントを作る

1. [Google Cloud Console](https://console.cloud.google.com/) を開く。
2. **client_secret_xxx.json があるプロジェクト**を選択する。
3. 左メニュー **「API とサービス」→「認証情報」** を開く。
4. **「+ 認証情報を作成」→「OAuth クライアント ID」** を選ぶ。
5. **アプリケーションの種類**で **「Android」** を選ぶ。
6. 次のように入力する:
   - **名前**: 任意（例: `Portfolio App Android`）
   - **パッケージ名**: `com.portfolio.portfolio_app`
   - **SHA-1 証明書フィンガープリント**: ステップ 1 でコピーした SHA1 の値
7. **「作成」** を押す。

これで「Web クライアント」と「Android クライアント」の両方が同じプロジェクトにできる。

---

### ステップ 3: Drive API を有効にする（まだの場合）

1. 左メニュー **「API とサービス」→「ライブラリ」** を開く。
2. **「Google Drive API」** で検索して開く。
3. **「有効にする」** を押す。

---

### ステップ 4: アプリを起動する

**client_id はアプリに埋め込み済み**なので、そのまま起動してよい。

```bash
flutter run
```

別の client_id を使う場合だけ、`--dart-define=GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com` を付ける。**client_secret はアプリに含めない。**

---

### ApiException 10 (DEVELOPER_ERROR) が出たとき

アカウントを選んでもサインインできず **10** が出る場合は、**Android 用 OAuth クライアント**の設定が足りないか、SHA-1 が違います。

**やること（この順で）:**

1. **この Mac のデバッグ SHA-1 を確認する**
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android | grep SHA1
   ```
   表示された `SHA1: XX:XX:...` をコピーする。

2. **Google Cloud Console** → 認証情報がある**同じプロジェクト**を開く。

3. **「認証情報」** → **「+ 認証情報を作成」→「OAuth クライアント ID」** → 種類 **「Android」**。

4. 次を**一字一句合わせて**入力する:
   - **パッケージ名**: `com.portfolio.portfolio_app`（コピペ推奨）
   - **SHA-1**: 手順 1 でコピーした値（コロン付きのまま）

5. **「作成」** を押す。

6. アプリを**完全に終了**してから `flutter run` で再度起動し、設定画面でサインインを試す。

**注意:** Web クライアント（client_id を埋め込んでいるもの）と **同じプロジェクト** に Android クライアントを作ること。別プロジェクトだと 10 のままになります。

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
