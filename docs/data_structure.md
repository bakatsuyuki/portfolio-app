# Portfolio データ構造ドキュメント

親ディレクトリ（Portfolio）のファイル・ディレクトリ構成と、アプリが参照するデータの構造をまとめる。

---

## 1. ディレクトリ構成（Portfolio ルート）

```
Portfolio/
├── app/                    # Flutter アプリ（本リポジトリ）
├── build/                  # ビルド成果物（build.py の出力）
│   ├── app_data.json       # アプリ・ダッシュボード用の統合 JSON
│   ├── index.html          # Web ダッシュボード
│   ├── sector_allocation.csv
│   ├── theme_exposure.csv
│   ├── region_exposure.csv
│   └── risk_tolerance.csv
├── master/                 # マスタデータ（銘柄・テーマ・リスク等）
│   ├── sectors.csv
│   ├── symbol_themes.csv
│   ├── themes_master.csv
│   ├── symbol_regions.csv
│   ├── symbol_exchanges.csv
│   ├── risk_factors.csv
│   └── theme_risks.csv
├── docs/
│   └── flutter_app_design.md
├── holdings.csv            # 現在の保有（銘柄・数量・価格・比率）
├── build.py                # セクター/テーマ/地域/リスクを計算し app_data.json 等を生成
├── calculate_holdings.py   # 取引CSVから保有残高を計算し holdings.csv を出力
├── add_trades.py           # 取引追加
├── add_theme.py            # テーマ追加
└── requirements.txt
```

- **データの流れ**: 取引CSV → `calculate_holdings.py` → `holdings.csv`。`holdings.csv` と `master/*.csv` → `build.py` → `build/app_data.json` および各種 CSV。
- アプリは **`build/app_data.json`** を読み込む想定（例: Google Drive 経由）。

---

## 2. 入力ソース

### 2.1 holdings.csv（現在の保有）

| カラム       | 型     | 説明 |
|-------------|--------|------|
| symbol      | string | 銘柄コード（例: AAPL, TYO:1655） |
| quantity    | number | 保有数量 |
| price       | number | 単価 |
| currency    | string | 通貨（USD, JPY 等） |
| value_usd   | number | 評価額（USD） |
| value_jpy   | number | 評価額（円） |
| ratio       | number | ポートフォリオに占める比率（%） |

- 銘柄ごと1行。`ratio` は全保有の評価額合計に対する割合（合計 100%）。

### 2.2 master/（マスタ CSV）

| ファイル             | 主キー・関連              | 説明 |
|----------------------|---------------------------|------|
| sectors.csv          | symbol                    | 銘柄 → 名称・セクター・業種 |
| symbol_themes.csv    | symbol, theme_id         | 銘柄 ↔ テーマ（重み %） |
| themes_master.csv    | theme_id                 | テーマ ID → 表示名・説明 |
| symbol_regions.csv   | symbol                   | 銘柄の地域別売上比率（%） |
| symbol_exchanges.csv | symbol                   | 銘柄 → 取引所（株価取得用） |
| risk_factors.csv     | risk_id                  | リスク要因の定義 |
| theme_risks.csv      | theme_id, risk_id        | テーマ × リスクの耐性スコア |

---

## 3. マスタの詳細スキーマ

### 3.1 sectors.csv

| カラム   | 型     | 説明 |
|----------|--------|------|
| symbol   | string | 銘柄コード |
| name     | string | 銘柄名（例: Apple Inc） |
| sector   | string | セクター（例: Information Technology） |
| industry | string | 業種（例: Consumer Electronics） |

### 3.2 symbol_themes.csv

| カラム    | 型     | 説明 |
|-----------|--------|------|
| symbol    | string | 銘柄コード |
| theme_id  | string | テーマ ID（例: AI, GOLD） |
| weight    | number | そのテーマへの重み（0–100、銘柄内で合計100のことが多い） |

- 1銘柄が複数テーマに属しうる（例: AAPL → AI 30, CONSUMER_TECH 50, SAAS 20）。

### 3.3 themes_master.csv

| カラム      | 型     | 説明 |
|-------------|--------|------|
| theme_id    | string | テーマ ID |
| theme_name  | string | 表示名（例: AI, ゴールド） |
| description | string | 説明（日本語可） |

### 3.4 symbol_regions.csv

| カラム        | 型     | 説明 |
|---------------|--------|------|
| symbol        | string | 銘柄コード |
| north_america | number | 北米比率（%） |
| europe        | number | 欧州比率（%） |
| asia          | number | アジア比率（%） |
| china         | number | 中国比率（%） |
| other         | number | その他（%） |

- 各行の合計は 100。

### 3.5 symbol_exchanges.csv

| カラム   | 型     | 説明 |
|----------|--------|------|
| symbol   | string | 銘柄コード |
| exchange | string | 取引所（例: NASDAQ, NYSE, TYO） |

- `calculate_holdings.py` の株価取得で利用。

### 3.6 risk_factors.csv

| カラム      | 型     | 説明 |
|-------------|--------|------|
| risk_id    | string | リスク ID（例: INFLATION, CHINA_RISK） |
| risk_name  | string | 表示名（例: インフレ, 中国リスク） |
| description| string | 説明 |

