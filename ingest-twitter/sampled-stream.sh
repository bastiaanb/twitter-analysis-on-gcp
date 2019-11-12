#!/bin/bash

BEARER_TOKEN=$(./generate-bearer-token.sh)
 
curl -v -X GET -H "Authorization: Bearer $BEARER_TOKEN" "https://api.twitter.com/labs/1/tweets/stream/sample?tweet.format=detailed&user.format=compact&place.format=default&expansions=geo.place_id"
#curl -X GET -H "Authorization: Bearer $BEARER_TOKEN" "https://api.twitter.com/labs/1/tweets/stream/sample?tweet.format=default&user.format=compact&place.format=compact"
