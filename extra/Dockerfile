FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    sudo \
    gnupg \
    software-properties-common \
    tar \
    gzip \
    curl \
    lsb-release && \
    rm -rf /var/lib/apt/lists/*

# Create group required by MQ script
RUN groupadd mqclient

# Create a non-root user and add to sudoers (useful for post-install commands)
RUN useradd -ms /bin/bash mqadmin && \
    usermod -aG sudo mqadmin && \
    echo "mqadmin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER root

WORKDIR /home/mqadmin

# Copy your install script into the container
COPY mq-ubuntu-install.sh .

# Make it executable (as root)
RUN chmod +x ./mq-ubuntu-install.sh

USER mqadmin

# Run the install script as the user (inside a sudo shell to allow system modifications)
USER root
RUN ./mq-ubuntu-install.sh

# Set user back (optional)
USER mqadmin

CMD [ "bash" ]
