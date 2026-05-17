variable "project_id" {
  type        = string
  description = "The GCP Project ID"
}

variable "member" {
  type        = string
  description = "The user email to completely offboard (e.g., kaavya.kumar@ankercloud.com)"
}

variable "is_offboarding" {
  type        = bool
  default     = false
  description = "Set to true to strip ALL roles from this user"
}