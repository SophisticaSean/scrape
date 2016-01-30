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

  def get_config do
    env_json = File.read("config.json")
    case env_json do
      {:error, :enoent} ->
        File.write("config.json", "{}")
        HashDict.new()
      _ ->
        env_json = elem(env_json, 1)
        elem(JSX.decode(env_json), 1)
    end
  end

  def push_config(key, value) do
    env_dict = get_config
    env_dict = Dict.put(env_dict, key, value)
    env_dict = JSX.encode(env_dict)
    File.write("config.json", elem(env_dict, 1))
  end

  def clear_config do
    File.write("config.json", "{}")
  end
end
