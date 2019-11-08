import argparse
import logging
import json

import apache_beam as beam
from apache_beam.io import ReadFromText
from apache_beam.io import WriteToText
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions

def run(argv=None, save_main_session=True):
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', dest='input', default='/tmp/beam/input', help='Input file to process.')
    parser.add_argument('--output', dest='output', default='/tmp/beam/output', help='Output file to write results to.')
    known_args, pipeline_args = parser.parse_known_args(argv)
    pipeline_args.extend([
      '--runner=DirectRunner',
      '--project=global-datacenter',
#      '--staging_location=/tmp/beam/staging',
#      '--temp_location=/tmp/beam/tmp',
      '--job_name=parse-twitter-job',
    ])

    def transform_tweet_to_bq(data):
        d = data['data']
        hashtags = [ h['tag'] for h in d.get('entities', {}).get('hashtags', {}) ]
        return {
            'id': d['id'],
            'author_id': d['author_id'],
            'created_at': d['created_at'],
            'place_id': d.get('geo', {}).get('place_id', ''),
            'lang': d.get('lang', ''),
            'text': d['text'],
            'keywords': hashtags
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
            | 'ToJSON' >> beam.Map(json.dumps)
            | 'Write' >> WriteToText(known_args.output)
        )

if __name__ == '__main__':
  logging.getLogger().setLevel(logging.INFO)
  run()
