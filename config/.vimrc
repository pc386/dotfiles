function! DenoFmtAndSave()
    silent! write               " Save the current file
    silent! !deno fmt "%"       " Format the current file with deno fmt
    checktime                   " Check if the file changed externally
    edit!                       " Force reload to reflect external changes
endfunction

command! DenoFmt call DenoFmtAndSave()

