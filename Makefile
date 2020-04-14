# Include overrides (must occur before include statements).
MAKESTER__REPO_NAME := loum
MAKESTER__CONTAINER_NAME := zeppelin-hive

include makester/makefiles/base.mk
include makester/makefiles/docker.mk
include makester/makefiles/python-venv.mk

MAKESTER__RUN_COMMAND := $(DOCKER) run --rm -d\
 --name $(MAKESTER__CONTAINER_NAME)\
 --env ZEPPELIN_ADDR=0.0.0.0\
 --env ZEPPELIN_PORT=18888\
 --env ZEPPELIN_INTERPRETER_DEP_MVNREPO=https://repo1.maven.org/maven2/\
 --publish 18888:18888\
 --hostname $(MAKESTER__CONTAINER_NAME)\
 --name $(MAKESTER__CONTAINER_NAME)\
 $(MAKESTER__SERVICE_NAME):$(HASH)

init: makester-requirements

bi: build-image

build-image:
	@$(DOCKER) build -t $(MAKESTER__SERVICE_NAME):$(HASH) .

rmi: rm-image

rm-image:
	@$(DOCKER) rmi $(MAKESTER__SERVICE_NAME):$(HASH) || true

login:
	@$(DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) bash || true

help: base-help docker-help python-venv-help
	@echo "(Makefile)\n\
  build-image:         Build docker image $(MAKESTER__SERVICE_NAME):$(HASH) (alias bi)\n\
  rm-image:            Delete docker image $(MAKESTER__SERVICE_NAME):$(HASH) (alias rmi)\n\
  login:               Login to container $(MAKESTER__CONTAINER_NAME) as user \"hdfs\"\n"
