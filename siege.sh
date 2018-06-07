#!/usr/bin/env bash

SERVER=${SERVER:-10.66.66.32:30001}

#
# Start user session.
#
curl -s -c cookies.txt -H 'Authorization: Basic dXNlcjpwYXNzd29yZA==' \
  $SERVER/login > /dev/null

logdn=$(cat cookies.txt | tail -n 2 | head -n 1 | awk '{print $6"="$7}')
mdsid=$(cat cookies.txt | tail -n 1 | awk '{print $6"="$7}')
cooke="Cookie: $logdn; $mdsid"

#
# Add item to cart.
#
curl -XPOST -b cookies.txt -H 'Content-Type: application/json' \
  -d '{"id":"510a0d7e-8e83-4193-b483-e27e09ddc34d"}' \
  $SERVER/cart

#
# Start CPU and RAM monitoring.
#
./rammon.sh &
./cpumon.sh &

#
# Checkout
#
for i in {1..1000}; do
  curl -XPOST \
    -s \
    -b cookies.txt \
    -w "%{time_total},%{http_code}\n" \
    -o /dev/null \
    $SERVER/orders >> log.csv
  sleep $(Rscript ./generate_random_number.r | awk {'print $2'})
done

kill -- -$$
