#!/bin/bash

yum check-update
yum groupinstall -y "Development Tools"

yum install -y libcap-devel tcp_wrappers-devel pam-devel libselinux-devel audit-libs-devel cryptsetup-devel dbus-devel libacl-devel pciutils-devel glib2-devel gobject-introspection-devel libblkid-devel xz-devel libidn-devel libcurl-devel kmod-devel elfutils-devel libgcrypt-devel gnutls-devel qrencode-devel libmicrohttpd-devel libxslt docbook-style-xsl gperf gtk-doc python2-devel python-lxml libseccomp-devel libmount-devel

CWD=`pwd`
cd /etc/yum.repos.d
wget https://copr.fedoraproject.org/coprs/lnykryn/systemd/repo/epel-7/lnykryn-systemd-epel-7.repo
cd $CWD

yum install -y dracut kmod

wget http://people.redhat.com/lnykryn/systemd-219-0.el7.1.src.rpm
rpm -ivh systemd-219-0.el7.1.src.rpm
cd /root
cat <<'EOL' > systemd.spec.patch
--- rpmbuild/SPECS/systemd.spec		2015-03-13 22:47:39.513353377 +0900
+++ rpmbuild/SPECS/systemd.spec.new	2015-03-13 22:48:06.935059994 +0900
@@ -11,7 +11,7 @@
 Name:           systemd
 Url:            http://www.freedesktop.org/wiki/Software/systemd
 Version:        219
-Release:        0%{?dist}.1
+Release:        0%{?dist}.2
 # For a breakdown of the licensing, see README
 License:        LGPLv2+ and MIT and GPLv2+
 Summary:        A System and Service Manager
@@ -48,6 +48,7 @@
 Patch0014: 0014-journald-audit-exit-gracefully-in-the-case-we-can-t-.patch
 Patch0015: 0015-fedora-disable-resolv.conf-symlink.patch
 Patch0016: 0016-Revert-timedated-manage-systemd-timesyncd-directly-i.patch
+Patch0017: 0017-fix-machinectl-login.patch
 Patch9001: 9001-FIXME-remove-from-systemd.conf.patch
 
 
EOL
patch -p0 < systemd.spec.patch

cat <<'EOL' > rpmbuild/SOURCES/0017-fix-machinectl-login.patch
From 1a3dd33f98312421e0f3d654e8f5d56554557a8c Mon Sep 17 00:00:00 2001
From: 2GMon <2gmon.t@gmail.com>
Date: Fri, 13 Mar 2015 22:34:14 +0900
Subject: [systemd-devel] [PATCH] machined: use x-machine-unix prefix for the
 container bus on dbus1

This fixes "machinectl login" on systems configured with --disable-kdbus.

The error was:
machinectl login foo
Failed to get machine PTY: Input/output error
---
 src/machine/machine-dbus.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/src/machine/machine-dbus.c b/src/machine/machine-dbus.c
index 116e711..2388c85 100644
--- a/src/machine/machine-dbus.c
+++ b/src/machine/machine-dbus.c
@@ -477,7 +477,7 @@
 #ifdef ENABLE_KDBUS
         asprintf(&container_bus->address, "x-machine-kernel:pid=" PID_FMT ";x-machine-unix:pid=" PID_FMT, m->leader, m->leader);
 #else
-        asprintf(&container_bus->address, "x-machine-kernel:pid=" PID_FMT, m->leader);
+        asprintf(&container_bus->address, "x-machine-unix:pid=" PID_FMT, m->leader);
 #endif
         if (!container_bus->address)
                 return -ENOMEM;
EOL

rpmbuild -ba --clean rpmbuild/SPECS/systemd.spec
cp -r rpmbuild /vagrant

cd rpmbuild/RPMS/x86_64
yum localinstall -y systemd-219-0.el7.centos.2.x86_64.rpm systemd-devel-219-0.el7.centos.2.x86_64.rpm systemd-libs-219-0.el7.centos.2.x86_64.rpm systemd-sysv-219-0.el7.centos.2.x86_64.rpm libgudev1-219-0.el7.centos.2.x86_64.rpm
