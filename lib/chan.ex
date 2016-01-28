import Crawl

defmodule Chan do
  @doc """
  Chan.download() takes a 4chan url and downloads all images in it
  """
  def download(url) do
    base_dir = "/Users/sean/Pictures/forumstuff/.topkek/"
    page = get(url)
    # title = Regex.replace(~r/http\:\/\/boards.4chan.org\/\w*\/thread\/\d+\//, to_string(url), "")
    temp_title = Floki.text(hd(Floki.find(page, "span.subject")))
    title = Regex.replace(~r/ /, temp_title, "-")
    board = to_string(Regex.scan(~r/(?:http\:\/\/boards.4chan.org\/)(\w*)/, url, capture: :all_but_first))

    folder =
      case String.length(title) do
        0 -> base_dir <> "misc"
        _ -> board <> "/" <> title
      end

    spawn fn -> File.mkdir!(base_dir <> board) end
    spawn fn -> File.mkdir!(base_dir <> folder) end
    links = Floki.find(page, "a.fileThumb")
    processes = Enum.map(links, fn(x) -> spawn fn -> dl_pic(Floki.attribute(x, "href"), folder) end end)
    # IO.inspect processes
    # :timer.sleep(5000)
    # Enum.map(processes, fn(x) -> IO.inspect Process.info(x) end)
    wait_for_process(List.last(processes))
  end

  def dl_pic(url, folder) do
    url = Regex.replace(~r/\/\//, to_string(url), "")
    %HTTPoison.Response{body: body} = HTTPoison.get! url
    uniq_id = Regex.replace(~r/i\.4cdn\.org\/\w*\//, url, "")
    filename = "/Users/sean/Pictures/forumstuff/.topkek/" <> folder <> "/" <> uniq_id
    File.write!(filename, body)
    # IO.puts url <> " " <> filename
  end

  def wait_for_process(pid) do
    info = Process.info(pid)
    :timer.sleep(100)
    case info do
      nil -> nil
      _ -> wait_for_process(pid)
    end
  end
end
