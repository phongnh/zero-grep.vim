" plugin/zero_grep.vim - Word getter commands and mappings (Vim9script)
" Maintainer: Phong Nguyen

if !has('vim9script') || has('nvim') || exists('g:loaded_zero_grep')
    finish
endif

vim9script

g:loaded_zero_grep = 1

# ============================================================================
# Functions
# ============================================================================
def g:FileTypeArgs(...args: list<any>): string
    return call(zero_grep#filetype#Args, args)
enddef

def g:DumbJumpCword(...args: list<any>): string
    return call(zero_grep#dumb_jump#Cword, args)
enddef

def g:DumbJumpCwordArgs(...args: list<any>): string
    return call(zero_grep#dumb_jump#CwordArgs, args)
enddef

def g:CCword(): string
    return zero_grep#CCword()
enddef

def g:Cword(): string
    return zero_grep#Cword()
enddef

def g:Word(): string
    return zero_grep#Word()
enddef

def g:Vword(): string
    return zero_grep#Vword()
enddef

def g:Pword(): string
    return zero_grep#Pword()
enddef

def g:ShellCCword(): string
    return zero_grep#ShellCCword()
enddef

def g:ShellCword(): string
    return zero_grep#ShellCword()
enddef

def g:ShellWord(): string
    return zero_grep#ShellWord()
enddef

def g:ShellVword(): string
    return zero_grep#ShellVword()
enddef

def g:ShellPword(): string
    return zero_grep#ShellPword()
enddef
