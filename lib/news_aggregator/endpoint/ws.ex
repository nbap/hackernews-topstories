defmodule NewsAggregator.Endpoint.Ws do
  @behaviour :cowboy_websocket

  alias NewsAggregator.HackerNews

  def init(req, opts) do
    {:cowboy_websocket, req, opts}
  end

  def websocket_init(state) do
    {:ok, state}
  end

  def websocket_handle({:text, "topstories"}, state) do
    {:ok, _} = Registry.register(Registry.EventWatcher, "evt_topstories", [])
    %{stories: stories, inserted_at: _} = HackerNews.get_topstories()

    {:reply, {:text, Jason.encode!(stories)}, state}
  end

  # Default fallback for unrecognized messages
  def websocket_handle({:text, _}, state) do
    {:ok, state, :hibernate}
  end

  def websocket_info(info, state) do
    {:reply, {:text, Jason.encode!(info)}, state}
  end
end
