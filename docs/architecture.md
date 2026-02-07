# Portfolio アプリ アーキテクチャ

本アプリのアーキテクチャ方針とレイヤー構成をまとめる。`.cursorrules` のプロジェクト構成・依存方向に準拠する。

---

## 1. 概要

- **アーキテクチャ**: レイヤード（Presentation / Domain / Data）
- **依存の向き**: Presentation → Domain ← Data（Domain は他層に依存しない）
- **状態管理**: Riverpod（ref.watch / ref.read、AsyncValue、autoDispose）
- **ナビゲーション**: go_router で宣言的ルーティング
- **データ**: `app_data.json` をデータソース（ローカル / Drive / API）から取得し、Domain 経由で UI に渡す

---

## 2. レイヤー構成図

```
                    ┌─────────────────────────────────────────┐
                    │              Presentation               │
                    │  (Screens, Widgets, Controllers)        │
                    │  - ユースケースを呼ぶ                   │
                    │  - UI 状態を保持・更新                  │
                    └─────────────────┬───────────────────────┘
                                      │ 依存
                                      ▼
                    ┌─────────────────────────────────────────┐
                    │                 Domain                  │
                    │  (Entities, Repositories 抽象, UseCases) │
                    │  - 他層に依存しない純粋 Dart              │
                    │  - ビジネスルール・インターフェース定義   │
                    └─────────────────┬───────────────────────┘
                                      ▲ 依存
                                      │ 実装
                    ┌─────────────────┴───────────────────────┐
                    │                  Data                   │
                    │  (Datasources, Models/DTO, Repo 実装)   │
                    │  - JSON パース、HTTP、ローカル読み込み   │
                    └─────────────────────────────────────────┘
```

- **Presentation**: 画面・ウィジェット・Controller。Domain の UseCase のみ参照する。
- **Domain**: エンティティ・抽象リポジトリ・ユースケース。Flutter や HTTP に依存しない。
- **Data**: データソース・DTO・リポジトリ実装。Domain の抽象を実装する。

---

## 3. ディレクトリ構成と責務

```
lib/
├── main.dart                 # エントリポイント、runApp(App())
├── app.dart                  # MaterialApp.router、テーマ、routerConfig
├── core/                     # アプリ全体で共有する基盤（ビジネスロジックは置かない）
│   ├── constants/            # 定数、API エンドポイント、ファイル名
│   ├── errors/               # 例外型、Failure、Result 用の型
│   ├── extensions/           # Dart 拡張メソッド
│   ├── network/              # HTTP クライアント設定（必要時）
│   ├── theme/                # ThemeData、色、テキストスタイル
│   ├── utils/                # 汎用ヘルパー（巨大化しない）
│   └── di/                   # 依存性注入（必要時）
├── features/                 # 機能単位。1 feature = data + domain + presentation
│   └── feature_name/
│       ├── data/
│       │   ├── datasources/   # リモート/ローカルデータ取得
│       │   ├── models/       # DTO（json_serializable）
│       │   └── repositories/ # リポジトリ実装
│       ├── domain/
│       │   ├── entities/     # ビジネスエンティティ（純粋 Dart）
│       │   ├── repositories/ # 抽象リポジトリ（interface）
│       │   └── usecases/     # ユースケース
│       └── presentation/
│           ├── screens/      # 画面
│           ├── widgets/      # 当 feature 専用ウィジェット
│           └── controllers/  # ViewModel / Controller
├── shared/                   # 複数 feature で使うもの
│   ├── widgets/              # 共通ウィジェット（ボトムナビ、チャート等）
│   ├── models/               # 横断的なモデル（必要時）
│   └── services/             # 共通サービス（設定永続化等）
└── routes/
    └── app_router.dart        # go_router のルート定義
```

### 3.1 core の責務

| ディレクトリ | 責務 | 例 |
|-------------|------|-----|
| constants   | アプリ名、ファイル名、URL 等の定数 | `appDataFileName`, `apiBaseUrl` |
| errors      | 例外クラス、Failure、Result 用の sealed 型 | `AppException`, `DataNotFoundException` |
| extensions  | 型の拡張メソッド | `String.toNumOrZero` |
| network     | Dio/Http クライアントの設定・インターセプタ | 使用する場合のみ |
| theme       | ThemeData、ColorScheme、TextTheme | `AppTheme.light`, `AppTheme.dark` |
| utils       | 日付フォーマット、数値フォーマット等のヘルパー | 巨大化しない |
| di          | リポジトリ・ユースケースの登録・取得 | 使用する場合のみ |

- **core にビジネスロジックは置かない**（「ポートフォリオの合計をどう計算するか」は domain または presentation）。

### 3.2 features の責務

- **1 機能 = 1 feature**。例: `portfolio`, `settings`, `watchlist`。
- 各 feature は **data / domain / presentation** の 3 層を持つ（小さい feature は domain を薄くしてもよい）。
- **Feature 内で完結するものは feature 内に置く**。複数 feature で使うものは `shared/` へ。

### 3.3 shared の責務

- **横断的に使う UI とサービス**。
- 例: ボトムナビ、ローディング表示、エラー表示、円グラフ/棒グラフ、設定の永続化サービス。
- feature 固有の画面・ロジックは shared に置かない。

### 3.4 routes の責務

- **go_router のルート定義を一箇所に集約**する。
- タブ（ShellRoute）と子ルート、銘柄詳細などのパスをここで定義する。
- 認証や初期リダイレクトが必要な場合は `redirect` で制御する。

---

## 4. 依存のルール

### 4.1 許可される依存の向き

```
Presentation  →  Domain   （UseCase を呼ぶ）
Data          →  Domain   （Repository 抽象を実装）
Presentation  →  core     （theme, errors, constants を参照可）
Data          →  core     （errors, network, constants を参照可）
Presentation  →  shared   （共通ウィジェットを参照可）
```

