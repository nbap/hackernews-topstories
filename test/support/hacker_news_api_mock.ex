defmodule Test.Support.HackerNewsApiMock do
  use HTTPoison.Base

  {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(Map.new())}}

  def item(id) do
    response = %{
      "id" => String.to_integer(id),
      "score" => Faker.Random.Elixir.random_between(1, 500),
      "title" => Faker.Lorem.Shakespeare.king_richard_iii()
    }

    {:ok,
     %HTTPoison.Response{
       status_code: 200,
       body: response
     }}
  end

  def topstories do
    response = [1231, 1232, 1233, 1234, 1235]

    {:ok,
     %HTTPoison.Response{
       status_code: 200,
       body: response
     }}
  end
end
