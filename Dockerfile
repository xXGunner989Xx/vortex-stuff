FROM ubuntu:bionic

MAINTAINER Udit Subramanya "usubramanya3@gatech.edu"

# Set the working directory to the user's home directory
WORKDIR /root

# Add build-essential, vim, python3, git, tree, wget, python2 and libz-dev packages
RUN apt-get update && \
    apt-get install -y build-essential vim python3 git tree wget python libz-dev

# Copy the setup scripts into the container
COPY entrypoint.sh /usr/local/bin/
COPY ./ci/toolchain_install.sh /usr/local/bin/

# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/toolchain_install.sh

# Create the ~/vortex directory
RUN mkdir vortex

# install toolchain
RUN /usr/local/bin/toolchain_install.sh -all

# Set the entrypoint script as the container's entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]