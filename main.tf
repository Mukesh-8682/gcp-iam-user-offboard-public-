resource "null_resource" "total_iam_removal" {
  # This ensures the script runs when the member email is provided
  triggers = {
    member_email = var.member
  }

  provisioner "local-exec" {
    command = <<EOT
      set -e # Exit immediately if a command fails

      # 1. Check if gcloud exists, if not, install it locally
      if ! command -v gcloud &> /dev/null; then
        echo "gcloud not found. Installing local version..."
        curl -sSL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz -o gcloud.tar.gz
        tar -xf gcloud.tar.gz
        export PATH=$PATH:$(pwd)/google-cloud-sdk/bin
      else
        echo "Using existing gcloud installation."
      fi

      echo "Searching for all roles for ${var.member} in project ${var.project_id}..."
      
      # 2. Fetch all roles currently held by the user
      ROLES=$(gcloud projects get-iam-policy ${var.project_id} \
        --flatten="bindings[].members" \
        --filter="bindings.members:${var.member}" \
        --format="value(bindings.role)")

      # 3. Loop through and remove each role one by one
      if [ -z "$ROLES" ]; then
        echo "No roles found for ${var.member}. User might already be removed."
      else
        for role in $ROLES; do
          echo "Removing role: $role"
          gcloud projects remove-iam-policy-binding ${var.project_id} \
            --member="${var.member}" \
            --role="$role" \
            --quiet
        done
        echo "Total removal complete for ${var.member}."
      fi
    EOT
  }
}