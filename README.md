# scrape
image scraper in elixir, currently can scrape images from 4chan threads

# Usage
compile:
```bash
mix escript.build
````
instead of compiling, you can just use the scrape executable

set download directory:
```bash
./scrape --dir path/to/download/dir
```
If dir is not set, it'll default to the current working directory

download all rare maymay images from 4chan thread:
```bash
./scrape --chan http://boards.4chan.org/vp/thread/210003
```


