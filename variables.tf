variable "project_id" {
  type = string
}

variable "members" {
  type        = string
  description = "Comma-separated list of users (e.g., user:a@gmail.com,user:b@gmail.com)"
}

variable "roles" {
  type        = string
  description = "Comma-separated list of roles (e.g., roles/viewer,roles/editor)"
}

variable "is_offboarding" {
  type    = bool
  default = false
}