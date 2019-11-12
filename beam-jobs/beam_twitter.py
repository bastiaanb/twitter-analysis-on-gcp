#!/usr/bin/env python3

import argparse
import logging
import json
import re

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
    parser.add_argument('--output-bq', dest='output_bq', help='Output BigQuery Table to write results to.')
    known_args, pipeline_args = parser.parse_known_args(argv)
#     pipeline_args.extend([
#       '--runner=DirectRunner',
# #      '--temp_location=/tmp/beam/tmp',
#       '--job_name=parse-twitter-job',
#     ])

    def transform_tweet_to_bq(data):
        d = data['data']
        hashtags = [ h['tag'] for h in d.get('entities', {}).get('hashtags', {}) ]
        places = data.get('includes', {}).get('places', {})
        place = places[0] if len(places) > 0 else {}
        return {
            'id': d['id'],
            'author_id': d['author_id'],
            'created_at': d['created_at'],
            'place_id': d.get('geo', {}).get('place_id', ''),
            'lang': d.get('lang', ''),
            'text': d['text'],
            'keywords': re.findall(r'[@#\w\']{6,}', d['text'], re.UNICODE),
            'place_name': place.get('full_name', ''),
            'place_country': place.get('country_code', ''),
            'hashtags': hashtags,

        }

    # We use the save_main_session option because one or more DoFn's in this
    # workflow rely on global context (e.g., a module imported at module level).
    pipeline_options = PipelineOptions(pipeline_args)
    pipeline_options.view_as(SetupOptions).save_main_session = save_main_session
    with beam.Pipeline(options=pipeline_options) as p:
        output = (p
            | 'Read' >> ReadFromText(known_args.input)
            | 'FromJSON' >> beam.Map(json.loads)
            | 'Transform' >> beam.Map(transform_tweet_to_bq)
        )

        if known_args.output_file:
            unused = (output
                | 'ToJSON' >> beam.Map(json.dumps)
                | 'Write' >> WriteToText(known_args.output_file)
            )

        if known_args.output_bq:
            unused = (output | 'LoadBigQuery' >> WriteToBigQuery(known_args.output_bq, method=WriteToBigQuery.Method.FILE_LOADS))

if __name__ == '__main__':
  logging.getLogger().setLevel(logging.INFO)
  run()
