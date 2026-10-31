# Azure Reusable Terraform Modules

A modular Terraform repository for provisioning multi-environment Azure infrastructure (Dev, QA, and Prod). It sets up a secure network baseline, Azure Bastion jump host, Linux virtual machines in private subnets, Network Security Groups, and Azure Public DNS zones/records, all automated through an Azure DevOps CI/CD pipeline.

---

## 📌 What's In This Repo?

Instead of writing monolithic Terraform files, this repository is split into two layers:
1. **Child Modules (`Child module/`)**: Reusable building blocks (Resource Group, VNet, Subnet, Bastion, NSG, VM, DNS). Each module handles one specific resource type using `for_each` maps so you can deploy one or many instances easily.
2. **Root Modules (`Root Module/`)**: Environment configurations (`Dev`, `QA`, `Prod`) that pull in the child modules, pass environment-specific variables, and wire up the infrastructure.

Security is built into the workflow:
- **No direct public IP on the VM**: The Linux VM sits on a private frontend subnet. Admin access is routed strictly through Azure Bastion.
- **Automated security scanning in CI/CD**: The Azure DevOps pipeline runs `gitleaks` (secret scanning), `tfsec` (Terraform misconfiguration scanning), and `tflint` on every pull request/run before any code can be planned or applied.
- **Zero hardcoded credentials**: VM admin credentials are saved in Azure Key Vault and injected dynamically at pipeline runtime via Azure DevOps Variable Groups.

---

## 🏛 Architecture

```text
                                  +---------------------------------------+
                                  |         PUBLIC INTERNET / USER        |
                                  +-------------------+-------------------+
                                                      |
                         +----------------------------+----------------------------+
                         |                                                         |
                         v (Resolve DNS)                                           v (TLS 443 Portal)
              +---------------------+                                     +-----------------+
              |   Azure Public DNS  |                                     |  Azure Bastion  |
              |   (b18g103.online)  |                                     |    (Public IP)  |
              +----------+----------+                                     +--------+--------+
                         |                                                         |
                         v (A Record -> IP)                                        | (SSH tunnel)
              +---------------------+                                              v
              |  Target Endpoint IP |                             +---------------------------------+
              +---------------------+                             |   Virtual Network (10.20.0.0/16)|
                                                                  |                                 |
                                                                  |  +---------------------------+  |
                                                                  |  | AzureBastionSubnet        |  |
                                                                  |  | (10.20.2.0/27)            |  |
                                                                  |  +---------------------------+  |
                                                                  |                                 |
                                                                  |  +---------------------------+  |
                                                                  |  | Dev-Frontend-Subnet       |  |
                                                                  |  | (10.20.1.0/24)            |  |
                                                                  |  |                           |  |
                                                                  |  |   [NSG: dev-nsg]          |  |
                                                                  |  |         |                 |  |
                                                                  |  |         v                 |  |
                                                                  |  |   [NIC: dev-vm-nic]       |  |
                                                                  |  |         |                 |  |
                                                                  |  |         v                 |  |
                                                                  |  |   [Ubuntu Linux VM]       |  |
                                                                  |  +---------------------------+  |
                                                                  +---------------------------------+
```

---

## 📂 Repository Structure

```text
Azure-Reusable-Terraform-Modules/
│
├── Child module/                         # Reusable child modules
│   ├── azurerm_resource_group/           # Resource Group
│   ├── azurerm_virtual_network/          # Virtual Network
│   ├── azurerm_subnet/                   # Subnets (Frontend & Bastion)
│   ├── azurerm_bastion/                  # Bastion Host & Public IP
│   ├── azurerm_NSG/                      # Network Security Groups & Rules
│   ├── azurerm_network_interface/        # VM Network Interface (NIC)
│   ├── azurerm_nsg_nic_association/      # Binds NSG to NIC
│   ├── azurerm_linux_vm/                 # Ubuntu Linux Virtual Machine
│   ├── azurerm_DNS_ZONE/                 # Public DNS Zone
│   ├── azurerm_DNS_RECORD/               # Public DNS A Records
│   └── azurerm_key_vault_secret/         # (Optional) Key Vault secret management
│
├── Root Module/                          # Environment deployments
│   ├── Dev/                              # Development environment
│   │   ├── Provider.tf                   # Backend (azurerm) and provider config
│   │   ├── main.tf                       # Child module calls
│   │   ├── variable.tf                   # Input variable definitions & validations
│   │   └── terraform.tfvars              # Dev configuration values
│   ├── QA/                               # QA environment
│   │   ├── Provider.tf
│   │   ├── main.tf
│   │   ├── variable.tf
│   │   └── terraform.tfvars
│   └── Prod/                             # Production environment
│       ├── Provider.tf
│       ├── main.tf
│       ├── variable.tf
│       └── terraform.tfvars
│
├── .gitleaks.toml                        # Custom secret scanning rules for Gitleaks
├── .gitignore                            # Ignores .terraform/, state files, and logs
├── azure-pipelines.yml                   # Azure DevOps multi-stage CI/CD pipeline
├── LICENSE                               # GPL-3.0 License
└── README.md                             # Documentation
```

---

## 🧱 Module Overview

