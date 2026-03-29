" autoload/zero_grep/filetype/legacy.vim - Filetype-aware rg/git grep helpers (legacy Vimscript)
" Maintainer: Phong Nguyen
"
" Wraps word getters with rg -t / git grep -- glob filetype filtering.
" Filetype data and opts builders live in zero_grep#dumb_jump#legacy#.

" ============================================================================
" Private Helpers
" ============================================================================

function! s:rg_opts(keyword, ...) abort
    let l:ft       = get(a:, 1, '')
    let l:type_opts = zero_grep#dumb_jump#legacy#RgFileTypeArgs(l:ft)
    let l:pat      = shellescape(a:keyword)
    return empty(l:type_opts)
                \ ? l:pat
                \ : l:type_opts .. ' ' .. l:pat
endfunction

function! s:git_opts(keyword, ...) abort
    let l:ft        = get(a:, 1, '')
    let l:file_opts = zero_grep#dumb_jump#legacy#GitFileTypeArgs(l:ft)
    let l:pat       = shellescape(a:keyword)
    return empty(l:file_opts)
                \ ? l:pat
                \ : l:pat .. ' ' .. l:file_opts
endfunction

" ============================================================================
" Public API — rg
" ============================================================================

function! zero_grep#filetype#legacy#RgCCword(...) abort
    return s:rg_opts(zero_grep#legacy#CCword(), get(a:, 1, ''))
endfunction

function! zero_grep#filetype#legacy#RgCword(...) abort
    return s:rg_opts(zero_grep#legacy#Cword(), get(a:, 1, ''))
endfunction

function! zero_grep#filetype#legacy#RgWord(...) abort
    return s:rg_opts(zero_grep#legacy#Word(), get(a:, 1, ''))
endfunction

function! zero_grep#filetype#legacy#RgVword(...) abort
    return s:rg_opts(zero_grep#legacy#Vword(), get(a:, 1, ''))
endfunction

" ============================================================================
" Public API — git grep
" ============================================================================

function! zero_grep#filetype#legacy#GitCCword(...) abort
    return s:git_opts(zero_grep#legacy#CCword(), get(a:, 1, ''))
endfunction

function! zero_grep#filetype#legacy#GitCword(...) abort
    return s:git_opts(zero_grep#legacy#Cword(), get(a:, 1, ''))
endfunction

function! zero_grep#filetype#legacy#GitWord(...) abort
    return s:git_opts(zero_grep#legacy#Word(), get(a:, 1, ''))
endfunction

function! zero_grep#filetype#legacy#GitVword(...) abort
    return s:git_opts(zero_grep#legacy#Vword(), get(a:, 1, ''))
endfunction
