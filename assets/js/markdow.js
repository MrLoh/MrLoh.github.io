// create figures with captions from p>img in article
$('article p img').unwrap().wrap('<figure></figure>').after(function() {
	return '<figcaption>'+this.alt+'</figcaption>';
});

// add linenumbers to pre
$('article div.highlight').wrap('<table class="highlighttable"><tbody><tr></tr></tbody></table>').before(function() {
	var out = '<td class="linenos"><div class="linenodiv"><pre><code>';
	var lines = $(this).text().split(/\n/).length;
	for ( var i=1; i<lines; i++ ) {
		out += i+'\n';
	}
	return out + '</code></pre></div></td>';
}).wrap('<td class="code"></td>');
