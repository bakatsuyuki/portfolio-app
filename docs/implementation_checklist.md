# 同種 Portfolio アプリの実装チェックリスト

`app_data.json` を参照するポートフォリオ表示アプリを新規に作る場合に必要な実装をリスト化する。既存の `.cursorrules` 構成（core / features / shared / routes）に沿って整理している。

## 方針（前提）

- **データソース**: **Google Drive のみ**。ローカル・アセットからの取得は行わない（テスト時はアセットのモック JSON を使用する）。
- **フォルダ指定**: 設定画面で **Drive のフォルダピッカー** によりフォルダを選択する。フォルダ ID の手入力は不要。
- **データの正体**: 親プロジェクトで取引履歴（Portfolio Tracker 等の CSV）→ `calculate_holdings.py` → `holdings.csv` → `build.py` で生成される **`app_data.json`** を Drive から取得する。

---

## 1. 基盤（core）

- [ ] **テーマ（core/theme）**
  - ダークテーマ（背景グラデーション、カード半透明など）
  - ライト/ダーク切替対応（任意）
  - 色・タイポグラフィの定数化（`core/constants` または theme 内）
- [ ] **ルーティング（routes）**
  - ボトムナビ用のルート（例: `/`, `/watchlist`, `/alerts`, `/settings`）
  - 銘柄詳細などサブ画面のルート（例: `/holding/:symbol`）
  - ShellRoute または 親子ルートでタブ＋子画面を構成
- [ ] **定数（core/constants）**
  - アプリ名、表示用ラベル
  - データファイル名（例: `app_data.json`）、API エンドポイント（使用する場合）
- [ ] **エラーハンドリング（core/errors）**
  - データ取得失敗・パース失敗用の例外型
  - ユーザー向けメッセージの定義（任意）

---

## 2. データ層（data）

### 2.1 モデル（DTO）

`app_data.json` および API レスポンス用。`json_serializable` でパースする想定。

- [ ] **Holding** — `symbol`, `quantity`, `price`, `currency`, `value_usd`, `value_jpy`, `ratio`
- [ ] **Sector**（銘柄→セクター） — `symbol`, `name`, `sector`, `industry`
- [ ] **SymbolTheme** — `symbol`, `theme_id`, `weight`
- [ ] **ThemeMaster** — `theme_id`, `theme_name`, `description`
- [ ] **SymbolRegion** — `symbol`, `north_america`, `europe`, `asia`, `china`, `other`
- [ ] **RiskFactor** — `risk_id`, `risk_name`, `description`
- [ ] **ThemeRisk** — `theme_id`, `risk_id`, `tolerance`
- [ ] **AppData**（ルート JSON） — 上記をまとめたレスポンス用モデル（`holdings`, `sectors`, `symbol_themes`, `themes_master`, `symbol_regions`, `risk_factors`, `theme_risks`, `sector_allocation`, `theme_exposure`, `region_exposure`, `risk_tolerance`）
- [ ] **SectorAllocation** — キー: セクター名、値: `{ ratio }` のマップ用モデル
- [ ] **ThemeExposure** — キー: theme_id、値: `theme_name`, `ratio`, `contributors` 用モデル
- [ ] **RegionExposure** — 地域名 → 比率のマップ用モデル
- [ ] **RiskTolerance** — risk_id → `risk_name`, `tolerance` のマップ用モデル
- [ ] 数値が JSON で文字列になっている場合のパース（`fromJson` 内で `num.tryParse` 等）

### 2.2 データソース

- [ ] **Google Drive**（本番のデータソース）
  - Drive API 用クライアント（スコープ `drive.readonly`）
  - 指定フォルダ内の `app_data.json` を取得する処理（フォルダ ID はピッカーで選択後に保存）
  - OAuth サインイン（`google_sign_in` 等）とトークン管理
  - クライアント ID の `--dart-define` または環境変数での注入（client_secret はアプリに含めない）
- [ ] **テスト用** — ユニット・ウィジェットテスト用に `app_data.json` をアセットに 1 本含め、モックとして読み込む

### 2.3 リポジトリ

- [ ] **PortfolioRepository**（抽象は domain、実装は data）
  - `Future<AppData> getAppData()` または `Stream<AppData>`（キャッシュ＋再取得）
  - エラー時は `Result` または例外で呼び出し元に伝える
- [ ] **SettingsRepository** — ピッカーで選択した Drive フォルダ ID・表示通貨などの永続化

---

## 3. ドメイン層（domain）

- [ ] **AppData を扱うユースケース**（例: `GetPortfolioData`） — リポジトリを呼び、プレゼン層に渡す
- [ ] **サマリー計算** — `holdings` から合計評価額（USD/JPY）を算出するロジック（ドメイン or アプリ層で実施）
- [ ] （任意） **銘柄名の解決** — `holdings[].symbol` → `sectors` から `name` を引く処理をユースケース or リポジトリで提供

---

## 4. プレゼンテーション層（features）

### 4.1 ポートフォリオ機能（features/portfolio）

- [ ] **ポートフォリオ画面**
  - ヘッダー（アプリ名・更新ボタン等）
  - サマリー: 合計評価額（USD/JPY）、保有銘柄数（＋日次損益・全収益等はデータがあれば表示）
  - 資産配分の円グラフ（セクター別 or 銘柄別、上位＋「その他」）
  - タブ: 「保有株式」「テーマ/地域/リスク」「履歴」など
- [ ] **保有株式タブ**
  - 銘柄リスト（symbol, name, sector, value, ratio）
  - ソート（比率・評価額等）
  - 行タップで銘柄詳細へ
- [ ] **テーマエクスポージャー**
  - テーマ別比率の表示（リスト or 横棒グラフ）
  - 寄与銘柄（contributors）の表示
