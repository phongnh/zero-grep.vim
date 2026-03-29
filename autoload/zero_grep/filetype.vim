vim9script

# autoload/zero_grep/filetype.vim - Filetype-aware rg/git grep helpers (Vim9script)
# Maintainer: Phong Nguyen
#
# Wraps word getters with rg -t / git grep -- glob filetype filtering.
# Filetype data and opts builders live in zero_grep#dumb_jump#.

# ============================================================================
# Private Helpers
# ============================================================================

def RgOpts(keyword: string, ft: string = ''): string
    var type_opts = zero_grep#dumb_jump#RgFileTypeArgs(ft)
    var pat = shellescape(keyword)
    return empty(type_opts)
        ? pat
        : type_opts .. ' ' .. pat
enddef

def GitOpts(keyword: string, ft: string = ''): string
    var file_opts = zero_grep#dumb_jump#GitFileTypeArgs(ft)
    var pat = shellescape(keyword)
    return empty(file_opts)
        ? pat
        : pat .. ' ' .. file_opts
enddef

# ============================================================================
# Public API — rg
# ============================================================================

export def RgCCword(ft: string = ''): string
    return RgOpts(zero_grep#CCword(), ft)
enddef

export def RgCword(ft: string = ''): string
    return RgOpts(zero_grep#Cword(), ft)
enddef

export def RgWord(ft: string = ''): string
    return RgOpts(zero_grep#Word(), ft)
enddef

export def RgVword(ft: string = ''): string
    return RgOpts(zero_grep#Vword(), ft)
enddef

# ============================================================================
# Public API — git grep
# ============================================================================

export def GitCCword(ft: string = ''): string
    return GitOpts(zero_grep#CCword(), ft)
enddef

export def GitCword(ft: string = ''): string
    return GitOpts(zero_grep#Cword(), ft)
enddef

export def GitWord(ft: string = ''): string
    return GitOpts(zero_grep#Word(), ft)
enddef

export def GitVword(ft: string = ''): string
    return GitOpts(zero_grep#Vword(), ft)
enddef
