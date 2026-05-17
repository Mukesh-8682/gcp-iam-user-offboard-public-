locals {
  # Ensures the mandatory "user:" prefix is cleanly formatted
  clean_member = "user:${replace(var.member, "user:", "")}"
}

# This resource is authoritative. If a user is not listed in the members array,
# they are instantly stripped of that role across the entire project.
resource "google_project_iam_binding" "total_role_cleanup" {
  for_each = toset([
    "roles/viewer",
    "roles/editor"
  ])

  project = var.project_id
  role    = each.value

  # Core Logic: If is_offboarding is true, member list is empty [] -> Evicts user.
  # If false, member list holds the user -> Keeps/tracks user.
  members = var.is_offboarding ? [] : [local.clean_member]
}