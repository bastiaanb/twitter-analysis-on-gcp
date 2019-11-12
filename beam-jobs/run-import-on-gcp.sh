#!/bin/bash

time ./beam_twitter.py \
   --input  gs://global-datacenter-twitter_dev/tweets/outstream-2019-11-09_04:06:44.json \
   --output-bq global-datacenter:twitter_dev.tweets \
   --runner=DataflowRunner \
   --temp_location=gs://global-datacenter-twitter_dev/load-tweets-job/temp \
   --project=global-datacenter \
   --job_name=load-tweets-job \
   --region=europe-west1

#   --runner=DirectRunner \
