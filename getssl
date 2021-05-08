#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# getssl - Obtain SSL certificates from the letsencrypt.org ACME server

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at <http://www.gnu.org/licenses/> for
# more details.

# For usage, run "getssl -h" or see https://github.com/srvrco/getssl

# ACMEv2 process is documented at https://tools.ietf.org/html/rfc8555#section-7.4

# Revision history:
# 2016-01-08 Created (v0.1)
# 2016-01-11 type correction and upload to github (v0.2)
# 2016-01-11 added import of any existing cert on -c  option (v0.3)
# 2016-01-12 corrected formatting of imported certificate (v0.4)
# 2016-01-12 corrected error on removal of token in some instances (v0.5)
# 2016-01-18 corrected issue with removing tmp if run as root with the -c option (v0.6)
# 2016-01-18 added option to upload a single PEN file ( used by cpanel) (v0.7)
# 2016-01-23 added dns challenge option (v0.8)
# 2016-01-24 create the ACL directory if it does not exist. (v0.9) - dstosberg
# 2016-01-26 correcting a couple of small bugs and allow curl to follow redirects (v0.10)
# 2016-01-27 add a very basic openssl.cnf file if it doesn't exist and tidy code slightly (v0.11)
# 2016-01-28 Typo corrections, quoted file variables and fix bug on DNS_DEL_COMMAND (v0.12)
# 2016-01-28 changed DNS checks to use nslookup and allow hyphen in domain names (v0.13)
# 2016-01-29 Fix ssh-reload-command, extra waiting for DNS-challenge,
# 2016-01-29 add error_exit and cleanup help message (v0.14)
# 2016-01-29 added -a|--all option to renew all configured certificates (v0.15)
# 2016-01-29 added option for elliptic curve keys (v0.16)
# 2016-01-29 added server-type option to use and check cert validity from website (v0.17)
# 2016-01-30 added --quiet option for running in cron (v0.18)
# 2016-01-31 removed usage of xxd to make script more compatible across versions (v0.19)
# 2016-01-31 removed usage of base64 to make script more compatible across platforms (v0.20)
# 2016-01-31 added option to safe a full chain certificate (v0.21)
# 2016-02-01 commented code and added option for copying concatenated certs to file (v0.22)
# 2016-02-01 re-arrange flow for DNS-challenge, to reduce time taken (v0.23)
# 2016-02-04 added options for other server types (ldaps, or any port) and check_remote (v0.24)
# 2016-02-04 added short sleep following service restart before checking certs (v0.25)
# 2016-02-12 fix challenge token location when directory doesn't exist (v0.26)
# 2016-02-17 fix sed -E issue, and reduce length of renew check to 365 days for older systems (v0.27)
# 2016-04-05 Ensure DNS cleanup on error exit. (0.28) - pecigonzalo
# 2016-04-15 Remove NS Lookup of A record when using dns validation (0.29) - pecigonzalo
# 2016-04-17 Improving the wording in a couple of comments and info statements. (0.30)
# 2016-05-04 Improve check for if DNS_DEL_COMMAND is blank. (0.31)
# 2016-05-06 Setting umask to 077 for security of private keys etc. (0.32)
# 2016-05-20 update to reflect changes in staging ACME server json (0.33)
# 2016-05-20 tidying up checking of json following ACME changes. (0.34)
# 2016-05-21 added AUTH_DNS_SERVER to getssl.cfg as optional definition of authoritative DNS server (0.35)
# 2016-05-21 added DNS_WAIT to getssl.cfg as (default = 10 seconds as before) (0.36)
# 2016-05-21 added PUBLIC_DNS_SERVER option, for forcing use of an external DNS server (0.37)
# 2016-05-28 added FTP method of uploading tokens to remote server (blocked for certs as not secure) (0.38)
# 2016-05-28 added FTP method into the default config notes. (0.39)
# 2016-05-30 Add sftp with password to copy files (0.40)
# 2016-05-30 Add version check to see if there is a more recent version of getssl (0.41)
# 2016-05-30 Add [-u|--upgrade] option to automatically upgrade getssl (0.42)
# 2016-05-30 Added backup when auto-upgrading (0.43)
# 2016-05-30 Improvements to auto-upgrade (0.44)
# 2016-05-31 Improved comments - no structural changes
# 2016-05-31 After running for nearly 6 months, final testing prior to a 1.00 stable version. (0.90)
# 2016-06-01 Reorder functions alphabetically as part of code tidy. (0.91)
# 2016-06-03 Version 1.0 of code for release (1.00)
# 2016-06-09 bugfix of issue 44, and add success statement (ignoring quiet flag) (1.01)
# 2016-06-13 test return status of DNS_ADD_COMMAND and error_exit if a problem (hadleyrich) (1.02)
# 2016-06-13 bugfix of issue 45, problem with SERVER_TYPE when it's just a port number (1.03)
# 2016-06-13 bugfix issue 47 - DNS_DEL_COMMAND cleanup was run when not required. (1.04)
# 2016-06-15 add error checking on RELOAD_CMD (1.05)
# 2016-06-20 updated sed and date functions to run on MAC OS X (1.06)
# 2016-06-20 added CHALLENGE_CHECK_TYPE variable to allow checks direct on https rather than http (1.07)
# 2016-06-21 updated grep functions to run on MAC OS X (1.08)
# 2016-06-11 updated to enable running on windows with cygwin (1.09)
# 2016-07-02 Corrections to work with older slackware issue #56 (1.10)
# 2016-07-02 Updating help info re ACL in config file (1.11)
# 2016-07-04 adding DOMAIN_STORAGE as a variable to solve for issue #59 (1.12)
# 2016-07-05 updated order to better handle non-standard DOMAIN_STORAGE location (1.13)
# 2016-07-06 added additional comments about SANS in example template (1.14)
# 2016-07-07 check for duplicate domains in domain / SANS (1.15)
# 2016-07-08 modified to be used on older bash for issue #64 (1.16)
# 2016-07-11 added -w to -a option and comments in domain template (1.17)
# 2016-07-18 remove / regenerate csr when generating new private domain key (1.18)
# 2016-07-21 add output of combined private key and domain cert (1.19)
# 2016-07-21 updated typo (1.20)
# 2016-07-22 corrected issue in nslookup debug option - issue #74 (1.21)
# 2016-07-26 add more server-types based on openssl s_client (1.22)
# 2016-08-01 updated agreement for letsencrypt (1.23)
# 2016-08-02 updated agreement for letsencrypt to update automatically (1.24)
# 2016-08-03 improve messages on test of certificate installation (1.25)
# 2016-08-04 remove carriage return from agreement - issue #80 (1.26)
# 2016-08-04 set permissions for token folders - issue #81 (1.27)
# 2016-08-07 allow default chained file creation - issue #85 (1.28)
# 2016-08-07 use copy rather than move when archiving certs - issue #86 (1.29)
# 2016-08-07 enable use of a single ACL for all checks (if USE_SINGLE_ACL="true" (1.30)
# 2016-08-23 check for already validated domains (issue #93) - (1.31)
# 2016-08-23 updated already validated domains (1.32)
# 2016-08-23 included better force_renew and template for USE_SINGLE_ACL (1.33)
# 2016-08-23 enable insecure certificate on https token check #94 (1.34)
# 2016-08-23 export OPENSSL_CONF so it's used by all openssl commands (1.35)
# 2016-08-25 updated defaults for ACME agreement (1.36)
# 2016-09-04 correct issue #101 when some domains already validated (1.37)
# 2016-09-12 Checks if which is installed (1.38)
# 2016-09-13 Don't check for updates, if -U parameter has been given (1.39)
# 2016-09-17 Improved error messages from invalid certs (1.40)
# 2016-09-19 remove update check on recursive calls when using -a (1.41)
# 2016-09-21 changed shebang for portability (1.42)
# 2016-09-21 Included option to Deactivate an Authorization (1.43)
# 2016-09-22 retry on 500 error from ACME server (1.44)
# 2016-09-22 added additional checks and retry on 500 error from ACME server (1.45)
# 2016-09-24 merged in IPv6 support (1.46)
# 2016-09-27 added additional debug info issue #119 (1.47)
# 2016-09-27 removed IPv6 switch in favour of checking both IPv4 and IPv6 (1.48)
# 2016-09-28 Add -Q, or --mute, switch to mute notifications about successfully upgrading getssl (1.49)
# 2016-09-30 improved portability to work natively on FreeBSD, Slackware and Mac OS X (1.50)
# 2016-09-30 comment out PRIVATE_KEY_ALG from the domain template Issue #125 (1.51)
# 2016-10-03 check remote certificate for right domain before saving to local (1.52)
# 2016-10-04 allow existing CSR with domain name in subject (1.53)
# 2016-10-05 improved the check for CSR with domain in subject (1.54)
# 2016-10-06 prints update info on what was included in latest updates (1.55)
# 2016-10-06 when using -a flag, ignore folders in working directory which aren't domains (1.56)
# 2016-10-12 allow multiple tokens in DNS challenge (1.57)
# 2016-10-14 added CHECK_ALL_AUTH_DNS option to check all DNS servers, not just one primary server (1.58)
# 2016-10-14 added archive of chain and private key for each cert, and purge old archives (1.59)
# 2016-10-17 updated info comment on failed cert due to rate limits. (1.60)
# 2016-10-17 fix error messages when using 1.0.1e-fips  (1.61)
# 2016-10-20 set secure permissions when generating account key (1.62)
# 2016-10-20 set permissions to 700 for getssl script during upgrade (1.63)
# 2016-10-20 add option to revoke a certificate (1.64)
# 2016-10-21 set revocation server default to acme-v01.api.letsencrypt.org (1.65)
# 2016-10-21 bug fix for revocation on different servers. (1.66)
# 2016-10-22 Tidy up archive code for certificates and reduce permissions for security
# 2016-10-22 Add EC signing for secp384r1 and secp521r1 (the latter not yet supported by Let's  Encrypt
# 2016-10-22 Add option to create a new private key for every cert (REUSE_PRIVATE_KEY="true" by default)
# 2016-10-22 Combine EC signing, Private key reuse and archive permissions (1.67)
# 2016-10-25 added CHECK_REMOTE_WAIT option ( to pause before final remote check)
# 2016-10-25 Added EC account key support ( prime256v1, secp384r1 ) (1.68)
# 2016-10-25 Ignore DNS_EXTRA_WAIT if all domains already validated (issue #146) (1.69)
# 2016-10-25 Add option for dual ESA / EDSA certs (1.70)
# 2016-10-25 bug fix Issue #141 challenge error 400 (1.71)
# 2016-10-26 check content of key files, not just recreate if missing.
# 2016-10-26 Improvements on portability (1.72)
# 2016-10-26 Date formatting for busybox (1.73)
# 2016-10-27 bug fix - issue #157 not recognising EC keys on some versions of openssl (1.74)
# 2016-10-31 generate EC account keys and tidy code.
# 2016-10-31 fix warning message if cert doesn't exist (1.75)
# 2016-10-31 remove only specified DNS token #161 (1.76)
# 2016-11-03 Reduce long lines, and remove echo from update (1.77)
# 2016-11-05 added TOKEN_USER_ID (to set ownership of token files )
# 2016-11-05 updated style to work with latest shellcheck (1.78)
# 2016-11-07 style updates
# 2016-11-07 bug fix DOMAIN_PEM_LOCATION starting with ./ #167
# 2016-11-08 Fix for openssl 1.1.0  #166 (1.79)
# 2016-11-08 Add and comment optional sshuserid for ssh ACL (1.80)
# 2016-11-09 Add SKIP_HTTP_TOKEN_CHECK option (Issue #170) (1.81)
# 2016-11-13 bug fix DOMAIN_KEY_CERT generation (1.82)
# 2016-11-17 add PREVENT_NON_INTERACTIVE_RENEWAL option (1.83)
# 2016-12-03 add HTTP_TOKEN_CHECK_WAIT option (1.84)
# 2016-12-03 bugfix CSR renewal when no SANS and when using MINGW (1.85)
# 2016-12-16 create CSR_SUBJECT variable - Issue #193
# 2016-12-16 added fullchain to archive (1.86)
# 2016-12-16 updated DOMAIN_PEM_LOCATION when using DUAL_RSA_ECDSA (1.87)
# 2016-12-19 allow user to ignore permission preservation with nfsv3 shares (1.88)
# 2016-12-19 bug fix for CA (1.89)
# 2016-12-19 included IGNORE_DIRECTORY_DOMAIN option (1.90)
# 2016-12-22 allow copying files to multiple locations (1.91)
# 2016-12-22 bug fix for copying tokens to multiple locations (1.92)
# 2016-12-23 tidy code - place default variables in alphabetical order.
# 2016-12-27 update checks to work with openssl in FIPS mode (1.93)
# 2016-12-28 fix leftover tmpfiles in upgrade routine (1.94)
# 2016-12-28 tidied up upgrade tmpfile handling (1.95)
# 2017-01-01 update comments
# 2017-01-01 create stable release 2.0 (2.00)
# 2017-01-02 Added option to limit number of old versions to keep (2.01)
# 2017-01-03 Created check_config function to list all obvious config issues (2.02)
# 2017-01-10 force renew if FORCE_RENEWAL file exists (2.03)
# 2017-01-12 added drill, dig or host as alternatives to nslookup (2.04)
# 2017-01-18 bugfix issue #227 - error deleting csr if doesn't exist
# 2017-01-18 issue #228 check private key and account key are different (2.05)
# 2017-01-21 issue #231 mingw bugfix and typos in debug messages (2.06)
# 2017-01-29 issue #232 use neutral locale for date formatting (2.07)
# 2017-01-30 issue #243 compatibility with bash 3.0 (2.08)
# 2017-01-30 issue #243 additional compatibility with bash 3.0 (2.09)
# 2017-02-18 add OCSP Must-Staple to the domain csr generation (2.10)
# 2018-01-04 updating to use the updated letsencrypt APIv2
# 2019-09-30 issue #423 Use HTTP 1.1 as workaround atm (2.11)
# 2019-10-02 issue #425 Case insensitive processing of agreement url because of HTTP/2 (2.12)
# 2019-10-07 update DNS checks to allow use of CNAMEs (2.13)
# 2019-11-18 Rebased master onto APIv2 and added Content-Type: application/jose+json (2.14)
# 2019-11-20 #453 and #454 Add User-Agent to all curl requests
# 2019-11-22 #456 Fix shellcheck issues
# 2019-11-23 #459 Fix missing chain.crt
# 2019-12-18 #462 Use POST-as-GET for ACMEv2 endpoints
# 2020-01-07 #464 and #486 "json was blank" (change all curl request to use POST-as-GET)
# 2020-01-08 Error and exit if rate limited, exit if curl returns nothing
# 2020-01-10 Change domain and getssl templates to v2 (2.15)
# 2020-01-17 #473 and #477 Don't use POST-as-GET when sending ready for challenge for ACMEv1 (2.16)
# 2020-01-22 #475 and #483 Fix grep regex for >9 subdomains in json_get
# 2020-01-24 Add support for CloudDNS
# 2020-01-24 allow file transfer using WebDAV over HTTPS
# 2020-01-26 Use urlbase64_decode() instead of base64 -d
# 2020-01-26 Fix "already verified" error for ACMEv2
# 2020-01-29 Check awk new enough to support json_awk
# 2020-02-05 Fix epoch_date for busybox
# 2020-02-06 Bugfixes for json_awk and nslookup to support old awk versions (2.17)
# 2020-02-11 Add SCP_OPTS and SFTP_OPTS
# 2020-02-12 Fix for DUAL_RSA_ECDSA not working with ACMEv2 (#334, #474, #502)
# 2020-02-12 Fix #424 - Sporadic "error in EC signing couldn't get R from ..." (2.18)
# 2020-02-12 Fix "Registration key already in use" (2.19)
# 2020-02-13 Fix bug with copying to all locations when creating RSA and ECDSA certs (2.20)
# 2020-02-22 Change sign_string to use openssl asn1parse (better fix for #424)
# 2020-02-23 Add dig to config check for systems without drill (ubuntu)
# 2020-03-11 Use dig +trace to find primary name server and improve dig parsing of CNAME
# 2020-03-12 Fix bug with DNS validation and multiple domains (#524)
# 2020-03-24 Find primary ns using all dns utils (dig, host, nslookup)
# 2020-03-23 Fix staging server URL in domain template (2.21)
# 2020-03-30 Fix error message find_dns_utils from over version of "command"
# 2020-03-30 Fix problems if domain name isn't in lowercase (2.22)
# 2020-04-16 Add alternative working dirs '/etc/getssl/' '${PROGDIR}/conf' '${PROGDIR}/.getssl'
# 2020-04-16 Add -i|--install command line option (2.23)
# 2020-04-19 Remove dependency on seq, ensure clean_up doesn't try to delete /tmp (2.24)
# 2020-04-20 Check for domain using all DNS utilities (2.25)
# 2020-04-22 Fix HAS_HOST and HAS_NSLOOKUP checks - wolfaba
# 2020-04-22 Fix domain case conversion for different locales - glynge (2.26)
# 2020-04-26 Fixed ipv4 confirmation with nslookup - Cyber1000
# 2020-04-29 Fix ftp/sftp problems if challenge starts with a dash
# 2020-05-06 Fix missing fullchain.ec.crt when creating dual certificates (2.27)
# 2020-05-14 Add --notify-valid option (exit 2 if certificate is valid)
# 2020-05-23 Fix --revoke (didn't work with ACMEv02) (2.28)
# 2020-06-06 Fix missing URL_revoke definition when no CA directory suffix (#566)
# 2020-06-18 Fix CHECK_REMOTE for DUAL_RSA_ECDSA (#570)
# 2020-07-14 Support space separated SANS (#574) (2.29)
# 2020-08-06 Use -sigalgs instead of -cipher when checking remote for tls1.3 (#570)
# 2020-08-31 Fix slow fork bomb when directory containing getssl isn't writeable (#440)
# 2020-09-01 Use RSA-PSS when checking remote for DUAL_RSA_ECDSA (#570)
# 2020-09-02 Fix issue when SANS is space and comma separated (#579) (2.30)
# 2020-10-02 Various fixes to get_auth_dns and changes to support unit tests (#308)
# 2020-10-04 Add CHECK_PUBLIC_DNS_SERVER to check the DNS challenge has been updated there
# 2020-10-13 Bugfix: strip comments in drill/dig output (mhameed)
# 2020-11-18 Wildcard support (#347)(#400)(2.31)
# 2020-12-08 Fix mktemp template on alpine (#612)
# 2020-12-17 Fix delimiter issues with ${alldomains[]} in create_csr (#614)(vietw)
# 2020-12-18 Wrong SANS when domain contains a minus character (atisne)
# 2020-12-22 Fixes to get_auth_dns
# 2020-12-22 Check that dig doesn't return an error (#611)(2.32)
# 2020-12-29 Fix dig SOA lookup (#617)(2.33)
# 2021-01-05 Show error if running in POSIX mode (#611)
# 2021-01-16 Fix double slash when using root directory with DAVS (ionos)
# 2021-01-22 Add FTP_OPTIONS
# 2021-01-27 Add the ability to set several reload commands (atisne)
# 2021-01-29 Use dig -r (if supported) to ignore.digrc (#630)
# 2021-02-07 Allow -u --upgrade without any domain, so that one can only update the script (Benno-K)(2.34)
# 2021-02-09 Prevent listing the complete file if version tag missing (#637)(softins)
# 2021-02-12 Add PREFERRED_CHAIN
# 2021-02-15 ADD ftp explicit SSL with curl for upload the challenge (CoolMischa)
# 2021-02-18 Add FULL_CHAIN_INCLUDE_ROOT
# 2021-03-25 Fix DNS challenge completion check if CNAMEs on different NS are used (sideeffect42)(2.35)
# 2021-05-08 Merge from tlhackque/getssl: GoDaddy, split-view, tempfile permissions fixes, --version(2.36)
# ----------------------------------------------------------------------------------------

