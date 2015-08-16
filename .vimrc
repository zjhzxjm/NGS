set encoding=utf-8
set fencs=utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936
set fileencodings=utf-8,ucs-bom,chinese
set fdm=indent
set langmenu=zh_CN.UTF-8

set showmatch

set expandtab
set tabstop=2
set shiftwidth=2
set autoindent
set smartindent
set tags="/home/xujm/tags"

if has("autocmd")
	"Drupal *.module and *.install files.
	augroup module
		autocmd BufRead,BufNewFile *.module set filetype=php
		autocmd BufRead,BufNewFile *.install set filetype=php
		autocmd BufRead,BufNewFile *.test set filetype=php
		autocmd BufRead,BufNewFile *.inc set filetype=php
		autocmd BufRead,BufNewFile *.profile set filetype=php
		autocmd BufRead,BufNewFile *.view set filetype=php
	augroup END
endif
syntax on

autocmd FileType php set omnifunc=phpcomplete#CompletePHP

" Highlight redundant whitespaces and tabs.
highlight RedundantSpaces ctermbg=red guibg=red
match RedundantSpaces /\s\+$\| \+\ze\t\|\t/
