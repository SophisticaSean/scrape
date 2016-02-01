import Crawl

defmodule Imgur do

  @directory Crawl.dl_dir_check

  def temp(url) do
    page = Crawl.get(url)
    titles = Crawl.find(page, "p.title > a")
    Enum.map(titles, fn(x) -> IO.inspect(Floki.attribute(x, "href")) end )
  end

  def album_or_img(url) do
    IO.puts url

  end

  def directory() do
    IO.puts @directory
  end

  def get_imgs_from_album(url, path) do

  end

  def get_image(url, path) do

  end

end
