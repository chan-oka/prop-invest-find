# README

## システムの概要

Gmailからメールを取得してDBに保存します。
DBに保存したメールから情報を抽出して一覧として表示します。

## 技術スタック

- Ruby 3.3.1
- Ruby on Rails 7.1.3
- MySQL 8.0.37

## 必要条件

- Docker
- Docker Compose

## セットアップ

1. Docker Composeを使用して、コンテナをビルドし、起動します。

```bash
docker-compose build
docker-compose up
```

2. データベースを作成します。

```bash
docker-compose run web rails db:create
```

3. ブラウザでhttp://localhost:3000を開き、Railsアプリケーションが実行されていることを確認します。

5. Seedを実行
```bash
bundle exec rails db:seed
```

4. Gmailを取得
```bash
# 未読メールを取得、DBに保存できると既読にします
bundle exec rails google:gmails:fetch_unread

# 全メールを取得、DBに保存できると既読にします
bundle exec rails google:gmails:fetch_all
```

## ライセンス

- daisaku.okada
- OkamoLife株式会社

