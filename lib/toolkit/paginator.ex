defmodule Toolkit.Paginator do
  @default_page_size Application.fetch_env!(:news_aggregator, __MODULE__)[
                       :default_page_size
                     ]

  @spec paginate([any], any) :: %{
          current_page: integer,
          page_content: [any],
          total_pages: integer
        }
  def paginate(content, page \\ 1)

  def paginate(content, page) when is_binary(page) do
    paginate(content, String.to_integer(page))
  end

  def paginate(content, page) when is_list(content) and page > 0 do
    content_length = length(content)
    total_pages = total_pages(content_length)

    page = if page > total_pages, do: total_pages, else: page

    %{
      total_pages: total_pages(content_length),
      page_content: page(content, page),
      current_page: page
    }
  end

  defp page(content, page) do
    offset = (page - 1) * @default_page_size
    Enum.slice(content, offset, @default_page_size)
  end

  defp total_pages(content_size) when is_integer(content_size) do
    cond do
      content_size > @default_page_size -> ceil(content_size / @default_page_size)
      true -> 1
    end
  end
end
