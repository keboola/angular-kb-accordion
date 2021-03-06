module.exports = (grunt) ->
  readPackage = ->
    grunt.file.readJSON('package.json')

  pkg = readPackage()

  # load npm tasks defined in package
  for npmTask of pkg.devDependencies
    continue  if npmTask.indexOf("grunt-") isnt 0
    grunt.loadNpmTasks npmTask

  # Project configuration.
  grunt.initConfig
    pkg: pkg
    meta:
      banner: "/**\n" + " * <%= pkg.description %>\n" + " * @version v<%= pkg.version %> - " + "<%= grunt.template.today(\"yyyy-mm-dd\") %>\n" + " * @link <%= pkg.homepage %>\n" + " * @license MIT License, http://www.opensource.org/licenses/MIT\n" + " */"

    bumpup: [
      'package.json'
      'bower.json'
    ]
    clean:
      dist: ["docs/build"]
      tmp: ["tmp/"]

    coffee:
      dist:
        expand: true
        cwd: "src/"
        src: ["**/*.coffee"]
        dest: "tmp/"
        ext: ".js"

    concat:
      options:
        banner: "<%= meta.banner %>"

      dist_scripts:
        src: [
          "tmp/**/*.js"
        ]
        dest: "dist/<%= pkg.name %>.js"


    # minifications
    uglify:
      dist:
        src: ["<%= concat.dist_scripts.dest %>"]
        dest: "dist/<%= pkg.name %>.min.js"

    # rebuild coffee on chage
    # rebuild all on index-template or grunt.js change
    watch:
      coffee:
        files: ["src/**/*.coffee"]
        tasks: ["coffee", "concat:dist_scripts", "uglify", "karma:unit:run"]

      grunt:
        files: ["Gruntfile.coffee"]
        tasks: "build"


    jshint:
      options:
        curly: true
        eqeqeq: true
        immed: true
        latedef: true
        newcap: true
        noarg: true
        sub: true
        undef: true
        boss: true
        eqnull: true
        browser: true

      globals:
        jQuery: true

    karma:
      unit:
        configFile: "karma.conf.js"
        background: true

      ci:
        configFile: "karma.conf.js"
        singleRun: true
        browsers: ["PhantomJS"]

    tagrelease:
      file: 'package.json'
      commit: true
      message: 'Release %version%'
      prefix: ''
      annotate: false

    connect:
      docsServer:
        options:
          port: 9002
          base: "docs"
          keepalive: true

    ###
      Publish gh pages, workflow:
      - init new repo in docs_dist directory
      - add everything into repo
      - commit
      - force push to origin repository gh-pages branch
    ###
    grunt.registerTask "uploadDocs", "Upload documentation to Github", ->
      this.requires(["clean:docs_dist", "copy:docs_dist"])

      # do everything in docs_dist folder
      grunt.file.setBase "docs_dist"
      done = this.async()

      commands = [
        {
          cmd: "git"
          args: ["init"]
        }
        {
          cmd: "git"
          args: ["add", "."]
        }
        {
          cmd: "git"
          args: ["commit", "-m", "Pages updated"]
        }
        {
          cmd: "git"
          args: ["push", "-f", "git@github.com:keboola/angular-kb.git", "master:gh-pages"]
        }
      ]

      executeCommand = (command, callback) ->
        grunt.log.write('Executing: ' + command.cmd + ' ' + command.args.join(" ") + ' ...')
        grunt.util.spawn(command, (error, result, code) ->
          grunt.log.ok() if !error
          callback(error, result, code)
        )

      grunt.util.async.forEachSeries(commands, executeCommand, (err) ->
        done(err)
      )


    grunt.registerTask "build", [
      "clean"
      "coffee"
      "concat"
      "uglify"
    ]

    grunt.registerTask "updatePkg", ->
      grunt.config.set "pkg", readPackage()

    grunt.registerTask "release", (type) ->
      grunt.task.run('jshint')
      grunt.task.run('bumpup:' + if type then type else "patch")
      grunt.task.run('updatePkg')
      grunt.task.run('build')
      grunt.task.run('tagrelease')

    grunt.registerTask "devel", [
      "karma:unit"
      "watch"
    ]

    grunt.registerTask "docsServer", [
      "connect:docsServer"
    ]

    grunt.registerTask "publishDocs", [
      "default"
      "clean:docs_dist"
      "copy:docs_dist"
      "uploadDocs"
    ]

    grunt.registerTask "default", [
      "build"
    ]