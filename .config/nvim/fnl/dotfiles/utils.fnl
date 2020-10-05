(module dotfiles.utils
  {:require {nvim aniseed.nvim
             a aniseed.core}})

(defn viml->lua [m f opts]
  (..
    "lua require('" m "')"
    "['" f "']"
    "(" (or (and opts opts.args) "") ")"))

(defn nnoremap [lhs rhs options]
  ; create a nnoremap
  ; usage (nnoremap "cr" ":echo 'foo'" {:expr true :buffer false :nowait false}))
  (let [{:expr expr
         :silent silent
         :buffer buffer
         :nowait nowait
         :script script
         :unique unique} (or options {})]

    (when buffer
      (nvim.buf_set_keymap 0 "n" lhs rhs {:expr expr
                                          :silent silent
                                          :nowait nowait
                                          :script script
                                          :noremap true})

      (nvim.set_keymap "n" lhs rhs {:expr expr
                                    :silent silent
                                    :nowait nowait
                                    :script script
                                    :noremap true}))))
