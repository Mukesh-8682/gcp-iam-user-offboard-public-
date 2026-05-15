resource "null_resource" "api_iam_removal" {
  triggers = {
    member_email = var.member
    force_run    = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
      set -e
      # 1. Get the current IAM Policy
      echo "Fetching current IAM policy..."
      curl -X POST "https://cloudresourcemanager.googleapis.com/v1/projects/${var.project_id}:getIamPolicy" \
        -H "Authorization: Bearer $(gcloud auth print-access-token 2>/dev/null || echo $GOOGLE_OAUTH_ACCESS_TOKEN)" \
        -H "Content-Type: application/json" \
        -d '{}' > policy.json

      # 2. Use python-less manipulation (sed/grep) to strip the user
      # We create a new policy file excluding the specific member
      echo "Removing ${var.member} from policy..."
      sed -i 's/"${var.member}"//g' policy.json
      sed -i 's/,,/,/g; s/\[,/[/g; s/,]/]/g' policy.json 

      # 3. Set the new IAM Policy
      echo "Uploading updated policy..."
      curl -X POST "https://cloudresourcemanager.googleapis.com/v1/projects/${var.project_id}:setIamPolicy" \
        -H "Authorization: Bearer $(gcloud auth print-access-token 2>/dev/null || echo $GOOGLE_OAUTH_ACCESS_TOKEN)" \
        -H "Content-Type: application/json" \
        -d "{ \"policy\": $(cat policy.json) }"
      
      echo "Success: User removed via API."
    EOT
  }
}