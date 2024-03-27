#!/bin/bash
set -ex

clusters=$@

cert_dir=`dirname "$BASH_SOURCE"`/certs

echo "Clean up contents of dir ${cert_dir}"
rm -rf ${cert_dir}

echo "Generating new certificates"

mkdir -p ${cert_dir}

step certificate create root.istio.io ${cert_dir}/root-cert.pem ${cert_dir}/root-ca.key \
  --profile root-ca --no-password --insecure --san root.istio.io \
  --not-after 87600h --kty RSA

for cluster in ${clusters}; do
    mkdir -p ${cert_dir}/${cluster}
    step certificate create ${cluster}.intermediate.istio.io ${cert_dir}/${cluster}/ca-cert.pem ${cert_dir}/${cluster}/ca-key.pem --ca ${cert_dir}/root-cert.pem --ca-key ${cert_dir}/root-ca.key --profile intermediate-ca --not-after 87600h --no-password --insecure --san ${cluster}.intermediate.istio.io --kty RSA 
    cat ${cert_dir}/${cluster}/ca-cert.pem ${cert_dir}/root-cert.pem > ${cert_dir}/${cluster}/cert-chain.pem
done
