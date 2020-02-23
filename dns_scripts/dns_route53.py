#!/usr/bin/env python

import boto3, sys, time
from os.path import basename
import dns.resolver

client = boto3.client('route53')

name = sys.argv[0]
fqdn = sys.argv[1]
challenge = sys.argv[2]

bname = basename(name)
if bname == 'dns_add_route53':
    action = 'UPSERT'
elif bname == 'dns_del_route53':
    action = 'DELETE'
else:
    print("No such action: {a}".format(a=bname))
    sys.exit(1)

try:
    response = client.list_hosted_zones()
except Exception as e:
    print("Oops: {e!r}".format(e=e))
    sys.exit(1)

zone_id = ""
zone_list = dict()
for zone in response['HostedZones']:
    if not zone['Config']['PrivateZone']:
        zone_list[zone['Name']] = zone['Id']

for key in sorted(zone_list.iterkeys(), key=len, reverse=True):
    if ".{z}".format(z=key) in ".{z}.".format(z=fqdn):
       zone_id = zone_list[key]

if zone_id == "":
    print("We didn't find the zone")
    sys.exit(1)

challenge_fqdn = "_acme-challenge.{f}".format(f=fqdn)
try:
    response = client.change_resource_record_sets(
        HostedZoneId=zone_id,
        ChangeBatch={
            'Comment': 'getssl/Letsencrypt verification',
            'Changes': [
                {
                    'Action': action,
                    'ResourceRecordSet': {
                        'Name': challenge_fqdn,
                        'Type': 'TXT',
                        'TTL': 300,
                        'ResourceRecords': [{'Value': "\"{c}\"".format(c=challenge)}]
                    }
                },
            ]
        }
    )
except Exception as e:
    print("Oops: {e!r}".format(e=e))
    sys.exit(1)

waiting = 0
if action == 'UPSERT':
    # Wait until we see the record before returning. The ACME server's timeout is too short.
    # But only if we're adding the record. Don't care how long it takes to delete.
    while (True):
        try:
            my_resolver = dns.resolver.Resolver(configure=False)
            my_resolver.nameservers = ['8.8.8.8', '8.8.4.4']
            results = my_resolver.query(challenge_fqdn, 'TXT')
            data = str(results.response.answer[0][0]).strip('\"')
            if data == challenge:
                print("found {f} entry".format(f=challenge_fqdn))
            else:
                print("found {f} entry but it has bad data: {d}".format(f=challenge_fqdn,
                                                                        d=data))
            break

        except dns.resolver.NXDOMAIN:
            waiting += 10
            print("Didn't find {f} entry yet, sleeping... ({w}s)".format(f=challenge_fqdn,
                                                                         w=waiting))
            time.sleep(10)
            pass
