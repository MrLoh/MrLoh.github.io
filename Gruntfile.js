module.exports = function (grunt) {

	grunt.initConfig({

		sass: {
			my_target: {
				files: [{
					expand: true,
					cwd: 'assets/css/',
					src: ['*.scss'],
					dest: 'assets/css/',
					ext: '.min.css'
				}]
			},
			options: {
				compress: false,
				sourcemap: 'none'
			}
		},

		autoprefixer: {
			options: {
				browsers: ['> 0.5%']
			},
			allcss: {
				src: 'assets/css/*.css'
			}
		},

		cssmin: {
			my_target: {
				files: [{
					expand: true,
					cwd: 'assets/css/',
					src: ['*.css'],
					dest: 'assets/css/',
					ext: '.min.css'
				}]
			}
		},

		uglify: {
			my_target: {
				files: [{
					expand: true,
					cwd: 'assets/js/',
					src: ['*.js', '!*.min.js'],
					dest: 'assets/js/',
					ext: '.min.js'
				}]
			}
		},

		watch: {
			// sass_compile: {
			// 	files: ['assets/css/*.scss'],
			// 	tasks: ['sass']
			// },
			postcss: {
				files: ['assets/css/*.scss'],
				tasks: ['sass', 'autoprefixer', 'cssmin']
			},
			postjs: {
				files: ['assets/js/*.js'],
				tasks: ['uglify']
			}
		}

	});

	grunt.loadNpmTasks('grunt-contrib-sass');
	grunt.loadNpmTasks('grunt-autoprefixer');
	grunt.loadNpmTasks('grunt-contrib-cssmin');
	grunt.loadNpmTasks('grunt-contrib-uglify');
	grunt.loadNpmTasks('grunt-contrib-watch');

	grunt.registerTask('default', ['sass','autoprefixer','cssmin','uglify']);

};
