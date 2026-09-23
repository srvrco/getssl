# PowerDNS API

These helper scripts use the PowerDNS HTTP API for DNS-01 validation.

## Requirements

- PowerDNS authoritative server with the HTTP API enabled
- `curl`
- `jq`

## Environment

Set these environment variables before running `getssl`:

- `PDNS_API_URL`
  Example: `https://ns1.example.com/pdns`
- `PDNS_API_KEY`
  API token for the PowerDNS server

Optional:

- `PDNS_SERVER_ID`
  Default: `localhost`
- `PDNS_TTL`
  Default: `120`

## Example `getssl.cfg`

```sh
VALIDATE_VIA_DNS="true"
DNS_ADD_COMMAND="/usr/share/getssl/dns_scripts/dns_add_pdns-api"
DNS_DEL_COMMAND="/usr/share/getssl/dns_scripts/dns_del_pdns-api"

export PDNS_API_URL="https://ns1.example.com/pdns"
export PDNS_API_KEY="your-api-token"
# export PDNS_SERVER_ID="localhost"
# export PDNS_TTL="120"
```
