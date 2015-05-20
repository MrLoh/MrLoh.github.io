module.exports = function (grunt) {

  grunt.initConfig({

    sass: {
      my_target: {
        files: [{
          expand: true,
          cwd: 'css/',
          src: ['*.scss'],
          dest: 'css/',
          ext: '.css'
        }]
      }
    },

    autoprefixer: {
      options: {
        browsers: ['> 1%']
      },
      allcss: {
        src: 'css/*.css'
      }
    },

  cssmin: {
    my_target: {
      files: [{
        expand: true,
        cwd: 'css/',
        src: ['*.css', '!*.min.css'],
        dest: 'css/',
        ext: '.min.css'
      }]
    }
  },

  uglify: {
    my_target: {
      files: [{
        expand: true,
        cwd: 'js/',
        src: ['*.js', '!*.min.js'],
        dest: 'js/',
        ext: '.min.js'
      }]
    }
  },

    watch: {
      sass_compile: {
        files: ['css/*.scss'],
        tasks: ['sass']
      },
      postcss: {
        files: ['css/*.css'],
        tasks: ['autoprefixer', 'cssmin']
      },
      postjs: {
        files: ['js/*.js'],
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
