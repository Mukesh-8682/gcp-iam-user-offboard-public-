variable "project_id" {
  type        = string
  description = "The GCP Project ID"
}

variable "members" {
  type        = string
  description = "Comma-separated emails to offboard (e.g., user1@gmail.com, user2@gmail.com)"
}

variable "is_offboarding" {
  type    = bool
  default = false
}