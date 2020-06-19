defmodule NewsAggregator.HackerNews.FetchBot do
  require Logger

  use Task

  alias Toolkit.DataStore

  @config NewsAggregator.HackerNews.config()

  @http_client @config[:http_client]
  @interval_between_requests @config[:interval_between_requests]
  @yield_tasks_timeout @config[:yield_tasks_timeout]
  @fetch_interval @config[:fetch_interval]

  @spec start_link([any]) :: {:ok, pid}
  def start_link(opts) do
    Task.start_link(__MODULE__, :run, opts)
  end

  @spec run :: no_return
  def run() do
    fetch_topstories()
    schedule()
  end

  @spec schedule :: no_return
  def schedule() do
    receive do
    after
      @fetch_interval -> run()
    end
  end

  @spec fetch_topstories(any) :: :error | :ok
  def fetch_topstories(fetch_max \\ 50) when fetch_max > 0 do
    case @http_client.topstories() do
      {:ok, %{body: [_ | _], status_code: 200} = response} ->
        topstories =
          response.body
          |> Enum.slice(0..(fetch_max - 1))
          |> fetch_stories()

        store_result(topstories)
        dispatch_event(topstories)
        :ok

      error ->
        Logger.error("An error occurred when retrieving topstories \n #{inspect(error)}")
        :error
    end
  end

  @spec fetch_story(binary | integer) :: Task.t()
  def fetch_story(story_id) when is_integer(story_id) do
    fetch_story(Integer.to_string(story_id))
  end

  def fetch_story(story_id) when is_binary(story_id) do
    Task.async(fn ->
      Process.sleep(@interval_between_requests)
      @http_client.item(story_id)
    end)
  end

  @spec fetch_stories(list) :: [any]
  def fetch_stories(stories_ids) when is_list(stories_ids) do
    tasks =
      stories_ids
      |> Enum.map(&fetch_story/1)
      |> Task.yield_many(@yield_tasks_timeout)
      |> Enum.map(fn {task, result} ->
        result || Task.shutdown(task, :brutal_kill)
      end)

    results =
      Enum.map(tasks, fn task ->
        case task do
          {:ok, {:ok, %{body: %{}, status_code: 200} = response}} ->
            response.body

          error ->
            "An error occurred when retrieving an story \n #{inspect(error)}"
            |> Logger.error()

            :error
        end
      end)

    results
    |> Enum.filter(fn story -> story != :error end)
    |> Enum.sort_by(& &1["score"], :desc)
  end

  defp store_result(result) do
    DataStore.insert(:topstories_ids, Enum.map(result, fn story -> story["id"] end))
    DataStore.insert(:topstories_ordered, result)
    Logger.info("#{length(result)} top stories retrieved")
  end

  defp dispatch_event(message) do
    Registry.dispatch(Registry.EventWatcher, "evt_topstories", fn entries ->
      for {pid, _} <- entries do
        if pid != self() do
          Process.send(pid, message, [])
        end
      end
    end)
  end
end
