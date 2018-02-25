
# vim:ft=zsh ts=2 sw=2 sts=2

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'
if [[ -z "$PRIMARY_FG" ]]; then
  PRIMARY_FG=black
fi

# Used by vim plugin
MODE_INDICATOR=""

# Characters
SEGMENT_SEPARATOR="\ue0b4"
RSEGMENT_SEPARATOR="\ue0b6"
PLUSMINUS="\u00b1"
BRANCH="\ue0a0"
DETACHED="\u27a6"
CROSS="\u2718"
LIGHTNING="\u26a1"
GEAR="\u2699"
DELTA="\u0394"

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  # when undefined these revert the custom color
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  # if not the first segment and
  # current background is not request background
  # this is to make the next separator's color (a foreground color)
  # in line with the previous background
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    # start using new packground
    # start using previous bg as new foreground
    # separator
    # start using fg color
    print -n "%{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%}"
  else
    print -n "%{$bg%}%{$fg%}"
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && print -n $3
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}$CROSS"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}$LIGHTNING"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}$GEAR"

  [[ -n "$symbols" ]] && prompt_segment $PRIMARY_FG default " $symbols"
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  local user=`whoami`

  if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CONNECTION" ]]; then
    prompt_segment $PRIMARY_FG default " %(!.%{%F{yellow}%}.)$user@%m"
  else
    prompt_segment white red " %(!.%{%F{red}%}.)$DELTA"
  fi
}

# Dir: current working directory
prompt_dir() {
  local wd="$(pwd | sed -e "s,^$HOME,~,")"
  local dir="$(basename $wd)"
  local wdl="$(expr length $wd)"
  if [[ wdl -lt 14  ]]; then
    prompt_segment yellow $PRIMARY_FG " $wd"
  else
    prompt_segment yellow $PRIMARY_FG "../$dir"
  fi
}

prompt_vim() {
  if [[ $KEYMAP = 'viins' ]] || [[ $KEYMAP = 'main' ]]; then
    prompt_segment green black " %{%B%}INSERT%{%b%}"
  elif [[ $KEYMAP = 'vicmd' ]]; then
    prompt_segment blue black " %{%B%}NORMAL%{%b%}"
  else
    prompt_segment red black " $KEYMAP"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  local color ref
  is_dirty() {
    test -n "$(git status --porcelain --ignore-submodules)"
  }
  ref="$vcs_info_msg_0_"
  if [[ -n "$ref" ]]; then
    if is_dirty; then
      color=yellow
      ref="${ref} $PLUSMINUS"
    else
      color=green
      ref="${ref} "
    fi
    if [[ "${ref/.../}" == "$ref" ]]; then
      ref="$BRANCH $ref"
    else
      ref="$DETACHED ${ref/.../}"
    fi
    prompt_segment $color $PRIMARY_FG
    print -n " $ref "
  fi
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    print -n "%{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    print -n "%{%k%}"
  fi
  print -n "%{%f%}"
  CURRENT_BG=''
}

## Main prompt
prompt_agnoster_main() {
  RETVAL=$?
  CURRENT_BG='NONE'
  prompt_status
  prompt_context
  prompt_dir
  prompt_git
  prompt_vim
  prompt_end
}

prompt_agnoster_precmd() {
  vcs_info
  # Make sure KEYMAP is initial set to insert
  # otherwise this is empty
  KEYMAP="viins"
  PROMPT='%{%f%b%k%}$(prompt_agnoster_main) '
}

prompt_agnoster_setup() {
  autoload -Uz add-zsh-hook
  autoload -Uz vcs_info

  prompt_opts=(cr subst percent)

  add-zsh-hook precmd prompt_agnoster_precmd

  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' check-for-changes false
  zstyle ':vcs_info:git*' formats '%b'
  zstyle ':vcs_info:git*' actionformats '%b (%a)'
}

prompt_agnoster_setup "$@"
