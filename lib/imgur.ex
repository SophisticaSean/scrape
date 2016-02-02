import Crawl

defmodule Imgur do

  @directory Crawl.dl_dir_check

  def temp(url) do
    subreddit = to_string(Regex.scan(~r/r\/(.*)/, url, capture: :all_but_first))
    if subreddit == "" do
      raise "URL: #{url} is invalid"
    end

    page = Crawl.get(url)
    titles = Crawl.find(page, "p.title > a")
    img_links = List.flatten(Enum.map(titles, fn(x) -> Floki.attribute(x, "href") end))
    imgur_list = Enum.filter(img_links, fn(x) -> Regex.match?(~r/imgur/, x) end)
  end

  def album_or_img(url) do
    IO.puts url

  end

  def directory() do
    IO.puts @directory
  end

  def get_imgs_from_album(url, path) do
    page = Crawl.get(url)
    images = Floki.find(page, "div.post-images > div > div > a")
    Enum.map(images, fn(i) -> get_image(Floki.attribute(i, "href"), path) end)
  end

  def get_image(url, path) do
    IO.puts(url)
  end

end
