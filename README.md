# jshint2.vim

Lightweight and functional Vim plugin for [JSHint](http://jshint.com/) integration.

## FEATURES

* Linting whole file or selected lines without saving to disk;

* Finding `.jshintrc` configuration files inside linting file path on upper in directories;

* Optionally opening list of linting errors with useful shortcuts;

* Setting lint flags from command line with autocompletion.

## INSTALLION

1. Install NodeJS:

	On Ubuntu/Debian:

		# apt-get install node

	On ArchLinux:

		# pacman -S node

2. Install JSHint package or update it to latest version:

		# npm install --global jshint

3. Install jshint2.vim plugin:

	If you have [Pahtogen](https://github.com/tpope/vim-pathogen):

		$ git clone https://github.com/Shutnik/jshint2.vim.git ~/.vim/bundle/jshint2.vim/

	If you don't have [Pathogen](https://github.com/tpope/vim-pathogen):

		$ git clone https://github.com/Shutnik/jshint2.vim.git
		$ cp jshint2.vim/* ~/.vim/

4. Place [JSHint configuration file](http://www.jshint.com/docs/#config) into your `~`, optionally place it into your project directory.

## USAGE

Use `:JSHint` command inside Vim for lint whole file or `:'<,'>JSHint` for lint selected lines.

Use `:JSHint!` to suppress opening error list (number of linting errors still will be shown).

Use tab after `:JSHint` command to autocomplete space separated lint flags — `:JSHint white:true eqeqeq:true`.

## TIPS

Quick validation mapping:

	nnoremap <silent><F1> :JSHint<CR>
	inoremap <silent><F1> <C-O>:JSHint<CR>
	vnoremap <silent><F1> :JSHint<CR>

Lint JS files before saving:

	autocmd! bufwritepre *.js :JSHint<CR>

Error list shortcuts:

* `t` — open error in new tab;
* `s` — open error in new split;
* `v` — open error in new vertical split;
* `n` — scroll to selected error;
* `q` — close error list.

## LICENSE & AUTHOR

jshint2.vim written by [Nikolay S. Frantsev](http://frantsev.ru/) under [GPL3 License](http://www.gnu.org/licenses/gpl.html).
