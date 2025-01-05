terraform {
  source = "../../../modules/vpc"
}

locals {
  # Load root variables from root.yaml located in the root directory
  root_variables = yamldecode(file("${get_terragrunt_dir()}/../../../root.yaml"))

  # Load environment-specific variables from dev.yaml located in the same directory as the environment Terragrunt file
  env_variables = yamldecode(file("${get_terragrunt_dir()}/../dev.yaml"))

  # Merge root variables and environment-specific variables
  merged_variables = merge(
    local.root_variables,
    local.env_variables
  )
}

inputs = local.merged_variables
