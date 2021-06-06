.DEFAULT_GOAL := help

MAKESTER__REPO_NAME := loum

ZEPPELIN_VERSION := 0.9.0

# Tagging convention used: <hadoop-version>-<hive-version>-<image-release-number>
MAKESTER__VERSION := $(ZEPPELIN_VERSION)-3.1.2
MAKESTER__RELEASE_NUMBER := 1

include makester/makefiles/makester.mk
include makester/makefiles/docker.mk
include makester/makefiles/python-venv.mk
include makester/makefiles/k8s.mk

UBUNTU_BASE_IMAGE := focal-20210416
OPENJDK_8_HEADLESS := 8u292-b10-0ubuntu1~20.04
PYTHON_38 := 3.8.5-1~20.04.3
PYTHON_38_PIP := 20.0.2-5ubuntu1.5

MAKESTER__BUILD_COMMAND = $(DOCKER) build --rm\
 --no-cache\
 --build-arg UBUNTU_BASE_IMAGE=$(UBUNTU_BASE_IMAGE)\
 --build-arg OPENJDK_8_HEADLESS=$(OPENJDK_8_HEADLESS)\
 --build-arg PYTHON_38=$(PYTHON_38)\
 --build-arg PYTHON_38_PIP=$(PYTHON_38_PIP)\
 -t $(MAKESTER__IMAGE_TAG_ALIAS) .

ZEPPELIN_ADDR ?= 0.0.0.0
ZEPPELIN_PORT ?= 18888
ZEPPELIN_INTERPRETER_HIVE_DEFAULT_URL ?= jdbc:hive2://localhost:10000
ZEPPELIN_INTERPRETER_DEP_MVNREPO ?= https://repo1.maven.org/maven2/
MAKESTER__CONTAINER_NAME := zeppelin-hive
MAKESTER__RUN_COMMAND := $(DOCKER) run --rm -d\
 --name $(MAKESTER__CONTAINER_NAME)\
 --env ZEPPELIN_ADDR=$(ZEPPELIN_ADDR)\
 --env ZEPPELIN_PORT=$(ZEPPELIN_PORT)\
 --env ZEPPELIN_INTERPRETER_DEP_MVNREPO=$(ZEPPELIN_INTERPRETER_DEP_MVNREPO)\
 --env ZEPPELIN_INTERPRETER_HIVE_DEFAULT_URL=$(ZEPPELIN_INTERPRETER_HIVE_DEFAULT_URL)\
 --publish $(ZEPPELIN_PORT):$(ZEPPELIN_PORT)\
 --hostname $(MAKESTER__CONTAINER_NAME)\
 --name $(MAKESTER__CONTAINER_NAME)\
 $(MAKESTER__SERVICE_NAME):$(HASH)

init: clear-env makester-requirements

backoff:
	@$(PYTHON) makester/scripts/backoff -d "Web UI for Zeppelin" -p $(ZEPPELIN_PORT) localhost

controlled-run: run backoff
	@$(shell which xdg-open) http://localhost:$(ZEPPELIN_PORT)

login:
	-@$(DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) bash

help: makester-help docker-help python-venv-help k8s-help
	@echo "(Makefile)\n\
  init                 Build the local Python-based virtual environment\n\
  login:               Login to container $(MAKESTER__CONTAINER_NAME) as user \"hdfs\"\n"

.PHONY: help login
