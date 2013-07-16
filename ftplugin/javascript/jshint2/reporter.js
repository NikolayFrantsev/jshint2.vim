/*
 * Custom JSHint reporter for Vim plugin
 * <https://github.com/Shutnik/jshint2.vim>
 *
 * Author: Nikolay S. Frantsev <code@frantsev.ru>
 */

/*jshint node:true*/

exports.reporter = function (reports) {
	var index = -1, length = reports.length,
		error, line, code,
		result = '';

	while (++index < length) {
		if ((line = (error = reports[index].error).line) > 1) { // filter command line flags errors
			result +=
				(line - 2) + '\t' + // quickfix lines starts with 1 + 1 line for command line flags
				error.character + '\t' +
				((typeof (code = error.code) === 'string') ? // see https://github.com/jshint/jshint/pull/1164
					code[0] + '\t' + (+code.substring(1)) : '\t') + '\t' + // quickfix strips leading zeros in error numbers
				error.reason + '\n';
		}
	}

	process.stdout.write(result);

	process.exit(0); // prevent showing shell error
};
