defmodule Imgur do

  @directory Crawl.dl_dir_check

  def temp(url) do
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
      |> imgur_domain_filter
    process_list = Enum.map(imgur_list, fn(x) -> spawn fn -> get_images(x, path) end end )
    Enum.map(process_list, fn(x) -> Crawl.wait_for_process(x) end)
  end

  def imgur_domain_filter(list) do
    Enum.filter(list, fn(x) -> Regex.match?(~r/imgur/, x) end)
  end

  def get_images(url, path) do
    url = Regex.replace(~r/^\/\//, to_string(url), "")
    page = Crawl.get(url)
    replace = fn(a, b, c) -> Regex.replace(b, a, c) end
    case String.valid?(page) do
      false ->
        uniq_id = replace.(url, ~r/i\.imgur.com\//, "")
        |> replace.(~r/http\:\/\//, "")
        |> replace.(~r/https\:\/\//, "")
        |> replace.(~r/\?.*/, "")

        filename = path <> "/" <> uniq_id
        # check if the file exists, if not dl it, write it and output the new file path
        unless elem(File.read(filename), 0) == :ok do
          File.write!(filename, page)
          IO.puts filename
        end
        IO.puts "downloading #{uniq_id}"
      _ ->
        images = Floki.find(page, "div.post-images")
          |> Floki.find("img")
          |> Enum.map(fn(i) -> Floki.attribute(i, "src") end)
        process_list = Enum.map(images, fn(x) -> spawn fn -> get_images(x, path) end end )
        Enum.map(process_list, fn(x) -> Crawl.wait_for_process(x) end)
    end
  end
end
