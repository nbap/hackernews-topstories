defmodule PaginatorTest do
  use ExUnit.Case

  alias Toolkit.Paginator

  setup_all do
    default_page_size =
      Application.fetch_env!(:news_aggregator, Toolkit.Paginator)[:default_page_size]

    [default_page_size: default_page_size]
  end

  test "paginate", context do
    entries =
      Faker.Util.sample_uniq(5, fn -> Faker.Random.Elixir.random_between(10, 99) end)

    %{
      current_page: current_page,
      page_content: page_content,
      total_pages: total_pages
    } = Paginator.paginate(entries)

    assert current_page == 1
    assert length(page_content) == context[:default_page_size]
    assert total_pages == ceil(length(entries) / context[:default_page_size])
  end

  test "paginate less elements than page size" do
    entries = [Faker.String.base64()]

    %{
      current_page: current_page,
      page_content: _,
      total_pages: total_pages
    } = Paginator.paginate(entries)

    assert current_page == total_pages
  end
end
