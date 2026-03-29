" autoload/zero_grep/dumb_jump/legacy.vim - Dumb Jump definitions (legacy Vimscript)
" Maintainer: Phong Nguyen
"
" Language regular expressions ported from:
" https://github.com/jacktasia/dumb-jump/blob/master/dumb-jump.el

let s:placeholder = 'KEYWORD'

let s:definitions = {
            \ 'c': [
            \   '\bKEYWORD(\s|\))*\((\w|[,&*.<>:]|\s)*(\))\s*(const|->|\{|$)|typedef\s+(\w|[(*]|\s)+KEYWORD(\)|\s)*\(',
            \   '\b(?!(class\b|struct\b|return\b|else\b|delete\b))(\w+|[,>])([*&]|\s)+KEYWORD\s*(\[(\d|\s)*\])*\s*([=,(){;]|:\s*\d)|#define\s+KEYWORD\b',
            \   '\b(class|struct|enum|union)\b\s*KEYWORD\b\s*(final\s*)?(:((\s*\w+\s*::)*\s*\w*\s*<?(\s*\w+\s*::)*\w+>?\s*,*)+)?((\{|$))|}\s*KEYWORD\b\s*;',
            \ ],
            \ 'cpp': [
            \   '\bKEYWORD(\s|\))*\((\w|[,&*.<>:]|\s)*(\))\s*(const|->|\{|$)|typedef\s+(\w|[(*]|\s)+KEYWORD(\)|\s)*\(',
            \   '\b(?!(class\b|struct\b|return\b|else\b|delete\b))(\w+|[,>])([*&]|\s)+KEYWORD\s*(\[(\d|\s)*\])*\s*([=,(){;]|:\s*\d)|#define\s+KEYWORD\b',
            \   '\b(class|struct|enum|union)\b\s*KEYWORD\b\s*(final\s*)?(:((\s*\w+\s*::)*\s*\w*\s*<?(\s*\w+\s*::)*\w+>?\s*,*)+)?((\{|$))|}\s*KEYWORD\b\s*;',
            \ ],
            \ 'python': [
            \   '\s*\bKEYWORD\b(\s*:[^=\n]+)?\s*=[^=\n]+',
            \   '\s*\bKEYWORD\b(\s*:[^=]+)?\s*=[^=]+',
            \   'def\s*KEYWORD\b\s*\(',
            \   'class\s*KEYWORD\b\s*\(?',
            \ ],
            \ 'ruby': [
            \   '^\s*((\w+[.])*\w+,\s*)*KEYWORD(,\s*(\w+[.])*\w+)*\s*=([^=>~]|$)',
            \   '(^|[^\w.])((private|public|protected)\s+)?def\s+(\w+(::|[.]))*KEYWORD($|[^\w|:])',
            \   '(^|\W)define(_singleton|_instance)?_method(\s|[(])\s*:KEYWORD($|[^\w|:])',
            \   '(^|[^\w.])class\s+(\w*::)*KEYWORD($|[^\w|:])',
            \   '(^|[^\w.])module\s+(\w*::)*KEYWORD($|[^\w|:])',
            \   '(^|\W)alias(_method)?\W+KEYWORD(\W|$)',
            \ ],
            \ 'crystal': [
            \   '^\s*((\w+[.])*\w+,\s*)*KEYWORD(,\s*(\w+[.])*\w+)*\s*=([^=>~]|$)',
            \   '(^|[^\w.])((private|public|protected)\s+)?def\s+(\w+(::|[.]))*KEYWORD($|[^\w|:])',
            \   '(^|[^\w.])class\s+(\w*::)*KEYWORD($|[^\w|:])',
            \   '(^|[^\w.])module\s+(\w*::)*KEYWORD($|[^\w|:])',
            \   '(^|[^\w.])struct\s+(\w*::)*KEYWORD($|[^\w|:])',
            \   '(^|[^\w.])alias\s+(\w*::)*KEYWORD($|[^\w|:])',
            \ ],
            \ 'shell': [
            \   'function\s*KEYWORD\s*',
            \   'KEYWORD\(\)\s*\{',
            \   '\bKEYWORD\s*=\s*',
            \ ],
            \ 'sh': [
            \   'function\s*KEYWORD\s*',
            \   'KEYWORD\(\)\s*\{',
            \   '\bKEYWORD\s*=\s*',
            \ ],
            \ 'bash': [
            \   'function\s*KEYWORD\s*',
            \   'KEYWORD\(\)\s*\{',
            \   '\bKEYWORD\s*=\s*',
            \ ],
            \ 'zsh': [
            \   'function\s*KEYWORD\s*',
            \   'KEYWORD\(\)\s*\{',
            \   '\bKEYWORD\s*=\s*',
            \ ],
            \ 'dart': [
            \   '\bKEYWORD\s*\([^()]*\)\s*[{]',
            \   'class\s*KEYWORD\s*[\(\{]',
            \ ],
            \ 'fennel': [
            \   '\((local|var)\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
            \   '\(fn\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
            \   '\(macro\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
            \ ],
            \ 'go': [
            \   '\s*\bKEYWORD\s*=[^=\n]+',
            \   '\s*\bKEYWORD\s*:=\s*',
            \   'func\s+\([^\)]*\)\s+KEYWORD\s*\(',
            \   'func\s+KEYWORD\s*\(',
            \   'type\s+KEYWORD\s+struct\s+\{',
            \ ],
            \ 'javascript': [
            \   "(service|factory)\\(['\"]KEYWORD['\"]",
            \   '\bKEYWORD\s*[=:]\s*\([^\)]*\)\s+=>',
            \   '\bKEYWORD\s*\([^()]*\)\s*[{]',
            \   'class\s*KEYWORD\s*[\(\{]',
            \   'class\s*KEYWORD\s+extends',
            \   '\s*\bKEYWORD\s*=[^=\n]+',
            \   '\bfunction\b[^\(]*\(\s*[^\)]*\bKEYWORD\b\s*,?\s*\)?',
            \   'function\s*KEYWORD\s*\(',
            \   '\bKEYWORD\s*:\s*function\s*\(',
            \   '\bKEYWORD\s*=\s*function\s*\(',
            \ ],
            \ 'javascriptreact': [
            \   "(service|factory)\\(['\"]KEYWORD['\"]",
            \   '\bKEYWORD\s*[=:]\s*\([^\)]*\)\s+=>',
            \   '\bKEYWORD\s*\([^()]*\)\s*[{]',
            \   'class\s*KEYWORD\s*[\(\{]',
            \   'class\s*KEYWORD\s+extends',
            \   '\s*\bKEYWORD\s*=[^=\n]+',
            \   '\bfunction\b[^\(]*\(\s*[^\)]*\bKEYWORD\b\s*,?\s*\)?',
            \   'function\s*KEYWORD\s*\(',
            \   '\bKEYWORD\s*:\s*function\s*\(',
            \   '\bKEYWORD\s*=\s*function\s*\(',
            \ ],
            \ 'typescript': [
            \   "(service|factory)\\(['\"]KEYWORD['\"]",
            \   '\bKEYWORD\s*[=:]\s*\([^\)]*\)\s+=>',
            \   '\bKEYWORD\s*\([^()]*\)\s*[{]',
            \   'class\s*KEYWORD(\s*<[^>]*>)?\s*[\(\{]',
            \   'class\s*KEYWORD(\s*<[^>]*>)?\s+extends',
            \   '(export\s+)?interface\s+KEYWORD\b',
            \   '(export\s+)?type\s+KEYWORD\b',
            \   '(export\s+)?enum\s+KEYWORD\b',
            \   '(declare\s+)?namespace\s+KEYWORD\b',
            \   '(export\s+)?module\s+KEYWORD\b',
            \   'function\s*KEYWORD\s*\(',
            \   '\bKEYWORD\s*:\s*function\s*\(',
            \   '\bKEYWORD\s*=\s*function\s*\(',
            \   '\s*\bKEYWORD\s*=[^=\n]+',
            \   '\bfunction\b[^\(]*\(\s*[^\)]*\bKEYWORD\b\s*,?\s*\)?',
            \ ],
            \ 'typescriptreact': [
            \   "(service|factory)\\(['\"]KEYWORD['\"]",
            \   '\bKEYWORD\s*[=:]\s*\([^\)]*\)\s+=>',
            \   '\bKEYWORD\s*\([^()]*\)\s*[{]',
            \   'class\s*KEYWORD(\s*<[^>]*>)?\s*[\(\{]',
            \   'class\s*KEYWORD(\s*<[^>]*>)?\s+extends',
            \   '(export\s+)?interface\s+KEYWORD\b',
            \   '(export\s+)?type\s+KEYWORD\b',
            \   '(export\s+)?enum\s+KEYWORD\b',
            \   '(declare\s+)?namespace\s+KEYWORD\b',
            \   '(export\s+)?module\s+KEYWORD\b',
            \   'function\s*KEYWORD\s*\(',
            \   '\bKEYWORD\s*:\s*function\s*\(',
            \   '\bKEYWORD\s*=\s*function\s*\(',
            \   '\s*\bKEYWORD\s*=[^=\n]+',
            \   '\bfunction\b[^\(]*\(\s*[^\)]*\bKEYWORD\b\s*,?\s*\)?',
            \ ],
            \ 'hcl': [
            \   '(variable|output|module)\s*"KEYWORD"\s*\{',
            \   '(data|resource)\s*"\w+"\s*"KEYWORD"\s*\{',
            \ ],
            \ 'lua': [
            \   '\s*\bKEYWORD\s*=[^=\n]+',
            \   '\bfunction\b[^\(]*\(\s*[^\)]*\bKEYWORD\b\s*,?\s*\)?',
            \   'function\s*KEYWORD\s*\(',
            \   'function\s*.+[.:]KEYWORD\s*\(',
            \   '\bKEYWORD\s*=\s*function\s*\(',
            \   '\b.+\.KEYWORD\s*=\s*function\s*\(',
            \ ],
            \ 'rust': [
            \   '\blet\s+(\([^=\n]*)?(mut\s+)?KEYWORD([^=\n]*\))?(:\s*[^=\n]+)?\s*=\s*[^=\n]+',
            \   '\bconst\s+KEYWORD:\s*[^=\n]+\s*=[^=\n]+',
            \   '\bstatic\s+(mut\s+)?KEYWORD:\s*[^=\n]+\s*=[^=\n]+',
            \   '\bfn\s+.+\s*\((.+,\s+)?KEYWORD:\s*[^=\n]+\s*(,\s*.+)*\)',
            \   '(if|while)\s+let\s+([^=\n]+)?(mut\s+)?KEYWORD([^=\n\(]+)?\s*=\s*[^=\n]+',
            \   'struct\s+[^\n{]+[{][^}]*(\s*KEYWORD\s*:\s*[^\n},]+)[^}]*}',
            \   'enum\s+[^\n{]+\s*[{][^}]*\bKEYWORD\b[^}]*}',
            \   '\bfn\s+KEYWORD\s*\(',
            \   '\bmacro_rules!\s+KEYWORD',
            \   'struct\s+KEYWORD\s*[{\(]?',
            \   'trait\s+KEYWORD\s*[{]?',
            \   '\btype\s+KEYWORD([^=\n]+)?\s*=[^=\n]+;',
            \   'impl\s+((\w+::)*\w+\s+for\s+)?(\w+::)*KEYWORD\s+[{]?',
            \   'mod\s+KEYWORD\s*[{]?',
            \   '\benum\s+KEYWORD\b\s*[{]?',
            \ ],
            \ 'elixir': [
            \   '\bdef(p)?\s+KEYWORD\s*[ ,\(]',
            \   '\s*KEYWORD\s*=[^=\n]+',
            \   'defmodule\s+(\w+\.)*KEYWORD\s+',
            \   'defprotocol\s+(\w+\.)*KEYWORD\s+',
            \ ],
            \ 'erlang': [
            \   '^KEYWORD\b\s*\(',
            \   '\s*KEYWORD\s*=[^:=\n]+',
            \   '^-module\(KEYWORD\)',
            \ ],
            \ 'sql': [
            \   '(CREATE|create)\s+(.+?\s+)?(FUNCTION|function|PROCEDURE|procedure)\s+KEYWORD\s*\(',
            \   '(CREATE|create)\s+(.+?\s+)?(TABLE|table)(\s+(IF NOT EXISTS|if not exists))?\s+KEYWORD\b',
            \   '(CREATE|create)\s+(.+?\s+)?(VIEW|view)\s+KEYWORD\b',
            \   '(CREATE|create)\s+(.+?\s+)?(TYPE|type)\s+KEYWORD\b',
            \ ],
            \ 'zig': [
            \   'fn\s+KEYWORD\b',
            \   '(var|const)\s+KEYWORD\b',
            \ ],
            \ 'protobuf': [
            \   'message\s+KEYWORD\s*\{',
            \   'enum\s+KEYWORD\s*\{',
            \ ],
            \ }

