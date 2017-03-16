#!/bin/sh

eval `dbus export gdddns_`

if [ "$gdddns_enable" != "1" ]; then
    echo "not enable"
    exit
fi

now=`date`

die () {
    echo $1
    dbus ram gdddns_last_act="$now: failed($1)"
}

[ "$gdddns_curl" = "" ] && gdddns_curl="curl -s whatismyip.akamai.com"
[ "$gdddns_dns" = "" ] && gdddns_dns="NS05.DOMAINCONTROL.COM"
[ "$gdddns_ttl" = "" ] && gdddns_ttl="600"

ip=`$gdddns_curl 2>&1` || die "$ip"

current_ip=`nslookup $gdddns_name.$gdddns_domain $gdddns_dns 2>&1`

if [ "$?" -eq "0" ]
then
    current_ip=`echo "$current_ip" | grep 'Address 1' | tail -n1 | awk '{print $NF}'`

    if [ "$ip" = "$current_ip" ]
    then
        echo "skipping"
        dbus set gdddns_last_act="$now: skipped($ip)"
        exit 0
    fi 
fi


timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"`

urlencode() {
    # urlencode <string>
    out=""
    while read -n1 c
    do
        case $c in
            [a-zA-Z0-9._-]) out="$out$c" ;;
            *) out="$out`printf '%%%02X' "'$c"`" ;;
        esac
    done
    echo -n $out
}

enc() {
    echo -n "$1" | urlencode
}

send_request() {
    local args="AccessKeyId=$gdddns_ak&Action=$1&Format=json&$2&Version=2015-01-09"
    local hash=$(echo -n "GET&%2F&$(enc "$args")" | openssl dgst -sha1 -hmac "$gdddns_sk&" -binary | openssl base64)
    curl -s "http://alidns.aliyuncs.com/?$args&Signature=$(enc "$hash")"
}

get_recordid() {
    grep -Eo '"RecordId":"[0-9]+"' | cut -d':' -f2 | tr -d '"'
}

query_recordid() {

    send_request "DescribeSubDomainRecords" "SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&SubDomain=$gdddns_name.$gdddns_domain&Timestamp=$timestamp"
}

update_record() {
    curl -kLsX PUT -H "Authorization: sso-key $gdddns_ak:$gdddns_sk" \
        -H "Content-type: application/json" "https://api.godaddy.com/v1/domains/$gdddns_domain/records/${Type}/$gdddns_name" \
        -d "{\"data\":\"${PublicIP}\",\"ttl\":${TTL}}" 2>/dev/null)
    send_request "UpdateDomainRecord" "RR=$gdddns_name&RecordId=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&TTL=$gdddns_ttl&Timestamp=$timestamp&Type=A&Value=$ip"
}

add_record() {
    send_request "AddDomainRecord&DomainName=$gdddns_domain" "RR=$gdddns_name&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&TTL=$gdddns_ttl&Timestamp=$timestamp&Type=A&Value=$ip"
}

if [ "$gdddns_record_id" = "" ]
then
    gdddns_record_id=`query_recordid | get_recordid`
fi
if [ "$gdddns_record_id" = "" ]
then
    gdddns_record_id=`add_record | get_recordid`
    echo "added record $gdddns_record_id"
else
    update_record $gdddns_record_id
    echo "updated record $gdddns_record_id"
fi

# save to file
if [ "$gdddns_record_id" = "" ]; then
    # failed
    dbus ram gdddns_last_act="$now: failed"
else
    dbus ram gdddns_record_id=$gdddns_record_id
    dbus ram gdddns_last_act="$now: success($ip)"
fi