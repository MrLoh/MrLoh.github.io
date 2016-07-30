---
title: Speed Dial for Safari
date: 2015-09-15 14:10:00 Z
tags:
- Web Development
- JavaScript
- Safari
- Mac OS X
description: Set up speed dial new tabs page and custom search engines in Safari
---

I have to admit that I am a Safari user. Mainly because of [battery life](http://www.theverge.com/2015/4/10/8381447/chrome-macbook-battery-life) and because I don't like Firefox's design. I have also never experienced any of the [Safari is the new IE](http://nolanlawson.com/2015/06/30/safari-is-the-new-ie/) issues everyone seems to be complaining about these days in any Development work I've done. But while I am usually quite happy with Safari, there is one big annoyance: the new window/tabs page. You can either use topsites, or favorites, but both look very unclean and certainly don't make it easy to recognize websites. Favorites only displays icons for a few sites and they are not visually coherent. Topsites displays a preview of the site, which end up as login screen for most sites --- there are some [workarounds](http://forums.macrumors.com/threads/custom-thumbnails-for-safari-top-sites.1454943/) for that at least. None of this is really any good.

![Ugly topsites and favorites page in Safari](/assets/img/2015-09-11-safari-topsites-favorites.png)

When I was using Chrome as my main browser the new tabs page was always a delight, thanks to the [Speed Dial 2](https://chrome.google.com/webstore/detail/speed-dial-2/jpfpebmajhhopeonhlcgidhclcccjcik?hl=en) extension (seems like there is a [version 3](https://chrome.google.com/webstore/detail/speed-dial-3/hfgjjcbbihjnpdommbepdkpfnkkapnbh?hl=en) now, and I think the origial speed dial is [this](https://addons.mozilla.org/en-us/firefox/addon/speed-dial/) Firefox add-on). It is great to quickly open your most used sites or even better the ones you can never remember the URL of --- try to remember that you have to start typing `panel` to get the suggestion of the URL for the DreamHost admin site `panel.dreamhost.com` for example. The other thing I have been missing from Chrome are [custom search engines](http://www.makeuseof.com/tag/create-custom-search-engines-google-chrome/), which are really useful to make a quick [WolframAlpha query](http://www.wolframalpha.com/input/?i=100+F) or get a quick [translation](http://dict.leo.org/ende/index_de.html#/search=heimat). But luckily I finally just found an easy solution to both issues.

![Speed dial in Chrome](/assets/img/2015-09-11-chrome-speeddial.png)


## Custom Search Engines with DuckDuckGo Bang

First to custom search engines in Safari. Until Yosemite, there was [Glims](http://www.machangout.com/), but that's gone. But when I tried switching from Google to [DuckDuckGo](https://duckduckgo.com/) again recently, I found the killer feature of DuckDuckGo: [**bang**](https://duckduckgo.com/bang). Bangs allow you to use hundreds of custom search engines with DuckDuckGo by typing an exclamation mark and a short code like `!wa 100F` or `!leo heimat`. It really rescues DuckDuckGo; sadly sometimes it just doesn't get as good results as Google, especially for people or news. But now you can just use `!g` for a quick Google search every once in a while.

## Safari Speed Dial with local Homepage

For the speed dial, the solution is a simple local homepage, i.e. a simple HTML file on your system that is set as the homepage. This can then be set as the new tabs/window page. What held me back from this approach so far, was that, unlike favorites or topsites on a homepage as the new tab page, the URL field of the browser is not selected, forcing you to click before you can type your URL, which can be very annoying. You can of course hit <kbd>&#8984;</kbd> + <kbd>L</kbd> to get to the URL field, which is better but still not ideal. So why not put a little form on the site and redirect it to search DuckDuckGo --- making sure the search field has the correct name `q` and an `autofocus` attribute. You have to use the empty bang `!` to directly type a URL and there is no autocomplete from history, but it covers a bunch of cases and otherwise <kbd>&#8984;</kbd> + <kbd>L</kbd> is not too much of a hassle. The form will have no submit field but be submitted on hitting <kbd>enter</kbd> --- which we can identify by scanning for `keyCode == 13` with JavaScript. The favorites will simply be in a list that is populated by a little JavaScript. The whole HTML for the site is this:

```html
<body>
	<form id="search" action="https://duckduckgo.com/">
		<input type="text" name="q" autofocus
               onkeydown="if (event.keyCode == 13) { this.form.submit(); }">
	</form>
	<ul id="favorites">
        <!-- populated via JavaScript -->
	</ul>
</body>
```

Now for the bit of JavaScript the favorites will be saved in a `SITES.json` file which contains the name and url for each favorite. We will save the JSON object directly into a variable, so we don't have to import it later. We will then import it directly to the HTML with a script tag.

```js
var favorites = [
  {
    name: "Wolfram Alpha",
    url: "https://www.wolframalpha.com/"
  },
  {
    name: "Readability",
    url: "https://www.readability.com/reading-list"
  },
]
```

The main script will be added directly into the HTML after the imported JSON. It simply loops over the `favorites` list from `SITES.json` and populates it with list items of the form `li>a>img`. We don't need to use any jQuery to keep it plain and simple. The images will be stored in an `img/` directory and simply use the name attributes converted to lowercase and stripped of all whitespace as filenames. It's all pretty straight forward:

```js
var list = document.getElementById('favorites');
for (var i in favorites) {
	// add <li>
	var item = document.createElement('li');
	list.appendChild(item);
	// add <a href="i.url">
	var link = document.createElement('a');
	link.setAttribute('href', favorites[i].url);
	item.appendChild(link)
	// add <img src="lower_strip(i.name).png" alt="i.name">
	var icon = document.createElement('img');
    var src = 'icons/'+favorites[i].name.toLowerCase().replace(/\s/g,'')+".png";
	icon.setAttribute('src', src);
	icon.setAttribute('alt', favorites[i].name);
	link.appendChild(icon)
};
```

After adding some CSS, we have a clean and beautiful speed dial page. You can find the full code on [GitHub](https://github.com/MrLoh/safari-speeddial) and see it live [here](http://mrloh.se/safari-speeddial/).

![The resulting safari speed dial page](/assets/img/2015-09-11-safari-speeddial.png)
