/*
 * Custom JSHint reporter for Vim plugin
 * <https://github.com/Shutnik/jshint2.vim>
 *
 * Author: Nikolay S. Frantsev <code@frantsev.ru>
 */

/*jshint node:true*/

exports.reporter = function (reports) {
	process.stdout.write(
		reports.filter(function (report) { // filter command line flags errors
			return report.error.line > 1;
		}).map(function (report) {
			var error = report.error;

			return [
				error.line - 2, // quickfix lines starts with 1 + 1 line for command line flags
				error.character,
				error.code[0],
				parseInt(error.code.substr(1), 10), // quickfix strips leading zeros in error numbers
				error.reason
			].join('\t');
		}).join('\n')
	);

	process.exit(0); // prevent showing shell error
};
