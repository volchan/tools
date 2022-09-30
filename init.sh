#!/bin/bash

SCRIPT=$(readlink -f $0)
TOOLINGPATH=$(dirname $SCRIPT)

function toolsUp() {
  cat <<EOM
function tools-up() {
  (cd $TOOLINGPATH; docker compose up -d \$@)
}
EOM
}

function toolsExec() {
  cat <<EOM
function tools-exec() {
  (cd $TOOLINGPATH; docker compose exec \$@)
}
EOM
}

function toolsRestart() {
  cat <<EOM
function tools-restart() {
  (cd $TOOLINGPATH; docker compose restart \$@)
}
EOM
}

function toolsStop() {
  cat <<EOM
function tools-stop() {
  (cd $TOOLINGPATH; docker compose stop \$@)
}
EOM
}

function toolsDown() {
  cat <<EOM
function tools-down() {
  (cd $TOOLINGPATH; docker compose down \$@)
}
EOM
}

function addFunctions {
  if !(grep -q tools-up ~/.zshrc); then echo "" >>$1 && echo "$(toolsUp)" >/dev/null 2>&1 >>$1; fi
  if !(grep -q tools-exec ~/.zshrc); then echo "" >>$1 && echo "$(toolsExec)" >/dev/null 2>&1 >>$1; fi
  if !(grep -q tools-restart ~/.zshrc); then echo "" >>$1 && echo "$(toolsRestart)" >/dev/null 2>&1 >>$1; fi
  if !(grep -q tools-stop ~/.zshrc); then echo "" >>$1 && echo "$(toolsStop)" >/dev/null 2>&1 >>$1; fi
  if !(grep -q tools-down ~/.zshrc); then echo "" >>$1 && echo "$(toolsDown)" >/dev/null 2>&1 >>$1; fi
}

function startup() {
  echo "🚀 Launching your tooling"
  docker compose up -d
  echo "✅ Done"
}

function doneAddingFunctions() {
  echo "✅ Done installing functions"
}

function setupBash() {
  echo "🤖 Setting up functions in your .bashrc"

  addFunctions ~/.bashrc

  doneAddingFunctions
}

function setupZsh() {
  echo "🤖 Setting up functions in your .zshrc"

  addFunctions ~/.zshrc

  doneAddingFunctions
}

read -p "Which shell are you using ?
  1) Bash
  2) Zsh
> " choice

case $choice in
1) setupBash ;;
2) setupZsh ;;
*) echo "Unrecognized selection: $choice" && exit 0 ;;
esac

startup
exec zsh
