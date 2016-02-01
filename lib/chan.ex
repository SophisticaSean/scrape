import Crawl

defmodule Chan do
  @doc """
  Chan.download() takes a 4chan url and downloads all images in it
  """
  def download(url) do
    base_dir = Crawl.dl_dir_check

    page = get(url)
    temp_title = Floki.text(hd(Floki.find(page, "span.subject")))
    title = Regex.replace(~r/ /, temp_title, "-")
    title = Regex.replace(~r/\//, title, "")
    board = to_string(Regex.scan(~r/(?:http\:\/\/boards.4chan.org\/)(\w*)/, url, capture: :all_but_first))

    folder =
      case String.length(title) do
        0 -> board <> "/" <> "misc"
        _ -> board <> "/" <> title
      end

    File.mkdir(base_dir <> board)
    File.mkdir(base_dir <> folder)
    links = Floki.find(page, "a.fileThumb")
    processes = Enum.map(links, fn(x) -> spawn fn -> dl_pic(Floki.attribute(x, "href"), base_dir <> folder) end end)
    Enum.map(processes, fn(x) -> wait_for_process(x) end )
    IO.puts "Done"
  end

  @doc """
    Takes a 4chan img url and downloads it if it does not already exist
  """
  def dl_pic(url, folder_path) do
    # replace the backslashes with nothing
    url = Regex.replace(~r/\/\//, to_string(url), "")
    uniq_id = Regex.replace(~r/i\.4cdn\.org\/\w*\//, url, "")
    filename = folder_path <> "/" <> uniq_id
    # check if the file exists, if not dl it, write it and output the new file path
    unless elem(File.read(filename), 0) == :ok do
      %HTTPoison.Response{body: body} = HTTPoison.get!(url, timeout: 10)
      File.write!(filename, body)
      IO.puts filename
    end
  end
end
