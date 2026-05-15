locals {
  # 1. Clean up the strings and split them into lists
  member_list = split(",", replace(var.members, " ", ""))
  role_list   = split(",", replace(var.roles, " ", ""))

  # 2. Create a combined list of user/role pairs
  # Example: [ {user1, role1}, {user1, role2}, {user2, role1}... ]
  user_role_pairs = setproduct(local.member_list, local.role_list)

  # 3. Create a unique map for the for_each loop
  # If is_offboarding is true, this map becomes empty {}, deleting everything.
  final_map = var.is_offboarding ? {} : {
    for pair in local.user_role_pairs : "${pair[0]}-${pair[1]}" => {
      member = pair[0]
      role   = pair[1]
    }
  }
}

resource "google_project_iam_member" "bulk_user_management" {
  for_each = local.final_map

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}