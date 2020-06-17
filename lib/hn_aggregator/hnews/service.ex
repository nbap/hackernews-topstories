defmodule HnAggregator.Hnews.Service do
  require Logger

  alias HnAggregator.Kv

  @spec get_topstories :: %{inserted_at: any, stories: any}
  def get_topstories() do
    {stories, inserted_at} =
      case Kv.find_topstories() do
        [_ | _] = topstories ->
          {_key, {stories, inserted_at}} = hd(topstories)
          {stories, inserted_at}

        _ ->
          {[], nil}
      end

    %{stories: stories, inserted_at: inserted_at}
  end

  def get_story(story_id) when is_binary(story_id) do
    get_story(String.to_integer(story_id))
  end

  def get_story(story_id) when is_integer(story_id) do
    %{stories: stories, inserted_at: inserted_at} = get_topstories()
    story = Enum.find(stories, fn story -> story["id"] == story_id end)
    %{story: story, inserted_at: inserted_at}
  end
end
