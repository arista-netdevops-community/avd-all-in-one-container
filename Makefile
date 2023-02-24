CURRENT_DIR = $(shell pwd)
DOCKER_NAME ?= avdteam/avd-all-in-one
BRANCH ?= $(shell git symbolic-ref --short HEAD)

.PHONY: help
help: ## Display help message
	@grep -E '^[0-9a-zA-Z_-]+\.*[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Build docker image
	if [ $(BRANCH) = 'master' ]; then \
      docker build --rm --pull -t $(DOCKER_NAME):latest -f $(CURRENT_DIR)/Dockerfile .;\
	else \
	  docker build --rm --pull -t $(DOCKER_NAME):$(BRANCH) -f $(CURRENT_DIR)/Dockerfile .;\
    fi

.PHONY: build_and_push
build_and_push: ## Build docker image
	if [ $(BRANCH) = 'master' ]; then \
      docker build --rm --pull -t $(DOCKER_NAME):latest -f $(CURRENT_DIR)/Dockerfile .;\
	  docker push avdteam/avd-all-in-one:latest;\
	else \
	  docker build --rm --pull -t $(DOCKER_NAME):$(BRANCH) -f $(CURRENT_DIR)/Dockerfile .;\
	  docker push avdteam/avd-all-in-one:$(BRANCH);\
    fi

# Note that there is currently no way to locally load a multi-platform image
# See https://github.com/docker/buildx/issues/59
.PHONY: buildx_and_push
buildx_and_push: ## Build multi-platform docker image
	if [ $(BRANCH) = 'master' ]; then \
	  docker buildx build --push --platform linux/amd64,linux/arm64 --rm --pull -t $(DOCKER_NAME):latest -f $(CURRENT_DIR)/Dockerfile .;\
	else \
	  docker buildx build --push  --platform linux/amd64,linux/arm64 --rm --pull -t $(DOCKER_NAME):$(BRANCH) -f $(CURRENT_DIR)/Dockerfile .;\
    fi

.PHONY: run
run: ## run docker image
	if [ $(BRANCH) = 'master' ]; then \
		docker run --rm -it -v $(CURRENT_DIR)/:/projects \
			-e AVD_GIT_USER="$(shell git config --get user.name)" \
			-e AVD_GIT_EMAIL="$(shell git config --get user.email)" \
			-v /etc/hosts:/etc/hosts $(DOCKER_NAME):latest ;\
	else \
		docker run --rm -it -v $(CURRENT_DIR)/:/projects \
			-e AVD_GIT_USER="$(shell git config --get user.name)" \
			-e AVD_GIT_EMAIL="$(shell git config --get user.email)" \
			-v /etc/hosts:/etc/hosts $(DOCKER_NAME):$(BRANCH) ;\
	fi
