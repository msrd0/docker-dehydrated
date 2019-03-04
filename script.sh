#!/usr/bin/env bash
set -e

keyalgo="prime256v1"
country=""
state=""
location=""
organization=""

# load domains
source /etc/domains.sh

# function to generate a private key
function genprivkey()
{
  echo "Generating $keyalgo private key, storing to $1"
  openssl ecparam -genkey -name $keyalgo -out "$1"
}

# function to generate a csr
function gencsr()
{
  echo "Generating CSR $2 for $1, storing to $3"
  openssl req -new -key "$1" -subj "/C=$country/ST=$state/L=$location/O=$organization/CN=$2" -out "$3"
}

# function to sign a csr
function signcsr()
{
  echo "Signing CSR $1 through dehydrated, storing to $2"
  dehydrated -fc -s "$1" >"$2"
}

# function to generate a self-signed certificate for one day
function gencert()
{
  echo "Generating Certificate $2 for $1, storing to $3"
  openssl req -x509 -new -key "$1" -days 1 -subj "/C=$country/ST=$state/L=$location/O=$organization/CN=$2" -out "$3"
}

for domain in ${domains[@]}
do
  # generate self-signed certificate for nginx to start
  mkdir -p "/certs/$domain"
  genprivkey "/certs/$domain/privkey.pem"
  gencert "/certs/$domain/privkey.pem" "$domain" "/certs/$domain/fullchain.pem"
done

# sleep to make sure nginx is up and running
sleep 30s

# register
dehydrated --register --accept-terms

# endless loop, renewing certificates
while true
do

  for domain in ${domains[@]}
  do
    # obtain key from lets encrypt
    genprivkey "/certs/$domain/privkey.pem" \
    && gencsr "/certs/$domain/privkey.pem" "$domain" "/certs/$domain/request.csr" \
    && signcsr "/certs/$domain/request.csr" "/certs/$domain/fullchain.pem" \
    || echo "ERROR: could not obtain certificate for $domain"
  done

  # wait 1 month
  sleep 5040h

done
