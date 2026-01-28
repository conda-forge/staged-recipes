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

The build process incorporates the cluster-api provider build logic from the upstream OpenShift installer:
* https://github.com/openshift/installer/blob/main/cluster-api/Makefile
* https://github.com/openshift/installer/blob/main/hack/build.sh
* https://github.com/openshift/installer/blob/main/hack/build-cluster-api.sh

This recipe is Unix-only and builds all cluster-api providers directly using Go build commands.
Windows builds are not supported due to the complexity of the build process
and dependencies on Unix-specific tools.

## Cluster API Build Process

The build script now incorporates the functionality equivalent to the upstream `cluster-api/Makefile`, building all provider binaries directly rather than relying on the makefile.

### Cluster API Providers Built

The following cluster-api provider binaries are built:

- **cluster-api**: The core Cluster API controller binary
- **cluster-api-provider-aws**: AWS infrastructure provider
- **cluster-api-provider-azure**: Azure infrastructure provider
- **cluster-api-provider-azureaso**: Azure Service Operator integration
- **cluster-api-provider-azurestack**: Azure Stack infrastructure provider
- **cluster-api-provider-gcp**: Google Cloud infrastructure provider
- **cluster-api-provider-vsphere**: vSphere infrastructure provider
- **cluster-api-provider-openstack**: OpenStack infrastructure provider
- **cluster-api-provider-nutanix**: Nutanix infrastructure provider
- **cluster-api-provider-ibmcloud**: IBM Cloud infrastructure provider

### Build Implementation

The build script (`build.sh`) directly implements the equivalent of:
```make
make -C cluster-api go-build
```

Each provider is built using individual `go build` commands with the same flags and output paths as the upstream Makefile:
- **GCFLAGS**: Compilation flags (empty for release builds)
- **LDFLAGS**: Link flags ("-s -w" for stripped binaries)
- **TARGET_OS_ARCH**: Target platform (e.g., "linux_amd64")

All binaries are placed in `bin/$TARGET_OS_ARCH/` and packaged into a single `cluster-api.zip` file.

### How It's Used in the Installer
The OpenShift installer **embeds these binaries** using Go's `embed` directive and extracts the appropriate Cluster API provider binaries at runtime based on:
- The target cloud platform (AWS, Azure, GCP, etc.)
- The target architecture (linux_amd64, darwin_arm64, etc.)

These binaries are then used to provision and manage the underlying infrastructure resources (VMs, networks, load balancers, etc.) that OpenShift needs.

The OpenShift installer uses Cluster API as its infrastructure provisioning layer, embedding pre-built provider binaries that handle infrastructure lifecycle management in a standardized way.
