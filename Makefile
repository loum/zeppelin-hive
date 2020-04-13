# Include overrides (must occur before include statements).
MAKESTER__REPO_NAME := loum
MAKESTER__CONTAINER_NAME := zeppelin-lite

include makester/makefiles/base.mk
include makester/makefiles/docker.mk
include makester/makefiles/python-venv.mk

init: makester-requirements

bi: build-image

build-image:
	@$(DOCKER) build -t $(MAKESTER__SERVICE_NAME):$(HASH) .

rmi: rm-image

rm-image:
	@$(DOCKER) rmi $(MAKESTER__SERVICE_NAME):$(HASH) || true

login:
	@$(DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) bash || true
