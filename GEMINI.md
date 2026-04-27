# Project Overview
This project establishes a secure, keyless authentication bridge between GitHub Actions and Google Cloud Platform (GCP) using **Workload Identity Federation (WIF)**. It eliminates the need for long-lived service account keys by using short-lived OpenID Connect (OIDC) tokens.

The project consists of:
1.  **Terraform Infrastructure**: Configuration to set up the Workload Identity Pool, OIDC Provider, and IAM bindings.
2.  **GitHub Actions Workflow**: A deployment pipeline that authenticates to GCP via OIDC and deploys a service to **Google Cloud Run**.

## Key Technologies
- **Terraform**: Infrastructure as Code (using `hashicorp/google` and `hashicorp/google-beta` providers).
- **Google Cloud Platform (GCP)**: Workload Identity Federation, IAM, and Cloud Run.
- **GitHub Actions**: Automated CI/CD for cloud deployments.

## Architecture and Components

### 1. Terraform (`main.tf`)
- **Workload Identity Pool & Provider**: Configured via the `terraform-google-modules/github-actions-runners/google//modules/gh-oidc` module.
- **IAM Binding**: Links the GitHub repository (`cloud-gtm-core-apps/e2e-agent-patterns`) to a specific GCP Service Account (`803095609412-compute@developer.gserviceaccount.com`).
- **Security**: Restricted to a specific GitHub organization (`cloud-gtm-core-apps`) via `attribute_condition`.

### 2. GitHub Actions (`.github/workflows/deploy.yml`)
- **Authentication**: Uses `google-github-actions/auth@v2` with the `workload_identity_provider` and `service_account` configured in Terraform.
- **Deployment**: Deploys a Docker image (`us-central1-docker.pkg.dev/genai-apps-25/adk/fast-api-fe:latest`) to Cloud Run (`e2e-agent-service`) in the `us-central1` region.

## Building and Running

### Terraform Commands
To manage the infrastructure:
```bash
# Initialize Terraform and download providers/modules
terraform init

# Preview changes
terraform plan

# Apply changes to GCP
terraform apply
```

### GitHub Actions Deployment
- The deployment workflow is automatically triggered on every push to the `main` branch.
- Ensure the `id-token: write` permission is set in the workflow for OIDC authentication to succeed.

## Development Conventions
- **Infrastructure Safety**: Always run `terraform plan` before `terraform apply` to verify IAM changes.
- **Service Account Permissions**: The service account used for deployment must have the necessary roles (e.g., `roles/run.admin`, `roles/iam.serviceAccountUser`) to deploy to Cloud Run.
- **Configuration**: Critical values like `project_id`, `pool_id`, and `repository_owner` are currently hardcoded in `main.tf` and should be parameterized if this setup is scaled.
