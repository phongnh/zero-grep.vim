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
# Trim
# ============================================================================

def Trim(str: string): string
    return trim(str)
enddef

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
    var reg_save     = @"
    var regtype_save = getregtype('"')
    normal! gvy
    var selection = @"
    setreg('"', reg_save, regtype_save)
    return selection ==# "\n" ? '' : selection
enddef

export def Pword(): string
    var search = @/
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
    return GrepEscape(CCword())
enddef

export def GrepCword(): string
    return GrepEscape(Cword())
enddef

export def GrepWord(): string
    return GrepEscape(Word())
enddef

export def GrepVword(): string
    return GrepEscape(Vword())
enddef

export def GrepPword(): string
    return GrepEscape(Pword())
enddef

# --- substitute ---

export def SubstituteEscapeText(text: string): string
    return SubstituteEscape(text)
enddef

export def SubstituteCCword(): string
    return '\<' .. Cword() .. '\>'
enddef

export def SubstituteCword(): string
    return Cword()
enddef

export def SubstituteWord(): string
    return SubstituteEscape(Word())
enddef

export def SubstituteVword(whole_word: bool = false): string
    var t = SubstituteEscape(Vword())
    return whole_word ? '\<' .. t .. '\>' : t
enddef

export def SubstitutePword(): string
    return SubstituteEscape(Pword())
enddef

# --- shell ---

export def ShellEscapeText(text: string): string
    return ShellEscape(text)
enddef

export def ShellCCword(): string
    return shellescape(CCword())
enddef

export def ShellCword(): string
    return shellescape(Cword())
enddef

export def ShellWord(): string
    return ShellEscape(Word())
enddef

export def ShellVword(): string
    return ShellEscape(Trim(Vword()))
enddef

export def ShellPword(): string
    return ShellEscape(Trim(Pword()))
enddef

# --- leaderf ---
# LeaderF uses its own regex engine; escape chars include '"' in addition to
# the shell set. CCword and Cword are passed as plain shellescape (no regex
# boundaries) because LeaderF handles word matching internally.

export def LeaderfEscapeText(text: string): string
    return LeaderfEscape(text)
enddef

export def LeaderfCCword(): string
    return shellescape(CCword())
enddef

export def LeaderfCword(): string
    return shellescape(Cword())
enddef

export def LeaderfWord(): string
    return LeaderfEscape(Word())
enddef

export def LeaderfVword(): string
    return LeaderfEscape(Trim(Vword()))
enddef

export def LeaderfPword(): string
    return LeaderfEscape(Trim(Pword()))
enddef

# ============================================================================
# Context-Aware Insert Functions (for <C-R>= mappings)
# ============================================================================

export def InsertCCword(): string
    var cmd = getcmdline()
    if IsSubstituteCommand(cmd)
        return SubstituteCCword()
    elseif IsGrepperGitCommand(cmd)
        return zero_grep#dumb_jump#GitCword()
    elseif IsGrepperCommand(cmd)
        return zero_grep#dumb_jump#RgCword()
    elseif IsGrepCommand(cmd)
        return GrepCCword()
    elseif IsLeaderfCommand(cmd)
        return LeaderfCCword()
    else
        return ShellCCword()
    endif
enddef

export def InsertCword(): string
    var cmd = getcmdline()
    if IsSubstituteCommand(cmd)
        return SubstituteCword()
    elseif IsGrepperGitCommand(cmd)
        return zero_grep#dumb_jump#GitCword()
    elseif IsGrepperCommand(cmd)
        return zero_grep#dumb_jump#RgCword()
    elseif IsGrepCommand(cmd)
        return GrepCCword()
    elseif IsLeaderfCommand(cmd)
        return LeaderfCword()
    elseif IsInputCommand()
        return ShellCword()
    else
        return Cword()
    endif
enddef

export def InsertWord(): string
    var cmd = getcmdline()
    if IsSubstituteCommand(cmd)
        return SubstituteWord()
    elseif IsGrepperGitCommand(cmd) || IsGrepperCommand(cmd)
        return zero_grep#dumb_jump#RgCword()
    elseif IsGrepCommand(cmd)
        return GrepWord()
    elseif IsLeaderfCommand(cmd)
        return LeaderfWord()
    else
        return ShellWord()
    endif
enddef

# Note: dumb_jump functions are called via autoload (zero_grep#dumb_jump#*)
# because Vim9script import autoload cannot be used inside exported functions
# that are themselves called from the command line at load time.

export def InsertVword(): string
    var cmd = getcmdline()
    if IsSubstituteCommand(cmd)
        return SubstituteVword()
    elseif IsGrepCommand(cmd)
        return GrepVword()
    elseif IsLeaderfCommand(cmd)
        return LeaderfVword()
    elseif IsInputCommand()
        return ShellVword()
    else
        return Vword()
    endif
enddef

export def InsertPword(): string
    var cmd = getcmdline()
    if IsSubstituteCommand(cmd)
        return SubstitutePword()
    elseif IsGrepCommand(cmd)
        return GrepPword()
    elseif IsLeaderfCommand(cmd)
        return LeaderfPword()
    else
        return ShellPword()
    endif
enddef
