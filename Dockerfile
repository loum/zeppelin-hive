ARG ZEPPELIN_VERSION=0.9.0
ARG ZEPPELIN_HIVE_INTERPRETER_JDBC=/tmp/interpreter/jdbc/hive
ARG UBUNTU_BASE_IMAGE

FROM ubuntu:${UBUNTU_BASE_IMAGE} AS downloader

RUN apt-get update && apt-get install -y --no-install-recommends\
 wget\
 ca-certificates

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG ZEPPELIN_VERSION
RUN wget -qO- "https://apache.mirror.digitalpacific.com.au/zeppelin/zeppelin-${ZEPPELIN_VERSION}/zeppelin-${ZEPPELIN_VERSION}-bin-netinst.tgz" |\
 tar -C /tmp -xzf -

# Add JAR dependencies for Hive.
ARG ZEPPELIN_HIVE_INTERPRETER_JDBC
ARG MAVEN_REPO=https://repo1.maven.org/maven2
RUN mkdir -pv $ZEPPELIN_HIVE_INTERPRETER_JDBC\
 && wget -P $ZEPPELIN_HIVE_INTERPRETER_JDBC ${MAVEN_REPO}/org/apache/hive/hive-jdbc/3.1.2/hive-jdbc-3.1.2.jar\
 && wget -P $ZEPPELIN_HIVE_INTERPRETER_JDBC ${MAVEN_REPO}/org/apache/hive/hive-exec/3.1.2/hive-exec-3.1.2.jar\
 && wget -P $ZEPPELIN_HIVE_INTERPRETER_JDBC ${MAVEN_REPO}/org/apache/hive/hive-service/3.1.2/hive-service-3.1.2.jar\
 && wget -P $ZEPPELIN_HIVE_INTERPRETER_JDBC ${MAVEN_REPO}/org/apache/hive/hive-service-rpc/3.1.2/hive-service-rpc-3.1.2.jar\
 && wget -P $ZEPPELIN_HIVE_INTERPRETER_JDBC ${MAVEN_REPO}/org/apache/hive/hive-common/3.1.2/hive-common-3.1.2.jar\
 && wget -P $ZEPPELIN_HIVE_INTERPRETER_JDBC ${MAVEN_REPO}/org/apache/hive/hive-serde/3.1.2/hive-serde-3.1.2.jar\
 && wget -P $ZEPPELIN_HIVE_INTERPRETER_JDBC ${MAVEN_REPO}/org/apache/curator/curator-client/5.1.0/curator-client-5.1.0.jar\
 && wget -P $ZEPPELIN_HIVE_INTERPRETER_JDBC ${MAVEN_REPO}/org/apache/hadoop/hadoop-common/3.2.1/hadoop-common-3.2.1.jar

COPY files/interpreters/jdbc/hive/interpreter-*.json.j2 /tmp/zeppelin-${ZEPPELIN_VERSION}-bin-netinst/conf/

### downloader layer end

ARG UBUNTU_BASE_IMAGE
FROM ubuntu:${UBUNTU_BASE_IMAGE}

ARG OPENJDK_8_HEADLESS
ARG PYTHON_38
ARG PYTHON_38_PIP
RUN apt-get update && apt-get install -y --no-install-recommends\
 openjdk-8-jdk-headless=${OPENJDK_8_HEADLESS}\
 python3.8=${PYTHON_38}\
 python3-pip=${PYTHON_38_PIP}\
 make\
 && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python3 /usr/bin/python3.8 1

# Run everything as ZEPPELIN_USER
ARG ZEPPELIN_USER=zeppelin
ARG ZEPPELIN_GROUP=zeppelin
RUN addgroup ${ZEPPELIN_GROUP}\
&& adduser --ingroup "${ZEPPELIN_GROUP}" --shell /bin/bash --disabled-password --disabled-login --gecos "" "${ZEPPELIN_USER}"

COPY scripts/zeppelin-bootstrap.sh /zeppelin-bootstrap.sh

USER "${ZEPPELIN_USER}"
WORKDIR "/home/${ZEPPELIN_USER}"

ARG ZEPPELIN_VERSION
COPY --from=downloader --chown="${ZEPPELIN_USER}":"${ZEPPELIN_GROUP}"\
 "/tmp/zeppelin-${ZEPPELIN_VERSION}-bin-netinst/" zeppelin-${ZEPPELIN_VERSION}-bin-netinst
RUN ln -s "zeppelin-${ZEPPELIN_VERSION}-bin-netinst" zeppelin

# Add the JDBC interpreter.
RUN ZEPPELIN_INTERPRETER_DEP_MVNREPO=https://repo1.maven.org/maven2/\
 zeppelin/bin/install-interpreter.sh --name jdbc --artifact "org.apache.zeppelin:zeppelin-jdbc:jar:${ZEPPELIN_VERSION}"

# Now add the HIVE (JDBC) Interpreter dependencies.
# Must follow the JDBC Interpreter installation.
ARG ZEPPELIN_HIVE_INTERPRETER_JDBC
COPY --from=downloader --chown="${ZEPPELIN_USER}":"${ZEPPELIN_GROUP}"\
 "${ZEPPELIN_HIVE_INTERPRETER_JDBC}/*" zeppelin-${ZEPPELIN_VERSION}-bin-netinst/interpreter/jdbc/

# Merge the Hive Interpreter definition into conf/interpreter.json
COPY --chown="${ZEPPELIN_USER}":"${ZEPPELIN_GROUP}" scripts/interpreter-*.py zeppelin/

# Need Jinja2 for Interpreter JIT dynamic settings during container create.
RUN python -V
RUN python -m pip install --user jinja2

CMD [ "/zeppelin-bootstrap.sh" ]
