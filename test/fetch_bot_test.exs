defmodule FetchBotTest do
  use ExUnit.Case

  alias NewsAggregator.HackerNews.FetchBot
  alias Toolkit.DataStore

  setup do
    start_supervised(DataStore)

    start_supervised(
      {Registry,
       keys: :duplicate,
       name: Registry.EventWatcher,
       partitions: System.schedulers_online()}
    )

    :ok
  end

  test "scheduled task running" do
    DataStore.clear_table()
    start_supervised(FetchBot)
    Process.sleep(100)
    assert [_ | _] = DataStore.find_topstories()
  end
end
