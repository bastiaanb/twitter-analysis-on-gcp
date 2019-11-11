import json
import flask
import os
from google.cloud import bigquery

TRENDS_TABLE = os.environ.get("TRENDS_TABLE", "twitter.trends")

def query_trends(request):
    client = bigquery.Client()
    query_job = client.query(f"SELECT keyword, occurrences FROM {TRENDS_TABLE} ORDER BY time DESC, occurrences DESC LIMIT 10")

    results = query_job.result()  # Waits for job to complete.
    items = [ {
            "id": row.keyword,
            "content_text": f"Keyword '{row.keyword}' counted {row.occurrences}",
            "url": f"https://twitter.com/search?q={row.keyword}"   # TODO security: urlencode keyword
        }
        for row in results
    ]

    response = flask.make_response(
        json.dumps({
            "version": "https://jsonfeed.org/version/1",
            "title": "Trending Twitter Keywords",
            "home_page_url": "https://example.org/",
            "feed_url": "https://example.org/feed.json",
            "items": items
        })
    )

    response.headers['content-type'] = 'application/json'

    return response
