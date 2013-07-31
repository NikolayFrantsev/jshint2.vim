"
" Modern Vim plugin for JSHint integration
" <https://github.com/Shutnik/jshint2.vim>
"
" Author: Nikolay S. Frantsev <code@frantsev.ru>
"
" Distributed under GPL3 License
" <http://www.gnu.org/licenses/gpl.html>
"

" check if plugin loaded
if exists(':JSHint')
	finish
endif

" define shell command
let g:jshint2_command = exists('g:jshint2_command') ? g:jshint2_command : 'jshint'

" define shell command arguments
let g:jshint2_arguments = exists('g:jshint2_arguments') ? g:jshint2_arguments :
	\ '--reporter='.shellescape(expand('<sfile>:p:h').'/jshint2.js')

" define shell command input
let g:jshint2_input = exists('g:jshint2_input') ? g:jshint2_input : '/dev/stdin'

" define config file name
let g:jshint2_config = exists('g:jshint2_config') ? g:jshint2_config : '.jshintrc'

" define lint after reading variable
let g:jshint2_read = exists('g:jshint2_read') ? g:jshint2_read : 0

" define lint after saving variable
let g:jshint2_save = exists('g:jshint2_save') ? g:jshint2_save : 0

" define show confirmation variable
let g:jshint2_confirm = exists('g:jshint2_confirm') ? g:jshint2_confirm : 1

" define completion dictionary
let g:jshint2_completion = {
	\ "asi": ["true", "false"],
	\ "bitwise": ["true", "false"],
	\ "boss": ["true", "false"],
	\ "browser": ["true", "false"],
	\ "camelcase": ["true", "false"],
	\ "couch": ["true", "false"],
	\ "curly": ["true", "false"],
	\ "debug": ["true", "false"],
	\ "devel": ["true", "false"],
	\ "dojo": ["true", "false"],
	\ "eqeqeq": ["true", "false"],
	\ "eqnull": ["true", "false"],
	\ "es3": ["true", "false"],
	\ "es5": ["true", "false"],
	\ "esnext": ["true", "false"],
	\ "evil": ["true", "false"],
	\ "expr": ["true", "false"],
	\ "forin": ["true", "false"],
	\ "funcscope": ["true", "false"],
	\ "gcl": ["true", "false"],
	\ "globalstrict": ["true", "false"],
	\ "immed": ["true", "false"],
	\ "indent": [2, 4, 8, "false"],
	\ "iterator": ["true", "false"],
	\ "jquery": ["true", "false"],
	\ "lastsemic": ["true", "false"],
	\ "latedef": ["nofunc", "true", "false"],
	\ "laxbreak": ["true", "false"],
	\ "laxcomma": ["true", "false"],
	\ "loopfunc": ["true", "false"],
	\ "maxcomplexity": [4, 6, 8, "false"],
	\ "maxdepth": [4, 6, 8, "false"],
	\ "maxerr": [25, 50, 100, "false"],
	\ "maxlen": [64, 128, 256, 512, "false"],
	\ "maxparams": [4, 6, 8, "false"],
	\ "maxstatements": [4, 6, 8, "false"],
	\ "mootools": ["true", "false"],
	\ "moz": ["true", "false"],
	\ "multistr": ["true", "false"],
	\ "newcap": ["true", "false"],
	\ "noarg": ["true", "false"],
	\ "node": ["true", "false"],
	\ "noempty": ["true", "false"],
	\ "nomen": ["true", "false"],
	\ "nonew": ["true", "false"],
	\ "nonstandard": ["true", "false"],
	\ "onecase": ["true", "false"],
	\ "onevar": ["true", "false"],
	\ "passfail": ["true", "false"],
	\ "phantom": ["true", "false"],
	\ "plusplus": ["true", "false"],
	\ "proto": ["true", "false"],
	\ "prototypejs": ["true", "false"],
	\ "quotmark": ["single", "double", "true", "false"],
	\ "regexdash": ["true", "false"],
	\ "regexp": ["true", "false"],
	\ "rhino": ["true", "false"],
	\ "scripturl": ["true", "false"],
	\ "shadow": ["true", "false"],
	\ "smarttabs": ["true", "false"],
	\ "strict": ["true", "false"],
	\ "sub": ["true", "false"],
	\ "supernew": ["true", "false"],
	\ "trailing": ["true", "false"],
	\ "undef": ["true", "false"],
	\ "unused": ["strict", "vars", "true", "false"],
	\ "validthis": ["true", "false"],
	\ "white": ["true", "false"],
	\ "withstmt": ["true", "false"],
	\ "worker": ["true", "false"],
	\ "wsh": ["true", "false"],
	\ "yui": ["true", "false"]
\ }

