#!/usr/bin/env sh

#This file name is "dns_freedns.sh"
#So, here must be a method dns_freedns_add()
#Which will be called by acme.sh to add the txt record to your api system.
#returns 0 means success, otherwise error.
#
#Author: David Kerr
#Report Bugs here: https://github.com/dkerr64/acme.sh
#or here... https://github.com/Neilpang/acme.sh/issues/2305
#
########  Public functions #####################

# Export FreeDNS userid and password in following variables...
#  FREEDNS_User=username
#  FREEDNS_Password=password
# login cookie is saved in acme account config file so userid / pw
# need to be set only when changed.

#Usage: dns_freedns_add   _acme-challenge.www.domain.com   "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs"
dns_freedns_add() {
  fulldomain="_acme-challenge.$1"
  txtvalue="$2"
  FREEDNS_COOKIE="$(cat $(dirname "$(readlink -f "$0")")/freednscookie.dat)"

  echo "Info: Add TXT record using FreeDNS"
  #echo "Debug: fulldomain: $fulldomain"
  #echo "Debug: txtvalue: $txtvalue"

  if [ -z "$FREEDNS_User" ] || [ -z "$FREEDNS_Password" ]; then
    FREEDNS_User=""
    FREEDNS_Password=""
    if [ -z "$FREEDNS_COOKIE" ]; then
      echo "ERROR: You did not specify the FreeDNS username and password yet."
      echo "ERROR: Please export as FREEDNS_User / FREEDNS_Password and try again."
      return 1
    fi
    using_cached_cookies="true"
  else
    FREEDNS_COOKIE="$(_freedns_login "$FREEDNS_User" "$FREEDNS_Password")"
    if [ -z "$FREEDNS_COOKIE" ]; then
      return 1
    fi
    using_cached_cookies="false"
  fi

  #echo "Debug: FreeDNS login cookies: $FREEDNS_COOKIE (cached = $using_cached_cookies)"

  echo "$FREEDNS_COOKIE">$(dirname "$(readlink -f "$0")")/freednscookie.dat

  # We may have to cycle through the domain name to find the
  # TLD that we own...
  i=1
  wmax="$(echo "$fulldomain" | tr '.' ' ' | wc -w)"
  while [ "$i" -lt "$wmax" ]; do
    # split our full domain name into two parts...
    sub_domain="$(echo "$fulldomain" | cut -d. -f -"$i")"
    i="$(_math "$i" + 1)"
    top_domain="$(echo "$fulldomain" | cut -d. -f "$i"-100)"
    #echo "Debug: sub_domain: $sub_domain"
    #echo "Debug: top_domain: $top_domain"

    DNSdomainid="$(_freedns_domain_id "$top_domain")"
    if [ "$?" = "0" ]; then
      echo "Info:Domain $top_domain found at FreeDNS, domain_id $DNSdomainid"
      break
    else
      echo "Info:Domain $top_domain not found at FreeDNS, try with next level of TLD"
    fi
  done

  if [ -z "$DNSdomainid" ]; then
    # If domain ID is empty then something went wrong (top level
    # domain not found at FreeDNS).
    echo "ERROR: Domain $top_domain not found at FreeDNS"
    return 1
  fi

  # Add in new TXT record with the value provided
  #echo "Debug: Adding TXT record for $fulldomain, $txtvalue"
  _freedns_add_txt_record "$FREEDNS_COOKIE" "$DNSdomainid" "$sub_domain" "$txtvalue"
  return $?
}

