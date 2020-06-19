defmodule HnAggregator.ThrottlePlug do
  use PlugAttack

  import Plug.Conn

  @storage Application.fetch_env!(:hn_aggregator, HnAggregator.ThrottlePlug)[:storage]

  rule "do not throttle localhost", conn do
    allow(conn.remote_ip == {127, 0, 0, 1})
  end

  def allow_action(conn, {:throttle, _data}, opts) do
    allow_action(conn, true, opts)
  end

  def allow_action(conn, _data, _opts) do
    conn
  end

  def block_action(conn, {:throttle, _data}, opts) do
    block_action(conn, false, opts)
  end

  def block_action(conn, _data, _opts) do
    conn
    |> send_resp(:forbidden, "Forbidden\n")
    |> halt
  end

  rule "ip throttle", conn do
    throttle(conn.remote_ip,
      period: 60_000,
      limit: 30,
      storage: {PlugAttack.Storage.Ets, @storage}
    )
  end
end
