locals {
  clean_member = "user:${replace(var.member, "user:", "")}"

  # Both sides of the condition now return a clean map structure
  final_role_map = var.is_offboarding ? {} : {
    "roles/viewer" : "roles/viewer",
    "roles/editor" : "roles/editor"
  }
}

resource "google_project_iam_member" "safe_user_offboard" {
  for_each = local.final_role_map

  project = var.project_id
  role    = each.value
  member  = local.clean_member
}