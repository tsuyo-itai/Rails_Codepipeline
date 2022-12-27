#!/bin/sh

rm -f tmp/pids/server.pid
mkdir -p tmp/sockets
mkdir -p tmp/pids

# DBの準備
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
# puma起動
bundle exec puma -C config/puma.rb