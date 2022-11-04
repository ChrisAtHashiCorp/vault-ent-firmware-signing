path "fw-sign/keys/*" {
  capabilities = ["list", "read"]
}

path "fw-sign/sign/dev" {
  capabilities = ["create", "read", "update", "list"]
}

path "fw-sign/verify/dev" {
  capabilities = ["create", "read", "update", "list"]
}

path "fw-sign/sign/prod" {
  capabilities = ["create", "read", "update", "list"]

  control_group = {
    factor "authorizer" {
      identity {
        group_names = ["managers"]
          approvals = 2
      }
    }
  }
}

path "fw-sign/verify/prod" {
  capabilities = ["create", "read", "update", "list"]
}