#Usage: fulldomain txtvalue
#Remove the txt record after validation.
dns_freedns_rm() {
  fulldomain="_acme-challenge.$1"
  txtvalue="$2"

  echo "Info:Delete TXT record using FreeDNS"
  #echo "Debug: fulldomain: $fulldomain"
  #echo "Debug: txtvalue: $txtvalue"

  # Need to read cookie from conf file again in case new value set
  # during login to FreeDNS when TXT record was created.
  FREEDNS_COOKIE="$(cat $(dirname "$(readlink -f "$0")")/freednscookie.dat)"
  #echo "Debug: FreeDNS login cookies: $FREEDNS_COOKIE"

  TXTdataid="$(_freedns_data_id "$fulldomain" "TXT")"
  if [ "$?" != "0" ]; then
    echo "Info:Cannot delete TXT record for $fulldomain, record does not exist at FreeDNS"
    return 1
  fi
  #echo "Debug: Data ID's found, $TXTdataid"

  # now we have one (or more) TXT record data ID's. Load the page
  # for that record and search for the record txt value.  If match
  # then we can delete it.
  lines="$(echo "$TXTdataid" | wc -l)"
  #echo "Debug: Found $lines TXT data records for $fulldomain"
  i=0
  while [ "$i" -lt "$lines" ]; do
    i="$(_math "$i" + 1)"
    dataid="$(echo "$TXTdataid" | sed -n "${i}p")"
    #echo "Debug: $dataid"

    htmlpage="$(_freedns_retrieve_data_page "$FREEDNS_COOKIE" "$dataid")"
    if [ "$?" != "0" ]; then
      if [ "$using_cached_cookies" = "true" ]; then
        echo "ERROR: Has your FreeDNS username and password changed?  If so..."
        echo "ERROR: Please export as FREEDNS_User / FREEDNS_Password and try again."
      fi
      return 1
    fi

    echo "$htmlpage" | grep "value=\"&quot;$txtvalue&quot;\"" >/dev/null
    if [ "$?" = "0" ]; then
      # Found a match... delete the record and return
      echo "Info:Deleting TXT record for $fulldomain, $txtvalue"
      _freedns_delete_txt_record "$FREEDNS_COOKIE" "$dataid"
      return $?
    fi
  done

  # If we get this far we did not find a match
  # Not necessarily an error, but log anyway.
  echo "Info:Cannot delete TXT record for $fulldomain, $txtvalue. Does not exist at FreeDNS"
  return 0
}

####################  Private functions below ##################################

# usage: _freedns_login username password
# print string "cookie=value" etc.
# returns 0 success
_freedns_login() {
  export _H1="Accept-Language:en-US"
  username="$1"
  password="$2"
  url="https://freedns.afraid.org/zc.php?step=2"

  #echo "Debug: Login to FreeDNS as user $username"
  data="username=$(printf '%s' "$username" | _url_encode)&password=$(printf '%s' "$password" | _url_encode)&submit=Login&action=auth"
  #echo "$data"

  if [ -z "$HTTP_HEADER" ] || ! touch "$HTTP_HEADER"; then
    HTTP_HEADER="$(_mktemp)"
  fi
  htmlpage="$(curl -L --silent --dump-header $HTTP_HEADER -X POST -H "$_H1" -H "$_H2"  --data "$data" "$url")"

  if [ "$?" != "0" ]; then
    echo "ERROR: FreeDNS login failed for user $username bad RC from _post"
    return 1
  fi

  cookies="$(grep -i '^Set-Cookie.*dns_cookie.*$' "$HTTP_HEADER" | _head_n 1 | tr -d "\r\n" | cut -d " " -f 2)"

  # if cookies is not empty then logon successful
  if [ -z "$cookies" ]; then
    #echo "Debug3: htmlpage: $htmlpage"
    echo "ERROR: FreeDNS login failed for user $username. Check $HTTP_HEADER file"
    return 1
  fi

  printf "%s" "$cookies"
  return 0
}

