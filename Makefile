.DEFAULT_GOAL := help

MAKESTER__REPO_NAME := loum

ZEPPELIN_VERSION := 0.10.0
HIVE_VERSION := 3.1.2

# Tagging convention used: <hadoop-version>-<hive-version>-<image-release-number>
MAKESTER__VERSION := $(ZEPPELIN_VERSION)-$(HIVE_VERSION)
MAKESTER__RELEASE_NUMBER := 1

MAKESTER__CONTAINER_NAME := zeppelin-hive

include makester/makefiles/makester.mk
include makester/makefiles/docker.mk
include makester/makefiles/python-venv.mk

UBUNTU_BASE_IMAGE := focal-20210921
OPENJDK_8_HEADLESS := 8u292-b10-0ubuntu1~20.04
PYTHON3_VERSION := 3.8.10-0ubuntu1~20.04
PYTHON3_PIP := 20.0.2-5ubuntu1.6

MAKESTER__BUILD_COMMAND = $(DOCKER) build --rm\
 --no-cache\
 --build-arg UBUNTU_BASE_IMAGE=$(UBUNTU_BASE_IMAGE)\
 --build-arg ZEPPELIN_VERSION=$(ZEPPELIN_VERSION)\
 --build-arg HIVE_VERSION=$(HIVE_VERSION)\
 --build-arg OPENJDK_8_HEADLESS=$(OPENJDK_8_HEADLESS)\
 --build-arg PYTHON3_VERSION=$(PYTHON3_VERSION)\
 --build-arg PYTHON3_PIP=$(PYTHON3_PIP)\
 -t $(MAKESTER__IMAGE_TAG_ALIAS) .

ZEPPELIN_ADDR ?= 0.0.0.0
ZEPPELIN_PORT ?= 18888
ZEPPELIN_INTERPRETER_HIVE_DEFAULT_URL ?= jdbc:hive2://localhost:10000
ZEPPELIN_INTERPRETER_DEP_MVNREPO ?= https://repo1.maven.org/maven2/
MAKESTER__RUN_COMMAND := $(DOCKER) run --rm -d\
 --name $(MAKESTER__CONTAINER_NAME)\
 --hostname $(MAKESTER__CONTAINER_NAME)\
 --env ZEPPELIN_ADDR=$(ZEPPELIN_ADDR)\
 --env ZEPPELIN_PORT=$(ZEPPELIN_PORT)\
 --env ZEPPELIN_INTERPRETER_DEP_MVNREPO=$(ZEPPELIN_INTERPRETER_DEP_MVNREPO)\
 --env ZEPPELIN_INTERPRETER_HIVE_DEFAULT_URL=$(ZEPPELIN_INTERPRETER_HIVE_DEFAULT_URL)\
 --publish $(ZEPPELIN_PORT):$(ZEPPELIN_PORT)\
 $(MAKESTER__SERVICE_NAME):$(HASH)

init: clear-env makester-requirements

backoff:
	@$(PYTHON) makester/scripts/backoff -d "Web UI for Zeppelin" -p $(ZEPPELIN_PORT) localhost

controlled-run: run backoff
	@$(shell which xdg-open) http://localhost:$(ZEPPELIN_PORT)

help: makester-help docker-help python-venv-help
	@echo "(Makefile)\n\
  init                 Build the local Python-based virtual environment\n"

.PHONY: help
