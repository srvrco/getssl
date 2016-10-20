# getssl
Obtain SSL certificates from the letsencrypt.org ACME server.  Suitable for automating the process on remote servers.

## Features
* **Bash** - It runs on virtually all linux machines, including BSD, Slackware, MAC OSX.
* **Get certificates for remote servers** - The tokens used to provide validation of domain ownership, and the certificates themselves can be automatically copied to remote servers (via ssh, sftp or ftp for tokens). The script doesn't need to run on the server itself. This can be useful if you don't have access to run such scripts on the server itself, as it's a shared server for example.
* **Runs as a daily cron** - so certificates will be automatically renewed when required.
* **Automatic certificate renewals**
* **Checks certificates are correctly loaded**. After installation of a new certificate it will test the port specified ( see [Server-Types](#server-types) for options ) that the certificate is actually being used correctly.
* **Automatically updates** - The script can automatically update itself with bug fixes etc if required.
* **Extensively configurable** - With a simple configuration file for each certificate it is possible to configure it exactly for your needs, whether a simple single domain or multiple domains across multiple servers on the same certificate.
* **Supports http and dns challenges** - Full ACME implementation
* **Simple and easy to use**
* **Detailed debug info** - Whilst it shouldn't be needed, detailed debug information is available.
* **Reload services** - After a new certificate is obtained then the relevant services (e.g. apache/nginx/postfix) can be reloaded.

## Installation
Since the script is only one file, you can use the command
```
curl --silent https://raw.githubusercontent.com/srvrco/getssl/master/getssl > getssl ; chmod 700 getssl
```
Which will copy the getssl bash script to the current location and change the permissions to make it executable for you.

Alternative you can use git
```
git clone https://github.com/srvrco/getssl.git
```

## Overview

GetSSL was written in standard bash ( so can be run on a server,  a desktop computer, or even a virtualbox) and add the checks, and certificates to a remote server ( providing you have a ssh with key, sftp or ftp access to the remote server).

```
getssl ver. 1.64
Obtain SSL certificates from the letsencrypt.org ACME server

Usage: getssl [-h|--help] [-d|--debug] [-c|--create] [-f|--force] [-a|--all] [-q|--quiet] [-Q|--mute] [-u|--upgrade] [-U|--nocheck] [-r|--revoke cert key] [-w working_dir] domain

Options:
  -a, --all       Check all certificates
  -d, --debug     Outputs debug information
  -c, --create    Create default config files
  -f, --force     Force renewal of cert (overrides expiry checks)
  -h, --help      Display this help message and exit
  -q, --quiet     Quiet mode (only outputs on error, success of new cert, or getssl was upgraded)
  -Q, --mute      Like -q, but mutes notification about successful upgrade
  -r, --revoke cert key  Revoke a certificate ( the cert and key are required)
  -u, --upgrade   Upgrade getssl if a more recent version is available
  -U, --nocheck   Do not check if a more recent version is available
  -w working_dir  Working directory
```

## Getting started

Once you have obtained the script (see Installation above), the next step is to use

```./getssl -c yourdomain.com```

where yourdomain.com is the primary domain name that you want to create a certificate for.   This will create the following folders and files.

```
~/.getssl
~/.getssl/getssl.cfg
~/.getssl/yourdomain.com
~/.getssl/yourdomain.com/getssl.cfg
```

You can then edit ~/.getssl/getssl.cfg to set the values you want as the default for the majority of your certificates.

Then edit ~/.getssl/yourdomain.com/getssl.cfg to have the values you want for this specific domain (make sure to uncomment and specify correct `ACL` option, since it is required).

You can then just run;

```getssl yourdomain.com ```

and it should run, providing output like;
```
Registering account
Verify each domain
Verifing yourdomain.com
Verified yourdomain.com
Verifing www.yourdomain.com
Verified www.yourdomain.com
Verification completed, obtaining certificate.
Certificate saved in /home/user/.getssl/yourdomain.com/yourdomain.com.crt
The intermediate CA cert is in /home/user/.getssl/yourdomain.com/chain.crt
copying domain certificate to ssh:server5:/home/yourdomain/ssl/domain.crt
copying private key to ssh:server5:/home/yourdomain/ssl/domain.key
copying CA certificate to ssh:server5:/home/yourdomain/ssl/chain.crt
reloading SSL services
```
**This will (by default) use the staging server, so should give you a certificate that isn't trusted ( Fake Let's Encrypt).**
Change the server in your config file to get a fully valid certificate.

**Note:**   Verification is done via port 80(http), port 443(https) or dns.  The certificate can be used ( and checked with getssl) on alternate ports.
 
## Automating updates

I use the following cron
```
23  5 * * * /root/scripts/getssl -u -a -q
```
The cron will automatically update getssl and  renew any certificates, only giving output if there are issues / errors.

* The -u flag updates getssl if there is a more recent version available.
* The -a flag automatically renews any certificates that are due for renewal.
* The -q flag is "quiet" so that it only outputs and emails me if there was an error / issue.

## Structure

The design aim was to provide flexibility in running the code.  The default working directory is ~/.getssl ( which can be modified via the command line)

Within the **working directory** is a config file, getssl.cfg which is a simple bash file containing variables, an example of which is 

```
# Uncomment and modify any variables you need
# The staging server is best for testing (hence set as default)
CA="https://acme-staging.api.letsencrypt.org"
# This server issues full certificates, however has rate limits
#CA="https://acme-v01.api.letsencrypt.org"

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

then, within the **working directory** there will be a folder for each certificate (based on it's domain name). Within that folder will be a config file (again called getssl.cfg).  An example of which is;

```
# Uncomment and modify any variables you need
# The staging server is best for testing
#CA="https://acme-staging.api.letsencrypt.org"
# This server issues full certificates, however has rate limits
#CA="https://acme-v01.api.letsencrypt.org"

#AGREEMENT="https://letsencrypt.org/documents/LE-SA-v1.0.1-July-27-2015.pdf"

# Set an email address associated with your account - generally set at account level rather than domain.
#ACCOUNT_EMAIL="me@example.com"
#ACCOUNT_KEY_LENGTH=4096
#ACCOUNT_KEY="/home/user/.getssl/account.key"
PRIVATE_KEY_ALG="rsa"

# Additional domains - this could be multiple domains / subdomains in a comma separated list
SANS=www.example.org,example.edu,example.net,example.org,www.example.com,www.example.edu,www.example.net

# Acme Challenge Location. The first line for the domain, the following ones for each additional domain.
# If these start with ssh: then the next variable is assumed to be the hostname and the rest the location.
# An ssh key will be needed to provide you with access to the remote server.
# If these start with ftp: or sftp: then the next variables are userid:password:servername:ACL_location
ACL=('/var/www/example.com/web/.well-known/acme-challenge'
     'ssh:server5:/var/www/example.com/web/.well-known/acme-challenge'
     'ftp:ftpuserid:ftppassword:example.com:/web/.well-known/acme-challenge')

# Location for all your certs, these can either be on the server (so full path name) or using ssh as for the ACL
DOMAIN_CERT_LOCATION="ssh:server5:/etc/ssl/domain.crt"
DOMAIN_KEY_LOCATION="ssh:server5:/etc/ssl/domain.key"
#CA_CERT_LOCATION="/etc/ssl/chain.crt"
#DOMAIN_CHAIN_LOCATION="" this is the domain cert and CA cert
#DOMAIN_PEM_LOCATION="" this is the domain_key. domain cert and CA cert


# The command needed to reload apache / nginx or whatever you use
RELOAD_CMD="service apache2 reload"
# The time period within which you want to allow renewal of a certificate - this prevents hitting some of the rate limits.
#RENEW_ALLOW="30"

# Define the server type. This can be https, ftp, ftpi, imap, imaps, pop3, pop3s, smtp,
# smtps_deprecated, smtps, smtp_submission, xmpp, xmpps, ldaps or a port number which
# will be checked for certificate expiry and also will be checked after
# an update to confirm correct certificate is running (if CHECK_REMOTE) is set to true
#SERVER_TYPE="https"
#CHECK_REMOTE="true"

# Use the following 3 variables if you want to validate via DNS
#VALIDATE_VIA_DNS="true"
#DNS_ADD_COMMAND=
#DNS_DEL_COMMAND=
# If your DNS-server needs extra time to make sure your DNS changes are readable by the ACME-server (time in seconds)
#DNS_EXTRA_WAIT=60
```

If a location for a file starts with ssh:  it is assumed the next part of the file is the hostname, followed by a colon, and then the path. 
Files will be securely copied using scp, and it assumes that you have a key on the server ( for passwordless access).  You can set the user, port etc for the server in your .ssh/config file

If an ACL starts with ftp: or sftp: it as assumed that the line is in the format "ftp:UserID:Password:servername:/path/to/acme-challenge". sftp requires sshpass.
Note:  FTP can be used for copying tokens only and can **not** be used for uploading private key or certificates as it's not a secure method of transfer.

ssh can also be used for the reload command if using on remote servers.


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


##Revoke a certificate

In general revoking a certificate is not required.

usage: getssl -r path/to/cert path/to/key

You need to specify both the certificate you want to revoke, and the account key which was used to sign / obtain the original key.


## Issues / problems / help
If you have any issues, please log them at https://github.com/srvrco/getssl/issues

There are additional help pages on the wiki - https://github.com/srvrco/getssl/wiki

If you have any suggestions for improvements then pull requests are welcomed, or raise an issue.
