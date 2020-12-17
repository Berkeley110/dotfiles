(module utils
  {:require {
             a aniseed.core
             nvim aniseed.nvim
             nutils aniseed.nvim.util
             : r
             str aniseed.string}})


;; hack to pass through nvim
(setmetatable *module* {:__index nvim})

(defn- viml-name-format [s] (-> s (: :gsub :%. "_") (: :gsub :%- "_")))

(defn viml-fn-bridge [mod name opts]
  (let [Mod (r.upperFirst mod)
        func-name (viml-name-format (.. Mod "_" name "_viml"))]
    (nutils.fn-bridge func-name mod name opts)
    func-name))

(defn viml->lua [m f opts]
  "(viml->lua :module.a :module-function {:args ['foo' 'bar']})"
  (..
    "lua require('" m "')"
    "['" f "']"
    "(" (or (and opts opts.args) "") ")"))

(def- map-types
  (->
    [:n :o :v :i]
    r.key-map))

(tset map-types :a "")

(defn- base-map [mtype lhs rhs options]
  "(base-map 'n' 'cr' ':echo foo' {:expr true :buffer false :nowait false})"
  (let [mode (. map-types mtype)
        {:expr expr
         :silent silent
         :buffer buffer
         :nowait nowait
         :script script
         :unique unique} (or options {})

        args [mode lhs rhs {:expr expr
                            :silent silent
                            :nowait nowait
                            :script script}]]
    (if
      buffer (nvim.buf_set_keymap 0 (unpack args))
      (nvim.set_keymap (unpack args)))))


(defn nmap [lhs rhs options] (base-map :n lhs rhs options))
(defn amap [lhs rhs options] (base-map :a lhs rhs options))
(defn omap [lhs rhs options] (base-map :o lhs rhs options))
(defn imap [lhs rhs options] (base-map :i lhs rhs options))
(defn vmap [lhs rhs options] (base-map :v lhs rhs options))

(defn noremap [lhs rhs options?]
  "norecur map for all modes"
  (let [options (r.assoc (or options? {}) :noremap true)]
    (base-map :a lhs rhs options)))

(defn nnoremap [lhs rhs options?]
  "(nnoremap 'cr' ':echo foo' {:expr true :buffer false :nowait false})
  create a nnoremap"
  (let [options (r.assoc (or options? {}) :noremap true)]
    (base-map :n lhs rhs options)))

(defn inoremap [lhs rhs options?]
  (let [options (r.assoc (or options? {}) :noremap true)]
    (base-map :i lhs rhs options)))

(defn get-cursor-pos []
  "(get-cursor-pos) => [x, y]
  get the chars under the cursor"
  [(nvim.fn.line ".")
   (nvim.fn.col ".")])

(defn get-char-under-curs []
  "(get-char-under-curs)
  get the character under the cursor
  should work with multi-byte chars but is slower than other methods"
  (let [line (nvim.fn.getline ".")
        col (nvim.fn.col ".")
        matchReg (.. "\\%" col "c.")]
    (nvim.fn.matchstr line matchReg)))

(def- none "NONE")

(defn hi-link [from to override?]
  "create a highlight link"
  (if override? (nvim.ex.highlight_ :link from to)
      (nvim.ex.highlight :link from to)))

(defn hi-link! [from to]
  "create a highlight! link"
  (hi-link from to true))

(defn highlight [scope fg bg attrs special]
  "create a highlight using a term/gui palette"
  (let [bg (or bg (none))

        attrs (str.join
                ", "
                (a.filter
                  #(= (type $1) "string")
                  (or attrs [none])))

        special (or special [none none])

        fg (if (and (not= (a.first special) none)
                    (= (a.first fg) none)
                    (not (nvim.fn.has "gui_running")))
             special
             fg)

        guifg (.. "guifg='" (a.first fg) "'")
        ctermfg (.. "ctermfg='" (a.second fg) "'")

        guibg (.. "guibg='" (a.first bg) "'")
        ctermbg (.. "ctermbg='" (a.second bg) "'")

        gui (.. "gui='" attrs "'")
        cterm (.. "cterm='" attrs "'")

        guisp (.. "guisp='" (a.first special) "'")]

    (nvim.ex.highlight scope gui cterm guifg ctermfg guibg ctermbg guisp)))

(defn augroup [name cmds]
  (nvim.ex.augroup name)
  (nvim.ex.autocmd_)
  (->>
    cmds
    (r.forEach
      (fn [{: event : pattern : cmd}]
        (nvim.ex.autocmd (.. event " " pattern " " cmd)))))
  (nvim.ex.augroup :END))

(defn autogroup [...]
  (print (.. "Warning: " *module-name* ".autogroup should be " *module-name* ".augroup"))
  (augroup ...))


(defn set-nvim-g! [map]
  (assert (= (type map) "table") (.. "set-nvim-g! expects a table but got a: " (tostring map)))
  (->>
    map
    (r.to-pairs)
    (r.forEach
      (fn [[key val]] (tset nvim.g key val))))
  map)

(defn set-nvim-o! [map]
  (assert (= (type map) "table") (.. "set-nvim-0! expects a table but got a: " (tostring map)))
  (->>
    map
    (r.to-pairs)
    (r.forEach
      (fn [[key val]] (tset nvim.o key val))))
  map)

(defn pack-add [package]
  "add optional package to runtime"
  (nvim.ex.packadd package))
