#!/usr/bin/env zsh

tab='    '
for dir in posts/*/; do
    author=$(basename $dir)
    # index=/dev/stdout
    index="$dir/index.html"

    echo '<!DOCTYPE html>\n<html>' >$index
    echo "<h1>$author's Posts</h1>" >>$index

    echo "Processing posts for author $author"

    # blog posts files, sorted in reverse alphabetical order (name of post should be date %Y-%M-%D.md)
    posts=("${(@f)$(find $dir -name '*.html' ! -name index.html | sort -r)}")
    [[ -z "$posts" ]] && echo "No posts for author $author" && rm -f $index && continue

    for post in $posts; do
        title=$(ag -o '(?<=<h1>).*?(?=</h1>)' $post)
        echo "$tab<a href=\"$post\">$title</a>" >>$index
    done

    echo "</html>" >>$index
done
