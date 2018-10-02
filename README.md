# PVE IaaS proof of concept
Main concept is taken from https://morph027.gitlab.io/post/pve-kickseed/
Setup Proxmox VM infrastructure using Ansible by just defining VMs in a yaml file using the [proxmox_kvm](http://docs.ansible.com/ansible/latest/proxmox_kvm_module.html) module. These VMs will then be [kickstarted/preseeded]

**You need to adjust all vars (storage, network, ...) to some sane values according to the module options!**

## Prerequisites

### General

* Ansible 2.3 (*proxmox_kvm* module added)
* passwordless SSH access to target PVE node(s)

### Python modules

* proxmoxer
* requests

## Usage

* add your target PVE node(s) to `infra` inventory file
* define your VMs in ansible external args
`ansible-playbook -i infra run.yaml -e '{"vms":{"vm-test":{"node":"proxmox01","type":"ubuntu"}}}' -e '{"defaults": {"net": "{\"net0\":\"virtio,bridge=vmbr30\"}","cores": "4","memory_size": "4096","scsihw": "virtio-scsi-pci","virtio": "{\"virtio0\":\"storage05:16,cache=writeback,discard=on\"}","ostype": "l26","agent": "1","vga": "qxl"}}'`
or uncomment appropriate values in vars.yaml
default user and password for ubuntu are ubuntu:ubuntu
default user and password for centos are root:centos
you can change default creds easily (and add ssh keys)
* 

## Notes

* **besides lab testing, you should use [Ansible Vaults](http://docs.ansible.com/ansible/latest/user_guide/playbooks_vault.html#single-encrypted-variable) for PVE API passwords!**
* There is a `contrib` folder which contains kickstart, preseed, ... stuff which is neccessary to run this magic. In a true Ansible way of life one could also deploy templates of these files per vm-deployment instead of doing dynamic cmdline parsing.
* **UPD**
* In ubuntu some variables are unavailable during early boot (before network kicks in), so use deploy-args-ubuntu.j2 instead.
* Also check, that `helper` host (check infra file) is available and has some web server running, don`t forget to check paths/permissions for kernels and configs upload.
* `wait for vm to stop after deploy` job is a bit lame, but it was necessary to wait for setup to complete before vm reboots, increase timers in case of errors.
 