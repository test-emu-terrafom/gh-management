# Testing the GitHub EMU Terraform Pipeline

## Prerequisites
1. Personal GitHub organization (free)
2. GitHub App created in your org
3. Azure account (optional - can use local state)

## Setup

1. Copy your GitHub App private key:
   ```bash
   cp ~/Downloads/your-app.pem test/github-app.pem

2. Update `test/terraform.tfvars` with your values
3. Run the test:
```
# From repository root
cd iac

# Use test configuration
terraform init -reconfigure -backend-config=../test/backend.tf
terraform plan -var-file=../test/terraform.tfvars -var="enable_emu_features=false"
terraform apply -var-file=../test/terraform.tfvars -var="enable_emu_features=false"
```

## Clean up
```
terraform destroy -var-file=../test/terraform.tfvars -var="enable_emu_features=false"
```

### 8. .github/workflows/test-local.yml
```yaml
name: Test Workflow (Local)
on:
  workflow_dispatch:
  pull_request:
    paths:
      - 'test/**'
      - 'config/test-resources.json'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
      
      - name: Test Init
        working-directory: ./iac
        run: |
          terraform init -reconfigure -backend-config=../test/backend.tf
      
      - name: Test Validate
        working-directory: ./iac
        run: |
          cp ../config/test-resources.json ../config/github-resources.json
          terraform validate
      
      - name: Test Plan
        working-directory: ./iac
        run: |
          terraform plan \
            -var-file=../test/terraform.tfvars \
            -var="enable_emu_features=false"
```

## How to Test
1. Prepare Test Environment
```
# Clone your repo
git clone <your-repo>
cd terraform-github-emu

# Add test files
mkdir test
# Create the test files above

# Copy your GitHub App key
cp ~/Downloads/your-app.pem test/github-app.pem
```
2. Run Local Test
```
cd iac

# Initialize with test backend
terraform init -reconfigure -backend-config=../test/backend.tf

# Copy test config
cp ../config/test-resources.json ../config/github-resources.json

# Plan with test variables
terraform plan \
  -var-file=../test/terraform.tfvars \
  -var="enable_emu_features=false"

# Apply if plan looks good
terraform apply \
  -var-file=../test/terraform.tfvars \
  -var="enable_emu_features=false"
```
3. Switch Back to Production
```
# Re-initialize with production backend
terraform init -reconfigure

# Use production config
cp ../config/github-resources.json ../config/github-resources.json

# Plan with production variables
terraform plan
```

