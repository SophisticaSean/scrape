defmodule Scrape do

end

defmodule Scrape.CLI do
  def main(args) do
    args |> parse_args |> execute
  end

  def parse_args(args) do
    IO.puts(args)
    options = OptionParser.parse(args, switches: [])
    case options do
      {[chan: chan], _, _} -> {:chan, chan}
      {[dir: dir], _, _} -> {:dir, dir}
      _ -> {:help}
    end
  end

  def execute(tuple) do
    case tuple do
      {:chan, value} ->
        IO.puts "CHAN IS A GO"
        Chan.download(value)

      {:dir, value} ->
        case File.exists?(value) do
          true ->
            IO.puts "Setting default download directory"
            Crawl.push_config(:dl_directory, value)
          _ -> IO.puts "That path does not exist: #{value}"
        end

      _ -> IO.puts "No idea what you want mate"
    end
  end
  # System.halt(0)
end