- [ ] **地域エクスポージャー**
  - 地域別比率（円グラフ or リスト）
- [ ] **リスク耐性**
  - リスク要因別の耐性スコア表示（表 or バー）
- [ ] **銘柄詳細画面**（任意）
  - 銘柄名・セクター・保有数量・評価額・比率
  - テーマ・地域の参照表示（任意）
- [ ] **履歴タブ**（データがある場合）
  - 期間選択（1M / 3M / 6M / YTD / 1Y 等）
  - パフォーマンス折れ線グラフ
- [ ] **状態（Riverpod Provider）**
  - データ取得用の FutureProvider または AsyncNotifierProvider（AsyncValue で loading/error/data）
  - サマリー・リスト用の算出は Provider で派生、または Notifier で保持
  - ソート・フィルタ状態は StateProvider 等（任意）。画面単位は autoDispose 推奨

### 4.2 その他タブ（将来実装用でも可）

- [ ] **ウォッチリスト** — 画面プレースホルダ＋ルート
- [ ] **アラート** — 画面プレースホルダ＋ルート
- [ ] **設定** — 通貨表示（USD/JPY）、**Drive フォルダの選択（ピッカー）**、テーマ切替

### 4.3 共通 UI（shared/widgets）

- [ ] **ボトムナビ** — 4タブ（ポートフォリオ・ウォッチ・アラート・設定）とルート連携
- [ ] **ローディング表示** — スピナー or スケルトン
- [ ] **エラー表示** — 再試行ボタン付き
- [ ] **空状態** — データなし時のメッセージ
- [ ] **円グラフ** — セクター/地域配分用（`fl_chart` 等）
- [ ] **棒グラフ** — テーマエクスポージャー用
- [ ] **折れ線グラフ** — 履歴用
- [ ] **損益テキスト** — 正負で色分け（緑/赤）のウィジェット
- [ ] **カード** — 半透明スタイルの共通カード

---

## 5. データソース連携の詳細（Google Drive）

- [ ] **初回起動** — 未サインイン or フォルダ未選択なら設定画面へ誘導（Google サインイン → フォルダピッカーで選択）
- [ ] **フォルダピッカー** — Drive のフォルダ選択 UI を開き、ユーザーが `app_data.json` を含むフォルダを選択。選択後にフォルダ ID を保存
- [ ] **フォルダ ID の保存** — 選択したフォルダ ID を SharedPreferences または secure storage に永続化
- [ ] **取得タイミング** — 起動時（フォルダ ID あり）・プルリフレッシュ・設定でフォルダ変更時
- [ ] **キャッシュ** — メモリ or ローカルファイルでキャッシュし、必要時だけ再取得
- [ ] **オフライン** — キャッシュがあれば表示、なければエラー表示（任意）

---

## 6. 設定・永続化

- [ ] **表示通貨** — USD / JPY 切替の保存
- [ ] **Drive フォルダ** — 設定画面のフォルダピッカーで選択したフォルダ ID を保存（手入力は行わない）
- [ ] **テーマ** — ライト/ダークの保存（任意）

---

## 7. 依存関係（pubspec.yaml）

- [ ] **flutter_riverpod** — 状態管理（ref.watch / ref.read、AsyncValue、autoDispose）
- [ ] **go_router** — ルーティング
- [ ] **json_annotation** + **json_serializable** + **build_runner** — JSON モデル
- [ ] **fl_chart**（または **syncfusion_flutter_charts** 等） — チャート
- [ ] **google_sign_in** + **googleapis** — Google サインインと Drive API（`drive.readonly`）
- [ ] **shared_preferences** または **flutter_secure_storage** — フォルダ ID・表示通貨などの設定保存
- [ ] **path_provider** — キャッシュ用ローカルパス（任意）
- [ ] **Drive フォルダピッカー** — Google Picker API または Drive UI によるフォルダ選択（パッケージ・実装方法は要検討）

---

## 8. テスト

- [ ] **モデル** — `fromJson` / `toJson` のユニットテスト（サンプル JSON 使用）
- [ ] **リポジトリ** — モックデータソースで `getAppData` のテスト
- [ ] **サマリー計算** —  Holdings リストから合計・比率が正しいか
- [ ] **ポートフォリオ画面** — モックデータでウィジェットテスト（リスト表示・サマリー表示）
- [ ] **ルート** — タブ切替・銘柄詳細への遷移のテスト（任意）

---

## 9. その他

- [ ] **アセット** — テスト用の `app_data.json` を 1 本アセットに含め、`pubspec.yaml` の `assets` に記載
- [ ] **多言語** — 必要なら `intl` / l10n の準備（ラベル・日付フォーマット）
- [ ] **アクセシビリティ** — セマンティクス・タップ領域 48dp 以上
- [ ] **CI** — `dart analyze` / `flutter test` の実行（任意）

---

## 10. 実装の優先順位（目安）

1. **Phase 1** — 基盤（テーマ・ルート・定数）、データ層（モデル・**Google Drive データソース**・リポジトリ）、**Google サインイン**、**フォルダピッカー**とフォルダ ID 保存、ポートフォリオ画面（サマリー＋保有株式タブ＋円グラフ）、共通 UI（ボトムナビ・ローディング・エラー）。テストはアセットの `app_data.json` で実施。
2. **Phase 2** — テーマ/地域/リスクの表示、銘柄詳細画面、プルリフレッシュ。
3. **Phase 3** — 設定画面の整備（表示通貨・テーマ切替）、キャッシュ・オフライン表示（任意）。
4. **Phase 4** — 履歴タブ（データ対応後）、ウォッチリスト・アラート・その他タブ。

---

参照: `data_structure.md`（データ仕様）, 親 `../docs/flutter_app_design.md`（画面・データソース方針）
