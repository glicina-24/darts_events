## サービス概要

ダーツバーやプロプレイヤーのイベント情報を集約して検索・閲覧できる、ダーツイベント情報掲示板アプリです。  
店舗オーナーやプロプレイヤーが店舗情報・イベント情報を投稿し、ユーザーは興味のあるイベントを検索・お気に入り登録できます。

## このサービスへの思い・作りたい理由

ダーツをしていてもったいないと感じたのが「イベント情報の不足」でした。
ダーツバーではイベントが頻繁に行われているのに、情報発信の多くはSNSや店内での宣伝がメインで、常連客以外にはなかなか届きません。
友達のSNSを見て「え、今日イベントやってるの？知ってたら絶対行ったのに！」という悔しい思いを何度もしました。
さらに、憧れのプロプレイヤーが隣県のイベントに参加していたことを後日知ったときは、チャンスを逃した悔しさが強く残りました。

現状、情報を手に入れる方法はダーツバーやプロプレイヤーのアカウントをいくつもフォローしチェックするしかありませんが、会いたいプレイヤーは人によっては何十人、何百人といます。さらにSNSの情報もイベントの告知だけではないため見逃す可能性は高いです。

こうした「参加できたはずのイベントを見逃す」課題を解決するために、ダーツバーのイベント情報やプロプレイヤーが参加する大会情報を一括でチェックできる掲示板アプリを作りたいと考えました。

## ユーザーの獲得について

- ダーツ業界の有名プロや人気店舗への案内
- 地域を絞った展開（宮崎県内）からスタート

### 理由
1. 推しのプロが参加するイベントや、近所のイベント、初心者向けイベントを探したい人に使ってもらいたいためです。
2. 店舗オーナーはイベントの宣伝ができ、プロプレイヤーは自分の出演イベント情報を管理できるためです。

## サービスの利用イメージ

イベント情報投稿: 店舗オーナーやダーツプロがイベント情報を投稿し、ユーザーが閲覧できます。
お気に入り登録: 店舗やプロプレイヤーをお気に入り登録できます。
通知機能: お気に入り登録した店舗やプレイヤーの新着イベント通知を受け取れます。

## ユーザーの獲得について

ダーツ業界の有名プロや人気店舗への宣伝。
地域を絞って展開（宮崎県内or九州内）

## サービスの差別化ポイント・推しポイント

既存のダーツ関連サービスとの比較
1. DARTSLIVE SEARCH
店舗検索に特化したサイトで、ダーツバーやネットカフェなど、ダーツがプレイできる場所を探せます
違い: 店舗の検索はできるが、イベント情報の検索機能はない

2. DARTSLIVEアプリ
プレイデータの確認やフレンド機能など、ダーツのゲーム体験をサポートする公式アプリ
違い: 個人のプレイ記録管理がメイン。店舗やプロが主催するイベント情報の投稿・検索機能はない

3. 各店舗の公式X/Instagram
現状、ほとんどの店舗やプロがSNSで個別にイベント告知
問題点: ユーザーが複数のアカウントをフォローして情報を追う必要がある

### 推しポイント
SNSを個別に追わなくても、イベント情報をまとめて検索できます。
カテゴリーや参加プロ情報で絞り込みできます。
お気に入り登録と通知機能により、推しプレイヤーや店舗のイベントを見逃しにくくなります。

## 画面遷移図

Figma: <https://www.figma.com/design/1gMjHohHXT7aGgkNVTZqO4/DartsEvents?node-id=0-1&p=f&t=Hq9wKqhQxxX9gFb9-0>

## ER図

