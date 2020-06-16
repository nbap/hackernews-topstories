defmodule HnAggregator.Hnews.Fetcher do
  require Logger

  use Task

  @fetcher_interval 15_000

  def start_link(opts) do
    Task.start_link(__MODULE__, :run, opts)
  end

  def run() do
    fetch_topstories()
    schedule()
  end

  def schedule() do
    receive do
    after
      @fetcher_interval ->
        run()
    end
  end

  def fetch_topstories(fetch_max \\ 5) when fetch_max > 0 do
    Logger.info("top stories retrieved")
  end
end
