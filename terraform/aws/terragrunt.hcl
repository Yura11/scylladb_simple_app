locals {
  backend_configs = {
    dev = {
      bucket         = "scylla_db_simple_app_dev"
      key_prefix     = "dev"
      dynamodb_table = "terraform-lock-table-dev"
      region         = "us-east-1"
    }
    staging = {
      bucket         = "scylla_db_simple_app_stage"
      key_prefix     = "staging"
      dynamodb_table = "terraform-lock-table-staging"
      region         = "us-east-1"
    }
    production = {
      bucket         = "scylla_db_simple_app_prod"
      key_prefix     = "prod"
      dynamodb_table = "terraform-lock-table-prod"
      region         = "us-east-1"
    }
  }

  environment = get_env("TERRAGRUNT_ENV", "dev")
  backend_config = local.backend_configs[local.environment]

  root_config = yamldecode(file("${find_in_parent_folders()}/root.yaml"))

  root_variables = local.root_config

  state_key = "${local.backend_config.key_prefix}/${path_relative_to_include()}/terraform.tfstate"
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

inputs = {
  root_variables = local.root_variables
  environment    = local.environment
}
