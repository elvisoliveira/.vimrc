" Author: Elvis Oliveira - http://github.com/elvisoliveira "
" vim: syntax=vim
set nocompatible
source ~/.vimrc
source ~/.vimrc.ide

function! s:StartJavaDebugging()
	if s:jdt_ls_debugger_port <= 0
		" Get the DAP port
		let s:jdt_ls_debugger_port = youcompleteme#GetCommandResponse('ExecuteCommand', 'vscode.java.startDebugSession')
		if s:jdt_ls_debugger_port == ''
			echom "Unable to get DAP port - is JDT.LS initialized?"
			let s:jdt_ls_debugger_port = 0
			return
		else
			echom "Assigned port is: " . s:jdt_ls_debugger_port
			let $DEBUGGER = s:jdt_ls_debugger_port
		endif
	endif
	" Start debugging with the DAP port
	call vimspector#LaunchWithSettings({'DAPPort': s:jdt_ls_debugger_port})
endfunction

function! ToggleBreakpoint()
	let alreadyHasBreakpoint1 = len(sign_getplaced(bufnr(), #{group:'VimspectorBP', lnum: line(".")})[0].signs) > 0
	let alreadyHasBreakpoint2 = len(sign_getplaced(bufnr(), #{group:'VimspectorCode', lnum: line(".")})[0].signs) > 0
	if alreadyHasBreakpoint1 || alreadyHasBreakpoint2
		call vimspector#ToggleBreakpoint()
	else
		let condition = input('condition:')
		if condition == ''
			call vimspector#ToggleBreakpoint()
		else
			call vimspector#ToggleBreakpoint({'condition': condition})
		endif
		redraw
	endif
endfunction

" YCM
let g:ycm_auto_hover = -1
let g:ycm_key_list_select_completion = ['<TAB>']
let g:ycm_key_list_previous_completion = ['<Up>']
let g:ycm_key_list_next_completion = ['<Down>']
let g:ycm_java_jdtls_extension_path = ['/home/elvisoliveira/.vim/bundle/vimspector/gadgets/linux']
" For now, only on Java [Eclipse] projects
let g:ycm_filetype_whitelist = { 'java': 1, 'VimspectorPrompt': 1 }
let g:ycm_semantic_triggers =  { 'VimspectorPrompt': [ '.', '->', ':', '<' ] }

" YCM + Vimspector
" To check the state of the debugger, use :YcmDebugInfo
nmap <C-a>1 :YcmCompleter GoTo<CR>
nmap <C-a>2 :YcmShowDetailedDiagnostic<CR>
nmap <C-a>3 :YcmForceCompileAndDiagnostics<CR>
nmap <C-a>4 :YcmCompleter GoToReferences<CR>
nmap <C-a>5 :YcmCompleter OrganizeImports<CR>
nmap <C-a>6 :YcmCompleter FixIt<CR>

" eclipse.jdt.ls
let s:jdt_ls_debugger_port = 0

" Leader + S = Vim[S]pector
nmap <C-s>j :call <SID>StartJavaDebugging()<CR>
nmap <C-s>c :call vimspector#Continue()<CR>
nmap <C-s>s :call vimspector#Stop()<CR>
nmap <C-s>b :call ToggleBreakpoint()<CR>
nmap <C-s>r :call vimspector#Reset()<CR>
nmap <C-s> <Right> :call vimspector#StepOver()<CR>
nmap <C-s> <Down> :call vimspector#StepInto()<CR>
nmap <C-s> <Up> :call vimspector#StepOut()<CR>
xmap <C-s>i <Plug>VimspectorBalloonEval

let g:vimspector_sign_priority = {
\    'vimspectorBP':         999,
\    'vimspectorPC':         999,
\    'vimspectorBPCond':     999,
\    'vimspectorBPDisabled': 999,
\ }
