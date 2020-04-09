#!/usr/bin/env zsh

tab() {
    printf '  %.0s' {1..$1}
}

cd html
index='index.html'
cp ../home.template.html $index

latest_posts=''
for dir in posts/*/; do
    dir=$(perl -pe 's|/$||' <(echo $dir))
    author=$(basename $dir)

    echo "Processing posts for author $author"

    # blog post files, sorted in reverse alphabetical order (name of post should start with date %Y-%M-%D*.html)
    posts=("${(@f)$(find $dir -name '*.html' ! -name index.html -exec basename {} \; | sort -r)}")
    [[ -z "$posts" ]] && echo "No posts for author $author" && continue

    author_index="$dir/index.html"
    cp ../author.template.html $author_index
    perl -pi -e "s|{author}|$author|" $author_index

    i=0
    author_posts=''
    for post in $posts; do
        title=$(ag -o '(?<=<h1>).*?(?=</h1>)' $dir/$post | head -n1)
        if ((i==0)); then # put entry into main page's latest posts
            latest_posts+="\n$(tab 2)<a href=\"$dir/$post\">$title</a> by <a href=\"$author_index\">$author</a><br/>"
        fi
        author_posts+="\n$(tab 2)<a href=\"$post\">$title</a><br/>"
        ((i++))
    done
    perl -pi -e "s|{posts}|$author_posts|" $author_index
done

perl -pi -e "s|{latest_posts}|$latest_posts|" $index

cd ..
