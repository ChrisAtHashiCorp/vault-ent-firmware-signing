#!/bin/bash

set -euo pipefail

if [[ $# -eq 1 ]]; then
  vault read "$1" -format=json | jq -r '[.data.keys | .[].public_key] | .[-1]'
elif [[ $# -eq 2 ]]; then
  vault read "$1" -format=json | jq -r '.data.keys.'\"$2\"'.public_key'
else
  printf "Illegal arguments: usage: vault-get-key-pub.sh keypath [key version]\n"
  exit 1
fi
