module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # Build the browser Component
    componentbuild:
      'gss-compiler':
        options:
          name: 'gss-compiler'
        src: '.'
        dest: 'browser'
        scripts: true
        styles: false

    # JavaScript minification for the browser
    uglify:
      options:
        report: 'min'
      'gss-compiler':
        files:
          './browser/gss-compiler.min.js': ['./browser/gss-compiler.js']

    # Automated recompilation and testing when developing
    watch:
      files: ['**/*.coffee']
      tasks: ['test']

    # Syntax checking
    jshint:
      lib: ['lib/*.js']

    # BDD tests on Node.js
    cafemocha:
      nodejs:
        src: ['spec/**/*.coffee']
      options:
        reporter: 'spec'

    # CoffeeScript compilation
    coffee:
      spec:
        options:
          bare: true
        expand: true
        cwd: 'spec'
        src: ['**/*.coffee']
        dest: 'spec'
        ext: '.js'
      src:
        options:
          bare: true
        expand: true
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'lib'
        ext: '.js'

    # BDD tests on browser
    mocha_phantomjs:
      all: ['spec/runner.html']

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-component-build'
  @loadNpmTasks 'grunt-contrib-uglify'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-cafe-mocha'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-mocha-phantomjs'
  @loadNpmTasks 'grunt-contrib-watch'

  @registerTask 'build', ['coffee:src', 'componentbuild', 'uglify']
  @registerTask 'test', ['build', 'coffee:spec', 'cafemocha', 'mocha_phantomjs']
  @registerTask 'default', ['build']
