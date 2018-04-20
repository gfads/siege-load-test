#!/usr/bin/env bash

export MYSQL_ROOT_PASSWORD=""

COMPOSE_FILE=/home/embs/Code/microservices-demo/microservices-demo/deploy/docker-compose/docker-compose.yml

function wait4spring {
  echo Waiting for $1 service to be ready...
  while :; do
    docker-compose -f $COMPOSE_FILE logs $1 | grep Started && break
    sleep 1
  done
}

function wait4mysql {
  echo Waiting for $1 service to be ready...
  while :; do
    docker-compose -f $COMPOSE_FILE logs $1 | grep sock | grep 3306 && break
    sleep 1
  done
}

docker-compose -f $COMPOSE_FILE down
docker-compose -f $COMPOSE_FILE up -d orders-db carts-db catalogue-db user-db

wait4mysql catalogue-db

docker-compose -f $COMPOSE_FILE up -d

wait4spring orders
wait4spring carts
