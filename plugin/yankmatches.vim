" Vim global plugin for yanking or deleting all lines with a match
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

if exists('loaded_delete_matches')
    finish
endif
let g:loaded_delete_matches = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpoptions
set cpoptions&vim


" Originally just:
"       nmap <silent> dm  :g//delete<CR>
" But that doesn't retain all deletes in the nameless register
"
" Then:
"       nmap <silent> dm  :let @a = ""<CR>:g//delete A<CR>
" But that doesn't seem to work :-(
" So:


"====[ Interface ]====================================================
"
" Example mappings
"
" I will set what I want explicitly in my vimrc
" nmap <silent> dm  :     call ForAllMatches('delete', {})<CR>
" nmap <silent> DM  :     call ForAllMatches('delete', {'inverse':1})<CR>
" nmap <silent> YM  :     call ForAllMatches('yank',   {})<CR>
" nmap <silent> YI  :     call ForAllMatches('yank',   {'inverse':1})<CR>
" vmap <silent> dm  :<C-U>call ForAllMatches('delete', {'visual':1})<CR>
" vmap <silent> DM  :<C-U>call ForAllMatches('delete', {'visual':1, 'inverse':1})<CR>
" vmap <silent> YM  :<C-U>call ForAllMatches('yank',   {'visual':1})<CR>
" vmap <silent> YI  :<C-U>call ForAllMatches('yank',   {'visual':1, 'inverse':1})<CR>

function! ForAllMatches (command, options)
    " Remember where we parked...
    let l:orig_pos = getpos('.')

    " Work out the implied range of lines to consider...
    let l:in_visual = get(a:options, 'visual', 0)
    let l:start_line = l:in_visual ? getpos("'<'")[1] : 1
    let l:end_line   = l:in_visual ? getpos("'>'")[1] : line('$')

    " Are we inverting the selection???
    let l:inverted = get(a:options, 'inverse', 0)

    " Are we modifying the buffer???
    let l:deleting = a:command ==? 'delete'

    " Honour smartcase (which :lvimgrep doesn't, by default)
    let l:sensitive = &ignorecase && &smartcase && @/ =~# '\u' ? '\C' : ''

    " Identify the lines to be operated on...
    exec 'silent lvimgrep /' . l:sensitive . @/ . '/j %'
    let l:matched_line_nums
    \ = reverse(filter(map(getloclist(0), 'v:val.lnum'), 'l:start_line <= v:val && v:val <= l:end_line'))

    " Invert the list of lines, if requested...
    if l:inverted
        let l:inverted_line_nums = range(l:start_line, l:end_line)
        for l:line_num in l:matched_line_nums
            call remove(l:inverted_line_nums, l:line_num-l:start_line)
        endfor
        let l:matched_line_nums = reverse(l:inverted_line_nums)
    endif

    " Filter the original lines...
    let l:yanked = ''
    for l:line_num in l:matched_line_nums
        " Remember yanks or deletions...
        let l:yanked = getline(l:line_num) . "\n" . l:yanked

        " Delete buffer lines if necessary...
        if l:deleting
            exec l:line_num . 'delete'
        endif
    endfor

    " Make yanked lines available for putting...
    " First however, check if the user has configured the option to change the
    " register that the information is yanked or deleted to. If no such
    " configuration exists, then check the clipboard setting.
    if !exists('g:YankMatches#ClipboardRegister')
        let l:clipboard_flags = split(&clipboard, ',')
        if index(l:clipboard_flags, 'unnamedplus') >= 0
            let g:YankMatches#ClipboardRegister='+'
        elseif index(l:clipboard_flags, 'unnamed') >= 0
            let g:YankMatches#ClipboardRegister='*'
        else
            let g:YankMatches#ClipboardRegister='"'
        endif
    endif
    let l:command = ':let @' . g:YankMatches#ClipboardRegister . ' = yanked'
    execute 'normal! ' . l:command . "\<cr>"

    " Return to original position...
    call setpos('.', l:orig_pos)

    " Report results...
    redraw
    let l:match_count = len(l:matched_line_nums)
    if l:match_count == 0
        unsilent echo 'Nothing to ' . a:command . ' (no matches found)'
    elseif l:deleting
        unsilent echo l:match_count . (l:match_count > 1 ? ' fewer lines' : ' less line')
    else
        unsilent echo l:match_count . ' line' . (l:match_count > 1 ? 's' : '') . ' yanked'
    endif
endfunction
