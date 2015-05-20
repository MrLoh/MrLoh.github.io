$(function() {
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

	// make links in article open in new tab
	$('article a').attr('target','_blank').html(function(i, str) {
		return str.replace(/ /g,'&nbsp;');
	});
});
