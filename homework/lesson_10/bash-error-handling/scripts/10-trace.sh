#!/usr/bin/env bash
PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:-main}: '
set -x
multiply() {
  echo "$(( $1 * $2 ))"
}
multiply 6 7
set +x
