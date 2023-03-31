FROM photon:4.0

# set argument defaults
ARG OS_ARCH="amd64"
ARG PACKER_VERSION="1.8.6"
ARG VSPHERE_PLUGIN_VERSION="1.1.1"
ARG ANSIBLE_VERSION="2.14.4"
ARG LABEL_PREFIX=com.vmware.eocto

# add metadata via labels
LABEL ${LABEL_PREFIX}.version="0.0.1"
LABEL ${LABEL_PREFIX}.git.repo="git@gitlab.eng.vmware.com:sydney/commonpool/containers/packer.git"
LABEL ${LABEL_PREFIX}.git.commit="DEADBEEF"
LABEL ${LABEL_PREFIX}.maintainer.name="Richard Croft"
LABEL ${LABEL_PREFIX}.maintainer.email="rcroft@vmware.com"
LABEL ${LABEL_PREFIX}.released="9999-99-99"
LABEL ${LABEL_PREFIX}.based-on="photon:4.0"
LABEL ${LABEL_PREFIX}.project="commonpool"

# set working to user's home directory
WORKDIR ${HOME}

# update repositories
RUN tdnf update -y && \
    tdnf install -y glibc-i18n && \
    tdnf clean all && \
    locale-gen.sh

ENV LOCALE=en_US.utf-8
ENV LC_ALL=en_US.utf-8

# Install packages, packer, packer-vsphere, ansible & ansible.windows
RUN tdnf update -y && \
    tdnf install -y wget tar git unzip cdrkit openssh python3 python3-pip python3-pyyaml python3-jinja2 python3-xml python3-paramiko python3-resolvelib && \
    wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_${OS_ARCH}.zip && \
    wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS && \
    sed -i "/.*linux_amd64.zip/!d" packer_${PACKER_VERSION}_SHA256SUMS && \
    sha256sum --check --status packer_${PACKER_VERSION}_SHA256SUMS && \
    unzip packer_${PACKER_VERSION}_linux_${OS_ARCH}.zip -d /bin && \
    packer plugins install github.com/hashicorp/vsphere v${VSPHERE_PLUGIN_VERSION} && \
    rm -f packer_${PACKER_VERSION}_linux_${OS_ARCH}.zip && \
    rm -f packer_${PACKER_VERSION}_SHA256SUMS && \
    pip3 install ansible-core==${ANSIBLE_VERSION} && \
    pip3 install pywinrm[credssp] && \
    ansible-galaxy collection install ansible.windows && \
    tdnf erase -y python3-pip && unzip && \
    tdnf clean all

# set entrypoint to terraform, not a shell
ENTRYPOINT ["packer"]

#############################################################################
# vim: ft=unix sync=dockerfile ts=4 sw=4 et tw=78:
