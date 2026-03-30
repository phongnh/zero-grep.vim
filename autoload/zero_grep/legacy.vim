" autoload/zero_grep/legacy.vim - Core word getters and context-aware dispatch (legacy Vimscript)
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

function! zero_grep#legacy#CCword() abort
    return '\b' . expand('<cword>') . '\b'
endfunction

function! zero_grep#legacy#Cword() abort
    return expand('<cword>')
endfunction

function! zero_grep#legacy#Word() abort
    return expand('<cWORD>')
endfunction

function! zero_grep#legacy#Vword() range abort
    let l:saved = @"
    silent execute 'normal! ""gvy'
    let l:selection = @"
    let @" = l:saved
    return l:selection ==# "\n" ? '' : l:selection
endfunction

function! zero_grep#legacy#Pword() abort
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

function! zero_grep#legacy#GrepEscape(text) abort
    return s:grep_escape(a:text)
endfunction

function! zero_grep#legacy#GrepCCword() abort
    return s:grep_escape(zero_grep#legacy#CCword())
endfunction

function! zero_grep#legacy#GrepCword() abort
    return s:grep_escape(zero_grep#legacy#Cword())
endfunction

function! zero_grep#legacy#GrepWord() abort
    return s:grep_escape(zero_grep#legacy#Word())
endfunction

function! zero_grep#legacy#GrepVword() range abort
    return s:grep_escape(zero_grep#legacy#Vword())
endfunction

function! zero_grep#legacy#GrepPword() abort
    return s:grep_escape(zero_grep#legacy#Pword())
endfunction

" --- substitute ---

function! zero_grep#legacy#SubstituteEscape(text) abort
    return s:substitute_escape(a:text)
endfunction

function! zero_grep#legacy#SubstituteCCword() abort
    return '\<' . zero_grep#legacy#Cword() . '\>'
endfunction

function! zero_grep#legacy#SubstituteCword() abort
    return zero_grep#legacy#Cword()
endfunction

function! zero_grep#legacy#SubstituteWord() abort
    return s:substitute_escape(zero_grep#legacy#Word())
endfunction

function! zero_grep#legacy#SubstituteVword(...) range abort
    let l:whole_word = get(a:, 1, 0)
    let l:t = s:substitute_escape(zero_grep#legacy#Vword())
    return l:whole_word ? '\<' . l:t . '\>' : l:t
endfunction

function! zero_grep#legacy#SubstitutePword() abort
    return s:substitute_escape(zero_grep#legacy#Pword())
endfunction

" --- shell ---

function! zero_grep#legacy#ShellEscape(text) abort
    return s:shell_escape(a:text)
endfunction

function! zero_grep#legacy#ShellCCword() abort
    return shellescape(zero_grep#legacy#CCword())
endfunction

function! zero_grep#legacy#ShellCword() abort
    return shellescape(zero_grep#legacy#Cword())
endfunction

function! zero_grep#legacy#ShellWord() abort
    return s:shell_escape(zero_grep#legacy#Word())
endfunction

function! zero_grep#legacy#ShellVword() range abort
    return s:shell_escape(s:trim(zero_grep#legacy#Vword()))
endfunction

function! zero_grep#legacy#ShellPword() abort
    return s:shell_escape(s:trim(zero_grep#legacy#Pword()))
endfunction

" --- leaderf ---
" LeaderF uses its own regex engine; escape chars include '"' in addition to
" the shell set. CCword and Cword are passed as plain shellescape (no regex
" boundaries) because LeaderF handles word matching internally.

function! zero_grep#legacy#LeaderfEscape(text) abort
    return s:leaderf_escape(a:text)
endfunction

function! zero_grep#legacy#LeaderfCCword() abort
    return shellescape(zero_grep#legacy#CCword())
endfunction

function! zero_grep#legacy#LeaderfCword() abort
    return shellescape(zero_grep#legacy#Cword())
endfunction

function! zero_grep#legacy#LeaderfWord() abort
    return s:leaderf_escape(zero_grep#legacy#Word())
endfunction

function! zero_grep#legacy#LeaderfVword() range abort
    return s:leaderf_escape(s:trim(zero_grep#legacy#Vword()))
endfunction

function! zero_grep#legacy#LeaderfPword() abort
    return s:leaderf_escape(s:trim(zero_grep#legacy#Pword()))
endfunction

" ============================================================================
" Context-Aware Insert Functions (for <C-R>= mappings)
" ============================================================================

function! zero_grep#legacy#InsertCCword() abort
    let l:cmd = getcmdline()
    if s:is_substitute_command(l:cmd)
        return zero_grep#legacy#SubstituteCCword()
    elseif s:is_grepper_git_command(l:cmd)
        return zero_grep#dumb_jump#legacy#GitCword()
    elseif s:is_grepper_command(l:cmd)
        return zero_grep#dumb_jump#legacy#RgCword()
    elseif s:is_grep_command(l:cmd)
        return zero_grep#legacy#GrepCCword()
    elseif s:is_leaderf_command(l:cmd)
        return zero_grep#legacy#LeaderfCCword()
    else
        return zero_grep#legacy#ShellCCword()
    endif
endfunction

function! zero_grep#legacy#InsertCword() abort
    let l:cmd = getcmdline()
    if s:is_substitute_command(l:cmd)
        return zero_grep#legacy#SubstituteCword()
    elseif s:is_grepper_git_command(l:cmd)
        return zero_grep#dumb_jump#legacy#GitCword()
    elseif s:is_grepper_command(l:cmd)
        return zero_grep#dumb_jump#legacy#RgCword()
    elseif s:is_grep_command(l:cmd)
        return zero_grep#legacy#GrepCCword()
    elseif s:is_leaderf_command(l:cmd)
        return zero_grep#legacy#LeaderfCword()
    elseif s:is_input_command()
        return zero_grep#legacy#ShellCword()
    else
        return zero_grep#legacy#Cword()
    endif
endfunction

function! zero_grep#legacy#InsertWord() abort
    let l:cmd = getcmdline()
    if s:is_substitute_command(l:cmd)
        return zero_grep#legacy#SubstituteWord()
    elseif s:is_grepper_git_command(l:cmd) || s:is_grepper_command(l:cmd)
        return zero_grep#dumb_jump#legacy#RgCword()
    elseif s:is_grep_command(l:cmd)
        return zero_grep#legacy#GrepWord()
    elseif s:is_leaderf_command(l:cmd)
        return zero_grep#legacy#LeaderfWord()
    else
        return zero_grep#legacy#ShellWord()
    endif
endfunction

function! zero_grep#legacy#InsertVword() abort
    let l:cmd = getcmdline()
    if s:is_substitute_command(l:cmd)
        return zero_grep#legacy#SubstituteVword()
    elseif s:is_grep_command(l:cmd)
        return zero_grep#legacy#GrepVword()
    elseif s:is_leaderf_command(l:cmd)
        return zero_grep#legacy#LeaderfVword()
    elseif s:is_input_command()
        return zero_grep#legacy#ShellVword()
    else
        return zero_grep#legacy#Vword()
    endif
endfunction

function! zero_grep#legacy#InsertPword() abort
    let l:cmd = getcmdline()
    if s:is_substitute_command(l:cmd)
        return zero_grep#legacy#SubstitutePword()
    elseif s:is_grep_command(l:cmd)
        return zero_grep#legacy#GrepPword()
    elseif s:is_leaderf_command(l:cmd)
        return zero_grep#legacy#LeaderfPword()
    else
        return zero_grep#legacy#ShellPword()
    endif
endfunction

