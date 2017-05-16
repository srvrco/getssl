Using GoDaddy DNS for LetsEncrypt domain validation.

Quick guide to setting up getssl for domain validation of
GoDaddy DNS domains.

There are two prerequisites to using getssl with GoDaddy DNS:

1) Obtain an API access key from developer.godaddy.com
   At first sign-up, you will be required to take a "test" key.
   This is NOT what you need.  Accept it, then get a "Production"
   key.  At this writing, there is no charge - but you must have
   a GoDaddy customer account.

   You must get the API key for the account which owns the domain
   that you want to get certificates for.  If the domains that you
   manage are owned by more than one account, get a key for each.

   The access key consists of a "Key" and a "Secret".  You need
   both.

2) Obtain JSON.sh - https://github.com/dominictarr/JSON.sh

With those in hand, the installation procedure is:

1) Put JSON.sh in the getssl DNS scripts directory 
   Default: /usr/share/getssl/dns_scripts

2) Open your config file (the global file in ~/.getssl/getssl.cfg
   or the per-account file in ~/.getssl/example.net/getssl.cfg

3) Set the following options:
   VALIDATE_VIA_DNS="true"
   DNS_ADD_COMMAND="/usr/share/getssl/dns_scripts/dns_add_godaddy"
   DNS_DEL_COMMAND="/usr/share/getssl/dns_scripts/dns_del_godaddy"
   # The API key for your account/this domain
   export GODADDY_KEY="..." GODADDY_SECRET="..."

 4) Set any other options that you wish (per the standard
   directions.)  Use the test CA to make sure that
   everything is setup correctly.

That's it.  getssl example.net will now validate with DNS.

To trace record additions and removals, run getssl as
GODADDY_TRACE=Y getssl example.net

There are additional options, which are documented in the
*godaddy" files and dns_godaddy -h.

Copyright (2017) Timothe Litt  litt at acm _dot org

This sofware may be freely used providing this notice is included with
all copies.  The name of the author may not be used to endorse
any other product or derivative work.  No warranty is provided
and the user assumes all responsibility for use of this software.

Report any issues to https://github.com/tlhackque/getssl/issues.

Enjoy.

