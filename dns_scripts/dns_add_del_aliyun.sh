#!/bin/bash
#https://blog.aymar.cn
#https://protocol.aymar.cn
PROGNAME=${0##*/}
VERSION="2021年3月22日 16:07:05"
Ali_API="https://dns.aliyuncs.com/"
_timestamp=$(date -u  +"%Y-%m-%dT%H%%3A%M%%3A%SZ")
__debug="0"
__delete="0"

#Wildcard certificates
#A partial example getssl.cfg file is:
#VALIDATE_VIA_DNS=true
#DNS_ADD_COMMAND=/root/.getssl/dns_add_del_aliyun.sh
#DNS_DEL_COMMAND=/root/.getssl/dns_add_del_aliyun.sh

# either configure KeyId & KeySecret here or export environment variables in getssl.cfg
AccessKeyId=${ALI_KeyId:-''}
AccessKeySecret=${ALI_KeySecret:-''}

usage() { # print out the program usage
  echo "Usage: $PROGNAME  [-a|--add <Domain Name> <RecordValue>]  [-d|--delete <Full.DomainName.com>] [-s|--search <Full.DomainName.com> ]  [-h|--help]  [-t|--type]  "\
  "[-q|--quiet] [-c|--check] [-S|--status] [-l|--lock #] [-T|--ttl] [-u|--update] [-w|--weight] [-L|--Line]"
}

help_message() { # print out the help message
  cat <<- _EOF_
	$PROGNAME Version. $VERSION
	$(usage)

	Options:
	  -a, --add          Add Domain Record    域名 ip (默认类型TXT）
	  -d, --delete       Delete Domain Record 域名    (默认类型TXT）
	  -s, --search       Search Domain Record 域名
	  -t, --type         Record Type          类型（A、MX、CNAME、TXT、REDIRECT_URL、FORWORD_URL、NS、AAAA、SRV）
	_EOF_
}

_arg_check(){
  [ -z "$1" ] || _arg_count=$1
  shift
  [ ${#} -lt $_arg_count ] && help_message && exit 1 || (echo $2 | grep "^-") && help_message && exit 1
  #If the number of arguments <$_ARG_COUNT print help and exit, and if the second argument begins with “-” print help and exit
  return 0
}

#[ ${#} -lt 2 ] && help_message && exit 1     #Same as below
#[ -z "$2" ] && help_message && exit 1        #Same as below
_arg_check 2  $@

_debug (){
  if [ "$__debug" -eq 1 ]; then
    echo -e "\033[1;31m # debug: $(date "+%m %d %T") | Func: ${FUNCNAME[@]} | Line:${BASH_LINENO[@]} \033[0m"  "\n $@ "  #"Current FUNCNAME ${FUNCNAME}  #$LINENO "  #"$(($RANDOM%10))"
  fi
  return 0
}

_requires() {
  _cmds=''                                # Check if the commands exists
  if [[ "$#" -gt 0 ]]; then
    for i in "$@"; do
      if eval type type >/dev/null 2>&1; then
        eval type "$i" >/dev/null 2>&1
      elif command >/dev/null 2>&1; then
        command -v "$i" >/dev/null 2>&1
      else
        which "$i" >/dev/null 2>&1
      fi
      #[ "$?" -eq 0  ] &&   _debug "checking for $i exists = ok" || _cmds=$_cmds"$i: "
      #shellcheck disable=SC2181
      if [ "$?" -eq 0  ]; then
        #_debug "checking for $i exists = ok"
        continue
      else
        _cmds=$_cmds"$i: "
      fi
    done
  else
    echo  "Usage: _requires [command] "
    return 1
  fi
  [ -n "$_cmds" ] && { echo -e "\033[1;31m $_cmds command not found \033[0m" && return 1 ;} || return 0
}

_requires openssl

#shellcheck disable=SC2120
_hex_dump() {  #ascii hex
  local _str=''
  [ $# -gt 0 ] &&  _str=$@ || read _str
  local _str_len=${#_str}
  local i=1
  while [ "$i" -le "$_str_len" ]; do
    local _str_c="$(printf "%s" "$_str" | cut -c "$i")"
    printf " %02x" "'$_str_c"
    i=$(($i + 1))
  done
  #printf "%s" " 0a"
}

_urlencode() {
  local length="${#1}"
  local i=''
    for i in $(awk "BEGIN { for ( i=0; i<$length; i++ ) print i }")
    do
      #local _strc="$(printf "%s" "$1" | cut -c "$i")" #i=1; i<=$length; i++
      local _strc="${1:$i:1}"
      case $_strc in [a-zA-Z0-9.~_-]) printf "%s" "$_strc" ;; *) printf "%%%02X" "'$_strc" ;;
      esac
  done
}

_signature(){
  signature=''
  _hexkey=$(printf "%s" "$AccessKeySecret&" | _hex_dump |sed 's/ //g')
  #signature=$(printf "%s" "GET&%2F&$(_urlencode "$query")" | openssl dgst -sha1 -hmac $(printf "%s" "$AccessKeySecret&" | _hex_dump |sed 's/ //g'| xxd -r -p ) -binary | openssl base64 -e)
  signature=$(printf "%s" "GET&%2F&$(_urlencode "$query")" | openssl dgst -sha1 -mac HMAC -macopt "hexkey:$_hexkey" -binary | openssl base64 -e)
  signature=$(_urlencode "$signature")
}

_query() {
  [ -n "$__type" ] && { [[ "$_Action" = "AddDomainRecord" ]] && _Type="$__type" || { [ "$_Action" = "DescribeDomainRecords" ] && _TypeKeyWord="$__type"; } ; }
  query=''
  [ -n $AccessKeyId ]   && query=$query'AccessKeyId='$AccessKeyId
                           query=$query'&Action='"$1"
  [ -z $_DomainNames ]  || query=$query'&DomainName='$_DomainNames
                           query=$query'&Format=json'
  [ -z $_RR ]           || query=$query'&RR='$_RR
  [ -z $_RRKeyWord ]    || query=$query'&RRKeyWord='$_RRKeyWord
  [ -z $_RecordId ]     || query=$query'&RecordId='$_RecordId
                           query=$query'&SignatureMethod=HMAC-SHA1'
                           query=$query"&SignatureNonce=$(date +"%s%N")"
                           query=$query'&SignatureVersion=1.0'
                           query=$query'&Timestamp='$_timestamp
  [ -z $_Type ]         || query=$query'&Type='$_Type
  [ -z $_TypeKeyWord ]  || query=$query'&TypeKeyWord='$_TypeKeyWord
  [ -z $_Value ]        || query=$query'&Value='$_Value
  [ -z $_ValueKeyWord ] || query=$query'&ValueKeyWord='$_ValueKeyWord
                           query=$query'&Version=2015-01-09'
  #_debug "$query"
  _signature
  return 0
}

_Get_RecordIds(){
  _Action="DescribeDomainRecords"
  _query $_Action $_DomainNames
  url="${Ali_API}?${query}&Signature=${signature}"
  _debug $url
  _RecordIds=$(curl -k -s $url | grep -Po  'RecordId[": "]+\K[^"]+') &&  __delete="1"            #RecordId requisite
  _debug  $_RecordIds
  return 0
}

__type='TXT'
_DomainNames=$(printf "%s" $1| awk -F"." '{if(NF>=2){print $(NF-1)"."$NF}}')  #awk -F\. '{print $(NF-1) FS $NF}')     #requisite
_RRKeyWord="_acme-challenge"

_Get_RecordIds

_RRKeyWord=''
_TypeKeyWord=''
_ValueKeyWord=''

if [ "$__delete" = "1" ];then
  _Action="DeleteDomainRecord"                                      #Action requisite
  _DomainNames=''
  for _RecordId in ${_RecordIds[@]}                                 #Delete multiple txt domain record
  do
    _debug "_RecordId" $_RecordId
    _query  $_Action $_RecordId
    url="${Ali_API}?${query}&Signature=${signature}"
    _debug $url
    curl -k -s $url && ( echo -e "\n\033[1;32m Aliyun DNS record _acme-challenge.$1 has been deleted  \033[0m")
  done
else
  _Action="AddDomainRecord"                                 #requisite
  _RR=$(printf "_acme-challenge.%s" $1| awk -F'.' '{if(NF>2){gsub("."$(NF-1)"."$NF,"");print}}')            #requisite
  _Value=$2                                                 #requisite
  _query  $_Action $_DomainNames
  url="${Ali_API}?${query}&Signature=${signature}"
  _debug $url
  curl -k -s $url  &&   (echo -e "\n\033[1;32m Start Checking aliyun DNS record _acme-challenge.$1 \033[0m")
  exit 0
fi
