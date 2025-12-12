FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    openssh-client \
    sshpass \
    vim \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Ansible and related Python packages
RUN pip install --no-cache-dir \
    ansible \
    ansible-lint \
    jmespath \
    netaddr

# Create working directory
WORKDIR /workspace

# Set up SSH directory
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Disable host key checking for easier development (can be changed for production)
RUN echo "Host *\n    StrictHostKeyChecking no\n    UserKnownHostsFile=/dev/null" > /root/.ssh/config

CMD ["/bin/bash"]
