locals {
  # 1. Split the comma strings into lists and strip spaces
  raw_members = split(",", replace(var.members, " ", ""))
  raw_roles   = split(",", replace(var.roles, " ", ""))

  # 2. Force the "user:" prefix onto every member
  # This fixes the "invalid value for member" error
  member_list = [for m in local.raw_members : "user:${replace(m, "user:", "")}"]

  # 3. Create combinations
  user_role_pairs = setproduct(local.member_list, local.raw_roles)

  # 4. The Offboarding Switch
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