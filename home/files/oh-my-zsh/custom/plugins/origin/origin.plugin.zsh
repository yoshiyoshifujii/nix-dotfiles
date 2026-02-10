function urlencode {
  echo "$1" | nkf -WwMQ | tr = %
}

USER_BASE_PATH=$(python -m site --user-base)
export PATH=$PATH:$USER_BASE_PATH/bin

[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

[ -s "$HOME/.jabba/jabba.sh" ] && source "$HOME/.jabba/jabba.sh"

[ -s "$HOME/.cargo" ] && export CARGO_HOME="$HOME/.cargo"
[ -s "$HOME/.cargo" ] && export PATH="$CARGO_HOME/bin:$PATH"

[ -s "${HOME}/.krew" ] && export PATH="${PATH}:${HOME}/.krew/bin"

[ -f "${HOME}/.ghcup/env" ] && . "${HOME}/.ghcup/env" # ghcup-env
