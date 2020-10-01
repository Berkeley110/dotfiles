" Configs
"++++++++++++++++++++++++++++++++++++++++++++++++++ {{{

call defx#custom#option('_', {
      \ 'columns': 'indent:mark:git:icons:icon:filename',
      \ 'winwidth': 32,
      \ 'show_ignored_files': 1,
      \ 'direction': 'topleft',
      \ 'split': 'vertical',
      \ })

call defx#custom#column('filename', {
      \ 'min_width': 32,
      \ 'max_width': -90,
      \ })

" Symbols{{{
call defx#custom#column('icon', {
      \ 'directory_icon': '▸',
      \ 'opened_icon': '▾',
      \ 'root_icon': '.',
      \ })

call defx#custom#column('mark', {
      \ 'readonly_icon': '✗',
      \ 'selected_icon': '✓',
      \ })

let g:defx_git#indicators = {
      \ 'Deleted'   : '✖',
      \ 'Ignored'   : '☒',
      \ 'Modified'  : '✹',
      \ 'Renamed'   : '➜',
      \ 'Staged'    : '✚',
      \ 'Unknown'   : '?',
      \ 'Unmerged'  : '═',
      \ 'Untracked' : '✭'
      \ }
"}}}
"}}}

" Keymaps
"++++++++++++++++++++++++++++++++++++++++++++++++++ {{{

" Func: Tab_Id
"-------------------------------------------------- {{{
let s:tab_id_max = 0
function! s:tab_id()
  if ! exists('t:defx_tab_id')
    let s:tab_id_max = s:tab_id_max + 1
    let t:defx_tab_id = s:tab_id_max
  endif
  return t:defx_tab_id
endfunction " }}}

" Func: DefxExplorer
"-------------------------------------------------- {{{
function! DefxExplorer(...)
  if &filetype =~# 'defx'
    call defx#call_action('quit')
    return
  endif

  let l:dir = a:0 >= 1 ? a:1 : './'
  let l:cmd = join([
    \ 'Defx',
    \ '-buffer-name=`"defx" . tabpagenr()`',
    \], ' ')

  execute l:cmd . ' ' . l:dir
endfunction
"}}}
"
" Func: DefxSearch
"-------------------------------------------------- {{{
function! DefxSearch(search, dir)

  if &filetype =~# 'defx'
    call defx#call_action('quit')
    return
  endif

  let l:cmd = join([
    \ 'Defx',
    \ '-search=' . a:search,
    \ '-buffer-name=`"defx" . tabpagenr()`',
    \], ' ')

  execute l:cmd . ' ' . a:dir
endfunction "}}}

" Func: DefxChangeRoot
"-------------------------------------------------- {{{
function! DefxChangeRoot()
  let l:isDir = defx#is_directory()

  if (!l:isDir)
    return
  endif

  call defx#call_action('yank_path')
  call defx#call_action('cd', [@0])
endfunction
"}}}

nnoremap <silent>zet :call DefxExplorer()<CR><C-w>=
nnoremap <silent>zef :call DefxSearch(expand('%:p'), getcwd())<CR><C-w>=

function! s:defx_settings() "{{{
  nnoremap <silent><buffer><expr><CR>     defx#is_directory() ? defx#do_action('open_tree', 'toggle') : defx#do_action('multi', ['drop', 'quit'])
  nnoremap <silent><buffer><expr><Space>  defx#is_directory() ? defx#do_action('open_tree', 'toggle') : defx#do_action('close_tree')
  nnoremap <silent><buffer><expr> C       defx#do_action('copy')
  nnoremap <silent><buffer><expr> M       defx#do_action('move')
  nnoremap <silent><buffer><expr><C-h>    defx#do_action('multi', [[ 'drop', 'split' ], 'quit'])
  nnoremap <silent><buffer><expr><C-v>    defx#do_action('multi', [[ 'drop', 'vsplit' ], 'quit'])
  nnoremap <silent><buffer><expr><C-t>    defx#do_action('multi', [[ 'drop', 'tabnew' ], 'quit'])
  nnoremap <silent><buffer><expr> a       defx#do_action('new_file')
  nnoremap <silent><buffer><expr> A       defx#do_action('new_directory')
  nnoremap <silent><buffer><expr> D       defx#do_action('remove')
  nnoremap <silent><buffer><expr> r       defx#do_action('rename')
  nnoremap <silent><buffer><expr> yy      defx#do_action('yank_path')
  nnoremap <silent><buffer><expr> .       defx#do_action('toggle_ignored_files')
  nnoremap <silent><buffer><expr><C-p>    defx#do_action('cd', ['..'])
  nnoremap <silent><buffer><expr> P       defx#do_action('paste')
  nnoremap <silent><buffer> cr            :call DefxChangeRoot()<CR>
  nnoremap <silent><buffer><expr><Tab>    defx#do_action('toggle_select')

  nnoremap <silent><buffer><expr> L       defx#do_action('open_tree')
  nnoremap <silent><buffer><expr> H       defx#do_action('close_tree')
  nnoremap <silent><buffer><expr> j       line('.') == line('$') ? 'gg' : 'j'
  nnoremap <silent><buffer><expr> k       line('.') == 1 ? 'G' : 'k'

  nnoremap <silent><buffer><expr> R       defx#do_action('redraw')
  nnoremap <silent><buffer><expr> cd      defx#do_action('change_vim_cwd')

  nnoremap <silent><buffer><expr> >> defx#do_action('resize', defx#get_context().winwidth + 20)
  nnoremap <silent><buffer><expr> << defx#do_action('resize', defx#get_context().winwidth - 20)
endfunction
"}}}

augroup DEFX "{{{
  autocmd FileType defx call <SID>defx_settings()
  autocmd FileType defx setlocal spell!
  autocmd VimResized defx call defx#call_action('resize', winwidth(0))
  autocmd BufWritePost * call defx#redraw()
augroup END "}}}
"}}}

" Colors
"++++++++++++++++++++++++++++++++++++++++++++++++++ {{{
highlight Defx_filename_4_opened_icon ctermfg=84
highlight Defx_filename_4_directory_icon ctermfg=117
"git
highlight Defx_filename_4_Deleted ctermfg=167 guifg=#fb4934
highlight Defx_filename_4_Ignored guibg=NONE guifg=NONE ctermbg=NONE ctermfg=NONE
highlight Defx_filename_4_Modified ctermfg=9 guifg=#fabd2f
highlight Defx_filename_4_Renamed ctermfg=214 guifg=#fabd2f
highlight Defx_filename_4_Staged ctermfg=142 guifg=#b8bb26
highlight Defx_filename_4_Unknown guibg=NONE guifg=NONE ctermbg=NONE ctermfg=NONE
highlight Defx_filename_4_Unmerged ctermfg=167 guifg=#fb4934
highlight Defx_filename_4_Untracked guibg=NONE guifg=NONE ctermbg=NONE ctermfg=NONE
"}}}
