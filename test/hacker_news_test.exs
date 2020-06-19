defmodule HackerNewsTest do
  use ExUnit.Case

  alias NewsAggregator.HackerNews
  alias Toolkit.DataStore

  setup_all do
    start_supervised(DataStore)

    start_supervised(
      {Registry,
       keys: :duplicate,
       name: Registry.EventWatcher,
       partitions: System.schedulers_online()}
    )

    :ok
  end

  describe "when hackernews api is live and responding" do
    setup do
      HackerNews.FetchBot.fetch_topstories()
      :ok
    end

    test "fetch stories" do
      stories = HackerNews.get_topstories()
      %{stories: stories, inserted_at: _} = stories
      assert is_list(stories)
      assert length(stories) > 0
    end

    test "fetch story" do
      story_id = 1232
      story = HackerNews.get_story(story_id)
      %{story: story, inserted_at: _} = story
      assert story["id"] == story_id
    end

    test "fetch story when story id is binary" do
      story_id = 1232
      story = HackerNews.get_story(Integer.to_string(story_id))
      %{story: story, inserted_at: _} = story
      assert story["id"] == story_id
    end
  end

  describe "when hackernews api down" do
    setup do
      DataStore.clear_table()
      :ok
    end

    test "fetch stories" do
      stories = HackerNews.get_topstories()
      %{stories: stories, inserted_at: _} = stories
      assert is_list(stories)
      assert length(stories) == 0
    end

    test "fetch story" do
      story_id = 1232
      story = HackerNews.get_story(story_id)
      %{story: story, inserted_at: _} = story
      assert story == %{}
    end
  end

  test "retrieve config" do
    config = HackerNews.config()
    assert [_ | _] = config
  end
end
