---
title: Serving Jekyll with Grunt
date: 2015-06-03 23:57:00 Z
tags:
- Jekyll
- Grunt
- Web Development
description: Using Grunt to serve Jekyll sites with custom CSS and JavaScript preprocessors
bla: Using Grunt to serve Jekyll sites with custom CSS and JavaScript preprocessors
---

If you are running a Jekyll blog, you might find that simply running `jekyll serve` to generate all your files is not enough. I for example want to [minify](https://github.com/gruntjs/grunt-contrib-cssmin)/[uglify](https://github.com/gruntjs/grunt-contrib-uglify) my CSS and JavaScript files and I totaly depend on [Autoprefixer](https://github.com/postcss/autoprefixer). So if you have done some serious front-end Web Development before you probably have used [Grunt](http://gruntjs.com/) for things like that --- if you haven't heard of it, go check it out now. But running `grunt watch` and `jekyll serve` parallel is really slow, since a change in any grunt-processed file (e.g. your `main.scss`) will trigger several Jekyll builds, because Grunt will most likely creates several new files which will each trigger a Jekyll build. That's no good! To solve the problem we will instead handle the compiling for any CSS/Sass and JavaScript/CoffeeScript ourselves with Grunt and only trigger Jekyll builds --- also with grunt --- if other files change and serve the whole thing with Grunt as well. The basic idea is described [here](http://thanpol.as/jekyll/jekyll-and-livereload-flow/), but I'll describe a little more complete setup.

## What's gonna be in the Gruntfile

[Grunt](http://gruntjs.com/) is a task runner that let's you automate all kinds of actions especially for front-end development. It can be configured very flexibly through plugins. I am currently using the following services on this site:

- [grunt-contrib-sass](https://github.com/gruntjs/grunt-contrib-sass): compile Sass files
- [grunt-postcss](https://github.com/nDmitry/grunt-postcss): autoprefix vendor prefixes and minify CSS
- [grunt-import](https://github.com/marcinrosinski/grunt-import): allow import statements in JavaScript files
- [grunt-contrib-uglify](https://github.com/gruntjs/grunt-contrib-uglify): minify JavaScript files
- [grunt-contrib-copy](https://github.com/gruntjs/grunt-contrib-copy): copy files (into the Jekyll build folder)
- [grunt-shell](https://github.com/sindresorhus/grunt-shell): run shell commands
- [grunt-contrib-watch](https://github.com/gruntjs/grunt-contrib-watch): watch files and execute all the other scripts on change
- [grunt-contrib-connect](https://github.com/gruntjs/grunt-contrib-connect): serve a static site

The configuration is done in a file named `Gruntfile.coffee` --- I much prefer the CoffeScript syntax, which avoids the annoying issues with trailing `,` for JSON like files. The Gruntfile has to first include all needed modules, which can be simplified with the [load-grunt-tasks](https://github.com/sindresorhus/load-grunt-tasks) plugin, so we start with:

```coffee
module.exports = (grunt) ->
	require('load-grunt-tasks')(grunt)
	grunt.initConfig
```

## Configuring the CSS and JS Processors

Next in the Gruntfile we will configure the Sass compiler to compile all `.scss` files in the `assets/css` directory and save them in files of the same name with the extension `.min.css` (we really don't care about anything but the final files). In most cases this will only compile the single `main.scss` file, files with a `_` at the start are ignored like expected. Than we will use PostCSS to run autoprefixer and csswring (a minifyer) on the created CSS files and simply overwrite them.

```coffee
# CSS Processors
sass:
    options:
        compress: false
        sourcemap: 'none'
    scss:
        files: [
            expand: true
            cwd: 'assets/css/'
            src: ['*.scss']
            dest: 'assets/css/'
            ext: '.min.css'
        ]
postcss:
    options:
        processors: [
            require 'autoprefixer-core'
            require 'csswring'
        ]
    mincss:
        files: [
            expand: true
            cwd: 'assets/css/'
            src: ['*.min.css']
            dest: 'assets/css/'
        ]
```

For the JavaScript files I am currently running import to enable using `@import "path/to/file";` statements. This one will only run on `.js` files not `.min.js` files, but change their extension to `.min.js` in the process. Than I also run a minifyer/uglifyer on all `.min.js` files. You might also want to do something like [compile CoffeeScript](https://github.com/gruntjs/grunt-contrib-coffee) or [transpile ES6](https://github.com/aaronfrost/grunt-traceur) syntax if you're usig something like that.

```coffee
# JS Processors
import:
    js:
        expand: true
        cwd: 'assets/js/'
        src: ['*.js', '!*.min.js']
        dest: 'assets/js/'
        ext: '.min.js'
uglify:
    minjs:
        files: [
            expand: true
            cwd: 'assets/js/'
            src: ['*.min.js']
            dest: 'assets/js/'
            ext: '.min.js'
        ]
```

## Building the Jekyll Site

Sweet, so we have compiled the Sass and JavaScript files, but now we need to move them into our `_site/` directory to be available to our local server. We will use the copy task for that and just copy all `.min.css` (read the `main.min.css`) file and all `.min.js` files over into the `_site/` directory. Easy enough:


```coffee
copy:
    mincss:
        expand: true
        cwd: 'assets/css/'
        src: ['*.min.css']
        dest: '_site/assets/css/'
    minjs:
        expand: true
        cwd: 'assets/js/'
        src: ['*.min.js']
        dest: '_site/assets/js/'
```

If any other file (mainly `html` and `md` files) change, we will just trigger a `jekyll build` via the shell plugin, since that's what Jekyll is there fore after all. In production I usually want to compile with the `--drafts` flag, so I include one task for that here and I also have another ruby script that I run which generates my archive pages without any plugins --- read more about it in [this post](http://MrLoh.se/2015/06/automatic-archives-for-jekyll-on-github-pages/). There also is a dedicated [grunt-jekyll](https://github.com/dannygarcia/grunt-jekyll) plugin, but that didn't work for me with drafts, is significantly slower, and not maintained well anymore, so the shell script seemed like the better option for now.

```coffee
shell:
    jekyll_drafts:
        command: 'jekyll build --drafts'
    jekyll:
        command: 'jekyll build'
    archive:
        command: 'ruby archive/_page_generator.ruby'
```

Now we just need to make sure that the appropriate task are run. For that we configure the watch task. If any `.scss` file changes, we will compile it and run PostCss on it and than copy it. If a `.js` file is changed, we will run the import and uglify tasks and than copy the files. If any other file changes we will run the Jekyll build task and the ruby script. I specify all other files here manually, you have to make sure changes in the `_site/` directory are excluded and all other CSS/JS related files as well (this is not an if-else statement).

```coffee
watch:
    css:
        files: ['assets/css/*.scss']
        tasks: ['sass', 'postcss', 'copy:mincss']
    js:
        files: ['assets/js/*.js', '!assets/js/*.min.js']
        tasks: ['import', 'uglify', 'copy:minjs']
    jekyll:
        files: ['*.html', '*.md', '*.yml', '*.png', '*.icon', '*.xml',
                 '_drafts/*', '_includes/**', '_layouts/*', '_posts/*',
                 'archive/*', 'assets/img/**', 'assets/lib/*', 'assets/svg/*']
        tasks: ['shell:jekyll_drafts', 'shell:archive', ]
```

## Serving the site locally

No that we can automatically build everything neatly, we just have to also serve it loally, since we are not running our Jekyll server anymore. Luckily there is the [grunt-contrib-connect](https://github.com/gruntjs/grunt-contrib-connect) plugin that allows us to do that from inside Grunt. We just have to specify a base directory and a port and that's it.

```coffee
connect:
    server:
        options:
            livereload: true
            base: '_site/'
            port: 4000
```

Lastly we configure two commands to be run from the console. The `grunt build` just compiles everything once without drafts (so no need for any copying or watching here). This can be used before a commit instead of `jekyll build` now. And than the `grunt serve` command, which will use everything we just build to build and serve the site, just like `jekyll serve` does, but with all the sweetness and configurability.

```coffee
grunt.registerTask 'build', [
    'sass'
    'postcss'
    'import'
    'uglify'
    'shell:jekyll'
]
grunt.registerTask 'serve', [
    'connect:server'
    'watch'
]
```

You can have a look at my current [Gruntfile](https://github.com/MrLoh/MrLoh.github.io/blob/master/Gruntfile.js) and the corresponding installed [NPM Packages](https://github.com/MrLoh/MrLoh.github.io/blob/master/package.json) on GitHub.

## Some other things to take care of

make sure to exclude the Grunt files by adding `exclude: [node_modules, Gruntfile.js, package.json]` to your `_config.yml`, if not the whole `node_modules` folder will be copied each time. You don't want that! Unfortunately it's not possible to avoid this by just wrapping the whole source code in another directory, because GitHub Pages [doesn't allow it](https://help.github.com/articles/using-jekyll-with-pages/#configuring-jekyll). Also make sure to delete all `---` front matter from you `.coffe` and `.scss/.sass` files to make sure the Jekyll-internal compilers don't process these files, since Grunt is already taking care of that now.
