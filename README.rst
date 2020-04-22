###########################################
Zeppelin (Hive Interpreter) v0.9.0-preview1
###########################################

`Zeppelin <https://zeppelin.apache.org/docs/0.9.0-preview1/>`_ on Docker with minimal capability and Hive Interpreter capability.

*************
Prerequisites
*************

- `Docker <https://docs.docker.com/install/>`_
- `GNU make <https://www.gnu.org/software/make/manual/make.html>`_

***************
Getting Started
***************

Get the code and change into the top level ``git`` project directory::

    $ git clone https://github.com/loum/hadoop-pseudo.git && cd hadoop-pseudo

.. note::

    Run all commands from the top-level directory of the ``git`` repository.

For first-time setup, get the `Makester project <https://github.com/loum/makester.git>`_::

    $ git submodule update --init

Keep `Makester project <https://github.com/loum/makester.git>`_ up-to-date with::

    $ git submodule update --remote --merge

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

    $ make bi

*********
Image Tag
*********

To tag the image as ``latest``::

    $ make tag

Or to apply tagging convention using ``<zeppelin-version>-<hive-version>-<image-release-number>``::

    $ make tag MAKESTER__IMAGE_TAG=0.9.0.preview1-3.1.2-1

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
