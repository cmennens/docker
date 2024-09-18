FROM semaphoreui/semaphore:latest

# Switch to root to install required packages
USER root

# Install pip, the WinRM module, and the packaging module
RUN apk update && apk add --no-cache py3-pip \
    && pip install --upgrade pip \
    && pip install pywinrm packaging

# Install the fedora.linux_system_roles collection
RUN ansible-galaxy collection install fedora.linux_system_roles

# Clean up to reduce image size
RUN apk del py3-pip && rm -rf /var/cache/apk/*

# Revert back to semaphore user
USER semaphore
