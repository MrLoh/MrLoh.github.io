---
title: Bending Markdown for Jekyll & GitHub Pages
date: 2015-05-26-15:45
tags: [Jekyll, Markdown, GitHub Pages, Web Development, jQuery, HTML]
description: 'jQuery Work-arounds for customizing Markdown conversion for figure tags and code-blocks with line numbers, using RedCarpet for Jekyll on GitHub Pages'
---

If you are using [Jekyll](http://jekyllrb.com) you probably love writing in [Markdown](http://daringfireball.net/projects/markdown/syntax). So do I and over time I've really gotten used to so called GitHub flavored markdown ([GFM](https://help.github.com/articles/github-flavored-markdown/)). This adds some nice features to Markdown, most notably: strike-through, checkmarks, tables, **and** fenced code blocks [^1]. One might think that when using Jekyll on [GitHub Pages](https://pages.github.com/) it would be standard to have GFM, but it's not that simple.

There are three main contenders as your markdown parser for Jekyll: [Redcarpet](https://github.com/vmg/redcarpet), [kramdown](http://kramdown.gettalong.org/index.html), and [RDiscount](http://dafoster.net/projects/rdiscount/). If you want fenced code blocks with syntax highlighting (via [Pygments](http://pygments.org)) to work properly on GitHub Pages, you should probably use Redcarpet. You can read more about why in [this blogpost](http://ajoz.github.io/2014/06/29/i-want-my-github-flavored-markdown/). GitHub Pages even supports version 3.1.2 of Redcarpet now, so you can use footnotes --- you can check the currently used version with `$ github-pages versions`.

However, there are still some things that are not possible. GitHub Pages doesn't allow you to use any custom plugins (understandably they do not want to run random code on their servers). So anything that is not build in, is not possible to do with the markdown compiler. For example I really like semantic markup for my image captions:

```html
![Image Caption](/image_path.jpg)

<!-- should become -->

<figure>
    <img src="/image_path.jpg" alt="Image Caption">
    <figcaption>Image Caption</figcaption>
</figure>
```


## The only solution at the moment: jQuery

There is no option to do these things with the converter, so we have to bend [^2] the rules of Jekyll a little and change the HTML on the front end instead. Since I have [jQuery](http://jquery.com/) included on my site anyways, it's simple enough to do that and it doesn't need many resources. To get the image captions we just unwrap all `img` tags from their `p` container tags and wrap them in `figure` tags instead and than add the `alt` attribute inside a `figcaption` tag like this:

```js
// create <figure> with caption from <p><img>
$('article p img').unwrap().wrap('<figure></figure>').after(function() {
    return '<figcaption>'+this.alt+'</figcaption>';
});
```

I also wanted to have line-numbers on my code block, just in the way they are rendered by pygments, if you use liquid code blocks like `{% raw %}{% codeblock js linenos:true %}{% endraw %}`. The following jQuery does the job:

```js
// add line-number to <pre> and wrapt in <table>
var table = '<table class="highlighttable"><tbody><tr></tr></tbody></table>';
$('article .highlight').wrap(table).before(function() {
    var out = '<td class="linenos"><div class="linenodiv"><pre><code>';
    var lines = $(this).text().split(/\n/).length;
    for ( var i=1; i<lines; i++ ) {
        out += i+'\n';
    }
    return out + '</code></pre></div></td>';
}).wrap('<td class="code"></td>');
```

And while we're at it, why not make sure that links only have non-breaking whitespace `&nbsp;` --- mainly because that breaks my link-hover animation, but also because those are often names. And make sure those external links open in a new tab by default with `target='_blank'`, but only if they are not footnote links of course.

```js
// prevent line-breaks in links and make open in new tab
$('article a').not('[rel="footnote"], [rev="footnote"]').html(function(i, str) {
    return str.replace(/ /g,'&nbsp;');
}).attr('target','_blank');
```

## Is there hope for a better solution in the future?

This solution is of course a little dirty, because it doesn't compile the final HTML and serves it statically. So is there hope this could be done on the backend? Not so much unless you are willing to precompile the whole site locally and not via GitHub Pages, which of course is an option. The Markdown converter on GitHub will probably also stay uncustomizable in the future, but maybe some more functionality (like figures and line-numbers in code blocks) could be added. GitHub also seems to be working on their own Markdown editor, so that might bring some change.

> I'm 100% sure that once we release PrettyLights (our native highlighter),
> it will become the default in Jekyll.
> [Vicent Marti on GitHub](https://github.com/github/pages-gem/pull/79)

However, in the end the jQuery solution is pretty fast, it's easy enough to handle fallbacks and it's certainly very flexible. So I'm happy with it for now.


[^1]: You know, the ones marked with ```` ```js ```` for example.
[^2]: Yes, this is an implicit reference to [Avatar the Last Airbender](http://avatar.wikia.com/wiki/Bending_arts). I loved the original show, but also the Legend of Korra.
