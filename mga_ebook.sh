#!/usr/bin/env bash
#
# Create ebook version of:
# http://www.wuxiaworld.com/mga-index/
#
# Working as of June 7, 2015
#
# Use ebook for personal use (e.g. kindle); and try not to distribute.
#
# Dependencies:
# https://github.com/jgm/pandoc (and Haskell)
# https://github.com/EricChiang/pup

story_downloader () {
    url="$1"

    html=$(curl -s "$url")

    if [ -z "$html" ]; then
        story_downloader "$url"
    else
        title=$(echo "$html" | pup 'h1.entry-title text{}')

        echo "Downloading: $title ${#html}"

        story=$(echo "$html" | pup 'div.entry-content' | pandoc -f html -t markdown_strict)

        echo "# $title" >> mga.md
        echo -e '\n' >> mga.md
        echo "$story" >> mga.md
        echo -e '\n\n' >> mga.md
    fi
}

# start link
url="http://www.wuxiaworld.com/mga-index/"

# get chapter links
chapters=$(curl -s "$url" | pup '.entry-content > p > a attr{href}' | grep "chapter")

>mga.md

while read -r line
do
  story_downloader "$line"
done <<<"$chapters"

echo "Converting to epub"

pandoc mga.md -o mga.epub

echo "Done"
