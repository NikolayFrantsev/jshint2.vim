# jshint2.vim

Lightweight and functional Vim plugin for [JSHint](http://jshint.com/) integration.

![jshint2.vim](https://raw.github.com/Shutnik/jshint2.vim/master/screenshot.png)

## Features

* Linting whole file or selected lines without saving to disk.
* Finding configuration files inside linting file path on upper in directories.
* Optionally opening list of linting errors with useful shortcuts.
* Setting lint flags from command line with autocompletion.

## Installation

1. Install [Node.js](https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager).
2. Globally install [JSHint](http://jshint.com/install/).
3. Place [.jshintrc](http://www.jshint.com/docs/#config) into your `~`, optionally place it into your project directory.
4. Install [Pathogen](https://github.com/tpope/vim-pathogen).
5. Place plugin into your `~/.vim/bundle/jshint2.vim/`.

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

## Tips

Quick lint mapping:

	nnoremap <silent><F1> :JSHint<CR>
	inoremap <silent><F1> <C-O>:JSHint<CR>
	vnoremap <silent><F1> :JSHint<CR>
	cnoremap <F1> JSHint

Lint JavaScript files after opening:

	autocmd! BufWinEnter * if &filetype == "javascript" | silent JSHint | endif

Lint JavaScript files before saving:

	autocmd! BufWritePost * if &filetype == "javascript" | silent JSHint | endif

## Author & License

Written by [Nikolay S. Frantsev](http://frantsev.ru/) under [GPL3 License](http://www.gnu.org/licenses/gpl.html).
