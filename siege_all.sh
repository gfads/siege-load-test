#!/usr/bin/env bash

export COMPOSE_HTTP_TIMEOUT=600
WAIT_FOR_CONTAINERS_TO_START=300

set -ev

rm -f log.csv
docker ps -aq | xargs docker rm -f || true

# no_tracing
cd ~/microservices-demo && git checkout master && cd -
COMPOSE_FILE=~/microservices-demo/deploy/docker-compose/docker-compose.yml
docker-compose -f $COMPOSE_FILE up -d
sleep $WAIT_FOR_CONTAINERS_TO_START
SERVER=localhost ./siege.sh
mv log.csv log/no_tracing.log
docker-compose -f $COMPOSE_FILE down

# instrumented
COMPOSE_FILE=~/microservices-demo-devops/docker-compose.yml
docker-compose -f $COMPOSE_FILE up -d
sleep $WAIT_FOR_CONTAINERS_TO_START
SERVER=localhost ./siege.sh
mv log.csv log/instrumented.log
docker-compose -f $COMPOSE_FILE down

# rbinder
COMPOSE_FILE=~/microservices-demo/deploy/docker-compose/docker-compose-envoy-rbinder.yml
cd ~/microservices-demo && git checkout rbinder && cd -
docker-compose -f $COMPOSE_FILE up -d orders-envoy
export ORDERS_ENVOY_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' docker-compose_orders-envoy_1)
echo $ORDERS_ENVOY_IP
docker-compose -f $COMPOSE_FILE up -d
sleep $WAIT_FOR_CONTAINERS_TO_START
SERVER=localhost ./siege.sh
mv log.csv log/rbinder.log
docker-compose -f $COMPOSE_FILE down
