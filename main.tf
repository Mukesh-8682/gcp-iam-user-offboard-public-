resource "null_resource" "total_iam_offboard" {
  # This triggers the script whenever the member email changes
  triggers = {
    member_email = var.member
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "Starting total offboard for ${var.member}..."
      
      # Get all roles for this specific user
      ROLES=$(gcloud projects get-iam-policy ${var.project_id} \
        --flatten="bindings[].members" \
        --filter="bindings.members:${var.member}" \
        --format="value(bindings.role)")

      # Loop through and remove each role
      for role in $ROLES; do
        echo "Removing role: $role"
        gcloud projects remove-iam-policy-binding ${var.project_id} \
          --member="${var.member}" \
          --role="$role" \
          --quiet
      done
      
      echo "Offboarding complete."
    EOT
  }
}