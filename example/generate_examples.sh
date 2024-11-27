set -e
set -x

# Needs CryptoNext's build for KEMRecipientInfo and cnsprovider.  Sorry!
PATH=/usr/local/cns_openssl3/bin/:$PATH
EXT_FILE=$(dirname $(realpath $0))/openssl.cnf

openssl pkey -in ML-KEM-512.priv -pubout -out ML-KEM-512.pub

##########################################################
# Create mldsa65 root certificate
##########################################################

openssl genpkey -algorithm mldsa65 -out mldsa65RootCA.priv
openssl req -x509 -new -nodes -extensions v3_ca -key mldsa65RootCA.priv -days 3650 \
    -out mldsa65RootCA.pem -subj "/C=PT/ST=Bliss/CN=ML-DSA-65 Root Cert"

##########################################################
# Create mlkem512 EE certificate
##########################################################
openssl genrsa -out fake_rsakey.pem 1024
openssl req -new -key fake_rsakey.pem -out fake_rsa.csr \
    -subj "/C=PT/ST=Bliss/CN=ML-KEM-512"

# Create KEM certificate from the fake CSR by forcing the KEM key during the certificate creation.
openssl x509 -req -in fake_rsa.csr -extfile $EXT_FILE -extensions v3_ee_kem -CAkey mldsa65RootCA.priv \
    -CA mldsa65RootCA.pem -force_pubkey ML-KEM-512.pub \
    -outform PEM -out ML-KEM-512.pem -CAcreateserial
rm fake_rsa.csr
rm fake_rsakey.pem

openssl x509 -in ML-KEM-512.pem -noout -ext subjectKeyIdentifier | tail -n 1 | tr -d ' :' > ML-KEM-512.keyid

##########################################################
# Encrypt message
##########################################################
echo -n "Hello, world!" > plaintext.txt

openssl cms -encrypt -in plaintext.txt \
    -outform PEM -out ML-KEM-512.cms \
    -recip ML-KEM-512.pem \
    -aes-256-gcm \
    -keyid
openssl cms -cmsout -in ML-KEM-512.cms -inform PEM -out ML-KEM-512.cms.der -outform DER

openssl cms -cmsout -in ML-KEM-512.cms -inform PEM -outform DER -out ML-KEM-512.cms.der
dumpasn1 -a -i -w66 ML-KEM-512.cms.der > ML-KEM-512.cms.txt
rm ML-KEM-512.cms.der

openssl cms -decrypt -inform PEM -in ML-KEM-512.cms -recip ML-KEM-512.pem \
    -inkey ML-KEM-512.priv -out decrypted.txt

rm plaintext.txt
rm mldsa65RootCA.*
rm ML-KEM-512.pem