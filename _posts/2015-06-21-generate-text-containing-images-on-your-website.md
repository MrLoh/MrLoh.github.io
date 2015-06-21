---
title: Generate Text-Containing Images on your Website
date: 2015-06-21-15:30
tags: [Web Development, PHP, SVG, PhantomJS]
description: 'How to generate images with text overlays for social media automatically using only PHP, SVG, and PhantomJS compatible with most shared hosting'
---

If there has been one constant in social media marketing in the last years, it's that [images rule](https://designschool.canva.com/blog/blog-traffic/). So instead of sharing text content it is often a good idea to typeset the text as an overlay inside an image and share that to draw attention. But creating text image overlays in accordance with your corporate design if you don't have photoshop installed can be a bit of a hassle. But it is relatively easy to style images on the web using SVG filters and to create text overlays. Only how to transform those into JPG files that can be used on social media sites and mailinglists? It's actually pretty easy with  [PhantomJS](http://phantomjs.org) and can be done on basically any shared hosting, with a little coding in PHP and SVG.

I recently ran into the described situation. We developed a really nice Blog design for my NGO [Kijani](http://blog.kijani.co/) and I wanted to have images with these nice green overlays and the blogpost title in the same font as on the website to use for [social media meta tags](http://zduck.com/2013/open-graph-twitter-cards-and-your-blog/) and in our [MailChimp](http://mailchimp.com) list (most email-clients don't support SVG and custom fonts). I found a way to build a solution on our [Dreamhost](http://www.dreamhost.com) shared hosting that allows me to generate such images with a little SVG, PHP, and PhantomJS on the fly --- with cashing --- by simply specifying a URL like `kijani.co/imagerenderer/img.php?imgurl=url_to_image.jpg&title=Some+Title&width=800&type=jpg&qual=80`. You can go to [kijani.co/imagerenderer](http://kijani.co/imagerenderer) to try it out right now. Read on to learn how it's done.

![Some examples of the kind of images with color and text overlays from the Kijani Blog that have been generated automatically](/assets/img/2015-06-20-kijanified-images.jpg)

To give an outline of what we're going to do. We will first generate webpage that contains the image with filters and color overlays applied and with a text overlay using some SVG and PHP. To transform that webpage into an image we need to render it with a browser on our server; we're using PhantomJS for that. In the last step we are creating a PHP script that acts as a controller to generate the images, cash them, and serve them back. We will also create a simple web-form to easily send requests to our image-generator.

## Creating the Text-Containing Image with SVG

SVG is an awesome technology to create more advanced content on the web, since it can be directly embedded in you HTML you can use it for blog elements with borders that are not just straight lines, or for manipulating images. There are not so many introductions to using SVG out there, the best I found is Jenkov's [SVG Tutorial](http://tutorials.jenkov.com/svg/index.html), you should use that as a reference if you have any questions. For our purpose we are gonna create a whole SVG website.

So in our main directory we create a file `svg.php` in which we will first capture some parameters from the URL: `title` will contain the text to be put in the image, `img` will contain the URL of the image to be used, and `width` the width of the image to be rendered --- we will just render 16:9 images, but you could also specify a height of course or an overlay color, whatever has to be adjustable. We then need to tell PHP to generate an SVG file with `header('Content-Type: image/svg+xml')`.

```php
<?php
    $title = htmlentities($_GET["title"]);
    $image_url = urldecode($_GET["img"]);
    $width = intval($_GET["width"]);

    header('Content-Type: image/svg+xml');
?>
```

Next we declare an SVG header and import the font that we want to use, We'll have to use `@font-face`, loading webfonts via something like Typekit does not work. Make sure the `font.otf` file sits in the same directory. We will also declare a grayscale filter to use later.

```html
<svg
	style="position:absolute; top:0; left:0;"
	version="1.1"
	width="<?php echo $width ?>"
	height="<?php echo $width*450/800 ?>"
	xmlns="http://www.w3.org/2000/svg"
	xmlns:xlink="http://www.w3.org/1999/xlink"
>

    <defs>
    	<style type="text/css">
    		@font-face {
    			font-family: title;
    			src: url("font.otf");
    			font-weight: bold;
    			}
    	</style>
    	<filter id="grayscale">
    		<feColorMatrix type="saturate" values="0"/>
    	</filter>
    </defs>

    ... [content] ...

</svg>
```

The actual content will go before the closing `{% raw %}</svg>{% endraw %}` tag. We use a little trick here to make everything easily scalable without having to adjust font sizes and stuff. We put the whole content in a group that is 800px wide and than simply scale the whole thing up or down to the desired `$width` with a transform. Our SVG has three layers (in photoshop terms): the first is the image to which we apply the grayscale filter; the second is a green overlay to tint the image; the third is the text that we want to add to the image. I adjust the font size according to the length of the text and also make the line-breaks manually with [tspan](http://tutorials.jenkov.com/svg/tspan-element.html) elements to balance the text nicely. That's what the `font_size($title)` and `title_tspan($title)` functions do. You can have a look at the [full file](https://github.com/KijaniNGO/kijanify-imagerenderer/blob/master/svg.php) to see how these PHP functions are setup. There also are some logo vectors included which I omitted here.

```html
<g transform="scale(<?php echo $width/800 ?>)">
	<image
		x="0" y="0"
		width="800" height="450"
		xlink:href="<?php echo $image_url ?>"
		filter="url(#grayscale)"
	/>
	<rect
		x="0" y="0"
		width="800" height="450"
		fill="forestgreen"
		opacity="0.5"
	>
	</rect>
	<text
		x="0" y="0"
		font-family="title"
		font-weight="bold"
		font-size="<?php echo font_size($title) ?>"
		fill="white"
	>
		<?php echo title_tspan($title) ?>
	</text>
</g>
```

## Transforming the SVG into a JPG with PhantomJS

To transform the SVG file into a JPG file might sound like an easy task, but it actually requires the same thing as is required to render a webpage. What we want to do is like taking a screenshot from a browser, but a browser is a quite complex program and we need to run it on our server. Luckily there is [PhantonJS](http://phantomjs.org) a headless webkit browser written in JavaScript that we can even run on most shared hosting servers.

On my MacBook I can simply install PhantomJS via `brew install phantomjs`. But if you only have shared hosting like me, there is no equivalent method to use on your server. You can not even download the official release and compile it without any root access. But as described in [this post](http://www.arlocarreon.com/blog/javascript/using-phantomjs-on-shared-hosting-like-hostgator/) we can simply upload a readily compiled binary file to our server. Since I don't have a Linux server handy to compile this on, I needed to find a binary somewhere though, but luckily there are some binaries available on [google code](https://code.google.com/p/phantomjs/downloads/list). You'll probably need the Linux 64-bit version, but if your server is old it might also be 32-bit --- just try it. It's a slightly older version, but it will do just fine for our purpose. Just download it unpack it and upload the `phantomjs` file to your directory.

Now we can write a PhantomJS program in a file we call `rasterize.js`. It's pretty simple, we just follow [this example](https://github.com/ariya/phantomjs/blob/master/examples/rasterize.js) to transform the SVG webpage into a JPG or PNG image. The program will be invoked as `./phantomjs rasterize.js path filename quality` and all it does is fetch the parameters: the first is for the path to the `svg.php?title=...&img=...&width=...` which we want to convert; the second is the path to which the output file should be written and implicitly contains the filetype; the third is optional and contains the quality of the output. The script basically just invokes `phantom.open(path)` to open the page and `phantom.render(output)` to save the file. The full version with error handling can be found [here](https://github.com/KijaniNGO/kijanify-imagerenderer/blob/master/rasterize.js).

```js
// create phantomjs page and initialize vars
var page = require('webpage').create(),
	system = require('system'),
	address, output, qual;

// capture vars from stdin
address = system.args[1];
output = system.args[2];
qual = system.args.length == 4 ? system.args[3] : '80';
page.viewportSize = { width: 1, height: 1 };

// create and save screenshot
page.open(address, function (status) {
	window.setTimeout(function () {
		page.render(output, {quality: qual});
		phantom.exit();
	}, 200);
});
```


## Serving and Cashing it all with PHP

What's still missing is a controller to put it all together. We will write an `img.php` file for that. This is the URL we call to get our images. If you remember from above it's called with a bunch of parameters like `img.php?imgurl=url_to_image.jpg&title=Some+Title&width=800&type=jpg&qual=80`. First we capture those and verify that the quality is an integer between 1 and 100 or set it to 70 by default.

{% highlight php startinline linenos=table %}
$title = $_GET["title"];
$image_url = $_GET["imgurl"];
$width = $_GET["width"];
$quality = intval($_GET["qual"]);
$quality = (0 < $quality && $quality <= 100) ? $quality : 70;
{% endhighlight %}

Since rendering the images with PhantomJS will take up quite some ressources we want to generate each image only once and then cache it so we don't have to regenerate it. For that we will simply calculate the unique MD5-Hash from the path to the SVG that we render plus the quality value and use that as the filename for the output image. We will save all generated images with their MD5 `$filename` in a `cache` folder. Then we can simply try to get the file from this folder with `@imagecreatefromjpeg($filename)` and if it doesn't exist we will run the PhantomJS rasterize script to create it and save it in the cache. Lastly we will serve the image from the cache on this very page by specifying to PHP that this is a JPG file with `header("Content-type: image/jpeg")` and then simply outputting it with `imagejpeg($image)`.

{% highlight php startinline linenos=table %}
// filename from unique hash
$path = "http://kijani.co/imagerenderer/svg.php?img={$image_url}&title={$title}&width={$width}";
$filename = 'cache/' . hash("md5", $path.$quality) . '.jpg';

// create image from svg, if needed
$image = @imagecreatefromjpeg($filename);
if ( !$image ) {
	`./phantomjs rasterize.js '{$path}' {$filename} {$quality}`;
	$image = @imagecreatefromjpeg($filename);
}

// output image
header("Content-type: image/jpeg");
imagejpeg($image);
{% endhighlight %}

So that's it. You can find the full code in [this](https://github.com/KijaniNGO/kijanify-imagerenderer) GitHub repository, it includes PNG rendering as well and some more error handling and making sure that special characters are encoded correctly for URLs and as HTML entities.

It also includes a simple [web-form](https://github.com/KijaniNGO/kijanify-imagerenderer/blob/master/index.html) in an `index.html` file that provides a minimal UI to easily specify the image URL, title, width, file type, and quality.

Feel free to contact me with questions. I hope this was inspiring to you.
