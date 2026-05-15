resource "google_project_iam_member" "user_access" {
  project = var.project_id
  role    = var.role
  member  = var.member
}