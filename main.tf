locals {
  # 1. Split and clean spaces
  raw_members = split(",", replace(var.members, " ", ""))
  raw_roles   = split(",", replace(var.roles, " ", ""))

  # 2. Fix Member Prefixes
  member_list = [for m in local.raw_members : "user:${replace(m, "user:", "")}"]

  # 3. FIX ROLE CASE: Force roles to lowercase (e.g., Viewer -> viewer)
  role_list = [for r in local.raw_roles : lower(r)]

  # 4. Create combinations
  user_role_pairs = setproduct(local.member_list, local.role_list)

  # 5. The Offboarding Switch
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