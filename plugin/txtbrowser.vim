" txtbrowser.vim:	Utilities to browser plain text file.
" Release:		1.3.2
" Maintainer:		ypguo<guoyoooping@163.com>
" Last modified:	2010.07.09
" License:		GPL.

" ****************** Do not modify after this line ************************

" Line continuation used here
let s:cpo_save = &cpo
set cpo&vim

if exists("g:txtbrowser_version")
    finish "stop loading the script
endif
let g:txtbrowser_version = "1.3.2"

"=Options===========================================================
" User defined web dictionary
if !exists('TxtBrowser_Dict_Url')
    let TxtBrowser_Dict_Url = 'http://www.google.cn/dictionary?aq=f&langpair=en|zh-CN&q=text&hl=zh-CN'
endif

" User defined Search Engine.
if !exists('Txtbrowser_Search_Engine')
    let Txtbrowser_Search_Engine = 'http://www.google.com/search?hl=zh-CN&source=hp&q=text&btnG=Google+%E6%90%9C%E7%B4%A2&lr=&aq=f&oq='
endif

"===================================================================
"Default map:
if ("" == mapcheck("<Leader>s", "n"))
    nmap <script> <silent> <unique> <Leader>s <ESC>:TSearch <cword> <CR>
endif
if ("" == mapcheck("<Leader>s", "v"))
    vmap <script> <silent> <unique> <Leader>s y<ESC>:TSearch <c-r>" <CR>
endif
if ("" == mapcheck("<Leader>f", "n"))
    nmap <script> <silent> <unique> <Leader>f <ESC>:TFind <cword> <CR>
endif
if ("" == mapcheck("<Leader>f", "v"))
    vmap <script> <silent> <unique> <Leader>f y<ESC>:TFind <c-r>" <CR>
endif
if ("" == mapcheck("<Leader>g", "n"))
    nmap <script> <silent> <unique> <Leader>g <ESC>:TGoto <CR>
endif
if ("" == mapcheck("<Leader>g", "v"))
    vmap <script> <silent> <unique> <Leader>g y<ESC>:TGoto <c-r>" <CR>
endif
if ("" == mapcheck("<Leader>h", "n"))
    nmap <script> <silent> <unique> <Leader>h yaw<ESC>:TBHighlight @\" <CR>
endif
if ("" == mapcheck("<Leader>h", "v"))
    vmap <script> <silent> <unique> <Leader>h y<ESC>:TBHighlight @\" <CR>
endif
if ("" == mapcheck("*", "v"))
    vnoremap <silent> * y/<C-R>=substitute(escape(@", '.*\\/[]'), "\n", '\\n', 'g')<CR><CR>
endif
if ("" == mapcheck("?", "v"))
    vnoremap <silent> ? y?<C-R>=substitute(escape(@", '.*\\/[]'), "\n", '\\n', 'g')<CR><CR>
endif

"Define the user commands:
command! -nargs=? -bar TSearch call s:TxtBrowserSearch(<f-args>)
command! -nargs=? -bar TFind call s:TxtBrowserWord(<f-args>)
command! -nargs=? -bar TGoto call s:TxtbrowserGoto(<f-args>)
command! -nargs=1 -bar TBHighlight call s:TxtBrowserHighlight(<args>)

function! s:TxtBrowserHighlight (text)
	if a:text == ""
		echohl ErrorMsg | echo "No url found in the cursor."
		return -1
	endif
	let tmp = a:text
	let tmp = substitute(tmp, "\n", "\\\\n", 'g')
	let tmp = substitute(tmp, "/", "\\\\/", 'g')
	exec ':match MatchParen ' . '/' . tmp . '/'
endfunction

"===================================================================
" Function to parse and get the url in the line gvien.
" @line: input line that need to open.
" return: Url that prased, return "" if not found.
function! s:TxtbrowserGoto(...)
    if a:0 == 0
	let line = getline('.')
    else
	let line = a:1
    endif

    "let url = matchstr(getline("."), '[filehtp]*:\/\/[^>,;]*')
    let url = matchstr(line, "http:\/\/[^ (),:]*")
    if url==""
	let url = matchstr(line, "ftp:\/\/[^ ]*")
    endif
    if url==""
	let url = matchstr(line, "file:\/\/[^,;>]*")
    endif
    if url==""
	let url = matchstr(line, "mailto:[^ ]*")
    endif
    if url==""
	let url = matchstr(line, "www\.[^ (),:]*")
    endif
    if url==""
	let url = matchstr(line, "[^,:\> ]*@[^ ,:]*")
	if url!=""
	    let url = "mailto:" . url
	endif
    endif

    "parse local file
    if url==""
	"Get the <cfile>
	let url = expand("<cfile>:.")

	"If the <cfile> is not readable, let isfname += <SPACE> and have a
	"more try.
	if (!filereadable(url))
	    let old_isfname = &isfname
	    set isfname+=32
	    let url = expand("<cfile>:.")
	    " Restore the isfname option
	    let &isfname = old_isfname
	endif

	if (!filereadable(url))
	    let url = ""
	endif
    endif

    let url = escape (url, "\"#;%")
    if url == ""
	echohl ErrorMsg | echo "No url found in the cursor." | echohl Normal
	return -1
    else
	echo "Open url: " . url
    endif

    call s:TxtbrowserOpenUrl(url)

    return url
endfunction

" Function to open the url gvien.
" @url: url that need to open.
function! s:TxtbrowserOpenUrl (url)
    if a:url == ""
	echohl ErrorMsg | echo "No url found in the cursor."
	return -1
    endif

    if (has("mac"))
	exec "!open \"" . a:url . "\""
    elseif (has("win32") || has("win32unix"))
	exec ':silent !cmd /q /c start "\""dummy title"\"" ' . "\"" . a:url . "\""
    elseif (has("unix"))
	"exec ':silent !firefox ' . "\"" . a:url . "\" & "
	exec ":silent !xdg-open \"" . a:url . "\""
    endif
endfunction

" Function to open the url gvien.
" @url: url that need to open.
function! s:TxtBrowserWord (...) range
    if a:0 == 0
	let word = expand('<cword>')
    else
	let word = a:1
    endif

    if word == ""
	echohl ErrorMsg | echo "No text to lookup." | echohl Normal
	return -1
    else
	echo "Find word: " . word
    endif

    call s:TxtbrowserOpenUrl(substitute(g:TxtBrowser_Dict_Url, "text", word, "g"))
endfunction


" Function to open the url gvien.
" @url: url that need to open.
function! s:TxtBrowserSearch (...) range
    if a:0 == 0
	let word = expand('<cword>')
    else
	let word = a:1
    endif

    if word == ""
	echohl ErrorMsg | echo "No text to search." | echohl Normal
	return -1
    else
	echo "Searching: " . word
    endif

    call s:TxtbrowserOpenUrl(substitute(g:Txtbrowser_Search_Engine, "text", word, 'g'))
endfunction


" restore 'cpo'
let &cpo = s:cpo_save
unlet s:cpo_save

" vim:ft=vim sw=4
