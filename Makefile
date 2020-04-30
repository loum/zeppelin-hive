include makester/makefiles/makester.mk
include makester/makefiles/docker.mk
include makester/makefiles/python-venv.mk
include makester/makefiles/k8s.mk

# Include overrides (must occur before include statements).
MAKESTER__REPO_NAME = loum
MAKESTER__CONTAINER_NAME = zeppelin-hive

ZEPPELIN_PORT = 18888

MAKESTER__RUN_COMMAND := $(DOCKER) run --rm -d\
 --name $(MAKESTER__CONTAINER_NAME)\
 --env ZEPPELIN_ADDR=0.0.0.0\
 --env ZEPPELIN_PORT=$(ZEPPELIN_PORT)\
 --env ZEPPELIN_INTERPRETER_DEP_MVNREPO=https://repo1.maven.org/maven2/\
 --publish $(ZEPPELIN_PORT):$(ZEPPELIN_PORT)\
 --hostname $(MAKESTER__CONTAINER_NAME)\
 --name $(MAKESTER__CONTAINER_NAME)\
 $(MAKESTER__SERVICE_NAME):$(HASH)

init: makester-requirements

login:
	-@$(DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) bash

help: base-help docker-help python-venv-help k8s-help
	@echo "(Makefile)\n\
  login:               Login to container $(MAKESTER__CONTAINER_NAME) as user \"hdfs\"\n"
