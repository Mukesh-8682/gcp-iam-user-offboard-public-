variable "project_id" {
  type        = string
  description = "The GCP Project ID"
}

variable "members" {
  type        = string
  description = "Comma-separated emails to dynamically offboard"
}

variable "is_offboarding" {
  type    = bool
  default = false
}