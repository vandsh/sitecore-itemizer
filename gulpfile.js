'use strict';
// Init
var gutil = require('gulp-util');
var gulp = require('gulp');
var exec = require('child_process').exec;


//Paths
var paths = {
	themeSrc: "../WebProject",
	itemSrc: "../TDSProject"
}
var scriptToCreateItem = "parse-content-and-itemize.ps1";
var scriptToCreateAsset = "parse-item-and-write.ps1";
	
gulp.task('default', function (cb) {
	gulp.watch([paths.themeSrc + '/**/*.js', paths.themeSrc + '/**/*.css']).on('change', function (file) {
		gutil.log('Changed:', gutil.colors.yellow(file.path));
		var execScript = "powershell.exe -file \"" + scriptToCreateItem + "\" \"" + file.path + "\" \"" + paths.themeSrc + "\" \"" + paths.itemSrc + "\"";
		exec(execScript, function (err, stdout, stderr) {
			gutil.log(gutil.colors.magenta(stdout));
			gutil.log(gutil.colors.red(stderr));
		});
	});
	
	gulp.watch([paths.itemSrc + '/**/*.item']).on('change', function (file) {
		gutil.log('Changed:', gutil.colors.blue(file.path));
		var execScript = "powershell.exe -file \"" + scriptToCreateAsset + "\" \"" + file.path + "\" \"" + paths.themeSrc + "\"";
		exec(execScript, function (err, stdout, stderr) {
			gutil.log(gutil.colors.magenta(stdout));
			gutil.log(gutil.colors.red(stderr));
		});
	});
});