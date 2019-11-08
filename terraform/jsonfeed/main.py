import json
import flask
from google.cloud import bigquery

def query_trends(request):
    client = bigquery.Client()
    query_job = client.query("""
        SELECT keyword, occurrences FROM twitter.trends ORDER BY time DESC, occurrences DESC LIMIT 10
    """)

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
