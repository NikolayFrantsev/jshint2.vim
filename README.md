# jshint2.vim

Lightweight, customizable and functional Vim plugin for [JSHint](http://jshint.com/) integration.

![jshint2.vim](https://dl.dropbox.com/s/ab95l1gnbub8m04/jshint2.vim.png)

## Features

* Linting whole file or selected lines without saving to disk.
* Using project-specific (locally installed) version of JSHint and JSHint configuration files if available.
* Setting lint flags from command line with autocompletion.
* Optionally opening list of linting errors with useful shortcuts.
* Optionally validating files after reading or saving.
* Working on Linux, Windows (with JSHint 2.1.5 and newer) and OS X.

## Installation

1. Install [Node.js](http://nodejs.org/download/) and [JSHint](http://jshint.com/install/).
1. Clone plugin into your `~/.vim/bundle/jshint2.vim/`.
1. Install [Pathogen](https://github.com/tpope/vim-pathogen) or just add `set runtimepath+=~/.vim/bundle/jshint2.vim/` into your `.vimrc`.
1. Optionally place [.jshintrc](http://www.jshint.com/docs/options/) into your home and/or project directory.
1. ???
1. PROFIT!

## Usage

Use `:JSHint` command inside Vim to lint whole file or `:'<,'>JSHint` to lint only selected lines.  
Add `!` to suppress opening error list (number of lint errors still will be shown), add space and use tab key to complete space separated lint flags — `:JSHint! white:true eqeqeq:true`. Use `-` to ignore errors by their codes — `:JSHint -E001 -W002 -I003`.  

## Error List Shortcuts

`t` — open error in new tab.  
`T` — open error in new tab with error list.  
`v` — open error in new vertical split.  
`V` — open error in new vertical split with error list.  
`s` — open error in new horizontal split.  
`S` — open error in new horizontal split with error list.  
`i` — ignore selected error.  
`n` — scroll to selected error.  
`q` — close error list.  

## Configuration

Set global JSHint command path (mostly for Windows):

```vim
let jshint2_command = '~/path/to/node_modules/.bin/jshint'
```

Lint JavaScript files after reading it:

```vim
let jshint2_read = 1
```

Lint JavaScript files after saving it:

```vim
let jshint2_save = 1
```

Do not automatically close orphaned error lists:
```vim
let jshint2_close = 0
```

Skip lint confirmation for non JavaScript files:

```vim
let jshint2_confirm = 0
```

Do not use colored messages:

```vim
let jshint2_color = 0
```

Hide error codes in error list (if you don't use error ignoring or error codes confuses you):

```vim
let jshint2_error = 0
```

Set min and max height of error list:

```vim
let jshint2_min_height = 3
let jshint2_max_height = 12
```

## Tips

Quick lint mapping:

```vim
" jshint validation
nnoremap <silent><F1> :JSHint<CR>
inoremap <silent><F1> <C-O>:JSHint<CR>
vnoremap <silent><F1> :JSHint<CR>

" show next jshint error
nnoremap <silent><F2> :lnext<CR>
inoremap <silent><F2> <C-O>:lnext<CR>
vnoremap <silent><F2> :lnext<CR>

" show previous jshint error
nnoremap <silent><F3> :lprevious<CR>
inoremap <silent><F3> <C-O>:lprevious<CR>
vnoremap <silent><F3> :lprevious<CR>
```

## Author & License

Written by [Nikolay S. Frantsev](http://frantsev.ru/) under [GNU GPL 3 License](http://www.gnu.org/licenses/gpl.html).
