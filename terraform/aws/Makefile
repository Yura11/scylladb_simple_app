# Define the shell script path
TERRAGRUNT_RUNNER := ./terragrunt-runner.sh

# Generic Makefile targets
apply+%+%:
	@$(TERRAGRUNT_RUNNER) apply $(word 2, $(subst +, ,$@)) $(word 3, $(subst +, ,$@))

init+%+%:
	@$(TERRAGRUNT_RUNNER) init $(word 2, $(subst +, ,$@)) $(word 3, $(subst +, ,$@))

plan+%+%:
	@$(TERRAGRUNT_RUNNER) plan $(word 2, $(subst +, ,$@)) $(word 3, $(subst +, ,$@))

destroy+%+%:
	@$(TERRAGRUNT_RUNNER) destroy $(word 2, $(subst +, ,$@)) $(word 3, $(subst +, ,$@))
