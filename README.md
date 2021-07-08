# Apache Zeppelin (Hive Interpreter) v0.9.0
- [Overview](#Overview)
- [Quick Links](#Quick-Links)
- [Quick Start](#Quick-Start)
- [Prerequisites](#Prerequisites)
- [Getting Started](#Getting-Started)
- [Getting Help](#Getting-Help)
- [Docker Image Management](#Docker-Image-Management)
  - [Image Build](#Image-Build)
  - [Image Searches](#Image-Searches)
  - [Image Tagging](#Image-Tagging)
- [Interact with Zeppelin as Docker Container](#Interact-with-Zeppelin-as-Docker-Container)

## Overview
[Zeppelin](https://zeppelin.apache.org/docs/0.9.0/) on Docker with minimal capability and Hive Interpreter capability.

> **_NOTE:_** Our custom `hive` interpreter overrides the `zeppelin.jdbc.hive.timeout.threshold` from 1 minute to 20 minutes.  Not sure if it's related to https://issues.apache.org/jira/browse/ZEPPELIN-5146?  Either way, this will hard-limit your query to twenty (20) minutes (as opposed to the default one (1) minute) regardless of the state of your query.  If triggerred, the resultant _"Cancel this job as no more log is produced in the last ?? seconds, maybe it is because no yarn resources"_ is an assumption that is just wrong.  Worse, it manifests in your Spark logs as an obscure `java.lang.NullPointerException: null` error.  I hope this is fixed or its intension made much, much clearer.

## Quick Links
- [Apache Zeppelin](https://zeppelin.apache.org/)

## Quick Start
Impatient and just want Zeppelin with Hive quickly?
```
docker run --rm -d --name zeppelin-hive \
 --env ZEPPELIN_ADDR=0.0.0.0 \
 --env ZEPPELIN_PORT=18888 \
 --env ZEPPELIN_INTERPRETER_DEP_MVNREPO=https://repo1.maven.org/maven2/ \
 --env ZEPPELIN_INTERPRETER_HIVE_DEFAULT_URL=jdbc:hive2://localhost:10000 \
 --publish 18888:18888 \
 --hostname zeppelin-hive \
 --name zeppelin-hive loum/zeppelin-hive:latest
```
## Prerequisites
- [Docker](https://docs.docker.com/install/)
- [GNU make](https://www.gnu.org/software/make/manual/make.html)

## Getting Started
Get the code and change into the top level `git` project directory:
```
git clone https://github.com/loum/zeppelin-hive.git && cd zeppelin-hive.git
```
> **_NOTE:_** Run all commands from the top-level directory of the `git` repository.

For first-time setup, get the [Makester project](https://github.com/loum/makester.git):
```
git submodule update --init
```
Keep [Makester project](https://github.com/loum/makester.git) up-to-date with:
```
make submodule-update
```
Setup the environment:
```
make init
```
## Getting Help
There should be a `make` target to get most things done.  Check the help for more information:
```
make help
```
### Image Build
```
make build-image
```
### Image Searches
Search for existing Docker image tags with command:
```
make search-image
```
### Image Tagging
By default, `makester` will tag the new Docker image with the current branch hash.  This provides a degree of uniqueness but is not very intuitive.  That's where the `tag-version` `Makefile` target can help.  To apply tag as per project tagging convention `<zeppelin-version>-<hive-version>-<image-release-number>`:
```
make tag-version
```
To tag the image as `latest`
```
make tag-latest
```
## Interact with Zeppelin as Docker Container
To start the container and wait for the Zeppelin service to initiate:
```
make controlled-run
```
Browse to http://localhost:[ZEPPELIN_PORT] (`ZEPPELIN_PORT` defaults to `18888`).

In addition to the rich set of environment variables provided by [Apache Zeppelin configuration](https://zeppelin.apache.org/docs/0.9.0/setup/operation/configuration.html) you can also set the Hive interpreter's `default.url` via the custom `ZEPPELIN_INTERPRETER_HIVE_DEFAULT_URL`.  For example, if your Hive server is running on the host named `hive` in port `10000` then set the `ZEPPELIN_INTERPRETER_HIVE_DEFAULT_URL` environment variable with this JDBC URL:
```
  ZEPPELIN_INTERPRETER_HIVE_DEFAULT_URL=jdbc:hive2://hive:10000
```
Use `make`'s `--dry-run` switch see the actual `docker` command that runs:
```
ZEPPELIN_INTERPRETER_HIVE_DEFAULT_URL=jdbc:hive2://hive:10000 --dry--run
```
Sample output:
```
/usr/bin/docker run --rm -d --name zeppelin-hive --env ZEPPELIN_ADDR=0.0.0.0 --env ZEPPELIN_PORT=18888 --env ZEPPELIN_INTERPRETER_DEP_MVNREPO=https://repo1.maven.org/maven2/ --env ZEPPELIN_INTERPRETER_HIVE_DEFAULT_URL=jdbc:hive2://localhost:10000 --publish 18888:18888 --hostname zeppelin-hive --name zeppelin-hive loum/zeppelin-hive:478154a
```
To stop:
```
make stop
```
---
[top](#Apache-Zeppelin-(Hive-Interpreter)-v0.9.0)
