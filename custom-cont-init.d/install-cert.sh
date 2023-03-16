#!/bin/bash

until [ -f /cert/mitmproxy-ca-cert.cer ]; do
    sleep 2
    echo "no cert yet"
done
if [ ! -f "/usr/share/ca-certificates/mitm/mitmproxy-ca.cer" ]; then
    mkdir -p /usr/share/ca-certificates/mitm
    cp /cert/mitmproxy-ca-cert.cer /usr/share/ca-certificates/mitm/mitmproxy-ca.cer
    chmod 644 /usr/share/ca-certificates/mitm/mitmproxy-ca.cer
    echo "mitm/mitmproxy-ca.cer" >>/etc/ca-certificates.conf
    update-ca-certificates

    javaversions="java-8-openjdk-amd64"

    for javaver in $javaversions; do
        if [ -f "/usr/lib/jvm/$javaver/jre/lib/security/cacerts" ]; then
            keytool -importcert -trustcacerts -keystore /usr/lib/jvm/$javaver/jre/lib/security/cacerts \
                -storepass changeit -noprompt -alias mmitm -file /cert/mitmproxy-ca-cert.pem
            echo "Added cert to $javaver keystore"
        fi
    done

    apt update
    apt install iptables net-tools iproute2 -y --no-install-recommends

    iptables -t nat -A OUTPUT -p tcp -m owner ! --uid-owner 0 --dport 443 -j REDIRECT --to-port 8080
    iptables -t nat -A OUTPUT -p tcp -m owner ! --uid-owner 0 --dport 80 -j REDIRECT --to-port 8080
fi

s6-setuidgid abc curl -I -s -w "%{http_code}\n" -o /dev/null -x http://localhost:8080 https://www.google.no
s6-setuidgid abc curl -I -s -w "%{http_code}\n" -o /dev/null https://www.vg.no