# usage _freedns_retrieve_subdomain_page login_cookies
# echo page retrieved (html)
# returns 0 success
_freedns_retrieve_subdomain_page() {
  export _H1="Cookie:$1"
  export _H2="Accept-Language:en-US"
  url="https://freedns.afraid.org/subdomain/"

  #echo "Debug: Retrieve subdomain page from FreeDNS"

  htmlpage="$(curl -L --silent -H "$_H1" -H "$_H2" "$url")"

  if [ "$?" != "0" ]; then
    echo "ERROR: FreeDNS retrieve subdomains failed bad RC from _get"
    return 1
  elif [ -z "$htmlpage" ]; then
    echo "ERROR: FreeDNS returned empty subdomain page"
    return 1
  fi

  #echo "Debug3: htmlpage: $htmlpage"

  printf "%s" "$htmlpage"
  return 0
}

# usage _freedns_retrieve_data_page login_cookies data_id
# echo page retrieved (html)
# returns 0 success
_freedns_retrieve_data_page() {
  export _H1="Cookie:$1"
  export _H2="Accept-Language:en-US"
  data_id="$2"
  url="https://freedns.afraid.org/subdomain/edit.php?data_id=$2"

  #echo "Debug: Retrieve data page for ID $data_id from FreeDNS"

  htmlpage="$(curl -L --silent -H "$_H1" -H "$_H2" "$url")"

  if [ "$?" != "0" ]; then
    echo "ERROR: FreeDNS retrieve data page failed bad RC from _get"
    return 1
  elif [ -z "$htmlpage" ]; then
    echo "ERROR: FreeDNS returned empty data page"
    return 1
  fi

  #echo "Debug3: htmlpage: $htmlpage"

  printf "%s" "$htmlpage"
  return 0
}

# usage _freedns_add_txt_record login_cookies domain_id subdomain value
# returns 0 success
_freedns_add_txt_record() {
  export _H1="Cookie:$1"
  export _H2="Accept-Language:en-US"
  domain_id="$2"
  subdomain="$3"
  value="$(printf '%s' "$4" | _url_encode)"
  url="https://freedns.afraid.org/subdomain/save.php?step=2"

  if [ -z "$HTTP_HEADER" ] || ! touch "$HTTP_HEADER"; then
    HTTP_HEADER="$(_mktemp)"
  fi
  htmlpage="$(curl -L --silent --dump-header $HTTP_HEADER -X POST -H "$_H1" -H "$_H2"  --data "type=TXT&domain_id=$domain_id&subdomain=$subdomain&address=%22$value%22&send=Save%21" "$url")"

  if [ "$?" != "0" ]; then
    echo "ERROR: FreeDNS failed to add TXT record for $subdomain bad RC from _post"
    return 1
  elif ! grep "200 OK" "$HTTP_HEADER" >/dev/null; then
    #echo "Debug3: htmlpage: $(cat $HTTP_HEADER)"
    echo "ERROR: FreeDNS failed to add TXT record for $subdomain. Check $HTTP_HEADER file"
    return 1
  elif _contains "$htmlpage" "security code was incorrect"; then
    #echo "Debug3: htmlpage: $htmlpage"
    echo "ERROR: FreeDNS failed to add TXT record for $subdomain as FreeDNS requested security code"
    echo "ERROR: Note that you cannot use automatic DNS validation for FreeDNS public domains"
    return 1
  fi

  #echo "Debug3: htmlpage: $htmlpage"
  echo "Info:Added acme challenge TXT record for $fulldomain at FreeDNS"
  return 0
}

# usage _freedns_delete_txt_record login_cookies data_id
# returns 0 success
_freedns_delete_txt_record() {
  export _H1="Cookie:$1"
  export _H2="Accept-Language:en-US"
  data_id="$2"
  url="https://freedns.afraid.org/subdomain/delete2.php"

  htmlheader="$(curl -L --silent -I -H "$_H1" -H "$_H2" "$url?data_id%5B%5D=$data_id&submit=delete+selected")"

  if [ "$?" != "0" ]; then
    echo "ERROR: FreeDNS failed to delete TXT record for $data_id bad RC from _get"
    return 1
  elif ! _contains "$htmlheader" "200 OK"; then
    #echo "Debug2: htmlheader: $htmlheader"
    echo "ERROR: FreeDNS failed to delete TXT record $data_id"
    return 1
  fi

  echo "Info:Deleted acme challenge TXT record for $fulldomain at FreeDNS"
  return 0
}

