---
title: Automatic Archives for Jekyll on GitHub Pages
date: 2015-06-14-17:00
tags: [Jekyll, Web Development, GitHub Pages, Ruby]
description: 'How to automatically generate month and tag archives for Jekyll blogs without the need for any GitHub Pages incompatible plugins'
---

Static sites are pretty cool. Not just, because they're so fast, but also because they are pretty intuitive. After all it's just a bunch of files in a folder structure --- just like you know it from your local filesystem. But while they are cool, they also have some drawbacks when compared to database driven sites. One is that it's hard(er) to generate query driven sites like archive pages by month, year and day or by things like tags and categories. There are a bunch of plugins for that task, but those don't work well with [GitHub Pages](https://pages.github.com). But there are other ways to solve the issue, after all we just need to generate some files.

Let's first clarify, what we want to achieve: The URL structure for my blog as specified in the `_config.yml` is `permalink: '/:year/:month/:title'`, so for this post the URL is `MrLoh.se/2015/06/automatic-archives-for-jekyll-on-github-pages/`. ![the static folder structure of this blog with index.html files in each directory](/assets/img/2015-06-11-blog-folder-structure.jpg) To be more intuitive and improve [SEO](http://static.googleusercontent.com/media/www.google.de/en/de/webmasters/docs/search-engine-optimization-starter-guide.pdf) with [breadcrumbs](https://developers.google.com/structured-data/breadcrumbs) we want each part of the URL to have a page, so `MrLoh.se` is the index of the blog, `MrLoh.se/2015/` is the archive page for 2015 and `MrLoh.se/2015/06/` the one for July 2015. So we basically need an `index.html` file in each folder. There should also be archive pages for each tag like `MrLoh.se/tags/jekyll/`. You can see the actual file structure of my blog in the picture.

So how do we do this? I couldn't find any automated solution --- which is why I'm writing this post --- but I was inspired by a post on [minddust](http://www.minddust.com/post/tags-and-categories-on-github-pages/). We are going to write a ruby script that generates markdown files for each month, year, and tag that contains only a liquid header. The actual content of the archive pages is created by a Jekyll layout file and the files are put in the right location with a permalink attribute in the header.


## Generating the Archive Template Files with Ruby

We'll do everything in an `archives/` directory, where our archive index page resides as well. The ruby script will be called `_generator.rb` --- the `_` is so it isn't included in the site since it is only needed internal. The main challenge is that the ruby script does not have access to any Jekyll internal attributes like the sites post dates or tags. So we need to generate something like an API for our blog, from which we can then read this information in our script. Doing this is actually pretty straight forward. In a file in `archive/dateslist.txt` we generate a simple list of all dates with liquid like this:

```html
{% raw %}
---
---
{% for post in site.posts %}{{ post.date | date: "%Y-%m-%d" }}
{% endfor %}
{% endraw %}
```

We'll do the same for tags, with `{% raw %}{% for tag in site.tags %} {{ tag[0] }} {% endfor %}{% endraw %}`, but I'll focus on explaining the setup for the date pages here. We could even create a full-blown JSON-API for our blog by creating `.json` files with liquid, but for now this is good enough. It might also be possible to use liquid in the ruby script and then compile it and execute it from the `_site` directory to generate files back in the source directory, but that's probably even more confusing.

Next we will read the dates from this file into an array of date-hashes called `dates` in our `_generator.rb`. We find the compiled datelist in `_site/archive/datelist.txt` and will just cut out the substrings, since we made sure the dates are written as `YYYY-MM-DD`:

```ruby
# read dates into array
dates = []
datelist_path = File.expand_path("../../_site/archive/datelist.txt", __FILE__)
File.open(datelist_path, 'r') do |f|
    while date = f.gets
        date = date.strip
        dates += [{year: date[0..3], month: date[5..6], day: date[8..9]}]
                 unless date == "" || date == "\n"
    end
end
```

Next we are going to create a directory `archives/dates/` if it doesn't exist already and then create the template files for each year and month in this directory using a function we are going to specify afterwards. Year pgaes are named as `YYYY.md`, month pages as `YYYY-MM.md`. We use an array `MONTH_NAMES = ["", "January", "February", ...]` to translate the month numbers into their string representations. It's all pretty straight forward:

```ruby
# create containing folders
dates_folder_path = File.expand_path("../dates/", __FILE__)
Dir.mkdir(dates_folder_path) unless File.exists?(dates_folder_path)

# create template files for each year and month
for date in dates
    # create year template files
    yearpage_path = dates_folder_path + "/#{date[:year]}.md"
    write_template_file(yearpage_path, "#{date[:year]}/", date[:year], {year:"#{date[:year]}"})

    # create month template files
    monthpage_path = dates_folder_path + "/#{date[:year]}-#{date[:month]}.md"
    month_name = "#{MONTH_NAMES[Integer(date[:month])]} #{date[:year]}"
    write_template_file(monthpage_path, "#{date[:year]}/#{date[:month]}/", month_name,
               {year: date[:year], month: date[:month]})
end
```

So the real work is done by the function `write_template_file(path, link, title, options={})` that will write the markdown template files. Let's first look at how these files will look like. They specify layout, title, the permalink that will put them in the right folder at compilation, and some extra information like year, month, or tag depending on the type. The file for June 2015 for example looks like this:

```yaml
---
layout: archive
permalink: '2015/06/'
title: 'June 2015'
year: '2015'
month: '06'
---
```

So our functions basically just writes these files to the given `path`, using the specified `permalink` and `title` and writing any other options, that are specified in a hash:

```ruby
def write_template_file(path, permalink, title, options={})
    unless File.exists?(path)
        File.open(path, 'w') do |f|
            f.puts "---"
            f.puts "layout: archive"
            f.puts "permalink: '#{permalink}'"
            f.puts "title: '#{title}'"
            options.each do |k, v|
                f.puts "#{k}: '#{v}'"
            end
            f.puts "---"
        end
        puts "created archive page for #{title}"
    end
end
```

So that's already our `_generator.rb` script. Creating the tag template files works in the same way. You can have a look at the whole file in [this gist](https://gist.github.com/MrLoh/b501e6df22fe039d6070). We can run the script as `$ ruby archive/_generator.ruby` from the home directory. It's important to run `$ jekyll build` once before and once after you run the script since the datelist.txt file needs to be updated first and then the generated archive file templates need to be parsed. I automate all this with  [Grunt](http://gruntjs.com/), as described in my recent post [here](http://mrloh.se/2015/06/serving-jekyll-with-grunt/index.html#IaoTai).


## The Archive Layout

To generate the actual archive pages, we build a layout in `_layouts/archive.html` that goes through all the posts and lists those that match the `year`, `month`, and/or `tag` parameters specified in the template file. My setup was inspired by the implementation on [mitsake](http://www.mitsake.net/2012/04/archives-in-jekyll/). The following shows the main part of the layout for the month pages, you can find the full implementation in the [GitHub repository](https://github.com/MrLoh/MrLoh.github.io/blob/master/_layouts/archive.html) of this blog.

```html
{% raw %}
<h1>Archive: {{ page.title }}</h1>
<ul>
  {% if page.month %}
    {% capture pagemonth %} {{ page.year | append: '-' | append: page.month }} {% endcapture %}
    {% for post in site.posts %}
      {% capture postmonth %} {{ post.date | date: '%Y-%m' }} {% endcapture %}
      {% if postmonth == pagemonth %}
        <li class="post">
          <p class="meta">
            by <a href="{{ post.author-link }}">{{ post.author }}</a>
            on <a href="{{ post.date | date: '/%Y/%m/' }}">{{ post.date | date: "%b %-d, %Y" }}</a>
          </p>
          <h3><a href="{{ post.url }}">{{ post.title }}</a></h3>
          <p class="tags">
            {% for tag in post.tags %}
              <a href="{{ tag | downcase | replace: ' ', '-' | prepend:'/tags/' }}">{{ tag }}</a>
            {% endfor %}
          </p>
        </li>
      {% endif %}
    {% endfor %}
  {% elsif page.year %}
    ...
{% endraw %}
```

So that's it, now you have full blown year, month, and tag archive pages for your site and you could add category and day archive pages in the same manner. If you found this helpful, please like the post, and feel free to leave comments with questions.


## Another Idea for a Solution

Of course there are other solutions. Another idea would be to handle all this on the front-end with a little JavaScript app --- probably using some [Backbone](http://backbonejs.org), [Angular](https://angularjs.org), or [Ember](http://emberjs.com) to handle the routing and so on. One could invoke the app from the 404 page and generate the archive in the front-end, using liquid-generated JSON file(s) as a databse-less API. Of course that shifts some of the (fairly light) lifting to the client device, but that's ok since the bottleneck in this case is more like to be the transfer-bandwidth than the computing power of the client device.

There is also a chance that a [future](http://jekyllrb.com/docs/permalinks/index.html#extensionless-permalinks) Jekyll release will include archive page functionality, but who knows.
