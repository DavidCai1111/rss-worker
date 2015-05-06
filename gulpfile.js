var gulp = require('gulp');
var coffee = require('gulp-coffee');

var src = ['.', './lib', './test'];

gulp.task('compile_coffee', function () {
  for (var i = 0; i < src.length; i++) {
    gulp.src(src[i] + '/*.coffee')
      .pipe(coffee())
      .pipe(gulp.dest(src[i]));
  }
});

gulp.task('default', ['compile_coffee']);