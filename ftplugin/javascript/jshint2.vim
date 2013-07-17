"
" Modern Vim plugin for JSHint integration
" <https://github.com/Shutnik/jshint2.vim>
"
" Author: Nikolay S. Frantsev <code@frantsev.ru>
"

" save plugin path + load plugin once for buffer
if exists('b:jshint2_path')
	finish
else
	let b:jshint2_path = expand('<sfile>:p:h').'/jshint2/'
endif

" load completion dictionary
execute 'let s:completion = '.substitute(system('cat '.shellescape(b:jshint2_path.'completion.json')), '\n', '', 'g')

" completion for command line
function! s:Complete(arg, cmd, ...)
	" check if we already have flag key
	let colon = stridx(a:arg, ':')

	" complete matched flags
	if colon == -1
		" find already typed flags
		let flags = map(filter(split(a:cmd, '\s\+'), 'stridx(v:val, ":") > -1'), 'v:val[: stridx(v:val, ":") - 1]')

		" filter complete flags
		return filter(keys(s:completion), 'index(flags, v:val) == -1 && v:val =~ "^".a:arg[: -1]')
	endif

	" find typed flag and value
	let flag = a:arg[: colon - 1]
	let value = a:arg[colon + 1 :]

	" complete flag values
	return has_key(s:completion, flag) ? sort(map(filter(copy(s:completion[flag]), 'v:val =~ "^".value'), 'flag.":".v:val')) : []
endfunction

" save shell command
let s:execute_command = 'jshint'

" save shell command arguments
let s:execute_arguments = ' --reporter='.shellescape(b:jshint2_path.'reporter.js').' /dev/stdin'

" lint command constructor
function! s:LintCommand()
	" current file path
	let path = expand('%:p:h')

	" config file to find
	let file = '/.jshintrc'

	" try to find config file
	while path != '/' && !filereadable(path.file)
		let path = fnamemodify(path, ':h')
	endwhile

	" save config argument
	let config = filereadable(path.file) ? ' --config='.shellescape(path.file) : ''

	" return full shell command
	return s:execute_command.config.s:execute_arguments
endfunction

" save buffer number
let b:jshint2_buffer = bufnr('%')

" lint buffer
function! s:Lint(start, stop, show, ...)
	" check if shell binary installed
	if !executable(s:execute_command)
		echohl ErrorMsg
		echo 'Seems JSHint is not installed!'
		echohl None

		return -2
	endif

	" save command line flags
	let b:jshint2_flags = len(a:000) ? join(a:000, ' ').' ' : ''
	let flags = len(a:000) ? '//jshint '.join(a:000, ', ') : ''

	" save whole file or selected lines
	let content = insert(getline(a:start, a:stop), flags)

	" run shell linting command
	let report = system(s:LintCommand(), join(content, "\n"))

	" check for shell errors
	if v:shell_error
		echohl ErrorMsg
		echo 'Error while executing JSHint!'
		echohl None

		return -1
	endif

	" convert shell output into quickfix dictionary
	let qflist = map(map(split(report, "\n"), 'split(v:val, "\t")'),
		\ '{"bufnr": '.b:jshint2_buffer.', "lnum": str2nr(v:val[0] + a:start), "col": str2nr(v:val[1]),
			\ "type": v:val[2], "nr": str2nr(v:val[3]), "text": v:val[4]}')

	" close old quickfix list
	cclose

	" replace quickfix with new data
	call setqflist(qflist, 'r')

	" save total number of errors
	let length = len(qflist)
	if length
		echo 'There are '.length.' errors found!'

		" open quickfix list if there is no bang
		if a:show
			belowright copen
		endif
	else
		echo 'No errors found!'
	endif

	return length
endfunction

" map quickfix shortcuts
function! s:Map()
	" switch to previous buffer
	execute "normal \<C-W>p"

	" save plugin loaded flag
	let g:jshint2_map = exists('b:jshint2_path')

	" switch back to quickfix list
	execute "normal \<C-W>p"

	" map commands if plugin loaded
	if g:jshint2_map
		" open error in new tab
		nnoremap <silent><buffer>t <C-W><CR><C-W>T:belowright copen<CR><C-W>p

		" open error in new split
		nnoremap <silent><buffer>s <C-W><CR><C-W>=

		" open error in new vertical split
		nnoremap <silent><buffer>v <C-W><CR><C-W>L

		" ignore selected error
		nnoremap <silent><buffer>i :call b:JSHintIgnore()<CR>

		" scroll to selected error
		nnoremap <silent><buffer>n <CR><C-W>p

		" close error list
		nnoremap <silent><buffer>q <C-W>p:cclose<CR>
	endif

	" remove loaded flag
	unlet g:jshint2_map
endfunction

" revalidate ignoring selected error
function! b:JSHintIgnore()
	" save error line
	let line = getqflist()[line('.') - 1]

	" save error number
	let error = '-'.line['type'].(('00'.line['nr'])[-3:])

	" switch to previous buffer
	execute "normal \<C-W>p"

	" revalidate buffer
	execute ':JSHint '.b:jshint2_flags.error
endfunction

" define command line function
command! -nargs=* -complete=customlist,s:Complete -range=% -bang -bar -buffer JSHint
	\ call s:Lint(<line1>, <line2>, <bang>1, <f-args>)

" define quickfix list mapper
autocmd! FileType qf
	\ call s:Map()
