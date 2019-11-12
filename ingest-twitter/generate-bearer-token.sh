#!/usr/bin/env bash

curl --silent -u "${API_KEY}:${API_SECRET_KEY}" --data 'grant_type=client_credentials' https://api.twitter.com/oauth2/token | jq -r .access_token
