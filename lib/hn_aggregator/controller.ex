defmodule HnAggregator.Controller do
  use Plug.Router

  alias HnAggregator.Hnews

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  get "/stories" do
    %{stories: stories, inserted_at: inserted_at} = Hnews.Service.get_topstories()

    conn
    |> put_resp_content_type("application/json")
    |> put_resp_header("last-modified", DateTime.to_string(inserted_at))
    |> send_resp(200, Jason.encode!(stories))
  end

  get "/stories/:story_id" do
    %{story: story, inserted_at: inserted_at} = Hnews.Service.get_story(story_id)

    conn
    |> put_resp_content_type("application/json")
    |> put_resp_header("last-modified", DateTime.to_string(inserted_at))
    |> send_resp(200, Jason.encode!(story))
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
