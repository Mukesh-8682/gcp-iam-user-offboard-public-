locals {
  roles_to_remove = [] 
}

resource "google_project_iam_member" "user_access" {
  for_each = toset(local.roles_to_remove)

  project = var.project_id
  member  = var.member
  role    = each.value   
}