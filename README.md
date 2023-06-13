# Container Image for HashiCorp Packer and Ansible

## Overview

Provides a container image for running HashiCorp Packer and Ansible.

This image includes the following components:

| Component                        | Version | Description                                                                                              |
|----------------------------------|---------|----------------------------------------------------------------------------------------------------------|
| VMware Photon OS                 | 4.0     | A Linux container host optimized for vSphere and cloud-computing platforms.                              |
| Ansible                          | 2.12.7  | A suite of software tools that enables infrastructure as code.                                           |
| HashiCorp Packer                 | 1.8.6   | Packer is an open source image creation tool.                                                            |
| Packer Plugin for VMware vSphere | 1.1.1   | Packer Plugin that uses the vSphere API to creates virtual machines remotely, starting from an ISO file. |

## Get Started

Run the following to download the latest container from Docker Hub:

```bash
docker pull harbor.sydeng.vmware.com/rcroft/packerplus:latest
```

Run the following to download a specific version from Docker Hub:

```bash
docker pull harbor.sydeng.vmware.com/rcroft/packerplus:x.y.z
```

Open an interactive terminal:

```bash
docker run --rm -it harbor.sydeng.vmware.com/rcroft/packerplus console
```

Run a local plan:

```bash
 cd /path/to/tf/files
docker run --rm -it --name packer -v $(pwd):/tmp -w /tmp harbor.sydeng.vmware.com/rcroft/packerplus init
docker run --rm -it --name packer -v $(pwd):/tmp -w /tmp harbor.sydeng.vmware.com/rcroft/packerplus validate
docker run --rm -it --name packer -v $(pwd):/tmp -w /tmp harbor.sydeng.vmware.com/rcroft/packerplus fmt
docker run --rm -it --name packer -v $(pwd):/tmp -w /tmp harbor.sydeng.vmware.com/rcroft/packerplus build
```

Where `/path/to/tf/files` is the local path for your packer scripts.

## Variables

### Harbor Variables

These can be set at any level but we generally set them at the group or project level.

| Variable        | Value                                                                           |
|-----------------|---------------------------------------------------------------------------------|
| HARBOR_HOST     | hostname of harbor instance, no `http://` or `https://`                         |
| HARBOR_CERT     | PEM format certificate with each `\n` (actual char) replaced with `"\n"` string |
|                 | Run the following command:                                                      |
|                 | `cat harbor.crt \| sed -E '$!s/$/\\n/' \| tr -d '\n'`                           |
|                 | where `harbor.crt`                                                              |
| HARBOR_USER     | Username of harbor user with permissions to push images                         |
| HARBOR_EMAIL    | Email  of harbor user with permissions to push images                           |
| HARBOR_PASSWORD | Password of harbor user with permissions to push images                         |

### GitLab Variables

| GitLab Env Var            | Value |
|---------------------------|-------|
| CI_COMMIT_AUTHOR          |       |
| CI_COMMIT_BRANCH          |       |
| CI_COMMIT_SHA             |       |
| CI_COMMIT_SHORT_SHA       |       |
| CI_COMMIT_TIMESTAMP       |       |
| CI_PAGES_DOMAIN           |       |
| CI_PAGES_URL              |       |
| CI_PIPELINE_CREATED_AT    |       |
| CI_PROJECT_DIR            |       |
| CI_PROJECT_NAME           |       |
| CI_PROJECT_NAMESPACE      |       |
| CI_PROJECT_PATH           |       |
| CI_PROJECT_PATH_SLUG      |       |
| CI_PROJECT_ROOT_NAMESPACE |       |
| CI_PROJECT_TITLE          |       |
| CI_PROJECT_URL            |       |
| CI_SERVER_HOST            |       |
| CI_SERVER_PORT            |       |
| CI_SERVER_PROTOCOL        |       |
| CI_SERVER_URL             |       |
| CI_TEMPLATE_REGISTRY_HOST |       |
| GITLAB_USER_EMAIL         |       |
| GITLAB_USER_LOGIN         |       |
| GITLAB_USER_NAME          |       |
