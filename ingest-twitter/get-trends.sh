#!/bin/bash

BEARER_TOKEN=$(./generate-bearer-token.sh)

curl -X GET -H "Authorization: Bearer $BEARER_TOKEN" "https://api.twitter.com/1.1/trends/place.json?id=727232"
