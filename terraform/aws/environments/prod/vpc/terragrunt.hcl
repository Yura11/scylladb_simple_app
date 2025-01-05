terraform {
  source = "../../../modules/vpc"
}

locals {
  backend_configs = {
    dev = {
      bucket         = "scylladbsimpleappdev"
      key_prefix     = "dev"
      dynamodb_table = "terraform-lock-table-dev"
      region         = "us-east-1"
    }
    stage = {
      bucket         = "scylladbsimpleappstage"
      key_prefix     = "staging"
      dynamodb_table = "terraform-lock-table-staging"
      region         = "us-east-1"
    }
    prod = {
      bucket         = "scylladbsimpleappprod"
      key_prefix     = "prod"
      dynamodb_table = "terraform-lock-table-prod"
      region         = "us-east-1"
    }
  }
  # Load root variables from root.yaml located in the root directory
  root_variables = yamldecode(file("${get_terragrunt_dir()}/../../../root.yaml"))

  # Load environment-specific variables from dev.yaml located in the same directory as the environment Terragrunt file
  env_variables = yamldecode(file("${get_terragrunt_dir()}/../prod.yaml"))

  # Merge root variables and environment-specific variables
  merged_variables = merge(
    local.root_variables,
    local.env_variables
  )

  environment = get_env("TERRAGRUNT_ENV")
  
  backend_config = local.backend_configs[local.environment]

  state_key = "${local.backend_config.key_prefix}/${get_env("TERRAGRUNT_MOD")}/terraform.tfstate"

}
remote_state {
  backend = "s3"
  config = {
    bucket         = local.backend_config.bucket
    key            = local.state_key
    region         = local.backend_config.region
    dynamodb_table = local.backend_config.dynamodb_table
    encrypt        = true
  }
}

inputs = local.merged_variables
