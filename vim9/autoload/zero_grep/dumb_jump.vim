vim9script

# autoload/zero_grep/dumb_jump.vim - Dumb Jump definitions (Vim9script)
# Maintainer: Phong Nguyen
#
# Language regular expressions ported from:
# https://github.com/jacktasia/dumb-jump/blob/master/dumb-jump.el

const PLACEHOLDER = 'KEYWORD'

const DEFINITIONS: dict<list<string>> = {
    'c++': [
        '\bKEYWORD(\s|\))*\((\w|[,&*.<>:]|\s)*(\))\s*(const|->|\{|$)|typedef\s+(\w|[(*]|\s)+KEYWORD(\)|\s)*\(',
        '\b(?!(class\b|struct\b|return\b|else\b|delete\b))(\w+|[,>])([*&]|\s)+KEYWORD\s*(\[(\d|\s)*\])*\s*([=,(){;]|:\s*\d)|#define\s+KEYWORD\b',
        '\b(class|struct|enum|union)\b\s*KEYWORD\b\s*(final\s*)?(:((\s*\w+\s*::)*\s*\w*\s*<?(\s*\w+\s*::)*\w+>?\s*,*)+)?((\{|$))|}\s*KEYWORD\b\s*;',
    ],
    'python': [
        '\s*\bKEYWORD\b(\s*:[^=\n]+)?\s*=[^=\n]+',
        '\s*\bKEYWORD\b(\s*:[^=]+)?\s*=[^=]+',
        'def\s*KEYWORD\b\s*\(',
        'class\s*KEYWORD\b\s*\(?',
    ],
    'ruby': [
        '^\s*((\w+[.])*\w+,\s*)*KEYWORD(,\s*(\w+[.])*\w+)*\s*=([^=>~]|$)',
        '(^|[^\w.])((private|public|protected)\s+)?def\s+(\w+(::|[.]))*KEYWORD($|[^\w|:])',
        '(^|\W)define(_singleton|_instance)?_method(\s|[(])\s*:KEYWORD($|[^\w|:])',
        '(^|[^\w.])class\s+(\w*::)*KEYWORD($|[^\w|:])',
        '(^|[^\w.])module\s+(\w*::)*KEYWORD($|[^\w|:])',
        '(^|\W)alias(_method)?\W+KEYWORD(\W|$)',
    ],
    'crystal': [
        '^\s*((\w+[.])*\w+,\s*)*KEYWORD(,\s*(\w+[.])*\w+)*\s*=([^=>~]|$)',
        '(^|[^\w.])((private|public|protected)\s+)?def\s+(\w+(::|[.]))*KEYWORD($|[^\w|:])',
        '(^|[^\w.])class\s+(\w*::)*KEYWORD($|[^\w|:])',
        '(^|[^\w.])module\s+(\w*::)*KEYWORD($|[^\w|:])',
        '(^|[^\w.])struct\s+(\w*::)*KEYWORD($|[^\w|:])',
        '(^|[^\w.])alias\s+(\w*::)*KEYWORD($|[^\w|:])',
    ],
    'shell': [
        'function\s*KEYWORD\s*',
        'KEYWORD\(\)\s*\{',
        '\bKEYWORD\s*=\s*',
    ],
    'sh': [
        'function\s*KEYWORD\s*',
        'KEYWORD\(\)\s*\{',
        '\bKEYWORD\s*=\s*',
    ],
    'bash': [
        'function\s*KEYWORD\s*',
        'KEYWORD\(\)\s*\{',
        '\bKEYWORD\s*=\s*',
    ],
    'zsh': [
        'function\s*KEYWORD\s*',
        'KEYWORD\(\)\s*\{',
        '\bKEYWORD\s*=\s*',
    ],
    'dart': [
        '\bKEYWORD\s*\([^()]*\)\s*[{]',
        'class\s*KEYWORD\s*[\(\{]',
    ],
    'fennel': [
        '\((local|var)\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
        '\(fn\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
        '\(macro\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
    ],
    'go': [
        '\s*\bKEYWORD\s*=[^=\n]+',
        '\s*\bKEYWORD\s*:=\s*',
        'func\s+\([^\)]*\)\s+KEYWORD\s*\(',
        'func\s+KEYWORD\s*\(',
        'type\s+KEYWORD\s+struct\s+\{',
    ],
    'javascript': [
        "(service|factory)\(['\"]KEYWORD['\"]",
        '\bKEYWORD\s*[=:]\s*\([^\)]*\)\s+=>',
        '\bKEYWORD\s*\([^()]*\)\s*[{]',
        'class\s*KEYWORD\s*[\(\{]',
        'class\s*KEYWORD\s+extends',
        '\s*\bKEYWORD\s*=[^=\n]+',
        '\bfunction\b[^\(]*\(\s*[^\)]*\bKEYWORD\b\s*,?\s*\)?',
        'function\s*KEYWORD\s*\(',
        '\bKEYWORD\s*:\s*function\s*\(',
        '\bKEYWORD\s*=\s*function\s*\(',
    ],
    'hcl': [
        '(variable|output|module)\s*"KEYWORD"\s*\{',
        '(data|resource)\s*"\w+"\s*"KEYWORD"\s*\{',
    ],
    'typescript': [
        "(service|factory)\(['\"]KEYWORD['\"]",
        '\bKEYWORD\s*[=:]\s*\([^\)]*\)\s+=>',
        '\bKEYWORD\s*\([^()]*\)\s*[{]',
        'class\s*KEYWORD(\s*<[^>]*>)?\s*[\(\{]',
        'class\s*KEYWORD(\s*<[^>]*>)?\s+extends',
        '(export\s+)?interface\s+KEYWORD\b',
        '(export\s+)?type\s+KEYWORD\b',
        '(export\s+)?enum\s+KEYWORD\b',
        '(declare\s+)?namespace\s+KEYWORD\b',
        '(export\s+)?module\s+KEYWORD\b',
        'function\s*KEYWORD\s*\(',
        '\bKEYWORD\s*:\s*function\s*\(',
        '\bKEYWORD\s*=\s*function\s*\(',
        '\s*\bKEYWORD\s*=[^=\n]+',
        '\bfunction\b[^\(]*\(\s*[^\)]*\bKEYWORD\b\s*,?\s*\)?',
    ],
    'lua': [
        '\s*\bKEYWORD\s*=[^=\n]+',
        '\bfunction\b[^\(]*\(\s*[^\)]*\bKEYWORD\b\s*,?\s*\)?',
        'function\s*KEYWORD\s*\(',
        'function\s*.+[.:]KEYWORD\s*\(',
        '\bKEYWORD\s*=\s*function\s*\(',
        '\b.+\.KEYWORD\s*=\s*function\s*\(',
    ],
    'rust': [
        '\blet\s+(\([^=\n]*)?(mut\s+)?KEYWORD([^=\n]*\))?(:\s*[^=\n]+)?\s*=\s*[^=\n]+',
        '\bconst\s+KEYWORD:\s*[^=\n]+\s*=[^=\n]+',
        '\bstatic\s+(mut\s+)?KEYWORD:\s*[^=\n]+\s*=[^=\n]+',
        '\bfn\s+.+\s*\((.+,\s+)?KEYWORD:\s*[^=\n]+\s*(,\s*.+)*\)',
        '(if|while)\s+let\s+([^=\n]+)?(mut\s+)?KEYWORD([^=\n\(]+)?\s*=\s*[^=\n]+',
        'struct\s+[^\n{]+[{][^}]*(\s*KEYWORD\s*:\s*[^\n},]+)[^}]*}',
        'enum\s+[^\n{]+\s*[{][^}]*\bKEYWORD\b[^}]*}',
        '\bfn\s+KEYWORD\s*\(',
        '\bmacro_rules!\s+KEYWORD',
        'struct\s+KEYWORD\s*[{\(]?',
        'trait\s+KEYWORD\s*[{]?',
        '\btype\s+KEYWORD([^=\n]+)?\s*=[^=\n]+;',
        'impl\s+((\w+::)*\w+\s+for\s+)?(\w+::)*KEYWORD\s+[{]?',
        'mod\s+KEYWORD\s*[{]?',
        '\benum\s+KEYWORD\b\s*[{]?',
    ],
    'elixir': [
        '\bdef(p)?\s+KEYWORD\s*[ ,\(]',
        '\s*KEYWORD\s*=[^=\n]+',
        'defmodule\s+(\w+\.)*KEYWORD\s+',
        'defprotocol\s+(\w+\.)*KEYWORD\s+',
    ],
    'erlang': [
        '^KEYWORD\b\s*\(',
        '\s*KEYWORD\s*=[^:=\n]+',
        '^-module\(KEYWORD\)',
    ],
    'sql': [
        '(CREATE|create)\s+(.+?\s+)?(FUNCTION|function|PROCEDURE|procedure)\s+KEYWORD\s*\(',
        '(CREATE|create)\s+(.+?\s+)?(TABLE|table)(\s+(IF NOT EXISTS|if not exists))?\s+KEYWORD\b',
        '(CREATE|create)\s+(.+?\s+)?(VIEW|view)\s+KEYWORD\b',
        '(CREATE|create)\s+(.+?\s+)?(TYPE|type)\s+KEYWORD\b',
    ],
    'zig': [
        'fn\s+KEYWORD\b',
        '(var|const)\s+KEYWORD\b',
    ],
    'protobuf': [
        'message\s+KEYWORD\s*\{',
        'enum\s+KEYWORD\s*\{',
    ],
    'c': [
        '\bKEYWORD(\s|\))*\((\w|[,&*.<>:]|\s)*(\))\s*(const|->|\{|$)|typedef\s+(\w|[(*]|\s)+KEYWORD(\)|\s)*\(',
        '\b(?!(class\b|struct\b|return\b|else\b|delete\b))(\w+|[,>])([*&]|\s)+KEYWORD\s*(\[(\d|\s)*\])*\s*([=,(){;]|:\s*\d)|#define\s+KEYWORD\b',
        '\b(class|struct|enum|union)\b\s*KEYWORD\b\s*(final\s*)?(:((\s*\w+\s*::)*\s*\w*\s*<?(\s*\w+\s*::)*\w+>?\s*,*)+)?((\{|$))|}\s*KEYWORD\b\s*;',
    ],
    'cpp': [
        '\bKEYWORD(\s|\))*\((\w|[,&*.<>:]|\s)*(\))\s*(const|->|\{|$)|typedef\s+(\w|[(*]|\s)+KEYWORD(\)|\s)*\(',
        '\b(?!(class\b|struct\b|return\b|else\b|delete\b))(\w+|[,>])([*&]|\s)+KEYWORD\s*(\[(\d|\s)*\])*\s*([=,(){;]|:\s*\d)|#define\s+KEYWORD\b',
        '\b(class|struct|enum|union)\b\s*KEYWORD\b\s*(final\s*)?(:((\s*\w+\s*::)*\s*\w*\s*<?(\s*\w+\s*::)*\w+>?\s*,*)+)?((\{|$))|}\s*KEYWORD\b\s*;',
    ],
    'javascriptreact': [
        "(service|factory)\(['\"]KEYWORD['\"]",
        '\bKEYWORD\s*[=:]\s*\([^\)]*\)\s+=>',
        '\bKEYWORD\s*\([^()]*\)\s*[{]',
        'class\s*KEYWORD\s*[\(\{]',
        'class\s*KEYWORD\s+extends',
        '\s*\bKEYWORD\s*=[^=\n]+',
        '\bfunction\b[^\(]*\(\s*[^\)]*\bKEYWORD\b\s*,?\s*\)?',
        'function\s*KEYWORD\s*\(',
        '\bKEYWORD\s*:\s*function\s*\(',
        '\bKEYWORD\s*=\s*function\s*\(',
    ],
    'typescriptreact': [
        "(service|factory)\(['\"]KEYWORD['\"]",
        '\bKEYWORD\s*[=:]\s*\([^\)]*\)\s+=>',
        '\bKEYWORD\s*\([^()]*\)\s*[{]',
        'class\s*KEYWORD(\s*<[^>]*>)?\s*[\(\{]',
        'class\s*KEYWORD(\s*<[^>]*>)?\s+extends',
        '(export\s+)?interface\s+KEYWORD\b',
        '(export\s+)?type\s+KEYWORD\b',
        '(export\s+)?enum\s+KEYWORD\b',
        '(declare\s+)?namespace\s+KEYWORD\b',
        '(export\s+)?module\s+KEYWORD\b',
        'function\s*KEYWORD\s*\(',
        '\bKEYWORD\s*:\s*function\s*\(',
        '\bKEYWORD\s*=\s*function\s*\(',
        '\s*\bKEYWORD\s*=[^=\n]+',
        '\bfunction\b[^\(]*\(\s*[^\)]*\bKEYWORD\b\s*,?\s*\)?',
    ],
}

