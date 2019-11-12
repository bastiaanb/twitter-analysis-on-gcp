#!/usr/bin/env python3

import argparse
import logging
import json
import re

from past.builtins import unicode

import apache_beam as beam
from apache_beam.io import ReadFromText
from apache_beam.io import WriteToText
from apache_beam.io.gcp.bigquery import WriteToBigQuery
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions

def run(argv=None, save_main_session=True):
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', dest='input', help='Input file to process.')
    parser.add_argument('--output-file', dest='output_file', help='Output file to write results to.')
    parser.add_argument('--output-topic', dest='output_topic', help='Output topic to write results to.')
    known_args, pipeline_args = parser.parse_known_args(argv)
    pipeline_args.extend([
      '--runner=DirectRunner',
      '--project=global-datacenter',
#      '--staging_location=/tmp/beam/staging',
#      '--temp_location=/tmp/beam/tmp',
      '--job_name=parse-twitter-job',
    ])

    # We use the save_main_session option because one or more DoFn's in this
    # workflow rely on global context (e.g., a module imported at module level).
    pipeline_options = PipelineOptions(pipeline_args)
    pipeline_options.view_as(SetupOptions).save_main_session = save_main_session
    with beam.Pipeline(options=pipeline_options) as p:
        def as_feed(top):
            return json.dumps({
                "version": "https://jsonfeed.org/version/1",
                "title": "Trending Twitter Keywords",
                "home_page_url": "https://example.org/",
                "feed_url": "https://example.org/feed.json",
                "items": [ {
                      "id": row[0],
                      "content_text": f"Keyword '{row[0]}' counted {row[1]}",
                      "url": f"https://twitter.com/search?q={row[0]}"   # TODO security: urlencode keyword
                  }
                  for row in top
                ]
            })

        texts = (p
            | 'Read' >> ReadFromText(known_args.input)
            | 'FromJSON' >> beam.Map(json.loads)
            | 'GetTexts' >> beam.Map(lambda x: x['data']['text'])
        )

        feed = (texts
            | 'Split' >> (beam.FlatMap(lambda x: re.findall(r'[@#\w\']{6,}', x, re.UNICODE))
                          .with_output_types(unicode))
            | 'PairWithOne' >> beam.Map(lambda x: (x, 1))
            | 'GroupAndSum' >> beam.CombinePerKey(sum)
            | 'Top10' >> beam.transforms.combiners.Top.Of(10, key=lambda x: x[1])
            | 'AsFeed' >> beam.Map(as_feed)
        )

        if known_args.output_file:
            unused = (feed
                | WriteToText(known_args.output_file)
            )

        if known_args.output_topic:
            unused = (feed
                | 'Encode' >> beam.Map(lambda x: x.encode('utf-8')).with_output_types(bytes)
                | 'Publish' >> beam.io.WriteToPubSub(known_args.output_topic)
            )

if __name__ == '__main__':
  logging.getLogger().setLevel(logging.INFO)
  run()
