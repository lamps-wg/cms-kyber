set -e
# set -x

# Needs CryptoNext's build for KEMRecipientInfo and cnsprovider.  Sorry!
PATH=/usr/local/cns_openssl3/bin/:$PATH

# Decapsulate ciphertext.txt
tr -d '\n' < ciphertext.txt | xxd -r -p > ciphertext.bin
openssl pkeyutl -decap -in ciphertext.bin -inkey ML-KEM-512-both.priv -secret shared_secret_decaps.bin
rm ciphertext.bin

# Ensure that the decapsulated shared secret matches shared_secret.txt
xxd -ps shared_secret_decaps.bin | tr -d '\n' > shared_secret_decaps_oneline.txt
cat shared_secret.txt | tr -d '\n' > shared_secret_oneline.txt
diff -i shared_secret_decaps_oneline.txt shared_secret_oneline.txt
SHARED_SECRET=$(cat shared_secret_oneline.txt)
rm shared_secret_decaps.bin shared_secret_decaps_oneline.txt shared_secret_oneline.txt

# Derive the KEK from the shared secret and ori_info.txt and ensure it matches kek.txt
KDF_INFO=$(cat ori_info.txt)
cat kek.txt | tr -d '\n' > kek_oneline.txt
openssl kdf -keylen 16 -kdfopt digest:SHA2-256 -kdfopt hexkey:$SHARED_SECRET -kdfopt hexinfo:$KDF_INFO -binary HKDF | xxd -ps | tr -d '\n' > kek_derived_oneline.txt
diff -i kek_derived_oneline.txt kek_oneline.txt
KEK=$(cat kek_oneline.txt)
rm kek_derived_oneline.txt kek_oneline.txt

# Decrypt the encryped CEK with the KEK and ensure it matches cek.txt
tr -d '\n' < encrypted_cek.txt | xxd -r -p > encrypted_cek.bin
cat cek.txt | tr -d '\n' > cek_oneline.txt
openssl enc -d -aes-128-wrap -K $KEK -iv A6A6A6A6A6A6A6A6 -in encrypted_cek.bin | xxd -ps | tr -d '\n' > cek_decrypted_oneline.txt
diff -i cek_decrypted_oneline.txt cek_oneline.txt
rm encrypted_cek.bin cek_decrypted_oneline.txt cek_oneline.txt

echo "*******************************************"
echo "Examples Validated!"
echo "*******************************************"
