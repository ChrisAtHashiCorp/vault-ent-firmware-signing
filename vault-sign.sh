#!/bin/bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
  printf "Illegal arguments: usage: vault-sign.sh keypath file\n"
  exit 1
else
  res=$(vault write -format=json "$1" input=$(openssl dgst -sha256 -binary "$2" | base64) hash_algorithm=sha2-256 prehashed=true)
fi

req_id=$(echo $res | jq -r '.request_id')
if [[ -z "$req_id" ]]; then
  echo $res | jq
else
  echo $res | jq -r '.data.signature' | awk -F ":" '{print $3}'
fi
