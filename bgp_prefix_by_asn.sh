#!/bin/bash

ASN=$1
whois -h whois.registro.br AS$ASN | awk 'match($0,/(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))/) {print substr($0,RSTART,RLENGTH)}' > /tmp/bgp_$ASN
echo "ASN: $ASN"
cat  /tmp/bgp_$ASN | while read LINE
do
  PREFIX=`echo $LINE | cut -d'/' -f 1`
  MASK=`echo $LINE | cut -d'/' -f 2`
  echo "Prefix: $LINE (Netowrk: $PREFIX, Mask: $MASK)"
  echo "LG SEABONE - AS-PATH"
  curl -s -k 'https://gambadilegno.noc.seabone.net/lg/lg.cgi' \
  -XPOST \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Referer: https://gambadilegno.noc.seabone.net/lg/' \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
  -H 'Origin: https://gambadilegno.noc.seabone.net' \
  --data "query=bgp&addr=${PREFIX}&router=RioDeJaneiro" \
  -o /tmp/seabone-$PREFIX.html

  cat /tmp/seabone-$PREFIX.html | eval "awk 'match(\$0,/[0-9 ]+ "$ASN"/) {print substr(\$0,RSTART,RLENGTH)}'" | uniq

  echo ""

  echo "LG LEVEL3 - AS-PATH"
  curl -s 'http://lg.level3.net/bgp/lg_bgp_output.php' \
  -XPOST -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Referer: http://lg.level3.net/bgp/lg_bgp_output.php' \
  -H 'Upgrade-Insecure-Requests: 1' \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
  -H 'Origin: http://lg.level3.net' --data "sitename=ear1.ams1&address=$PREFIX&length=$MASK&longer=longertrue" \
  -o /tmp/level3-$PREFIX.html

   cat /tmp/level3-$PREFIX.html | eval "awk 'match(\$0,/[0-9 ]+ "$ASN"/) {print substr(\$0,RSTART,RLENGTH)}'" | uniq
  echo ""
  echo ""

done
