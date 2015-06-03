---
title: Serving Jekyll with Grunt & LiveReload
tags: [Jekyll, Grunt, Web Development]
keywords: [LiveReload, NPM]
---

If you are running a Jekyll blog, you might find that simply running `jekyll serve` to generate all your files is not enough. I for example want to [minify](https://github.com/gruntjs/grunt-contrib-cssmin)/[uglify](https://github.com/gruntjs/grunt-contrib-uglify) my CSS and JavaScript files and I totaly depend on [Autoprefixer](https://github.com/postcss/autoprefixer). So if you have done some serious front-end Web Development before you probably have used [Grunt](http://gruntjs.com/) for things like that --- if you haven't heard of it, go check it out now. But running `grunt watch` and `jekyll serve` parallel is really slow, since a change in any grunt-processed file (e.g. your `main.scss`) will trigger several Jekyll builds, because Grunt will most likely creates several new files which will each trigger a Jekyll build. That's no good! To solve the problem we will instead handle the compiling for any CSS/Sass and JavaScript/CoffeeScript ourselves with Grunt and only trigger Jekyll builds --- also with grunt --- if other files change and serve the whole thing with Grunt as well. The basic idea is described [here](http://thanpol.as/jekyll/jekyll-and-livereload-flow/), but I'll describe a little more complete setup.




make sure to exclude the Grunt files by adding `exclude: [node_modules, Gruntfile.js, package.json]` to your `_config.yml`, if not the whole `node_modules` folder will be copied each time. You don't want that! Unfortunately it's not possible to avoid this by just wrapping the whole source code in another directory, because GitHub Pages [doesn't allow it](https://help.github.com/articles/using-jekyll-with-pages/#configuring-jekyll). Also make sure to delete all `---` front matter from you `.coffe` and `.scss/.sass` files to make sure the Jekyll-internal compilers don't process these files, since Grunt is already taking care of that now.
