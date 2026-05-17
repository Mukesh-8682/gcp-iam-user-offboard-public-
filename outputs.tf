output "offboarded_targets" {
  value = [
    # We parse the live decoded JSON policy directly, ignoring if final_role_map is empty or not
    for idx, item in local.discovered_user_bindings : 
    var.is_offboarding ? "WIPED: ${item.member} from ${item.role}" : "TRACKING: ${item.member} -> ${item.role}"
  ]
  description = "The list of users and their corresponding GCP roles processed by this run."
}