let s:rg_filetypes = {
            \ 'c':          ['*.[chH]', '*.[chH].in', '*.cats'],
            \ 'cpp':        ['*.[ChH]', '*.[ChH].in', '*.[ch]pp', '*.[ch]pp.in', '*.[ch]xx', '*.[ch]xx.in', '*.cc', '*.cc.in', '*.hh', '*.hh.in', '*.inl'],
            \ 'crystal':    ['*.cr', '*.ecr', 'Projectfile', 'shard.yml'],
            \ 'css':        ['*.css', '*.scss'],
            \ 'dart':       ['*.dart'],
            \ 'elixir':     ['*.eex', '*.ex', '*.exs', '*.heex', '*.leex', '*.livemd'],
            \ 'erlang':     ['*.erl', '*.hrl'],
            \ 'fennel':     ['*.fnl'],
            \ 'go':         ['*.go'],
            \ 'hcl':        ['*.hcl', '*.tf', '*.tfvars'],
            \ 'html':       ['*.ejs', '*.htm', '*.html'],
            \ 'js':         ['*.cjs', '*.js', '*.jsx', '*.mjs', '*.vue'],
            \ 'json':       ['*.json', '*.sarif', 'composer.lock'],
            \ 'lua':        ['*.lua'],
            \ 'make':       ['*.mak', '*.mk', 'Makefile.*', '[Mm]akefile', '[Mm]akefile.am', '[Mm]akefile.in'],
            \ 'markdown':   ['*.markdown', '*.md', '*.mdown', '*.mdwn', '*.mdx', '*.mkd', '*.mkdn'],
            \ 'protobuf':   ['*.proto'],
            \ 'py':         ['*.py', '*.pyi'],
            \ 'ruby':       ['*.gemspec', '*.rake', '*.rb', '*.rbw', '.irbrc', 'Gemfile', 'Rakefile', 'config.ru'],
            \ 'rust':       ['*.rs'],
            \ 'sh':         ['*.bash', '*.bashrc', '*.env', '*.ksh', '*.sh', '*.zsh', '.bashrc', '.profile', '.zshrc'],
            \ 'sql':        ['*.psql', '*.sql'],
            \ 'tf':         ['*.terraform.lock.hcl', '*.tf', '*.tfvars'],
            \ 'toml':       ['*.toml', 'Cargo.lock'],
            \ 'ts':         ['*.cts', '*.mts', '*.ts', '*.tsx'],
            \ 'vim':        ['*.vim', '.vimrc', 'vimrc'],
            \ 'xml':        ['*.dtd', '*.rng', '*.xhtml', '*.xml', '*.xsd', '*.xsl', '*.xslt'],
            \ 'yaml':       ['*.yaml', '*.yml'],
            \ 'zig':        ['*.zig'],
            \ }

