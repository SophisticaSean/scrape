defmodule Scrape do

end

defmodule Scrape.CLI do
  def main(args) do
    args |> parse_args |> execute
  end

  def parse_args(args) do
    options = OptionParser.parse(args)
    case options do
      {[chan: chan], _, _} -> [chan]
      _ -> :help
    end
  end
  
  def execute([chan]) do
    IO.puts "CHAN IS A GO"
    Chan.download(chan)
  end

  def execute(:help) do
    IO.puts "lol no"
  end

  # System.halt(0)
end
