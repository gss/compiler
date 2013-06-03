module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # Build the browser Component
    component:
      install:
        options:
          action: 'install'
    component_build:
      'gss-compiler':
        output: './browser/'
        config: './component.json'
        scripts: true
        styles: false

    # JavaScript minification for the browser
    uglify:
      options:
        report: 'min'
      noflo:
        files:
          './browser/gss-compiler.min.js': ['./browser/gss-compiler.js']

    # Automated recompilation and testing when developing
    watch:
      files: ['spec/*.coffee', 'lib/*.js']
      tasks: ['test']

    # Syntax checking
    jshint:
      lib: ['lib/*.js']

    # BDD tests on Node.js
    cafemocha:
      nodejs:
        src: ['spec/*.coffee']

    # CoffeeScript compilation
    coffee:
      spec:
        options:
          bare: true
        expand: true
        cwd: 'spec'
        src: ['**.coffee']
        dest: 'spec'
        ext: '.js'

    # BDD tests on browser
    mocha_phantomjs:
      all: ['spec/runner.html']

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-component'
  @loadNpmTasks 'grunt-component-build'
  @loadNpmTasks 'grunt-contrib-uglify'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-cafe-mocha'
  @loadNpmTasks 'grunt-contrib-jshint'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-mocha-phantomjs'
  @loadNpmTasks 'grunt-contrib-watch'

  @registerTask 'build', ['component', 'component_build', 'uglify']
  @registerTask 'test', ['jshint', 'build', 'coffee', 'cafemocha', 'mocha_phantomjs']
  @registerTask 'default', ['build']
