#!/usr/bin/env bash
#
# Create ebook version of:
# https://bluesilvertranslations.wordpress.com/chapter-list/
#
# Working as of July 31, 2015
#
# Use ebook for personal use (e.g. kindle); and try not to distribute.
# For Andy D.
#
# Dependencies:
# https://github.com/jgm/pandoc (and Haskell)
# https://github.com/EricChiang/pup

story_downloader () {
    url="$1"

    html=$(curl -s "$url")

    # if html is empty; re-download
    if [ -z "$html" ]; then
        story_downloader "$url"
    else
        googledocsurl=$(echo "$html" | pup 'iframe attr{src}' | grep docs.google)

        title=$(echo "$html" | pup 'header > h1 text{}')
        docshtml=$(curl -s "$googledocsurl")

        echo "Downloading: $title"

        story=$(echo "$docshtml" | pup 'div#contents' | pandoc -f html -t markdown_strict)

        echo "# $title" >> dd.md
        echo -e '\n' >> dd.md
        echo "$story" >> dd.md
        echo -e '\n\n' >> dd.md
    fi
}


url='https://bluesilvertranslations.wordpress.com/chapter-list/'

# get chapter links
chapters=$(curl -s "$url" | pup '.entry-content > ul > li > a attr{href}')

# create new markdown file
>dd.md

while read -r line
do
  story_downloader "$line"
done <<<"$chapters"

echo "Converting to epub"

pandoc dd.md -o dd.epub

echo "Done"
