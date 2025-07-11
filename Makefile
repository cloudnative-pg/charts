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
schema: cloudnative-pg-schema cluster-schema plugin-barman-cloud ## Generate charts' schema using helm-schema-gen

cloudnative-pg-schema:
	@helm schema-gen charts/cloudnative-pg/values.yaml | cat > charts/cloudnative-pg/values.schema.json || \
		(echo "Please, run: helm plugin install https://github.com/karuppiah7890/helm-schema-gen.git" && exit 1)

cluster-schema:
	@helm schema-gen charts/cluster/values.yaml | cat > charts/cluster/values.schema.json || \
		(echo "Please, run: helm plugin install https://github.com/karuppiah7890/helm-schema-gen.git" && exit 1)

plugin-barman-cloud:
	@helm schema --skip-auto-generation additionalProperties -c charts/plugin-barman-cloud || \
		(echo "Please, run: helm plugin install https://github.com/dadav/helm-schema" && exit 1)
