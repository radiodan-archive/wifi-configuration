module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    config: {
      banner: '/*! <%= pkg.name %> <%= grunt.template.today("dd-mm-yyyy") %> */\n'
    },
    /*
      Concatenate all CSS under modules into a single file
    */
    concat: {
      css: {
        options: {
          banner: '<%= config.banner %>'
        },
        // the files to concatenate
        src: [
          // Specific external deps first
          'bower_components/normalize-css/*.css',
          // Then everything else
          'modules/**/*.css'
        ],
        // the location of the resulting JS file
        dest: '<%= pkg.name %>.css'
      }
    },
    /*
      Minify concatenated CSS
    */
    cssmin: {
      dist: {
        files: {
          '<%= pkg.name %>.min.css': ['<%= concat.css.dest %>']
        }
      }
    },
    /* 
      Remove built files 
    */
    clean: ['<%= pkg.name %>.min.css', '<%= pkg.name %>.css']
  });

  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-cssmin');

  grunt.registerTask('build', ['clean', 'concat', 'cssmin']);
};