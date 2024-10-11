# Yandex DNS management via Yandex API

## Requrements

- [JQ](https://jqlang.github.io/jq/) command-line JSON processor needed

## Useful links

- [Yandex API Access](https://yandex.ru/dev/api360/doc/concepts/access.html)
- [Yandex DNS API](https://yandex.ru/dev/api360/doc/ref/DomainDNSService.html)

## Yandex Auth parameters in domain config file

0. Authorize in Your Yandex Account in web browser. You must have Administartor rights
1. Get `OrgId` from Your Comapny Profile - <https://admin.yandex.ru/company-profile> (You have Your first important variable `YANDEX_ORGID` now!)
2. Create Your new application for DNS management - <https://oauth.yandex.ru/client/new/id>
3. Get `ClientID` for this application on application page
4. Get `OAuthToken` for this application from URL <https://oauth.yandex.ru/authorize?response_type=token&client_id=ClientID> in authtorised browser  where `ClientID` code from previous step. This is Your second secret variable `YANDEX_OAUTH`!
5. Define this variables in domain config file

```bash
# Use the following 3 variables if you want to validate via DNS
VALIDATE_VIA_DNS="true"
DNS_ADD_COMMAND="/usr/share/getssl/dns_scripts/dns_yandex add"
DNS_DEL_COMMAND="/usr/share/getssl/dns_scripts/dns_yandex del"
DNS_WAIT="600" # Waiting 10 minutes. Very-very-very slow distrbution

# Yandex base DNS
AUTH_DNS_SERVER="77.88.8.8"

# Yandex Authentication credintals
export YANDEX_ORGID="<OrgId>"
export YANDEX_OAUTH="<OAuthToken>"
```

## Manual run

- `/usr/share/getssl/dns_scripts/dns_yandex add domain.tld <token>` - add `<token> TXT _acme-challenge.domain.tld` record
- `/usr/share/getssl/dns_scripts/dns_yandex add subdomain.domain.tld <token>` - add `<token> TXT _acme-challenge.subdomain.domain.tld` record
- `/usr/share/getssl/dns_scripts/dns_yandex del domain.tld <token>` - delete `<token> TXT _acme-challenge.domain.tld` record
- `/usr/share/getssl/dns_scripts/dns_yandex del subdomain.domain.tld <token>` - delete `<token> TXT _acme-challenge.subdomain.domain.tld` record

- `/usr/share/getssl/dns_scripts/dns_yandex cleanup domain.tld` - cleanup all dangling `_acme-challenge` records from DNS for <domain.tld>
- `/usr/share/getssl/dns_scripts/dns_yandex cleanup subdomain.domain.tld` - cleanup all dangling `_acme-challenge.subdomain` records from DNS for <subdomain.domain.tld>
- `/usr/share/getssl/dns_scripts/dns_yandex cleanup [subdomain.]domain.tld <token>` - cleanup all dangling `_acme-challenge` domain or subdomain records with `<token>`
