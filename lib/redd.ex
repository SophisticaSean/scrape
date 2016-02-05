defmodule Redd do

  @directory Crawl.dl_dir_check

  def subreddit_get(url, page_count \\ 1) do
    subreddit = Regex.scan(~r/r\/(.*)\//, url, capture: :all_but_first)
    |> hd
    |> to_string
    if subreddit == "" do
      raise "URL: #{url} is invalid"
    end

    path = @directory <> subreddit

    File.mkdir(path)

    page = Crawl.get(url)

    imgur_list = Crawl.find(page, "p.title > a")
      |> Enum.map(fn(x) -> Floki.attribute(x, "href") end)
      |> List.flatten
      |> Imgur.domain_filter
    next_link = Floki.find(page, "span.nextprev > a")
      |> Floki.attribute("href")
      |> hd
    if page_count > 0 do
      page_count = page_count - 1
      subreddit_get(next_link, page_count)
      process_list = Enum.map(imgur_list, fn(x) -> spawn fn -> Imgur.get_images(x, path) end end )
      Enum.map(process_list, fn(x) -> Crawl.wait_for_process(x) end)
    end
  end
end
