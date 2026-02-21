ARG DEV_PYTHON=3.13.5
FROM python:${DEV_PYTHON}

ARG KUBECTL_VERSION=1.35.0
ARG POPEYE_VERSION=0.22.1
ARG UV_VERSION=0.10.4

# The target platform.
# Some tool installations (like kubectl) need to know whether we're AMD or ARM
# The value will be the platform value used in the build ("linux/amd64" or "linux/arm64")
ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM}

# To fix "unsupported locale"
RUN apt-get update \
    && apt-get install -y locales \
    && echo 'en_GB.UTF-8 UTF-8' > /etc/locale.gen \
    && echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen \
    && locale-gen \
    && dpkg-reconfigure --frontend=noninteractive locales

ENV LANGUAGE=en_GB.UTF-8
ENV LANG=en_GB.UTF-8
ENV LC_ALL=en_GB.UTF-8

# Add a non-root user ("vscode") with sudo support
# https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user
# And attempt to persist command history
# https://code.visualstudio.com/remote/advancedcontainers/persist-bash-history
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID --create-home $USERNAME --shell /bin/bash \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && mkdir /commandhistory \
    && touch /commandhistory/.bash_history \
    && chown -R $USERNAME /commandhistory \
    && echo "$SNIPPET" >> "/home/$USERNAME/.bashrc"

# Install our python requirements, and kubectl
COPY requirements.txt /tmp
RUN pip install -r /tmp/requirements.txt \
    && curl -LO https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGETPLATFORM}/kubectl \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl
# Popeye (ARM or AMD)
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        wget https://github.com/derailed/popeye/releases/download/v${POPEYE_VERSION}/popeye_linux_arm64.tar.gz && \
        tar -xf popeye_linux_arm64.tar.gz; \
    elif [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        wget https://github.com/derailed/popeye/releases/download/v${POPEYE_VERSION}/popeye_linux_amd64.tar.gz && \
        tar -xf popeye_linux_amd64.tar.gz; \
    else \
        exit 112; \
    fi \
    && mv popeye /usr/local/bin \
    && rm LICENSE README.md
# uv
ADD https://astral.sh/uv/${UV_VERSION}/install.sh /uv-installer.sh
RUN apt-get update \
    && apt-get install -y \
        vim \
    && sh /uv-installer.sh \
    && rm /uv-installer.sh \
    && mv /root/.local/bin/uv /usr/local/bin \
    && mv /root/.local/bin/uvx /usr/local/bin \
    && chown -R $USERNAME /usr/local/bin/uv \
    && chown -R $USERNAME /usr/local/bin/uvx
ENV UV_LINK_MODE=copy

USER $USERNAME
