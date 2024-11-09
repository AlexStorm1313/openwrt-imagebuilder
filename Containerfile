FROM fedora:latest

RUN dnf -y update && \ 
    dnf install -y git gawk gettext ncurses-devel zlib-devel openssl-devel libxslt wget which @c-development @development-tools @development-libs zlib-static which python3 perl && \
    dnf -y clean all

# User and permissions, a.k.a. userspace
ARG USER=builder
ARG UUID=1001
ARG GUID=0
ARG HOME_DIR=/home/${USER}

# Add the user
RUN groupadd ${USER} && \
    useradd -g ${USER} ${USER}

# Changing ownership and user rights to support following use-cases:
# 1) running container on OpenShift, whose default security model
#    is to run the container under random UID, but GID=0
# 2) for working root-less container with UID=1001, which does not have
#    to have GID=0
# 3) for default use-case, that is running container directly on operating system,
#    with default UID and GID (1001:0)
# Supported combinations of UID:GID are thus following:
# UID=1001 && GID=0
# UID=<any>&& GID=0
# UID=1001 && GID=<any>
RUN chown -R ${UUID}:${GUID} ${HOME_DIR} && \
    chmod -R g=u ${HOME_DIR}

# Set fixed non-root user for compatibility with Podman/Docker and Kubernetes
USER 1001

WORKDIR ${HOME_DIR}