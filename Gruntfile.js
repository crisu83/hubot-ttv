module.exports = function (grunt) {

  var path = require('path');

  require('jit-grunt')(grunt, {
    useminPrepare: 'grunt-usemin'
  });

  require('time-grunt')(grunt);

  // Project configuration
  require('load-grunt-config')(grunt, {
    configPath: path.join(process.cwd(), 'grunt_config'),
    jitGrunt: true,
    data: {
      appRoot: 'client/app',
      buildRoot: 'client/build',
      webRoot: 'client/public'
    }
  });

  // Default task
  grunt.registerTask('default', ['watch']);

  // Build task
  grunt.registerTask('build', [
    //'jshint', // annoying during development
    'concat:scripts',
    'bower_concat',
    'less_imports:all',
    'less:all',
    'copy:assets',
    'copy:html',
    'copy:images',
    'copy:misc'
  ]);

  // Optimization task (must be ran after the 'build' task)
  grunt.registerTask('optimize', [
    //'htmlmin', // breaks usemin
    //'imagemin', // slows down the build
    'ngAnnotate',
    'uglify',
    'cssmin',
    'useminPrepare',
    'filerev',
    'usemin'
  ]);

  // Moves the build to the public folder
  grunt.registerTask('publish', [
    'clean:web_root',
    'copy:build',
    'clean:build'
  ]);

  // Development build task
  grunt.registerTask('dev', [
    'build',
    'publish'
  ]);

  // Distribution build task
  grunt.registerTask('dist', [
    'build',
    'optimize',
    'publish'
  ]);

};
