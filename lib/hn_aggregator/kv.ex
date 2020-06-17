defmodule HnAggregator.Kv do
  use GenServer

  @table_name Application.get_env(:hn_aggregator, :kv_table_name)

  def start_link(opts \\ []) do
    with {:ok, _} <- setup_table() do
      GenServer.start_link(__MODULE__, nil, opts)
    end
  end

  defp setup_table do
    try do
      {:ok, :ets.new(@table_name, [:named_table, :public, read_concurrency: true])}
    rescue
      _ -> {:error, :not_setup}
    end
  end

  def init(opts) do
    {:ok, opts}
  end

  @spec insert(any, any) :: true
  def insert(key, value) do
    :ets.insert(@table_name, {key, {value, DateTime.now!("Etc/UTC")}})
  end

  @spec find(any) :: [tuple]
  def find(key) do
    :ets.lookup(@table_name, key)
  end

  def find_topstories() do
    find(:topstories_ordered)
  end

  @spec clear_table :: true
  def clear_table() do
    :ets.delete_all_objects(@table_name)
  end
end
