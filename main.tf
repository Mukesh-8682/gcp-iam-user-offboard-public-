resource "null_resource" "total_iam_removal" {
  triggers = {
    member_email = var.member
    # This forces the script to run even if it "succeeded" before
    force_run    = timestamp() 
  }

  provisioner "local-exec" {
    command = <<EOT
      set -e

      # 1. Download gcloud if it's missing (No sudo needed)
      if ! command -v gcloud &> /dev/null; then
        echo "gcloud not found. Downloading CLI..."
        curl -sSL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz -o gcloud.tar.gz
        tar -xf gcloud.tar.gz
        export PATH=$PATH:$(pwd)/google-cloud-sdk/bin
      fi

      echo "Searching for all roles for ${var.member}..."
      
      # 2. Get all roles for the user
      ROLES=$(gcloud projects get-iam-policy ${var.project_id} \
        --flatten="bindings[].members" \
        --filter="bindings.members:${var.member}" \
        --format="value(bindings.role)")

      # 3. Loop and remove
      if [ -z "$ROLES" ]; then
        echo "No roles found. User is likely already gone."
      else
        for role in $ROLES; do
          echo "Removing: $role"
          gcloud projects remove-iam-policy-binding ${var.project_id} \
            --member="${var.member}" \
            --role="$role" \
            --quiet
        done
        echo "Success: User removed from all roles."
      fi
    EOT
  }
}