" define error list shortcuts
let g:jshint2_shortcuts = [
	\ {'key': 't', 'info': 'open error in new tab', 'exec': '<C-W><CR><C-W>T:belowright lopen<CR><C-W>p'},
	\ {'key': 's', 'info': 'open error in new split', 'exec': '<C-W><CR><C-W>='},
	\ {'key': 'v', 'info': 'open error in new vertical split', 'exec': '<C-W><CR><C-W>L'},
	\ {'key': 'i', 'info': 'ignore selected error', 'exec': ':call <SID>Ignore()<CR>'},
	\ {'key': 'n', 'info': 'scroll to selected error', 'exec': '<CR><C-W>p'},
	\ {'key': 'q', 'info': 'close error list', 'exec': ':bd<CR>'},
	\ {'key': '?', 'info': 'show help', 'exec': ':redraw<CR>
		\ :echo ''Shortcuts:''."\n".join(map(copy(g:jshint2_shortcuts), ''v:val.key." → ".v:val.info''), "\n")<CR>'}
\ ]

" lint command constructor
function s:Command()
	" current file path
	let l:path = expand('%:p:h')

	" try to find config file
	while l:path != '/' && !filereadable(l:path.'/'.g:jshint2_config)
		let l:path = fnamemodify(l:path, ':h')
	endwhile

	" save lint command list
	let l:command = [g:jshint2_command, g:jshint2_arguments, g:jshint2_input]

	" save config file
	let l:config = l:path.'/'.g:jshint2_config

	" insert config argument
	if filereadable(l:config)
		let l:command = insert(l:command, '--config='.shellescape(l:config), 1)
	endif

	" return full shell command
	return join(l:command)
endfunction

" lint command
function s:Lint(start, stop, show, ...)
	" detect file type
	let l:filetype = &filetype

	" filter error list and confirm no javascript buffers
	if l:filetype == 'qf' || l:filetype != 'javascript' && g:jshint2_confirm &&
			\ confirm('Current file is not JavaScript, lint it any way?', '&Yes'."\n".'&No', 1, 'Question') != 1
		return -3
	endif

	" clear previous output
	redraw

	" check if shell binary installed
	if !executable(g:jshint2_command)
		echohl ErrorMsg
		echo 'Seems JSHint is not installed!'
		echohl None

		return -2
	endif

	" save command flags
	let b:jshint2_flags = len(a:000) ? join(a:000, ' ').' ' : ''
	let l:flags = len(a:000) ? '//jshint '.join(a:000, ', ') : ''

	" save whole file or selected lines
	let l:content = insert(getline(a:start, a:stop), l:flags)

	" ignore first shebang line
	if l:content[1][:1] == '#!'
		let l:content[1] = ''
	endif

	" run shell linting command
	let l:report = system(s:Command(), join(l:content, "\n"))

	" check for shell errors
	if v:shell_error
		echohl ErrorMsg
		echo 'Error while executing JSHint!'
		echohl None

		return -1
	endif

	" save buffer number
	let l:buffer = bufnr('%')

	" convert shell output into data matrix
	let l:matrix = map(map(split(l:report, "\n"), 'split(v:val, "\t")'),
		\ '{''bufnr'': '.l:buffer.', ''lnum'': str2nr(v:val[0] + a:start), ''col'': str2nr(v:val[1]),
			\ ''type'': v:val[2], ''nr'': str2nr(v:val[3]), ''text'': v:val[4]}')

	" replace location list with new data
	call setloclist(0, l:matrix, 'r')

	" save total number of errors
	let l:length = len(l:matrix)
	if l:length
		echo 'There are '.l:length.' errors found!'

		" open location list if there is no bang
		if a:show
			belowright lopen
		endif
	else
		echo 'No errors found!'

		" close old location list
		lclose
	endif

	return l:length
endfunction

" command completion
function s:Complete(arg, cmd, ...)
	" find colon in current argument
	let l:colon = stridx(a:arg, ':')

	" check if we have flag
	if l:colon == -1
		" save typed flags
		let l:flags = map(filter(split(a:cmd, '\s\+'), 'stridx(v:val, '':'') > -1'), 'v:val[: stridx(v:val, '':'') - 1]')

		" filter complete flags
		return filter(keys(g:jshint2_completion), 'index(l:flags, v:val) == -1 && v:val =~ ''^''.a:arg[: -1]')
	endif

	" save flag and value
	let l:flag = a:arg[: l:colon - 1]
	let l:value = a:arg[l:colon + 1 :]

	" filter complete flag values
	return has_key(g:jshint2_completion, l:flag) ?
		\ sort(map(filter(copy(g:jshint2_completion[l:flag]), 'v:val =~ ''^''.l:value'), 'l:flag.'':''.v:val')) : []
endfunction

" location list mapper
function s:Map()
	" switch to previous buffer
	execute "normal! \<C-W>p"

	" save plugin loaded flag
	let g:jshint2_map = exists('b:jshint2_flags')

	" switch back to location list
	execute "normal! \<C-W>p"

	" map commands if plugin loaded
	if g:jshint2_map
		for l:item in g:jshint2_shortcuts
			execute 'nnoremap <silent><buffer>'.l:item.key.' '.l:item.exec
		endfor
	endif

	" remove loaded flag
	unlet g:jshint2_map
endfunction

" revalidate ignoring selected error
function s:Ignore()
	" save error line
	let l:line = getloclist(0)[line('.') - 1]

	" save error number
	let l:error = '-'.l:line['type'].(('00'.l:line['nr'])[-3:])

	" switch to previous buffer
	execute "normal! \<C-W>p"

	" revalidate buffer
	execute ':JSHint '.b:jshint2_flags.l:error
endfunction

" command function
command! -nargs=* -complete=customlist,s:Complete -range=% -bang JSHint call s:Lint(<line1>, <line2>, <bang>1, <f-args>)

" automatic commands group
augroup jshint2

	" lint files after reading
	if g:jshint2_read
		autocmd BufReadPost * if &filetype == 'javascript' | silent JSHint | endif
	endif

	" lint files after saving
	if g:jshint2_save
		autocmd BufWritePost * if &filetype == 'javascript' | silent JSHint | endif
	endif

	" map commands for error list
	autocmd FileType qf call s:Map()

augroup END
