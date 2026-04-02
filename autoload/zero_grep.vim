vim9script

# autoload/zero_grep.vim - Core word getters and context-aware dispatch (Vim9script)
# Maintainer: Phong Nguyen

# ============================================================================
# Escape Characters per Context
# ============================================================================

const GREP_ESCAPE_CHARS      = '^$.*+?()[]{}|-'
const SUBSTITUTE_ESCAPE_CHARS = '^$.*\/~[]'
const SHELL_ESCAPE_CHARS     = '\^$.*+?()[]{}|-'
const LEADERF_ESCAPE_CHARS   = '\^$.*+?()[]{}|-"'

# ============================================================================
# Raw Word Getters
# ============================================================================

export def CCword(): string
    return '\b' .. expand('<cword>') .. '\b'
enddef

export def Cword(): string
    return expand('<cword>')
enddef

export def Word(): string
    return expand('<cWORD>')
enddef

export def Vword(): string
    if exists('*getregion')
        return trim(join(call('getregion', [getpos("'<"), getpos("'>")])->slice(0, 1), "\n"))
    endif
    const line = getline("'<")
    const [_b1, l1, c1, _o1] = getpos("'<")
    const [_b2, l2, c2, _o2] = getpos("'>")
    if l1 != l2
        return trim(strpart(line, c1 - 1))
    endif
    return trim(strpart(line, c1 - 1, c2 - c1 + 1))
enddef

export def Pword(): string
    const search = @/
    if empty(search) || search ==# "\n"
        return ''
    endif
    return substitute(search, '^\\<\(.\+\)\\>$', '\\b\1\\b', '')
enddef

# ============================================================================
# Escape Helpers
# ============================================================================

def GrepEscape(text: string): string
    var t = substitute(text, '#', '\\\\#', 'g')
    t = escape(t, GREP_ESCAPE_CHARS)
    return shellescape(t)
enddef

def SubstituteEscape(text: string): string
    var t = escape(text, SUBSTITUTE_ESCAPE_CHARS)
    return substitute(t, '\n', '\\n', 'g')
enddef

def ShellEscape(text: string): string
    return shellescape(escape(text, SHELL_ESCAPE_CHARS))
enddef

def LeaderfEscape(text: string): string
    return shellescape(escape(text, LEADERF_ESCAPE_CHARS))
enddef

# ============================================================================
# Context Detection
# ============================================================================

def IsSubstituteCommand(cmd: string): bool
    return cmd =~# '^%\?\(s\|substitute\|S\|Subvert\)/' ||
        cmd =~# '^\(silent!\?\s\+\)\?\(c\|l\)\(fdo\|do\)\s\+\(s\|substitute\|S\|Subvert\)/'
enddef

def IsGrepCommand(cmd: string): bool
    return cmd =~# '^\(Grep\|LGrep\|BGrep\|grep\|lgrep\)\s' ||
        cmd =~# '^\(Ggrep!\?\|Gcgrep!\?\|Glgrep!\?\)\s' ||
        cmd =~# '^\(Git!\?\s\+grep\)\s'
enddef

def IsGrepperGitCommand(cmd: string): bool
    return cmd =~# '^\(GrepperGit\)\s'
enddef

def IsGrepperCommand(cmd: string): bool
    return cmd =~# '^\(Grepper\|SGrepper\|LGrepper\|PGrepper\|TGrepper\|GrepperRg\)\s'
enddef

def IsLeaderfCommand(cmd: string): bool
    return cmd =~# '^\(Leaderf\|LF\)\s'
enddef

def IsInputCommand(): bool
    return getcmdtype() == '@'
enddef

# ============================================================================
# Context-Namespaced Escape Functions
# ============================================================================
# --- grep ---

export def GrepEscapeText(text: string): string
    return GrepEscape(text)
enddef

