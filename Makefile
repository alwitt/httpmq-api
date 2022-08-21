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
	  openapitools/openapi-generator-cli:v6.0.1 \
	    generate -i /input/swagger.yaml -g go -o /output/go --package-name api
	@echo
	@echo '!!! IMPORTANT: The generated Golang SDK at $(BASE_DIR)/tmp/go is owned by root !!!'
	@echo

.PHONY: build-cpp
build-cpp: .prepare ## Generate C++ client using MS cpprestsdk
	@mkdir -vp tmp/cpp
	@docker run --rm \
	  --mount type=bind,source=$(BASE_DIR)/spec,target=/input,readonly \
	  --mount type=bind,source=$(BASE_DIR)/tmp,target=/output \
	  openapitools/openapi-generator-cli:v6.0.1 \
	    generate -i /input/swagger.yaml -g cpp-restsdk -o /output/cpp --package-name httpmq --additional-properties apiPackage=httpmq.client.api,modelPackage=httpmq.client.model
	@echo
	@echo '!!! IMPORTANT: The generated C++ SDK at $(BASE_DIR)/tmp/cpp is owned by root !!!'
	@echo

.PHONY: build-python
build-python: .prepare ## Generate python client using urllib3
	@mkdir -vp tmp/python
	@docker run --rm \
	  --mount type=bind,source=$(BASE_DIR)/spec,target=/input,readonly \
	  --mount type=bind,source=$(BASE_DIR)/tmp,target=/output \
	  openapitools/openapi-generator-cli:v6.0.1 \
	    generate -i /input/swagger.yaml -g python-aiohttp -o /output/python --package-name httpmq
	@echo
	@echo '!!! IMPORTANT: The generated Python SDK at $(BASE_DIR)/tmp/python is owned by root !!!'
	@echo

.prepare: ## Prepare build environment
	@mkdir tmp
	@touch .prepare

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
