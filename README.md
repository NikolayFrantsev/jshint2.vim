# jshint2.vim

Lightweight, customizable and functional Vim plugin for [JSHint](http://jshint.com/) integration.

![jshint2.vim](https://dl.dropbox.com/s/ab95l1gnbub8m04/jshint2.vim.png)

## Features

* Linting whole file or selected lines without saving to disk.
* Finding configuration files inside linting file path or upper in directories.
* Setting lint flags from command line with autocompletion.
* Optionally opening list of linting errors with useful shortcuts.
* Optionally validating files after reading or saving.
* Working on Linux, Windows and OS X.

## Installation

1. [Install Node.js](http://nodejs.org/download/).
2. [Install JSHint](http://jshint.com/install/), globally [preferred](#configuration).
3. Place [.jshintrc](http://www.jshint.com/docs/options/) into your `~`, optionally place it into your project directory.
4. [Install Pathogen](https://github.com/tpope/vim-pathogen#installation), necessarily check [super-minimal example](https://github.com/tpope/vim-pathogen#runtime-path-manipulation).
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

```vim
let jshint2_command = '~/path/to/jshint'
```

Lint JavaScript files after reading it:

```vim
let jshint2_read = 1
```

Lint JavaScript files after saving it:

```vim
let jshint2_save = 1
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

## Tips

Quick lint mapping:

```vim
nnoremap <silent><F1> :JSHint<CR>
inoremap <silent><F1> <C-O>:JSHint<CR>
vnoremap <silent><F1> :JSHint<CR>
cnoremap <F1> JSHint
```

## Author & License

Written by [Nikolay S. Frantsev](http://frantsev.ru/) under [GNU GPL 3 License](http://www.gnu.org/licenses/gpl.html).