[![Image from Gyazo](https://i.gyazo.com/817d7ce6a060f1df6783dc8fb40966b1.png)](https://gyazo.com/817d7ce6a060f1df6783dc8fb40966b1)

## 実装済み機能（2026-03 時点）

### 認証・ユーザー

- Devise によるメール/パスワード認証
- Confirmable（メール確認）
- Google OAuth ログイン（`omniauth-google-oauth2`）
- ロール管理（`general` / `admin`）
- プロ申請フロー（`unapplied/pending/approved/rejected`）
- プロ承認時の自動通知（`Notification` 作成）

### イベント

- 一覧 / 詳細 / 作成 / 編集 / 削除
- 店舗オーナーのみ作成可能、かつ自分の店舗に紐づくイベントのみ編集可能
- 画像複数アップロード（JPEG/PNG/WebP、5MB 以下、最大 5 枚）
- 参加予定プロの紐づけ（承認済みプロを検索して選択）
- 検索（イベント名・店舗名・都道府県・開催日・参加プロ）
- ページネーション（12 件/ページ）
- イベント詳細で地図表示（Google Maps 埋め込み）
- ステータス管理（`scheduled/finished/canceled`）

### 店舗

- 店舗登録申請（`pending` で作成）
- 申請時メール認証（トークン付き URL、24 時間有効）
- 承認済み店舗のみ一覧/詳細で公開（`Shop.visible`）
- 店舗画像アップロード（イベント画像と同条件）

### お気に入り・通知

- お気に入り対象: `Event` / `Shop` / `User(承認済みプロのみ)`
- お気に入り追加/解除（Turbo 対応）
- お気に入り追加時に対象オーナーへ通知
- 通知一覧、個別既読、全件既読
- イベント作成時:
  - お気に入り店舗ユーザーへアプリ内通知
  - お気に入り店舗/プロユーザーへメール通知
  - `EmailDelivery` に dedupe キー付きで送信履歴を記録

### 管理・運用

- RailsAdmin + CanCanCan による管理画面（`/admin`、admin のみアクセス可）
- Sentry 連携（production のみ）
- ヘルスチェック（`GET /up`）
- 定期タスク: `events:update_status` を 1 時間ごとに実行

## 技術スタック

- Ruby 3.3.6
- Ruby on Rails 7.2.3
- Node.js 20.19.3
- PostgreSQL
- Hotwire（Turbo / Stimulus）
- Tailwind CSS v4（`@tailwindcss/cli`）
- Ransack（検索）
- Kaminari（ページネーション）
- Active Storage（画像管理）
- Amazon S3（本番画像ストレージ）
- Devise / omniauth-google-oauth2
- RailsAdmin / CanCanCan
- Sentry
- Docker / Docker Compose（ローカル開発）
- Render（本番デプロイ）

## データモデル概要

中心は `users -> shops -> events` の 3 層です。

- `users`: ユーザー、認証情報、権限、プロ申請状態
- `shops`: 店舗情報（`user_id` でオーナーに紐づく）
- `events`: イベント情報（`shop_id` に紐づく）
- `event_participants`: イベントと参加プロ（User）の中間テーブル
- `favorites`: ポリモーフィックなお気に入り
- `notifications`: 通知（受信者/実行者/対象）
- `email_deliveries`: メール送信履歴（重複送信防止キーあり）
- `active_storage_*`: 画像メタデータ管理

### event_participants の運用方針（設計メモ）

- テーブル自体は汎用の中間テーブルとして維持します（将来的な一般参加者対応を想定）。
- 現時点の機能では `pro_player_ids` のみを扱い、実運用上は「参加予定プロ」用途です。
- 将来、一般参加者を扱う際は `event_participants` に role（例: `pro` / `general`）を追加して拡張する方針です。

## 環境変数（主なもの）

### 認証
- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`

### メール
- `MAIL_FROM`
- `SMTP_ADDRESS`
- `SMTP_PORT`
- `SMTP_DOMAIN`
- `SMTP_USERNAME`
- `SMTP_PASSWORD`
- `SMTP_AUTHENTICATION`
- `SMTP_ENABLE_STARTTLS`

### ストレージ / 監視
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AWS_S3_BUCKET`
- `SENTRY_DSN`
- `SENTRY_ENVIRONMENT`

### アプリ / DB
- `APP_HOST`
- `DATABASE_URL`

## ローカル開発（Docker）

前提:

- Docker / Docker Compose が利用可能

起動:

```bash
docker compose up --build
```

アクセス:

- <http://localhost:3000>

補足:

- `web` コンテナは起動時に `bundle install` / `rails db:prepare` / `bin/dev` を実行
- `bin/dev` は `web + js + css` を同時起動（`Procfile.dev`）

## ローカル開発（直接実行する場合）

`config/database.yml` は Docker 前提（`host: db`）なので、直接実行時は `DATABASE_URL` の指定または DB 設定の調整が必要です。

```bash
bundle install
yarn install
bin/rails db:prepare
bin/dev
```

## テスト・静的解析

```bash
# RSpec
docker compose exec -e RAILS_ENV=test web bundle exec rspec

# RuboCop
docker compose exec web bin/rubocop

# Brakeman
docker compose exec web bin/brakeman

# Bundler Audit
docker compose exec web bundle exec bundler-audit check --update
```

## デプロイ/運用（本番）

- Web: Render Web Service（Rails / Puma）
- DB: Render PostgreSQL（`DATABASE_URL`）
- 画像: Amazon S3（Active Storage）
- メール: SMTP
- 監視: Sentry
- バッチ: cron（`events:update_status` を毎時実行）

補足:

- 開発環境の画像保存先はローカル（`config.active_storage.service = :local`）
- 本番は S3（`config.active_storage.service = :amazon`）

## ディレクトリ構成

```text
.
├── app/            # controllers, models, views, services, mailers
├── config/         # routes, environments, initializers
├── db/             # migrations, schema, seeds
├── docs/           # リリース手順など
├── lib/tasks/      # rake tasks
├── spec/           # RSpec tests
├── test/           # Minitest (一部)
├── public/         # 静的ファイル
├── compose.yml     # 開発用 docker compose
├── Dockerfile      # 本番用イメージ
└── README.md
```

## 今後の改善候補

- 通知チャネルの拡張（Web Push など）
- 検索 UI / 検索性能の改善
- イベント・店舗情報の入力補助（地図連携強化）
- バッチ・メール送信の運用可観測性向上
