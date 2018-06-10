function! cheat#providers#quickfix#GetError()
    try
        cr
    catch /^Vim\%((\a\+)\)\=:E42/
        return ''
    endtry
    silent cclose
    cwindow
    if( search('ERROR\c') == -1)
        " No error search current line
        call search('|'.getpos('.')[1].' col ')
    endif
    echo getline('.')
    let query=substitute(substitute(substitute(
                \getline('.'), '^[^|]*|[^|]*|', '', ''),
                \'\[.*\]$', '', ''),
                \'‘\|’', '', 'g')
    echo query
    cclose
    return query
endfunction
