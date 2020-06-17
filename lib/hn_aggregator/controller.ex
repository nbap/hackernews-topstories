defmodule HnAggregator.Controller do
  use Plug.Router

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  get "/stories" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, "hello")
  end

  get "/stories/:story_id" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, "hello")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
