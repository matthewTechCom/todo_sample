## 使用する言語
必ず日本語で回答してください

## コーディング規約
### 1. 共通方針

- **必ずDockerコンテナ内で動作確認・テスト実行を行ってください**
- プログラミング言語
	- フロントエンド: TypeScript（厳格モードを推奨）
	- バックエンド: Ruby / Ruby on Rails
- フォーマッタ & リンターを必ず通す
	- フロント: ESLint + Prettier
	- バック: RuboCop（Rails/Performance/Lint 拡張を利用）
- 命名規則
	- 変数・関数: lowerCamelCase
	- クラス・React コンポーネント: PascalCase
	- 定数: UPPER_SNAKE_CASE
	- ファイル名: 基本は kebab-case（React コンポーネントはファイル名も PascalCase 可）
- コメントは「なぜ」を書く（「何を」はコードで表現）。
- 外部サービス鍵やシークレットは .env（または Rails 資格情報）で管理し、リポジトリにコミットしない。

### 2. Git 運用・PR ルール

- ブランチ戦略: GitHub Flow
	- main: 常にデプロイ可能
	- feature/*: 機能単位で作成（例: `feature/frontend-user-authentication`）
- コミットメッセージ: Conventional Commits を推奨
	- 例: `feat(frontend): ログインフォームを実装` / `fix(api): ユーザ登録のバリデーションエラーを修正`
- Pull Request
	- 小さく早く出す（~400行以内目安）
	- 説明に目的・変更点・スコープ外・テスト観点・スクリーンショット（UI変更時）を記載
	- チェックリスト
		- [ ] ESLint/Prettier/RuboCop を通過
		- [ ] 既存テストグリーン + 追加テスト
		- [ ] Swagger（rswag）を更新（API変更時）
		- [ ] 破壊的変更の影響を説明

### 3. バックエンド規約
- スタイルと構造
	- RuboCop を導入し、`Style/`, `Lint/`, `Rails/` を基本遵守
	- Fat Controller/Model 回避。サービス層（`app/services/`）やクエリオブジェクトで責務分離
	- JSON API 専用のため、ビューは使わずコントローラは `render json:` を基本
- API 設計
	- パスは `/api/v1/...` のバージョニングを採用
	- レスポンスは JSON で統一。成功 2xx、失敗 4xx/5xx
	- ページング・フィルタ・ソートのクエリパラメータは明示（例: `?page=1&per=20&sort=-created_at`）
	- エラーフォーマット（例）

- 認証/認可
	- Devise を使用。API でのセッション/トークン戦略はプロジェクト方針に従う
	- 認可が必要なエンドポイントは `before_action :authenticate_user!`
- 例外処理
	- `ApplicationController` にて `rescue_from` を定義し 404/422/500 を JSON 化
- RSwag（OpenAPI）
	- API 追加・変更時は rswag のリクエストスペックと `swagger/v1/swagger.yaml` を更新
- データベース
	- マイグレーションは「目的が明確な名前」（例: `add_index_to_users_email`）
	- 外部キー制約・NOT NULL・ユニーク制約を積極的に付与