### 4.2 禁止される依存

- **Domain → 他層**: Domain は Flutter / HTTP / core の具体的な実装に依存しない。
- **Domain → Data**: リポジトリは「抽象（interface）」のみを Domain に置き、実装は Data に置く。
- **Data → Presentation**: データ層から UI を参照しない。
- **逆方向の循環**: どの層も下位層から上位層へ依存しない。

### 4.3 インポートの目安

- `features/portfolio/domain/` 内のファイルは `package:portfolio_app/...` で **core または同一 feature の data** 以外を import しない。
- `features/portfolio/presentation/` は `domain` と `core` / `shared` を import する。**他 feature の presentation を直接 import しない**（遷移は route で行う）。

---

## 5. データの流れ（ポートフォリオ取得の例）

1. **ユーザー**: アプリ起動 or プルリフレッシュ
2. **Presentation**: Controller が「データ取得」をトリガー
3. **Presentation → Domain**: `GetPortfolioData` のような UseCase を呼ぶ
4. **Domain**: UseCase が抽象 `PortfolioRepository` の `getAppData()` を呼ぶ
5. **Data**: 実装 `PortfolioRepositoryImpl` が Datasource（ローカル / Drive / API）から JSON を取得
6. **Data**: JSON を DTO（AppData 等）にパースし、Domain の Entity または DTO のまま返す（方針による）
7. **Domain → Presentation**: UseCase が Result または Entity を返す
8. **Presentation**: Controller が状態を更新（loading → data / error）、UI が再描画

```
[User] → [Screen] → [Controller] → [UseCase] → [Repository 抽象]
                                              ↓
[Datasource] ← [Repository 実装] ← [JSON / API]
         ↓
[Controller] ← [UseCase] ← [Repository 実装]
     ↓
[Screen] 再描画
```

---

## 6. 状態管理（Riverpod）

本アプリでは **Riverpod** を使用する。テスト時に Provider をオーバーライドしやすく、非同期状態を AsyncValue で統一できる。

- **build 内**: `ref.watch(provider)` で Provider を購読する。状態が変わるとそのウィジェットだけが再ビルドされる。
- **イベントハンドラ内**: `ref.read(provider)` で参照する。`ref.watch` は build 外では使わない。
- **非同期**: `FutureProvider` / `StreamProvider` の戻り値は `AsyncValue<T>`。`when` や `switch` で loading / error / data を分岐する。
- **破棄**: 画面単位の状態は `autoDispose` を付与し、画面を離れたら自動破棄する。
- **Provider の配置**: feature の presentation 付近（または domain に近い層）に定義。共通なら shared や core/di。リポジトリ・ユースケースを Provider で注入するとテストで差し替えやすい。

---

## 7. ナビゲーション

- **宣言的ルーティング**: go_router の `GoRouter` を `MaterialApp.router(routerConfig: ...)` に渡す。
- **ルート定義**: `routes/app_router.dart` に集約。タブは `StatefulShellRoute` でボトムナビと対応させる。
- **画面間パラメータ**: 銘柄詳細などは `path: '/holding/:symbol'` のようにパスパラメータで渡す。クエリが必要なら `extra` や query を使用。
- **ダイアログ**: 一時的なものは `Navigator.of(context).push` 等でよい（go_router に含めてもよい）。

---

## 8. エラーハンドリング

- **Domain**: 失敗を表現する場合は `Result<T>` のような型（sealed class: Success / Failure）を返す。
- **core/errors**: アプリ固有の例外型（`AppException`, `NetworkException` 等）を定義し、Data 層で catch して Failure に詰める。
- **Presentation**: UseCase の Result を受け、Failure ならエラー表示・再試行ボタンを出す。未捕捉例外はグローバルでキャッチする方針でもよい。

---

## 9. Feature の分割例（本アプリ）

| Feature      | 主な責務 |
|-------------|----------|
| portfolio   | app_data 取得、サマリー・保有・テーマ/地域/リスク表示、銘柄詳細 |
| settings    | 表示通貨、データソース（Drive フォルダ ID）、テーマ切替の永続化 |
| watchlist   | ウォッチリスト一覧（将来） |
| alerts      | アラート設定（将来） |

- **共通 UI**: ボトムナビ、チャート、ローディング、エラー表示 → `shared/widgets`
- **共通サービス**: 設定の読み書き → `shared/services` または feature `settings` の data

---

## 10. どこに何を置くか（簡易表）

| 種類               | 置く場所 |
|--------------------|----------|
| 画面               | `features/<feature>/presentation/screens/` |
| 画面専用ウィジェット | `features/<feature>/presentation/widgets/` |
| 画面の状態・ロジック | `features/<feature>/presentation/controllers/` |
| ユースケース       | `features/<feature>/domain/usecases/` |
| リポジトリ抽象     | `features/<feature>/domain/repositories/` |
| リポジトリ実装     | `features/<feature>/data/repositories/` |
| データソース       | `features/<feature>/data/datasources/` |
| DTO / JSON モデル  | `features/<feature>/data/models/` |
| エンティティ       | `features/<feature>/domain/entities/` |
| 共通ウィジェット   | `shared/widgets/` |
| テーマ・色         | `core/theme/` |
| 定数               | `core/constants/` |
| 例外・Failure      | `core/errors/` |
| ルート定義         | `routes/app_router.dart` |

---

## 11. 関連ドキュメント

- **プロジェクト構成・規約**: ルートの `.cursorrules`
- **データ仕様**: `data_structure.md`
- **実装タスク一覧**: `implementation_checklist.md`
- **画面・データソース方針**: 親 `../docs/flutter_app_design.md`
