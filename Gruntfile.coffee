module.exports = (grunt) ->
	require('load-grunt-tasks')(grunt)

	grunt.initConfig

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

		# Copy JS and CSS
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

		# Jekyll Build and run Ruby scripts
		shell:
			jekyll_drafts:
				command: 'jekyll build --drafts'
			jekyll:
				command: 'jekyll build'
			archive:
				command: 'ruby archive/_generator.rb'

		# Watch
		watch:
			css:
				files: ['assets/css/*.scss']
				tasks: ['sass', 'postcss', 'copy:mincss']
			js:
				files: ['assets/js/*.js', '!assets/js/*.min.js']
				tasks: ['import', 'uglify', 'copy:minjs']
			jekyll:
				files: ['*.html', '*.md', '*.yml', '*.png', '*.ico', '*.xml', '_includes/**', '_layouts/*', '_posts/*', 'archive/**', 'assets/img/**', 'assets/lib/*', 'assets/svg/*']
				tasks: ['shell:archive', 'shell:jekyll']

		# Serve
		connect:
			server:
				options:
					livereload: true
					base: '_site/'
					port: 4000



	# Register Tasks
	grunt.registerTask 'build', [
		'sass'
		'postcss'
		'import'
		'uglify'
		'shell:jekyll'
		'shell:archive'
		'shell:jekyll'
	]
	grunt.registerTask 'serve', [
		'connect:server'
		'watch'
	]