# ============================================================================
# Private Helpers
# ============================================================================

def Regexes(ft: string = ''): list<string>
    const filetype = empty(ft) ? (&filetype !=# '' ? &filetype : &buftype) : ft
    return get(DEFINITIONS, filetype, [])
enddef

def BuildPattern(keyword: string, ft: string = ''): string
    var patterns: list<string> = []
    for regex in Regexes(ft)
        patterns->add('(' .. substitute(regex, PLACEHOLDER, keyword, 'g') .. ')')
    endfor
    if len(patterns) > 0
        return '"(' .. join(patterns, '|') .. ')"'
    endif
    return shellescape('\b' .. keyword .. '\b')
enddef

def BuildPatternArgs(keyword: string, ft: string = ''): string
    var patterns: list<string> = []
    for regex in Regexes(ft)
        patterns->add('-e ' .. shellescape(substitute(regex, PLACEHOLDER, keyword, 'g')))
    endfor
    if len(patterns) > 0
        return join(patterns, ' ')
    endif
    return shellescape('\b' .. keyword .. '\b')
enddef

# ============================================================================
# Public API
# ============================================================================

# Returns the compiled dumb-jump pattern for the word under cursor.
# Format: "(pattern1|pattern2|...)" — ready to pass to rg -P or git grep -P
export def Cword(ft: string = ''): string
    return BuildPattern(expand('<cword>'), ft)
enddef

# Returns multiple -e args for grep -E (no PCRE needed)
export def CwordArgs(ft: string = ''): string
    return BuildPatternArgs(expand('<cword>'), ft)
enddef
