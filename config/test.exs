import Config
config :logger, level: :error

config :news_aggregator, NewsAggregator.HackerNews,
  fetch_interval: 100,
  interval_between_requests: 0

config :news_aggregator, NewsAggregator.HackerNews,
  http_client: Test.Support.HackerNewsApiMock

config :news_aggregator, Toolkit.Paginator, default_page_size: 2
