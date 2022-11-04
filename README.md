# In first shell, let's start the cluster and tail the logs
./01_start-vault.sh
podman exec -it [containersha] /usr/bin/tail -f /vault/logs/vault_audit.log

# In second shell, log in as the dev user
export VAULT_TOKEN=$(vault login -format=json -method=okta username=chrisathashicorp+user1@gmail.com | jq -r '.auth.client_token')

# In third shell, log in as the first manager
export VAULT_TOKEN=$(vault login -format=json -method=okta username=chrisathashicorp+manager1@gmail.com | jq -r '.auth.client_token')

# In the fourth shell, log in as the second manager
export VAULT_TOKEN=$(vault login -format=json -method=okta username=chrisathashicorp+manager2@gmail.com | jq -r '.auth.client_token')

# Back in the second shell, as the user, let's create some firmware, and get the pub keys.
# Then, we'll sign the firmware with the development key without having to get approval

dd if=/dev/urandom of=fwup.bin bs=1M count=10

../vault-get-key-pub.sh fw-sign/keys/dev > dev.pub

../vault-get-key-pub.sh fw-sign/keys/prod > prod.pub

../vault-sign.sh fw-sign/sign/dev fwup.bin | base64 -d > fwup.bin.dev.sig 

openssl dgst -sha256 -verify dev.pub -signature fwup.bin.dev.sig fwup.bin

../vault-sign.sh fw-sign/sign/prod fwup.bin

vault write sys/control-group/request accessor=[accessor]
vault write sys/control-group/authorize accessor=[accessor]

vault unwrap [token]

base64 -d <<< "" > fwup.bin.prod.sig

openssl dgst -sha256 -verify prod.pub -signature fwup.bin.prod.sig fwup.bin
