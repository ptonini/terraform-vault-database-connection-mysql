module "user" {
  source  = "ptonini/user/mysql"
  version = "~> 1.1.0"
  name    = "${var.user_name_prefix}-${var.database}"
  grants = {
    "*" = ["SELECT", "INSERT", "UPDATE", "DELETE", "CREATE", "DROP", "RELOAD", "PROCESS", "REFERENCES", "INDEX", "ALTER", "SHOW DATABASES", "CREATE TEMPORARY TABLES", "LOCK TABLES", "EXECUTE", "REPLICATION SLAVE", "REPLICATION CLIENT", "CREATE VIEW", "SHOW VIEW", "CREATE ROUTINE", "ALTER ROUTINE", "CREATE USER", "EVENT", "TRIGGER"]
  }
  providers = {
    mysql = mysql
  }
}

resource "vault_database_secret_backend_connection" "this" {
  name              = var.database
  backend           = try(var.backend.path, var.backend)
  verify_connection = var.verify_connection
  allowed_roles     = var.allowed_roles
  mysql {
    connection_url = "{{username}}:{{password}}@tcp(${var.host}:${var.port})/"
    username       = "${module.user.this.user}${var.login_name_suffix}"
    tls_ca         = var.server_ca
  }
  data = {
    username = "${module.user.this.user}${var.login_name_suffix}"
    password = module.user.password
  }
}

resource "null_resource" "rotate_role_password" {
  triggers = {
    password = module.user.this.plaintext_password
  }
  provisioner "local-exec" {
    command = "VAULT_TOKEN=${var.vault_token} vault write -force ${vault_database_secret_backend_connection.this.backend}/rotate-root/${vault_database_secret_backend_connection.this.name}"
  }
  depends_on = [
    vault_database_secret_backend_connection.this
  ]
}