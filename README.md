# jshint2.vim

Lightweight, customizable and functional Vim plugin for [JSHint](http://jshint.com/) integration.

![jshint2.vim](https://raw.github.com/Shutnik/jshint2.vim/master/screenshot.png)

## Features

* Linting whole file or selected lines without saving to disk.
* Finding configuration files inside linting file path on upper in directories.
* Optionally opening list of linting errors with useful shortcuts.
* Setting lint flags from command line with autocompletion.
* Autovalidation files after reading or saving.

## Installation

1. [Install Node.js](https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager).
2. [Install JSHint](http://jshint.com/install/), globally prefered (see [Configuration](#configuration)).
3. Place [.jshintrc](http://www.jshint.com/docs/#config) into your `~`, optionally place it into your project directory.
4. [Install Pathogen](https://github.com/tpope/vim-pathogen#installation).
5. Clone plugin into your `~/.vim/bundle/jshint2.vim/`.
6. ???
7. PROFIT!

## Usage

Use `:JSHint` command inside Vim to lint whole file or `:'<,'>JSHint` to lint only selected lines.  
Add `!` to suppress opening error list (number of lint errors still will be shown) — `:JSHint!`.  
Add space and use tab key to complete space separated lint flags — `:JSHint white:true eqeqeq:true`.  
Use `-` to ignore errors by their codes — `:JSHint -E001 -W002 -I003`.  

## Error List Shortcuts

`t` — open error in new tab.  
`s` — open error in new split.  
`v` — open error in new vertical split.  
`i` — ignore selected error.  
`n` — scroll to selected error.  
`q` — close error list.  
`?` — show help.  

## Configuration

Set JSHint command path if it installed locally:

	let g:jshint_command = '~/path/to/jshint'

Lint JavaScript files after opening:

	let g:jshint2_read = 1

Lint JavaScript files after saving:

	let g:jshint2_save = 1

## Tips

Quick lint mapping:

	nnoremap <silent><F1> :JSHint<CR>
	inoremap <silent><F1> <C-O>:JSHint<CR>
	vnoremap <silent><F1> :JSHint<CR>
	cnoremap <F1> JSHint

## Author & License

Written by [Nikolay S. Frantsev](http://frantsev.ru/) under [GPL3 License](http://www.gnu.org/licenses/gpl.html).
