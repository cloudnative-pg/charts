.DEFAULT_GOAL := help

# behave identically regardless of the caller's working directory
PROJECT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
LOCALBIN    ?= $(PROJECT_DIR)/bin
# renovate: datasource=github-releases depName=norwoodj/helm-docs
HELM_DOCS_VERSION ?= v1.14.2
# renovate: datasource=github-releases depName=dadav/helm-schema
HELM_SCHEMA_VERSION ?= 0.23.4
HELM_SCHEMA_FLAGS ?= -a --no-dependencies --skip-auto-generation title,required,additionalProperties

# Credits: https://gist.github.com/prwhite/8168133
.PHONY: help
help: ## Prints help command output
	@awk 'BEGIN {FS = ":.*##"; printf "\ncnpg CLI\nUsage:\n"} /^[$$()% 0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

## Update chart's README.md
.PHONY: docs
docs: helm-docs ## Generate charts' docs using helm-docs
	@$(HELM_DOCS) --skip-version-footer

.PHONY: schema
schema: cloudnative-pg-schema cluster-schema plugin-barman-cloud-schema ## Generate charts' schema using helm-schema

cloudnative-pg-schema: helm-schema
	@$(HELM_SCHEMA) $(HELM_SCHEMA_FLAGS) -c charts/cloudnative-pg

cluster-schema: helm-schema
	@$(HELM_SCHEMA) $(HELM_SCHEMA_FLAGS) -c charts/cluster

plugin-barman-cloud-schema: helm-schema
	@$(HELM_SCHEMA) $(HELM_SCHEMA_FLAGS) -c charts/plugin-barman-cloud

.PHONY: helm-schema
HELM_SCHEMA = $(LOCALBIN)/helm-schema
helm-schema: ## Download helm-schema locally if necessary.
	$(call go-install-tool,$(HELM_SCHEMA),github.com/dadav/helm-schema/cmd/helm-schema@$(HELM_SCHEMA_VERSION))

.PHONY: helm-docs
HELM_DOCS = $(LOCALBIN)/helm-docs
helm-docs: ## Download helm-docs locally if necessary.
	$(call go-install-tool,$(HELM_DOCS),github.com/norwoodj/helm-docs/cmd/helm-docs@$(HELM_DOCS_VERSION))

# go-install-tool will 'go install' any package $2 and install it to $1.
define go-install-tool
@[ -f $(1) ] || { \
set -e ;\
echo "Downloading $(2)" ;\
GOBIN=$(LOCALBIN) go install $(2) ;\
}
endef
