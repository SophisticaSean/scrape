defmodule Redd do

  @directory Crawl.dl_dir_check

  def subreddit_get(url) do
    subreddit = to_string(Regex.scan(~r/r\/(.*)/, url, capture: :all_but_first))
    if subreddit == "" do
      raise "URL: #{url} is invalid"
    end

    path = @directory <> subreddit

    File.mkdir(path)

    imgur_list = Crawl.get(url)
      |> Crawl.find("p.title > a")
      |> Enum.map(fn(x) -> Floki.attribute(x, "href") end)
      |> List.flatten
      |> Imgur.domain_filter
    process_list = Enum.map(imgur_list, fn(x) -> spawn fn -> Imgur.get_images(x, path) end end )
    Enum.map(process_list, fn(x) -> Crawl.wait_for_process(x) end)
  end
end
