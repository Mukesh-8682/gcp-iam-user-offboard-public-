resource "null_resource" "total_user_wipeout" {
  count = var.is_offboarding ? 1 : 0

  triggers = {
    user_to_delete = var.member
  }

  provisioner "local-exec" {
    command = <<EOT
      set -e

      # 1. Format user to match GCP internal policy naming rules
      CLEAN_MEMBER="${var.member}"
      if [[ ! $CLEAN_MEMBER == user:* ]]; then 
        CLEAN_MEMBER="user:$CLEAN_MEMBER"
      fi

      echo "Step 1: Fetching current live IAM policy for ${var.project_id}..."
      
      # Pull down the current live policy JSON using the default runner authentication token
      curl -X POST "https://cloudresourcemanager.googleapis.com/v1/projects/${var.project_id}:getIamPolicy" \
        -H "Authorization: Bearer $(gcloud auth print-access-token 2>/dev/null || echo $GOOGLE_OAUTH_ACCESS_TOKEN)" \
        -H "Content-Type: application/json" \
        -d '{}' > live_policy.json

      echo "Step 2: Scanning and completely erasing $CLEAN_MEMBER from all roles..."
      
      # Use an inline python snippet wrapped in standard shell utilities to safely parse 
      # the json and extract the user out of every single array item cleanly.
      python3 -c "
import json
with open('live_policy.json', 'r') as f:
    policy = json.load(f)

if 'bindings' in policy:
    for binding in policy['bindings']:
        if '$CLEAN_MEMBER' in binding.get('members', []):
            binding['members'].remove('$CLEAN_MEMBER')
            print(f'Removed from role: {binding[\"role\"]}')

with open('clean_policy.json', 'w') as f:
    json.dump(policy, f)
"

      echo "Step 3: Pushing the cleaned policy back to Google Cloud..."
      
      # Submit the modified policy file back to Google Cloud
      curl -X POST "https://cloudresourcemanager.googleapis.com/v1/projects/${var.project_id}:setIamPolicy" \
        -H "Authorization: Bearer $(gcloud auth print-access-token 2>/dev/null || echo $GOOGLE_OAUTH_ACCESS_TOKEN)" \
        -H "Content-Type: application/json" \
        -d "{ \"policy\": $(cat clean_policy.json) }"

      echo "SUCCESS: User has been completely removed from all existing roles!"
    EOT
  }
}