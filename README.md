# getssl
get an SSL certificate via LetsEncryot.  Suitable for automating the process in remote servers. 

This was written as an addition to checkssl for servers to automatically renew certifictes.  In addition it allows the running of this script in standard bash ( on a desktop computer, or even virtualbox) and add the checks, and certificates to a remote server ( providing you have an ssh key on the remote server with access). Potentially I can include FTP as an option for uploading as well. 

   getssl ver. 0.1
   To obtain a letsencrypt SSL cert

   Usage: getssl [-h|--help] [-d|--debug] [-c] [-w working_dir] domain

   Options:
  -h, --help  Display this help message and exit.
  -d, --debug  outputs debug information
  -c,          Create default config files
  -w working_dir  working directory
    Where 'working_dir' is the Working Directory.


## Structure

The design aim was to provide flexibility in running the code.  The default working directory is ~/.getssl ( which can be modified via the command line)

Within the **working directory** is a config file, getssl.cfg which is a simple bash file containing variables, an example of which is 

```
# uncomment and modify any variables you need
# The staging server is best for testing
CA="https://acme-staging.api.letsencrypt.org"
# This server issues full certificates, however has rate limits
#CA="https://acme-v01.api.letsencrypt.org"

AGREEMENT="https://letsencrypt.org/documents/LE-SA-v1.0.1-July-27-2015.pdf"

#set an email address associated with your account 
ACCOUNT_EMAIL="me@example.com"
ACCOUNT_KEY_LENGTH=4096

#The default directory for all your certs to be stored within ( in subdirectories by domain name ) 
WORKING_DIR=~/.getssl

# the command needed to reload apache / gninx or whatever you use
#RELOAD_CMD=""
#The time period within which you want to allow renewal of a certificate - this prevents hitting some of the rate limits. 
RENEW_ALLOW="30"`
```

then, within the **working directory** there will be a folder for each certificate (based on it's domain name). Within that folder will be a config file (again called getssl.cfg).  An example of which is;

```
# uncomment and modify any variables you need
# The staging server is best for testing
#CA="https://acme-staging.api.letsencrypt.org"
# This server issues full certificates, however has rate limits
#CA="https://acme-v01.api.letsencrypt.org"

#AGREEMENT="https://letsencrypt.org/documents/LE-SA-v1.0.1-July-27-2015.pdf"

#set an email address associated with your account - generally set at account level rather than domain. 
#ACCOUNT_EMAIL="me@example.com"
#ACCOUNT_KEY_LENGTH=4096

# additional domains - this could be multiple domains / subdomains in a comma separated list
SANS=www.testdomain.com

#Acme Challenge Location.   The first line for the domain, the following ones for each additional domain
#if these start with ssh: then the next variable is assumed to be the hostname and the rest the location.
#an ssh key will be needed to provide you with access to the remote server.
#ACL=('/var/www/testdomain.com/web/.well-known/acme-challenge'
#     'ssh:server5:/var/www/testdomain.com/web/.well-known/acme-challenge')

# location for all your certs these can either be on the server ( so full path name) or using ssh as for the ACL
#DOMAIN_CERT_LOCATION="ssh:server5:/home/domain/public_html/.well-known/acme-challenge/domain.crt"
#DOMAIN_KEY_LOCATION="ssh:server5:/home/domain/public_html/.well-known/acme-challenge/domain.key"
#CA_CERT_LOCATION="/etc/ssl/chain.crt"
# the command needed to reload apache / gninx or whatever you use
#RELOAD_CMD="ssh:server5:service apache2 reload"
#The time period within which you want to allow renewal of a certificate - this prevents hitting some of the rate limits. 
#RENEW_ALLOW="30"`
```

if a location for a file starts with ssh:  it is assumed the next part of the file is the hostname, followed by a colon, and then the path. 
files will be copied using scp, and it assumes that you have a key on the server ( for passwordless access).  You can set the user, port etc for the server in your .ssh/config file

ssh can also be used for the reload command if using on remote servers. 

## Getting started

The easiest way to get started is to use

```
getssl -c yourdomain.com 
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
