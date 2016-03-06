$(function() {
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

	// make / in code blocks line-breakable
	$('article p code').html(function() {
		var text = $(this).text();
		text = text.split('/').join('/<wbr>');
		text = text.split('=').join('=<wbr>');
		text = text.split('&').join('<wbr>&');
		return text;
	});
});
