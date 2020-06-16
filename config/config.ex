import Config

config :hn_aggregator,
  kv_table_name: :hn_topstories,
  news_fetcher_interval: 5_000,
