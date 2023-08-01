FROM photon:5.0

# set argument defaults
ARG OS_ARCH="amd64"
ARG PACKER_VERSION="1.8.6"
ARG VSPHERE_PLUGIN_VERSION="1.1.1"
ARG ANSIBLE_VERSION="2.14.4"
ARG USER=vlabs
ARG USER_ID=1000
ARG GROUP=users
ARG GROUP_ID=100
#ARG LABEL_PREFIX=com.vmware.eocto

# add metadata via labels
#LABEL ${LABEL_PREFIX}.version="0.0.1"
#LABEL ${LABEL_PREFIX}.git.repo="git@gitlab.eng.vmware.com:sydney/commonpool/containers/packer.git"
#LABEL ${LABEL_PREFIX}.git.commit="DEADBEEF"
#LABEL ${LABEL_PREFIX}.maintainer.name="Richard Croft"
#LABEL ${LABEL_PREFIX}.maintainer.email="rcroft@vmware.com"
#LABEL ${LABEL_PREFIX}.released="9999-99-99"
#LABEL ${LABEL_PREFIX}.based-on="photon:5.0"
#LABEL ${LABEL_PREFIX}.project="containers"

# update repositories
RUN tdnf update -y && \
    tdnf install -y glibc-i18n && \
    tdnf clean all && \
    locale-gen.sh

ENV LOCALE=en_US.utf-8
ENV LC_ALL=en_US.utf-8

# update repositories, install packages, and then clean up
RUN tdnf update -y && \
    # grab what we can via standard packages
    tdnf install -y wget tar git unzip cdrkit openssh python3 python3-pip python3-pyyaml python3-jinja2 python3-xml python3-paramiko python3-resolvelib shadown && \
    # add user/group
    useradd -u ${USER_ID} -m ${USER} && \
    chown -R ${USER_ID}:${GROUP_ID} /home/${USER} && \
    # add /workspace and give user permissions
    mkdir -p /workspace && \
    chown -R ${USER_ID}:${GROUP_ID} /workspace && \
    # set git config
    echo -e "[safe]\n\tdirectory=/workspace" > /etc/gitconfig && \
    # install packer and packer vsphere plugin
    wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_${OS_ARCH}.zip && \
    wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS && \
    sed -i "/.*linux_${OS_ARCH}.zip/!d" packer_${PACKER_VERSION}_SHA256SUMS && \
    sha256sum --check --status packer_${PACKER_VERSION}_SHA256SUMS && \
    unzip packer_${PACKER_VERSION}_linux_${OS_ARCH}.zip -d /bin && \
    packer plugins install github.com/hashicorp/vsphere v${VSPHERE_PLUGIN_VERSION} && \
    rm -f packer_${PACKER_VERSION}_linux_${OS_ARCH}.zip && \
    rm -f packer_${PACKER_VERSION}_SHA256SUMS && \
    # install ansible
    pip3 install ansible-core==${ANSIBLE_VERSION} && \
    pip3 install pywinrm[credssp] && \
    ansible-galaxy collection install ansible.windows && \
    # clean up
    tdnf erase -y python3-pip shadow unzip && \
    tdnf clean all

# set user
USER ${USER}

# set working directory
WORKDIR /workspace

# set entrypoint to packer, not a shell
ENTRYPOINT ["packer"]

#############################################################################
# vim: ft=unix sync=dockerfile ts=4 sw=4 et tw=78:
