# 1. Look up the current IAM policy for the project
data "google_iam_policy" "current_project_policy" {
  project = var.project_id
}

locals {
  # 2. Extract every role that the specific member currently holds
  # This replaces the need for a manual 'roles' variable
  roles_to_manage = [
    for binding in data.google_iam_policy.current_project_policy.bindings :
    binding.role if contains(binding.members, "user:${replace(var.member, "user:", "")}")
  ]

  # 3. If offboarding is true, we create an empty map to delete them
  final_map = var.is_offboarding ? {} : {
    for role in local.roles_to_manage : role => {
      member = "user:${replace(var.member, "user:", "")}"
      role   = role
    }
  }
}

resource "google_project_iam_member" "auto_user_cleanup" {
  for_each = local.final_map

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}