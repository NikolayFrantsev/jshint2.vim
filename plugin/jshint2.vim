"
" Modern Vim plugin for JSHint integration
" <https://github.com/Shutnik/jshint2.vim>
"
" Author: Nikolay S. Frantsev <code@frantsev.ru>
"

" save plugin path + load plugin once for buffer
if exists('g:jshint2_path')
	finish
else
	let g:jshint2_path = expand('<sfile>:p:h').'/jshint2/'
endif

" save completion dictionary
execute 'let g:jshint2_completion = '.substitute(system('cat '.shellescape(g:jshint2_path.'completion.json')), '\n', '', 'g')

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

" save shell command
let g:jshint2_command = 'jshint'

" save shell command arguments
let g:jshint2_arguments = '--reporter='.shellescape(g:jshint2_path.'reporter.js')

" save shell input argument
let g:jshint2_input = '/dev/stdin'

" save config file name
let g:jshint2_config = '.jshintrc'

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

" lint buffer
function s:Lint(start, stop, show, ...)
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
	call setloclist(l:buffer, l:matrix, 'r')

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

" define command function
command! -nargs=* -complete=customlist,s:Complete -range=% -bang JSHint call s:Lint(<line1>, <line2>, <bang>1, <f-args>)

" lint files after opening
if exists('g:jshint2_read') && g:jshint2_read
	autocmd BufReadPost * if &filetype == 'javascript' | silent JSHint | endif
endif

" lint files after saving
if exists('g:jshint2_save') && g:jshint2_save
	autocmd BufWritePost * if &filetype == 'javascript' | silent JSHint | endif
endif

" define shortcuts
let g:jshint2_shortcuts = [
	\ {'key': 't', 'info': 'open error in new tab', 'exec': '<C-W><CR><C-W>T:belowright lopen<CR><C-W>p'},
	\ {'key': 's', 'info': 'open error in new split', 'exec': '<C-W><CR><C-W>='},
	\ {'key': 'v', 'info': 'open error in new vertical split', 'exec': '<C-W><CR><C-W>L'},
	\ {'key': 'i', 'info': 'ignore selected error', 'exec': ':call <SID>Ignore()<CR>'},
	\ {'key': 'n', 'info': 'scroll to selected error', 'exec': '<CR><C-W>p'},
	\ {'key': 'q', 'info': 'close error list', 'exec': ':bd<CR>'},
	\ {'key': '?', 'info': 'show help',
		\ 'exec': ':echo ''Shortcuts:''."\n".join(map(copy(g:jshint2_shortcuts), ''v:val.key." → ".v:val.info''), "\n")<CR>'}
\ ]

" define location list shortcuts
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

" ignore selected error
function s:Ignore()
	" save error line
	let l:line = getloclist(bufnr('%'))[line('.') - 1]

	" save error number
	let l:error = '-'.l:line['type'].(('00'.l:line['nr'])[-3:])

	" switch to previous buffer
	execute "normal! \<C-W>p"

	" revalidate buffer
	execute ':JSHint '.b:jshint2_flags.l:error
endfunction

" define location list mapper
autocmd FileType qf call s:Map()
