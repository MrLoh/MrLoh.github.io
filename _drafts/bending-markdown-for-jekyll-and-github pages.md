---
title: Bending Markdown for Jekyll and GitHub Pages
date: 2015-05-05T18:43:24.000Z
tags:
  - Jekyll
  - Markdown
  - GitHub
  - WebDev
  - jQuery
  - HTML
keywords:
  - RedCarpet
  - GitHub Pages
  - Kramdown
  - JavaScript
---

Git flavoured markdown ([GFM]())

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



> I'm 100% sure that once we release PrettyLights (our native highlighter), it will become the default in Jekyll. [Vicent Marti on GitHub](https://github.com/github/pages-gem/pull/79)
