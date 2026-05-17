locals {
  # 1. Strip out any unintended empty spaces and break the string by commas
  raw_member_list = split(",", replace(var.members, " ", ""))
  
  # Target roles to monitor/strip
  target_roles = ["roles/viewer", "roles/editor"]

  # 2. Sanitize and enforce the "user:" prefix across the parsed array elements
  member_list = [
    for m in local.raw_member_list : "user:${replace(m, "user:", "")}"
  ]

  # 3. Create combinations of all users and all roles
  # Output looks like: [[user1, viewer], [user1, editor], [user2, viewer]...]
  user_role_pairs = setproduct(local.member_list, local.target_roles)

  # 4. If offboarding is true, clear the map completely to trigger an automatic DESTROY plan
  final_role_map = var.is_offboarding ? {} : {
    for pair in local.user_role_pairs : "${pair[0]}-${pair[1]}" => {
      member = pair[0]
      role   = pair[1]
    }
  }
}

resource "google_project_iam_member" "safe_user_offboard" {
  for_each = local.final_role_map

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}