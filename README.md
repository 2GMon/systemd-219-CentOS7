# systemd-219 for CentOS7

** systemd-219-0.el7.3 has been fixed, so we don't need this repository. **

* base SRPM is https://copr.fedoraproject.org/coprs/lnykryn/systemd/
* patch http://lists.freedesktop.org/archives/systemd-devel/2015-February/028603.html

# How to build the packages

```
vagrant up --provision
vagrant destroy
```

# How to install packages

```
cd /etc/yum.repos.d
wget https://copr.fedoraproject.org/coprs/lnykryn/systemd/repo/epel-7/lnykryn-systemd-epel-7.repo

yum localinstall systemd-219-0.el7.centos.2.x86_64.rpm systemd-devel-219-0.el7.centos.2.x86_64.rpm systemd-libs-219-0.el7.centos.2.x86_64.rpm systemd-sysv-219-0.el7.centos.2.x86_64.rpm libgudev1-219-0.el7.centos.2.x86_64.rpm
```
