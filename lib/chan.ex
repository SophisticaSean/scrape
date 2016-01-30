import Crawl

defmodule Chan do
  @doc """
  Chan.download() takes a 4chan url and downloads all images in it
  """
  def download(url) do
    env_dict = Crawl.get_config
    base_dir = env_dict["dl_directory"]
    if base_dir == nil do
      IO.puts "No directory set, use '--dir some/dir' to set it"
      base_dir = System.cwd()
      IO.puts "Using current working directory instead: #{base_dir}"
    end

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

  def dl_pic(url, folder_path) do
    # replace the backslashes with nothing
    url = Regex.replace(~r/\/\//, to_string(url), "")
    uniq_id = Regex.replace(~r/i\.4cdn\.org\/\w*\//, url, "")
    filename = folder_path <> "/" <> uniq_id
    # check if the file exists, if not dl it, write it and output the new file path
    unless elem(File.read(filename), 0) == :ok do
      %HTTPoison.Response{body: body} = HTTPoison.get!(url, timeout: 10)
      File.write!(filename, body)
      IO.puts url <> " " <> filename
    end
  end

  def wait_for_process(pid) do
    info = Process.info(pid)
    :timer.sleep(10)
    case info do
      nil -> nil
      _ -> wait_for_process(pid)
    end
  end
end