### 3.7 theme_risks.csv

| カラム    | 型     | 説明 |
|-----------|--------|------|
| theme_id  | string | テーマ ID |
| risk_id   | string | リスク ID |
| tolerance | int    | 耐性スコア（正: 耐性あり、負: 弱い、0: 中立） |

- 例: GOLD × INFLATION → 2、SEMICONDUCTORS × CHINA_RISK → -2。

---

## 4. build/app_data.json の構造

`build.py` が出力する JSON。アプリはこのファイルを読み込む。

### 4.1 トップレベルキー一覧

| キー               | 型       | 説明 |
|--------------------|----------|------|
| holdings           | array    | 保有一覧（holdings.csv 相当） |
| sectors            | array    | 銘柄→セクター情報（sectors.csv 相当） |
| symbol_themes      | array    | 銘柄×テーマ×重み（symbol_themes.csv 相当） |
| themes_master      | array    | テーママスタ（themes_master.csv 相当） |
| symbol_regions     | array    | 銘柄×地域比率（symbol_regions.csv 相当） |
| risk_factors       | array    | リスク要因マスタ（risk_factors.csv 相当） |
| theme_risks        | array    | テーマ×リスク耐性（theme_risks.csv 相当） |
| sector_allocation  | object   | セクター別配分比率（計算値） |
| theme_exposure     | object   | テーマ別エクスポージャー（計算値） |
| region_exposure    | object   | 地域別エクスポージャー（計算値） |
| risk_tolerance     | object   | リスク要因別のポートフォリオ耐性（計算値） |

### 4.2 holdings（配列要素）

`holdings.csv` の1行が1要素。キーは CSV のカラム名と同一。

- `symbol`, `quantity`, `price`, `currency`, `value_usd`, `value_jpy`, `ratio`
- 数値は JSON では文字列で格納されている場合あり（パース時に数値化すること）。

### 4.3 sectors（配列要素）

- `symbol`, `name`, `sector`, `industry`

### 4.4 symbol_themes（配列要素）

- `symbol`, `theme_id`, `weight`（文字列の場合あり）

### 4.5 themes_master（配列要素）

- `theme_id`, `theme_name`, `description`

### 4.6 symbol_regions（配列要素）

- `symbol`, `north_america`, `europe`, `asia`, `china`, `other`（数値または文字列）

### 4.7 risk_factors（配列要素）

- `risk_id`, `risk_name`, `description`

### 4.8 theme_risks（配列要素）

- `theme_id`, `risk_id`, `tolerance`（数値または文字列）

### 4.9 sector_allocation（計算値・オブジェクト）

- **キー**: セクター名（例: `Information Technology`）
- **値**: `{ "ratio": number }`（そのセクターの比率 %）
- 例: `"Information Technology": { "ratio": 24.63 }`

### 4.10 theme_exposure（計算値・オブジェクト）

- **キー**: theme_id（例: `AI`）
- **値**: `{ "theme_name": string, "ratio": number, "contributors": string }`
  - `theme_name`: 表示名
  - `ratio`: ポートフォリオに占めるテーマの比率（%）
  - `contributors`: 寄与銘柄の説明（例: `"PLTR (2.75%), AAPL (2.00%), ..."`）

### 4.11 region_exposure（計算値・オブジェクト）

- **キー**: 地域名（`North America`, `Europe`, `Asia`, `China`, `Other`）
- **値**: 数値（その地域のエクスポージャー %）
- 例: `"North America": 56.35`

### 4.12 risk_tolerance（計算値・オブジェクト）

- **キー**: risk_id（例: `INFLATION`）
- **値**: `{ "risk_name": string, "tolerance": number }`
  - テーマ別耐性を保有比率で加重平均したポートフォリオ全体の耐性スコア。

---

## 5. 計算ロジック概要（build.py）

- **sector_allocation**: 各保有の `ratio` を、その銘柄の `sectors.sector` に加算。セクターごとに合計して比率化。
- **theme_exposure**: 各保有について `(ratio * symbol_themes.weight) / 100` を該当 theme_id に加算。テーマごとに合計。
- **region_exposure**: 各保有について、`symbol_regions` の地域比率（%）を `ratio` で加重して合計。
- **risk_tolerance**: テーマ別エクスポージャーを重みに、`theme_risks.tolerance` を加重平均し、リスク要因ごとにポートフォリオ耐性を算出。

---

## 6. アプリでの利用のポイント

1. **データソース**: `build/app_data.json` を 1 ファイルで読み込めば、一覧・マスタ・集計が揃う。
2. **数値**: JSON 内で数値が文字列になっている場合は、クライアントでパースする。
3. **銘柄コード**: 日本株は `TYO:1655` のように取引所プレフィックス付き。
4. **関連の取り方**: `holdings[].symbol` → `sectors` / `symbol_themes` / `symbol_regions` は symbol で紐付け。テーマ名は `themes_master` の theme_id で取得。

---

## 7. 関連ドキュメント

- 親ディレクトリ: `../docs/flutter_app_design.md` — 画面構成・データソース（Google Drive）・Phase 分けなど。
