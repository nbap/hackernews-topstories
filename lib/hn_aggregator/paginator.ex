defmodule HnAggregator.Paginator do
  alias __MODULE__

  @default_page_size 2

  def paginate(content, page \\ 1) when is_list(content) and page > 0 do
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
    if content_size > @default_page_size do
      ceil(content_size / @default_page_size)
    else
      1
    end
  end
end