let s:rg_filetype_map = {
            \ 'javascript':      'js',
            \ 'javascriptreact': 'js',
            \ 'typescript':      'ts',
            \ 'typescriptreact': 'ts',
            \ 'python':          'py',
            \ 'sh':              'sh',
            \ 'bash':            'sh',
            \ 'zsh':             'sh',
            \ }

" ============================================================================
" Private Helpers
" ============================================================================

function! s:regexes(...) abort
    let l:ft = get(a:, 1, &filetype !=# '' ? &filetype : &buftype)
    return get(s:definitions, l:ft, [])
endfunction

function! s:build_pattern(keyword, ...) abort
    let l:ft = get(a:, 1, '')
    let l:patterns = []
    for l:regex in s:regexes(l:ft)
        call add(l:patterns, '(' .. substitute(l:regex, s:placeholder, a:keyword, 'g') .. ')')
    endfor
    if len(l:patterns) > 0
        return '"(' .. join(l:patterns, '|') .. ')"'
    endif
    return shellescape('\b' .. a:keyword .. '\b')
endfunction

function! s:build_pattern_args(keyword, ...) abort
    let l:ft = get(a:, 1, '')
    let l:args = []
    for l:regex in s:regexes(l:ft)
        call add(l:args, '-e ' .. shellescape(substitute(l:regex, s:placeholder, a:keyword, 'g')))
    endfor
    if len(l:args) > 0
        return join(l:args, ' ')
    endif
    return printf("'\\b%s\\b'", a:keyword)
endfunction

function! s:rg_filetype_opts(...) abort
    let l:ft = get(a:, 1, &filetype !=# '' ? &filetype : &buftype)
    let l:ft = get(s:rg_filetype_map, l:ft, l:ft)
    let l:opts = []
    if !empty(l:ft) && has_key(s:rg_filetypes, l:ft)
        call add(l:opts, '-t ' .. l:ft)
    else
        let l:ext = expand('%:e')
        if !empty(l:ext)
            call add(l:opts, '-g ' .. shellescape(printf('*.{%s}', l:ext)))
        endif
    endif
    return l:opts
endfunction

function! s:git_filetype_opts(...) abort
    let l:ft = get(a:, 1, &filetype !=# '' ? &filetype : &buftype)
    let l:ft = get(s:rg_filetype_map, l:ft, l:ft)
    let l:opts = []
    if !empty(l:ft) && has_key(s:rg_filetypes, l:ft)
        call add(l:opts, '--')
        for l:glob in s:rg_filetypes[l:ft]
            call add(l:opts, shellescape(l:glob))
        endfor
    else
        let l:ext = expand('%:e')
        if !empty(l:ext)
            call add(l:opts, '--')
            call add(l:opts, shellescape(printf('*.{%s}', l:ext)))
        endif
    endif
    return l:opts
endfunction

" ============================================================================
" Public API
" ============================================================================

function! zero_grep#dumb_jump#legacy#Cword(...) abort
    let l:ft = get(a:, 1, '')
    return s:build_pattern(expand('<cword>'), l:ft)
endfunction

function! zero_grep#dumb_jump#legacy#CwordArgs(...) abort
    let l:ft = get(a:, 1, '')
    return s:build_pattern_args(expand('<cword>'), l:ft)
endfunction

function! zero_grep#dumb_jump#legacy#RgCword(...) abort
    let l:ft = get(a:, 1, '')
    let l:type_opts = join(s:rg_filetype_opts(l:ft), ' ')
    let l:pattern   = zero_grep#dumb_jump#legacy#Cword(l:ft)
    return empty(l:type_opts)
                \ ? '-s ' .. l:pattern
                \ : '-s ' .. l:type_opts .. ' ' .. l:pattern
endfunction

function! zero_grep#dumb_jump#legacy#GitCword(...) abort
    let l:ft = get(a:, 1, '')
    let l:file_opts = join(s:git_filetype_opts(l:ft), ' ')
    let l:pattern   = zero_grep#dumb_jump#legacy#Cword(l:ft)
    return empty(l:file_opts)
                \ ? l:pattern
                \ : l:pattern .. ' ' .. l:file_opts
endfunction

function! zero_grep#dumb_jump#legacy#RgFileTypeArgs(...) abort
    let l:ft = get(a:, 1, '')
    return join(s:rg_filetype_opts(l:ft), ' ')
endfunction

function! zero_grep#dumb_jump#legacy#GitFileTypeArgs(...) abort
    let l:ft = get(a:, 1, '')
    return join(s:git_filetype_opts(l:ft), ' ')
endfunction

