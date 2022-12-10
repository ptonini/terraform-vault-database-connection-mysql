variable "host" {}

variable "port" {
  default = 3306
}

variable "database" {}

variable "backend" {}

variable "server_ca" {
  default = null
}

variable "verify_connection" {
  default = true
}

variable "allowed_roles" {
  type    = list(string)
  default = null
}

variable "user_name_prefix" {
  default = "vault"
}

variable "login_name_suffix" {
  default = ""
}

variable "skip_reassign_owned" {
  default = true
}