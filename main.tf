resource "google_project_iam_member" "user_offboard" {
  project = var.project_id
  role    = "roles/viewer"
  member  = var.member
}