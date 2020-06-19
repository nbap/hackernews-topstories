defmodule NewsAggregator.HackerNews do
  require Logger

  alias Toolkit.DataStore

  @spec get_topstories :: %{inserted_at: any, stories: list}
  def get_topstories() do
    {stories, inserted_at} =
      case DataStore.find_topstories() do
        [_ | _] = topstories ->
          {_key, {stories, inserted_at}} = hd(topstories)
          {stories, inserted_at}

        _ ->
          {[], DateTime.from_unix!(0)}
      end

    %{stories: stories, inserted_at: inserted_at}
  end

  @spec get_story(binary | integer) :: %{inserted_at: any, story: map}
  def get_story(story_id) when is_binary(story_id) do
    get_story(String.to_integer(story_id))
  end

  def get_story(story_id) when is_integer(story_id) do
    %{stories: stories, inserted_at: _} = get_topstories()
    story = Enum.find(stories, fn story -> story["id"] == story_id end) || %{}
    inserted_at = Map.get(story, :inserted_at, DateTime.from_unix!(0))

    %{story: story, inserted_at: inserted_at}
  end

  def config() do
    Application.fetch_env!(:news_aggregator, NewsAggregator.HackerNews)
  end
end
