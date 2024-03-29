#!/bin/bash

set -e
bundle check || bundle install --binstubs="$BUNDLE_BIN"

bundle exec rake db:create
bundle exec rake db:migrate

rm -f tmp/pids/server.pid

# yarn install
# bundle exec rails assets:precompile
bundle exec rake rswag:specs:swaggerize || true
bundle exec rails s -p 3000 -b 0.0.0.0

exec "$@"
