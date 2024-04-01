module "naming" {
  for_each = local.regions

  source = "Azure/naming/azurerm"
  # prefix"	It is not recommended that you use prefix by azure you should be using a suffix for your resources.

  ## suffix:	It is recommended that you specify a suffix for consistency. please use only lowercase characters when possible	list(string)	[]	no
  suffix = ["${lower(var.prefix)}-${lower(var.environment)}-${lower(local.regions[each.key].short_name)}"]

  ## unique-include-numbers: include numbers in the unique generation	bool. Default	to true

  ## unique-length:	Max length of the uniqueness suffix to be added	number
  # unique-length 

  ## Custom value for the random characters to be used
  unique-seed = 1
}

terraform {

  required_version = ">= 1.7.4"

  required_providers {
    azurerm = {
      # Azure resource manager
      source  = "hashicorp/azurerm"
      version = "~>3.0, < 4.0"
    }
    azuread = {
      # Azure AD (Entra ID)
      source  = "hashicorp/azuread"
      version = "~>2.0, < 3.0"
    }
    azapi = {
      # Azure API Provider - use for Azure resources that are not directly support by the azurerm or azuread providers
      source = "azure/azapi"
    }
    github = {
      # GitHub
      source  = "integrations/github"
      version = "~>6.0, < 7.0"
    }
    random = {
      # Random
      source  = "hashicorp/random"
      version = "~>3.0, < 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3.0, < 4.0"
    }
    time = {
      ## In most cases, this resource should be considered a workaround for issues that should be reported and handled in downstream Terraform Provider logic.
      ## Downstream resources can usually introduce or adjust retries in their code to handle time delay issues for all Terraform configurations or upstream resources
      ## can be improved to better wait for a resource to be fully ready and available.
      source  = "hashicorp/time"
      version = "0.9.1"
    }
    curl = {
      # curl
      source  = "anschoewe/curl"
      version = "1.0.2"
    }
    local = {
      # The Local provider is used to manage local resources, such as files.
      source  = "hashicorp/local"
      version = "2.4.1"
    }
    tls = {
      # working with Transport Layer Security keys and certificates
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    acme = {
      # Letsencrypt certs etc..
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
    cloudinit = {
      # CloudInit
      source  = "hashicorp/cloudinit"
      version = "2.3.2"
    }
  }
}
## Terraform state - comes from command line due GitHub Actions

# This is the "Default" provider for azurerm
provider "azurerm" {
  # The "features" block is required for AzureRM provider 2.x.
  features {
    api_management {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
    template_deployment {
      delete_nested_items_during_deletion = false
    }
    /*
    machine_learning_workspace {
      enable_managed_identity = false
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = false
    }
*/
  }
  skip_provider_registration = true
}

/*
# This provider uses the "prod" alias
provider "azurerm" {
  alias = "prod"
  # The "features" block is required for AzureRM provider 2.x.
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = false
    }
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }
  skip_provider_registration = true
}
*/

# This is the "Default" provider for azuread
provider "azuread" {
  # Configuration options
  use_oidc  = true
  tenant_id = data.azurerm_client_config.current.tenant_id
}

provider "acme" {
  # Configuration options
  // don't use staging endpoint, as it obviously won't work with AKV
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "azapi" {
  # Configuration options
}

provider "cloudinit" {
  # Configuration options
}

provider "tls" {
  # Configuration options
}

provider "github" {
  alias = "organization" // provider = github.organization
  # Configuration options
  owner = var.git_organisation
  token = var.git_organisation_sec
}

provider "github" {
  alias = "individual" // provider = github.individual
  # Configuration options
  owner = "webstean"
  token = var.git_personal_sec
}

provider "github" {
  alias = "current" // provider = github.individual
  owner = var.git_organisation
  token = var.git_organisation_sec
}

provider "time" {
  # Configuration options
}

