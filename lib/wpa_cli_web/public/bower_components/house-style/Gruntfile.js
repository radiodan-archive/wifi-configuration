module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    config: {
      banner: '/*! <%= pkg.name %> <%= grunt.template.today("dd-mm-yyyy") %> */\n',
      tmpDir: './.tmp'
    },
    /*
      Expand unprefixed CSS properties into 
      their vendor-prefixed equivalents
    */
    autoprefixer: {
      dist: {
        options: {
          browsers: ['last 1 version', '> 1%', 'ie 8', 'ie 7']
        },
        files: {
          'house-style.css': ['house-style.css']
        }
      }
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
          '<%= config.tmpDir %>/**/*.css'
        ],
        // the location of the resulting JS file
        dest: '<%= pkg.name %>.css'
      }
    },
    /*
      Copy all modules into a tmp location for transformation
    */
    copy: {
      tmp: {
        files: [
          {expand: true, src: ['modules/**'], dest: '<%= config.tmpDir %>'}, // includes files in path and its subdirs
        ]
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
      Embed all image refs as base64 encoded data URIs
    */
    imageEmbed: {
      dist: {
        src: [ '<%= config.tmpDir %>/**/*.css' ],
        dest: '.', // the same dir as src
        options: {
          deleteAfterEncoding : true
        }
      }
    },
    /*
      Start a web server for local development
    */
    connect: {
      server: {
        options: {
          port: 9292,
          keepalive: true,
        }
      }
    },
    /* 
      Remove built files 
    */
    clean: ['<%= pkg.name %>.min.css', '<%= pkg.name %>.css', '<%= config.tmpDir %>']
  });

  grunt.loadNpmTasks('grunt-autoprefixer');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-connect');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-image-embed');

  grunt.registerTask('build', ['clean', 'copy:tmp', 'imageEmbed', 'concat', 'autoprefixer', 'cssmin']);
};