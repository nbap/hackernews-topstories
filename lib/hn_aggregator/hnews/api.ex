defmodule HnAggregator.Hnews.Api do
  use HTTPoison.Base

  @base_url "https://hacker-news.firebaseio.com/v0/"
  alias __MODULE__

  def process_request_url(resource) do
    @base_url <> resource
  end

  def process_request_options(options) do
    options
    |> Keyword.put(:ssl, [{:versions, [:"tlsv1.2"]}])
  end

  def process_response_body(body) do
    body
    |> Jason.decode!()
  end

  @spec item(any) ::
          {:error, HTTPoison.Error.t()}
          | {:ok,
             %{
               :__struct__ => HTTPoison.AsyncResponse | HTTPoison.Response,
               optional(:body) => any,
               optional(:headers) => [any],
               optional(:id) => reference,
               optional(:request) => HTTPoison.Request.t(),
               optional(:request_url) => any,
               optional(:status_code) => integer
             }}
  @doc """
  Expected response's format
    {
      "by":"doener",
      "descendants":148,
      "id":23271624,
      "kids":[23272482,23277910,23274992,23271761,23272618],
      "score":287,
      "time":1590153014,
      "title":"Pac-Man recreated with a GAN trained on 50k game episodes",
      "type":"story",
      "url":"https://blogs.nvidia.com/blog/2020/05/22/gamegan-research-pacman-anniversary/"
    }
  """
  def item(id) do
    Api.get("item/#{id}.json")
  end

  @doc """
    Expected response's format
    [ 23319901, 23317800, 23322253, 23320974, 23320803, 23318137, 23321048, ...]
  """
  @spec topstories ::
          {:error, HTTPoison.Error.t()}
          | {:ok,
             %{
               :__struct__ => HTTPoison.AsyncResponse | HTTPoison.Response,
               optional(:body) => any,
               optional(:headers) => [any],
               optional(:id) => reference,
               optional(:request) => HTTPoison.Request.t(),
               optional(:request_url) => any,
               optional(:status_code) => integer
             }}
  def topstories do
    Api.get("topstories.json")
  end
end
