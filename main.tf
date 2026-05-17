# 1. Fetch the live, current IAM policy from the GCP project
data "google_project_iam_policy" "live_project_policy" {
  project = var.project_id
}

locals {
  # 2. Clean and parse the input string of comma-separated members
  raw_member_list = split(",", replace(var.members, " ", ""))
  target_members  = [for m in local.raw_member_list : "user:${replace(m, "user:", "")}"]

  # 3. Read the live policy data string from GCP and decode it to find actual bindings
  # This creates a flat list of actual user-to-role mappings that exist on the cloud right now
  live_policy_json = jsondecode(data.google_project_iam_policy.live_project_policy.policy_data)
  
  discovered_user_bindings = flatten([
    for binding in lookup(local.live_policy_json, "bindings", []) : [
      for member in lookup(binding, "members", []) : {
        member = member
        role   = binding.role
      } if contains(local.target_members, member)
    ]
  ])

  # 4. If is_offboarding is true, this map drops to {}, triggering a clean DESTROY plan.
  # If false, it dynamically maps only the roles those users ACTUALLY have.
  final_role_map = var.is_offboarding ? {} : {
    for idx, item in local.discovered_user_bindings : "${item.member}-${item.role}" => item
  }
}

resource "google_project_iam_member" "safe_user_offboard" {
  for_each = local.final_role_map

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}