export def GrepCCword(): string
    return GrepEscape(zero_grep#CCword())
enddef

export def GrepCword(): string
    return GrepEscape(zero_grep#Cword())
enddef

export def GrepWord(): string
    return GrepEscape(zero_grep#Word())
enddef

export def GrepVword(): string
    return GrepEscape(zero_grep#Vword())
enddef

export def GrepPword(): string
    return GrepEscape(zero_grep#Pword())
enddef

# --- substitute ---

export def SubstituteEscapeText(text: string): string
    return SubstituteEscape(text)
enddef

export def SubstituteCCword(): string
    return '\<' .. zero_grep#Cword() .. '\>'
enddef

export def SubstituteCword(): string
    return zero_grep#Cword()
enddef

export def SubstituteWord(): string
    return SubstituteEscape(zero_grep#Word())
enddef

export def SubstituteVword(whole_word: bool = false): string
    var t = SubstituteEscape(zero_grep#Vword())
    return whole_word ? '\<' .. t .. '\>' : t
enddef

export def SubstitutePword(): string
    return SubstituteEscape(zero_grep#Pword())
enddef

# --- shell ---

export def ShellEscapeText(text: string): string
    return ShellEscape(text)
enddef

export def ShellCCword(): string
    return shellescape(zero_grep#CCword())
enddef

export def ShellCword(): string
    return shellescape(zero_grep#Cword())
enddef

export def ShellWord(): string
    return ShellEscape(zero_grep#Word())
enddef

export def ShellVword(): string
    return ShellEscape(trim(zero_grep#Vword()))
enddef

export def ShellPword(): string
    return ShellEscape(trim(zero_grep#Pword()))
enddef

# --- leaderf ---
# LeaderF uses its own regex engine; escape chars include '"' in addition to
# the shell set. CCword and Cword are passed as plain shellescape (no regex
# boundaries) because LeaderF handles word matching internally.

export def LeaderfEscapeText(text: string): string
    return LeaderfEscape(text)
enddef

export def LeaderfCCword(): string
    return shellescape(zero_grep#CCword())
enddef

export def LeaderfCword(): string
    return shellescape(zero_grep#Cword())
enddef

export def LeaderfWord(): string
    return LeaderfEscape(zero_grep#Word())
enddef

export def LeaderfVword(): string
    return LeaderfEscape(trim(zero_grep#Vword()))
enddef

export def LeaderfPword(): string
    return LeaderfEscape(trim(zero_grep#Pword()))
enddef

export def FileTypeArgs(tool: string = '', ft: string = ''): string
    return zero_grep#filetype#Args(tool, ft)
enddef

export def DumbJumpCword(ft: string = ''): string
    return zero_grep#dumb_jump#Cword(ft)
enddef

export def DumbJumpCwordArgs(ft: string = ''): string
    return zero_grep#dumb_jump#CwordArgs(ft)
enddef

# ============================================================================
# Context-Aware Insert Functions (for <C-R>= mappings)
# ============================================================================

# Note: dumb_jump functions are called via autoload (zero_grep#dumb_jump#*)
# because Vim9script import autoload cannot be used inside exported functions
# that are themselves called from the command line at load time.

export def InsertCCword(): string
    var cmd = getcmdline()
    if IsSubstituteCommand(cmd)
        return zero_grep#SubstituteCCword()
    elseif IsGrepperGitCommand(cmd)
        return zero_grep#dumb_jump#GitCword()
    elseif IsGrepperCommand(cmd)
        return zero_grep#dumb_jump#RgCword()
    elseif IsGrepCommand(cmd)
        return zero_grep#GrepCCword()
    elseif IsLeaderfCommand(cmd)
        return zero_grep#LeaderfCCword()
    else
        return zero_grep#ShellCCword()
    endif
enddef

export def InsertCword(): string
    var cmd = getcmdline()
    if IsSubstituteCommand(cmd)
        return zero_grep#SubstituteCword()
    elseif IsGrepperGitCommand(cmd)
        return zero_grep#dumb_jump#GitCword()
    elseif IsGrepperCommand(cmd)
        return zero_grep#dumb_jump#RgCword()
    elseif IsGrepCommand(cmd)
        return zero_grep#GrepCCword()
    elseif IsLeaderfCommand(cmd)
        return zero_grep#LeaderfCword()
    elseif IsInputCommand()
        return zero_grep#ShellCword()
    else
        return zero_grep#Cword()
    endif
enddef

export def InsertWord(): string
    var cmd = getcmdline()
    if IsSubstituteCommand(cmd)
        return zero_grep#SubstituteWord()
    elseif IsGrepperGitCommand(cmd) || IsGrepperCommand(cmd)
        return zero_grep#dumb_jump#RgCword()
    elseif IsGrepCommand(cmd)
        return zero_grep#GrepWord()
    elseif IsLeaderfCommand(cmd)
        return zero_grep#LeaderfWord()
    else
        return zero_grep#ShellWord()
    endif
enddef

export def InsertVword(): string
    var cmd = getcmdline()
    if IsSubstituteCommand(cmd)
        return zero_grep#SubstituteVword()
    elseif IsGrepCommand(cmd)
        return zero_grep#GrepVword()
    elseif IsLeaderfCommand(cmd)
        return zero_grep#LeaderfVword()
    elseif IsInputCommand()
        return zero_grep#ShellVword()
    else
        return zero_grep#Vword()
    endif
enddef

export def InsertPword(): string
    var cmd = getcmdline()
    if IsSubstituteCommand(cmd)
        return zero_grep#SubstitutePword()
    elseif IsGrepCommand(cmd)
        return zero_grep#GrepPword()
    elseif IsLeaderfCommand(cmd)
        return zero_grep#LeaderfPword()
    else
        return zero_grep#ShellPword()
    endif
enddef
