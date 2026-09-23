# getssl <!-- omit in toc -->

## Table of Contents <!-- omit in toc -->

- [Building getssl as an RPM Package (Redhat/CentOS/SuSe/Oracle/AWS)](#building-as-an-rpm-package)
- [Building getssl as a Debian Package (Debian/Ubuntu)](#building-as-a-debian-package)

## Building as an RPM Package

In order to build getssl as an RPM, the program must be compressed into a tar.gz
file and the tar.gz file named to match the versioning information contained in the 
associated .spec file.  

Spec files are special files which contain instructions on how to build a particular package
from a source code archive.  On Red Hat, CentOS, Oracle Linux, and AWS Linux systems, RPMS are built in the /root/rpmbuild/ top directory.  SuSe systems build RPMS in the /usr/src/packages/ as top directory.  These "top directories" will contain BUILD, BUILDROOT, SPECS, RPMS, SRPMS, and SOURCES subdirectories.  

The SPECS directory contains the \*.spec files used to build RPMS and SRPMS packages.  The SOURCES subdirectory will contain the soure code archive file referred to in the \*.spec file used to build the 
RPM package.

See the [Quick Start Guide](#quick-start-guide) on instructions for installing the 
source rpm which installs both the .spec file and source archive file (tar.gz) into 
the rpm build top directory (i.e. /root/rpmbuild/).  You should have previously 
installed the src.rpm file before attempting to build the rpm.  You can also 
manually install the .spec file into the \<top directory\>/SPECS/ directory and 
the source code tarball in the \<top directory\/SOURCES/ directory, then attempt 
to build the rpm package.

To build getssl using the rpm tool, change directories (cd) into the /root/rpmbuild/SPECS/ directory (/usr/src/packages/SPECS/ for SuSe) and enter the following command:

```sh
rpmbuild -ba getssl.spec <enter>
```

The program should output the following if the build is successful and verify that the program
wrote both the RPMS and SRPMS packages:

```sh
Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.BYQw0V
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd /root/rpmbuild/BUILD
+ rm -rf getssl-2.50
+ /usr/bin/gzip -dc /root/rpmbuild/SOURCES/getssl-2.50.tar.gz
+ /usr/bin/tar -xof -
+ STATUS=0
+ '[' 0 -ne 0 ']'
+ cd getssl-2.50
+ /usr/bin/chmod -Rf a+rX,u+w,g-w,o-w .
+ exit 0
Executing(%build): /bin/sh -e /var/tmp/rpm-tmp.xpA456
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd getssl-2.50
+ exit 0
Executing(%install): /bin/sh -e /var/tmp/rpm-tmp.zQs24R
+ umask 022
+ cd /root/rpmbuild/BUILD
+ '[' /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64 '!=' / ']'
+ rm -rf /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64
++ dirname /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64
+ mkdir -p /root/rpmbuild/BUILDROOT
+ mkdir /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64
+ cd getssl-2.50
+ '[' -n /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64 -a /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64 '!=' / ']'
+ /usr/bin/rm -rf /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64
+ /usr/bin/mkdir -p /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/bin
+ /usr/bin/mkdir -p /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts
+ /usr/bin/mkdir -p /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/other_scripts
+ /usr/bin/make DESTDIR=/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64 install
mkdir -p /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64
install -Dvm755 getssl /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/bin/getssl
'getssl' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/bin/getssl'
install -dvm755 /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl
for dir in *_scripts; do install -dv /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/$dir; install -pv $dir/* /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/$dir/; done
'dns_scripts/Azure-README.txt' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/Azure-README.txt'
'dns_scripts/Cloudflare-README.md' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/Cloudflare-README.md'
'dns_scripts/DNS_IONOS.md' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/DNS_IONOS.md'
'dns_scripts/DNS_ROUTE53.md' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/DNS_ROUTE53.md'
'dns_scripts/GoDaddy-README.txt' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/GoDaddy-README.txt'
'dns_scripts/PowerDNS-API-README.md' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/PowerDNS-API-README.md'
'dns_scripts/dns_add_acmedns' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_acmedns'
'dns_scripts/dns_add_azure' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_azure'
'dns_scripts/dns_add_challtestsrv' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_challtestsrv'
'dns_scripts/dns_add_clouddns' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_clouddns'
'dns_scripts/dns_add_cloudflare' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_cloudflare'
'dns_scripts/dns_add_cpanel' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_cpanel'
'dns_scripts/dns_add_del_aliyun.sh' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_del_aliyun.sh'
'dns_scripts/dns_add_dnspod' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_dnspod'
'dns_scripts/dns_add_duckdns' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_duckdns'
'dns_scripts/dns_add_dynu' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_dynu'
'dns_scripts/dns_add_godaddy' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_godaddy'
'dns_scripts/dns_add_hostway' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_hostway'
'dns_scripts/dns_add_ionos' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_ionos'
'dns_scripts/dns_add_ispconfig' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_ispconfig'
'dns_scripts/dns_add_joker' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_joker'
'dns_scripts/dns_add_lexicon' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_lexicon'
'dns_scripts/dns_add_linode' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_linode'
'dns_scripts/dns_add_manual' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_manual'
'dns_scripts/dns_add_nsupdate' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_nsupdate'
'dns_scripts/dns_add_ovh' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_ovh'
'dns_scripts/dns_add_pdns-api' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_pdns-api'
'dns_scripts/dns_add_pdns-mysql' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_pdns-mysql'
'dns_scripts/dns_add_vultr' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_vultr'
'dns_scripts/dns_add_windows_dns_server' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_add_windows_dns_server'
'dns_scripts/dns_del_acmedns' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_acmedns'
'dns_scripts/dns_del_azure' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_azure'
'dns_scripts/dns_del_challtestsrv' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_challtestsrv'
'dns_scripts/dns_del_clouddns' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_clouddns'
'dns_scripts/dns_del_cloudflare' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_cloudflare'
'dns_scripts/dns_del_cpanel' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_cpanel'
'dns_scripts/dns_del_dnspod' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_dnspod'
'dns_scripts/dns_del_duckdns' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_duckdns'
'dns_scripts/dns_del_dynu' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_dynu'
'dns_scripts/dns_del_godaddy' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_godaddy'
'dns_scripts/dns_del_hostway' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_hostway'
'dns_scripts/dns_del_ionos' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_ionos'
'dns_scripts/dns_del_ispconfig' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_ispconfig'
'dns_scripts/dns_del_joker' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_joker'
'dns_scripts/dns_del_lexicon' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_lexicon'
'dns_scripts/dns_del_linode' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_linode'
'dns_scripts/dns_del_manual' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_manual'
'dns_scripts/dns_del_nsupdate' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_nsupdate'
'dns_scripts/dns_del_ovh' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_ovh'
'dns_scripts/dns_del_pdns-api' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_pdns-api'
'dns_scripts/dns_del_pdns-mysql' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_pdns-mysql'
'dns_scripts/dns_del_vultr' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_vultr'
'dns_scripts/dns_del_windows_dns_server' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_del_windows_dns_server'
'dns_scripts/dns_freedns.sh' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_freedns.sh'
'dns_scripts/dns_godaddy' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_godaddy'
'dns_scripts/dns_route53.py' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/dns_route53.py'
'dns_scripts/ispconfig_soap.php' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/dns_scripts/ispconfig_soap.php'
'other_scripts/cpanel_cert_upload' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/other_scripts/cpanel_cert_upload'
'other_scripts/iis_install_certeficate.ps1' -> '/root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/usr/share/getssl/other_scripts/iis_install_certeficate.ps1'
+ install -Dpm 644 /root/rpmbuild/SOURCES/getssl.crontab /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/etc/cron.d/getssl
+ install -Dpm 644 /root/rpmbuild/SOURCES/getssl.logrotate /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64/etc/logrotate.d/getssl
+ /usr/lib/rpm/check-buildroot
+ /usr/lib/rpm/redhat/brp-ldconfig
/sbin/ldconfig: Warning: ignoring configuration file that cannot be opened: /etc/ld.so.conf: No such file or directory
+ /usr/lib/rpm/brp-compress
+ /usr/lib/rpm/brp-strip /usr/bin/strip
+ /usr/lib/rpm/brp-strip-comment-note /usr/bin/strip /usr/bin/objdump
+ /usr/lib/rpm/brp-strip-static-archive /usr/bin/strip
+ /usr/lib/rpm/brp-python-bytecompile '' 1
+ /usr/lib/rpm/brp-python-hardlink
+ /usr/bin/true
Processing files: getssl-2.50-1.noarch
Provides: getssl = 2.50-1
Requires(interp): /bin/sh /bin/sh /bin/sh /bin/sh
Requires(rpmlib): rpmlib(CompressedFileNames) <= 3.0.4-1 rpmlib(FileDigests) <= 4.6.0-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1
Requires(pre): /bin/sh
Requires(post): /bin/sh
Requires(preun): /bin/sh
Requires(postun): /bin/sh
Requires: /bin/bash /usr/bin/env
Checking for unpackaged file(s): /usr/lib/rpm/check-files /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64
Wrote: /root/rpmbuild/SRPMS/getssl-2.50-1.src.rpm
Wrote: /root/rpmbuild/RPMS/noarch/getssl-2.50-1.noarch.rpm
Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.hgma8Q
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd getssl-2.50
+ /usr/bin/rm -rf /root/rpmbuild/BUILDROOT/getssl-2.50-1.x86_64
+ exit 0
```

## Building as a Debian Package

In order to build getssl as a Debian package, the program must be compressed into a tar.gz
file and the tar.gz file named to match the versioning information contained in the associated .spec file. Spec files are special files which contain instructions on how to build a particular package from a source code archive.  

Debian Packages can be built using a utility called "debbuild" and use a top directory structure which is similar to that used by the RPM tool but using /root/debbuild/ as the "top directory".  These "top directories" will contain BUILD, BUILDROOT, SPECS, DEBS, SDEBS, and SOURCES subdirectories and follows a similar layout that is used for RPM files.  

The SPECS directory contains the \*.spec files used to build DEB and SDEB packages.  The SOURCES subdirectory will contain the soure code archive file referred to in the \*.spec file used to build the 
DEB and SDEB packages.

See the [Quick Start Guide](#quick-start-guide) on instructions for installing the 
source SDEB which installs both the .spec file and source archive file (tar.gz) into 
the debbuild top directory (i.e. /root/debbuild/).  You should have previously installed 
the SDEB file before attempting to build the DEB package.  You can also manually 
install the .spec file into the \<top directory\>/SPECS/ directory and the source 
code tarball in the \<top directory\/SOURCES/ directory, then attempt to build the 
DEB package.

To build getssl using debbuild, change directories (cd) into the /root/debbuild/SPECS/ directory and enter the following command:

```sh
debbuild -vv -ba getssl.spec <enter>
```

The program should output the following if the build is successful and verify that the program
wrote both the DEB and SDEB packages:

```sh
This is debbuild, version 22.02.1\ndebconfigdir:/usr/lib/debbuild\nsysconfdir:/etc\n
Lua: No Lua module loaded
Executing (%prep): /bin/sh -e /var/tmp/deb-tmp.prep.92007
+ umask 022
+ cd /root/debbuild/BUILD
+ /bin/rm -rf getssl-2.50
+ /bin/gzip -dc /root/debbuild/SOURCES/getssl-2.50.tar.gz
+ /bin/tar -xf -
+ STATUS=0
+ '[' 0 -ne 0 ']'
+ cd getssl-2.50
+ /bin/chmod -Rf a+rX,u+w,go-w .
+ exit 0
Executing (%build): /bin/sh -e /var/tmp/deb-tmp.build.40956
+ umask 022
+ cd /root/debbuild/BUILD
+ cd getssl-2.50
+ exit 0
Executing (%install): /bin/sh -e /var/tmp/deb-tmp.install.36647
+ umask 022
+ cd /root/debbuild/BUILD
+ cd getssl-2.50
+ '[' -n /root/debbuild/BUILDROOT/getssl-2.50-1.amd64 -a /root/debbuild/BUILDROOT/getssl-2.50-1.amd64 '!=' / ']'
+ /bin/rm -rf /root/debbuild/BUILDROOT/getssl-2.50-1.amd64
+ /bin/mkdir -p /root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/bin
+ /bin/mkdir -p /root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts
+ /bin/mkdir -p /root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/other_scripts
+ /usr/bin/make DESTDIR=/root/debbuild/BUILDROOT/getssl-2.50-1.amd64 install
mkdir -p /root/debbuild/BUILDROOT/getssl-2.50-1.amd64
install -Dvm755 getssl /root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/bin/getssl
'getssl' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/bin/getssl'
install -dvm755 /root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl
for dir in *_scripts; do install -dv /root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/$dir; install -pv $dir/* /root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/$dir/; done
'dns_scripts/Azure-README.txt' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/Azure-README.txt'
'dns_scripts/Cloudflare-README.md' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/Cloudflare-README.md'
'dns_scripts/DNS_IONOS.md' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/DNS_IONOS.md'
'dns_scripts/DNS_ROUTE53.md' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/DNS_ROUTE53.md'
'dns_scripts/GoDaddy-README.txt' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/GoDaddy-README.txt'
'dns_scripts/PowerDNS-API-README.md' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/PowerDNS-API-README.md'
'dns_scripts/dns_add_acmedns' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_acmedns'
'dns_scripts/dns_add_azure' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_azure'
'dns_scripts/dns_add_challtestsrv' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_challtestsrv'
'dns_scripts/dns_add_clouddns' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_clouddns'
'dns_scripts/dns_add_cloudflare' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_cloudflare'
'dns_scripts/dns_add_cpanel' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_cpanel'
'dns_scripts/dns_add_del_aliyun.sh' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_del_aliyun.sh'
'dns_scripts/dns_add_dnspod' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_dnspod'
'dns_scripts/dns_add_duckdns' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_duckdns'
'dns_scripts/dns_add_dynu' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_dynu'
'dns_scripts/dns_add_godaddy' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_godaddy'
'dns_scripts/dns_add_hostway' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_hostway'
'dns_scripts/dns_add_ionos' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_ionos'
'dns_scripts/dns_add_ispconfig' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_ispconfig'
'dns_scripts/dns_add_joker' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_joker'
'dns_scripts/dns_add_lexicon' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_lexicon'
'dns_scripts/dns_add_linode' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_linode'
'dns_scripts/dns_add_manual' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_manual'
'dns_scripts/dns_add_nsupdate' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_nsupdate'
'dns_scripts/dns_add_ovh' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_ovh'
'dns_scripts/dns_add_pdns-api' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_pdns-api'
'dns_scripts/dns_add_pdns-mysql' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_pdns-mysql'
'dns_scripts/dns_add_vultr' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_vultr'
'dns_scripts/dns_add_windows_dns_server' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_add_windows_dns_server'
'dns_scripts/dns_del_acmedns' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_acmedns'
'dns_scripts/dns_del_azure' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_azure'
'dns_scripts/dns_del_challtestsrv' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_challtestsrv'
'dns_scripts/dns_del_clouddns' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_clouddns'
'dns_scripts/dns_del_cloudflare' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_cloudflare'
'dns_scripts/dns_del_cpanel' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_cpanel'
'dns_scripts/dns_del_dnspod' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_dnspod'
'dns_scripts/dns_del_duckdns' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_duckdns'
'dns_scripts/dns_del_dynu' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_dynu'
'dns_scripts/dns_del_godaddy' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_godaddy'
'dns_scripts/dns_del_hostway' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_hostway'
'dns_scripts/dns_del_ionos' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_ionos'
'dns_scripts/dns_del_ispconfig' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_ispconfig'
'dns_scripts/dns_del_joker' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_joker'
'dns_scripts/dns_del_lexicon' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_lexicon'
'dns_scripts/dns_del_linode' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_linode'
'dns_scripts/dns_del_manual' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_manual'
'dns_scripts/dns_del_nsupdate' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_nsupdate'
'dns_scripts/dns_del_ovh' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_ovh'
'dns_scripts/dns_del_pdns-api' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_pdns-api'
'dns_scripts/dns_del_pdns-mysql' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_pdns-mysql'
'dns_scripts/dns_del_vultr' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_vultr'
'dns_scripts/dns_del_windows_dns_server' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_del_windows_dns_server'
'dns_scripts/dns_freedns.sh' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_freedns.sh'
'dns_scripts/dns_godaddy' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_godaddy'
'dns_scripts/dns_route53.py' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/dns_route53.py'
'dns_scripts/ispconfig_soap.php' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/dns_scripts/ispconfig_soap.php'
'other_scripts/cpanel_cert_upload' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/other_scripts/cpanel_cert_upload'
'other_scripts/iis_install_certeficate.ps1' -> '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/usr/share/getssl/other_scripts/iis_install_certeficate.ps1'
+ install -Dpm 644 /root/debbuild/SOURCES/getssl.crontab /root/debbuild/BUILDROOT/getssl-2.50-1.amd64/etc/cron.d/getssl
+ install -Dpm 644 /root/debbuild/SOURCES/getssl.logrotate /root/debbuild/BUILDROOT/getssl-2.50-1.amd64/etc/logrotate.d/getssl
+ exit 0
Checking library requirements...
Executing (package-creation): /bin/sh -e /var/tmp/deb-tmp.pkg.6107 for getssl
+ umask 022
+ cd /root/debbuild/BUILD
+ /usr/bin/fakeroot -- /usr/bin/dpkg-deb -b /root/debbuild/BUILDROOT/getssl-2.50-1.amd64/main /root/debbuild/DEBS/all/getssl_2.50-1_all.deb
dpkg-deb: warning: parsing file '/root/debbuild/BUILDROOT/getssl-2.50-1.amd64/main/DEBIAN/control' near line 10 package 'getssl':
 missing 'Maintainer' field
dpkg-deb: warning: ignoring 1 warning about the control file(s)
dpkg-deb: building package 'getssl' in '/root/debbuild/DEBS/all/getssl_2.50-1_all.deb'.
+ exit 0
Executing (%clean): /bin/sh -e /var/tmp/deb-tmp.clean.52780
+ umask 022
+ cd /root/debbuild/BUILD
+ '[' /root/debbuild/BUILDROOT/getssl-2.50-1.amd64 '!=' / ']'
+ /bin/rm -rf /root/debbuild/BUILDROOT/getssl-2.50-1.amd64
+ exit 0
Wrote source package getssl-2.50-1.sdeb in /root/debbuild/SDEBS.
Wrote binary package getssl_2.50-1_all.deb in /root/debbuild/DEBS/all
```

## Issues / problems / help

If you have any issues, please log them at <https://github.com/srvrco/getssl/issues>

There are additional help pages on the [wiki](https://github.com/srvrco/getssl/wiki)

If you have any suggestions for improvements then pull requests are
welcomed, or raise an issue.
