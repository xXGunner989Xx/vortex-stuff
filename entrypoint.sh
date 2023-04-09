#!/bin/bash

# Vortex container entrypoint
# Primarily handles verilator setup to make our local intallation is recognized gloablly
# Could integrate into ci/toolchain_install.sh hypothetically

if [ ! -d "/opt/verilator" ]
then
    mkdir /opt/verilator
fi

if [ ! -d "/opt/verilator/share" ]
then
    mkdir /opt/verilator/share
fi

if [ ! -d "/opt/verilator/share/verilator" ]
then
    mkdir /opt/verilator/share/verilator
fi

if [ ! -d "/opt/verilator/share/verilator/bin" ]
then
    mkdir /opt/verilator/share/verilator/bin
fi

echo 'export PATH="$PATH:/opt/verilator"' >> /root/.bashrc
echo 'export VERILATOR_ROOT="/opt/verilator"' >> /root/.bashrc
echo 'export PATH="$VERILATOR_ROOT/bin:$PATH"' >> /root/.bashrc

# hack to actually get soruce to run
/bin/bash -c "source ~/.bashrc"

# create the symlinks if they don't already exist
if [ ! -L /opt/verilator/share/verilator/include ]; then
  ln -s /opt/verilator/include /opt/verilator/share/verilator
fi

if [ ! -L /opt/verilator/share/verilator/bin/verilator_includer ]; then
  ln -s /opt/verilator/bin/verilator_includer /opt/verilator/share/verilator/bin
fi

# start bash shell
exec /bin/bash