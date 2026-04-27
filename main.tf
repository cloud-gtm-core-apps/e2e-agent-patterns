# 1. The Workload Identity Pool and Provider
module "gh_oidc" {
  source      = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id  = "genai-apps-25"
  pool_id     = "aaa-github-pool"
  provider_id = "github-provider"
  
  # DO NOT CHANGE THESE VALUES - They are the translation instructions
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.owner"      = "assertion.repository_owner"
  }

  # HARDCODE YOUR ORG HERE - This protects your project from other GitHub users
  attribute_condition = "assertion.repository_owner == 'cloud-gtm-core-apps'"
}

# 2. The IAM Binding (The "Permissions" link)
resource "google_service_account_iam_member" "wif_binding" {
  # Your specific service account
  service_account_id = "projects/genai-apps-25/serviceAccounts/803095609412-compute@developer.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  
  # Locked specifically to your repository
  member = "principalSet://iam.googleapis.com/projects/803095609412/locations/global/workloadIdentityPools/aaa-github-pool/attribute.repository/cloud-gtm-core-apps/e2e-agent-patterns"
}
