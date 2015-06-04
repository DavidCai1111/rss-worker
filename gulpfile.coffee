gulp = require 'gulp'
coffee = require 'gulp-coffee'
mocha = require 'gulp-mocha'
istanbul = require 'gulp-istanbul'
fs = require 'fs-extra'

gulp.task 'compile_coffee', () ->
  gulp.src(['**/*.coffee', 'index.coffee', '!node_modules/**/*.coffee'])
  .pipe(coffee())
  .pipe gulp.dest 'build/'

gulp.task 'test', ['compile_coffee'], (cb) ->
  test = () ->
    gulp.src(['build/lib/**/*.js', 'build/index.js'])
    .pipe(istanbul())
    .pipe(istanbul.hookRequire())
    .on 'finish', () ->
      gulp.src(['build/test/*.js'])
      .pipe(mocha())
      .pipe(istanbul.writeReports())
      .on 'end', () ->
        cb()
        process.exit 0
  process.nextTick test

gulp.task 'default', ['compile_coffee'], () ->
  fs.copySync './test/rss_test', './build/test/rss_test'
  gulp.start 'test'