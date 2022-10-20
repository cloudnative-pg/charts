.DEFAULT_GOAL := help

# Credits: https://gist.github.com/prwhite/8168133
.PHONY: help
help: ## Prints help command output
	@awk 'BEGIN {FS = ":.*##"; printf "\ncnpg CLI\nUsage:\n"} /^[$$()% 0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

## Update chart's README.md
.PHONY: docs
docs: ## Generate charts' docs using helm-docs
	helm-docs || \
		(echo "Please, install https://github.com/norwoodj/helm-docs first" && exit 1)

.PHONY: schema
schema: ## Generate charts' schema usign helm schema-gen plugin
	@helm schema-gen charts/cloudnative-pg/values.yaml > charts/cloudnative-pg/values.schema.json || \
		(echo "Please, run: helm plugin install https://github.com/karuppiah7890/helm-schema-gen.git" && exit 1)
	@helm schema-gen charts/cnpg-sandbox/values.yaml > charts/cnpg-sandbox/values.schema.json || \
		(@echo "Please, run: helm plugin install https://github.com/karuppiah7890/helm-schema-gen.git" && exit 1)
	@helm schema-gen charts/pgbench/values.yaml > charts/pgbench/values.schema.json || \
		(@echo "Please, run: helm plugin install https://github.com/karuppiah7890/helm-schema-gen.git" && exit 1)

.PHONY: sandbox-deploy
sandbox-deploy: ## Installs cnpg-sandbox chart
	helm dependency update charts/cnpg-sandbox
	helm upgrade --install cnpg-sandbox --atomic charts/cnpg-sandbox

.PHONY: sandbox-deploy-dev
sandbox-deploy-dev: ## Installs cnpg-sandbox chart with a development version of CNP
	helm dependency update charts/cnpg-sandbox
	helm upgrade --install cnpg-sandbox --set cnpg.enabled=false --atomic charts/cnpg-sandbox

.PHONY: sandbox-uninstall
sandbox-uninstall: ## Uninstalls cnpg-sandbox chart if present
	@helm uninstall cnpg-sandbox
	@kubectl delete cluster cnpg-sandbox

.PHONY: pgbench-deploy
pgbench-deploy: ## Installs pgbench chart
	helm dependency update charts/pgbench
	helm upgrade --install pgbench --atomic charts/pgbench

.PHONY: pgbench-uninstall
pgbench-uninstall: ## Uninstalls cnpg-pgbench chart if present
	@helm uninstall pgbench
