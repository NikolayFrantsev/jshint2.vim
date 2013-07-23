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

" save completion dictionary
execute 'let s:completion = '.substitute(system('cat '.shellescape(b:jshint2_path.'completion.json')), '\n', '', 'g')

" command completion
function! s:Complete(arg, cmd, ...)
	" find colon in current argument
	let l:colon = stridx(a:arg, ':')

	" check if we have flag
	if l:colon == -1
		" save typed flags
		let l:flags = map(filter(split(a:cmd, '\s\+'), 'stridx(v:val, ":") > -1'), 'v:val[: stridx(v:val, ":") - 1]')

		" filter complete flags
		return filter(keys(s:completion), 'index(l:flags, v:val) == -1 && v:val =~ "^".a:arg[: -1]')
	endif

	" save flag and value
	let l:flag = a:arg[: l:colon - 1]
	let l:value = a:arg[l:colon + 1 :]

	" filter complete flag values
	return has_key(s:completion, l:flag) ?
		\ sort(map(filter(copy(s:completion[l:flag]), 'v:val =~ "^".l:value'), 'l:flag.":".v:val')) : []
endfunction

" save shell command
let s:command = 'jshint'

" save shell command arguments
let s:arguments = ' --reporter='.shellescape(b:jshint2_path.'reporter.js').' /dev/stdin'

" save config file name
let s:config = '.jshintrc'

" lint command constructor
function! s:LintCommand()
	" current file path
	let l:path = expand('%:p:h')

	" try to find config file
	while l:path != '/' && !filereadable(l:path.'/'.s:config)
		let l:path = fnamemodify(l:path, ':h')
	endwhile

	" save config argument
	let l:config = filereadable(l:path.'/'.s:config) ? ' --config='.shellescape(l:path.'/'.s:config) : ''

	" return full shell command
	return s:command.l:config.s:arguments
endfunction

" save buffer number
let b:jshint2_buffer = bufnr('%')

" lint buffer
function! s:Lint(start, stop, show, ...)
	" check if shell binary installed
	if !executable(s:command)
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

	" run shell linting command
	let l:report = system(s:LintCommand(), join(l:content, "\n"))

	" check for shell errors
	if v:shell_error
		echohl ErrorMsg
		echo 'Error while executing JSHint!'
		echohl None

		return -1
	endif

	" convert shell output into quickfix dictionary
	let l:qflist = map(map(split(l:report, "\n"), 'split(v:val, "\t")'),
		\ '{"bufnr": '.b:jshint2_buffer.', "lnum": str2nr(v:val[0] + a:start), "col": str2nr(v:val[1]),
			\ "type": v:val[2], "nr": str2nr(v:val[3]), "text": v:val[4]}')

	" close old quickfix list
	cclose

	" replace quickfix with new data
	call setqflist(l:qflist, 'r')

	" save total number of errors
	let l:length = len(l:qflist)
	if l:length
		echo 'There are '.l:length.' errors found!'

		" open quickfix list if there is no bang
		if a:show
			belowright copen
		endif
	else
		echo 'No errors found!'
	endif

	return l:length
endfunction

" define quickfix shortcuts
function! s:Map()
	" switch to previous buffer
	execute "normal! \<C-W>p"

	" save plugin loaded flag
	let g:jshint2_map = exists('b:jshint2_path')

	" switch back to quickfix list
	execute "normal! \<C-W>p"

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

" ignore selected error
function! b:JSHintIgnore()
	" save error line
	let l:line = getqflist()[line('.') - 1]

	" save error number
	let l:error = '-'.l:line['type'].(('00'.l:line['nr'])[-3:])

	" switch to previous buffer
	execute "normal! \<C-W>p"

	" revalidate buffer
	execute ':JSHint '.b:jshint2_flags.l:error
endfunction

" define command function
command! -nargs=* -complete=customlist,s:Complete -range=% -bang -bar -buffer JSHint
	\ call s:Lint(<line1>, <line2>, <bang>1, <f-args>)

" define quickfix list mapper
autocmd! FileType qf
	\ call s:Map()
