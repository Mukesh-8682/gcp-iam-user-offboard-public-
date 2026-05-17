# 1. Look up the live IAM policy of the project to find the user's roles automatically
data "google_project_iam_policy" "live_policy" {
  project = var.project_id
}

locals {
  # Clean the input email to ensure it has the mandatory "user:" prefix
  clean_member = "user:${replace(var.member, "user:", "")}"

  # Search through the live policy and extract every role assigned to this user
  discovered_roles = [
    for binding in data.google_project_iam_policy.live_policy.bindings :
    binding.role if contains(binding.members, local.clean_member)
  ]

  # If is_offboarding is true, this map becomes empty, triggering total deletion of those roles
  final_role_map = var.is_offboarding ? {} : {
    for r in local.discovered_roles : r => r
  }
}

resource "google_project_iam_member" "auto_role_wipeout" {
  for_each = local.final_role_map

  project = var.project_id
  role    = each.value
  member  = local.clean_member
}