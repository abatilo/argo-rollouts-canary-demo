SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

PROJECT_NAME = argo-rollouts-canary-demo

.PHONY: help
help: ## View help information
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

tmp/asdf-installs: .tool-versions ## Install all tools through asdf-vm
	@-mkdir -p $(@D)
	@-asdf plugin-add argo-rollouts https://github.com/abatilo/asdf-argo-rollouts.git || asdf install argo-rollouts
	@-asdf plugin-add golang    || asdf install golang
	@-asdf plugin-add helm      || asdf install helm
	@-asdf plugin-add helmfile  || asdf install helmfile
	@-asdf plugin-add kind      || asdf install kind
	@-asdf plugin-add kubectl   || asdf install kubectl
	@-touch $@

tmp/k8s-cluster: tmp/asdf-installs helmfile.yaml helmfile.lock ## Create a Kubernetes cluster for local development
	@-mkdir -p $(@D)
	@-kind create cluster --name $(PROJECT_NAME)
	@-helmfile sync
	@-touch $@

.PHONY: bootstrap
bootstrap: tmp/asdf-installs tmp/k8s-cluster ## Perform all bootstrapping to start your project

.PHONY: clean
clean: ## Delete local dev environment
	@-rm -rf tmp
	@-kind delete cluster --name $(PROJECT_NAME)

.PHONY: up
up: bootstrap ## Run a local dev environment
	@-docker build -t pingserver:0.0.0 -t pingserver:0.1.0 -t pingserver:rollback -f build/Dockerfile .
	@-kind load docker-image pingserver:0.0.0 --name $(PROJECT_NAME)
	@-kind load docker-image pingserver:0.1.0 --name $(PROJECT_NAME)
	@-kind load docker-image pingserver:rollback --name $(PROJECT_NAME)
	echo "Deploying initial set of pods"
	@-kubectl apply -f deployments/pingserver.yml

.PHONY: deploy
deploy: up ## Perform a deployment with a new version
	@-kubectl argo rollouts set image pingserver pingserver=pingserver:0.1.0

.PHONY: rollback
rollback: up ## Perform a deployment with rollback due to rollback
	@-kubectl apply -f deployments/with-rollback.yml
