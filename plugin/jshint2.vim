"
" Modern Vim plugin for JSHint integration
" <https://github.com/Shutnik/jshint2.vim>
"
" Author: Nikolay S. Frantsev
" <http://frantsev.ru/>
"
" License: GNU GPL 3
" <http://www.gnu.org/licenses/gpl.html>
"

" check if plugin loaded
if exists(':JSHint')
	finish
endif

" define shell command
if !exists('g:jshint2_command')
	let g:jshint2_command = 'jshint'
endif

" define lint after reading variable
if !exists('g:jshint2_read')
	let g:jshint2_read = 0
endif

" define lint after saving variable
if !exists('g:jshint2_save')
	let g:jshint2_save = 0
endif

" define close orphaned error lists variable
if !exists('g:jshint2_close')
	let g:jshint2_close = 1
endif

" define show confirmation variable
if !exists('g:jshint2_confirm')
	let g:jshint2_confirm = 1
endif

" define use colors variable
if !exists('g:jshint2_color')
	let g:jshint2_color = 1
endif

" define show error number variable
if !exists('g:jshint2_error')
	let g:jshint2_error = 1
endif

" define error list min height variable
if !exists('g:jshint2_min_height')
	let g:jshint2_min_height = 3
endif

" define error list max height variable
if !exists('g:jshint2_max_height')
	let g:jshint2_max_height = 12
endif

" define local binary path
let s:local = 'node_modules/.bin/jshint'

" define config file name
let s:config = '.jshintrc'

" define shell command arguments
let s:arguments = '--reporter='.shellescape(expand('<sfile>:p:h').'/jshint2.js')

" find needle file upper in root path
function s:Find(root, needle)
	" save root path
	let l:root = a:root

	" try to find needle file
	while 1
		" save possible needle path
		let l:candidate = l:root.'/'.a:needle

		" check if needle file exists
		if filereadable(l:candidate)
			return l:candidate
		endif

		" save head path
		let l:head = fnamemodify(l:root, ':h')

		" check if we reach root
		if l:root == l:head
			return ''
		endif

		" save new root path
		let l:root = l:head
	endwhile
endfunction

" colorized output
function s:Echo(type, message)
	" set color
	if g:jshint2_color
		execute 'echohl '.a:type.'Msg'
	endif

	" output message
	echo a:message

	" reset color
	if g:jshint2_color
		echohl None
	endif
endfunction

" trim and clean string
function s:Trim(str)
	return substitute(substitute(a:str, '[\n\r]\|\s\{2,\}', ' ', 'g'), '^\s\+\|\s\+$', '', 'g')
endfunction

" lint command
function s:Lint(start, stop, show, flags)
	" filter third party quickfix and help buffers
	if &buftype == 'quickfix' && !exists('b:jshint2_buffer') || &buftype == 'help'
		return
	endif

	" save buffer number
	let l:buffer = exists('b:jshint2_buffer') ? b:jshint2_buffer : bufnr('%')

	" save buffer lines
	let l:lines = getbufline(l:buffer, a:start, a:stop)

	" save buffer hashbang flag
	let l:hashbang = l:lines[0] == '#!/usr/bin/env node'

	" confirm non javascript buffers
	if g:jshint2_confirm && &filetype != 'javascript' && !l:hashbang &&
			\ !exists('b:jshint2_flags') && !exists('b:jshint2_buffer')
		if confirm('Current file is not JavaScript, lint it anyway?', '&Yes'."\n".'&No', 1, 'Question') == 1
			redraw
		else
			return
		endif
	endif

	" get current file path
	let l:path = expand('%:p:h')

	" get local binary
	let l:local = s:Find(l:path, s:local)

	" save binary path
	let l:binary = len(l:local) ? l:local : g:jshint2_command

	" check if shell binary installed
	if !executable(l:binary)
		call s:Echo('Error', 'JSHint is not executable, check if “'.s:Trim(l:binary).'” callable from your terminal.')

		return
	endif

	" get config path
	let l:config = s:Find(l:path, s:config)

	" save full shell command
	let l:command = shellescape(l:binary).
		\ (len(l:config) ? ' --config='.shellescape(l:config) : '').' '.s:arguments.
			\ ' '.(has('win32') || has('win64') ? '-' : '/dev/stdin') " https://github.com/Shutnik/jshint2.vim/issues/8

	" save command flags
	call setbufvar(l:buffer, 'jshint2_flags', a:flags)

	" save jshint flags
	let l:flags = len(a:flags) ? '//jshint '.join(a:flags, ', ') : ''

	" ignore first hashbang line
	if l:hashbang
		let l:lines[0] = ''
	endif

	" run shell linting command
	let l:report = system(l:command, join(insert(l:lines, l:flags), "\n"))

	" check for shell errors
	if v:shell_error
		call s:Echo('Error', 'JSHint returns shell error “'.s:Trim(l:report).'”.')

		return
	endif

	" convert shell output into data matrix
	let l:matrix = map(map(split(l:report, "\n"), 'split(v:val, "\t")'),
		\ '{''bufnr'': '.l:buffer.', ''lnum'': str2nr(v:val[0] + a:start), ''col'': str2nr(v:val[1]),
			\ ''text'': v:val[2]'.(g:jshint2_error ? ', ''type'': v:val[3], ''nr'': str2nr(v:val[4])' : '').'}')

	" replace location list with new data
	call setloclist(0, l:matrix, 'r')

	" save ignored errors message
	let l:ignored = len(filter(copy(a:flags), 'v:val =~ ''^-[EWI][0-9]\{3\}$''')) ? ' Some messages are ignored.' : ''

	" close and/or override height of old location list
	lclose

	" save total number of errors
	let l:length = len(l:matrix)
	if l:length
		call s:Echo('Warning', 'JSHint found '.(l:length == 1 ? '1 error' : l:length.' errors').'.'.l:ignored.
			\ substitute(matchstr(matchstr(l:matrix[-1].text, ' (\d\+% scanned)'), '\d\+'), '\d\+',
				\ ' About &% of file scanned.', ''))

		" open location list if there is no bang
		if a:show
			let l:length = l:length + 1

			let l:height = (l:length < g:jshint2_min_height ? g:jshint2_min_height :
				\ (l:length + 1 > g:jshint2_max_height ? g:jshint2_max_height : l:length))

			execute 'belowright lopen '.l:height
		endif
	else
		call s:Echo('More', 'JSHint did not find any errors.'.l:ignored)
	endif
