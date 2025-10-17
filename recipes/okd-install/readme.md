# OKD Installer

This recipe is based on:
* https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.19.15/openshift-installer-src.tar.gz
* https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/installing_on_bare_metal/preparing-to-install-on-bare-metal
* https://github.com/okd-project/okd/releases
* https://github.com/openshift/installer

## Overview

The openshift-installer is the command-line utility used to deploy and
install Red Hat OpenShift Container Platform on various cloud providers
(like AWS, Azure, Google Cloud) or
on-premises infrastructure (like vSphere or bare metal).

## Key Functions

Deployment Automation::
It automates the complex process of provisioning the necessary infrastructure
(virtual machines, networking, load balancers, etc.) and then installing the complete OpenShift cluster on top of it.

Configuration Management::
It uses an install-config.yaml file to define the cluster's parameters,
such as the cloud provider, region, cluster name, SSH key, pull secret, and the size and number of worker nodes.

Infrastructure Provisioning::
For "installer-provisioned infrastructure" (IPI) installations,
the installer manages the entire lifecycle of the underlying infrastructure, creating and configuring it as needed.

Simplified Experience::
It aims to provide a reliable, repeatable, and
relatively straightforward way to set up a production-ready OpenShift cluster,
abstracting away many of the underlying infrastructure complexities.

## Build Notes

The build uses the existing bash script from the source:
* https://github.com/openshift/installer/blob/main/hack/build.sh
* https://github.com/openshift/installer/blob/main/hack/build-cluster-api.sh

This recipe is Unix-only and uses the upstream build scripts directly.
Windows builds are not supported due to the complexity of the build process
and dependencies on Unix-specific tools.
