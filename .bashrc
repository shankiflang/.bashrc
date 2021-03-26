#!/bin/bash
#
# DESCRIPTION:
#
#   Set the bash prompt according to:
#    * the active virtualenv
#    * the branch of the current git/mercurial repository
#    * the return value of the previous command
#
# USAGE:
#
#   1. Save this file as ~/.bash_prompt
#   2. Add the following line to the end of your ~/.bashrc or ~/.bash_profile:
#        . ~/.bash_prompt
#
# LINEAGE:
#
#   Based on work by woods
#
#   https://gist.github.com/31967

# The various escape codes that we can use to color our prompt.
       BLACK="\[\033[0;30m\]"
 LIGHT_BLACK="\[\033[1;30m\]"
         RED="\[\033[0;31m\]"
   LIGHT_RED="\[\033[1;31m\]"
       GREEN="\[\033[0;32m\]"
 LIGHT_GREEN="\[\033[1;32m\]"
      YELLOW="\[\033[33m\]"
LIGHT_YELLOW="\[\033[1;33m\]"
        BLUE="\[\033[0;34m\]"
  LIGHT_BLUE="\[\033[1;34m\]"
      PURPLE="\[\033[0;35m\]"
LIGHT_PURPLE="\[\033[1;35m\]"
        CYAN="\[\033[0;36m\]"
  LIGHT_CYAN="\[\033[1;36m\]"
       WHITE="\[\033[0;37m\]"
 LIGHT_WHITE="\[\033[1;37m\]"
  COLOR_NONE="\[\e[0m\]"

# determine git branch name
function parse_git_branch(){
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

# Determine the branch/state information for this git repository.
function set_git_branch() {
  # Get the name of the branch.
  branch=$(parse_git_branch)

  # Set the final branch string.
  if [[ ! -z "$branch" ]]; then
	  BRANCH=" ${LIGHT_BLACK}(${PURPLE}${branch}${LIGHT_BLACK})${COLOR_NONE} "
  else
	  BRANCH=" "
  fi
}

function set_k8s_namespace() {
  kubectl config view --minify -o jsonpath="{.contexts[0].context.namespace}"
}

function set_k8s_context() {

  kubectl config current-context 2> /dev/null

}

function set_k8s_prompt () {
  CONTEXT=$(set_k8s_context)
  NAMESPACE=$(set_k8s_namespace)
  if [[ ! -z "${NAMESPACE}" ]]; then
	  NAMESPACE="${LIGHT_BLACK}|${LIGHT_CYAN}${NAMESPACE}"
  fi

  if [[ ! -z "${NAMESPACE}" ]] && [[ ! -z "${CONTEXT}" ]]; then
    K8S="${LIGHT_BLACK}[${LIGHT_CYAN}${CONTEXT}${NAMESPACE}${LIGHT_BLACK}]${COLOR_NONE}"
  fi
}

# Return the prompt symbol to use, colorized based on the return value of the
# previous command.
function set_prompt_symbol () {
  #if test $1 -eq 0 ; then
      PROMPT_SYMBOL="\$"
  #else
  #    PROMPT_SYMBOL="${LIGHT_RED}\$${COLOR_NONE}"
  #fi
}

# Determine active Python virtualenv details.
function set_virtualenv () {
  if test -z "$VIRTUAL_ENV" ; then
      PYTHON_VIRTUALENV=""
  else
      PYTHON_VIRTUALENV="${BLUE}[`basename \"$VIRTUAL_ENV\"`]${COLOR_NONE} "
  fi
}

# Set the full bash prompt.
function set_bash_prompt () {
  # Set the PROMPT_SYMBOL variable. We do this first so we don't lose the
  # return value of the last command.
  set_prompt_symbol $?

  # Set the PYTHON_VIRTUALENV variable.
  set_virtualenv

  # Set the BRANCH variable.
  set_git_branch

  # set k8s prompt
  set_k8s_prompt

  # Set the bash prompt variable.
  PS1="
${PYTHON_VIRTUALENV}${GREEN}\u@\h${COLOR_NONE}:${YELLOW}\w${COLOR_NONE}${BRANCH}${K8S}
${PROMPT_SYMBOL} "
}

# Tell bash to execute this function just before displaying its prompt.
PROMPT_COMMAND=set_bash_prompt

alias cl='clear'