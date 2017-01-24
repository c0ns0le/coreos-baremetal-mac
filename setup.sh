#!/bin/bash

# Create a Host Only Adapter 'vboxnet0', similar to the metal0 one generated by coreos-baremetal.
VBoxManage hostonlyif create
VBoxManage hostonlyif ipconfig vboxnet0 --ip 172.18.0.2 --netmask 255.255.255.0
vboxmanage dhcpserver modify --netname HostInterfaceNetworking-vboxnet0 --disable
sudo route -nv add -net 172.18.0.0/24 -interface vboxnet0

# Setup NAT on vboxnet0.
sudo sysctl -w net.inet.ip.forwarding=1

echo 'net.inet.ip.forwarding=1' | sudo tee -a /etc/sysctl.conf > /dev/null
eval echo 'load anchor "com.apple.vboxnet0" from "$(pwd)/etc/pf.conf"' | sudo tee -a /etc/pf.conf > /dev/null

sudo pfctl -e -f /etc/pf.conf 
sudo defaults write /System/Library/LaunchDaemons/com.apple.pfctl ProgramArguments '(pfctl, -f, /etc/pf.conf, -e)'

# Enable iPXE booting for the virtio-net network driver.
eval VBoxManage setextradata global VBoxInternal/Devices/pcbios/0/Config/LanBootRom $(pwd)/assets/virtio-net.rom
