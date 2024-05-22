# Using Route53 BASH scripts for LetsEncrypt domain validation.

## Quick guide to setting up getssl for domain validation of Route53 DNS domains.

There a few prerequisites to using getssl with Route53 DNS:

1. You will need to set up an IAM user with the necessary permissions to modify resource records in the hosted zone.

   - route53:ListHostedZones
   - route53:ChangeResourceRecordSets

1. You will need the AWS CLI Client installed on your machine.

1. You will need to configure the client for the IAM user that has permission to modify the resource records.

With those in hand, the installation procedure is:

1. Open your config file (the global file in ~/.getssl/getssl.cfg
   or the per-account file in ~/.getssl/example.net/getssl.cfg)

1. Set the following options:

   - VALIDATE_VIA_DNS="true"
   - DNS_ADD_COMMAND="/usr/share/getssl/dns_scripts/dns_add_route53"
   - DNS_DEL_COMMAND="/usr/share/getssl/dns_scripts/dns_del_route53"

   The AWS CLI profile to use (will use _default_ if not specified)

   - export AWS*CLI_PROFILE="\_profile name*"

1. Set any other options that you wish (per the standard
   directions.) Use the test CA to make sure that
   everything is setup correctly.

That's it. getssl example.net will now validate with DNS.

There are additional options, which are documented in `dns_route53 -h`
