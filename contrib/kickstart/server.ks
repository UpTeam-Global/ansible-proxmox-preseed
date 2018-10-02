#version=RHEL7
install
text
lang en_US.UTF-8
keyboard en
timezone UTC
auth --useshadow --passalgo=sha256
firewall --disabled
services --enabled=sshd
eula --agreed

%pre
#!/bin/bash
DISK=$(lsblk --output NAME,TYPE | grep disk | head -n1 | cut -d" " -f1)
cat > /tmp/setup << EOF
ignoredisk --only-use=$DISK
clearpart --drives=$DISK --all --initlabel
bootloader --location=mbr --boot-drive=$DISK
zerombr
part swap --asprimary --fstype="swap" --ondisk=$DISK --recommended
part /boot --fstype ext4 --ondisk=$DISK --recommended
part / --fstype ext4 --ondisk=$DISK --size 8192 --grow
EOF

NET_CFG=$(grep -oE 'net_cfg=#.*#' < /proc/cmdline)
HOST_NAME=${HOST_NAME##*=}
if [ ! -z "$NET_CFG" ]; then
  NET_CFG=${NET_CFG#*=}
  echo "${NET_CFG//#/}" >> /tmp/setup
fi

ACTION=$(grep -oE 'action=[a-z]+' < /proc/cmdline)
if [ -z "$ACTION" ]; then
  echo "poweroff" >> /tmp/setup
else
  case "${ACTION##*=}" in
    "reboot")
      echo "${ACTION##*=}" >> /tmp/setup
    ;;
    *)
      echo "poweroff" >> /tmp/setup
    ;;
  esac
fi
%end

%include /tmp/setup

rootpw --plaintext centos

## repos
repo --name=updates --baseurl=http://ftp.hosteurope.de/mirror/centos.org/7/updates/x86_64/
repo --name=extras --baseurl=http://ftp.hosteurope.de/mirror/centos.org/7/extras/x86_64/
repo --name=epel --baseurl=https://dl.fedoraproject.org/pub/epel/7/x86_64/

## network install mirror
url --url="http://ftp.hosteurope.de/mirror/centos.org/7/os/x86_64/"

%packages --ignoremissing --excludedocs
@core --nodefaults
bash-completion
epel-release
deltarpm
-NetworkManager*
-aic94xx-firmware*
#-alsa-*
-iwl*firmware
-ql*firmware
-ivtv*
-plymouth*
-kexec-tools
-dracut-network
#-btrfs-progs*
-postfix
-qemu-quest-agent
%end

%post
#!/bin/bash

##
## Ansible: Add SSH Key (Optional)
##

#mkdir -m 700 -p /root/.ssh
#install -b -m 600 /dev/null /root/.ssh/authorized_keys
#cat > /root/.ssh/authorized_keys << EOF
#ssh-rsa ...
#EOF
yum -y install curl
yum -y install python

##
## END: Ansible
##

##
## Cleanup
##

yum clean all
#fstrim /

##
## END: Cleanup
##

%end
