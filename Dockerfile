# Use a slim Debian base image
FROM debian:bullseye-slim

# Set environment variables to prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install sudo, a basic terminal, VNC server, Fluxbox, and noVNC web client
RUN apt-get update && apt-get install -y \
    sudo \
    xterm \
    fluxbox \
    tigervnc-standalone-server \
    novnc \
    websockify \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# === MOVED THESE LINES UP ===
# Copy and set up the entrypoint script (while still root)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# === END OF MOVE ===

# Set default configuration via environment variables
# These can be overridden at runtime
ENV VNC_USER=user
ENV VNC_PW=mypassword
ENV VNC_RESOLUTION=1920x1080

# Create a non-root user and add to sudo group
RUN useradd -m -s /bin/bash -G sudo $VNC_USER && \
    echo "$VNC_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Switch to the new user
USER $VNC_USER
WORKDIR /home/$VNC_USER

# Expose VNC port (for VNC clients) and noVNC port (for web browsers)
EXPOSE 5901
EXPOSE 6901

# Run the entrypoint script when the container starts
ENTRYPOINT ["/entrypoint.sh"]