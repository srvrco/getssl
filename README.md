# getssl <!-- omit in toc -->

![Run all tests](https://github.com/srvrco/getssl/workflows/Run%20all%20tests/badge.svg) ![shellcheck](https://github.com/srvrco/getssl/workflows/shellcheck/badge.svg)

Obtain SSL certificates from the letsencrypt.org ACME server. Suitable
for automating the process on remote servers.

## Table of Contents <!-- omit in toc -->
- [Features](#features)
- [Installation](#installation)
- [Overview](#overview)
- [Getting started](#getting-started)
- [Detailed guide to getting started with more examples](#detailed-guide-to-getting-started-with-more-examples)
- [Wildcard certificates](#wildcard-certificates)
- [Automating updates](#automating-updates)
- [Structure](#structure)
- [Server-Types](#server-types)
- [Revoke a certificate](#revoke-a-certificate)
- [Elliptic curve keys](#elliptic-curve-keys)
- [Preferred Chain](#preferred-chain)
- [Include Root certificate in full chain](#include-root-certificate-in-full-chain)
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

## Installation

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
```

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

## Issues / problems / help

If you have any issues, please log them at <https://github.com/srvrco/getssl/issues>

There are additional help pages on the [wiki](https://github.com/srvrco/getssl/wiki)

If you have any suggestions for improvements then pull requests are
welcomed, or raise an issue.
