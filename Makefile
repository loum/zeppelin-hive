# Include overrides (must occur before include statements).
MAKESTER__REPO_NAME := loum
MAKESTER__CONTAINER_NAME := zeppelin-hive

include makester/makefiles/makester.mk
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

login:
	-@$(DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) bash

help: base-help docker-help python-venv-help
	@echo "(Makefile)\n\
  login:               Login to container $(MAKESTER__CONTAINER_NAME) as user \"hdfs\"\n"
