variable "admin_username" {
  description = "Username to access Linux VM"
  default     = "azureuser"
}

variable "admin_password" {
  description = "Password to access Linux VM"
  default     = "1234!Password"
}

variable "email" {
  description = "Email for SSL"
  default     = "example@email.com"
}

variable "mysql_host" {
  description = "MySQL Host"
  default     = "db"
}

variable "mysql_user" {
  description = "MySQL User"
  default     = "backend"
}

variable "mysql_password" {
  description = "MySQL Password"
  default     = "password1234"
}

variable "mysql_root_password" {
  description = "MySQL Root Password"
  default     = "password1234"
}

variable "mysql_database" {
  description = "MySQL Database name"
  default     = "tutorials"
}
