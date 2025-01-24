ARG VARIANT="jammy"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# Install system dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
    # Tauri dependencies
    build-essential \
    curl \
    libappindicator3-dev \
    libgtk-3-dev \
    librsvg2-dev \
    libssl-dev \
    libwebkit2gtk-4.1-dev \
    wget \
    # LunarVim dependencies
    python3-dev \
    python3-pip \
    ripgrep \
    fd-find \
    git \
    npm \
    nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Rust properly for Ubuntu 22.04
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install latest Neovim from source
RUN git clone https://github.com/neovim/neovim \
    && cd neovim \
    && make CMAKE_BUILD_TYPE=RelWithDebInfo \
    && make install

USER vscode
WORKDIR /home/vscode

# Install LunarVim nightly for Neovim 0.10.0
RUN bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) --no-install-dependencies
