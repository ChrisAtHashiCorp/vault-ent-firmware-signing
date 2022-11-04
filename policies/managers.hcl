path "fw-sign/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "fw-sign/keys/prod/rotate" {
  capabilities = ["create", "read", "update", "delete", "list"]
  mfa_methods = ["okta_mfa"]
}

path "sys/control-group/authorize" {
  capabilities = ["create", "update"]
  mfa_methods = ["okta_mfa"]
}

path "sys/control-group/request" {
  capabilities = ["create", "update"]
}
