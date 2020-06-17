defmodule HnAggregator.Hnews.Fetcher do
  require Logger

  use Task

  alias HnAggregator.Hnews.Api
  alias HnAggregator.Kv
  # To prevent hammering hnews's api, apply a little sleep between requests
  @sleep_between_requests 500
  @yield_tasks_interval 4 * 60 * 1000
  # Application.get_env(:hn_aggregator, :news_fetcher_interval)
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
    with {:ok, %{body: [_ | _], status_code: 200} = response} <- Api.topstories() do
      topstories =
        response.body
        |> Enum.slice(0..(fetch_max - 1))
        |> fetch_stories()

      Kv.insert(:topstories_ids, Enum.map(topstories, fn story -> story["id"] end))
      Kv.insert(:topstories_ordered, topstories)
      Logger.info("#{length(topstories)} top stories retrieved")

      :ok
    else
      {:error, response} ->
        Logger.error("An error occurred when retrieving topstories \n #{inspect(response)}")
        :error

      _ ->
        :error
    end
  end

  def fetch_story(story_id) when is_integer(story_id) do
    fetch_story(Integer.to_string(story_id))
  end

  def fetch_story(story_id) when is_binary(story_id) do
    Task.async(fn ->
      Process.sleep(@sleep_between_requests)
      Api.item(story_id)
    end)
  end

  def fetch_stories(stories_ids) when is_list(stories_ids) do
    stories_ids
    |> Enum.map(&fetch_story/1)
    |> Task.yield_many(@yield_tasks_interval)
    |> Enum.map(fn {task, result} ->
      result || Task.shutdown(task, :brutal_kill)
    end)
    |> Enum.map(fn
      {:ok, value} ->
        with {:ok, %{body: %{}, status_code: 200} = response} <- value do
          response.body
        else
          error ->
            Logger.error("An error occurred when retrieving an story \n #{inspect(error)}")
            :error
        end

      error ->
        Logger.error("An error occurred when retrieving an story \n #{inspect(error)}")
        :error
    end)
    |> Enum.filter(fn story -> story != :error end)
    |> Enum.sort_by(& &1["score"], :desc)
  end
end