# usage _freedns_domain_id domain_name
# echo the domain_id if found
# return 0 success
_freedns_domain_id() {
  # Start by escaping the dots in the domain name
  search_domain="$(echo "$1" | sed 's/\./\\./g')"

  # Sometimes FreeDNS does not return the subdomain page but rather
  # returns a page regarding becoming a premium member.  This usually
  # happens after a period of inactivity.  Immediately trying again
  # returns the correct subdomain page.  So, we will try twice to
  # load the page and obtain our domain ID
  attempts=2
  while [ "$attempts" -gt "0" ]; do
    attempts="$(_math "$attempts" - 1)"

    htmlpage="$(_freedns_retrieve_subdomain_page "$FREEDNS_COOKIE")"
    if [ "$?" != "0" ]; then
      if [ "$using_cached_cookies" = "true" ]; then
        echo "ERROR: Has your FreeDNS username and password changed?  If so..."
        echo "ERROR: Please export as FREEDNS_User / FREEDNS_Password and try again."
      fi
      return 1
    fi

    domain_id="$(echo "$htmlpage" | tr -d " \t\r\n\v\f" | sed 's/<tr>/@<tr>/g' | tr '@' '\n' \
      | grep "<td>$search_domain</td>\|<td>$search_domain(.*)</td>" \
      | sed -n 's/.*\(edit\.php?edit_domain_id=[0-9a-zA-Z]*\).*/\1/p' \
      | cut -d = -f 2)"
    # The above beauty extracts domain ID from the html page...
    # strip out all blank space and new lines. Then insert newlines
    # before each table row <tr>
    # search for the domain within each row (which may or may not have
    # a text string in brackets (.*) after it.
    # And finally extract the domain ID.
    if [ -n "$domain_id" ]; then
      printf "%s" "$domain_id"
      return 0
    fi
    #echo "Debug:Domain $search_domain not found. Retry loading subdomain page ($attempts attempts remaining)"
  done
  #echo "Debug:Domain $search_domain not found after retry"
  return 1
}

# usage _freedns_data_id domain_name record_type
# echo the data_id(s) if found
# return 0 success
_freedns_data_id() {
  # Start by escaping the dots in the domain name
  search_domain="$(echo "$1" | sed 's/\./\\./g')"
  record_type="$2"

  # Sometimes FreeDNS does not return the subdomain page but rather
  # returns a page regarding becoming a premium member.  This usually
  # happens after a period of inactivity.  Immediately trying again
  # returns the correct subdomain page.  So, we will try twice to
  # load the page and obtain our domain ID
  attempts=2
  while [ "$attempts" -gt "0" ]; do
    attempts="$(_math "$attempts" - 1)"

    htmlpage="$(_freedns_retrieve_subdomain_page "$FREEDNS_COOKIE")"
    if [ "$?" != "0" ]; then
      if [ "$using_cached_cookies" = "true" ]; then
        echo "ERROR: Has your FreeDNS username and password changed?  If so..."
        echo "ERROR: Please export as FREEDNS_User / FREEDNS_Password and try again."
      fi
      return 1
    fi

    data_id="$(echo "$htmlpage" | tr -d " \t\r\n\v\f" | sed 's/<tr>/@<tr>/g' | tr '@' '\n' \
      | grep "<td[a-zA-Z=#]*>$record_type</td>" \
      | grep "<ahref.*>$search_domain</a>" \
      | sed -n 's/.*\(edit\.php?data_id=[0-9a-zA-Z]*\).*/\1/p' \
      | cut -d = -f 2)"
    # The above beauty extracts data ID from the html page...
    # strip out all blank space and new lines. Then insert newlines
    # before each table row <tr>
    # search for the record type withing each row (e.g. TXT)
    # search for the domain within each row (which is within a <a..>
    # </a> anchor. And finally extract the domain ID.
    if [ -n "$data_id" ]; then
      printf "%s" "$data_id"
      return 0
    fi
    #echo "Debug:Domain $search_domain not found. Retry loading subdomain page ($attempts attempts remaining)"
  done
  #echo "Debug:Domain $search_domain not found after retry"
  return 1
}

