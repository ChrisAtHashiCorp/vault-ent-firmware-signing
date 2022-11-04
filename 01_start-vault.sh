#!/bin/bash

set -euo pipefail

PORT=${2:-'8200'}
VAULT_LICENSE=$(cat /home/vagrant/hashicorp/ent-licenses/vault.hclic)
export VAULT_ADDR=${1:-"http://127.0.0.1:$PORT"}
export VAULT_SKIP_VERIFY=true
export VAULT_TOKEN=${3:-'root'}

podman run -d --rm --cap-add=IPC_LOCK \
          -e "VAULT_DEV_ROOT_TOKEN_ID=$VAULT_TOKEN" \
          -e "VAULT_LICENSE=$VAULT_LICENSE" \
          -p $PORT:$PORT hashicorp/vault-enterprise:latest

sleep 5

# Enable Vault audit logging
vault audit enable file file_path=/vault/logs/vault_audit.log

# Create policies for users and managers
vault policy write users policies/users.hcl
vault policy write managers policies/managers.hcl

# Setup Okta auth engine
# You must have the env variable OKTA_API_TOKEN set for this to work.
OKTA_ORG_NAME="dev-1805200"
OKTA_API_TOKEN=${OKTA_API_TOKEN:-'puttokenhereifnotinenv'}

vault auth enable okta

vault write auth/okta/config org_name="$OKTA_ORG_NAME" api_token="$OKTA_API_TOKEN"

# Setup Okta MFA
ACCESSOR=$(vault auth list -format=json | jq -r '.["okta/"].accessor')

vault write sys/mfa/method/okta/okta_mfa mount_accessor="$ACCESSOR" org_name="$OKTA_ORG_NAME" api_token="$OKTA_API_TOKEN"

# Setup Okta group identities
GROUP_ID=$(vault write identity/group name="managers" policies="managers" type="external" -format=json | jq -r '.data.id')
vault write identity/group-alias name="Managers" mount_accessor="$ACCESSOR" canonical_id="$GROUP_ID"
vault write auth/okta/groups/Managers policies=managers

GROUP_ID=$(vault write identity/group name="users" policies="users" type="external" -format=json | jq -r '.data.id')
vault write identity/group-alias name="Users" mount_accessor="$ACCESSOR" canonical_id="$GROUP_ID"
vault write auth/okta/groups/Users policies=users

# Enable transit secret engine, and add the two keys (dev, prod)
vault secrets enable -path=fw-sign transit

vault write -f fw-sign/keys/dev type=ecdsa-p521
vault write -f fw-sign/keys/prod type=ecdsa-p521
