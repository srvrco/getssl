# getssl <!-- omit in toc -->

![Run all tests on Pebble](https://github.com/srvrco/getssl/actions/workflows/run-tests-pebble.yml/badge.svg) ![shellcheck](https://github.com/srvrco/getssl/workflows/shellcheck/badge.svg)

Obtain SSL certificates from the letsencrypt.org ACME server. Suitable
for automating the process on remote servers.

## Table of Contents <!-- omit in toc -->
- [Upgrade broken in v2.43](#upgrade-broken-in-v243)
- [Features](#features)
- [Overview](#overview)
- [Quick Start Guide](#quick-start-guide)
- [Manual Installation](#manual-installation)
- [Getting started](#getting-started)
- [Detailed guide to getting started with more examples](#detailed-guide-to-getting-started-with-more-examples)
- [Wildcard certificates](#wildcard-certificates)
- [ISPConfig](#ispconfig)
- [Automating updates](#automating-updates)
- [Structure](#structure)
- [Custom template for configuration](#custom-template-for-configuration)
- [Server-Types](#server-types)
- [Revoke a certificate](#revoke-a-certificate)
- [Elliptic curve keys](#elliptic-curve-keys)
- [Preferred Chain](#preferred-chain)
- [Include Root certificate in full chain](#include-root-certificate-in-full-chain)
- [Windows Server and IIS Support](#windows-server-and-iis-support)
- [Building getssl as an RPM Package (Redhat/CentOS/SuSe/Oracle/AWS)](#building-as-an-rpm-package)
- [Building getssl as a Debian Package (Debian/Ubuntu)](#building-as-a-debian-package)
- [Issues / problems / help](#issues--problems--help)

## Upgrade broken in v2.43

The automatic upgrade in v2.43 is broken as the url is incorrect.  If you have this version installed you'll need to manually upgrade using:
```curl --silent --user-agent getssl/manual https://raw.githubusercontent.com/srvrco/getssl/latest/getssl --output getssl```

## Features

* **Bash** - It runs on virtually all unix machines, including BSD, most
  Linux distributions, macOS.
* **Get certificates for remote servers** - The tokens used to provide
  validation of domain ownership, and the certificates themselves can be
  automatically copied to remote servers (via ssh, sftp or ftp for
  tokens). The script doesn't need to run on the server itself. This can
  be useful if you don't have access to run such scripts on the server
  itself, e.g. if it's a shared server.
* **Runs as a daily cron** - so certificates will be automatically
  renewed when required.
* **Automatic certificate renewals**
* **Checks certificates are correctly loaded** - After installation of a
  new certificate it will test the port specified ( see
  [Server-Types](#server-types) for options ) that the certificate is
  actually being used correctly.
* **Automatically updates** - The script can automatically update itself
  with bug fixes etc if required.
* **Extensively configurable** - With a simple configuration file for
  each certificate it is possible to configure it exactly for your
  needs, whether a simple single domain or multiple domains across
  multiple servers on the same certificate.
* **Supports http and dns challenges** - Full ACME implementation
* **Simple and easy to use**
* **Detailed debug info** - Whilst it shouldn't be needed, detailed
  debug information is available.
* **Reload services** - After a new certificate is obtained then the
  relevant services (e.g. apache/nginx/postfix) can be reloaded.
* **ACME v1 and V2** - Supports both ACME versions 1 and 2 (note ACMEv1 is deprecated and clients will automatically use v2)

## Overview

GetSSL was written in standard bash ( so it can be run on a server, a
desktop computer, or even a virtualbox) and add the checks, and
certificates to a remote server ( providing you have a ssh with key,
sftp or ftp access to the remote server).

```getssl -h
getssl ver. 2.36
Obtain SSL certificates from the letsencrypt.org ACME server

Usage: getssl [-h|--help] [-d|--debug] [-c|--create] [-f|--force] [-a|--all] [-q|--quiet] [-Q|--mute] [-u|--upgrade] [-X|--experimental tag] [-U|--nocheck] [-r|--revoke cert key] [-w working_dir] [--preferred-chain chain] domain   

Options:
  -a, --all          Check all certificates
  -d, --debug        Output debug information
  -c, --create       Create default config files
  -f, --force        Force renewal of cert (overrides expiry checks)
  -h, --help         Display this help message and exit
  -i, --install      Install certificates and reload service
  -q, --quiet        Quiet mode (only outputs on error, success of new cert, or getssl was upgraded)
  -Q, --mute         Like -q, but also mute notification about successful upgrade
  -r, --revoke   "cert" "key" [CA_server] Revoke a certificate (the cert and key are required)
  -u, --upgrade      Upgrade getssl if a more recent version is available - can be used with or without domain(s)
  -X  --experimental tag Allow upgrade to a specified version of getssl
  -U, --nocheck      Do not check if a more recent version is available
  -v  --version      Display current version of getssl
  -w working_dir "Working directory"
    --preferred-chain "chain" Use an alternate chain for the certificate
    --account-id       Display account id and exit
    --new-account-key  Replace the account key with a new one
    --DEACTIVATE-account Permanently deactivate account
```

## Quick Start Guide 

You can download precompiled RPM packages and Debian (DEB) packages from
the [release page](https://github.com/jeffmerkey/getssl/releases) for 
this project, or you can manually build and install the program from the git sources.   

If you want to manually install the program from scratch with the git sources rather than use the pre-compiled RPMS and DEB packages, or if your target platform does not support Linux RPM or DEB packages, then please skip to the section [Manual Installation](#manual-installation) for instructions on installing the getssl program manually. 
 
Packages are provided in binary and source versions, and can be downloaded and 
installed directly or rebuilt. Package types are
Red Hat Package Manager (RPM) packages and Debian (DEB) packages for binary installation and 
Source RPM packages (SRPMS) and Debbuild SDEB packages for source code installation.  

RPM and DEB packages for each release include a binary architecture specific package
and a source package which can be downloaded and built/rebuilt and which contains the source code.

For example, the release v2.47 contains the following packages in the release section:

### **RPM Based Packages (RedHat, CentOS, SuSe, Oracle Linux, AWS Linux)**

- [getssl-2.47-1.src.rpm](https://github.com/jeffmerkey/getssl/releases/download/v2.47/getssl-2.47-1.src.rpm) (source)
- [getssl-2.47-1.noarch.rpm](https://github.com/jeffmerkey/getssl/releases/download/v2.47/getssl-2.47-1.noarch.rpm) (binary)

### **Debian Based Packages (Debian, Ubuntu)**

- [getssl-2.47-1.sdeb](https://github.com/jeffmerkey/getssl/releases/download/v2.47/getssl-2.47-1.sdeb) (source)
- [getssl_2.47-1_all.deb](https://github.com/jeffmerkey/getssl/releases/download/v2.47/getssl_2.47-1_all.deb) (binary)

### **Installing Binary Packages**

To install the binary package with the rpm package manager for RedHat, CentOS, SuSe, Oracle Linux, or AWS Linux distributions:
```sh
rpm -i getssl-2.47-1.noarch.rpm
```

To deinstall the RPM binary package:
```sh
rpm -e getssl
```

To install the binary package with the Debian dpkg package manager for Debian and Ubuntu Linux distributions:
```sh
dpkg -i getssl_2.47-1_all.deb
```

To deinstall the Debian dpkg binary package:
```sh
dpkg -r getssl
```

### **Installing Source Packages**

To install the source package with the rpm package manager for RedHat, CentOS, SuSe, Oracle Linux, or AWS Linux distributions:
```sh
rpm -i getssl-2.47-1.src.rpm 
```
*(Note: rpm installs the source code files in /root/rpmbuild/ as top directory for RedHat, CentOS, Oracle Linux, and AWS Linux platforms.  SuSe platforms install the source code files in /usr/src/packages/)*

To install the source package with the Debbuild package tool for Debian or Ubuntu Linux distributions:
```sh
debbuild -i getssl-2.47-1.sdeb
```
*(Note: Debbuild installs the source code files in /root/debbuild/ as top directory)*

One item of note is that SDEB packages are actually just tar.gz archives renamed with an .sdeb file extension with the files organized into a SPECS and SOURCES directory tree structure.  Subsequently, an SDEB can also be extracted and installed with the **tar -xvf command** or the files listed with the **tar -tvf command**:

```sh
[root@localhost getssl]$ tar -tvf /root/debbuild/SDEBS/getssl-2.47-1.sdeb 
-rw-r--r-- root/root   1772110 2022-10-12 20:42 SOURCES/getssl-2.47.tar.gz
-rw-r--r-- root/root       192 2022-08-02 15:02 SOURCES/getssl.crontab
-rw-r--r-- root/root       126 2022-08-02 15:02 SOURCES/getssl.logrotate
-rw-r--r-- root/root      1537 2022-08-02 15:02 SPECS/getssl.spec
[root@localhost getssl]$ 
```

For building or rebuilding RPMS or DEB Packages after you have installed the associated source packages on your platform, refer to the following:

- [Building getssl as an RPM Package (Redhat/CentOS/SuSe/Oracle/AWS)](#building-as-an-rpm-package)
- [Building getssl as a Debian Package (Debian/Ubuntu)](#building-as-a-debian-package)

## Manual Installation

Since the script is only one file, you can use the following command for
a quick installation of GetSSL only:

```sh
curl --silent https://raw.githubusercontent.com/srvrco/getssl/latest/getssl > getssl ; chmod 700 getssl
```

This will copy the getssl Bash script to the current location and change
the permissions to make it executable for you.

For a more comprehensive installation (e.g. install also helper scripts)
use the provided Makefile with each release tarball. Use the `install`
target.

You'll find the latest version in the git repository:

```sh
git clone https://github.com/srvrco/getssl.git
```

For Arch Linux there are packages in the AUR, see
[here](https://aur.archlinux.org/packages/getssl/) and
[there](https://aur.archlinux.org/packages/getssl-git/).

If you use puppet, there is a [GetSSL Puppet
module](https://github.com/dthielking/puppet_getssl) by dthielking

## Getting started

Once you have obtained the script (see Installation above), the next step is to use

```sh
./getssl -c yourdomain.com
```

where yourdomain.com is the primary domain name that you want to create
a certificate for. This will create the following folders and files.

```sh
~/.getssl
~/.getssl/getssl.cfg
~/.getssl/yourdomain.com
~/.getssl/yourdomain.com/getssl.cfg
```

You can then edit `~/.getssl/getssl.cfg` to set the values you want as the
default for the majority of your certificates.

Then edit `~/.getssl/yourdomain.com/getssl.cfg` to have the values you
want for this specific domain (make sure to uncomment and specify
correct `ACL` option, since it is required).

You can then just run:

```sh
getssl yourdomain.com
```

and it should run, providing output like:

```sh
Registering account
Verify each domain
Verifying yourdomain.com
Verified yourdomain.com
Verifying www.yourdomain.com
Verified www.yourdomain.com
Verification completed, obtaining certificate.
Certificate saved in /home/user/.getssl/yourdomain.com/yourdomain.com.crt
The intermediate CA cert is in /home/user/.getssl/yourdomain.com/chain.crt
copying domain certificate to ssh:server5:/home/yourdomain/ssl/domain.crt
copying private key to ssh:server5:/home/yourdomain/ssl/domain.key
copying CA certificate to ssh:server5:/home/yourdomain/ssl/chain.crt
reloading SSL services
```

**This will (by default) use the staging server, so should give you a
certificate that isn't trusted ( Fake Let's Encrypt).**
Change the server in your config file to get a fully valid certificate.

**Note:** Verification is done via port 80 (http), port 443 (https) or
dns. The certificate can be used (and checked with getssl) on alternate
ports.

## Detailed guide to getting started with more examples

[Guide to getting a certificate for example.com and www.example.com](https://github.com/srvrco/getssl/wiki/Guide-to-getting-a-certificate-for-example.com-and-www.example.com)

## Wildcard certificates

`getssl` supports creating wildcard certificates, i.e. _*.example.com_ which allows a single certificate to be used for any domain under *example.com*, e.g. *www.example.com*, *mail.example.com*.  These must be validated using the dns-01 method.

A *partial* example `getssl.cfg` file is:

```sh
VALIDATE_VIA_DNS=true
export CPANEL_USERNAME=''
export CPANEL_URL='https://www.cpanel.host:2083'
export CPANEL_APITOKEN='1ABC2DEF3GHI4JKL5MNO6PQR7STU8VWX9YZA'
DNS_ADD_COMMAND=/home/root/getssl/dns_scripts/dns_add_cpanel
DNS_DEL_COMMAND=/home/root/getssl/dns_scripts/dns_del_cpanel
```


## ISPConfig

There is a need to create a remote user in `ISPConfig` to enable the remote API access.

You need to go to `System -> Remote Users` and then enable the features for the remote user such as `DNS zone functions`.

PHP is required to exeucte soap functions in file ispconfig_soap.php.
```sh
DNS_ADD_COMMAND="/home/root/getssl/dns_scripts/dns_add_ispconfig"
DNS_DEL_COMMAND="/home/root/getssl/dns_scripts/dns_del_ispconfig"

export ISPCONFIG_REMOTE_USER_NAME="ussename"
export ISPCONFIG_REMOTE_USER_PASSWORD="password"
export ISPCONFIG_SOAP_LOCATION="https://localhost:8080/remote/index.php"
export ISPCONFIG_SOAP_URL="https://localhost:8080/remote/"
```


Create the wildcard certificate (need to use quotes to prevent globbing):

```sh
getssl "*.example.domain"
```

You can renew the certificate using `getssl -a` to renew all configured certificates.

You can also specify additional domains in the `SANS` line, e.g. `SANS="www.test.example.com"`.
This cannot contain any of the domains which would be covered by the wildcard certificate.

## Automating updates

I use the following **cron** job

```cron
23  5 * * * /root/scripts/getssl -u -a -q
```

The cron will automatically update getssl and renew any certificates,
only giving output if there are issues / errors.

* The -u flag updates getssl if there is a more recent version available.
* The -a flag automatically renews any certificates that are due for renewal.
* The -q flag is "quiet" so that it only outputs and emails me if there
  was an error / issue.

## Structure

The design aim was to provide flexibility in running the code. The
default working directory is `~/.getssl` (which can be modified via the
command line).

Within the **working directory** is a config file `getssl.cfg` which is a
simple bash file containing variables, an example of which is:

```sh
# Uncomment and modify any variables you need
# The staging server is best for testing (hence set as default)
CA="https://acme-staging-v02.api.letsencrypt.org"
# This server issues full certificates, however has rate limits
#CA="https://acme-v02.api.letsencrypt.org"

AGREEMENT="https://letsencrypt.org/documents/LE-SA-v1.0.1-July-27-2015.pdf"

# Set an email address associated with your account - generally set at account level rather than domain.
ACCOUNT_EMAIL="me@example.com"
ACCOUNT_KEY_LENGTH=4096
ACCOUNT_KEY="/home/user/.getssl/account.key"
PRIVATE_KEY_ALG="rsa"

# The time period within which you want to allow renewal of a certificate - this prevents hitting some of the rate limits.
RENEW_ALLOW="30"

# openssl config file.  The default should work in most cases.
SSLCONF="/usr/lib/ssl/openssl.cnf"
```

then, within the **working directory** there will be a folder for each
certificate (based on its domain name). Within that folder will be a
config file (again called `getssl.cfg`). An example of which is:

```sh
# Uncomment and modify any variables you need
# see https://github.com/srvrco/getssl/wiki/Config-variables for details
# see https://github.com/srvrco/getssl/wiki/Example-config-files for example configs
#
# The staging server is best for testing
#CA="https://acme-staging-v02.api.letsencrypt.org"
# This server issues full certificates, however has rate limits
#CA="https://acme-v02.api.letsencrypt.org"

#AGREEMENT="https://letsencrypt.org/documents/LE-SA-v1.1.1-August-1-2016.pdf"

PRIVATE_KEY_ALG="rsa"

# Additional domains - this could be multiple domains / subdomains in a comma separated list
SANS="www.example.org"

# Acme Challenge Location. The first line for the domain, the following ones for each additional domain.
# If these start with ssh: then the next variable is assumed to be the hostname and the rest the location.
# An ssh key will be needed to provide you with access to the remote server.
# Optionally, you can specify a different userid for ssh/scp to use on the remote server before the @ sign.
# If left blank, the username on the local server will be used to authenticate against the remote server.
# If these start with ftp: then the next variables are ftpuserid:ftppassword:servername:ACL_location
# These should be of the form "/path/to/your/website/folder/.well-known/acme-challenge"
# where "/path/to/your/website/folder/" is the path, on your web server, to the web root for your domain.
#ACL=('/var/www/${DOMAIN}/web/.well-known/acme-challenge'
#     'ssh:server5:/var/www/${DOMAIN}/web/.well-known/acme-challenge'
#     'ssh:sshuserid@server5:/var/www/${DOMAIN}/web/.well-known/acme-challenge'
#     'ftp:ftpuserid:ftppassword:${DOMAIN}:/web/.well-known/acme-challenge')


# Location for all your certs, these can either be on the server (so full path name) or using ssh as for the ACL
DOMAIN_CERT_LOCATION="ssh:server5:/etc/ssl/domain.crt"
DOMAIN_KEY_LOCATION="ssh:server5:/etc/ssl/domain.key"
#CA_CERT_LOCATION="/etc/ssl/chain.crt"
#DOMAIN_CHAIN_LOCATION="" this is the domain cert and CA cert
#DOMAIN_PEM_LOCATION="" this is the domain_key. domain cert and CA cert


# The command needed to reload apache / nginx or whatever you use.
# Several (ssh) commands may be given using a bash array:
# RELOAD_CMD=('ssh:sshuserid@server5:systemctl reload httpd' 'logger getssl for server5 efficient.')
RELOAD_CMD="service apache2 reload"

# Define the server type. This can be https, ftp, ftpi, imap, imaps, pop3, pop3s, smtp,
# smtps_deprecated, smtps, smtp_submission, xmpp, xmpps, ldaps or a port number which
# will be checked for certificate expiry and also will be checked after
# an update to confirm correct certificate is running (if CHECK_REMOTE) is set to true
#SERVER_TYPE="https"
#CHECK_REMOTE="true"
```

If a location for a file starts with `ssh:` it is assumed the next part
of the file is the hostname, followed by a colon, and then the path.
Files will be securely copied using scp, and it assumes that you have a
key on the server (for passwordless access). You can set the user,
port etc for the server in your `.ssh/config` file.

If an ACL starts with `ftp:` or `sftp:` it as assumed that the line is
in the format "ftp:UserID:Password:servername:/path/to/acme-challenge".
sftp requires sshpass.
Note: FTP can be used for copying tokens only
and can **not** be used for uploading private key or certificates as
it's not a secure method of transfer.

ssh can also be used for the reload command if using on remote servers.

Multiple locations can be defined for a file by separating the locations with a semi-colon.

A typical config file for `example.com` and `www.example.com` on the
same server would be:

```sh
# uncomment and modify any variables you need
# The staging server is best for testing
CA="https://acme-staging-v02.api.letsencrypt.org"
# This server issues full certificates, however has rate limits
#CA="https://acme-v02.api.letsencrypt.org"

# additional domains - this could be multiple domains / subdomains in a comma separated list
SANS="www.example.com"

#Acme Challenge Location.   The first line for the domain, the following ones for each additional domain
ACL=('/var/www/example.com/web/.well-known/acme-challenge')

USE_SINGLE_ACL="true"

DOMAIN_CERT_LOCATION="/etc/ssl/example.com.crt"
DOMAIN_KEY_LOCATION="/etc/ssl/example.com.key"
CA_CERT_LOCATION="/etc/ssl/example.com.bundle"

RELOAD_CMD="service apache2 reload"

```

## Custom template for configuration

You can create and customize a template that can be use to generate the `~/.getssl/yourdomain.com/getssl.cfg` config file, instead of the default one.

Create one of fhe following allowed locations, according to your getssl installation:

```sh
/etc/getssl/getssl_default.cfg
/path/of/your/getssl/installation/getssl_default.cfg
~/.getssl/getssl_default.cfg

```

And define the default values, optionally using the dynamic variables, as in the example below:

```sh
# Additional domains - this could be multiple domains / subdomains in a comma separated list
# Note: this is Additional domains - so should not include the primary domain.
SANS="${EX_SANS}"

ACL=('/home/myuser/${DOMAIN}/public_html/.well-known/acme-challenge')

USE_SINGLE_ACL="true"

RELOAD_CMD="sudo /bin/systemctl restart nginx.service"

# Define the server type. This can be https, ftp, ftpi, imap, imaps, pop3, pop3s, smtp,
# smtps_deprecated, smtps, smtp_submission, xmpp, xmpps, ldaps or a port number which
# will be checked for certificate expiry and also will be checked after
# an update to confirm correct certificate is running (if CHECK_REMOTE) is set to true
SERVER_TYPE="https"
#CHECK_REMOTE="true"
CHECK_REMOTE_WAIT="1" # wait 1 second before checking the remote server

```

## Server-Types

OpenSSL has built-in support for getting the certificate from a number of SSL services
these are available in getssl to check if the certificate is installed correctly

| Server-Type      | Port | Extra        |
|------------------|------|--------------|
| https            | 443  |              |
| ftp              | 21   | FTP Explicit |
| ftpi             | 990  | FTP Implicit |
| imap             | 143  | StartTLS     |
| imaps            | 993  |              |
| pop3             | 110  | StartTLS     |
| pop3s            | 995  |              |
| smtp             | 25   | StartTLS     |
| smtps_deprecated | 465  |              |
| smtps            | 587  | StartTLS     |
| smtp_submission  | 587  | StartTLS     |
| xmpp             | 5222 | StartTLS     |
| xmpps            | 5269 |              |
| ldaps            | 636  |              |
| postgres         | 5432 |              |
| port number      |      |              |

## Revoke a certificate

In general revoking a certificate is not required.

Usage: `getssl -r path/to/cert path/to/key [CA_server]`

You need to specify both the certificate you want to revoke, and the
account or private domain key which was used to sign / obtain the
original certificate. The `CA_server` is an optional parameter and
defaults to Let's Encrypt ("<https://acme-v02.api.letsencrypt.org>") as
that is currently the only Certificate Authority using the ACME
protocol.

## Elliptic curve keys

You can use Elliptic curve keys for both the account key and the domain
key (different of course, don't use the same key for both). prime256v1
(NIST P-256) and secp384r1 (NIST P-384) are both fully supported.
secp521r1 (NIST P-521) is included in the code, but not currently
supported by Let's Encrypt).

## Preferred Chain

If a CA offers multiple chains then it is possible to select which chain
is used by using the `PREFERRED_CHAIN` variable in `getssl.cfg` or specifying
 `--preferred-chain` in the call to `getssl`

This uses wildcard matching so requesting "X1" returns the first certificate
returned by the CA which contains the text "X1",  Note you may need to escape
any characters which special characters, e.g.
` PREFERRED_CHAIN="\(STAGING\) Doctored Durian Root CA X3"`

* Staging options are: "(STAGING) Doctored Durian Root CA X3" and "(STAGING) Pretend Pear X1"
* Production options are: "ISRG Root X1" and "ISRG Root X2"

## Include Root certificate in full chain

Some servers, including those that use Java keystores, will not accept a server certificate if it cannot valid the full chain of signers.

Specifically, Nutanix Prism (Element and Central) will not accept the `fullchain.crt` until the root CA's certificate has been appended to it manually.

If your application requires the full chain, i.e. including the
root certificate of the CA, then this can be included in the `fullchain.crt` file by
adding the following line to `getssl.cfg`

```sh
FULL_CHAIN_INCLUDE_ROOT="true"
```

## Windows Server and IIS Support

**System and software requirements**:

-   Windows Server with DNS and IIS services

-   One of

    -   WSL Windows Sub for Linux

        -   Ubuntu or any other distro

        -   gettssl can be installed inside WSL or using `/mnt/` path to windows

    -   Bash - gettssl should be installed in Windows

        -   Git Bash - <https://git-scm.com/downloads>

        -   Rtools4.0 - <https://cran.r-project.org/bin/windows/Rtools/>

**WSL**

-   Installing and configuring WSL 2

    -   Add remove Windows features and choose "Windows for sub Linux"

    -   Install a distro like Ubuntu or any other Linux platform

        -   If newly added to the system a reboot is required to continue

        -   wsl --install -d ubuntu

        -   Any user will work

        -   Copying files to WSL

            -   From Windows open `Windows Explorer` and browse to `\\wsl$\Ubuntu\home\user\` and then place the getssl files and folders `.getssl` and `getssl` into users home directory `\\wsl$\Ubuntu\home\user\.getssl .` or in Windows

        -   Open `cmd` in Widnows and type\
            `wsl -d Ubuntu /bin/bash /home/UserName/getssl/getssl domain.eu && exit`

        -   Using a specific distro if not set as default in WSL then use the `wsl -d distro` command

    **Notes:**

    -   While configuring WSL please do check the `/etc/hosts` file if the IP of the domain is correct since it overrides the DNS server.

    -   Make sure running version 2.

**GIT Bash** - MINGW64_NT

-   Install git GIT Bash

-   `"C:\Program Files\Git\bin\bash.exe" --login -i -- path_to/getssl/getssl domain.eu`

**Rtools Bash** - MSYS_NT

-   Make sure that the path of `\rtools42\usr\bin` in Windows system environment variables is right before `c:\windows\system32\` so that getssl will use the `Rtools` applications instead of Windows applications such as `sort.exe` that crashes or speify full path to sort.

-   `\rtools42\usr\bin\bash.exe \Users\Administrator\getssl\getssl domain.eu 2>&1 1>out.txt`

**Updating DNS TXT records**

-   Using `PowerShell` to add and delete `_acme-challenge` records

    -   dns_add_windows_dnsserver

    -   dns_del_windows_dnsserver

    **Notes:** The script supports optional second level `TLDs`. `sub.domain.co.uk` You can update the reqexp `.(co|com).uk` to fit your needs.

**IIS internet information service**

-   Under folder `other_scripts` you can find a `PowerSheell` script `iis_install_certeficate.ps1` which generates `PFX` certificate to be installed in `IIS` and binds the domains to the `PFX` certificate.

-   WSL

    -   `RELOAD_CMD=("powershell.exe -ExecutionPolicy Bypass -File "\\\\wsl$\\Ubuntu\\home\\user\\getssl\\other_scripts\\iis_install_certeficate.ps1" "domain.eu" "IIS SiteName" "\\\\wsl$\\Ubuntu\\home\\user\\ssl\\" "path_to_ssl_dir" )`

-   GIT and Rtools4 Bash

    -   `RELOAD_CMD=("powershell.exe /c/Users/Administrator/getssl/other_scripts/iis_install_certeficate.ps1 domain.eu domain path_to_ssl_dir")`

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
+ rm -rf getssl-2.47
+ /usr/bin/gzip -dc /root/rpmbuild/SOURCES/getssl-2.47.tar.gz
+ /usr/bin/tar -xof -
+ STATUS=0
+ '[' 0 -ne 0 ']'
+ cd getssl-2.47
+ /usr/bin/chmod -Rf a+rX,u+w,g-w,o-w .
+ exit 0
Executing(%build): /bin/sh -e /var/tmp/rpm-tmp.xpA456
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd getssl-2.47
+ exit 0
Executing(%install): /bin/sh -e /var/tmp/rpm-tmp.zQs24R
+ umask 022
+ cd /root/rpmbuild/BUILD
+ '[' /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64 '!=' / ']'
+ rm -rf /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64
++ dirname /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64
+ mkdir -p /root/rpmbuild/BUILDROOT
+ mkdir /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64
+ cd getssl-2.47
+ '[' -n /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64 -a /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64 '!=' / ']'
+ /usr/bin/rm -rf /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64
+ /usr/bin/mkdir -p /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/bin
+ /usr/bin/mkdir -p /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts
+ /usr/bin/mkdir -p /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/other_scripts
+ /usr/bin/make DESTDIR=/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64 install
mkdir -p /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64
install -Dvm755 getssl /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/bin/getssl
'getssl' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/bin/getssl'
install -dvm755 /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl
for dir in *_scripts; do install -dv /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/$dir; install -pv $dir/* /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/$dir/; done
'dns_scripts/Azure-README.txt' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/Azure-README.txt'
'dns_scripts/Cloudflare-README.md' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/Cloudflare-README.md'
'dns_scripts/DNS_IONOS.md' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/DNS_IONOS.md'
'dns_scripts/DNS_ROUTE53.md' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/DNS_ROUTE53.md'
'dns_scripts/GoDaddy-README.txt' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/GoDaddy-README.txt'
'dns_scripts/dns_add_acmedns' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_acmedns'
'dns_scripts/dns_add_azure' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_azure'
'dns_scripts/dns_add_challtestsrv' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_challtestsrv'
'dns_scripts/dns_add_clouddns' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_clouddns'
'dns_scripts/dns_add_cloudflare' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_cloudflare'
'dns_scripts/dns_add_cpanel' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_cpanel'
'dns_scripts/dns_add_del_aliyun.sh' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_del_aliyun.sh'
'dns_scripts/dns_add_dnspod' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_dnspod'
'dns_scripts/dns_add_duckdns' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_duckdns'
'dns_scripts/dns_add_dynu' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_dynu'
'dns_scripts/dns_add_godaddy' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_godaddy'
'dns_scripts/dns_add_hostway' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_hostway'
'dns_scripts/dns_add_ionos' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_ionos'
'dns_scripts/dns_add_ispconfig' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_ispconfig'
'dns_scripts/dns_add_joker' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_joker'
'dns_scripts/dns_add_lexicon' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_lexicon'
'dns_scripts/dns_add_linode' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_linode'
'dns_scripts/dns_add_manual' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_manual'
'dns_scripts/dns_add_nsupdate' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_nsupdate'
'dns_scripts/dns_add_ovh' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_ovh'
'dns_scripts/dns_add_pdns-mysql' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_pdns-mysql'
'dns_scripts/dns_add_vultr' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_vultr'
'dns_scripts/dns_add_windows_dns_server' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_add_windows_dns_server'
'dns_scripts/dns_del_acmedns' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_acmedns'
'dns_scripts/dns_del_azure' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_azure'
'dns_scripts/dns_del_challtestsrv' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_challtestsrv'
'dns_scripts/dns_del_clouddns' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_clouddns'
'dns_scripts/dns_del_cloudflare' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_cloudflare'
'dns_scripts/dns_del_cpanel' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_cpanel'
'dns_scripts/dns_del_dnspod' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_dnspod'
'dns_scripts/dns_del_duckdns' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_duckdns'
'dns_scripts/dns_del_dynu' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_dynu'
'dns_scripts/dns_del_godaddy' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_godaddy'
'dns_scripts/dns_del_hostway' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_hostway'
'dns_scripts/dns_del_ionos' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_ionos'
'dns_scripts/dns_del_ispconfig' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_ispconfig'
'dns_scripts/dns_del_joker' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_joker'
'dns_scripts/dns_del_lexicon' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_lexicon'
'dns_scripts/dns_del_linode' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_linode'
'dns_scripts/dns_del_manual' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_manual'
'dns_scripts/dns_del_nsupdate' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_nsupdate'
'dns_scripts/dns_del_ovh' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_ovh'
'dns_scripts/dns_del_pdns-mysql' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_pdns-mysql'
'dns_scripts/dns_del_vultr' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_vultr'
'dns_scripts/dns_del_windows_dns_server' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_del_windows_dns_server'
'dns_scripts/dns_freedns.sh' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_freedns.sh'
'dns_scripts/dns_godaddy' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_godaddy'
'dns_scripts/dns_route53.py' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/dns_route53.py'
'dns_scripts/ispconfig_soap.php' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/dns_scripts/ispconfig_soap.php'
'other_scripts/cpanel_cert_upload' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/other_scripts/cpanel_cert_upload'
'other_scripts/iis_install_certeficate.ps1' -> '/root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/usr/share/getssl/other_scripts/iis_install_certeficate.ps1'
+ install -Dpm 644 /root/rpmbuild/SOURCES/getssl.crontab /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/etc/cron.d/getssl
+ install -Dpm 644 /root/rpmbuild/SOURCES/getssl.logrotate /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64/etc/logrotate.d/getssl
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
Processing files: getssl-2.47-1.noarch
Provides: getssl = 2.47-1
Requires(interp): /bin/sh /bin/sh /bin/sh /bin/sh
Requires(rpmlib): rpmlib(CompressedFileNames) <= 3.0.4-1 rpmlib(FileDigests) <= 4.6.0-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1
Requires(pre): /bin/sh
Requires(post): /bin/sh
Requires(preun): /bin/sh
Requires(postun): /bin/sh
Requires: /bin/bash /usr/bin/env
Checking for unpackaged file(s): /usr/lib/rpm/check-files /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64
Wrote: /root/rpmbuild/SRPMS/getssl-2.47-1.src.rpm
Wrote: /root/rpmbuild/RPMS/noarch/getssl-2.47-1.noarch.rpm
Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.hgma8Q
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd getssl-2.47
+ /usr/bin/rm -rf /root/rpmbuild/BUILDROOT/getssl-2.47-1.x86_64
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
+ /bin/rm -rf getssl-2.47
+ /bin/gzip -dc /root/debbuild/SOURCES/getssl-2.47.tar.gz
+ /bin/tar -xf -
+ STATUS=0
+ '[' 0 -ne 0 ']'
+ cd getssl-2.47
+ /bin/chmod -Rf a+rX,u+w,go-w .
+ exit 0
Executing (%build): /bin/sh -e /var/tmp/deb-tmp.build.40956
+ umask 022
+ cd /root/debbuild/BUILD
+ cd getssl-2.47
+ exit 0
Executing (%install): /bin/sh -e /var/tmp/deb-tmp.install.36647
+ umask 022
+ cd /root/debbuild/BUILD
+ cd getssl-2.47
+ '[' -n /root/debbuild/BUILDROOT/getssl-2.47-1.amd64 -a /root/debbuild/BUILDROOT/getssl-2.47-1.amd64 '!=' / ']'
+ /bin/rm -rf /root/debbuild/BUILDROOT/getssl-2.47-1.amd64
+ /bin/mkdir -p /root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/bin
+ /bin/mkdir -p /root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts
+ /bin/mkdir -p /root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/other_scripts
+ /usr/bin/make DESTDIR=/root/debbuild/BUILDROOT/getssl-2.47-1.amd64 install
mkdir -p /root/debbuild/BUILDROOT/getssl-2.47-1.amd64
install -Dvm755 getssl /root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/bin/getssl
'getssl' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/bin/getssl'
install -dvm755 /root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl
for dir in *_scripts; do install -dv /root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/$dir; install -pv $dir/* /root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/$dir/; done
'dns_scripts/Azure-README.txt' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/Azure-README.txt'
'dns_scripts/Cloudflare-README.md' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/Cloudflare-README.md'
'dns_scripts/DNS_IONOS.md' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/DNS_IONOS.md'
'dns_scripts/DNS_ROUTE53.md' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/DNS_ROUTE53.md'
'dns_scripts/GoDaddy-README.txt' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/GoDaddy-README.txt'
'dns_scripts/dns_add_acmedns' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_acmedns'
'dns_scripts/dns_add_azure' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_azure'
'dns_scripts/dns_add_challtestsrv' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_challtestsrv'
'dns_scripts/dns_add_clouddns' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_clouddns'
'dns_scripts/dns_add_cloudflare' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_cloudflare'
'dns_scripts/dns_add_cpanel' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_cpanel'
'dns_scripts/dns_add_del_aliyun.sh' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_del_aliyun.sh'
'dns_scripts/dns_add_dnspod' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_dnspod'
'dns_scripts/dns_add_duckdns' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_duckdns'
'dns_scripts/dns_add_dynu' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_dynu'
'dns_scripts/dns_add_godaddy' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_godaddy'
'dns_scripts/dns_add_hostway' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_hostway'
'dns_scripts/dns_add_ionos' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_ionos'
'dns_scripts/dns_add_ispconfig' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_ispconfig'
'dns_scripts/dns_add_joker' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_joker'
'dns_scripts/dns_add_lexicon' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_lexicon'
'dns_scripts/dns_add_linode' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_linode'
'dns_scripts/dns_add_manual' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_manual'
'dns_scripts/dns_add_nsupdate' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_nsupdate'
'dns_scripts/dns_add_ovh' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_ovh'
'dns_scripts/dns_add_pdns-mysql' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_pdns-mysql'
'dns_scripts/dns_add_vultr' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_vultr'
'dns_scripts/dns_add_windows_dns_server' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_add_windows_dns_server'
'dns_scripts/dns_del_acmedns' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_acmedns'
'dns_scripts/dns_del_azure' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_azure'
'dns_scripts/dns_del_challtestsrv' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_challtestsrv'
'dns_scripts/dns_del_clouddns' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_clouddns'
'dns_scripts/dns_del_cloudflare' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_cloudflare'
'dns_scripts/dns_del_cpanel' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_cpanel'
'dns_scripts/dns_del_dnspod' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_dnspod'
'dns_scripts/dns_del_duckdns' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_duckdns'
'dns_scripts/dns_del_dynu' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_dynu'
'dns_scripts/dns_del_godaddy' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_godaddy'
'dns_scripts/dns_del_hostway' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_hostway'
'dns_scripts/dns_del_ionos' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_ionos'
'dns_scripts/dns_del_ispconfig' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_ispconfig'
'dns_scripts/dns_del_joker' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_joker'
'dns_scripts/dns_del_lexicon' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_lexicon'
'dns_scripts/dns_del_linode' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_linode'
'dns_scripts/dns_del_manual' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_manual'
'dns_scripts/dns_del_nsupdate' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_nsupdate'
'dns_scripts/dns_del_ovh' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_ovh'
'dns_scripts/dns_del_pdns-mysql' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_pdns-mysql'
'dns_scripts/dns_del_vultr' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_vultr'
'dns_scripts/dns_del_windows_dns_server' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_del_windows_dns_server'
'dns_scripts/dns_freedns.sh' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_freedns.sh'
'dns_scripts/dns_godaddy' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_godaddy'
'dns_scripts/dns_route53.py' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/dns_route53.py'
'dns_scripts/ispconfig_soap.php' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/dns_scripts/ispconfig_soap.php'
'other_scripts/cpanel_cert_upload' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/other_scripts/cpanel_cert_upload'
'other_scripts/iis_install_certeficate.ps1' -> '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/usr/share/getssl/other_scripts/iis_install_certeficate.ps1'
+ install -Dpm 644 /root/debbuild/SOURCES/getssl.crontab /root/debbuild/BUILDROOT/getssl-2.47-1.amd64/etc/cron.d/getssl
+ install -Dpm 644 /root/debbuild/SOURCES/getssl.logrotate /root/debbuild/BUILDROOT/getssl-2.47-1.amd64/etc/logrotate.d/getssl
+ exit 0
Checking library requirements...
Executing (package-creation): /bin/sh -e /var/tmp/deb-tmp.pkg.6107 for getssl
+ umask 022
+ cd /root/debbuild/BUILD
+ /usr/bin/fakeroot -- /usr/bin/dpkg-deb -b /root/debbuild/BUILDROOT/getssl-2.47-1.amd64/main /root/debbuild/DEBS/all/getssl_2.47-1_all.deb
dpkg-deb: warning: parsing file '/root/debbuild/BUILDROOT/getssl-2.47-1.amd64/main/DEBIAN/control' near line 10 package 'getssl':
 missing 'Maintainer' field
dpkg-deb: warning: ignoring 1 warning about the control file(s)
dpkg-deb: building package 'getssl' in '/root/debbuild/DEBS/all/getssl_2.47-1_all.deb'.
+ exit 0
Executing (%clean): /bin/sh -e /var/tmp/deb-tmp.clean.52780
+ umask 022
+ cd /root/debbuild/BUILD
+ '[' /root/debbuild/BUILDROOT/getssl-2.47-1.amd64 '!=' / ']'
+ /bin/rm -rf /root/debbuild/BUILDROOT/getssl-2.47-1.amd64
+ exit 0
Wrote source package getssl-2.47-1.sdeb in /root/debbuild/SDEBS.
Wrote binary package getssl_2.47-1_all.deb in /root/debbuild/DEBS/all
```

## Issues / problems / help

If you have any issues, please log them at <https://github.com/srvrco/getssl/issues>

There are additional help pages on the [wiki](https://github.com/srvrco/getssl/wiki)

If you have any suggestions for improvements then pull requests are
welcomed, or raise an issue.
