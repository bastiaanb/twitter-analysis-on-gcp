#!/usr/bin/env python3

import os
import requests
import time

filter_stream_url = "https://api.twitter.com/labs/1/tweets/stream/filter?tweet.format=detailed&user.format=compact&place.format=detailed&expansions=geo.place_id"
sample_stream_url = "https://api.twitter.com/labs/1/tweets/stream/sample?tweet.format=detailed&user.format=compact&place.format=detailed&expansions=geo.place_id"

rules_url = "https://api.twitter.com/labs/1/tweets/stream/filter/rules"

class BearerTokenAuth(requests.auth.AuthBase):
  def __init__(self, bearer_token):
    if bearer_token is None:
      raise Exception("bearer token is not defined")

    self.auth_header = f"Bearer {bearer_token}"

  def __call__(self, r):
    r.headers['Authorization'] = self.auth_header
    return r


def get_all_rules(auth):
  response = requests.get(rules_url, auth=auth)

  if response.status_code is not 200:
    raise Exception(f"Cannot get rules (HTTP %d): %s" % (response.status_code, response.text))

  return response.json()


def delete_rules(rules, auth):
  if rules is None or 'data' not in rules:
    return None

  ids = list(map(lambda rule: rule['id'], rules['data']))

  payload = {
    'delete': {
      'ids': ids
    }
  }

  response = requests.post(rules_url, auth=auth, json=payload)

  if response.status_code is not 200:
    raise Exception(f"Cannot delete rules (HTTP {response.status_code}): {response.text}")

def add_rules(rules, auth):
  if rules is None:
    return

  payload = {
    'add': rules
  }

  response = requests.post(rules_url, auth=auth, json=payload)

  if response.status_code is not 201:
    raise Exception(f"Cannot create rules (HTTP {response.status_code}): {response.text}")

def stream_connect(url, auth):
  starttime = 0
  file = None
  response = requests.get(url, auth=auth, stream=True)
  if response.status_code is not 200:
    raise Exception(f"Cannot get stream (HTTP {response.status_code}): {response.text}")

  for response_line in response.iter_lines():
    now = time.time()
    if (now - starttime >= 300):
        starttime = now
        if file:
            file.close()
        print(f"\n{starttime}  ")
        file = open(f"data/outstream-{time.strftime('%Y-%m-%d_%H:%M:%S')}.json", "ab")
    if response_line:
        file.write(response_line)
        file.write(b"\n")
        print(".", end='', flush=True)

def setup_rules(auth):
  current_rules = get_all_rules(auth)
  delete_rules(current_rules, auth)
  add_rules([
    { 'value': 'place_country:NL', 'tag': 'NL' },
    { 'value': 'place_country:US', 'tag': 'US' },
  ], auth)

auth = BearerTokenAuth(os.environ.get("BEARER_TOKEN"))

setup_rules(auth)

while True:
    stream_connect(filter_stream_url, auth)
    time.sleep(2)
