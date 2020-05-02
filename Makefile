MAKESTER__REPO_NAME = loum

# Tagging convention used: <hadoop-version>-<hive-version>-<image-release-number>
MAKESTER__VERSION = 0.9.0.preview1-3.1.2
MAKESTER__RELEASE_NUMBER = 1

include makester/makefiles/makester.mk
include makester/makefiles/docker.mk
include makester/makefiles/python-venv.mk
include makester/makefiles/k8s.mk

ZEPPELIN_PORT = 18888
MAKESTER__CONTAINER_NAME = zeppelin-hive
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

backoff:
	@$(PYTHON) makester/scripts/backoff -d "Web UI for Zeppelin" -p $(ZEPPELIN_PORT) localhost

controlled-run: run backoff
	@$(shell which xdg-open) http://localhost:$(ZEPPELIN_PORT)

login:
	-@$(DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) bash

help: base-help docker-help python-venv-help k8s-help
	@echo "(Makefile)\n\
  login:               Login to container $(MAKESTER__CONTAINER_NAME) as user \"hdfs\"\n"