| Child Module | Purpose | Key Inputs |
| :--- | :--- | :--- |
| **`azurerm_resource_group`** | Creates one or more resource groups | `name`, `location` |
| **`azurerm_virtual_network`** | Creates virtual networks with custom address spaces | `name`, `resource_group_name`, `location`, `address_space` |
| **`azurerm_subnet`** | Provisions workload subnets and `AzureBastionSubnet` | `name`, `resource_group_name`, `virtual_network_name`, `address_prefixes` |
| **`azurerm_bastion`** | Deploys Azure Bastion host with dedicated Standard Public IP | `name`, `name_PIP`, `sku`, `data_subnet`, `virtual_network_name` |
| **`azurerm_network_interface`** | Creates private NIC attached to the workload subnet | `name`, `name_ip_config`, `data_subnet`, `virtual_network_name` |
| **`azurerm_NSG`** | Provisions Network Security Group and rules | `name`, `name_rule`, `priority`, `direction`, `access`, `protocol`, ports |
| **`azurerm_nsg_nic_association`** | Associates the security group with the VM's network interface | `nic_name`, `nsg_name`, `resource_group_name` |
| **`azurerm_linux_vm`** | Deploys an Ubuntu 22.04 LTS VM using credentials passed via variables | `name`, `size`, `nic_name`, `admin_username`, `admin_password` |
| **`azurerm_DNS_ZONE`** | Creates public DNS zones (e.g. `b18g103.online`) | `name`, `resource_group_name` |
| **`azurerm_DNS_RECORD`** | Creates DNS A-records pointing domains to IP addresses | `name`, `dns_zone_name`, `records`, `ttl` |

---

## 🔐 How Secrets & State Are Handled

### 1. Remote State in Azure Blob Storage
Terraform state is stored centrally in an Azure Storage Account with blob lease locking so multiple people/pipelines don't step on each other:
- **Resource Group:** `backend_pipeline`
- **Storage Account:** `pipelinestorageaccount13`
- **Container:** `arjun-tfstate`
- **State Keys:**
  - Dev: `dev.terraform.tfstate`
  - QA: `qa.terraform.tfstate`
  - Prod: `prod.terraform.tfstate`

### 2. Runtime Secret Injection (Zero Hardcoded Passwords)
VM credentials (`admin_username` and `admin_password`) are **not stored in `.tfvars` files**. Instead:
1. Passwords are saved in Azure Key Vault (`pipelinekeyvaultG103`).
2. Azure DevOps Variable Groups (`vg-dev`, `vg-qa`, `vg-prod`) link directly to Azure Key Vault.
3. During pipeline runs, credentials are passed into Terraform via environment variables:
   ```yaml
   env:
     TF_VAR_admin_username: $(adminusername1)
     TF_VAR_admin_password: $(adminpassword1)
   ```

---

## 🚀 How to Run & Deploy

### Option A: Via Azure DevOps Pipeline (Recommended)

The included `azure-pipelines.yml` handles end-to-end testing and deployment:

1. **Stage 1 — Validate & Security Scan:**
   - Runs `terraform fmt -check -recursive`
   - Runs `terraform validate`
   - Runs `tflint` for linting issues
   - Runs `gitleaks` against Git history and working tree using `.gitleaks.toml`
   - Runs `tfsec` to flag high/critical security misconfigurations
   - Publishes reports as build artifacts
2. **Stage 2 — Terraform Plan:**
   - Runs `terraform init` and `terraform plan -out=tfplan` with Key Vault secrets injected
3. **Stage 3 — Manual Approval:**
   - Halts the pipeline and sends an approval prompt to the reviewer (`arjun1@b18g103.online`) to verify the plan before applying
4. **Stage 4 — Deployment:**
   - Runs `terraform apply tfplan` to deploy into the selected environment (`dev`, `qa`, or `prod`)

---

### Option B: Running Locally

If you need to test or deploy directly from your machine:

#### Prerequisites
- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (>= 1.5.0)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) logged in (`az login`)
- TFLint, tfsec, and Gitleaks (if running local scans)

#### 1. Authenticate with Azure
```bash
az login
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
```

#### 2. Choose Your Environment
Change into the target environment folder:
```bash
# For Dev:
cd "Root Module/Dev"

# For QA:
cd "Root Module/QA"

# For Prod:
cd "Root Module/Prod"
```

#### 3. Initialize Terraform
```bash
terraform init
```
> **Tip for QA/Prod:** If you are running locally outside the pipeline, make sure to specify the backend state key so you don't share the Dev state:
> ```bash
> terraform init -backend-config="key=qa.terraform.tfstate"
> ```

#### 4. Validate & Format
```bash
terraform fmt -check
terraform validate
```

#### 5. Plan and Apply
Pass your VM credentials via command line or environment variables:
```bash
# On Windows PowerShell:
$env:TF_VAR_admin_username="your_admin_user"
$env:TF_VAR_admin_password="YourSecurePassword123!"

terraform plan -out=tfplan
terraform apply tfplan
```

#### 6. Clean Up (Teardown)
```bash
terraform destroy
```

---

## 🔍 Validation Rules Built Into the Code

In `variable.tf`, custom validation blocks prevent common configuration mistakes before Azure even receives a request:
- **Resource Group Name Check**: Ensures RG names strictly match `dev-rg`, `qa-rg`, or `prod-rg`.
- **DNS A-Record IP Validation**: Uses `can(cidrnetmask("${ip}/32"))` to ensure all entries in `dns_record` are valid IPv4 addresses.
- **DNS TTL Bounds**: Enforces TTL values between 30 and 86,400 seconds (1 day).
- **Non-Empty String Check**: Verifies that DNS record names, zone names, and resource groups cannot be left blank or whitespace.

---


## 📄 License

This repository is licensed under the [GNU General Public License v3.0](LICENSE).