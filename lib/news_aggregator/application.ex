defmodule NewsAggregator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {PlugAttack.Storage.Ets,
       name:
         Application.fetch_env!(:news_aggregator, NewsAggregator.Endpoint.ThrottlePlug)[
           :storage
         ],
       clean_period:
         Application.fetch_env!(:news_aggregator, NewsAggregator.Endpoint.ThrottlePlug)[
           :clean_period
         ]},
      Toolkit.DataStore,
      NewsAggregator.HackerNews.FetchBot,
      {Registry,
       keys: :duplicate,
       name: Registry.EventWatcher,
       partitions: System.schedulers_online()},
      {Plug.Cowboy, scheme: :http, plug: nil, options: [port: 4001, dispatch: dispatch()]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NewsAggregator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch() do
    [
      {:_,
       [
         {"/ws/[...]", NewsAggregator.Endpoint.Ws, %{}},
         {:_, Plug.Cowboy.Handler, {NewsAggregator.Endpoint.Web, []}}
       ]}
    ]
  end
end
