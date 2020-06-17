defmodule HnAggregator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: HnAggregator.Worker.start_link(arg)
      # {HnAggregator.Worker, arg}
      HnAggregator.Kv,
      HnAggregator.Hnews.Fetcher,
      {Plug.Cowboy, scheme: :http, plug: nil, options: [port: 4001, dispatch: dispatch()]},
      {Registry,
       keys: :duplicate, name: Registry.EventWatcher, partitions: System.schedulers_online()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HnAggregator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch() do
    [
      {:_,
       [
         {"/ws/[...]", HnAggregator.Ws, %{}},
         {:_, Plug.Cowboy.Handler, {HnAggregator.Controller, []}}
       ]}
    ]
  end
end
