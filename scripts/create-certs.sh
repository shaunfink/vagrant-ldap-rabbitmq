
#!/bin/bash
# Script to generate a local CA and aerver & client certificates signed by that CA.
set -e
set -x

# Set the current path
dir=$( pwd )
hostname="rabbitmq.dev"
ou="rabbitmq"
o="dev"
caname="TestCA"

# Create directory structure
mkdir -p ${dir}/ca-certs/${caname}/{certs,private}

# Configure the ${caname} directory
chmod 700 ${dir}/ca-certs/${caname}/private
echo 01 > ${dir}/ca-certs/${caname}/serial
touch ${dir}/ca-certs/${caname}/index.txt

# Create openssl.cnf
cat > ${dir}/ca-certs/${caname}/openssl.cnf << EOF
[ ca ]
default_ca = ${caname}

[ ${caname} ]
dir = ${dir}/ca-certs/${caname}
certificate = ${dir}/ca-certs/${caname}/cacert.pem
database = ${dir}/ca-certs/${caname}/index.txt
new_certs_dir = ${dir}/ca-certs/${caname}/certs
private_key = ${dir}/ca-certs/${caname}/private/cakey.pem
serial = ${dir}/ca-certs/${caname}/serial

default_crl_days = 7
default_days = 365
default_md = sha256

policy = ${caname}_policy
x509_extensions = certificate_extensions

[ ${caname}_policy ]
commonName = supplied
stateOrProvinceName = optional
countryName = optional
emailAddress = optional
organizationName = optional
organizationalUnitName = optional
domainComponent = optional

[ certificate_extensions ]
basicConstraints = CA:false

[ req ]
default_bits = 2048
default_keyfile = ${dir}/ca-certs/${caname}/private/cakey.pem
default_md = sha256
prompt = yes
distinguished_name = root_ca_distinguished_name
x509_extensions = root_ca_extensions

[ root_ca_distinguished_name ]
commonName = hostname

[ root_ca_extensions ]
basicConstraints = CA:true
keyUsage = keyCertSign, cRLSign

[ client_ca_extensions ]
basicConstraints = CA:false
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment, keyAgreement
extendedKeyUsage = 1.3.6.1.5.5.7.3.1, 1.3.6.1.5.5.7.3.2

[ server_ca_extensions ]
basicConstraints = CA:false
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment, keyAgreement
extendedKeyUsage = 1.3.6.1.5.5.7.3.1, 1.3.6.1.5.5.7.3.2
EOF

# Generate ca certs
openssl req -x509 -config ${dir}/ca-certs/${caname}/openssl.cnf -newkey rsa:2048 -days 365 -out ${dir}/ca-certs/${caname}/cacert.pem -outform PEM -subj /CN=${caname}/ -nodes
openssl x509 -in ${dir}/ca-certs/${caname}/cacert.pem -out ${dir}/ca-certs/${caname}/cacert.cer -outform DER

# Function for creating certs
createcert() {
  mkdir -p ${dir}/ca-certs/$1
  openssl genrsa -out ${dir}/ca-certs/$1/key.pem 2048
  openssl req -new -key ${dir}/ca-certs/$1/key.pem -out ${dir}/ca-certs/$1/req.pem -outform PEM -subj /CN=$1/OU=${ou}/O=${o}/ -nodes
  openssl ca -config ${dir}/ca-certs/${caname}/openssl.cnf -in ${dir}/ca-certs/$1/req.pem -out ${dir}/ca-certs/$1/cert.pem -notext -batch -extensions server_ca_extensions
  openssl pkcs12 -export -out ${dir}/ca-certs/$1/keycert.p12 -in ${dir}/ca-certs/$1/cert.pem -inkey ${dir}/ca-certs/$1/key.pem -passout pass:MySecretPassword
  cp ${dir}/ca-certs/${caname}/cacert.pem ${dir}/ca-certs/$1/
}

createcert rabbitdevcode
createcert rabbitmq.dev

echo "Done!"
