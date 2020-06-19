defmodule NewsAggregator.HackerNews.Api do
  use HTTPoison.Base

  alias __MODULE__

  @base_url NewsAggregator.HackerNews.config()[:base_url]

  def process_request_url(resource) do
    @base_url <> resource
  end

  def process_request_options(options) do
    Keyword.put(options, :ssl, [{:versions, [:"tlsv1.2"]}])
  end

  def process_response_body(body) do
    Jason.decode!(body)
  end

  @spec item(any) :: {:error, HTTPoison.Error.t()} | {:ok, HTTPoison.Response.t()}
  def item(id) do
    Api.get("item/#{id}.json")
  end

  @spec topstories :: {:error, HTTPoison.Error.t()} | {:ok, HTTPoison.Response.t()}
  def topstories do
    Api.get("topstories.json")
  end
end
