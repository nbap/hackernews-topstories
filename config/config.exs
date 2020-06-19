import Config

config :hn_aggregator, HnAggregator.Hnews.Fetcher,
  news_fetcher_interval: 5_000,
  sleep_between_requests: 500,
  yield_tasks_interval: 4 * 60 * 1000

config :hn_aggregator, HnAggregator.Hnews.Api,
  base_url: "https://hacker-news.firebaseio.com/v0/"

config :hn_aggregator, HnAggregator.Kv, kv_table_name: :hn_topstories

config :hn_aggregator, HnAggregator.Paginator, default_page_size: 2

config :hn_aggregator, HnAggregator.ThrottlePlug,
  storage: HnAggregator.ThrottlePlug.Storage,
  clean_period: 60_000
