## Using Cloudflare DNS for LetsEncrypt domain validation

### Enabling the scripts

Set the following options in `getssl.cfg` (either global or domain-specific):

```
VALIDATE_VIA_DNS="true"
DNS_ADD_COMMAND="/usr/share/getssl/dns_scripts/dns_add_cloudflare"
DNS_DEL_COMMAND="/usr/share/getssl/dns_scripts/dns_del_cloudflare"
```

### Authentication

There are 2 methods of authenticating with Cloudflare:

1. API Keys - Account level, all-purpose tokens
2. API Tokens - Scoped and permissioned access to resources

Both are configured from your profile in the [Cloudflare dashboard][1]

[1]: https://dash.cloudflare.com/profile/api-tokens

#### API Keys

The **Zone ID** for the domain will be searched for programmatically.

Set the following options in `getssl.cfg`:

```
export CF_EMAIL="..." # Cloudflare account email address
export CF_KEY="..."   # Global API Key
```

#### API Tokens

Cloudflare provides a template for creating an API Token with access to edit
zone records.  Tokens must be created with at least '**DNS:Edit** permissions
for the domain to add/delete records.

Set the following options in the domain-specific `getssl.cfg`

```
export CF_API_TOKEN="..."
```

By default, the associated **Zone ID** is searched automatically. However, it
is also possible to configure the Zone ID manually. This might be necessary
if there are a lot of zones. You can find the Zone ID at the Overview tab in
the Cloudflare Dashboard.

```
export CF_ZONE_ID="..."
```

__Note__: API Keys will be used instead if also configured 