#### BEGIN things shamefully ripped from https://github.com/Neilpang/acme.sh/blob/master/acme.sh

#_ascii_hex str
#this can only process ascii chars, should only be used when od command is missing as a backup way.
_ascii_hex() {
  _debug2 "Using _ascii_hex"
  _str="$1"
  _str_len=${#_str}
  _h_i=1
  while [ "$_h_i" -le "$_str_len" ]; do
    _str_c="$(printf "%s" "$_str" | cut -c "$_h_i")"
    printf " %02x" "'$_str_c"
    _h_i="$(_math "$_h_i" + 1)"
  done
}

#stdin  output hexstr splited by one space
#input:"abc"
#output: " 61 62 63"
_hex_dump() {
  if _exists od; then
    od -A n -v -t x1 | tr -s " " | sed 's/ $//' | tr -d "\r\t\n"
  elif _exists hexdump; then
    hexdump -v -e '/1 ""' -e '/1 " %02x" ""'
  elif _exists xxd; then
    xxd -ps -c 20 -i | sed "s/ 0x/ /g" | tr -d ",\n" | tr -s " "
  else
    str=$(cat)
    _ascii_hex "$str"
  fi
}

#url encode, no-preserved chars
#A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z
#41 42 43 44 45 46 47 48 49 4a 4b 4c 4d 4e 4f 50 51 52 53 54 55 56 57 58 59 5a

#a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z
#61 62 63 64 65 66 67 68 69 6a 6b 6c 6d 6e 6f 70 71 72 73 74 75 76 77 78 79 7a

#0  1  2  3  4  5  6  7  8  9  -  _  .  ~
#30 31 32 33 34 35 36 37 38 39 2d 5f 2e 7e

#stdin stdout
_url_encode() {
  _hex_str=$(_hex_dump)
  for _hex_code in $_hex_str; do
    #upper case
    case "${_hex_code}" in
      "41")
        printf "%s" "A"
        ;;
      "42")
        printf "%s" "B"
        ;;
      "43")
        printf "%s" "C"
        ;;
      "44")
        printf "%s" "D"
        ;;
      "45")
        printf "%s" "E"
        ;;
      "46")
        printf "%s" "F"
        ;;
      "47")
        printf "%s" "G"
        ;;
      "48")
        printf "%s" "H"
        ;;
      "49")
        printf "%s" "I"
        ;;
      "4a")
        printf "%s" "J"
        ;;
      "4b")
        printf "%s" "K"
        ;;
      "4c")
        printf "%s" "L"
        ;;
      "4d")
        printf "%s" "M"
        ;;
      "4e")
        printf "%s" "N"
        ;;
      "4f")
        printf "%s" "O"
        ;;
      "50")
        printf "%s" "P"
        ;;
      "51")
        printf "%s" "Q"
        ;;
      "52")
        printf "%s" "R"
        ;;
      "53")
        printf "%s" "S"
        ;;
      "54")
        printf "%s" "T"
        ;;
      "55")
        printf "%s" "U"
        ;;
      "56")
        printf "%s" "V"
        ;;
      "57")
        printf "%s" "W"
        ;;
      "58")
        printf "%s" "X"
        ;;
      "59")
        printf "%s" "Y"
        ;;
      "5a")
        printf "%s" "Z"
        ;;

      #lower case
      "61")
        printf "%s" "a"
        ;;
      "62")
        printf "%s" "b"
        ;;
      "63")
        printf "%s" "c"
        ;;
      "64")
        printf "%s" "d"
        ;;
      "65")
        printf "%s" "e"
        ;;
      "66")
        printf "%s" "f"
        ;;
      "67")
        printf "%s" "g"
        ;;
      "68")
        printf "%s" "h"
        ;;
      "69")
        printf "%s" "i"
        ;;
      "6a")
        printf "%s" "j"
        ;;
      "6b")
        printf "%s" "k"
        ;;
      "6c")
        printf "%s" "l"
        ;;
      "6d")
        printf "%s" "m"
        ;;
      "6e")
        printf "%s" "n"
        ;;
      "6f")
        printf "%s" "o"
        ;;
      "70")
        printf "%s" "p"
        ;;
      "71")
        printf "%s" "q"
        ;;
      "72")
        printf "%s" "r"
        ;;
      "73")
        printf "%s" "s"
        ;;
      "74")
        printf "%s" "t"
        ;;
      "75")
        printf "%s" "u"
        ;;
      "76")
        printf "%s" "v"
        ;;
      "77")
        printf "%s" "w"
        ;;
      "78")
        printf "%s" "x"
        ;;
      "79")
        printf "%s" "y"
        ;;
      "7a")
        printf "%s" "z"
        ;;
      #numbers
      "30")
        printf "%s" "0"
        ;;
      "31")
        printf "%s" "1"
        ;;
      "32")
        printf "%s" "2"
        ;;
      "33")
        printf "%s" "3"
        ;;
      "34")
        printf "%s" "4"
        ;;
      "35")
        printf "%s" "5"
        ;;
      "36")
        printf "%s" "6"
        ;;
      "37")
        printf "%s" "7"
        ;;
      "38")
        printf "%s" "8"
        ;;
      "39")
        printf "%s" "9"
        ;;
      "2d")
        printf "%s" "-"
        ;;
      "5f")
        printf "%s" "_"
        ;;
      "2e")
        printf "%s" "."
        ;;
      "7e")
        printf "%s" "~"
        ;;
      #other hex
      *)
        printf '%%%s' "$_hex_code"
        ;;
    esac
  done
}

_exists() {
  cmd="$1"
  if [ -z "$cmd" ]; then
    _usage "Usage: _exists cmd"
    return 1
  fi

  if eval type type >/dev/null 2>&1; then
    eval type "$cmd" >/dev/null 2>&1
  elif command >/dev/null 2>&1; then
    command -v "$cmd" >/dev/null 2>&1
  else
    which "$cmd" >/dev/null 2>&1
  fi
  ret="$?"
  #echo "Debug3: $cmd exists=$ret"
  return $ret
}

_head_n() {
  head -n "$1"
}

_mktemp() {
  if _exists mktemp; then
    if mktemp 2>/dev/null; then
      return 0
    elif _contains "$(mktemp 2>&1)" "-t prefix" && mktemp -t "$PROJECT_NAME" 2>/dev/null; then
      #for Mac osx
      return 0
    fi
  fi
  if [ -d "/tmp" ]; then
    echo "/tmp/${PROJECT_NAME}wefADf24sf.$(_time).tmp"
    return 0
  elif [ "$LE_TEMP_DIR" ] && mkdir -p "$LE_TEMP_DIR"; then
    echo "/$LE_TEMP_DIR/wefADf24sf.$(_time).tmp"
    return 0
  fi
  _err "Can not create temp file."
}

#a + b
_math() {
  _m_opts="$@"
  printf "%s" "$(($_m_opts))"
}

_contains() {
  _str="$1"
  _sub="$2"
  echo "$_str" | grep -- "$_sub" >/dev/null 2>&1
}

##Now actually do something with that function
case "$1" in

  add)
    dns_freedns_add $2 $3
    ;;
  rm)
    dns_freedns_rm $2  $3
    ;;
esac
