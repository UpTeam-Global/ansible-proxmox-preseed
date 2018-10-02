# Preseed

## Prepare Kernel

Unfortunately there's no single kernel and initrd like for CentOS, just an archive, so you'll need to fetch the files and serve via HTTP/FTP.

### Example

```bash
cd /var/www/html # << or any place your webserver is serving from
wget http://archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/current/images/netboot/netboot.tar.gz
tar xzf netboot.tar.gz 
mv ubuntu-installer/amd64/linux ubuntu-installer/amd64/initrd.gz .
rm -rf ubuntu-installer netboot.tar.gz ldlinux.c32 pxelinux.0 pxelinux.cfg version.info
```