endfunction

" define completion dictionary
let s:completion = {
	\ 'asi': ['true', 'false'],
	\ 'bitwise': ['true', 'false'],
	\ 'boss': ['true', 'false'],
	\ 'browser': ['true', 'false'],
	\ 'camelcase': ['true', 'false'],
	\ 'couch': ['true', 'false'],
	\ 'curly': ['true', 'false'],
	\ 'debug': ['true', 'false'],
	\ 'devel': ['true', 'false'],
	\ 'dojo': ['true', 'false'],
	\ 'eqeqeq': ['true', 'false'],
	\ 'eqnull': ['true', 'false'],
	\ 'es3': ['true', 'false'],
	\ 'es5': ['true', 'false'],
	\ 'esnext': ['true', 'false'],
	\ 'evil': ['true', 'false'],
	\ 'expr': ['true', 'false'],
	\ 'forin': ['true', 'false'],
	\ 'funcscope': ['true', 'false'],
	\ 'gcl': ['true', 'false'],
	\ 'globalstrict': ['true', 'false'],
	\ 'immed': ['true', 'false'],
	\ 'indent': [2, 4, 8, 'false'],
	\ 'iterator': ['true', 'false'],
	\ 'jquery': ['true', 'false'],
	\ 'lastsemic': ['true', 'false'],
	\ 'latedef': ['nofunc', 'true', 'false'],
	\ 'laxbreak': ['true', 'false'],
	\ 'laxcomma': ['true', 'false'],
	\ 'loopfunc': ['true', 'false'],
	\ 'maxcomplexity': [4, 6, 8, 'false'],
	\ 'maxdepth': [4, 6, 8, 'false'],
	\ 'maxerr': [25, 50, 100, 'false'],
	\ 'maxlen': [64, 128, 256, 512, 'false'],
	\ 'maxparams': [4, 6, 8, 'false'],
	\ 'maxstatements': [4, 6, 8, 'false'],
	\ 'mootools': ['true', 'false'],
	\ 'moz': ['true', 'false'],
	\ 'multistr': ['true', 'false'],
	\ 'newcap': ['true', 'false'],
	\ 'noarg': ['true', 'false'],
	\ 'node': ['true', 'false'],
	\ 'noempty': ['true', 'false'],
	\ 'nomen': ['true', 'false'],
	\ 'nonew': ['true', 'false'],
	\ 'nonstandard': ['true', 'false'],
	\ 'onecase': ['true', 'false'],
	\ 'onevar': ['true', 'false'],
	\ 'passfail': ['true', 'false'],
	\ 'phantom': ['true', 'false'],
	\ 'plusplus': ['true', 'false'],
	\ 'proto': ['true', 'false'],
	\ 'prototypejs': ['true', 'false'],
	\ 'quotmark': ['single', 'double', 'true', 'false'],
	\ 'regexdash': ['true', 'false'],
	\ 'regexp': ['true', 'false'],
	\ 'rhino': ['true', 'false'],
	\ 'scripturl': ['true', 'false'],
	\ 'shadow': ['true', 'false'],
	\ 'shelljs': ['true', 'false'],
	\ 'smarttabs': ['true', 'false'],
	\ 'strict': ['true', 'false'],
	\ 'sub': ['true', 'false'],
	\ 'supernew': ['true', 'false'],
	\ 'trailing': ['true', 'false'],
	\ 'typed': ['true', 'false'],
	\ 'undef': ['true', 'false'],
	\ 'unused': ['vars', 'strict', 'true', 'false'],
	\ 'validthis': ['true', 'false'],
	\ 'white': ['true', 'false'],
	\ 'withstmt': ['true', 'false'],
	\ 'worker': ['true', 'false'],
	\ 'wsh': ['true', 'false'],
	\ 'yui': ['true', 'false']
\ }

