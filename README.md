# getssl
Obtain SSL certificates from the letsencrypt.org ACME server.  Suitable for automating the process on remote servers. 

This was written in standard bash ( so can be run on a server,  a desktop computer, or even virtualbox) and add the checks, and certificates to a remote server ( providing you have an ssh key on the remote server with access).  

```
getssl ver. 0.42
Obtain SSL certificates from the letsencrypt.org ACME server

Usage: getssl [-h|--help] [-d|--debug] [-c|--create] [-f|--force] [-a|--all] [-q|--quiet] [-u|--upgrade] [-w working_dir] domain

Options:
  -h, --help      Display this help message and exit
  -d, --debug     Outputs debug information
  -c, --create    Create default config files
  -f, --force     Force renewal of cert (overrides expiry checks)
  -a, --all       Check all certificates
  -q, --quiet     Quiet mode (only outputs on error)
  -u, --upgrade   Upgrade getssl if more recent version available
  -w working_dir  Working directory
```

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
#ACCOUNT_EMAIL="me@example.com"
ACCOUNT_KEY_LENGTH=4096
ACCOUNT_KEY="/home/andy/.getssl/account.key"
PRIVATE_KEY_ALG="rsa"

# The command needed to reload apache / nginx or whatever you use
#RELOAD_CMD=""
# The time period within which you want to allow renewal of a certificate - this prevents hitting some of the rate limits.
RENEW_ALLOW="30"
# Define the server type.  If it's a "webserver" then the main website will be checked for certificate expiry 
# and also will be checked after an update to confirm correct certificate is running. 
#SERVER_TYPE="webserver"

# openssl config file.  The default should work in most cases.
SSLCONF="/usr/lib/ssl/openssl.cnf"

# Use the following 3 variables if you want to validate via DNS
#VALIDATE_VIA_DNS="true"
#DNS_ADD_COMMAND=
#DNS_DEL_COMMAND=
# If your DNS-server needs extra time to make sure your DNS changes are readable by the ACME-server (time in seconds)
#DNS_EXTRA_WAIT=60

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
#ACCOUNT_KEY="/home/andy/.getssl/account.key"
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

# Define the server type.  The can either webserver, ldaps or a port number which
# will be checked for certificate expiry and also will be checked after
# an update to confirm correct certificate is running (if CHECK_REMOTE) is set to true
#SERVER_TYPE="webserver"
#CHECK_REMOTE="true"

# Use the following 3 variables if you want to validate via DNS
#VALIDATE_VIA_DNS="true"
#DNS_ADD_COMMAND=
#DNS_DEL_COMMAND=
# If your DNS-server needs extra time to make sure your DNS changes are readable by the ACME-server (time in seconds)
#DNS_EXTRA_WAIT=60
```

if a location for a file starts with ssh:  it is assumed the next part of the file is the hostname, followed by a colon, and then the path. 
files will be copied using scp, and it assumes that you have a key on the server ( for passwordless access).  You can set the user, port etc for the server in your .ssh/config file

if an ACL starts with ftp: or sftp: it as assumed that the line is in the format "ftp:UserID:Password:someserver.com:/path/to/acme-challenge". sftp requires sshpass.
Note:  FTP can not be used for uploading private key or certificates as it's not a secure method of transfer. 

ssh can also be used for the reload command if using on remote servers. 

## Getting started

First you need to download the script.   You can either use git, or simply

```
curl --silent https://raw.githubusercontent.com/srvrco/getssl/master/getssl > getssl ; chmod 700 getssl
```

Once downloaded, the next step is to use

```
./getssl -c yourdomain.com 
```

where yourdomain.com is the primary domain name that you want to create a certificate for.   This will create

```
~/.getssl
~/.getssl/getssl.cfg
~/.getssl/yourdomain.com
~/.getssl/yourdomain.com/getssl.cfg
```

You can then edit ~/.getssl/getssl.cfg to have the values you want as the default for the majority of your certificates. 
Edit ~/.getssl/yourdomain.com/getssl.cfg to have the values you want for this specific domain. 

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
The intermediate CA cert is in /home/andy/.getssl/yourdomain.com/chain.crt
copying domain certificate to ssh:server5:/home/yourdomain/ssl/domain.crt
copying private key to ssh:server5:/home/yourdomain/ssl/domain.key
copying CA certificate to ssh:server5:/home/yourdomain/ssl/chain.crt
reloading SSL services
```
This will (by default) used the staging server, so should give you a certificate that isn't trusted ( Fake Let's Encrypt).
Change the server in your config file to get a fully valid certificate. 

Note:   Using DNS validation is now working successfully for issuing certificates. (examples provided on the wiki pages - https://github.com/srvrco/getssl/wiki/DNS-Challenge-example ) 
 
## Automating updates

I use 2 seperate crons, so my crontab looks like 
```
23  5 * * * /root/scripts/getssl -u -q
47  5 * * * /root/scripts/getssl -a -q
```
The first cron will update getssl if there are any more recent versions available (the -u flag).   I use the -q flag so it only outputs and emails me if it has upgraded. 

The second cron runs though all certificates (the -a flag) and uutomatically renews any certificates thatare due for renewal.   I use the -q flag so that it only outputs and emails me if any certificates were updated, or there was an error / issue.