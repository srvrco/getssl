# getssl using Google Cloud DNS

https://github.com/kshji/getssl_gcloud

ver 2025-09-13

## You need install gcloud command

[Gcloud install](gle.com/sdk/docs/install)

If you are using *nix server without desktop (x-term), remove DISPLAY set if it's.
If you have set DISPLAY, try init process to start local chrome GUI process.
``` sh
unset DISPLAY
```

Init gcloud using, need to do once.

``` sh
gcloud init
```

Need also Google Cloud Console Service Account:
[Google Cloud Console Service Account](https://console.cloud.google.com/projectselector2/iam-admin/serviceaccounts )

* Permissions role "DNS Zone Editor" or "DNS Administrator"
* tab Keys generate Key, JSON: result is JSON keyfile

Service Account  account is email, usually something like  xxx@xxx.gserviceaccount.com

***Example*** using keyfile:

``` sh
gcloud auth activate-service-account xxx@xxx.gserviceaccount.com --key-file=/somepath/PROJECT_ID_xxxxx.json
```

After auth you can use gcloud dns services.

***Example***: Get zones from your Google Cloud DNS project:

``` sh
gcloud dns managed-zones list --project=PROJECT_ID
``` 

More gcloud dns commands: [Reference DNS](https://google.com/sdk/gcloud/reference/dns)

***Example***: List domain TXT records:

``` sh
gcloud dns record-sets list --zone=ZONEID --name="example.com." --type="TXT" 
```

ZONEID is usually ex. for domain example.com it is ***examplecom***

## getssl configuration DNS validation using Google Cloud DNS

example.com/getssl.cfg

``` sh
CA="https://acme-v02.api.letsencrypt.org"
SANS="*.example.com"

#Set this to "true" to enable DNS validation
VALIDATE_VIA_DNS="true"             
# Google Cloud DNS setup
# Use this command/script to add the challenge token to the DN#S entries for the domain
DNS_ADD_COMMAND="/somepath/dns_gcloud -c add "              
# Use this command/script to remove the challenge token from the DNS entries for the domain
DNS_DEL_COMMAND="/somepath/dns_gcloud -c del "        

# example.com setup Google Cloud DNS validation
export GCLOUD_ZONE="examplecom"          # Google Cloud DNS zoneid
export GCLOUD_PROJECTID="mydnsproject"   # Google Cloud projectid
# Google Cloud Service Account
export GCLOUD_ACCOUNT="someuser@mydnsproject.iam.gserviceaccount.com"  
export GCLOUD_KEYFILE="/somepath/mydnsprojectSomeid.json"

```

## dns_cloud manual

 * default host is _acme-challenge.
 * default ttl is 60 s.
 * default sleep after gcloud process is 10 s.
 * default debug is 0 = off
 * env variables have to setup before using `dns_gcloud`:
   * GCLOUD_ZONE
   * GCLOUD_PROJECTID
   * GCLOUD_ACCOUNT
   * GCLOUD_KEYFILE

### get help
``` sh
dns_gloud -?
dns_gloud --help
```

### Add TXT token
Add TXT token "testN"", host _acme-challenge.example.com

``` sh
dns_gloud -c add example.com "testN"
```
 
Add TXT token "testN"", host somehost.example.com
``` sh
dns_gloud -h somehost -c add example.com "testN"
```

### Del TXT token
Del TXT token "testN"", host _acme-challenge.example.com
``` sh
dns_gloud -c del example.com "testN"
```
Del TXT token "testN"", host somehost.example.com
``` sh
dns_gloud -h somehost -c del example.com "testN"
```

### List TXT token

List host TXT tokens, default host _acme-challenge
``` sh
dns_gloud -c list example.com 
```

List domain TXT tokens, not host. Set host empty string.
``` sh
dns_gloud -h "" -c list example.com 
```


### Extra options

Debug messages, option -d with argument 0 or 1. 
Some debug messages to the stdout and log env settings to file to dir ***/var/tmp/getssl***

``` sh
dns_gloud -d 1 -h "" -c list example.com 
```

Change default 60 second ttl value when adding. Remember,when deleting, ttl have to be same.
``` sh
dns_gloud -c add -t 300 example.com "testN"
```
Change default 10 second sleep after process
``` sh
dns_gloud -c add -s 5 example.com "testN"
```

