$(function() {
	// find {.class} instances and translate them
	$('article .content > *').addClass(function() {
		var classFound = $(this).text().trim().match(/\{\..*\}$/);
		if ( classFound ) {
			console.log(this);
			$(this).html($(this).html().trim().split(classFound[0]).join(''));
			classNames = classFound[0].trim().substring(1, classFound[0].length-1).split(/\W/g).join(" ").trim();
			return classNames;
		}
	});

	// create <figure> with caption from <p><img>
	$('article p img').after(function() {
		classes = $(this).parent().attr('class');
		if ( $(this).parent().text().trim() === "" ) {
			if ( classes ) {
				$(this).unwrap().wrap('<figure class="' + classes + '"></figure>');
			} else {
				$(this).unwrap().wrap('<figure></figure>');
			}
		} else {
			$(this).wrap('<figure class="left"></figure>');
		}
		return '<figcaption>'+this.alt+'</figcaption>';
	});

	// add linenumbers to <pre>
	var table = '<table class="highlighttable"><tbody><tr></tr></tbody></table>';
	$('article .content > .highlight, article .content > .highlighter-rouge').wrap(table).before(function() {
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
	$('article a').not('[rel="footnote"], [rev="footnote"], .footnote, .reversefootnote').html(function(i, str) {
		return str.replace(/ /g,'&nbsp;');
	}).attr('target','_blank');

	// add ruler before footnotes
	$('article .footnotes').children().first().not('hr').before(function() {
		return '<hr>'
	});

	// make / in code blocks ine-breakable
	$('article p code').html(function() {
		var text = $(this).text();
		text = text.split('/').join('/<wbr>');
		text = text.split('=').join('=<wbr>');
		text = text.split('&').join('<wbr>&');
		return text;
	});
});
