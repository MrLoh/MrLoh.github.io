module.exports = (grunt) ->
	require('load-grunt-tasks')(grunt);

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
		autoprefixer:
			options:
				browsers: ['> 0.5%']
			mincss:
				src: 'assets/css/*.css'
		cssmin:
			mincss:
				files: [
					expand: true
					cwd: 'assets/css/'
					src: ['*.css']
					dest: 'assets/css/'
					ext: '.min.css'
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
			jekyll:
				command: 'jekyll build --drafts'
			archive:
				command: 'ruby archive/_page_generator.ruby'

		# Watch
		watch:
			css:
				files: ['assets/css/*.scss']
				tasks: ['sass', 'autoprefixer', 'cssmin', 'copy:mincss']
			js:
				files: ['assets/js/*.js', '!assets/js/*.min.js']
				tasks: ['import', 'uglify', 'copy:minjs']
			jekyll:
				files: ['*.html', '*.md', '*.yml', '*.png', '*.icon', '*.xml', '_drafts/*', '_includes/**', '_layouts/*', '_posts/*', 'archive/*', 'assets/img/**', 'assets/lib/*', 'assets/svg/*']
				tasks: ['shell:jekyll', 'shell:archive', ]

		# Serve
		connect:
			server:
				options:
					livereload: true
					base: '_site/'
					port: 4000



	# Register Tasks
	grunt.registerTask 'default', [
		'sass'
		'autoprefixer'
		'cssmin'
		'import'
		'uglify'
		'jekyll'
	]
	grunt.registerTask 'serve', [
		'connect:server'
		'watch'
	]
