FROM photon:5.0

# set argument defaults
ARG OS_ARCH="amd64"
ARG OS_ARCH2="x86_64"
ARG USER=vlabs
ARG USER_ID=1000
ARG GROUP=users
ARG GROUP_ID=100
#ARG LABEL_PREFIX=net.lab

# # add metadata via labels
# LABEL ${LABEL_PREFIX}.version="0.0.1"
# LABEL ${LABEL_PREFIX}.git.repo="git@github.com:grumpdumpty/packer.git"
# LABEL ${LABEL_PREFIX}.git.commit="DEADBEEF"
# LABEL ${LABEL_PREFIX}.maintainer.name="Richard Croft"
# LABEL ${LABEL_PREFIX}.maintainer.email="rcroft@vmware.com"
# LABEL ${LABEL_PREFIX}.maintainer.url="https://github.com/grumpdumpty"
# LABEL ${LABEL_PREFIX}.released="9999-99-99"
# LABEL ${LABEL_PREFIX}.based-on="photon:5.0"
# LABEL ${LABEL_PREFIX}.project="packer"

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
    tdnf install -y \
        ansible \
        bash \
        ca-certificates \
        cdrkit \
        coreutils \
        curl \
        diffutils \
        gawk \
        git \
        jq \
        ncurses \
        nodejs \
        openssh \
        python3 \
        python3-jinja2 \
        python3-paramiko \
        python3-pip \
        python3-pyyaml \
        python3-resolvelib \
        python3-xml \
        shadow \
        tar \
        unzip \
        vim && \
    # add user/group
    # groupadd -g ${GROUP_ID} ${GROUP} && \
    # useradd -u ${USER_ID} -g ${GROUP} -m ${USER} && \
    useradd -g ${GROUP} -m ${USER} && \
    chown -R ${USER_ID}:${GROUP_ID} /home/${USER} && \
    # add /workspace and give user permissions
    mkdir -p /workspace && \
    chown -R ${USER_ID}:${GROUP_ID} /workspace && \
    # set git config
    git config --system --add safe.directory "/workspace"

# install ansible
RUN pip3 install ansible-core && \
    pip3 install pywinrm[credssp] && \
    ansible-galaxy collection install ansible.windows

# grab packer
RUN PACKER_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/hashicorp/packer/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_${OS_ARCH}.zip && \
    unzip -o -d /usr/local/bin/ packer.zip && \
    chown root:root /usr/local/bin/packer && \
    chmod 0755 /usr/local/bin/packer && \
    rm -f packer.zip

# grab packer vsphere plugin
RUN VSPHERE_PLUGIN_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/hashicorp/packer-plugin-vsphere/releases/latest | jq -r '.tag_name') && \
    packer plugins install github.com/hashicorp/vsphere ${VSPHERE_PLUGIN_VERSION}

# harden and remove unecessary packages
RUN chown -R root:root /usr/local/bin/ && \
    chown root:root /var/log && \
    chmod 0640 /var/log && \
    chown root:root /usr/lib/ && \
    chmod 755 /usr/lib/

# clean up
RUN tdnf erase -y unzip shadow && \
    tdnf clean all

# set user
USER ${USER}

# set working directory
WORKDIR /workspace

# set entrypoint to packer, not a shell
ENTRYPOINT ["packer"]

#############################################################################
# vim: ft=unix sync=dockerfile ts=4 sw=4 et tw=78:
