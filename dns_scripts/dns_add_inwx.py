#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script to Set TXT Record at INWX using the API
This script requires the pip packages INWX.Domrobot and tldextract
This script is using enviroment variables to get inwx credentials
"""

import sys
import os
import argparse
from INWX.Domrobot import ApiClient
import tldextract

# Create Parser-Objekt
parser = argparse.ArgumentParser(
    description='Using the INWX API to change DNS TXT Records for the ACME DNS-01 Challange',
        epilog= "The environment variables 'INWX_USERNAME' and 'INWX_PASSWORD' are required too")

# Adding Args
parser.add_argument('fulldomain', type=str, help='The full domain to add TXT Record.')
parser.add_argument('token', type=str, help='The ACME DNS-01 token.')
parser.add_argument('--debug', action='store_true', help='Enable debug mode.')

# Parsing Args
args = parser.parse_args()
INWX_FULLDOMAIN = args.fulldomain
ACME_TOKEN = args.token
DEBUG = args.debug

# Parsing ENV
INWX_USERNAME = os.getenv('INWX_USERNAME', '')
INWX_PASSWORD = os.getenv('INWX_PASSWORD', '')

# Splitting Domain
domain = tldextract.extract(INWX_FULLDOMAIN)
INWX_SUBDOMAIN = domain.subdomain
INWX_DOMAIN = f"{domain.domain}.{domain.suffix}"

# Check if either environment variable is empty and handle the error
if not INWX_USERNAME or not INWX_PASSWORD:
    print("Error: The following environment variables are required and cannot be empty:")
    if not INWX_USERNAME:
        print("  - INWX_USERNAME: Your INWX account username.")
    if not INWX_PASSWORD:
        print("  - INWX_PASSWORD: Your INWX account password.")
    sys.exit(1)

if DEBUG:
    print(f'FQDN: {INWX_FULLDOMAIN}')
    print(f'Domain: {INWX_DOMAIN}')
    print(f'Subdomain: {INWX_SUBDOMAIN}')
    print(f'Token: {ACME_TOKEN}')
    print(f'User: {INWX_USERNAME}')
    print(f'Password: {INWX_PASSWORD}')

# By default the ApiClient uses the test api (OT&E).
# If you want to use the production/live api we have a
# constant named API_LIVE_URL in the ApiClient class.
# Just set api_url=ApiClient.API_LIVE_URL and you're good.
# api_client = ApiClient(api_url=ApiClient.API_OTE_URL, debug_mode=DEBUG)
api_client = ApiClient(api_url=ApiClient.API_LIVE_URL, debug_mode=DEBUG)

# If you have 2fa enabled, take a look at the documentation of the ApiClient#login method
# to get further information about the login, especially the shared_secret parameter.
login_result = api_client.login(INWX_USERNAME, INWX_PASSWORD)

# login was successful
if login_result['code'] == 1000:

    # Make an api call and save the result in a variable.
    # We want to create a new nameserver record, so we call the api method nameserver.createRecord.
    # See https://www.inwx.de/en/help/apidoc/f/ch02s15.html#nameserver.createRecord for parameters
    # ApiClient#call_api returns the api response as a dict.
    if INWX_SUBDOMAIN == '':
        domain_entry_result = api_client.call_api(api_method='nameserver.createRecord', method_params={'domain': INWX_DOMAIN, 'name': '_acme-challenge', 'type': 'TXT', 'content': ACME_TOKEN})  # pylint: disable=C0301
    else:
        domain_entry_result = api_client.call_api(api_method='nameserver.createRecord', method_params={'domain': INWX_DOMAIN, 'name': f'_acme-challenge.{INWX_SUBDOMAIN}', 'type': 'TXT', 'content': ACME_TOKEN})  # pylint: disable=C0301

    # With or without successful check, we perform a logout.
    api_client.logout()

    # validating return code
    if domain_entry_result['code'] == 2302:
        sys.exit(f"{domain_entry_result['msg']}.\nTry nameserver.updateRecord or nameserver.deleteRecord instead")  # pylint: disable=C0301
    elif domain_entry_result['code'] == 1000:
        if DEBUG:
            print(domain_entry_result['msg'])
        sys.exit()
    else:
        sys.exit(domain_entry_result)
else:
    sys.exit('Api login error. Code: ' + str(login_result['code']) + '  Message: ' + login_result['msg'])  # pylint: disable=C0301
