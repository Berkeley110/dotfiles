" Configs
"++++++++++++++++++++++++++++++++++++++++++++++++++ {{{
" let $NVIM_COC_LOG_LEVEL='debug'
" let g:node_client_debug= 1
" let g:coc_node_args = ['--nolazy']
" let g:coc_watch_extensions = ['coc-conjure']
"
let g:coc_global_extensions = [
      \ 'coc-conjure',
      \ 'coc-css',
      \ 'coc-dictionary',
      \ 'coc-elixir',
      \ 'coc-emmet',
      \ 'coc-emoji',
      \ 'coc-git',
      \ 'coc-html',
      \ 'coc-jest',
      \ 'coc-json',
      \ 'coc-omni',
      \ 'coc-prettier',
      \ 'coc-rls',
      \ 'coc-snippets',
      \ 'coc-stylelint',
      \ 'coc-tag',
      \ 'coc-tsserver',
      \ 'coc-vetur',
      \ 'coc-word',
      \ 'coc-yaml',
      \ 'coc-yank']
"}}}

" Keymaps
"++++++++++++++++++++++++++++++++++++++++++++++++++ {{{
nmap gd <Plug>(coc-definition)
" refactor name
nmap zr <Plug>(coc-rename)
vmap zp <Plug>(coc-format-selected)
nmap zp <Plug>(coc-format-selected)
" fix current error on line
nmap zf <Plug>(coc-fix-current)
nmap zc <Plug>(coc-codeaction)
"}}}
