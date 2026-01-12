FROM ghcr.io/void-linux/void-glibc-full:latest

RUN mkdir -p /etc/xbps.d && \
    echo "repository=https://repo-default.voidlinux.org/current" > /etc/xbps.d/00-repository-main.conf

RUN xbps-install -Syu xbps && \
    xbps-install -Syu

RUN xbps-install -Syu \
    bash \
    bash-completion \
    cmake \
    fastfetch \
    git \
    git-lfs \
    github-cli \
    gnupg2 \
    helix \
    libsecret \
    ninja \
    nodejs \
    jupyterlab \
    python \
    ruby \
    rust \
    zsh && \
    xbps-remove -Oy

RUN ln -sf /bin/bash /bin/sh

RUN useradd -m -s /bin/bash codespace && \
    echo "codespace ALL=(root) NOPASSWD:ALL" >> /etc/sudoers.d/codespace && \
    chmod 0440 /etc/sudoers.d/codespace

RUN mkdir -p /home/vscode/.vscode-server /home/vscode/.vscode-server-insiders && \
    chown -R root:root /home/vscode

WORKDIR /workspaces
RUN chown -R codespace:root /workspaces

SHELL ["/bin/bash", "-c"]

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color \
    SHELL=/bin/bash
