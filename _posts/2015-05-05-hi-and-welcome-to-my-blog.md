---
title: 'Hi & Welcome to My Blog!'
date: 2015-05-05T18:43:24.000Z
tags:
  - Jekyll
  - Markdown
  - WebDev
  - jQuery
---

This is my new blog. It is powered by [Jekyll](http://jekyll.com). The theme is completely hand coded. With a lot of love and [CSS3](). I hope you like it.

You'll find this post in your `_posts` directory. Go ahead and edit it and rebuild the site to see your changes. You can rebuild the site in many different ways, but the most common way is to run `jekyll serve`, which launches a web server and auto-regenerates your site when a file is updated.
<!--/-->

To add new posts, simply add a file in the `_posts` directory that follows the convention `YYYY-MM-DD-name-of-post.ext` and includes the necessary front matter. Take a look at the source for this post to get an idea about how it works.

## Awesome Perks
- [carnival comments]()
- code highlighting
- blockquotes
- [kudos](http://amitu.com/2013/04/kudos-using-parse-for-jekyll/)
- tags
- [balance text](https://github.com/adobe-webplatform/balance-text)
- [google analytics]()

## Code Snippets
Jekyll also offers powerful support for code snippets with syntax highlighting and line numbering. It's pretty cool, check it out:

```js
// create <figure> with caption from <p><img>
$('article p img').unwrap().wrap('<figure></figure>').after(function() {
    return '<figcaption>'+this.alt+'</figcaption>';
});

// add linenumbers to <pre>
var table = '<table class="highlighttable"><tbody><tr></tr></tbody></table>';
$('article .highlight').wrap(table).before(function() {
    var out = '<td class="linenos"><div class="linenodiv"><pre><code>';
    var lines = $(this).text().split(/\n/).length;
    for ( var i=1; i<lines; i++ ) {
        out += i+'\n';
    }
    return out + '</code></pre></div></td>';
}).wrap('<td class="code"></td>');

// convert last <a> of blockquote into <cite>
$('article blockquote').append(function() {
    var cite = $(this).find('a').last();
    cite.remove();
    return cite;
}).children('a').wrap('<cite></cite>');
```

Check out the [Jekyll docs][jekyll] for more info on how to get the most out of Jekyll. File all bugs/feature requests at [Jekyll's GitHub repo][jekyll-gh]. If you have questions, you can ask them on [Jekyll's dedicated Help repository][jekyll-help].

> I'm 100% sure that once we release PrettyLights (our native highlighter), it will become the default in Jekyll. [Vicent Marti on GitHub](https://github.com/github/pages-gem/pull/79)

Vivamus dapibus tincidunt justo ut pulvinar. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Mauris blandit sollicitudin metus, a rutrum sapien mattis placerat. Nulla facilisi. Vestibulum vestibulum vitae nulla eu tristique. Sed lacinia venenatis dolor eu fermentum. Donec cursus ligula sit amet elementum rutrum. Vivamus posuere mollis dolor at vehicula. Suspendisse lobortis viverra justo quis sagittis.

## Images
![The inspiration for the color scheme of this blog](/assets/img/color-sheme.jpg)

[from](http://palettes.co/post/75914098457/photo-by-emmanuel-coupe)

Vivamus dapibus tincidunt justo ut pulvinar. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Mauris blandit sollicitudin metus, a rutrum sapien mattis placerat. Nulla facilisi. Vestibulum vestibulum vitae nulla eu tristique. Sed lacinia venenatis dolor eu fermentum. Donec cursus ligula sit amet elementum rutrum. Vivamus posuere mollis dolor at vehicula. Suspendisse lobortis viverra justo quis sagittis.

## LaTeX Typesetting
This even has support for $\LaTeX$[^1] typesetting if needed. It's a bit slow, but if you need mathematical formulas, this is the way to go. Here's the Shrödinger Equation for a wave function $\varphi(\vec{r},t)$:

$$ -\frac{\hbar^2}{2m} \;\nabla^2_{\vec{r}}\;\varphi(\vec{r},t) = \mathrm{i}\hbar\;\partial_t\;\varphi(\vec{r},t) $$

[http://carlosbecker.com/posts/jekyll-reading-time-without-plugins/](http://carlosbecker.com/posts/jekyll-reading-time-without-plugins/) [http://blog.webink.com/opentype-features-css/](http://blog.webink.com/opentype-features-css/)

[jekyll]: http://jekyllrb.com
[jekyll-gh]: https://github.com/jekyll/jekyll
[jekyll-help]: https://github.com/jekyll/jekyll-help
