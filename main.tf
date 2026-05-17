locals {
  clean_member = "user:${replace(var.member, "user:", "")}"

  # If offboarding is true, this map becomes empty {}, forcing a clean DESTROY plan
  final_role_map = var.is_offboarding ? {} : toset([
    "roles/viewer",
    "roles/editor"
  ])
}

resource "google_project_iam_member" "safe_user_offboard" {
  for_each = local.final_role_map

  project = var.project_id
  role    = each.value
  member  = local.clean_member
}