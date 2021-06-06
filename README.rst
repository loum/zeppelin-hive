#########################################
Apache Zeppelin (Hive Interpreter) v0.9.0
#########################################

`Zeppelin <https://zeppelin.apache.org/docs/0.9.0/>`_ on Docker with minimal capability and Hive Interpreter capability.

.. note::

  Our custom ``hive`` interpreter overrides the ``zeppelin.jdbc.hive.timeout.threshold`` from 1 minute to 20 minutes.  Not sure if it's related to `<https://issues.apache.org/jira/browse/ZEPPELIN-5146>`_?  Either way, this will hard-limit your query to twenty (20) minutes (as opposed to the default one (1) minute) regardless of the state of your query.  If triggerred, the resultant *"Cancel this job as no more log is produced in the last ?? seconds, maybe it is because no yarn resources"* is an assumption that is just wrong.  Worse, it manifests in your Spark logs as an obscure ``java.lang.NullPointerException: null`` error.  I hope this is fixed or its intension made much, much clearer.

*************
Prerequisites
*************

- `Docker <https://docs.docker.com/install/>`_
- `GNU make <https://www.gnu.org/software/make/manual/make.html>`_

***************
Getting Started
***************

Get the code and change into the top level ``git`` project directory::

  $ git clone https://github.com/loum/zeppelin-hive.git && cd zeppelin-hive.git

.. note::

  Run all commands from the top-level directory of the ``git`` repository.

For first-time setup, get the `Makester project <https://github.com/loum/makester.git>`_::

  $ git submodule update --init

Keep `Makester project <https://github.com/loum/makester.git>`_ up-to-date with::

  $ make submodule-update

Setup the environment::

  $ make init

************
Getting Help
************

There should be a ``make`` target to be able to get most things done.  Check the help for more information::

  $ make help

***********
Image Build
***********

When you are ready to build the image::

  $ make build-image

******************************************
Interact with Zeppelin as Docker Container
******************************************

To start::

  $ make run

Browse to `<http://localhost:[ZEPPELIN_PORT]>`_ (``ZEPPELIN_PORT`` defaults to ``18888``).

In addition to the rich set of environment variables provided by `Apache Zeppelin configuration <https://zeppelin.apache.org/docs/0.9.0/setup/operation/configuration.html>`_ you can also set the Hive interpreter's ``default.url`` via the custom ``ZEPPELIN_INTERPRETER_HIVE_DEFAULT_URL``.  For example, if your Hive server is running on the host named ``hive`` in port ``10000`` then set the ``ZEPPELIN_INTERPRETER_HIVE_DEFAULT_URL`` environment variable with this JDBC URL::

  ZEPPELIN_INTERPRETER_HIVE_DEFAULT_URL=jdbc:hive2://hive:10000

Use ``make``'s ``--dry-run`` switch see the actual ``docker`` command that runs::

  ZEPPELIN_INTERPRETER_HIVE_DEFAULT_URL=jdbc:hive2://hive:10000 --dry--run

Sample output::

  /usr/bin/docker run --rm -d --name zeppelin-hive --env ZEPPELIN_ADDR=0.0.0.0 --env ZEPPELIN_PORT=18888 --env ZEPPELIN_INTERPRETER_DEP_MVNREPO=https://repo1.maven.org/maven2/ --env ZEPPELIN_INTERPRETER_HIVE_DEFAULT_URL=jdbc:hive2://localhost:10000 --publish 18888:18888 --hostname zeppelin-hive --name zeppelin-hive loum/zeppelin-hive:478154a

To stop::

  $ make stop

***********************
Docker Image Management
***********************

Image Searches
==============

Search for existing Docker image tags with command::

  $ make search-image

Image Tagging
=============

By default, ``makester`` will tag the new Docker image with the current branch hash.  This provides a degree of uniqueness but is not very intuitive.  That's where the ``tag-version`` ``Makefile`` target can help

To apply tagging convention using ``<zeppelin-version>-<hive-version>-<image-release-number>``::

  $ make tag-version

To tag the image as ``latest``::

  $ make tag-latest

**********************
Kubernetes Integration
**********************

Try running your Docker image containers in Kubernetes.

Prerequisites
=============

- `Minikube <https://kubernetes.io/docs/tasks/tools/install-minikube/>`_
- `kubectll <https://kubernetes.io/docs/tasks/tools/install-kubectl/>`_
- `kompose <https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/#install-kompose>`_ if you would like to convert `docker-compose.yml` files to Kubernetes manifests

(Optional) Convert existing ``docker-compose.yml`` to Kubernetes Manifests
--------------------------------------------------------------------------

Kubernetes provides the `kompose <https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes>`__ conversion tool that can help you migrate to Kubernetes from ``docker-compose``.  Ensure that your ``docker-compose.yml`` file exists in the top-level directory of your project repository.

To create your Kubernetes manifests::

  $ make konvert

This will deposit the generated Kubernetes manifests under the ``./k8s`` directory.

Create A Local Kubernetes Cluster (Minikube) and Create Resources
-----------------------------------------------------------------

Create a Pod and requires Services taken from manifests under ``./k8s`` directory::

  $ make kube-apply

Interact with Kubernetes Resources
----------------------------------

View the Pods and Services::

  $ make kube-get

Delete the Pods and Services::

  $ make kube-del

Cleanup Kubernetes
------------------

::

  $ make mk-del
