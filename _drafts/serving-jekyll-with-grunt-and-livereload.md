---
title: Serving Jekyll with Grunt & LiveReload
date: 2015-05-13T00:00:00.000Z
tags:
  - Jekyll
  - WebDev
  - Grunt
keywords:
    - LiveReload
    - NPM
---

[this article](http://thanpol.as/jekyll/jekyll-and-livereload-flow/)


[static-server](https://www.npmjs.com/package/static-server)

`$ static-server -p 4000 _site/`

make sure to exclude the Grunt files by adding `exclude: [node_modules, Gruntfile.js, package.json]` to your `_config.yml`, if not the whole `node_modules` folder will be copied each time. You don't want that! Unfortunately it's not possible to avoid this by just wrapping the whole source code in another directory, because GitHub Pages [doesn't allow it](https://help.github.com/articles/using-jekyll-with-pages/#configuring-jekyll).