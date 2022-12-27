# Rails Todoアプリ

## 初期環境構築
下記のファイルを準備

```text
.
├── Gemfile.lock
├── Gemfile
├── Dockerfile
└── docker-compose.yml
```

#### Gemfile.lock

空ファイル

#### Gemfile

```Gemfile
source 'https://rubygems.org'
gem 'rails', '5.2.8'
```

#### Dockerfile

```Dockerfile
FROM ruby:2.7.5

RUN mkdir /todoapp
WORKDIR /todoapp
COPY Gemfile /todoapp/Gemfile
COPY Gemfile.lock /todoapp/Gemfile.lock

# Bundlerの不具合対策(1)
RUN gem update --system && \
    bundle update --bundler && \
    bundle install && \
    apt-get update && \
    apt-get install -y tzdata && \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt-get install -y nodejs

COPY . /todoapp
```

#### docker-compose.yml

```YAML
version: '3'
services:
  db:
    # コンテナ名の指定
    container_name: rails_todoapl_db
    image: mysql:5.7
    # DBのレコードが日本語だと文字化けするので、utf8をセットする
    command: mysqld --character-set-server=utf8 --collation-server=utf8_unicode_ci
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: root
      TZ: "Asia/Tokyo"
    ports:
      - "3306:3306"
    # ローカルにDBを持つ
    volumes:
      - ./tmp/db:/var/lib/mysql

  webapl:
    # コンテナ名の指定
    container_name: rails_todoapl_webapl
    build: .
    command: bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -p 3000 -b '0.0.0.0'"
    volumes:
      - .:/todoapp
    ports:
      - "3000:3000"
    depends_on:
      - db
```

### プロジェクトの作成

```bash
docker-compose run web rails new . --force --no-deps --database=mysql
```

### イメージの構築

```bash
docker-compose build
```

### DBの設定

`config/database.yml`の編集

```YAML
default: &default
  adapter: mysql2
  encoding: utf8mb4
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: root
  password: password
  host: db
```

passwordは`docker-compose.yml`で設定した`MYSQL_ROOT_PASSWORD`  
hostはdockerコンテナのサービス名

### DBの作成

```bash
docker-compose run webapl rails db:create
```

### railsの起動

```bash
docker-compose up
```

## アプリの作成

### bootstrapの導入

こちらを参考にした  
<https://rails-ambassador.herokuapp.com/tips/install_bootstrap4_with_rails5_2>

### コントローラーの作成

コントローラー名は**複数形**にしておくこと

```bash
docker-compose exec webapl rails g controller todos
```

### モデルの作成

```bash
docker-compose exec webapl rails g model todo title:string content:text status:boolean
```

作成されたマイグレートファイルを下記のように変更

```ruby
class CreateTodos < ActiveRecord::Migration[5.2]
  def change
    create_table :todos do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.boolean :status, default: false

      t.timestamps
    end
  end
end
```

`title`、`content`はNULLを許容しない  
`status`のdefaultをfalseとする

マイグレートの実行

```bash
docker-compose exec webapl rails db:migrate
```

#### 疑似データの作成

`db/seeds.rb`に記載

```ruby
if Rails.env == 'development'
  (1..20).each do |i|
    Todo.create(title: "やること#{i}", content: "内容#{i}", status: 0)
  end
end
```

下記コマンドの実行

```bash
docker-compose exec webapl rails db:seed
```

#### データベースの新規作成

##### データベースの初期化

```bash
docker-compose exec webapl rails db:drop 
```

以下の動きをする  
DBの削除

##### データベースのセットアップ

```bash
docker-compose exec webapl rails db:setup
```

以下の動きをする  
DBの作成(db:create)  
スキーマからのテーブル作成(db:schema:load)  
初期データの登録(db:seed)
