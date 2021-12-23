BASE_DIR = $(realpath .)

all: build

.PHONY: build
build: build-go ## Generate client SDKs

.PHONY: build-go
build-go: .prepare ## Generate golang client
	@mkdir -vp tmp/go
	@docker run --rm \
	  --mount type=bind,source=$(BASE_DIR)/spec,target=/input,readonly \
	  --mount type=bind,source=$(BASE_DIR)/tmp,target=/output \
	  openapitools/openapi-generator-cli:v5.3.1 generate -i /input/swagger.yaml -g go -o /output/go
	@echo
	@echo '!!! IMPORTANT: The generate Golang SDK at $(BASE_DIR)/tmp/go is owned by root !!!'
	@echo

.prepare: ## Prepare build environment
	@mkdir tmp
	@touch .prepare

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'