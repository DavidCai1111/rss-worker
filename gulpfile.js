var gulp = require('gulp');
var coffee = require('gulp-coffee');
var mocha = require('gulp-mocha');
var istanbul = require('gulp-istanbul');

gulp.task('compile_coffee', function () {
  gulp.src(['**/*.coffee', 'index.coffee', '!node_modules/**/*.coffee'])
    .pipe(coffee())
    .pipe(gulp.dest('build/'));
});

gulp.task('test', ['compile_coffee'], function (cb) {
  //确保coffee已被编译
  setTimeout(test, 1000 * 5);

  function test() {
    gulp.src(['build/lib/**/*.js', 'build/index.js'])
      .pipe(istanbul())
      .pipe(istanbul.hookRequire())
      .on('finish', function () {
        gulp.src(['build/test/*.js'])
          .pipe(mocha())
          .pipe(istanbul.writeReports())
          .on('end', cb)
      })
  }
});

gulp.task('default', ['compile_coffee'], function () {
  gulp.start('test');
});