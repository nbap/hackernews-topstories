defmodule HnAggregator.Controller do
  use Plug.Router

  alias HnAggregator.Hnews
  alias HnAggregator.Paginator

  plug(HnAggregator.ThrottlePlug)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:respond_json)
  plug(:dispatch)

  get "/stories" do
    %{stories: stories, inserted_at: inserted_at} = Hnews.Service.get_topstories()

    page =
      conn.params
      |> Map.get("page", "1")
      |> String.to_integer()

    paginator = Paginator.paginate(stories, page)

    conn
    |> put_resp_header("last-modified", DateTime.to_string(inserted_at))
    |> put_resp_header("x-total-pages", Integer.to_string(paginator.total_pages))
    |> put_resp_header("x-current-page", Integer.to_string(paginator.current_page))
    |> put_resp_header("last-modified", DateTime.to_string(inserted_at))
    |> send_resp(200, Jason.encode!(paginator.page_content))
  end

  get "/stories/:story_id" do
    %{story: story, inserted_at: inserted_at} = Hnews.Service.get_story(story_id)

    conn
    |> put_resp_header("last-modified", DateTime.to_string(inserted_at))
    |> send_resp(200, Jason.encode!(story))
  end

  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "Not Found"}))
  end

  defp respond_json(%Plug.Conn{} = conn, _),
    do: put_resp_content_type(conn, "application/json")
end
