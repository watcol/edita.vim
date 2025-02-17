let s:repo = fnamemodify(expand('<sfile>'), ':p:h:h:h:h')

function! edita#vim#client#open() abort
  bwipeout!
  let args = argv()
  let target = len(args) isnot# 0 ? fnamemodify(args[-1], ':p') : ""
  call s:send(['call', 'Tapi_edita_open', [target]])
  enew | redraw
  " Disable mappings to prevent accidental edit
  for nr in range(256)
    silent! execute printf("cnoremap \<buffer>\<silent> \<Char-%d> \<Nop>", nr)
  endfor
  " Accept 'Editaquit' to quit
  silent! cnoremap <buffer> Editaquit <C-u>OK<Return>
  silent! cnoremap <buffer> <C-c> <Esc>
  let r = input(printf('Waiting %s. Hit Ctrl-C to cancel', target))
  if !empty(r)
    quitall!
  else
    cquit!
  endif
endfunction

function! edita#vim#client#EDITOR() abort
  let args = [
        \ v:progpath,
        \ '--not-a-term',
        \ '--clean',
        \ '--noplugin',
        \ '-n',
        \ '-R',
        \]
  let cmds = [
        \ printf('set runtimepath^=%s', fnameescape(s:repo)),
        \ 'call edita#vim#client#open()'
        \]
  call map(cmds, { -> printf('-c %s', shellescape(v:val)) })
  return join(args + cmds)
endfunction

function! s:send(data) abort
  execute "set t_ts=\<Esc>]51; t_fs=\x07"
  let &titlestring = json_encode(a:data)
  set title
  redraw!
  let &titlestring = ''
  set t_ts& t_fs&
endfunction
