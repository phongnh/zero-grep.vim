" autoload/zero_grep.vim - Core word getters and context-aware dispatch
" Maintainer: Phong Nguyen

" ============================================================================
" Escape Characters per Context
" ============================================================================

let s:grep_escape_chars      = '^$.*+?()[]{}|-'
let s:substitute_escape_chars = '^$.*\/~[]'
let s:shell_escape_chars     = '\^$.*+?()[]{}|-'
let s:leaderf_escape_chars   = '\^$.*+?()[]{}|-"'

" ============================================================================
" Trim
" ============================================================================

function! s:trim(str) abort
    if exists('*trim')
        return trim(a:str)
    endif
    return substitute(a:str, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

" ============================================================================
" Raw Word Getters
" ============================================================================

function! zero_grep#CCword() abort
    return '\b' . expand('<cword>') . '\b'
endfunction

function! zero_grep#Cword() abort
    return expand('<cword>')
endfunction

function! zero_grep#Word() abort
    return expand('<cWORD>')
endfunction

function! zero_grep#Vword() range abort
    if exists('*getregion')
        return trim(join(call('getregion', [getpos("'<"), getpos("'>")])->slice(0, 1), "\n"))
    endif
    let l:line = getline("'<")
    let [_b1, l:l1, l:c1, _o1] = getpos("'<")
    let [_b2, l:l2, l:c2, _o2] = getpos("'>")
    if l:l1 != l:l2
        return trim(strpart(l:line, l:c1 - 1))
    endif
    return trim(strpart(l:line, l:c1 - 1, l:c2 - l:c1 + 1))
endfunction

function! zero_grep#Pword() abort
    let l:search = @/
    if empty(l:search) || l:search ==# "\n"
        return ''
    endif
    return substitute(l:search, '^\\<\(.\+\)\\>$', '\\b\1\\b', '')
endfunction

" ============================================================================
" Escape Helpers
" ============================================================================

function! s:grep_escape(text) abort
    let l:t = substitute(a:text, '#', '\\\\#', 'g')
    let l:t = escape(l:t, s:grep_escape_chars)
    return shellescape(l:t)
endfunction

function! s:substitute_escape(text) abort
    let l:t = escape(a:text, s:substitute_escape_chars)
    return substitute(l:t, '\n', '\\n', 'g')
endfunction

function! s:shell_escape(text) abort
    return shellescape(escape(a:text, s:shell_escape_chars))
endfunction

function! s:leaderf_escape(text) abort
    return shellescape(escape(a:text, s:leaderf_escape_chars))
endfunction

" ============================================================================
" Context Detection
" ============================================================================

function! s:is_substitute_command(cmd) abort
    return a:cmd =~# '^%\?\(s\|substitute\|S\|Subvert\)/' ||
                \ a:cmd =~# '^\(silent!\?\s\+\)\?\(c\|l\)\(fdo\|do\)\s\+\(s\|substitute\|S\|Subvert\)/'
endfunction

function! s:is_grep_command(cmd) abort
    return a:cmd =~# '^\(Grep\|LGrep\|BGrep\|grep\|lgrep\)\s' ||
                \ a:cmd =~# '^\(Ggrep!\?\|Gcgrep!\?\|Glgrep!\?\)\s' ||
                \ a:cmd =~# '^\(Git!\?\s\+grep\)\s'
endfunction

function! s:is_grepper_git_command(cmd) abort
    return a:cmd =~# '^\(GrepperGit\)\s'
endfunction

function! s:is_grepper_command(cmd) abort
    return a:cmd =~# '^\(Grepper\|SGrepper\|LGrepper\|PGrepper\|TGrepper\|GrepperRg\)\s'
endfunction

function! s:is_leaderf_command(cmd) abort
    return a:cmd =~# '^\(Leaderf\|LF\)\s'
endfunction

function! s:is_input_command() abort
    return getcmdtype() ==# '@'
endfunction

" ============================================================================
" Context-Namespaced Escape Functions
" ============================================================================

" --- grep ---

function! zero_grep#GrepEscape(text) abort
    return s:grep_escape(a:text)
endfunction

function! zero_grep#GrepCCword() abort
    return s:grep_escape(zero_grep#CCword())
endfunction

function! zero_grep#GrepCword() abort
    return s:grep_escape(zero_grep#Cword())
endfunction

function! zero_grep#GrepWord() abort
    return s:grep_escape(zero_grep#Word())
endfunction

function! zero_grep#GrepVword() range abort
    return s:grep_escape(zero_grep#Vword())
endfunction

function! zero_grep#GrepPword() abort
    return s:grep_escape(zero_grep#Pword())
endfunction

" --- substitute ---

function! zero_grep#SubstituteEscape(text) abort
    return s:substitute_escape(a:text)
endfunction

function! zero_grep#SubstituteCCword() abort
    return '\<' . zero_grep#Cword() . '\>'
endfunction

function! zero_grep#SubstituteCword() abort
    return zero_grep#Cword()
endfunction

function! zero_grep#SubstituteWord() abort
    return s:substitute_escape(zero_grep#Word())
endfunction

function! zero_grep#SubstituteVword(...) range abort
    let l:whole_word = get(a:, 1, 0)
    let l:t = s:substitute_escape(zero_grep#Vword())
    return l:whole_word ? '\<' . l:t . '\>' : l:t
endfunction

function! zero_grep#SubstitutePword() abort
    return s:substitute_escape(zero_grep#Pword())
endfunction

" --- shell ---

function! zero_grep#ShellEscape(text) abort
    return s:shell_escape(a:text)
endfunction

function! zero_grep#ShellCCword() abort
    return shellescape(zero_grep#CCword())
endfunction

function! zero_grep#ShellCword() abort
    return shellescape(zero_grep#Cword())
endfunction

function! zero_grep#ShellWord() abort
    return s:shell_escape(zero_grep#Word())
endfunction

function! zero_grep#ShellVword() range abort
    return s:shell_escape(s:trim(zero_grep#Vword()))
endfunction

function! zero_grep#ShellPword() abort
    return s:shell_escape(s:trim(zero_grep#Pword()))
endfunction

" --- leaderf ---
" LeaderF uses its own regex engine; escape chars include '"' in addition to
" the shell set. CCword and Cword are passed as plain shellescape (no regex
" boundaries) because LeaderF handles word matching internally.

function! zero_grep#LeaderfEscape(text) abort
    return s:leaderf_escape(a:text)
endfunction

function! zero_grep#LeaderfCCword() abort
    return shellescape(zero_grep#CCword())
endfunction

function! zero_grep#LeaderfCword() abort
    return shellescape(zero_grep#Cword())
endfunction

function! zero_grep#LeaderfWord() abort
    return s:leaderf_escape(zero_grep#Word())
endfunction

function! zero_grep#LeaderfVword() range abort
    return s:leaderf_escape(s:trim(zero_grep#Vword()))
endfunction

function! zero_grep#LeaderfPword() abort
    return s:leaderf_escape(s:trim(zero_grep#Pword()))
endfunction

" ============================================================================
" Context-Aware Insert Functions (for <C-R>= mappings)
" ============================================================================

function! zero_grep#InsertCCword() abort
    let l:cmd = getcmdline()
    if s:is_substitute_command(l:cmd)
        return zero_grep#SubstituteCCword()
    elseif s:is_grepper_git_command(l:cmd)
        return zero_grep#dumb_jump#GitCword()
    elseif s:is_grepper_command(l:cmd)
        return zero_grep#dumb_jump#RgCword()
    elseif s:is_grep_command(l:cmd)
        return zero_grep#GrepCCword()
    elseif s:is_leaderf_command(l:cmd)
        return zero_grep#LeaderfCCword()
    else
        return zero_grep#ShellCCword()
    endif
endfunction

function! zero_grep#InsertCword() abort
    let l:cmd = getcmdline()
    if s:is_substitute_command(l:cmd)
        return zero_grep#SubstituteCword()
    elseif s:is_grepper_git_command(l:cmd)
        return zero_grep#dumb_jump#GitCword()
    elseif s:is_grepper_command(l:cmd)
        return zero_grep#dumb_jump#RgCword()
    elseif s:is_grep_command(l:cmd)
        return zero_grep#GrepCCword()
    elseif s:is_leaderf_command(l:cmd)
        return zero_grep#LeaderfCword()
    elseif s:is_input_command()
        return zero_grep#ShellCword()
    else
        return zero_grep#Cword()
    endif
endfunction

function! zero_grep#InsertWord() abort
    let l:cmd = getcmdline()
    if s:is_substitute_command(l:cmd)
        return zero_grep#SubstituteWord()
    elseif s:is_grepper_git_command(l:cmd) || s:is_grepper_command(l:cmd)
        return zero_grep#dumb_jump#RgCword()
    elseif s:is_grep_command(l:cmd)
        return zero_grep#GrepWord()
    elseif s:is_leaderf_command(l:cmd)
        return zero_grep#LeaderfWord()
    else
        return zero_grep#ShellWord()
    endif
endfunction

function! zero_grep#InsertVword() abort
    let l:cmd = getcmdline()
    if s:is_substitute_command(l:cmd)
        return zero_grep#SubstituteVword()
    elseif s:is_grep_command(l:cmd)
        return zero_grep#GrepVword()
    elseif s:is_leaderf_command(l:cmd)
        return zero_grep#LeaderfVword()
    elseif s:is_input_command()
        return zero_grep#ShellVword()
    else
        return zero_grep#Vword()
    endif
endfunction

function! zero_grep#InsertPword() abort
    let l:cmd = getcmdline()
    if s:is_substitute_command(l:cmd)
        return zero_grep#SubstitutePword()
    elseif s:is_grep_command(l:cmd)
        return zero_grep#GrepPword()
    elseif s:is_leaderf_command(l:cmd)
        return zero_grep#LeaderfPword()
    else
        return zero_grep#ShellPword()
    endif
endfunction

