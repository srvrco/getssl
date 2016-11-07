#! /usr/bin/env bash
. assert.sh

P=../dns_scripts

assert_raises $P/dns_add_cloudflare 1
assert_raises "$P/dns_add_cloudflare ''" 1
assert_raises "$P/dns_add_cloudflare '' ''" 1
assert_raises "$P/dns_add_cloudflare only_one" 1

assert "CF_EMAIL=w@e.org $P/dns_add_cloudflare a.$CF_DOMAIN a" 'domain name not found on your cloudflare account'
assert_raises "CF_EMAIL=w@e.org $P/dns_add_cloudflare a.$CF_DOMAIN a" 1

assert "CF_KEY= $P/dns_add_cloudflare a.$CF_DOMAIN a" 'domain name not found on your cloudflare account'
assert_raises "CF_KEY= $P/dns_add_cloudflare a.$CF_DOMAIN a" 1

assert_end dns_add_cloudflare params

assert "$P/dns_add_cloudflare a a" 'domain name not found on your cloudflare account'
assert_raises "$P/dns_add_cloudflare a a" 1

assert "$P/dns_add_cloudflare t1.$CF_DOMAIN t1" ''
assert_raises "$P/dns_add_cloudflare t1.$CF_DOMAIN t1" 0

assert "$P/dns_add_cloudflare t2.subdomain.$CF_DOMAIN t2" ''
assert_raises "$P/dns_add_cloudflare t2.subdomain.$CF_DOMAIN t2" 0

assert "$P/dns_add_cloudflare t3.sub\(domain.$CF_DOMAIN t3" 'Error: DNS challenge not added: DNS Validation Error'
assert_raises "$P/dns_add_cloudflare t3.sub\(domain.$CF_DOMAIN t3" 2

assert_end dns_add_cloudflare API

assert_raises $P/dns_del_cloudflare 1
assert_raises "$P/dns_del_cloudflare ''" 1
assert_raises "$P/dns_del_cloudflare '' ''" 1

assert_end dns_del_cloudflare params