" command completion
function s:Complete(arg, cmd, ...)
	" find colon in current argument
	let l:colon = stridx(a:arg, ':')

	" check if we have flag
	if l:colon == -1
		" save typed flags
		let l:flags = map(filter(split(a:cmd, '\s\+'), 'stridx(v:val, '':'') > -1'), 'v:val[: stridx(v:val, '':'') - 1]')

		" filter complete flags
		return filter(keys(s:completion), 'index(l:flags, v:val) == -1 && v:val =~ ''^''.a:arg[: -1]')
	endif

	" save flag and value
	let l:flag = a:arg[: l:colon - 1]
	let l:value = a:arg[l:colon + 1 :]

	" filter complete flag values
	return has_key(s:completion, l:flag) ?
		\ sort(map(filter(copy(s:completion[l:flag]), 'v:val =~ ''^''.l:value'), 'l:flag.'':''.v:val')) : []
endfunction

" define error list shortcuts
let s:shortcuts = {
	\ 't': '<C-W><CR><C-W>T',
	\ 'T': '<C-W><CR><C-W>T:lopen<CR><C-W>p',
	\ 'v': '<C-W><CR><C-W>L<C-W>=',
	\ 'V': '<C-W><CR><C-W>L:lopen<CR><C-W>p<C-W>=',
	\ 's': '<C-W><CR><C-W>=',
	\ 'S': '<C-W><CR>:lopen<CR><C-W>p<C-W>=',
	\ 'i': ':call <SID>Ignore()<CR>',
	\ 'n': '<CR><C-W>p',
	\ 'q': ':lclose<CR>'
\ }

" location list mapper
function s:Map()
	" get errors list
	let l:errors = getloclist(0)

	" check errors length
	if !len(l:errors)
		return
	endif

	" get lint flags
	let l:flags = getbufvar(l:errors[0].bufnr, 'jshint2_flags')

	" check mapping necessity
	if type(l:flags) != type([])
		return
	endif

	" set buffer status line
	execute 'setlocal statusline=[JSHint\ Error\ List]\ '.join(l:flags, '\ ')

	" hide buffer from buffers list
	setlocal nobuflisted

	" map shortcuts
	for l:key in keys(s:shortcuts)
		execute 'nnoremap <silent><buffer>'.l:key.' '.s:shortcuts[l:key]
	endfor

	" save buffer associated with error list
	let b:jshint2_buffer = l:errors[0].bufnr
endfunction

" revalidate ignoring selected error
function s:Ignore()
	" get current error (no need to check errors length since mapping function do it)
	let l:line = getloclist(0)[line('.') - 1]

	" get error number
	let l:number = l:line.nr

	" check if showing error number not disabled
	if !l:number
		return
	endif

	" switch to linting buffer
	execute bufwinnr(l:line.bufnr).'wincmd w'

	" get new error
	let l:error = '-'.l:line.type.(('00'.l:number)[-3 :])

	" save ignore command
	let l:ignore = 'JSHint '.join(b:jshint2_flags).' '.l:error

	" push ignore command into history
	call histadd(':', l:ignore)

	" revalidate buffer
	execute l:ignore
endfunction

" command function
command! -nargs=* -complete=customlist,s:Complete -range=% -bang JSHint call s:Lint(<line1>, <line2>, <bang>1, [<f-args>])

" automatic commands group
augroup jshint2
	" lint files after reading
	autocmd BufReadPost *
		\ if g:jshint2_read && &filetype == 'javascript' |
			\ silent execute 'JSHint' |
		\ endif

	" lint files after saving
	autocmd BufWritePost *
		\ if g:jshint2_save && &filetype == 'javascript' |
			\ silent execute 'JSHint' |
		\ endif

	" close orphaned error lists
	autocmd BufEnter *
		\ if g:jshint2_close && exists('b:jshint2_buffer') && bufwinnr(b:jshint2_buffer) == -1 |
			\ quit |
		\ endif

	" map commands for error list
	autocmd FileType qf call s:Map()
augroup END
