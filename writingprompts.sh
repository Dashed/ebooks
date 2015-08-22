#!/usr/bin/env bash
#
# Fetch reddit writing prompts and convert to ebook (i.e. epub).
#
# dependencies: jq, pandoc
#
# API reference: https://www.reddit.com/dev/api

SORT='week'
LIMIT='25'
STORIES_PER_PROMPT='10'

STAMP=$(date +%b-%d-%Y_%H.%M.%S)
FILENAME="writingprompt-${STAMP}"
MD_FILE="$FILENAME.md"
EPUB_FILE="$FILENAME.epub"

# create empty markdown file
>"$MD_FILE"

prompt_downloader () {
    comment_id="$1"

    # fetch comments
    comments=$(curl -s "https://www.reddit.com/comments/$comment_id.json?depth=0&limit=$STORIES_PER_PROMPT&sort=confidence&showmore=false")

    # fetch prompt info
    prompt_info=$(echo "$comments" | jq '.[0].data.children[] | {selftext: .data.selftext, author: .data.author, title: .data.title}')
    title=$(echo "$prompt_info" | jq --raw-output '.title')
    author=$(echo "$prompt_info" | jq --raw-output '.author')
    selftext=$(echo "$prompt_info" | jq --raw-output '.selftext')

    echo "Fetching: $title"

    echo "# $title" >> "$MD_FILE"
    echo -e '\n\n' >> "$MD_FILE"

    echo "**URL:** reddit.com/comments/$comment_id" >> "$MD_FILE"
    echo -e '\n\n' >> "$MD_FILE"

    echo "**Prompt:** $title" >> "$MD_FILE"
    echo -e '\n\n' >> "$MD_FILE"

    echo "**Prompt by:**: $author" >> "$MD_FILE"
    echo -e '\n\n' >> "$MD_FILE"

    echo "**Self-text:**: $selftext" >> "$MD_FILE"
    echo -e '\n\n' >> "$MD_FILE"

    # fetch stories
    # stories=$(echo "$comments" | jq '.[1].data.children[] | {story: .data.body, author: .data.author}')
    stories=$(echo "$comments" | jq --raw-output '.[1].data.children[] | "## \(.data.author) \n\n \(.data.body) \n\n"')

    echo "$stories" >> "$MD_FILE"
}

# fetch list of prompts
# note: --raw-output to remove quotes
prompts=$(curl -s "https://www.reddit.com/r/WritingPrompts/top.json?t=$SORT&limit=$LIMIT" | jq --raw-output '.data.children[] | select(.data.title | contains("[WP]")) | .data.id')

while read -r line
do
    prompt_downloader "$line"
done <<<"$prompts"

echo "Converting to epub"

pandoc "$MD_FILE" -f markdown -o "$EPUB_FILE"

echo "Done"
