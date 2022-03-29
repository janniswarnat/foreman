#!/usr/bin/env bash

set -x

docker compose down
docker volume rm foreman_db
docker volume rm foreman_redis-persistent
docker compose up -d salt salt-minion db
docker compose run --rm app bundle exec rake db:create db:migrate
docker compose run --rm app bundle exec rake db:seed permissions:reset password=changeme
docker compose up -d

# get ip address using ifconfig in Ubuntu
#netsh interface portproxy add v4tov4 listenport=4505 listenaddress=0.0.0.0 connectport=4505 connectaddress=172.24.137.158
#netsh interface portproxy add v4tov4 listenport=4506 listenaddress=0.0.0.0 connectport=4506 connectaddress=172.24.137.158