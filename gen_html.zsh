#!/usr/bin/env zsh

cd html

tab='    '

index='index.html'
echo '<!DOCTYPE html>\n<html>' >$index
echo '<head>\n<link rel="stylesheet" href="styles.css">\n</head>' >>$index
echo '<header class="main-header" role="banner">\n<img src="img/logo.png">\n</header>' >>$index
echo '<h2>Latest Posts</h2>' >>$index

echo '<body>' >>$index
for dir in posts/*/; do
    dir=$(perl -pe 's|/$||' <(echo $dir))
    author=$(basename $dir)

    echo "Processing posts for author $author"

    # blog posts files, sorted in reverse alphabetical order (name of post should start with date %Y-%M-%D*.html)
    posts=("${(@f)$(find $dir -name '*.html' ! -name index.html | sort -r)}")
    [[ -z "$posts" ]] && echo "No posts for author $author" && continue

    author_index="$dir/index.html"
    echo '<!DOCTYPE html>\n<html>' >$author_index
    echo "<h1>$author's Posts</h1>" >>$author_index

    i=0
    for post in $posts; do
        title=$(ag -o '(?<=<h1>).*?(?=</h1>)' $post | head -n1)
        if ((i==0)); then # put entry into main page's latest posts
            echo "$tab<a href=\"$post\">$title</a> by <a href=\"$author_index\">$author</a><br/>" >>$index
        fi
        echo "$tab<a href=\"$post\">$title</a><br/>" >>$author_index
        ((i++))
    done

    echo "</html>" >>$author_index
done

echo '</body>\n</html>' >>$index

cd ..
