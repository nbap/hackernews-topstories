import Config

config :news_aggregator, NewsAggregator.HackerNews,
  fetch_interval: 5 * 60 * 1000,
  interval_between_requests: 500,
  yield_tasks_timeout: 4 * 60 * 1000,
  http_client: NewsAggregator.HackerNews.Api,
  base_url: "https://hacker-news.firebaseio.com/v0/"

config :news_aggregator, Toolkit.DataStore, datastore_table_name: :hn_topstories

config :news_aggregator, Toolkit.Paginator, default_page_size: 10

config :news_aggregator, NewsAggregator.Endpoint.ThrottlePlug,
  storage: NewsAggregator.Endpoint.ThrottlePlug.Storage,
  clean_period: 60_000

import_config "#{Mix.env()}.exs"