case :$SHELLOPTS: in
  *:posix:*)   echo -e "${0##*/}: Running with POSIX mode enabled is not supported" >&2; exit 1;;
esac

PROGNAME=${0##*/}
PROGDIR="$(cd "$(dirname "$0")" || exit; pwd -P;)"
VERSION="2.36"

# defaults
ACCOUNT_KEY_LENGTH=4096
ACCOUNT_KEY_TYPE="rsa"
CA="https://acme-staging-v02.api.letsencrypt.org/directory"
CA_CERT_LOCATION=""
CHALLENGE_CHECK_TYPE="http"
CHECK_REMOTE="true"
CHECK_REMOTE_WAIT=0
CODE_LOCATION="https://raw.githubusercontent.com/srvrco/getssl/master/getssl"
CSR_SUBJECT="/"
CURL_USERAGENT="${PROGNAME}/${VERSION}"
DEACTIVATE_AUTH="false"
DEFAULT_REVOKE_CA="https://acme-v02.api.letsencrypt.org"
DOMAIN_KEY_LENGTH=4096
DUAL_RSA_ECDSA="false"
FTP_OPTIONS=""
FULL_CHAIN_INCLUDE_ROOT="false"
GETSSL_IGNORE_CP_PRESERVE="false"
HTTP_TOKEN_CHECK_WAIT=0
IGNORE_DIRECTORY_DOMAIN="false"
ORIG_UMASK=$(umask)
PREFERRED_CHAIN=""              # Set this to use an alternative root certificate
PREVIOUSLY_VALIDATED="true"
PRIVATE_KEY_ALG="rsa"
RELOAD_CMD=""
RENEW_ALLOW="30"
REUSE_PRIVATE_KEY="true"
SERVER_TYPE="https"
SKIP_HTTP_TOKEN_CHECK="false"
SSLCONF="$(openssl version -d 2>/dev/null| cut -d\" -f2)/openssl.cnf"
OCSP_MUST_STAPLE="false"
TEMP_UPGRADE_FILE=""
TOKEN_USER_ID=""
USE_SINGLE_ACL="false"
WORKING_DIR_CANDIDATES=("/etc/getssl" "${PROGDIR}/conf" "${PROGDIR}/.getssl" "${HOME}/.getssl")

# Variables used when validating using a DNS entry
VALIDATE_VIA_DNS=""             # Set this to "true" to enable DNS validation
export AUTH_DNS_SERVER=""       # Use this DNS server to check the challenge token has been set
export DNS_CHECK_OPTIONS=""     # Options (such as TSIG file) required by DNS_CHECK_FUNC
export PUBLIC_DNS_SERVER=""     # Use this DNS server to find the authoritative DNS servers for the domain
CHECK_ALL_AUTH_DNS="false"      # Check the challenge token has been set on all authoritative DNS servers
CHECK_PUBLIC_DNS_SERVER="true"  # Check the public DNS server as well as the authoritative DNS servers
DNS_ADD_COMMAND=""              # Use this command/script to add the challenge token to the DNS entries for the domain
DNS_DEL_COMMAND=""              # Use this command/script to remove the challenge token from the DNS entries for the domain
DNS_WAIT_COUNT=100              # How many times to wait for the DNS record to update
DNS_WAIT=10                     # How long to wait before checking the DNS record again
DNS_EXTRA_WAIT=60               # How long to wait after the DNS entries are visible to us before telling the ACME server to check.
DNS_WAIT_RETRY_ADD="false"      # Try the dns_add_command again if the DNS record hasn't updated

# Private variables
_CHECK_ALL=0
_CREATE_CONFIG=0
_FORCE_RENEW=0
_KEEP_VERSIONS=""
_MUTE=0
_NOTIFY_VALID=0
_QUIET=0
_RECREATE_CSR=0
_REVOKE=0
_RUNNING_TEST=0
_TEST_SKIP_CNAME_CALL=0
_TEST_SKIP_SOA_CALL=0
_UPGRADE=0
_UPGRADE_CHECK=1
_USE_DEBUG=0
_ONLY_CHECK_CONFIG=0
config_errors="false"
export LANG=C
API=1

# store copy of original command in case of upgrading script and re-running
ORIGCMD="$0 $*"

# Define all functions (in alphabetical order)

auto_upgrade_v2() {  # Automatically update clients to v2
  if [[ "${CA}" == *"acme-v01."* ]] || [[ "${CA}" == *"acme-staging."* ]]; then
    OLDCA=${CA}
    # shellcheck disable=SC2001
    CA=$(echo "${OLDCA}" | sed "s/v01/v02/g")
    # shellcheck disable=SC2001
    CA=$(echo "${CA}" | sed "s/staging/staging-v02/g")
    info "Upgraded to v2 (changed ${OLDCA} to ${CA})"
  fi
  debug "Using certificate issuer: ${CA}"
}

cert_archive() {  # Archive certificate file by copying files to dated archive dir.
  debug "creating an archive copy of current new certs"
  date_time=$(date +%Y_%m_%d_%H_%M)
  mkdir -p "${DOMAIN_DIR}/archive/${date_time}"
  umask 077
  cp "$CERT_FILE" "${DOMAIN_DIR}/archive/${date_time}/${DOMAIN}.crt"
  cp "$DOMAIN_DIR/${DOMAIN}.csr" "${DOMAIN_DIR}/archive/${date_time}/${DOMAIN}.csr"
  cp "$DOMAIN_DIR/${DOMAIN}.key" "${DOMAIN_DIR}/archive/${date_time}/${DOMAIN}.key"
  cp "$CA_CERT" "${DOMAIN_DIR}/archive/${date_time}/chain.crt"
  cat "$CERT_FILE" "$CA_CERT" > "${DOMAIN_DIR}/archive/${date_time}/fullchain.crt"
  if [[ "$DUAL_RSA_ECDSA" == "true" ]]; then
    cp "${CERT_FILE%.*}.ec.crt" "${DOMAIN_DIR}/archive/${date_time}/${DOMAIN}.ec.crt"
    cp "$DOMAIN_DIR/${DOMAIN}.ec.csr" "${DOMAIN_DIR}/archive/${date_time}/${DOMAIN}.ec.csr"
    cp "$DOMAIN_DIR/${DOMAIN}.ec.key" "${DOMAIN_DIR}/archive/${date_time}/${DOMAIN}.ec.key"
    cp "${CA_CERT%.*}.ec.crt" "${DOMAIN_DIR}/archive/${date_time}/chain.ec.crt"
    cat "${CERT_FILE%.*}.ec.crt" "${CA_CERT%.*}.ec.crt" > "${DOMAIN_DIR}/archive/${date_time}/fullchain.ec.crt"
  fi
  umask "$ORIG_UMASK"
  debug "purging old GetSSL archives"
  purge_archive "$DOMAIN_DIR"
}

cert_install() {  # copy certs to the correct location (creating concatenated files as required)
  umask 077

  copy_file_to_location "domain certificate" "$CERT_FILE" "$DOMAIN_CERT_LOCATION"
  copy_file_to_location "private key" "$DOMAIN_DIR/${DOMAIN}.key" "$DOMAIN_KEY_LOCATION"
  copy_file_to_location "CA certificate" "$CA_CERT" "$CA_CERT_LOCATION"
  if [[ "$DUAL_RSA_ECDSA" == "true" ]]; then
    if [[ -n "$DOMAIN_CERT_LOCATION" ]]; then
      copy_file_to_location "ec domain certificate" \
                            "${CERT_FILE%.*}.ec.crt" \
                            "${DOMAIN_CERT_LOCATION}" \
                            "ec"
    fi
    if [[ -n "$DOMAIN_KEY_LOCATION" ]]; then
      copy_file_to_location "ec private key" \
                            "$DOMAIN_DIR/${DOMAIN}.ec.key" \
                            "${DOMAIN_KEY_LOCATION}" \
                            "ec"
    fi
    if [[ -n "$CA_CERT_LOCATION" ]]; then
      copy_file_to_location "ec CA certificate" \
                            "${CA_CERT%.*}.ec.crt" \
                            "${CA_CERT_LOCATION%.*}.crt" \
                            "ec"
    fi
  fi

  # if DOMAIN_CHAIN_LOCATION is not blank, then create and copy file.
  if [[ -n "$DOMAIN_CHAIN_LOCATION" ]]; then
    if [[ "$(dirname "$DOMAIN_CHAIN_LOCATION")" == "." ]]; then
      to_location="${DOMAIN_DIR}/${DOMAIN_CHAIN_LOCATION}"
    else
      to_location="${DOMAIN_CHAIN_LOCATION}"
    fi
    cat "$CERT_FILE" "$CA_CERT" > "$TEMP_DIR/${DOMAIN}_chain.pem"
    copy_file_to_location "full chain" "$TEMP_DIR/${DOMAIN}_chain.pem"  "$to_location"
    if [[ "$DUAL_RSA_ECDSA" == "true" ]]; then
      cat "${CERT_FILE%.*}.ec.crt" "${CA_CERT%.*}.ec.crt" > "$TEMP_DIR/${DOMAIN}_chain.pem.ec"
      copy_file_to_location "full chain" "$TEMP_DIR/${DOMAIN}_chain.pem.ec"  "${to_location}" "ec"
    fi
  fi
  # if DOMAIN_KEY_CERT_LOCATION is not blank, then create and copy file.
  if [[ -n "$DOMAIN_KEY_CERT_LOCATION" ]]; then
    if [[ "$(dirname "$DOMAIN_KEY_CERT_LOCATION")" == "." ]]; then
      to_location="${DOMAIN_DIR}/${DOMAIN_KEY_CERT_LOCATION}"
    else
      to_location="${DOMAIN_KEY_CERT_LOCATION}"
    fi
    cat "$DOMAIN_DIR/${DOMAIN}.key" "$CERT_FILE" > "$TEMP_DIR/${DOMAIN}_K_C.pem"
    copy_file_to_location "private key and domain cert pem" "$TEMP_DIR/${DOMAIN}_K_C.pem"  "$to_location"
    if [[ "$DUAL_RSA_ECDSA" == "true" ]]; then
      cat "$DOMAIN_DIR/${DOMAIN}.ec.key" "${CERT_FILE%.*}.ec.crt" > "$TEMP_DIR/${DOMAIN}_K_C.pem.ec"
      copy_file_to_location "private ec key and domain cert pem" "$TEMP_DIR/${DOMAIN}_K_C.pem.ec" "${to_location}" "ec"
    fi
  fi
  # if DOMAIN_PEM_LOCATION is not blank, then create and copy file.
  if [[ -n "$DOMAIN_PEM_LOCATION" ]]; then
    if [[ "$(dirname "$DOMAIN_PEM_LOCATION")" == "." ]]; then
      to_location="${DOMAIN_DIR}/${DOMAIN_PEM_LOCATION}"
    else
      to_location="${DOMAIN_PEM_LOCATION}"
    fi
    cat "$DOMAIN_DIR/${DOMAIN}.key" "$CERT_FILE" "$CA_CERT" > "$TEMP_DIR/${DOMAIN}.pem"
    copy_file_to_location "full key, cert and chain pem" "$TEMP_DIR/${DOMAIN}.pem"  "$to_location"
    if [[ "$DUAL_RSA_ECDSA" == "true" ]]; then
      cat "$DOMAIN_DIR/${DOMAIN}.ec.key" "${CERT_FILE%.*}.ec.crt" "${CA_CERT%.*}.ec.crt" > "$TEMP_DIR/${DOMAIN}.pem.ec"
      copy_file_to_location "full ec key, cert and chain pem" "$TEMP_DIR/${DOMAIN}.pem.ec"  "${to_location}" "ec"
    fi
  fi
  # end of copying certs.
  umask "$ORIG_UMASK"
}

check_challenge_completion() { # checks with the ACME server if our challenge is OK
  uri=$1
  domain=$2
  keyauthorization=$3

  info "sending request to ACME server saying we're ready for challenge"

  # check response from our request to perform challenge
  if [[ $API -eq 1 ]]; then
    send_signed_request "$uri" "{\"resource\": \"challenge\", \"keyAuthorization\": \"$keyauthorization\"}"

    if [[ -n "$code" ]] && [[ ! "$code" == '202' ]] ; then
      error_exit "$domain:Challenge error: $code"
    fi
  else # APIv2
    send_signed_request "$uri" "{}"
    if [[ -n "$code" ]] && [[ ! "$code" == '200' ]] ; then
      detail=$(echo "$response" | grep "detail" | awk -F\" '{print $4}')
      error_exit "$domain:Challenge error: $code:Detail: $detail"
    fi
  fi

  # loop "forever" to keep checking for a response from the ACME server.
  while true ; do
    info "checking if challenge is complete"
    if [[ $API -eq 1 ]]; then
      if ! get_cr "$uri" ; then
        error_exit "$domain:Verify error:$code"
      fi
    else # APIv2
      send_signed_request "$uri" ""
    fi

    status=$(json_get "$response" status)

    # If ACME response is valid, then break out of loop
    if [[ "$status" == "valid" ]] ; then
      info "Verified $domain"
      break;
    fi

    # if ACME response is that their check gave an invalid response, error exit
    if [[ "$status" == "invalid" ]] ; then
      err_detail=$(echo "$response" | grep "detail")
      # TODO need to check for "DNS problem: SERVFAIL looking up CAA ..." and retry
      error_exit "$domain:Verify error:$err_detail"
    fi

    # if ACME response is pending (they haven't completed checks yet)
    # or valid (completed checks but not created certificate) then wait and try again.
    if [[ "$status" == "pending" ]] || [[ "$status" == "valid" ]]; then
      info "Pending"
    else
      err_detail=$(echo "$response" | grep "detail")
      error_exit "$domain:Verify error:$status:$err_detail"
    fi
    debug "sleep 5 secs before testing verify again"
    sleep 5
  done

  if [[ "$DEACTIVATE_AUTH" == "true" ]]; then
    deactivate_url=$(echo "$responseHeaders" | grep "^Link" | awk -F"[<>]" '{print $2}')
    deactivate_url_list="$deactivate_url_list $deactivate_url"
    debug "adding url to deactivate list - $deactivate_url"
  fi
}

check_challenge_completion_dns() { # perform validation via DNS challenge
  d=${1}
  rr=${2}
  primary_ns=${3}
  auth_key=${4}

  # check for token at public dns server, waiting for a valid response.
  for ns in $primary_ns; do
    info "checking DNS at $ns"
    ntries=0
    check_dns="fail"
    while [[ "$check_dns" == "fail" ]]; do
      if [[ "$os" == "cygwin" ]]; then
        check_result=$(nslookup -type=txt "${rr}" "${ns}" \
                      | grep ^_acme -A2\
                      | grep '"'|awk -F'"' '{ print $2}')
      elif [[ "$DNS_CHECK_FUNC" == "drill" ]] || [[ "$DNS_CHECK_FUNC" == "dig" ]]; then
        debug "$DNS_CHECK_FUNC" TXT "${rr}" "@${ns}"
        check_result=$($DNS_CHECK_FUNC TXT "${rr}" "@${ns}" \
                      | grep -i "^${rr}" \
                      | grep 'IN\WTXT'|awk -F'"' '{ print $2}')
        debug "check_result=$check_result"
        if [[ -z "$check_result" ]]; then
          debug "$DNS_CHECK_FUNC" ANY "${rr}" "@${ns}"
          check_result=$($DNS_CHECK_FUNC ANY "${rr}" "@${ns}" \
                      | grep -i "^${rr}" \
                      | grep 'IN\WTXT'|awk -F'"' '{ print $2}')
          debug "check_result=$check_result"
        fi
      elif [[ "$DNS_CHECK_FUNC" == "host" ]]; then
        check_result=$($DNS_CHECK_FUNC -t TXT "${rr}" "${ns}" \
                      | grep 'descriptive text'|awk -F'"' '{ print $2}')
      else
        check_result=$(nslookup -type=txt "${rr}" "${ns}" \
                      | grep 'text ='|awk -F'"' '{ print $2}')
        if [[ -z "$check_result" ]]; then
          check_result=$(nslookup -type=any "${rr}" "${ns}" \
                      | grep 'text ='|awk -F'"' '{ print $2}')
        fi
      fi
      debug "expecting  $auth_key"
      debug "${ns} gave ... $check_result"

      if [[ "$check_result" == *"$auth_key"* ]]; then
        check_dns="success"
      else
        if [[ $ntries -lt $DNS_WAIT_COUNT ]]; then
          ntries=$(( ntries + 1 ))

          if [[ $DNS_WAIT_RETRY_ADD == "true" && $(( ntries % 10 )) == 0 ]]; then
            test_output "Deleting DNS RR via command: ${DNS_DEL_COMMAND}"
            del_dns_rr "${d}" "${auth_key}"
            test_output "Retrying adding DNS via command: ${DNS_ADD_COMMAND}"
            add_dns_rr "${d}" "${auth_key}" \
              || error_exit "DNS_ADD_COMMAND failed for domain ${d}"
          fi
          info "checking DNS at ${ns} for ${rr}. Attempt $ntries/${DNS_WAIT_COUNT} gave wrong result, "\
            "waiting $DNS_WAIT secs before checking again"
          sleep $DNS_WAIT
        else
          debug "dns check failed - removing existing value"
          del_dns_rr "${d}" "${auth_key}"

          error_exit "checking ${rr} gave $check_result not $auth_key"
        fi
      fi
    done
  done

  if [[ "$DNS_EXTRA_WAIT" -gt 0 && "$PREVIOUSLY_VALIDATED" != "true" ]]; then
    info "sleeping $DNS_EXTRA_WAIT seconds before asking the ACME server to check the dns"
    sleep "$DNS_EXTRA_WAIT"
  fi
}
# end of ... perform validation if via DNS challenge

check_config() { # check the config files for all obvious errors
  debug "checking config"

  # check keys
  case "$ACCOUNT_KEY_TYPE" in
    rsa|prime256v1|secp384r1|secp521r1)
      debug "checked ACCOUNT_KEY_TYPE " ;;
    *)
      info "${DOMAIN}: invalid ACCOUNT_KEY_TYPE - $ACCOUNT_KEY_TYPE"
      config_errors=true ;;
  esac
  if [[ "$ACCOUNT_KEY" == "$DOMAIN_DIR/${DOMAIN}.key" ]]; then
    info "${DOMAIN}: ACCOUNT_KEY and domain key ( $DOMAIN_DIR/${DOMAIN}.key ) must be different"
    config_errors=true
  fi
  case "$PRIVATE_KEY_ALG" in
    rsa|prime256v1|secp384r1|secp521r1)
      debug "checked PRIVATE_KEY_ALG " ;;
    *)
      info "${DOMAIN}: invalid PRIVATE_KEY_ALG - '$PRIVATE_KEY_ALG'"
      config_errors=true ;;
  esac
  if [[ "$DUAL_RSA_ECDSA" == "true" ]] && [[ "$PRIVATE_KEY_ALG" == "rsa" ]]; then
    info "${DOMAIN}: PRIVATE_KEY_ALG not set to an EC type and DUAL_RSA_ECDSA=\"true\""
    config_errors=true
  fi

  # get all domains into an array
  if [[ "$IGNORE_DIRECTORY_DOMAIN" == "true" ]]; then
    read -r -a alldomains <<< "${SANS//[, ]/ }"
  else
    read -r -a alldomains <<< "$(echo "$DOMAIN,$SANS" | sed "s/,/ /g")"
  fi
  if [[ -z "${alldomains[*]}" ]]; then
    info "${DOMAIN}: no domains specified"
    config_errors=true
  fi

  if [[ $VALIDATE_VIA_DNS == "true" ]]; then # using dns-01 challenge
    if [[ -z "$DNS_ADD_COMMAND" ]]; then
      info "${DOMAIN}: DNS_ADD_COMMAND not defined (whilst VALIDATE_VIA_DNS=\"true\")"
      config_errors=true
    fi
    if [[ -z "$DNS_DEL_COMMAND" ]]; then
      info "${DOMAIN}: DNS_DEL_COMMAND not defined (whilst VALIDATE_VIA_DNS=\"true\")"
      config_errors=true
    fi
  fi

  dn=0
  tmplist=$(mktemp 2>/dev/null || mktemp -t getssl.XXXXXX) || error_exit "mktemp failed"
  for d in "${alldomains[@]}"; do # loop over domains (dn is domain number)
    debug "checking domain $d"
    if [[ "$(grep "^${d}$" "$tmplist")" = "$d" ]]; then
      info "${DOMAIN}: $d appears to be duplicated in domain, SAN list"
      config_errors=true
    elif [[ "$d" != "${d##\*.}" ]] && [[ "$VALIDATE_VIA_DNS" != "true" ]]; then
      info "${DOMAIN}: cannot use http-01 validation for wildcard domains"
      config_errors=true
    else
      echo "$d" >> "$tmplist"
    fi

    if [[ "$USE_SINGLE_ACL" == "true" ]]; then
      DOMAIN_ACL="${ACL[0]}"
    else
      DOMAIN_ACL="${ACL[$dn]}"
    fi

    if [[ $VALIDATE_VIA_DNS != "true" ]]; then # using http-01 challenge
      if [[ -z "${DOMAIN_ACL}" ]]; then
        info "${DOMAIN}: ACL location not specified for domain $d in $DOMAIN_DIR/getssl.cfg"
        config_errors=true
      fi

      # check domain exists using all DNS utilities. DNS_CHECK_OPTIONS may bind IP address or provide TSIG
      found_ip=false
      if [[ -n "$HAS_DIG_OR_DRILL" ]]; then
        debug "DNS lookup using $HAS_DIG_OR_DRILL $DNS_CHECK_OPTIONS ${d}"
        if [[ "$($HAS_DIG_OR_DRILL $DNS_CHECK_OPTIONS -t SOA "${d}" |grep -c -i "^${d}")" -ge 1 ]]; then
          found_ip=true
        elif [[ "$($HAS_DIG_OR_DRILL $DNS_CHECK_OPTIONS -t A "${d}"|grep -c -i "^${d}")" -ge 1 ]]; then
          found_ip=true
        elif [[ "$($HAS_DIG_OR_DRILL $DNS_CHECK_OPTIONS -t AAAA "${d}"|grep -c -i "^${d}")" -ge 1 ]]; then
          found_ip=true
        fi
      fi

      if [[ "$HAS_HOST" == "true" ]]; then
        debug "DNS lookup using host ${d}"
        if [[ "$(host $DNS_CHECK_OPTIONS "${d}" |grep -c -i "^${d}")" -ge 1 ]]; then
          found_ip=true
        fi
      fi

      if [[ "$HAS_NSLOOKUP" == "true" ]]; then
        debug "DNS lookup using nslookup -query AAAA ${d}"
        if [[ "$(nslookup $DNS_CHECK_OPTIONS -query=AAAA "${d}"|grep -c -i "^${d}.*has AAAA address")" -ge 1 ]]; then
          debug "found IPv6 record for ${d}"
          found_ip=true
        elif [[ "$(nslookup $DNS_CHECK_OPTIONS "${d}"| grep -c ^Name)" -ge 1 ]]; then
          debug "found IPv4 record for ${d}"
          found_ip=true
        fi
      fi

      if [[ "$found_ip" == "false" ]]; then
        info "${DOMAIN}: DNS lookup failed for $d"
        config_errors=true
      fi
    fi # end using dns-01 challenge
    ((dn++))
  done

  # tidy up
  rm -f "$tmplist"

  if [[ "$config_errors" == "true" ]]; then
    error_exit "${DOMAIN}: exiting due to config errors"
  fi
  debug "${DOMAIN}: check_config completed  - all OK"
}

check_getssl_upgrade() { # check if a more recent version of code is available available
  TEMP_UPGRADE_FILE="$(mktemp 2>/dev/null || mktemp -t getssl.XXXXXX)"
  if [ "$TEMP_UPGRADE_FILE" == "" ]; then
    error_exit "mktemp failed"
  fi
  curl --user-agent "$CURL_USERAGENT" --silent "$CODE_LOCATION" --output "$TEMP_UPGRADE_FILE"
  errcode=$?
  if [[ $errcode -eq 60 ]]; then
    error_exit "curl needs updating, your version does not support SNI (multiple SSL domains on a single IP)"
  elif [[ $errcode -gt 0 ]]; then
    error_exit "curl error : $errcode"
  fi
  latestversion=$(awk -F '"' '$1 == "VERSION=" {print $2}' "$TEMP_UPGRADE_FILE")
  latestvdec=$(echo "$latestversion"| tr -d '.')
  localvdec=$(echo "$VERSION"| tr -d '.' )
  debug "current code is version ${VERSION}"
  debug "Most recent version is  ${latestversion}"
  # use a default of 0 for cases where the latest code has not been obtained.
  if [[ "${latestvdec:-0}" -gt "$localvdec" ]]; then
    if [[ ${_UPGRADE} -eq 1 ]]; then
      if ! install "$0" "${0}.v${VERSION}"; then
        error_exit "problem renaming old version while updating, check permissions"
      fi
      if ! install -m 700 "$TEMP_UPGRADE_FILE" "$0"; then
        error_exit "problem installing new version while updating, check permissions"
      fi
      if [[ ${_MUTE} -eq 0 ]]; then
        echo "Updated getssl from v${VERSION} to v${latestversion}"
        echo "These update notifications can be turned off using the -Q option"
        echo ""
        echo "Updates are;"
        awk "/\(${VERSION}\)$/ {s=1} s; /\(${latestversion}\)$/ || /^# ----/ {s=0}" "$TEMP_UPGRADE_FILE" | awk '{if(NR>1)print}'
        echo ""
      fi
      if [[ -n "$_KEEP_VERSIONS" ]] && [[ "$_KEEP_VERSIONS" =~ ^[0-9]+$ ]]; then
        # Obtain all locally stored old versions in getssl_versions
        declare -a getssl_versions
        shopt -s nullglob
        for getssl_version in "$0".v*; do
          getssl_versions[${#getssl_versions[@]}]="$getssl_version"
        done
        shopt -u nullglob
        # Explicitly sort the getssl_versions array to make sure
        shopt -s -o noglob
        # shellcheck disable=SC2207
        IFS=$'\n' getssl_versions=($(sort <<< "${getssl_versions[*]}"))
        shopt -u -o noglob
        # Remove entries until given number of old versions to keep is reached
        while [[ ${#getssl_versions[@]} -gt $_KEEP_VERSIONS ]]; do
          debug "removing old version ${getssl_versions[0]}"
          rm "${getssl_versions[0]}"
          getssl_versions=("${getssl_versions[@]:1}")
        done
      fi
      if ! eval "$ORIGCMD"; then
        error_exit "Running upgraded getssl failed"
      fi
      graceful_exit
    else
      info ""
      info "A more recent version (v${latestversion}) of getssl is available, please update"
      info "The easiest way is to use the -u or --upgrade flag"
      info ""
    fi
  fi
}

clean_up() { # Perform pre-exit housekeeping
  umask "$ORIG_UMASK"
  if [[ $VALIDATE_VIA_DNS == "true" ]]; then
    # Tidy up DNS entries if things failed part way though.
    shopt -s nullglob
    for dnsfile in "$TEMP_DIR"/dns_verify/*; do
      # shellcheck source=/dev/null
      . "$dnsfile"
      debug "attempting to clean up DNS entry for $d"
      del_dns_rr "${d}" "${auth_key}"
    done
    shopt -u nullglob
  fi
  if [[ -n "$DOMAIN_DIR" ]]; then
    if [ "${TEMP_DIR}" -ef "/tmp" ]; then
        info "Not going to delete TEMP_DIR ${TEMP_DIR} as it appears to be /tmp"
    else
        rm -rf "${TEMP_DIR:?}"
    fi
  fi
  if [[ -n "$TEMP_UPGRADE_FILE" ]] && [[ -f "$TEMP_UPGRADE_FILE" ]]; then
    rm -f "$TEMP_UPGRADE_FILE"
  fi
}

copy_file_to_location() { # copies a file, using scp, sftp or ftp if required.
  cert=$1   # descriptive name, just used for display
  from=$2   # current file location
  to=$3     # location to move file to.
  suffix=$4 # (optional) optional suffix for DUAL_RSA_ECDSA, i.e. save to private.key becomes save to private.ec.key
  IFS=\; read -r -a copy_locations <<<"$3"
  for to in "${copy_locations[@]}"; do
    if [[ -n "$suffix" ]]; then
      to="${to%.*}.${suffix}.${to##*.}"
    fi
    info "copying $cert to $to"
    if [[ "${to:0:4}" == "ssh:" ]] ; then
      debug "using scp -q $SCP_OPTS $from ${to:4}"
      # shellcheck disable=SC2086
      if ! scp -q $SCP_OPTS "$from" "${to:4}" >/dev/null 2>&1 ; then
        error_exit "problem copying file to the server using scp.
        scp $from ${to:4}"
      fi
      debug "userid $TOKEN_USER_ID"
      if [[ "$cert" == "challenge token" ]] && [[ -n "$TOKEN_USER_ID" ]]; then
        servername=$(echo "$to" | awk -F":" '{print $2}')
        tofile=$(echo "$to" | awk -F":" '{print $3}')
        debug "servername $servername"
        debug "file $tofile"
        # shellcheck disable=SC2029
        # shellcheck disable=SC2086
        ssh $SSH_OPTS "$servername" "chown $TOKEN_USER_ID $tofile"
      fi
    elif [[ "${to:0:4}" == "ftp:" ]] ; then
      if [[ "$cert" != "challenge token" ]] ; then
        error_exit "ftp is not a secure method for copying certificates or keys"
      fi
      if [[ -z "$FTP_COMMAND" ]]; then
        error_exit "No ftp command found"
      fi
      debug "using ftp to copy the file from $from"
      ftpuser=$(echo "$to"| awk -F: '{print $2}')
      ftppass=$(echo "$to"| awk -F: '{print $3}')
      ftphost=$(echo "$to"| awk -F: '{print $4}')
      ftplocn=$(echo "$to"| awk -F: '{print $5}')
      ftpdirn=$(dirname "$ftplocn")
      ftpfile=$(basename "$ftplocn")
      fromdir=$(dirname "$from")
      fromfile=$(basename "$from")
      debug "ftp user=$ftpuser - pass=$ftppass - host=$ftphost dir=$ftpdirn file=$ftpfile"
      debug "from dir=$fromdir  file=$fromfile"
      if [ -n "$FTP_OPTIONS" ]; then
        # Use eval to expand any variables in FTP_OPTIONS
        FTP_OPTIONS=$(eval echo "$FTP_OPTIONS")
        debug "FTP_OPTIONS=$FTP_OPTIONS"
      fi
      $FTP_COMMAND <<- _EOF
			open $ftphost
      user $ftpuser $ftppass
      $FTP_OPTIONS
			cd $ftpdirn
			lcd $fromdir
			put ./$fromfile
			_EOF
    elif [[ "${to:0:5}" == "sftp:" ]] ; then
      debug "using sftp to copy the file from $from"
      ftpuser=$(echo "$to"| awk -F: '{print $2}')
      ftppass=$(echo "$to"| awk -F: '{print $3}')
      ftphost=$(echo "$to"| awk -F: '{print $4}')
      ftplocn=$(echo "$to"| awk -F: '{print $5}')
      ftpdirn=$(dirname "$ftplocn")
      ftpfile=$(basename "$ftplocn")
      fromdir=$(dirname "$from")
      fromfile=$(basename "$from")
      debug "sftp $SFTP_OPTS user=$ftpuser - pass=$ftppass - host=$ftphost dir=$ftpdirn file=$ftpfile"
      debug "from dir=$fromdir  file=$fromfile"
      # shellcheck disable=SC2086
      sshpass -p "$ftppass" sftp $SFTP_OPTS "$ftpuser@$ftphost" <<- _EOF
			cd $ftpdirn
			lcd $fromdir
			put ./$fromfile
			_EOF
    elif [[ "${to:0:5}" == "davs:" ]] ; then
      debug "using davs to copy the file from $from"
      davsuser=$(echo "$to"| awk -F: '{print $2}')
      davspass=$(echo "$to"| awk -F: '{print $3}')
      davshost=$(echo "$to"| awk -F: '{print $4}')
      davsport=$(echo "$to"| awk -F: '{print $5}')
      davslocn=$(echo "$to"| awk -F: '{print $6}')
      davsdirn=$(dirname "$davslocn")
      davsdirn=$(echo "${davsdirn}/" | sed 's,//,/,g')
      davsfile=$(basename "$davslocn")
      fromdir=$(dirname "$from")
      fromfile=$(basename "$from")
      debug "davs user=$davsuser - pass=$davspass - host=$davshost port=$davsport dir=$davsdirn file=$davsfile"
      debug "from dir=$fromdir  file=$fromfile"
      curl -u "${davsuser}:${davspass}" -T "${fromdir}/${fromfile}" "https://${davshost}:${davsport}${davsdirn}${davsfile}"
    elif [[ "${to:0:6}" == "ftpes:" ]] ; then
      debug "using ftp to copy the file from $from"
      ftpuser=$(echo "$to"| awk -F: '{print $2}')
      ftppass=$(echo "$to"| awk -F: '{print $3}')
      ftphost=$(echo "$to"| awk -F: '{print $4}')
      ftplocn=$(echo "$to"| awk -F: '{print $5}')
      ftpdirn=$(dirname "$ftplocn")
      ftpfile=$(basename "$ftplocn")
      fromdir=$(dirname "$from")
      fromfile=$(basename "$from")
      debug "ftp user=$ftpuser - pass=$ftppass - host=$ftphost dir=$ftpdirn file=$ftpfile"
      debug "from dir=$fromdir  file=$fromfile"
      curl --insecure --ftp-ssl -u "${ftpuser}:${ftppass}" -T "${fromdir}/${fromfile}" "ftp://${ftphost}${ftpdirn}/"
    else
      if ! mkdir -p "$(dirname "$to")" ; then
        error_exit "cannot create ACL directory $(basename "$to")"
      fi
      if [[ "$GETSSL_IGNORE_CP_PRESERVE" == "true" ]]; then
        if ! cp "$from" "$to" ; then
          error_exit "cannot copy $from to $to"
        fi
      else
        if ! cp -p "$from" "$to" ; then
          error_exit "cannot copy $from to $to"
        fi
      fi
      if [[ "$cert" == "challenge token" ]] && [[ -n "$TOKEN_USER_ID" ]]; then
        chown "$TOKEN_USER_ID" "$to"
      fi
    fi
    debug "copied $from to $to"
  done
}

create_csr() { # create a csr using a given key (if it doesn't already exist)
  csr_file=$1
  csr_key=$2
  # check if domain csr exists - if not then create it
  if [[ -s "$csr_file" ]]; then
    debug "domain csr exists at - $csr_file"
    # check all domains in config are in csr
    if [[ "$IGNORE_DIRECTORY_DOMAIN" == "true" ]]; then
      read -d '\n' -r -a alldomains <<< "$(echo "$SANS" | sed -e 's/ //g; s/,$//; y/,/\n/' | sort -u)"
    else
      read -d '\n' -r -a alldomains <<< "$(echo "$DOMAIN,$SANS" | sed -e 's/,/ /g; s/ $//; y/ /\n/' | sort -u)"
    fi
    domains_in_csr=$(openssl req -text -noout -in "$csr_file" \
        | sed -n -e 's/^ *Subject: .* CN=\([A-Za-z0-9.-]*\).*$/\1/p; /^ *DNS:.../ { s/ *DNS://g; y/,/\n/; p; }' \
        | sort -u)
    for d in "${alldomains[@]}"; do
      if [[ "$(echo "${domains_in_csr}"| grep "^${d}$")" != "${d}" ]]; then
        info "existing csr at $csr_file does not contain ${d} - re-create-csr"\
          ".... $(echo "${domains_in_csr}"| grep "^${d}$")"
        _RECREATE_CSR=1
      fi
    done
    # check all domains in csr are in config
    if [[ "$(IFS=$'\n'; echo -n "${alldomains[*]}")" != "$domains_in_csr" ]]; then
      info "existing csr at $csr_file does not have the same domains as the config - re-create-csr"
      _RECREATE_CSR=1
    else
      test_output "Existing csr at $csr_file contains same domains as the config"
    fi
  fi
  # end of ... check if domain csr exists - if not then create it

  # if CSR does not exist, or flag set to recreate, then create csr
  if [[ ! -s "$csr_file" ]] || [[ "$_RECREATE_CSR" == "1" ]]; then
    info "creating domain csr - $csr_file"
    # create a temporary config file, for portability.
    tmp_conf=$(mktemp 2>/dev/null || mktemp -t getssl) || error_exit "mktemp failed"
    cat "$SSLCONF" > "$tmp_conf"
    printf "[SAN]\n%s" "$SANLIST" >> "$tmp_conf"
    # add OCSP Must-Staple to the domain csr
    # if openssl version >= 1.1.0 one can also use "tlsfeature = status_request"
    if [[ "$OCSP_MUST_STAPLE" == "true" ]]; then
      printf "\n1.3.6.1.5.5.7.1.24 = DER:30:03:02:01:05" >> "$tmp_conf"
    fi
    openssl req -new -sha256 -key "$csr_key" -subj "$CSR_SUBJECT" -reqexts SAN -config "$tmp_conf" > "$csr_file"
    rm -f "$tmp_conf"
  fi
}

create_key() { # create a domain key (if it doesn't already exist)
  key_type=$1 # domain key type
  key_loc=$2  # domain key location
  key_len=$3  # domain key length - for rsa keys.
  # check if key exists, if not then create it.
  if [[ -s "$key_loc" ]]; then
    debug "domain key exists at $key_loc - skipping generation"
    # ideally need to check validity of domain key
  else
    umask 077
    info "creating key - $key_loc"
    case "$key_type" in
      rsa)
        openssl genrsa "$key_len" > "$key_loc";;
      prime256v1|secp384r1|secp521r1)
        openssl ecparam -genkey -name "$key_type" > "$key_loc";;
      *)
        error_exit "unknown private key algorithm type $key_loc";;
    esac
    umask "$ORIG_UMASK"
    # remove csr on generation of new domain key
    if [[ -e "${key_loc%.*}.csr" ]]; then
      rm -f "${key_loc%.*}.csr"
    fi
  fi
}

create_order() {
  dstring="["
  for d in "${alldomains[@]}"; do
    dstring="${dstring}{\"type\":\"dns\",\"value\":\"$d\"},"
  done
  dstring="${dstring::${#dstring}-1}]"
  # request NewOrder currently seems to ignore the dates ....
  #  dstring="${dstring},\"notBefore\": \"$(date -d "-1 hour" --utc +%FT%TZ)\""
  #  dstring="${dstring},\"notAfter\": \"$(date -d "2 days" --utc +%FT%TZ)\""
  request="{\"identifiers\": $dstring}"
  send_signed_request "$URL_newOrder" "$request"
  OrderLink=$(echo "$responseHeaders" | grep -i location | awk '{print $2}'| tr -d '\r\n ')
  debug "Order link $OrderLink"
  FinalizeLink=$(json_get "$response" "finalize")
  debug "Finalize link $FinalizeLink"

  if [[ $API -eq 1 ]]; then
    dn=0
    for d in "${alldomains[@]}"; do
      # get authorizations link
      AuthLink[$dn]=$(json_get "$response" "identifiers" "value" "${d##\*.}" "authorizations" "x")
      debug "authorizations link for $d - ${AuthLink[$dn]}"
      ((dn++))
    done
  else
    # Authorization links are unsorted, so fetch the authorization link, find the domain, save response in the correct array position
    AuthLinks=$(json_get "$response" "authorizations")
    AuthLinkResponse=()
    AuthLinkResponseHeader=()
    for l in $AuthLinks; do
      debug "Requesting authorizations link for $l"
      send_signed_request "$l" ""
      # Get domain from response
      authdomain=$(json_get "$response" "identifier" "value")
      wildcard=$(json_get "$response" "wildcard")
      debug wildcard="$wildcard"
      # find array position (This is O(n2) but doubt that we'll see performance issues)
      dn=0
      for d in "${alldomains[@]}"; do
        # Convert domain to lowercase as response from server will be in lowercase
        lower_d=$(echo "$d" | tr "[:upper:]" "[:lower:]")
        if [[ ( "$lower_d" == "$authdomain" && -z "$wildcard" ) || ( "$lower_d" == "*.${authdomain}" && -n "$wildcard" ) ]]; then
          debug "Saving authorization response for $authdomain for domain alldomains[$dn]"
          debug "Response = ${response//[$'\t\r\n']}"
          AuthLinkResponse[$dn]=$response
          AuthLinkResponseHeader[$dn]=$responseHeaders
        fi
        ((dn++))
      done
    done
  fi
}

date_epoc() { # convert the date into epoch time
  if [[ "$os" == "bsd" ]]; then
    date -j -f "%b %d %T %Y %Z" "$1" +%s
  elif [[ "$os" == "mac" ]]; then
    date -j -f "%b %d %T %Y %Z" "$1" +%s
  elif [[ "$os" == "busybox" ]]; then
    de_ld=$(echo "$1" | awk '{print $1 " " $2 " " $3 " " $4}')
    date -D "%b %d %T %Y" -d "$de_ld" +%s
  else
    date -d "$1" +%s
  fi

}

date_fmt() { # format date from epoc time to YYYY-MM-DD
  if [[ "$os" == "bsd" ]]; then #uses older style date function.
    date -j -f "%s" "$1" +%F
  elif [[ "$os" == "mac" ]]; then # macOS uses older BSD style date.
    date -j -f "%s" "$1" +%F
  else
    date -d "@$1" +%F
  fi
}

date_renew() { # calculates the renewal time in epoch
  date_now_s=$( date +%s )
  echo "$((date_now_s + RENEW_ALLOW*24*60*60))"
}

debug() { # write out debug info if the debug flag has been set
  if [[ ${_USE_DEBUG} -eq 1 ]]; then
    # If running tests then output in TAP format (for debugging tests)
    if [[ ${_RUNNING_TEST} -eq 1 ]]; then
      echo "# $(date "+%b %d %T") ${FUNCNAME[1]}:${BASH_LINENO[1]}" "$@" >&3
    else
      echo " "
      echo "$@"
    fi
  fi
}

test_output() { # write out debug output for testing
  if [[ ${_RUNNING_TEST} -eq 1 ]]; then
    echo "#" "$@"
  fi
}

error_exit() { # give error message on error exit
  echo -e "${PROGNAME}: ${1:-"Unknown Error"}" >&2
  clean_up
  exit 1
}

find_dns_utils() {
    HAS_NSLOOKUP=false
    HAS_DIG_OR_DRILL=""
    HAS_HOST=false
    if [[ -n "$(command -v nslookup 2>/dev/null)" ]]; then
        debug "HAS NSLOOKUP=true"
        HAS_NSLOOKUP=true
    fi

    if [[ -n "$(command -v drill 2>/dev/null)" ]]; then
        debug "HAS DIG_OR_DRILL=drill"
        HAS_DIG_OR_DRILL="drill"
    elif [[ -n "$(command -v dig 2>/dev/null)" ]] && dig >/dev/null 2>&1; then
        if [[ $(dig -r >/dev/null 2>&1) ]]; then
          # use dig -r so ~/.digrc is not used
          HAS_DIG_OR_DRILL="dig -r"
        else
          HAS_DIG_OR_DRILL="dig"
        fi
        debug "HAS DIG_OR_DRILL=$HAS_DIG_OR_DRILL"
    fi

    if [[ -n "$(command -v host 2>/dev/null)" ]]; then
        debug "HAS HOST=true"
        HAS_HOST=true
    fi
}

find_ftp_command() {
  FTP_COMMAND=""
  if [[ -n "$(command -v ftp 2>/dev/null)" ]]; then
    debug "Has ftp"
    FTP_COMMAND="ftp -n"
  elif [[ -n "$(command -v lftp 2>/dev/null)" ]]; then
    debug "Has lftp"
    FTP_COMMAND="lftp"
  fi
}


add_dns_rr() {
  d=${1}
  auth_key=${2}

  # shellcheck disable=SC2018,SC2019
  lower_d=$(printf '%s' "${d#\*.}" | tr 'A-Z' 'a-z')
  debug "adding DNS RR via command: ${DNS_ADD_COMMAND} ${lower_d} ${auth_key}"
  eval "${DNS_ADD_COMMAND}" "${lower_d}" "${auth_key}"
}

del_dns_rr() {
  d=${1}
  auth_key=${2}

  # shellcheck disable=SC2018,SC2019
  lower_d=$(printf '%s' "${d#\*.}" | tr 'A-Z' 'a-z')
  debug "removing DNS RR via command: ${DNS_DEL_COMMAND} ${lower_d} ${auth_key}"
  eval "${DNS_DEL_COMMAND}" "${lower_d}" "${auth_key}"
}

fulfill_challenges() {
dn=0
for d in "${alldomains[@]}"; do
  # $d is domain in current loop, which is number $dn for ACL
  info "Verifying $d"
  if [[ "$USE_SINGLE_ACL" == "true" ]]; then
    DOMAIN_ACL="${ACL[0]}"
  else
    DOMAIN_ACL="${ACL[$dn]}"
  fi

  # request a challenge token from ACME server
  if [[ $API -eq 1 ]]; then
    request="{\"resource\":\"new-authz\",\"identifier\":{\"type\":\"dns\",\"value\":\"${d##\*.}\"}}"
    send_signed_request "$URL_new_authz" "$request"
    debug "completed send_signed_request"

    # check if we got a valid response and token, if not then error exit
    if [[ -n "$code" ]] && [[ ! "$code" == '201' ]] ; then
      error_exit "new-authz error: $response"
    fi
  else
    response=${AuthLinkResponse[$dn]}
    responseHeaders=${AuthLinkResponseHeader[$dn]}
    response_status=$(json_get "$response" status)
  fi

  if [[ $response_status == "valid" ]]; then
    info "$d is already validated"
    if [[ "$DEACTIVATE_AUTH" == "true" ]]; then
      deactivate_url="$(echo "$responseHeaders" | awk ' $1 ~ "^Location" {print $2}' | tr -d "\r")"
      deactivate_url_list+=" $deactivate_url "
      debug "url added to deactivate list ${deactivate_url}"
      debug "deactivate list is now $deactivate_url_list"
    fi
    # increment domain-counter
    ((dn++))
  else
    PREVIOUSLY_VALIDATED="false"
    if [[ $VALIDATE_VIA_DNS == "true" ]]; then # set up the correct DNS token for verification
      if [[ $API -eq 1 ]]; then
        # get the dns component of the ACME response
        # get the token and uri from the dns component
        token=$(json_get "$response" "token" "dns-01")
        uri=$(json_get "$response" "uri" "dns-01")
        debug uri "$uri"
      else # APIv2
        debug "authlink response = ${response//[$'\t\r\n']}"
        # get the token and uri from the dns-01 component
        token=$(json_get "$response" "challenges" "type" "dns-01" "token")
        uri=$(json_get "$response" "challenges" "type" "dns-01" "url")
        debug uri "$uri"
      fi

      keyauthorization="$token.$thumbprint"
      debug keyauthorization "$keyauthorization"

      #create signed authorization key from token.
      auth_key=$(printf '%s' "$keyauthorization" \
        | openssl dgst -sha256 -binary \
        | openssl base64 -e \
        | tr -d '\n\r' \
        | sed -e 's:=*$::g' -e 'y:+/:-_:')
      debug auth_key "$auth_key"

      add_dns_rr "${d}" "${auth_key}" \
        || error_exit "DNS_ADD_COMMAND failed for domain $d"

      # shellcheck disable=SC2018,SC2019
      rr="_acme-challenge.$(printf '%s' "${d#\*.}" | tr 'A-Z' 'a-z')"

      # find a primary / authoritative DNS server for the domain
      if [[ -z "$AUTH_DNS_SERVER" ]]; then
        # Find authorative dns server for _acme-challenge.{domain} (for CNAMES/acme-dns)
        get_auth_dns "${rr}"
        if test -n "${cname}"; then
          rr=${cname}
        fi

        # If no authorative dns server found, try again for {domain}
        if [[ -z "$primary_ns" ]]; then
          get_auth_dns "$d"
        fi
      elif [[ "$CHECK_PUBLIC_DNS_SERVER" == "true" ]]; then
        primary_ns="$AUTH_DNS_SERVER $PUBLIC_DNS_SERVER"
      else
        primary_ns="$AUTH_DNS_SERVER"
      fi
      debug set primary_ns = "$primary_ns"

      # internal check
      check_challenge_completion_dns "${d}" "${rr}" "${primary_ns}" "${auth_key}"

      # let Let's Encrypt check
      check_challenge_completion "${uri}" "${d}" "${keyauthorization}"

      del_dns_rr "${d}" "${auth_key}"
    else      # set up the correct http token for verification
      if [[ $API -eq 1 ]]; then
        # get the token from the http component
        token=$(json_get "$response" "token" "http-01")
        # get the uri from the http component
        uri=$(json_get "$response" "uri" "http-01")
        debug uri "$uri"
      else # APIv2
        debug "authlink response = ${response//[$'\t\r\n']}"
        # get the token from the http-01 component
        token=$(json_get "$response" "challenges" "type" "http-01" "token")
        # get the uri from the http component
        uri=$(json_get "$response" "challenges" "type" "http-01" "url" | head -n1)
        debug uri "$uri"
      fi

      #create signed authorization key from token.
      keyauthorization="$token.$thumbprint"

      # save variable into temporary file
      echo -n "$keyauthorization" > "$TEMP_DIR/$token"
      chmod 644 "$TEMP_DIR/$token"

      # copy to token to acme challenge location
      umask 0022
      IFS=\; read -r -a token_locations <<<"$DOMAIN_ACL"
      for t_loc in "${token_locations[@]}"; do
        debug "copying file from $TEMP_DIR/$token to ${t_loc}"
        copy_file_to_location "challenge token" \
                              "$TEMP_DIR/$token" \
                              "${t_loc}/$token"
      done
      umask "$ORIG_UMASK"

      wellknown_url="${CHALLENGE_CHECK_TYPE}://${d}/.well-known/acme-challenge/$token"
      debug wellknown_url "$wellknown_url"

      if [[ "$SKIP_HTTP_TOKEN_CHECK" == "true" ]]; then
        info "SKIP_HTTP_TOKEN_CHECK=true so not checking that token is working correctly"
      else
        sleep "$HTTP_TOKEN_CHECK_WAIT"
        # check that we can reach the challenge ourselves, if not, then error
        if [[ ! "$(curl --user-agent "$CURL_USERAGENT" -k --silent --location "$wellknown_url")" == "$keyauthorization" ]]; then
          error_exit "for some reason could not reach $wellknown_url - please check it manually"
        fi
      fi

      check_challenge_completion "$uri" "$d" "$keyauthorization"

      debug "remove token from ${DOMAIN_ACL}"
      IFS=\; read -r -a token_locations <<<"$DOMAIN_ACL"
      for t_loc in "${token_locations[@]}"; do
        if [[ "${t_loc:0:4}" == "ssh:" ]] ; then
          sshhost=$(echo "${t_loc}"| awk -F: '{print $2}')
          command="rm -f ${t_loc:(( ${#sshhost} + 5))}/${token:?}"
          debug "running following command to remove token"
          debug "ssh $SSH_OPTS $sshhost ${command}"
          # shellcheck disable=SC2029 disable=SC2086
          ssh $SSH_OPTS "$sshhost" "${command}" 1>/dev/null 2>&1
          rm -f "${TEMP_DIR:?}/${token:?}"
        elif [[ "${t_loc:0:4}" == "ftp:" ]] ; then
          debug "using ftp to remove token file"
          ftpuser=$(echo "${t_loc}"| awk -F: '{print $2}')
          ftppass=$(echo "${t_loc}"| awk -F: '{print $3}')
          ftphost=$(echo "${t_loc}"| awk -F: '{print $4}')
          ftplocn=$(echo "${t_loc}"| awk -F: '{print $5}')
          debug "$FTP_COMMAND user=$ftpuser - pass=$ftppass - host=$ftphost location=$ftplocn"
          $FTP_COMMAND <<- EOF
					open $ftphost
					user $ftpuser $ftppass
					cd $ftplocn
					delete ${token:?}
					EOF
        else
          rm -f "${t_loc:?}/${token:?}"
        fi
      done
    fi
    # increment domain-counter
    ((dn++))
  fi
done # end of ... loop through domains for cert ( from SANS list)
#end of verify each domain.
}

get_auth_dns() { # get the authoritative dns server for a domain (sets primary_ns )
  orig_gad_d="$1" # domain name
  orig_gad_s="$PUBLIC_DNS_SERVER" # start with PUBLIC_DNS_SERVER
  gad_d="$orig_gad_d"
  gad_s="$orig_gad_s"

  if [[ "$os" == "cygwin" ]]; then
    # shellcheck disable=SC2086
    all_auth_dns_servers=$(nslookup -type=soa "${d}" ${PUBLIC_DNS_SERVER} 2>/dev/null \
                          | grep "primary name server" \
                          | awk '{print $NF}')
    if [[ -z "$all_auth_dns_servers" ]]; then
      error_exit "couldn't find primary DNS server - please set AUTH_DNS_SERVER in config"
    fi
    primary_ns="$all_auth_dns_servers"
    if [[ "$CHECK_PUBLIC_DNS_SERVER" == "true" ]]; then
      primary_ns="$primary_ns $PUBLIC_DNS_SERVER"
    fi

    return
  fi

  if [[ -n "$HAS_DIG_OR_DRILL" ]]; then
    if [[ -n "$gad_s" ]]; then
      gad_s="@$gad_s"
    fi

    # Check if domain is a CNAME, first
    test_output "Using $HAS_DIG_OR_DRILL $DNS_CHECK_OPTIONS CNAME"

    # Two options here; either dig CNAME will return the CNAME and the NS or just the CNAME
    debug Checking for CNAME using "$HAS_DIG_OR_DRILL $DNS_CHECK_OPTIONS CNAME $gad_d $gad_s"
    res=$($HAS_DIG_OR_DRILL $DNS_CHECK_OPTIONS CNAME "$gad_d" $gad_s| grep "^$gad_d")
    cname=$(echo "$res"| awk '$4 ~ "CNAME" {print $5}' |sed 's/\.$//g')

    if [[ $_TEST_SKIP_CNAME_CALL == 0 ]]; then
      debug Checking if CNAME result contains NS records
      res=$($HAS_DIG_OR_DRILL $DNS_CHECK_OPTIONS CNAME "$gad_d" $gad_s| grep -E "IN\W(NS|SOA)\W")
    else
      res=
    fi

    if [[ -n "${cname}" ]]; then
      # domain is a CNAME: resolve it and continue with that
      debug Domain is a CNAME, actual domain is "$cname"
      gad_d=${cname}
    fi

    # Use SOA +trace to find the name server
    if [[ -z "$res" ]] && [[ $_TEST_SKIP_SOA_CALL == 0 ]]; then
      if [[ "$HAS_DIG_OR_DRILL" == "drill" ]]; then
        debug Using "$HAS_DIG_OR_DRILL $DNS_CHECK_OPTIONS -T $gad_d $gad_s" to find primary nameserver
        test_output "Using $HAS_DIG_OR_DRILL $DNS_CHECK_OPTIONS SOA"
        res=$($HAS_DIG_OR_DRILL $DNS_CHECK_OPTIONS -T SOA "$gad_d" $gad_s 2>/dev/null | grep "IN\WNS\W")
      else
        debug Using "$HAS_DIG_OR_DRILL $DNS_CHECK_OPTIONS SOA +trace +nocomments $gad_d $gad_s" to find primary nameserver
        test_output "Using $HAS_DIG_OR_DRILL $DNS_CHECK_OPTIONS SOA"
        res=$($HAS_DIG_OR_DRILL $DNS_CHECK_OPTIONS SOA +trace +nocomments "$gad_d" $gad_s 2>/dev/null | grep "IN\WNS\W")
      fi
    fi

    # Query for NS records
    if [[ -z "$res" ]]; then
      test_output "Using $HAS_DIG_OR_DRILL $DNS_CHECK_OPTIONS NS"
      debug Using "$HAS_DIG_OR_DRILL $DNS_CHECK_OPTIONS NS $gad_d $gad_s" to find primary nameserver
      res=$($HAS_DIG_OR_DRILL $DNS_CHECK_OPTIONS NS "$gad_d" $gad_s | grep -E "IN\W(NS|SOA)\W")
    fi

    if [[ -n "$res" ]]; then
      # Convert dig output into an array of nameservers
      IFS=$'\n' read -r -d '' -a ns_servers < <(echo "$res" | awk '$4 ~ "(NS|SOA)" {print $5}' | sed 's/\.$//g')

      # Nameservers from SOA +trace includes root and all intermediate servers, so just use all the ones with the same domain as the last name server
      # i.e. if we have root, google, duckdns1, duckdns2 then return all the duckdns servers
      ns_domain=${ns_servers[${#ns_servers[@]} -1 ]#*.}
      all_auth_dns_servers=""
      for i in "${ns_servers[@]}"; do
        if [[ $i =~ $ns_domain ]]; then
          all_auth_dns_servers="$all_auth_dns_servers $i"
        fi
      done

      if [[ $CHECK_ALL_AUTH_DNS == "true" ]]; then
        primary_ns="$all_auth_dns_servers"
      else
        primary_ns=$(echo "$all_auth_dns_servers" | awk '{print " " $1}')
      fi

      if [[ "$CHECK_PUBLIC_DNS_SERVER" == "true" ]]; then
        primary_ns="$primary_ns $PUBLIC_DNS_SERVER"
      fi

      test_output set primary_ns ="$primary_ns"

      return
    fi
  fi

  # Remove leading '@' if we tried using dig/drill
  gad_s="$orig_gad_s"

  if [[ "$HAS_HOST" == "true" ]]; then
    gad_d="$orig_gad_d"
    debug Using "host -t NS" to find primary name server for "$gad_d"
    if [[ -z "$gad_s" ]]; then
      res=$(host $DNS_CHECK_OPTIONS -t NS "$gad_d"| grep "name server")
    else
      # shellcheck disable=SC2086
      res=$(host $DNS_CHECK_OPTIONS -t NS "$gad_d" $gad_s| grep "name server")
    fi
    if [[ -n "$res" ]]; then
      all_auth_dns_servers=$(echo "$res" | awk '{print $4}' | sed 's/\.$//g'|tr '\n' ' ')
      if [[ $CHECK_ALL_AUTH_DNS == "true" ]]; then
        primary_ns="$all_auth_dns_servers"
      else
        primary_ns=$(echo "$all_auth_dns_servers" | awk '{print $1}')
      fi

      if [[ "$CHECK_PUBLIC_DNS_SERVER" == "true" ]]; then
        primary_ns="$primary_ns $PUBLIC_DNS_SERVER"
      fi

      return
    fi
  fi

  if [[ "$HAS_NSLOOKUP" == "true" ]]; then
    gad_d="$orig_gad_d"
    debug Using "nslookup $DNS_CHECK_OPTIONS -debug -type=soa -type=ns $gad_d $gad_s" to find primary name server
    # shellcheck disable=SC2086
    res=$(nslookup $DNS_CHECK_OPTIONS -debug -type=soa -type=ns "$gad_d" ${gad_s})

    if [[ "$(echo "$res" | grep -c "Non-authoritative")" -gt 0 ]]; then
      # this is a Non-authoritative server, need to check for an authoritative one.
      gad_s=$(echo "$res" | awk '$2 ~ "nameserver" {print $4; exit }' |sed 's/\.$//g')
      if [[ "$(echo "$res" | grep -c "an't find")" -gt 0 ]]; then
        # if domain name doesn't exist, then find auth servers for next level up
        gad_s=$(echo "$res" | awk '$1 ~ "origin" {print $3; exit }')
        gad_d=$(echo "$res" | awk '$1 ~ "->" {print $2; exit}')
        # handle scenario where awk returns nothing
        if [[ -z "$gad_d" ]]; then
          gad_d="$orig_gad_d"
        fi
      fi

      # shellcheck disable=SC2086
      res=$(nslookup $DNS_CHECK_OPTIONS -debug -type=soa -type=ns "$gad_d" ${gad_s})
    fi

    if [[ "$(echo "$res" | grep -c "canonical name")" -gt 0 ]]; then
      gad_d=$(echo "$res" | awk ' $2 ~ "canonical" {print $5; exit }' |sed 's/\.$//g')
    elif [[ "$(echo "$res" | grep -c "an't find")" -gt 0 ]]; then
      gad_s=$(echo "$res" | awk ' $1 ~ "origin" {print $3; exit }')
      gad_d=$(echo "$res"| awk '$1 ~ "->" {print $2; exit}')
      # handle scenario where awk returns nothing
      if [[ -z "$gad_d" ]]; then
        gad_d="$orig_gad_d"
      fi
    fi

    # shellcheck disable=SC2086
    # not quoting gad_s fixes the nslookup: couldn't get address for '': not found warning (#332)
    all_auth_dns_servers=$(nslookup $DNS_CHECK_OPTIONS -debug -type=soa -type=ns "$gad_d" $gad_s \
                          | awk '$1 ~ "nameserver" {print $3}' \
                          | sed 's/\.$//g'| tr '\n' ' ')

    if [[ -n "$all_auth_dns_servers" ]]; then
      if [[ $CHECK_ALL_AUTH_DNS == "true" ]]; then
        primary_ns="$all_auth_dns_servers"
      else
        primary_ns=$(echo "$all_auth_dns_servers" | awk '{print $1}')
      fi

      return
    fi
  fi

  # nslookup on alpine/ubuntu containers doesn't support -debug, print a warning in this case
  # This means getssl cannot check that the DNS record has been updated on the primary name server
  info "Warning: Couldn't find primary DNS server - please set PUBLIC_DNS_SERVER or AUTH_DNS_SERVER in config"
  info "This means getssl cannot check the DNS entry has been updated"
}

get_certificate() { # get certificate for csr, if all domains validated.
  gc_csr=$1         # the csr file
  gc_certfile=$2    # The filename for the certificate
  gc_cafile=$3      # The filename for the CA certificate
  gc_fullchain=$4   # The filename for the fullchain

  der=$(openssl req -in "$gc_csr" -outform DER | urlbase64)

  if [[ $API -eq 1 ]]; then
    send_signed_request "$URL_new_cert" "{\"resource\": \"new-cert\", \"csr\": \"$der\"}" "needbase64"
    # convert certificate information into correct format and save to file.
    CertData=$(awk ' $1 ~ "^Location" {print $2}' "$CURL_HEADER" |tr -d '\r')
    if [[ "$CertData" ]] ; then
      echo -----BEGIN CERTIFICATE----- > "$gc_certfile"
      curl --user-agent "$CURL_USERAGENT" --silent "$CertData" | openssl base64 -e  >> "$gc_certfile"
      echo -----END CERTIFICATE-----  >> "$gc_certfile"
      info "Certificate saved in $CERT_FILE"
    fi

    # If certificate wasn't a valid certificate, error exit.
    if [[ -z "$CertData" ]] ; then
      response2=$(echo "$response" | fold -w64 |openssl base64 -d)
      debug "response was $response"
      error_exit "Sign failed: $(echo "$response2" | grep "detail")"
    fi

    # get a copy of the CA certificate.
    IssuerData=$(grep -i '^Link' "$CURL_HEADER" \
                | cut -d " " -f 2\
                | cut -d ';' -f 1 \
                | sed 's/<//g' \
                | sed 's/>//g')
    if [[ "$IssuerData" ]] ; then
      echo -----BEGIN CERTIFICATE----- > "$gc_cafile"
      curl --user-agent "$CURL_USERAGENT" --silent "$IssuerData" | openssl base64 -e  >> "$gc_cafile"
      echo -----END CERTIFICATE-----  >> "$gc_cafile"
      info "The intermediate CA cert is in $gc_cafile"
    fi
  else # APIv2
    info "Requesting Finalize Link"
    send_signed_request "$FinalizeLink" "{\"csr\": \"$der\"}" "needbase64"
    info Requesting Order Link
    debug "order link was $OrderLink"
    send_signed_request "$OrderLink" ""
    # if ACME response is processing (still creating certificates) then wait and try again.
    while [[ "$response_status" == "processing" ]]; do
      info "ACME server still Processing certificates"
      sleep 5
      send_signed_request "$OrderLink" ""
    done
    info "Requesting certificate"
    CertData=$(json_get "$response" "certificate")
    send_signed_request "$CertData" "" "" "$gc_fullchain"
    IFS=$'\n' read -r -d '' -a alternate_links < <(echo "$responseHeaders" | grep "^Link" | grep "alternate" | awk -F"[<>]" '{print $2}')
    debug "Alternate Links are ${alternate_links[*]}"
    if [[ -n "$PREFERRED_CHAIN" ]]; then
      cert_to_check=$(mktemp 2>/dev/null || mktemp -t getssl.XXXXXX) || error_exit "mktemp failed"
      # Check the default certificate to see if that has the required chain
      cp "$gc_fullchain" "$cert_to_check"
      i=0
      while [[ $i -le ${#alternate_links[@]} ]]; do
        cert_issuer=$(openssl crl2pkcs7 -nocrl -certfile "$cert_to_check" | openssl pkcs7 -print_certs -text -noout | grep 'Issuer:' | tail -1 | awk -F"CN=" '{ print $2 }')
        debug Certificate issued by "$cert_issuer"
        if [[ $cert_issuer = *${PREFERRED_CHAIN}* ]]; then
          debug "Found required certificate"
          cp "$cert_to_check" "$gc_fullchain"
          break
        fi

        if [[ $i -lt ${#alternate_links[@]} ]]; then
          debug "Fetching next alternate certificate $i ${alternate_links[$i]}"
          send_signed_request "${alternate_links[$i]}" "" "" "$cert_to_check"
        fi
        i=$(( i + 1 ))
      done

      # tidy up
      rm -f "$cert_to_check"
    fi

    awk -v CERT_FILE="$gc_certfile" -v CA_CERT="$gc_cafile" 'BEGIN {outfile=CERT_FILE} split_after==1 {outfile=CA_CERT;split_after=0} /-----END CERTIFICATE-----/ {split_after=1} {print > outfile}' "$gc_fullchain"
    if [[ "$FULL_CHAIN_INCLUDE_ROOT" = "true" ]]; then
      # Some of the code below was copied from zakjan/cert-chain-resolver

      # Download the certificate for the issuer using the "CA Issuers" attribute from the AIA x509 extension
      issuer_url=$(openssl x509 -inform pem -noout -text -in "$gc_certfile" | awk 'BEGIN {FS="CA Issuers - URI:"} NF==2 {print $2; exit}')
      debug Issuer for "$gc_certfile" is "$issuer_url"

      # Keep downloading issuer certficates until we find the root certificate (which doesn't have a "CA Issuers" attribure)
      cp "$gc_certfile" "$gc_fullchain"
      while [[ -n "$issuer_url" ]]; do
        debug Fetching certificate issuer from "$issuer_url"
        issuer_cert=$(curl --user-agent "$CURL_USERAGENT" --silent "$issuer_url" | openssl x509 -inform der -outform pem)
        debug Fetched issuer certificate "$(echo "$issuer_cert" | openssl x509 -inform pem -noout -text | awk 'BEGIN {FS="Subject: "} NF==2 {print $2; exit}')"
        echo "$issuer_cert" >> "$gc_fullchain"

        # get issuer for the certificate that's just been downloaded
        issuer_url=$(echo "$issuer_cert" | openssl x509 -inform pem -noout -text | awk 'BEGIN {FS="CA Issuers - URI:"} NF==2 {print $2; exit}')
      done
    fi
    info "Certificate saved in $gc_certfile"
  fi
}

get_cr() { # get curl response
  url="$1"
  debug url "$url"
  response=$(curl --user-agent "$CURL_USERAGENT" --silent "$url")
  ret=$?
  debug response "${response//[$'\t\r\n']}"
  code=$(json_get "$response" status)
  debug code "$code"
  debug "get_cr return code $ret"
  return $ret
}

get_os() { # function to get the current Operating System
  uname_res=$(uname -s)
  if [[ $(date -h 2>&1 | grep -ic busybox) -gt 0 ]]; then
    os="busybox"
  elif [[ ${uname_res} == "Linux" ]]; then
    os="linux"
  elif [[ ${uname_res} == "FreeBSD" ]]; then
    os="bsd"
  elif [[ ${uname_res} == "Darwin" ]]; then
    os="mac"
  elif [[ ${uname_res:0:6} == "CYGWIN" ]]; then
    os="cygwin"
  elif [[ ${uname_res:0:5} == "MINGW" ]]; then
    os="mingw"
  else
    os="unknown"
  fi
  debug "detected os type = $os"
  if [[ -f /etc/issue ]]; then
    debug "Running $(cat /etc/issue)"
  fi
}

get_signing_params() { # get signing parameters from key
  skey=$1
  if openssl rsa -in "${skey}" -noout 2>/dev/null ; then # RSA key
    pub_exp64=$(openssl rsa -in "${skey}" -noout -text \
                | grep publicExponent \
                | grep -oE "0x[a-f0-9]+" \
                | cut -d'x' -f2 \
                | hex2bin \
                | urlbase64)
    pub_mod64=$(openssl rsa -in "${skey}" -noout -modulus \
                | cut -d'=' -f2 \
                | hex2bin \
                | urlbase64)

    jwk='{"e":"'"${pub_exp64}"'","kty":"RSA","n":"'"${pub_mod64}"'"}'
    jwkalg="RS256"
    signalg="sha256"
  elif openssl ec -in "${skey}" -noout 2>/dev/null ; then # Elliptic curve key.
    crv="$(openssl ec -in  "$skey" -noout -text 2>/dev/null | awk '$2 ~ "CURVE:" {print $3}')"
    if [[ -z "$crv" ]]; then
      gsp_keytype="$(openssl ec -in  "$skey" -noout -text 2>/dev/null \
                    | grep "^ASN1 OID:" \
                    | awk '{print $3}')"
      case "$gsp_keytype" in
        prime256v1) crv="P-256" ;;
        secp384r1) crv="P-384" ;;
        secp521r1) crv="P-521" ;;
        *) error_exit "invalid curve algorithm type $gsp_keytype";;
      esac
    fi
    case "$crv" in
      P-256) jwkalg="ES256" ; signalg="sha256" ;;
      P-384) jwkalg="ES384" ; signalg="sha384" ;;
      P-521) jwkalg="ES512" ; signalg="sha512" ;;
      *) error_exit "invalid curve algorithm type $crv";;
    esac
    pubtext="$(openssl ec  -in "$skey"  -noout -text 2>/dev/null \
              | awk '/^pub:/{p=1;next}/^ASN1 OID:/{p=0}p' \
              | tr -d ": \n\r")"
    mid=$(( (${#pubtext} -2) / 2 + 2 ))
    x64=$(echo "$pubtext" | cut -b 3-$mid | hex2bin | urlbase64)
    y64=$(echo "$pubtext" | cut -b $((mid+1))-${#pubtext} | hex2bin | urlbase64)
    jwk='{"crv":"'"$crv"'","kty":"EC","x":"'"$x64"'","y":"'"$y64"'"}'
  else
    error_exit "Invalid key file"
  fi
  thumbprint="$(printf "%s" "$jwk" | openssl dgst -sha256 -binary | urlbase64)"
  debug "jwk alg = $jwkalg"
}

graceful_exit() { # normal exit function.
  exit_code=$1
  clean_up
  # shellcheck disable=SC2086
  exit $exit_code
}

help_message() { # print out the help message
  cat <<- _EOF_
	$PROGNAME ver. $VERSION
	Obtain SSL certificates from the letsencrypt.org ACME server

	$(usage)

	Options:
	  -a, --all          Check all certificates
	  -d, --debug        Output debug information
	  -c, --create       Create default config files
	  -f, --force        Force renewal of cert (overrides expiry checks)
	  -h, --help         Display this help message and exit
	  -i, --install      Install certificates and reload service
	  -q, --quiet        Quiet mode (only outputs on error, success of new cert, or getssl was upgraded)
	  -Q, --mute         Like -q, but also mute notification about successful upgrade
	  -r, --revoke   "cert" "key" [CA_server] Revoke a certificate (the cert and key are required)
	  -u, --upgrade      Upgrade getssl if a more recent version is available - can be used with or without domain(s)
	  -k, --keep     "#" Maximum number of old getssl versions to keep when upgrading
	  -U, --nocheck      Do not check if a more recent version is available
	  -v  --version      Display current version of $PROGNAME
	  -w working_dir "Working directory"
    --preferred-chain "chain" Use an alternate chain for the certificate

	_EOF_
}

hex2bin() { # Remove spaces, add leading zero, escape as hex string ensuring no trailing new line char
#  printf -- "$(cat | os_esed -e 's/[[:space:]]//g' -e 's/^(.(.{2})*)$/0\1/' -e 's/(.{2})/\\x\1/g')"
  echo -e -n "$(cat | os_esed -e 's/[[:space:]]//g' -e 's/^(.(.{2})*)$/0\1/' -e 's/(.{2})/\\x\1/g')"
}

info() { # write out info as long as the quiet flag has not been set.
  if [[ ${_QUIET} -eq 0 ]]; then
    # If running tests then output in TAP format as well (for debugging tests)
    if [[ ${_RUNNING_TEST} -eq 1 ]]; then
      echo "# $(date "+%b %d %T") ${FUNCNAME[1]}:${BASH_LINENO[1]}" "$@" >&3
    fi

    echo "$@"
  fi
}

json_awk() { # AWK json converter used for API2 - needs tidying up ;)
# shellcheck disable=SC2086
echo "$1" | tr -d '\n' | awk '
{
  tokenize($0) # while(get_token()) {print TOKEN}
  if (0 == parse()) {
    apply(JPATHS, NJPATHS)
  }
}

function apply (ary,size,i) {
  for (i=1; i<size; i++)
    print ary[i]
}

function get_token() {
  TOKEN = TOKENS[++ITOKENS] # for internal tokenize()
  return ITOKENS < NTOKENS
}

function parse_array(a1,idx,ary,ret) {
  idx=0
  ary=""
  get_token()
  if (TOKEN != "]") {
    while (1) {
      if (ret = parse_value(a1, idx)) {
        return ret
      }
      idx=idx+1
      ary=ary VALUE
      get_token()
      if (TOKEN == "]") {
        break
      } else if (TOKEN == ",") {
        ary = ary ","
      } else {
        report(", or ]", TOKEN ? TOKEN : "EOF")
        return 2
      }
      get_token()
    }
  }
  VALUE=""
  return 0
}

function parse_object(a1,key,obj) {
  obj=""
  get_token()
  if (TOKEN != "}") {
    while (1) {
      if (TOKEN ~ /^".*"$/) {
        key=TOKEN
      } else {
        report("string", TOKEN ? TOKEN : "EOF")
        return 3
      }
      get_token()
      if (TOKEN != ":") {
        report(":", TOKEN ? TOKEN : "EOF")
        return 4
      }
      get_token()
      if (parse_value(a1, key)) {
        return 5
      }
      obj=obj key ":" VALUE
      get_token()
      if (TOKEN == "}") {
        break
      } else if (TOKEN == ",") {
        obj=obj ","
      } else {
        report(", or }", TOKEN ? TOKEN : "EOF")
        return 6
      }
      get_token()
    }
  }
  VALUE=""
  return 0
}


function parse_value(a1, a2,   jpath,ret,x) {
  jpath=(a1!="" ? a1 "," : "") a2 # "${1:+$1,}$2"
  if (TOKEN == "{") {
    if (parse_object(jpath)) {
      return 7
    }
  } else if (TOKEN == "[") {
    if (ret = parse_array(jpath)) {
      return ret
    }
  } else if (TOKEN == "") { #test case 20150410 #4
    report("value", "EOF")
    return 9
  } else if (TOKEN ~ /^([^0-9])$/) {
    # At this point, the only valid single-character tokens are digits.
    report("value", TOKEN)
    return 9
  } else {
    VALUE=TOKEN
  }
  if (! ("" == jpath || "" == VALUE)) {
    x=sprintf("[%s]\t%s", jpath, VALUE)
    print x
  }
  return 0
}

function parse(   ret) {
  get_token()
  if (ret = parse_value()) {
    return ret
  }
  if (get_token()) {
    report("EOF", TOKEN)
    return 11
  }
  return 0
}

function report(expected, got,   i,from,to,context) {
  from = ITOKENS - 10; if (from < 1) from = 1
  to = ITOKENS + 10; if (to > NTOKENS) to = NTOKENS
  for (i = from; i < ITOKENS; i++)
    context = context sprintf("%s ", TOKENS[i])
  context = context "<<" got ">> "
  for (i = ITOKENS + 1; i <= to; i++)
    context = context sprintf("%s ", TOKENS[i])
  scream("json_awk expected <" expected "> but got <" got "> at input token " ITOKENS "\n" context)
}

function reset() {
  TOKEN=""; delete TOKENS; NTOKENS=ITOKENS=0
  delete JPATHS; NJPATHS=0
  VALUE=""
}

function scream(msg) {
  FAILS[FILENAME] = FAILS[FILENAME] (FAILS[FILENAME]!="" ? "\n" : "") msg
  msg = FILENAME ": " msg
  print msg >"/dev/stderr"
}

function tokenize(a1,pq,pb,ESCAPE,CHAR,STRING,NUMBER,KEYWORD,SPACE) {
  SPACE="[ \t\n]+"
  gsub(/"[^\001-\037"\\]*((\\[^u\001-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^\001-\037"\\]*)*"|-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?|null|false|true|[ \t\n]+|./, "\n&", a1)
  gsub("\n" SPACE, "\n", a1)
  sub(/^\n/, "", a1)
  ITOKENS=0 # get_token() helper
  return NTOKENS = split(a1, TOKENS, /\n/)
}'
}

json_get() { # get values from json
  if [[ -z "$1" ]] || [[ "$1" == "null" ]]; then
    echo "json was blank"
    return
  fi
  if [[ $API = 1 ]]; then
    # remove newlines, so it's a single chunk of JSON
    json_data=$( echo "$1" | tr '\n' ' ')
    # if $3 is defined, this is the section which the item is in.
    if [[ -n "$3" ]]; then
      jg_section=$(echo "$json_data" | awk -F"[}]" '{for(i=1;i<=NF;i++){if($i~/\"'"${3}"'\"/){print $i}}}')
      if [[ "$2" == "uri" ]]; then
        jg_subsect=$(echo "$jg_section" | awk -F"[,]" '{for(i=1;i<=NF;i++){if($i~/\"'"${2}"'\"/){print $(i)}}}')
        jg_result=$(echo "$jg_subsect" | awk -F'"' '{print $4}')
      else
        jg_result=$(echo "$jg_section" | awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/\"'"${2}"'\"/){print $(i+1)}}}')
      fi
    else
      jg_result=$(echo "$json_data" |awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/\"'"${2}"'\"/){print $(i+1)}}}')
    fi
    # check number of quotes
    jg_q=${jg_result//[^\"]/}
    # if 2 quotes, assume it's a quoted variable and just return the data within the quotes.
    if [[ ${#jg_q} -eq 2 ]]; then
      echo "$jg_result" | awk -F'"' '{print $2}'
    else
      echo "$jg_result"
    fi
  else
    if [[ -n "$6" ]]; then
      full=$(json_awk "$1")
      section=$(echo "$full" | grep "\"$2\"" | grep "\"$3\"" | grep "\"$4\"" | awk -F"," '{print $2}')
      echo "$full" | grep "^..${5}\",$section\]" | awk '{print $2}' | tr -d '"'
    elif [[ -n "$5" ]]; then
      full=$(json_awk "$1")
      section=$(echo "$full" | grep "\"$2\"" | grep "\"$3\"" | grep "\"$4\"" | awk -F"," '{print $2}')
      echo "$full" | grep "^..${2}\",$section" | grep "$5" | awk '{print $2}' | tr -d '"'
    elif [[ -n "$3" ]]; then
      json_awk "$1" | grep "^..${2}...${3}" | awk '{print $2}' | tr -d '"'
    elif [[ -n "$2" ]]; then
      json_awk "$1" | grep "^..${2}" | awk '{print $2}' | tr -d '"'
    else
      json_awk "$1"
    fi
  fi
}

obtain_ca_resource_locations()
{
  for suffix in "" "/directory" "/dir";
  do
    # Obtain CA resource locations
    ca_all_loc=$(curl --user-agent "$CURL_USERAGENT" "${CA}${suffix}" 2>/dev/null)
    debug "ca_all_loc from ${CA}${suffix} gives $ca_all_loc"
    # APIv1
    URL_new_reg=$(echo "$ca_all_loc" | grep "new-reg" | awk -F'"' '{print $4}')
    URL_new_authz=$(echo "$ca_all_loc" | grep "new-authz" | awk -F'"' '{print $4}')
    URL_new_cert=$(echo "$ca_all_loc" | grep "new-cert" | awk -F'"' '{print $4}')
    #API v2
    URL_newAccount=$(echo "$ca_all_loc" | grep "newAccount" | awk -F'"' '{print $4}')
    URL_newNonce=$(echo "$ca_all_loc" | grep "newNonce" | awk -F'"' '{print $4}')
    URL_newOrder=$(echo "$ca_all_loc" | grep "newOrder" | awk -F'"' '{print $4}')
    URL_revoke=$(echo "$ca_all_loc" | grep "revokeCert" | awk -F'"' '{print $4}')

    if [[ -n "$URL_new_reg" ]] || [[ -n "$URL_newAccount" ]]; then
      break
    fi
  done

  if [[ -n "$URL_new_reg" ]]; then
    API=1
  elif [[ -n "$URL_newAccount" ]]; then
    API=2
  else
    error_exit "unknown API version"
  fi
  debug "Using API v$API"
}

os_esed() { # Use different sed version for different os types (extended regex)
  if [[ "$os" == "bsd" ]]; then # BSD requires -E flag for extended regex
    sed -E "${@}"
  elif [[ "$os" == "mac" ]]; then # MAC uses older BSD style sed.
    sed -E "${@}"
  else
    sed -r "${@}"
  fi
}

purge_archive() { # purge archive of old, invalid, certificates
  arcdir="$1/archive"
  debug "purging archives in ${arcdir}/"
  for padir in "$arcdir"/????_??_??_??_??; do
    # check each directory
    if [[ -d "$padir" ]]; then
      tstamp=$(basename "$padir"| awk -F"_" '{print $1"-"$2"-"$3" "$4":"$5}')
      if [[ "$os" == "bsd" ]]; then
        direpoc=$(date -j -f "%F %H:%M" "$tstamp" +%s)
      elif [[ "$os" == "mac" ]]; then
        direpoc=$(date -j -f "%F %H:%M" "$tstamp" +%s)
      else
        direpoc=$(date -d "$tstamp" +%s)
      fi
      current_epoc=$(date "+%s")
      # as certs currently valid for 90 days, purge anything older than 100
      purgedate=$((current_epoc - 60*60*24*100))
      if [[ "$direpoc" -lt "$purgedate" ]]; then
        echo "purge $padir"
        rm -rf "${padir:?}"
      fi
    fi
  done
}

reload_service() {  # Runs a command to reload services ( via ssh if needed)
  if [[ -n "$RELOAD_CMD" ]]; then
    info "reloading SSL services"
    for ARELOAD_CMD in "${RELOAD_CMD[@]}"
    do
      if [[ "${ARELOAD_CMD:0:4}" == "ssh:" ]] ; then
        sshhost=$(echo "$ARELOAD_CMD"| awk -F: '{print $2}')
        command=${ARELOAD_CMD:(( ${#sshhost} + 5))}
        debug "running following command to reload cert:"
        debug "ssh $SSH_OPTS $sshhost ${command}"
        # shellcheck disable=SC2029
        # shellcheck disable=SC2086
        ssh $SSH_OPTS "$sshhost" "${command}" 1>/dev/null 2>&1
        # allow 2 seconds for services to restart
        sleep 2
      else
        debug "running reload command: $ARELOAD_CMD"
        if ! eval "$ARELOAD_CMD" ; then
          error_exit "error running: $ARELOAD_CMD"
        fi
      fi
    done
  fi
}

revoke_certificate() { # revoke a certificate
  debug "revoking cert $REVOKE_CERT"
  debug "using key $REVOKE_KEY"
  ACCOUNT_KEY="$REVOKE_KEY"
  # need to set the revoke key as "account_key" since it's used in send_signed_request.
  get_signing_params "$REVOKE_KEY"
  TEMP_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t getssl) || error_exit "mktemp failed"
  debug "revoking from $URL_revoke"
  rcertdata=$(sed '1d;$d' "$REVOKE_CERT" | tr -d "\r\n" | tr '/+' '_-' | tr -d '= ')
  send_signed_request "$URL_revoke" "{\"certificate\": \"$rcertdata\",\"reason\": $REVOKE_REASON}"
  if [[ $code -eq "200" ]]; then
    info "certificate revoked"
  else
    error_exit "Revocation failed: $(echo "$response" | grep "detail")"
  fi
}

requires() { # check if required function is available
  args=("${@}")
  lastarg=${args[${#args[@]}-1]}
  if [[ "$#" -gt 1 ]]; then # if more than 1 value, check list
    for i in "$@"; do
      if [[ "$i" == "$lastarg" ]]; then # if on last variable then exit as not found
        error_exit "this script requires one of: ${*:1:$(($#-1))}"
      fi
      res=$(command -v "$i" 2>/dev/null)
      debug "checking for $i ... $res"
      if [[ -n "$res" ]]; then # if function found, then set variable to function and return
        debug "function $i found at $res  - setting ${lastarg} to $i"
        eval "${lastarg}=\$i"
        return
      fi
    done
  else # only one value, so check it.
    result=$(command -v "$1" 2>/dev/null)
    debug "checking for required $1 ... $result"
    if [[ -z "$result" ]]; then
      error_exit "This script requires $1 installed"
    fi
  fi
}

set_server_type() { # uses SERVER_TYPE to set REMOTE_PORT and REMOTE_EXTRA
  if [[ ${SERVER_TYPE} == "https" ]] || [[ ${SERVER_TYPE} == "webserver" ]]; then
    REMOTE_PORT=443
  elif [[ ${SERVER_TYPE} == "ftp" ]]; then
    REMOTE_PORT=21
    REMOTE_EXTRA="-starttls ftp"
  elif [[ ${SERVER_TYPE} == "ftpi" ]]; then
    REMOTE_PORT=990
  elif [[ ${SERVER_TYPE} == "imap" ]]; then
    REMOTE_PORT=143
    REMOTE_EXTRA="-starttls imap"
  elif [[ ${SERVER_TYPE} == "imaps" ]]; then
    REMOTE_PORT=993
  elif [[ ${SERVER_TYPE} == "pop3" ]]; then
    REMOTE_PORT=110
    REMOTE_EXTRA="-starttls pop3"
  elif [[ ${SERVER_TYPE} == "pop3s" ]]; then
    REMOTE_PORT=995
  elif [[ ${SERVER_TYPE} == "smtp" ]]; then
    REMOTE_PORT=25
    REMOTE_EXTRA="-starttls smtp"
  elif [[ ${SERVER_TYPE} == "smtps_deprecated" ]]; then
    REMOTE_PORT=465
  elif [[ ${SERVER_TYPE} == "smtps" ]] || [[ ${SERVER_TYPE} == "smtp_submission" ]]; then
    REMOTE_PORT=587
    REMOTE_EXTRA="-starttls smtp"
  elif [[ ${SERVER_TYPE} == "xmpp" ]]; then
    REMOTE_PORT=5222
    REMOTE_EXTRA="-starttls xmpp"
  elif [[ ${SERVER_TYPE} == "xmpps" ]]; then
    REMOTE_PORT=5269
  elif [[ ${SERVER_TYPE} == "ldaps" ]]; then
    REMOTE_PORT=636
  elif [[ ${SERVER_TYPE} =~ ^[0-9]+$ ]]; then
    REMOTE_PORT=${SERVER_TYPE}
  else
    info "${DOMAIN}: unknown server type \"$SERVER_TYPE\" in SERVER_TYPE"
    config_errors=true
  fi
}

send_signed_request() { # Sends a request to the ACME server, signed with your private key.
  url=$1
  payload=$2
  needbase64=$3
  outfile=$4 # save response into this file (certificate data)

  debug url "$url"

  CURL_HEADER="$TEMP_DIR/curl.header"
  dp="$TEMP_DIR/curl.dump"

  CURL="curl "
  # shellcheck disable=SC2072
  if [[ "$($CURL -V | head -1 | cut -d' ' -f2 )" > "7.33" ]]; then
    CURL="$CURL --http1.1 "
  fi

  CURL="$CURL --user-agent $CURL_USERAGENT --silent --dump-header $CURL_HEADER "

  if [[ ${_USE_DEBUG} -eq 1 ]]; then
    CURL="$CURL --trace-ascii $dp "
  fi

  # convert payload to url base 64
  payload64="$(printf '%s' "${payload}" | urlbase64)"

  # get nonce from ACME server
  if [[ $API -eq 1 ]]; then
    nonceurl="$CA/directory"
    nonce=$($CURL -I "$nonceurl" | grep "^Replay-Nonce:" | awk '{print $2}' | tr -d '\r\n ')
  else # APIv2
    nonce=$($CURL -I "$URL_newNonce" | grep "^Replay-Nonce:" | awk '{print $2}' | tr -d '\r\n ')
  fi

  nonceproblem="true"
  while [[ "$nonceproblem" == "true" ]]; do

    # Build header with just our public key and algorithm information
    header='{"alg": "'"$jwkalg"'", "jwk": '"$jwk"'}'

    # Build another header which also contains the previously received nonce and encode it as urlbase64
    if [[ $API -eq 1 ]]; then
      protected='{"alg": "'"$jwkalg"'", "jwk": '"$jwk"', "nonce": "'"${nonce}"'", "url": "'"${url}"'"}'
      protected64="$(printf '%s' "${protected}" | urlbase64)"
    else # APIv2
      if [[ -z "$KID" ]]; then
        debug "KID is blank, so using jwk"
        protected='{"alg": "'"$jwkalg"'", "jwk": '"$jwk"', "nonce": "'"${nonce}"'", "url": "'"${url}"'"}'
        protected64="$(printf '%s' "${protected}" | urlbase64)"
      else
        debug "using KID=${KID}"
        protected="{\"alg\": \"$jwkalg\", \"kid\": \"$KID\",\"nonce\": \"${nonce}\", \"url\": \"${url}\"}"
        protected64="$(printf '%s' "${protected}" | urlbase64)"
      fi
    fi

    # Sign header with nonce and our payload with our private key and encode signature as urlbase64
    sign_string "$(printf '%s' "${protected64}.${payload64}")"  "${ACCOUNT_KEY}" "$signalg"

    # Send header + extended header + payload + signature to the acme-server
    debug "payload = $payload"
    if [[ $API -eq 1 ]]; then
      body="{\"header\": ${header},"
      body="${body}\"protected\": \"${protected64}\","
      body="${body}\"payload\": \"${payload64}\","
      body="${body}\"signature\": \"${signed64}\"}"
    else
      body="{"
      body="${body}\"protected\": \"${protected64}\","
      body="${body}\"payload\": \"${payload64}\","
      body="${body}\"signature\": \"${signed64}\"}"
    fi

    code="500"
    loop_limit=5
    while [[ "$code" -eq 500 ]]; do
      if [[ "$outfile" ]] ; then
        $CURL -X POST -H "Content-Type: application/jose+json" --data "$body" "$url" > "$outfile"
        errcode=$?
        response=$(cat "$outfile")
      elif [[ "$needbase64" ]] ; then
        response=$($CURL -X POST -H "Content-Type: application/jose+json" --data "$body" "$url" | urlbase64)
        errcode=$?
      else
        response=$($CURL -X POST -H "Content-Type: application/jose+json" --data "$body" "$url")
        errcode=$?
      fi

      if [[ $errcode -gt 0 || ( "$response" == "" && $url != *"revoke"* ) ]]; then
        error_exit "ERROR curl \"$url\" failed with $errcode and returned $response"
      fi

      responseHeaders=$(cat "$CURL_HEADER")
      if [[ "$needbase64" && ${response##*()} != "{"* ]]; then
        # response is in base64 too, decode
        response=$(urlbase64_decode "$response")
      fi

      debug responseHeaders "$responseHeaders"
      debug response "${response//[$'\t\r\n']}"
      code=$(awk ' $1 ~ "^HTTP" {print $2}' "$CURL_HEADER" | tail -1)
      debug code "$code"
      if [[ "$code" == 4* && $response != *"error:badNonce"* && "$code" != 409 ]]; then
        detail=$(echo "$response" | grep "detail")
        error_exit "ACME server returned error: ${code}: ${detail}"
      fi

      if [[ $API -eq 1 ]]; then
        response_status=$(json_get "$response" status \
                        | head -1| awk -F'"' '{print $2}')
      else # APIv2
        if [[ "$outfile" && "$response" ]]; then
          debug "response written to $outfile"
        elif [[ ${response##*()} == "{"* ]]; then
          response_status=$(json_get "$response" status)
        else
          debug "response not in json format"
          debug "$response"
        fi
      fi
      debug "response status = $response_status"
      if [[ "$code" -eq 500 ]]; then
        info "error on acme server - trying again ...."
        debug "loop_limit = $loop_limit"
        sleep 5
        loop_limit=$((loop_limit - 1))
        if [[ $loop_limit -lt 1 ]]; then
          error_exit "500 error from ACME server:  $response"
        fi
      fi
    done
    if [[ $response == *"error:badNonce"* ]]; then
      debug "bad nonce"
      nonce=$(echo "$responseHeaders" | grep -i "^replay-nonce:" | awk '{print $2}' | tr -d '\r\n ')
      debug "trying new nonce $nonce"
    else
      nonceproblem="false"
    fi
  done
}

sign_string() { # sign a string with a given key and algorithm and return urlbase64
                # sets the result in variable signed64
  str=$1
  key=$2
  signalg=$3

  if openssl rsa -in "${skey}" -noout 2>/dev/null ; then # RSA key
    signed64="$(printf '%s' "${str}" | openssl dgst -"$signalg" -sign "$key" | urlbase64)"
  elif openssl ec -in "${skey}" -noout 2>/dev/null ; then # Elliptic curve key.
    # ECDSA signature width
    # e.g. 521 bits requires 66 bytes to express, a signature consists of 2 integers so 132 bytes
    # https://crypto.stackexchange.com/questions/12299/ecc-key-size-and-signature-size/
    if [ "$signalg" = "sha256" ]; then
      w=64
    elif [ "$signalg" = "sha384" ]; then
      w=96
    elif [ "$signalg" = "sha512" ]; then
      w=132
    else
      error_exit "Unknown signing algorithm $signalg"
    fi
    asn1parse=$(printf '%s' "${str}" | openssl dgst -"$signalg" -sign "$key" | openssl asn1parse -inform DER)
    #shellcheck disable=SC2086
    R=$(echo $asn1parse | awk '{ print $13 }' | cut -c2-)
    debug "R $R"
    #shellcheck disable=SC2086
    S=$(echo $asn1parse | awk '{ print $20 }' | cut -c2-)
    debug "S $S"

    # pad R and S to the correct length for the signing algorithm
    signed64=$(printf "%${w}s%${w}s" "${R}" "${S}" | tr ' ' '0' | hex2bin | urlbase64 )
    debug "encoded RS $signed64"
  fi
}

signal_exit() { # Handle trapped signals
  case $1 in
    INT)
      error_exit "Program interrupted by user" ;;
    TERM)
      echo -e "\n$PROGNAME: Program terminated" >&2
      graceful_exit ;;
    *)
      error_exit "$PROGNAME: Terminating on unknown signal" ;;
  esac
}

urlbase64() { # urlbase64: base64 encoded string with '+' replaced with '-' and '/' replaced with '_'
  openssl base64 -e | tr -d '\n\r' | os_esed -e 's:=*$::g' -e 'y:+/:-_:'
}

# base64url decode
# From: https://gist.github.com/alvis/89007e96f7958f2686036d4276d28e47
urlbase64_decode() {
  INPUT=$1 # $(if [ -z "$1" ]; then echo -n $(cat -); else echo -n "$1"; fi)
  MOD=$(($(echo -n "$INPUT" | wc -c) % 4))
  PADDING=$(if [ $MOD -eq 2 ]; then echo -n '=='; elif [ $MOD -eq 3 ]; then echo -n '=' ; fi)
  echo -n "$INPUT$PADDING" |
    sed s/-/+/g |
    sed s/_/\\//g |
    openssl base64 -d -A
}

usage() { # echos out the program usage
  echo "Usage: $PROGNAME [-h|--help] [-d|--debug] [-c|--create] [-f|--force] [-a|--all] [-q|--quiet]"\
       "[-Q|--mute] [-u|--upgrade] [-k|--keep #] [-U|--nocheck] [-r|--revoke cert key] [-w working_dir]"\
       "[--preferred-chain chain] domain"
}

write_domain_template() { # write out a template file for a domain.
  if [[ -s "$WORKING_DIR/getssl_default.cfg" ]]; then
    export DOMAIN="$DOMAIN"
    export EX_SANS="$EX_SANS"
    envsubst < "$WORKING_DIR/getssl_default.cfg"  > "$1"
  else
    cat > "$1" <<- _EOF_domain_
		# vim: filetype=sh
		#
		# This file is read second (and per domain if running with the -a option)
		# and overwrites any settings from the first file
		#
		# Uncomment and modify any variables you need
		# see https://github.com/srvrco/getssl/wiki/Config-variables for details
		# see https://github.com/srvrco/getssl/wiki/Example-config-files for example configs
		#
		# The staging server is best for testing
		#CA="https://acme-staging-v02.api.letsencrypt.org"
		# This server issues full certificates, however has rate limits
		#CA="https://acme-v02.api.letsencrypt.org"

		# Private key types - can be rsa, prime256v1, secp384r1 or secp521r1
		#PRIVATE_KEY_ALG="rsa"

		# Additional domains - this could be multiple domains / subdomains in a comma separated list
		# Note: this is Additional domains - so should not include the primary domain.
		SANS="${EX_SANS}"

		# Acme Challenge Location. The first line for the domain, the following ones for each additional domain.
		# If these start with ssh: then the next variable is assumed to be the hostname and the rest the location.
		# An ssh key will be needed to provide you with access to the remote server.
		# Optionally, you can specify a different userid for ssh/scp to use on the remote server before the @ sign.
		# If left blank, the username on the local server will be used to authenticate against the remote server.
		# If these start with ftp:/ftpes: then the next variables are ftpuserid:ftppassword:servername:ACL_location
		# These should be of the form "/path/to/your/website/folder/.well-known/acme-challenge"
		# where "/path/to/your/website/folder/" is the path, on your web server, to the web root for your domain.
		# You can also user WebDAV over HTTPS as transport mechanism. To do so, start with davs: followed by username,
		# password, host, port (explicitly needed even if using default port 443) and path on the server.
        # Multiple locations can be defined for a file by separating the locations with a semi-colon.
		#ACL=('/var/www/${DOMAIN}/web/.well-known/acme-challenge'
		#     'ssh:server5:/var/www/${DOMAIN}/web/.well-known/acme-challenge'
		#     'ssh:sshuserid@server5:/var/www/${DOMAIN}/web/.well-known/acme-challenge'
		#     'ftp:ftpuserid:ftppassword:${DOMAIN}:/web/.well-known/acme-challenge'
		#     'davs:davsuserid:davspassword:{DOMAIN}:443:/web/.well-known/acme-challenge'
		#     'ftpes:ftpuserid:ftppassword:${DOMAIN}:/web/.well-known/acme-challenge')

		# Specify SSH options, e.g. non standard port in SSH_OPTS
		# (Can also use SCP_OPTS and SFTP_OPTS)
		# SSH_OPTS=-p 12345

		# Set USE_SINGLE_ACL="true" to use a single ACL for all checks
		#USE_SINGLE_ACL="false"

		# Preferred Chain - use an different certificate root from the default
		# This uses wildcard matching so requesting "X1" returns the correct certificate - may need to escape characters
		# Staging options are: "(STAGING) Doctored Durian Root CA X3" and "(STAGING) Pretend Pear X1"
		# Production options are: "ISRG Root X1" and "ISRG Root X2"
		#PREFERRED_CHAIN="\(STAGING\) Pretend Pear X1"

		# Uncomment this if you need the full chain file to include the root certificate (Java keystores, Nutanix Prism)
		#FULL_CHAIN_INCLUDE_ROOT="true"

		# Location for all your certs, these can either be on the server (full path name)
		# or using ssh /sftp as for the ACL
		#DOMAIN_CERT_LOCATION="/etc/ssl/${DOMAIN}.crt" # this is domain cert
		#DOMAIN_KEY_LOCATION="/etc/ssl/${DOMAIN}.key" # this is domain key
		#CA_CERT_LOCATION="/etc/ssl/chain.crt" # this is CA cert
		#DOMAIN_CHAIN_LOCATION="" # this is the domain cert and CA cert
		#DOMAIN_PEM_LOCATION="" # this is the domain key, domain cert and CA cert

		# The command needed to reload apache / nginx or whatever you use.
		# Several (ssh) commands may be given using a bash array:
		# RELOAD_CMD=('ssh:sshuserid@server5:systemctl reload httpd' 'logger getssl for server5 efficient.')
		#RELOAD_CMD=""

		# Uncomment the following line to prevent non-interactive renewals of certificates
		#PREVENT_NON_INTERACTIVE_RENEWAL="true"

		# Define the server type. This can be https, ftp, ftpi, imap, imaps, pop3, pop3s, smtp,
		# smtps_deprecated, smtps, smtp_submission, xmpp, xmpps, ldaps or a port number which
		# will be checked for certificate expiry and also will be checked after
		# an update to confirm correct certificate is running (if CHECK_REMOTE) is set to true
		#SERVER_TYPE="https"
		#CHECK_REMOTE="true"
		#CHECK_REMOTE_WAIT="2" # wait 2 seconds before checking the remote server
		_EOF_domain_
  fi
}

write_getssl_template() { # write out the main template file
  cat > "$1" <<- _EOF_getssl_
	# vim: filetype=sh
	#
	# This file is read first and is common to all domains
	#
	# Uncomment and modify any variables you need
	# see https://github.com/srvrco/getssl/wiki/Config-variables for details
	#
	# The staging server is best for testing (hence set as default)
	CA="https://acme-staging-v02.api.letsencrypt.org"
	# This server issues full certificates, however has rate limits
	#CA="https://acme-v02.api.letsencrypt.org"

	# The agreement that must be signed with the CA, if not defined the default agreement will be used
	#AGREEMENT="$AGREEMENT"

	# Set an email address associated with your account - generally set at account level rather than domain.
	#ACCOUNT_EMAIL="me@example.com"
	ACCOUNT_KEY_LENGTH=4096
	ACCOUNT_KEY="$WORKING_DIR/account.key"

	# Account key and private key types - can be rsa, prime256v1, secp384r1 or secp521r1
	#ACCOUNT_KEY_TYPE="rsa"
	PRIVATE_KEY_ALG="rsa"
	#REUSE_PRIVATE_KEY="true"

	# Preferred Chain - use an different certificate root from the default
	# This uses wildcard matching so requesting "X1" returns the correct certificate - may need to escape characters
	# Staging options are: "(STAGING) Doctored Durian Root CA X3" and "(STAGING) Pretend Pear X1"
	# Production options are: "ISRG Root X1" and "ISRG Root X2"
	#PREFERRED_CHAIN="\(STAGING\) Pretend Pear X1"

	# Uncomment this if you need the full chain file to include the root certificate (Java keystores, Nutanix Prism)
	#FULL_CHAIN_INCLUDE_ROOT="true"

	# The command needed to reload apache / nginx or whatever you use.
	# Several (ssh) commands may be given using a bash array:
	# RELOAD_CMD=('ssh:sshuserid@server5:systemctl reload httpd' 'logger getssl for server5 efficient.')
	#RELOAD_CMD=""

	# The time period within which you want to allow renewal of a certificate
	#  this prevents hitting some of the rate limits.
	# Creating a file called FORCE_RENEWAL in the domain directory allows one-off overrides
	# of this setting
	RENEW_ALLOW="30"

	# Define the server type. This can be https, ftp, ftpi, imap, imaps, pop3, pop3s, smtp,
	# smtps_deprecated, smtps, smtp_submission, xmpp, xmpps, ldaps or a port number which
	# will be checked for certificate expiry and also will be checked after
	# an update to confirm correct certificate is running (if CHECK_REMOTE) is set to true
	SERVER_TYPE="https"
	CHECK_REMOTE="true"

	# Use the following 3 variables if you want to validate via DNS
	#VALIDATE_VIA_DNS="true"
	#DNS_ADD_COMMAND=
	#DNS_DEL_COMMAND=

        # Unusual configurations (especially split views) may require these.
        # If you have a mixture, these can go in the per-domain getssl.cfg.
        #
        # If you must use an external DNS Server (e.g. due to split views)
        # Specify it here.  Otherwise, the default is to find the zone master.
        # The default will usually work.
        # PUBLIC_DNS_SERVER="8.8.8.8"

        # If getssl is unable to determine the authoritative nameserver for a domain
        # it will as you to enter AUTH_DNS_SERVER.  This is a server that
        # can answer queries for the zone - a master or a slave, not a recursive server.
        # AUTH_DNS_SERVER="10.0.0.14"
	_EOF_getssl_
}

write_openssl_conf() { # write out a minimal openssl conf
  cat > "$1" <<- _EOF_openssl_conf_
	# minimal openssl.cnf file
	distinguished_name  = req_distinguished_name
	[ req_distinguished_name ]
	[v3_req]
	[v3_ca]
	_EOF_openssl_conf_
}

# Trap signals
trap "signal_exit TERM" TERM HUP
trap "signal_exit INT"  INT

# Parse command-line
while [[ -n ${1+defined} ]]; do
  case $1 in
    -h | --help)
      help_message; graceful_exit ;;
    -v | --version)
      echo "$PROGNAME V$VERSION"; graceful_exit ;;
    -d | --debug)
      _USE_DEBUG=1 ;;
    -c | --create)
      _CREATE_CONFIG=1 ;;
    -f | --force)
      _FORCE_RENEW=1 ;;
    --notify-valid)
      # Exit 2 if certificate is valid and doesn't need renewing
      _NOTIFY_VALID=2 ;;
    -a | --all)
      _CHECK_ALL=1 ;;
    -k | --keep)
      shift; _KEEP_VERSIONS="$1";;
    -q | --quiet)
      _QUIET=1 ;;
    -Q | --mute)
      _QUIET=1
      _MUTE=1 ;;
    -r | --revoke)
      _REVOKE=1
      shift
      REVOKE_CERT="$1"
      shift
      REVOKE_KEY="$1"
      shift
      CA="$1"
      REVOKE_CA="$1"
      REVOKE_REASON=0 ;;
    -u | --upgrade)
      _UPGRADE=1 ;;
    -U | --nocheck)
      _UPGRADE_CHECK=0 ;;
    -i | --install)
      _CERT_INSTALL=1 ;;
    --check-config)
      _ONLY_CHECK_CONFIG=1 ;;
    -w)
      shift; WORKING_DIR="$1" ;;
    -preferred-chain)
      shift; PREFERRED_CHAIN="$1" ;;
    --source)
      return ;;
    -*)
      usage
      error_exit "Unknown option $1" ;;
    *)
      if [[ -n $DOMAIN ]]; then
        error_exit "invalid command line $DOMAIN - it appears to contain more than one domain"
      fi
      DOMAIN="$1"
      if [[ -z $DOMAIN ]]; then
        error_exit "invalid command line - it appears to contain a null variable"
      fi ;;
  esac
  shift
done

# Main logic
############

# Get the current OS, so the correct functions can be used for that OS. (sets the variable os)
get_os

# check if "recent" version of bash.
#if [[ "${BASH_VERSINFO[0]}${BASH_VERSINFO[1]}" -lt 42 ]]; then
#  info "this script is designed for bash v4.2 or later - earlier version may give errors"
#fi

#check if required applications are included

requires which
requires openssl
requires curl
requires dig nslookup drill host DNS_CHECK_FUNC
requires dirname
requires awk
requires tr
requires date
requires grep
requires sed
requires sort
requires mktemp

# Check if upgrades are available (unless they have specified -U to ignore Upgrade checks)
if [[ $_UPGRADE_CHECK -eq 1 ]]; then
  check_getssl_upgrade
  # if nothing in command line and no revocation and not only config check,
  # then exit after upgrade
  if [[ -z "$DOMAIN" ]] && [[ ${_CHECK_ALL} -ne 1 ]] && [[ ${_REVOKE} -ne 1 ]] && [ "${_ONLY_CHECK_CONFIG}" -ne 1 ]; then
    graceful_exit
  fi
fi

# Revoke a certificate if requested
if [[ $_REVOKE -eq 1 ]]; then
  if [[ -z $REVOKE_CA ]]; then
    CA=$DEFAULT_REVOKE_CA
  elif [[ "$REVOKE_CA" == "-d" ]]; then
    _USE_DEBUG=1
    CA=$DEFAULT_REVOKE_CA
  else
    CA=$REVOKE_CA
  fi

  obtain_ca_resource_locations
  revoke_certificate
  graceful_exit
fi

# get latest agreement from CA (as default)
AGREEMENT=$(curl --user-agent "$CURL_USERAGENT" -I "${CA}/terms" 2>/dev/null | awk 'tolower($1) ~ "location:" {print $2}'|tr -d '\r')

# if nothing in command line, print help and exit.
if [[ -z "$DOMAIN" ]] && [[ ${_CHECK_ALL} -ne 1 ]]; then
  help_message
  graceful_exit
fi

# Test working directory candidates if unset. Last candidate defaults (~/getssl/)
if [[ -z "${WORKING_DIR}" ]]
then
  for WORKING_DIR in "${WORKING_DIR_CANDIDATES[@]}"
  do
    debug "Testing working dir location '${WORKING_DIR}'"
    if [[ -s "$WORKING_DIR/getssl.cfg" ]]
    then
      break
    fi
  done
fi

# if the "working directory" doesn't exist, then create it.
if [[ ! -d "$WORKING_DIR" ]]; then
  debug "Making working directory - $WORKING_DIR"
  mkdir -p "$WORKING_DIR"
fi

# read any variables from config in working directory
if [[ -s "$WORKING_DIR/getssl.cfg" ]]; then
  debug "reading config from $WORKING_DIR/getssl.cfg"
  # shellcheck source=/dev/null
  . "$WORKING_DIR/getssl.cfg"
fi

if [[ -n "$DNS_CHECK_FUNC" ]]; then
  requires "${DNS_CHECK_FUNC}"
else
  requires nslookup drill dig host DNS_CHECK_FUNC
fi

# Define defaults for variables not set in the main config.
ACCOUNT_KEY="${ACCOUNT_KEY:=$WORKING_DIR/account.key}"
DOMAIN_STORAGE="${DOMAIN_STORAGE:=$WORKING_DIR}"
DOMAIN_DIR="$DOMAIN_STORAGE/$DOMAIN"
CERT_FILE="$DOMAIN_DIR/${DOMAIN}.crt"
FULL_CHAIN="$DOMAIN_DIR/fullchain.crt"
CA_CERT="$DOMAIN_DIR/chain.crt"
TEMP_DIR="$DOMAIN_DIR/tmp"
if [[ "$os" == "mingw" ]]; then
  CSR_SUBJECT="//"
fi

# Set the OPENSSL_CONF environment variable so openssl knows which config to use
export OPENSSL_CONF=$SSLCONF

# if "-a" option then check other parameters and create run for each domain.
if [[ ${_CHECK_ALL} -eq 1 ]]; then
  info "Check all certificates"

  if [[ ${_CREATE_CONFIG} -eq 1 ]]; then
    error_exit "cannot combine -c|--create with -a|--all"
  fi

  if [[ ${_FORCE_RENEW} -eq 1 ]]; then
    error_exit "cannot combine -f|--force with -a|--all because of rate limits"
  fi

  if [[ ! -d "$DOMAIN_STORAGE" ]]; then
    error_exit "DOMAIN_STORAGE not found  - $DOMAIN_STORAGE"
  fi

  for dir in "${DOMAIN_STORAGE}"/*; do
    if [[ -d "$dir" ]]; then
      debug "Checking $dir"
      cmd="$0 -U" # No update checks when calling recursively
      if [[ ${_USE_DEBUG} -eq 1 ]]; then
        cmd="$cmd -d"
      fi
      if [[ ${_QUIET} -eq 1 ]]; then
        cmd="$cmd -q"
      fi
      # check if $dir is a directory with a getssl.cfg in it
      if [[ -f "$dir/getssl.cfg" ]]; then
        cmd="$cmd -w $WORKING_DIR \"$(basename "$dir")\""
        debug "CMD: $cmd"
        eval "$cmd"
      fi
    fi
  done

  graceful_exit
fi
# end of "-a" option (looping through all domains)

# if "-c|--create" option used, then create config files.
if [[ ${_CREATE_CONFIG} -eq 1 ]]; then
  # If main config file does not exists then create it.
  if [[ ! -s "$WORKING_DIR/getssl.cfg" ]]; then
    info "creating main config file $WORKING_DIR/getssl.cfg"
    if [[ ! -s "$SSLCONF" ]]; then
      SSLCONF="$WORKING_DIR/openssl.cnf"
      write_openssl_conf "$SSLCONF"
    fi
    write_getssl_template "$WORKING_DIR/getssl.cfg"
  fi
  # If domain and domain config don't exist then create them.
  if [[ ! -d "$DOMAIN_DIR" ]]; then
    info "Making domain directory - $DOMAIN_DIR"
    mkdir -p "$DOMAIN_DIR"
  fi
  if [[ -s "$DOMAIN_DIR/getssl.cfg" ]]; then
    info "domain config already exists $DOMAIN_DIR/getssl.cfg"
  else
    info "creating domain config file in $DOMAIN_DIR/getssl.cfg"
    # if domain has an existing cert, copy from domain and use to create defaults.
    EX_CERT=$(echo \
      | openssl s_client -servername "${DOMAIN##\*.}" -connect "${DOMAIN##\*.}:443" 2>/dev/null \
      | openssl x509 2>/dev/null)
    EX_SANS="www.${DOMAIN##\*.}"
    if [[ -n "${EX_CERT}" ]]; then
      escaped_d=${DOMAIN/\*/\\\*}
      EX_SANS=$(echo "$EX_CERT" \
        | openssl x509 -noout -text 2>/dev/null| grep "Subject Alternative Name" -A2 \
        | grep -Eo "DNS:[a-zA-Z 0-9.\*-]*" | sed "s@DNS:${escaped_d}@@g" | grep -v '^$' | cut -c 5-)
      EX_SANS=${EX_SANS//$'\n'/','}
    fi
    if [[ -n "${EX_SANS}" ]]; then
      info "Adding SANS=$EX_SANS from certificate installed on ${DOMAIN##\*.} to new configuration file"
    fi
    write_domain_template "$DOMAIN_DIR/getssl.cfg"
    info "created domain config file in $DOMAIN_DIR/getssl.cfg"
  fi
  TEMP_DIR="$DOMAIN_DIR/tmp"
  # end of "-c|--create" option, so exit
  graceful_exit
fi
# end of "-c|--create" option to create config file.

# if domain directory doesn't exist, then create it.
if [[ ! -d "$DOMAIN_DIR" ]]; then
  debug "Making working directory - $DOMAIN_DIR"
  mkdir -p "$DOMAIN_DIR"
fi

# define a temporary directory, and if it doesn't exist, create it.
TEMP_DIR="$DOMAIN_DIR/tmp"
if [[ ! -d "${TEMP_DIR}" ]]; then
  debug "Making temp directory - ${TEMP_DIR}"
  mkdir -p "${TEMP_DIR}"
fi

# read any variables from config in domain directory
if [[ -s "$DOMAIN_DIR/getssl.cfg" ]]; then
  debug "reading config from $DOMAIN_DIR/getssl.cfg"
  # shellcheck source=/dev/null
  . "$DOMAIN_DIR/getssl.cfg"
fi

# Ensure SANS is comma separated by replacing any number of commas or spaces with a single comma
# shellcheck disable=SC2001
SANS=$(echo "$SANS" | sed 's/[, ]\+/,/g')

# from SERVER_TYPE set REMOTE_PORT and REMOTE_EXTRA
set_server_type

# check what dns utils are installed
find_dns_utils

# Find what ftp client is installed
find_ftp_command

# auto upgrade clients to v2
auto_upgrade_v2

# check config for typical errors.
check_config

# exit if just checking config (used for testing)
if [ "${_ONLY_CHECK_CONFIG}" -eq 1 ]; then
  info "Configuration check successful"
  graceful_exit
fi

# if -i|--install install certs, reload and exit
if [ "0${_CERT_INSTALL}" -eq 1 ]; then
  cert_install
  reload_service
  graceful_exit
fi

if [[ -e "$DOMAIN_DIR/FORCE_RENEWAL" ]]; then
  rm -f "$DOMAIN_DIR/FORCE_RENEWAL" || error_exit "problem deleting file $DOMAIN_DIR/FORCE_RENEWAL"
  _FORCE_RENEW=1
  info "${DOMAIN}: forcing renewal (due to FORCE_RENEWAL file)"
fi

obtain_ca_resource_locations

# Check if awk supports json_awk (required for ACMEv2)
if [[ $API -eq 2 ]]; then
    json_awk_test=$(json_awk '{ "test": "1" }' 2>/dev/null)
    if [[ "${json_awk_test}" == "" ]]; then
        error_exit "Your version of awk does not work with json_awk (see http://github.com/step-/JSON.awk/issues/6), please install a newer version of mawk or gawk"
    fi
fi

# if check_remote is true then connect and obtain the current certificate (if not forcing renewal)
if [[ "${CHECK_REMOTE}" == "true" ]] && [[ $_FORCE_RENEW -eq 0 ]]; then
  real_d=${DOMAIN##\*.}
  debug "getting certificate for $DOMAIN from remote server ($real_d)"
  if [[ "$DUAL_RSA_ECDSA" == "true" ]]; then
    # shellcheck disable=SC2086
    # check if openssl supports RSA-PSS
    if [[ $(echo | openssl s_client -servername "${real_d}" -connect "${real_d}:${REMOTE_PORT}" ${REMOTE_EXTRA} -sigalgs RSA-PSS+SHA256 2>/dev/null) ]]; then
        CIPHER="-sigalgs RSA+SHA256:RSA+SHA384:RSA+SHA512:RSA-PSS+SHA256:RSA-PSS+SHA512"
    else
        CIPHER="-sigalgs RSA+SHA256:RSA+SHA384:RSA+SHA512"
    fi
  else
    CIPHER=""
  fi
  # shellcheck disable=SC2086
  EX_CERT=$(echo \
    | openssl s_client -servername "${real_d}" -connect "${real_d}:${REMOTE_PORT}" ${REMOTE_EXTRA} ${CIPHER} 2>/dev/null \
    | openssl x509 2>/dev/null)
  if [[ -n "$EX_CERT" ]]; then # if obtained a cert
    if [[ -s "$CERT_FILE" ]]; then # if local exists
      CERT_LOCAL=$(openssl x509 -noout -fingerprint < "$CERT_FILE" 2>/dev/null)
    else # since local doesn't exist leave empty so that the domain validation will happen
      CERT_LOCAL=""
    fi
    CERT_REMOTE=$(echo "$EX_CERT" | openssl x509 -noout -fingerprint 2>/dev/null)
    if [[ "$CERT_LOCAL" == "$CERT_REMOTE" ]]; then
      debug "certificate on server is same as the local cert"
    else
      # check if the certificate is for the right domain
      EX_CERT_DOMAIN=$(echo "$EX_CERT" | openssl x509 -text \
        | sed -n -e 's/^ *Subject: .*CN=\([A-Za-z0-9.-]*\).*$/\1/p; /^ *DNS:.../ { s/ *DNS://g; y/,/\n/; p; }' \
        | sort -u | grep "^$DOMAIN\$")
      if [[ "$EX_CERT_DOMAIN" == "$DOMAIN" ]]; then
        # check renew-date on ex_cert and compare to local ( if local exists)
        enddate_ex=$(echo "$EX_CERT" | openssl x509 -noout -enddate 2>/dev/null| cut -d= -f 2-)
        enddate_ex_s=$(date_epoc "$enddate_ex")
        debug "external cert has enddate $enddate_ex ( $enddate_ex_s ) "
        if [[ -s "$CERT_FILE" ]]; then # if local exists
          enddate_lc=$(openssl x509 -noout -enddate < "$CERT_FILE" 2>/dev/null| cut -d= -f 2-)
          enddate_lc_s=$(date_epoc "$enddate_lc")
          debug "local cert has enddate $enddate_lc ( $enddate_lc_s ) "
        else
          enddate_lc_s=0
          debug "local cert doesn't exist"
        fi
        if [[ "$enddate_ex_s" -eq "$enddate_lc_s" ]]; then
          debug "certificates expire at the same time"
        elif [[ "$enddate_ex_s" -gt "$enddate_lc_s" ]]; then
          # remote has longer to expiry date than local copy.
          debug "remote cert has longer to run than local cert - ignoring"
        else
          info "${DOMAIN}: remote cert expires sooner than local, attempting to upload from local"
          copy_file_to_location "domain certificate" \
                                "$CERT_FILE" \
                                "$DOMAIN_CERT_LOCATION"
          copy_file_to_location "private key" \
                                "$DOMAIN_DIR/${DOMAIN}.key" \
                                "$DOMAIN_KEY_LOCATION"
          copy_file_to_location "CA certificate" "$CA_CERT" "$CA_CERT_LOCATION"
          cat "$CERT_FILE" "$CA_CERT" > "$TEMP_DIR/${DOMAIN}_chain.pem"
          copy_file_to_location "full pem" \
                                "$TEMP_DIR/${DOMAIN}_chain.pem" \
                                "$DOMAIN_CHAIN_LOCATION"
          umask 077
          cat "$DOMAIN_DIR/${DOMAIN}.key" "$CERT_FILE" > "$TEMP_DIR/${DOMAIN}_K_C.pem"
          umask "$ORIG_UMASK"
          copy_file_to_location "private key and domain cert pem" \
                                "$TEMP_DIR/${DOMAIN}_K_C.pem"  \
                                "$DOMAIN_KEY_CERT_LOCATION"
          umask 077
          cat "$DOMAIN_DIR/${DOMAIN}.key" "$CERT_FILE" "$CA_CERT" > "$TEMP_DIR/${DOMAIN}.pem"
          umask "$ORIG_UMASK"
          copy_file_to_location "full pem" \
                                "$TEMP_DIR/${DOMAIN}.pem"  \
                                "$DOMAIN_PEM_LOCATION"
          reload_service
        fi
      else
        # Get the domain from the existing certificate for the error message
        EX_CERT_DOMAIN=$(echo "$EX_CERT" | openssl x509 -text \
          | sed -n -e 's/^ *Subject: .*CN=\([A-Za-z0-9.-]*\).*$/\1/p; /^ *DNS:.../ { s/ *DNS://g; y/,/\n/; p; }' \
          | sort -u | head -1)
        info "${DOMAIN}: Certificate on remote domain does not match, ignoring remote certificate ($EX_CERT_DOMAIN != $real_d)"
      fi
    fi
  else
    info "${DOMAIN}: no certificate obtained from host"
  fi
  # end of .... if obtained a cert
fi
# end of .... check_remote is true then connect and obtain the current certificate

# if there is an existing certificate file, check details.
if [[ -s "$CERT_FILE" ]]; then
  debug "certificate $CERT_FILE exists"
  enddate=$(openssl x509 -in "$CERT_FILE" -noout -enddate 2>/dev/null| cut -d= -f 2-)
  debug "local cert is valid until $enddate"
  if [[ "$enddate" != "-" ]]; then
    enddate_s=$(date_epoc "$enddate")
    if [[ $(date_renew) -lt "$enddate_s" ]] && [[ $_FORCE_RENEW -ne 1 ]]; then
      issuer=$(openssl x509 -in "$CERT_FILE" -noout -issuer 2>/dev/null)
      if [[ "$issuer" == *"Fake LE Intermediate"* ]] && [[ "$CA" == "https://acme-v02.api.letsencrypt.org" ]]; then
        debug "upgrading from fake cert to real"
      else
        info "${DOMAIN}: certificate is valid for more than $RENEW_ALLOW days (until $enddate)"
        # everything is OK, so exit, if requested with the --notify-valid, exit with code 2
        graceful_exit $_NOTIFY_VALID
      fi
    else
      debug "${DOMAIN}: certificate needs renewal"
    fi
  fi
fi
# end of .... if there is an existing certificate file, check details.

if [[ ! -t 0 ]] && [[ "$PREVENT_NON_INTERACTIVE_RENEWAL" = "true" ]]; then
  errmsg="$DOMAIN due for renewal,"
  errmsg="${errmsg} but not completed due to PREVENT_NON_INTERACTIVE_RENEWAL=true in config"
  error_exit "$errmsg"
fi

# create account key if it doesn't exist.
if [[ -s "$ACCOUNT_KEY" ]]; then
  debug "Account key exists at $ACCOUNT_KEY skipping generation"
else
  info "creating account key $ACCOUNT_KEY"
  create_key "$ACCOUNT_KEY_TYPE" "$ACCOUNT_KEY" "$ACCOUNT_KEY_LENGTH"
fi

# if not reusing private key, then remove the old keys
if [[ "$REUSE_PRIVATE_KEY" != "true" ]]; then
  if [[ -s "$DOMAIN_DIR/${DOMAIN}.key" ]]; then
    rm -f "$DOMAIN_DIR/${DOMAIN}.key"
  fi
  if [[ -s "$DOMAIN_DIR/${DOMAIN}.ec.key" ]]; then
    rm -f "$DOMAIN_DIR/${DOMAIN}.ec.key"
  fi
fi
# create new domain keys if they don't already exist
if [[ "$DUAL_RSA_ECDSA" == "false" ]]; then
  create_key "${PRIVATE_KEY_ALG}" "$DOMAIN_DIR/${DOMAIN}.key" "$DOMAIN_KEY_LENGTH"
else
  create_key "rsa" "$DOMAIN_DIR/${DOMAIN}.key" "$DOMAIN_KEY_LENGTH"
  create_key "${PRIVATE_KEY_ALG}" "$DOMAIN_DIR/${DOMAIN}.ec.key" "$DOMAIN_KEY_LENGTH"
fi
# End of creating domain keys.

#create SAN
if [[ -z "$SANS" ]]; then
  SANLIST="subjectAltName=DNS:${DOMAIN}"
elif [[ "$IGNORE_DIRECTORY_DOMAIN" == "true" ]]; then
  SANLIST="subjectAltName=DNS:${SANS//[, ]/,DNS:}"
else
  SANLIST="subjectAltName=DNS:${DOMAIN},DNS:${SANS//[, ]/,DNS:}"
fi
debug "created SAN list = $SANLIST"

#create CSR's
if [[ "$DUAL_RSA_ECDSA" == "false" ]]; then
  create_csr "$DOMAIN_DIR/${DOMAIN}.csr" "$DOMAIN_DIR/${DOMAIN}.key"
else
  create_csr "$DOMAIN_DIR/${DOMAIN}.csr" "$DOMAIN_DIR/${DOMAIN}.key"
  create_csr "$DOMAIN_DIR/${DOMAIN}.ec.csr" "$DOMAIN_DIR/${DOMAIN}.ec.key"
fi

# use account key to register with CA
# currently the code registers every time, and gets an "already registered" back if it has been.
get_signing_params "$ACCOUNT_KEY"

info "Registering account"
# send the request to the ACME server.
if [[ $API -eq 1 ]]; then
  if [[ "$ACCOUNT_EMAIL" ]] ; then
	regjson='{"resource": "new-reg", "contact": ["mailto: '$ACCOUNT_EMAIL'"], "agreement": "'$AGREEMENT'"}'
  else
	regjson='{"resource": "new-reg", "agreement": "'$AGREEMENT'"}'
  fi
  send_signed_request "$URL_new_reg"  "$regjson"
elif [[ $API -eq 2 ]]; then
  if [[ "$ACCOUNT_EMAIL" ]] ; then
	regjson='{"termsOfServiceAgreed": true, "contact": ["mailto: '$ACCOUNT_EMAIL'"]}'
  else
	regjson='{"termsOfServiceAgreed": true}'
  fi
  send_signed_request "$URL_newAccount"  "$regjson"
else
	debug "cant determine account API"
	graceful_exit
fi

if [[ "$code" == "" ]] || [[ "$code" == '201' ]] ; then
  info "Registered"
  KID=$(echo "$responseHeaders" | grep -i "^location" | awk '{print $2}'| tr -d '\r\n ')
  debug "KID=_$KID}_"
  echo "$response" > "$TEMP_DIR/account.json"
elif [[ "$code" == '409' ]] ; then
  KID=$(echo "$responseHeaders" | grep -i "^location" | awk '{print $2}'| tr -d '\r\n ')
  debug responseHeaders "$responseHeaders"
  debug "Already registered KID=$KID"
elif [[ "$code" == '200' ]] ; then
  KID=$(echo "$responseHeaders" | grep -i "^location" | awk '{print $2}'| tr -d '\r\n ')
  debug responseHeaders "$responseHeaders"
  debug "Already registered account, KID=${KID}"
else
  error_exit "Error registering account ...$responseHeaders ... $(json_get "$response" detail)"
fi
# end of registering account with CA

# verify each domain
info "Verify each domain"

# loop through domains for cert ( from SANS list)
if [[ "$IGNORE_DIRECTORY_DOMAIN" == "true" ]]; then
  read -r -a alldomains <<< "${SANS//[, ]/ }"
else
  read -r -a alldomains <<< "$(echo "$DOMAIN,$SANS" | sed "s/,/ /g")"
fi

if [[ $API -eq 2 ]]; then
  create_order
fi

fulfill_challenges

# Verification has been completed for all SANS, so request certificate.
info "Verification completed, obtaining certificate."

#obtain the certificate.
get_certificate "$DOMAIN_DIR/${DOMAIN}.csr" \
                "$CERT_FILE" \
                "$CA_CERT" \
                "$FULL_CHAIN"
if [[ "$DUAL_RSA_ECDSA" == "true" ]]; then
  info "Creating order for EC certificate"
  if [[ $API -eq 2 ]]; then
    create_order
    fulfill_challenges
  fi
  info "obtaining EC certificate."
  get_certificate "$DOMAIN_DIR/${DOMAIN}.ec.csr" \
                  "${CERT_FILE%.*}.ec.crt" \
                  "${CA_CERT%.*}.ec.crt" \
                  "${FULL_CHAIN%.*}.ec.crt"
fi

# create Archive of new certs and keys.
cert_archive

debug "Certificates obtained and archived locally, will now copy to specified locations"

# copy certs to the correct location (creating concatenated files as required)
cert_install

# Run reload command to restart apache / nginx or whatever system
reload_service

# deactivate authorizations
if [[ "$DEACTIVATE_AUTH" == "true" ]]; then
  debug "in deactivate list is $deactivate_url_list"
  for deactivate_url in $deactivate_url_list; do
    send_signed_request "$deactivate_url" ""
    d=$(json_get "$response" "hostname")
    info "deactivating domain $d"
    debug "deactivating  $deactivate_url"
    send_signed_request "$deactivate_url" "{\"resource\": \"authz\", \"status\": \"deactivated\"}"
    # check response
    if [[ "$code" == "200" ]]; then
      debug "Authorization deactivated"
    else
      error_exit "$domain: Deactivation error: $code"
    fi
  done
fi
# end of deactivating authorizations

# Check if the certificate is installed correctly
if [[ ${CHECK_REMOTE} == "true" ]]; then
  real_d=${DOMAIN##\*.}
  sleep "$CHECK_REMOTE_WAIT"
  if [[ "$DUAL_RSA_ECDSA" == "true" ]]; then
    # shellcheck disable=SC2086
    # check if openssl supports RSA-PSS
    if [[ $(echo | openssl s_client -servername "${real_d}" -connect "${real_d}:${REMOTE_PORT}" ${REMOTE_EXTRA} -sigalgs RSA-PSS+SHA256 2>/dev/null) ]]; then
        PARAMS=("-sigalgs RSA-PSS+SHA256:RSA-PSS+SHA512:RSA+SHA256:RSA+SHA384:RSA+SHA512" "-sigalgs ECDSA+SHA256:ECDSA+SHA384:ECDSA+SHA512")
    else
        PARAMS=("-sigalgs RSA+SHA256:RSA+SHA384:RSA+SHA512" "-sigalgs ECDSA+SHA256:ECDSA+SHA384:ECDSA+SHA512")
    fi

    CERTS=("$CERT_FILE" "${CERT_FILE%.*}.ec.crt")
    TYPES=("rsa" "$PRIVATE_KEY_ALG")
  else
    PARAMS=("")
    CERTS=("$CERT_FILE")
    TYPES=("$PRIVATE_KEY_ALG")
  fi

  for ((i=0; i<${#PARAMS[@]};++i)); do
    debug "Checking ${CERTS[i]}"
    # shellcheck disable=SC2086
    debug openssl s_client -servername "${real_d}" -connect "${real_d}:${REMOTE_PORT}" ${REMOTE_EXTRA} ${PARAMS[i]}
    # shellcheck disable=SC2086
    CERT_REMOTE=$(echo \
        | openssl s_client -servername "${real_d}" -connect "${real_d}:${REMOTE_PORT}" ${REMOTE_EXTRA} ${PARAMS[i]} 2>/dev/null \
        | openssl x509 -noout -fingerprint 2>/dev/null)
    CERT_LOCAL=$(openssl x509 -noout -fingerprint < "${CERTS[i]}" 2>/dev/null)
    debug CERT_LOCAL="${CERT_LOCAL}"
    debug CERT_REMOTE="${CERT_REMOTE}"
    if [[ "$CERT_LOCAL" == "$CERT_REMOTE" ]]; then
        info "${real_d} - ${TYPES[i]} certificate installed OK on server"
    elif [[ "$CERT_REMOTE" == "" ]]; then
        info "${CERTS[i]} not returned by server"
        error_exit "${real_d} - ${TYPES[i]} certificate obtained but not installed on server"
    else
        info "${CERTS[i]} didn't match server"
        error_exit "${real_d} - ${TYPES[i]} certificate obtained but certificate on server is different from the new certificate"
    fi
  done
fi
# end of Check if the certificate is installed correctly

# To have reached here, a certificate should have been successfully obtained.
# Use echo rather than info so that 'quiet' is ignored.
echo "certificate obtained for ${DOMAIN}"

# gracefully exit ( tidying up temporary files etc).
graceful_exit
