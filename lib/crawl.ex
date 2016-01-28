defmodule Crawl do
  @doc """
    takes a URL and grabs all hrefs on the page
  """
  def crawl(url) do
    page = get(url)
    a_elements = find(page, "a.choice")
    urls = Enum.uniq(Enum.map(a_elements, fn(a) -> Floki.attribute(a, "href") end))
    List.delete(urls, [url])
    IO.puts length(urls)
    IO.puts url
    # @not_visited = Enum.uniq((@not_visited ++ urls))
    # Enum.map(tl(urls), fn(x) -> crawl(x) end)
    # urls
    Enum.map(urls, fn(url) -> spawn fn -> Crawl.crawl(url) end end)
  end

  @doc """
  accepts a URL and returns that page or an empty array
  """
  def get(url) do
    try do
      page = HTTPoison.get! url
      page.body || []
    rescue
      HTTPoison.HTTPError -> []
    end
  end

  @doc """
  accepts some HTML and something to select by, returns nodes that match that selector(s)
  """
  def find(html, selector) do
    Floki.find(html, selector)
  end
end
