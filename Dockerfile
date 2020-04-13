FROM ubuntu:bionic-20200311 AS downloader

RUN apt-get update && apt-get install -y --no-install-recommends\
 git\
 maven\
 npm\
 libfontconfig\
 r-base-dev\
 r-cran-evaluate

ARG ZEPPELIN_TAG=v0.9.0-preview1

RUN git clone --depth 1 --branch "${ZEPPELIN_TAG}" https://github.com/apache/zeppelin
WORKDIR /zeppelin
RUN mvn clean package -DskipTests
RUN ls -altr
