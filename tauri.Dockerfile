# Use the official Rust image as the base image
FROM rust:latest

# Install system dependencies required for building Tauri apps and libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    libwebkit2gtk-4.1-dev \
    libjavascriptcoregtk-4.0-dev \
    libsoup-3.0-dev \
    libgtk-3-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    libxdo-dev \
    build-essential \
    curl \
    wget \
    file \
    libssl-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install a cross-compilation wrapper for pkg-config (if needed for MUSL builds)
RUN echo '#!/bin/sh\nexec pkg-config --define-prefix "$@"' > /usr/local/bin/musl-pkg-config && \
    chmod +x /usr/local/bin/musl-pkg-config

# Set environment variables for pkg-config to support cross-compilation
ENV PKG_CONFIG_ALLOW_CROSS=1
ENV PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/share/pkgconfig
ENV PKG_CONFIG_SYSROOT_DIR=/

# Install the Tauri CLI globally using Cargo
RUN cargo install tauri-cli

# Add Rust targets for cross-compilation
RUN rustup target add x86_64-unknown-linux-musl x86_64-unknown-linux-gnu

# Set the working directory inside the container
WORKDIR /app

# Copy project files into the container
COPY . .

# Default command to build the Tauri app
CMD ["cargo", "tauri", "build"]
