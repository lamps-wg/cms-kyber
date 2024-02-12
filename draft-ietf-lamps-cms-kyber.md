---
title: Use of KYBER in the Cryptographic Message Syntax (CMS)
abbrev: KYBER in CMS
# <!-- EDNOTE: Edits the draft name -->
docname: draft-ietf-lamps-cms-kyber-latest
date: 2023-11-05
# <!-- date: 2023-11 -->
# <!-- date: 2023 -->

# <!-- stand_alone: true -->
ipr: trust200902
area: Security
wg: LAMPS
kw: Internet-Draft
cat: std

coding: us-ascii
pi:    # can use array (if all yes) or hash here
  toc: yes
  sortrefs:   # defaults to yes
  symrefs: yes

author:
    -
      ins: J. Prat
      name: Julien Prat
      org: CryptoNext Security
      email: julien.prat@cryptonext-security.com
    -
      ins: M. Ounsworth
      name: Mike Ounsworth
      org: Entrust Limited
      email: mike.ounsworth@entrust.com


normative:
  RFC2119:
  RFC5280:
  RFC5652:
  RFC8619:
  RFC5869:
  RFC5649:
  RFC8174:
  RFC8551:
  X.690:
      title: "Information technology - ASN.1 encoding Rules: Specification of Basic Encoding Rules (BER), Canonical Encoding Rules (CER) and Distinguished Encoding Rules (DER)"
      date: 2007
      author:
        org: ASC
  SP-800-56C-r2:
      title: "Recommendation for Key-Derivation Methods in Key-Establishment Schemes"
      date: 2020
      author:
        org: NIST
  draft-ietf-lamps-cms-kemri:
      title: "Using Key Encapsulation Mechanism (KEM) Algorithms in the Cryptographic Message Syntax (CMS)"
      date: 2023
      author:
        org: IETF
  draft-housley-lamps-cms-sha3-hash:
      title: "Use of the SHA3 One-way Hash Functions in the Cryptographic Message Syntax (CMS)"
      date: 2023
      author:
        org: IETF
  draft-ietf-lamps-kyber-certificates:
      title: "Internet X.509 Public Key Infrastructure - Algorithm Identifiers for Kyber"
      date: 2023
      author:
        org: IETF

# <!-- EDNOTE: full syntax for this defined here: https://github.com/cabo/kramdown-rfc2629 -->

informative:
  RFC5990:
  RFC8411:
  RFC9180:
  SP-800-108:
      title: "Recommendation for Key Derivation Using Pseudorandom Functions"
      date: 2009
      author:
        org: NIST

--- abstract
This document describes the conventions for using a Key Encapsulation Mechanism algorithm (KEM) within the Cryptographic Message Syntax (CMS). The CMS specifies the envelopped-data content type, which consists of an encrypted content and encrypted content-encryption keys for one or more recipients. The mechanism proposed here can rely on either post-quantum KEMs, hybrid KEMs or classical KEMs.

<!-- End of Abstract -->

--- middle


# Revision History {#sec-version-changes}

- draft-ietf-lamps-cms-kyber-01:
   - Details of the KEMRecipientInfo content when using Kyber;
   - Editorial changes.
- draft-ietf-lamps-cms-kyber-00:
   - Use of KEMRecipientInfo to communicate algorithm info;
   - Editorial changes.


# Introduction {#sec-introduction}

In recent years, there has been a substantial amount of research on quantum computers – machines that exploit quantum mechanical phenomena to solve mathematical problems that are difficult or intractable for conventional computers. If large-scale quantum computers are ever built, they will be able to break many of the public-key cryptosystems currently in use. This would seriously compromise the confidentiality and integrity of digital communications on the Internet and elsewhere. Under such a threat model, the current key encapsulation mechanisms would be vulnerable.

Post-quantum key encapsulation mechanisms (PQ-KEM) are being developed in order to provide secure key establishment against an adversary with access to a quantum computer.

As the National Institute of Standards and Technology (NIST) is still in the process of selecting the new post-quantum cryptographic algorithms that are secure against both quantum and classical computers, the purpose of this document is to propose a generic "algorithm-agnostic" solution to protect in confidentiality the CMS envelopped-data content against the quantum threat : the KEM-TRANS mechanism.

Although this mechanism could thus be used with any key encapsulation mechanism, including post-quantum KEMs or hybrid KEMs.

This RFC nonetheless specifically specifies the case where the algorithm PQ-KEM algorithm is Kyber.

<!-- End of introduction section -->


# Terminology {#sec-terminology}
The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in BCP 14 {{RFC2119}}  {{RFC8174}} when, and only when, they appear in all capitals, as shown here.

The following terms are used in this document:

BER:
          Basic Encoding Rules (BER) as defined in [X.690].

DER:
          Distinguished Encoding Rules as defined in [X.690].

<!-- End of terminology section -->

# Design Rationales {#sec-design-rationales}

The Cryptographic Message Syntax (CMS) [RFC5652] defines two levels of encryptions in the Envelopped-Data Content section:

 - the Content-encryption process which protects the data using a symmetric algorithm used with a content encryption key (CEK);
 - the Key-encryption process which protects this CEK using a key transport mechanism.

One of the typical use case of the CMS Envelopped-Data Content is to randomly generate a CEK, encrypt the data with a symmetric algorithm using this CEK and individually send the CEK to one or more recipients protected by asymmetric cryptography in a RecipientInfo object.

To achieve this scenario with KEM primitives, it is necessary to define a new key transport mechanism that will fulfil the following requirements:

- the Key Transport Mechanism SHALL be secure against quantum computers.
- the Key Transport Mechanism SHALL take the Content-Encryption Key (CEK) as input.

According to NIST, a KEM generates a random secret and a ciphertext from which the recipient can extract the shared secret, meaning that a KEM can not be used straightforwardly as a key transport mechanism in the CMS "multi-recipients" context. The KEM-TRANS mechanism defined in this document aims to turn a KEM into a key transport scheme allowing the sender to distribute a randomly generated key to several recipients.
The KEM-TRANS Key transport mechanism described in the following section fulfils the requirements listed above and is an adaptation of the RSA-KEM algorithm previously specified in [RFC5990]. The solution is also aligned with the hybrid public key encyption scheme described in {{RFC9180}}.

# KEM Key Transport Mechanism (KEM-TRANS) {#sec-kem-key-transport-mechanism}

The KEM Key Transport Mechanism (KEM-TRANS) is a one-pass (store-and-forward) mechanism for transporting keying data to a recipient.

With this type of mechanism, a sender cryptographically encapsulates the keying data using the recipient's public key to obtain encrypted keying data. The recipient can then decapsulate the encrypted keying data using his private key to recover the plaintext keying data.

<!-- End of kem-key-transport-mechanism section -->

## Underlying Components {#sec-underlying-components}

The KEM-TRANS requires use of the following underlying components, which are provided to KEM-TRANS as algorithm parameters.

- KEM, a Key Encapsulation Mechanism;
- KDF, a Key Derivation Function, which derives keying data of a specified length from a shared secret value;
- WRAP, a symmetric key-wrapping scheme, which encrypts keying Data using a key-encrypting key (KEK).

### KEM

A KEM is a cryptographic algorithm consisting of three functions :

- a key generation function **KEM.keygen** taking as input a security level and returning a key pair (private key and the associated public key) for this security level.
- an encapsulation function **KEM.encaps** taking a public key as input and returning a random session key and a ciphertext that is an encapsulation of the session key.
- a decaspulation function **KEM.decaps** taking as input a private key and a ciphertext and returning a session key.

### KDF

A key derivation function (KDF) is a cryptographic function that deterministically derives one or more secret keys from a secret value using a pseudorandom function. KDFs can be used to stretch keys into longer keys or to obtain keys of a required format.

If the session key obtained from the KEM algorithm is long enough to fit into the WRAP algorithm, then the KDF could be equal to the identity function.

### WRAP

A wrapping algorithm is a symmetric algorithm protecting data in confidentiality and integrity. It is especially designed to transport key material. the WRAP algorithm consists of two functions :

- a wrapping function **Wrap** taking a wrapping key and a plaintext key as input and returning a wrapped key.
- a decaspulation function **Unwrap** taking as input a wrapping key and a wraped key and returning the plaintext key.

In the following, *kekLen* denotes the length in bytes of the wrapping key for the underlying symmetric key-wrapping scheme.

In this scheme, the length of the keying data to be transported MUST be among the lengths supported by the underlying symmetric key-wrapping scheme.

<!-- End of underlying-components section -->

## Recipient's Key Generation and Distribution {#sec-key-generation-and-distribution}

The KEM-TRANS described in the next sections assumes that the recipient has previously generated a key pair (*recipPrivKey* and *recipPubKey*) and has distributed his public key to the sender.

The protocols and mechanisms by which the key pair is securely generated and the public key is securely distributed are out of the scope of this document.

<!-- End of key-generation-and-distribution section -->

## Sender's Operations {#sec-sender-operations}

This process assumes that the following algorithm parameters have been selected:

- *KEM*: a key encapsulation mechanism, as defined above.
- *KDF*: a key derivation function, as defined above.
- *Wrap*: a symmetric key-wrapping algorithm, as defined above.
- *kekLen*: the length in bits of the key required for the Wrap algorithm.

This process assumes that the following input data has been provided:

- *recipPubKey*: the recipient's public key.
- *K*: the keying data to be transported, assumed to be a length that is compatible with the chosen Wrap algorithm.

This process outputs:

- *EK*: the encrypted keying data, from which the recipient will be able to retrieve *K*.



The sender performs the following operations:

1. Generate a shared secret *SS* and the associated ciphertext *CT* using the KEM encaspulation function and the recipient's public key *recipPubKey*:

   > (SS, CT) = KEM.encaps(recipPubKey)

2. Derive a key-encrypting key *KEK* of length *kekLen* bytes from the shared secret *SS* using the underlying key derivation function:

   > KEK = KDF(SS, kekLen)

3. Wrap the keying data *K* with the key-encrypting key *KEK* using the underlying key-wrapping scheme to obtain wrapped keying data *WK* of length *wrappedKekLen*:

   > WK = Wrap(KEK, K)

4. Concatenate the wrapped keying data *WK* of length *wrappedKekLen* and the ciphertext *CT* to obtain the encrypted keying data *EK*:

   > EK = (WK \|\| CT)

5. Output the encrypted keying data *EK*.

<!-- End of sender-operations section -->


## Recipient's Operations {#sec-recipient-operations}

This process assumes that the following algorithm parameters have been communicated from the sender:

- *KEM*: a key encapsulation mechanism, as defined above.
- *KDF*: a key derivation function, as defined above.
- *Wrap*: a symmetric key-wrapping algorithm, as defined above.
- *kekLen*: the length in bits of the key required for the Wrap algorithm.

This process assumes that the following input data has been provided:

- *recipPrivKey*: the recipient's private key.
- *EK*: the encrypted keying data.

This process outputs:

- *K*: the keying data to be transported.

The recipient performs the following operations:

1. Separate the encrypted keying data *EK* into wrapped keying data *WK* of length *wrappedKekLen* and a ciphertext *CT* :

   > (WK \|\| CT) = EK

2. Decapsulate the ciphertext *CT* using the KEM decaspulation function and the recipient's private key to retrieve the shared secret *SS*:

   > SS = KEM.decaps(recipPrivKey, CT)

   If the decapsulation operation outputs an error, output "decryption error", and stop.

3. Derive a key-encrypting key *KEK* of length *kekLen* bytes from the shared secret *SS* using the underlying key derivation function:

   > KEK = KDF(SS, kekLen)

4. Unwrap the wrapped keying data *WK* with the key-encrypting key *KEK* using the underlying key-wrapping scheme to recover the keying data *K*:

   > K = Unwrap(KEK, WK)

   If the unwrapping operation outputs an error, output "decryption error", and stop.

5. Output the keying data *K*.

<!-- End of recipient-operations section -->

# Use of Kyber in CMS {#sec-use-kyber-in-cms}

The KEM Key Transport Mechanism MAY be employed for one or more recipients in the CMS envelopped-data content type (Section 6 of [RFC5652]), where the keying data *K* processed by the mechanism is the CMS content-encryption key (*CEK*).

## Use of of Kyber within KEM-TRANS {#sec-use-kyber-in-kem-trans}

When Kyber is employed in CMS, the security levels of the different underlying components used by the sender within the KEM-TRANS should be consistant.

When kyber512 is used, the following configuration should be used:

- KEM: id-kyber512
- KDF: id-alg-hkdf-with-sha256 OR id-alg-hkdf-with-sha3-256
- kekLen: 128
- WRAP: id-aes128-Wrap

When kyber768 is used, the following configuration should be used:

- KEM: id-kyber768
- KDF: id-alg-hkdf-with-sha384 OR id-alg-hkdf-with-sha3-384
- kekLen: 192
- WRAP: id-aes192-Wrap

When kyber1024 is used, the following configuration should be used:

- KEM: id-kyber1024
- KDF: None
- kekLen: 256
- WRAP: id-aes256-Wrap

<!-- End of use-kyber-in-kem-trans section -->

## RecipientInfo Conventions {#sec-recipientInfo-conventions}

When KEM-TRANS is employed for a recipient, the RecipientInfo alternative for that recipient MUST be OtherRecipientInfo using the KEMRecipientInfo structure as defined in [draft-ietf-lamps-cms-kemri].
The fields of the KEMRecipientInfo MUST have the following values:

 - version is the syntax version number; it MUST be 0;
 - rid identifies the recipient's certificate or public key (*recipPubKey*);
 - kem identifies the KEM algorithm (*KEM*); it MUST contain one of the id-kyber (id-kyber512, id-kyber768, id-kyber1024);
 - kemct is the ciphertext produced for this recipient (*CT*);
 - kdf identifies the key-derivation algorithm (*KDF*);
 - kekLength is the size of the key-encryption key in octets (*kekLen*);
 - ukm is an optional random input to the key-derivation function;
 - wrap identifies a key wrappingn algorithm used to encrypt the content-encryption key (*WRAP*).

<!-- End of recipientInfo-conventions section -->

## Certificate Conventions {#sec-certificate-conventions}

The conventions specified in this section augment [RFC5280].

### Key Usage Extension {#sec-key-usage-extension}

The intended application for the key MAY be indicated in the key usage certificate extension (see [RFC5280], Section 4.2.1.3). If the keyUsage extension is present in a certificate that conveys a public key with the id-kem object identifier as discussed above, then the key usage extension MUST contain only the value *keyEncipherment*.

*digitalSignature*, *nonRepudiation*, *dataEncipherment*, *keyAgreement*, *keyCertSign*, *cRLSign*, *encipherOnly* and *decipherOnly* SHOULD NOT be present.

A key intended to be employed only with the KEM-TRANS SHOULD NOT also be employed for data encryption. Good cryptographic practice employs a given key pair in only one scheme. This practice avoids the risk that vulnerability in one scheme may compromise the security of the other, and may be essential to maintain provable security.

<!-- End of key-usage-extension section -->

### Subject Public Key Info {#sec-subject-public-key-info}

If the recipient wishes to employ the KEM-TRANS with a given public key, the recipient MUST use a X.509 certificate as defined in [draft-ietf-lamps-kyber-certificates].

The public key in the certificate should be identified by one of object identifiers given in Annex : id-kyber512, id-kyber768 or id-kyber1024.

<!-- End of subject-public-key-info section -->

<!-- End of certificate-conventions section -->

## SMIME Capabilities Attribute Conventions {#sec-smime-capabilities-attribute-conventions}

[RFC8551], Section 2.5.2 defines the SMIMECapabilities signed attribute (defined as a SEQUENCE of SMIMECapability SEQUENCEs) to be used to specify a partial list of algorithms that the software announcing the SMIMECapabilities can support.  When constructing a signedData object, compliant software MAY include the SMIMECapabilities signed attribute announcing that it supports the KEM Key Transport Mechanism.

The SMIMECapability SEQUENCE representing the KEM Key Transport Mechanism MUST include the id-kem-trans object identifier in the capabilityID field and MUST include a GenericKemTransParameters value in the parameters field identifying the components with which the mechanism is to be employed.

The DER encoding of a SMIMECapability SEQUENCE is the same as the DER encoding of an AlgorithmIdentifier. Example DER encodings for typical sets of components are given in Appendix A.

<!-- End of smime-capabilities-attribute-conventions section -->

<!-- End of use-in-cms section -->

# Security Considerations {#sec-security-considerations}

~~~
EDITOR'S NOTE' - TODO
section to be completed
~~~

<!-- End of security-considerations section -->


# IANA Considerations {#sec-iana-considerations}

Within the CMS, algorithms are identified by object identifiers (OIDs).  With one exception, all of the OIDs used in this document were assigned in other IETF documents, in ISO/IEC standards documents, by the National Institute of Standards and Technology (NIST).
The two exceptions are the ASN.1 module's identifier and id-kem-transport that are both assigned in this document.

<!-- End of iana-considerations section -->

# Acknowledgements {#sec-acknowledgements}
This document incorporates contributions and comments from a large group of experts. The Editors would especially like to acknowledge the expertise and tireless dedication of the following people, who attended many long meetings and generated millions of bytes of electronic mail and VOIP traffic over the past year in pursuit of this document:

We are grateful to all, including any contributors who may have been inadvertently omitted from this list.

This document borrows text from similar documents, including those referenced below. Thanks to the authors of those documents..

<!-- End of acknowledgements section -->

# Annex A : ASN.1 Syntax {#sec-asn1}

The syntax for the scheme is given in Appendix A.1.

The syntax for selected underlying components including those mentioned above is given in Appendix A.2.

The following object identifier prefixes are used in the definitions below:

      nistAlgorithm OID ::= {
         joint-iso-itu-t(2) country(16) us(840) organization(1)
         gov(101) csor(3) nistAlgorithm(4)
      }

      smimeAlgorithm OID ::= { iso(1) member-body(2)
         us(840) rsadsi(113549) pkcs(1) pkcs-9(9) smime(16) alg(3)
      }


## Annex A1 : KEM-TRANS Key Transport Mechanism

The object identifier for the KEM Key Transport Mechanism is id-kem-trans, which is defined in this document as:

    id-kem-trans OID ::= { smimeAlgorithm TBD }

When id-kem-trans is used in an AlgorithmIdentifier, the parameters MUST employ the GenericKemTransParameters syntax.
The syntax for GenericKemTransParameters is as follows:

    GenericKemTransParameters ::= {
        kem  KeyEncapsulationMechanism,
        kdf  KeyDerivationFunction,
        wrap KeyWrappingMechanism
    }

The fields of type GenericKemTransParameters have the following meanings:

- kem identifies the underlying key encapsulation mechanism (KEM). This can be Kyber.
- kdf identifies the underlying key derivation function (KDF). This can be any KDF from [SP-800-56C-r2].
  kdf can be equal to *null* if the key encaspulation mechanism outputs a shared secret *SS* of size *kekLen*.
- wrap identifies the underlying key wrapping mechanism (WRAP). This can be any wrapping mechanism from [RFC5649].


## Annex A2 : Underlying Components

### Key Encapsulation Mechanisms

KEM-TRANS can support any NIST KEM, including the post-quantum KEM Kyber.
This RFC only specifies the use of Kyber.

The object identifier for KEM depends on the security level (128 bits, 192 bits or 256 bits)

      id-kyber512 OID ::= { nistAlgorithm TBD }
      id-kyber768 OID ::= { nistAlgorithm TBD }
      id-kyber1024 OID ::= { nistAlgorithm TBD }

These object identifiers have no associated parameters.

      kyber512 ALGORITHM ::= { OID id-kyber512 }
      kyber768 ALGORITHM ::= { OID id-kyber768 }
      kyber1024 ALGORITHM ::= { OID id-kyber1024 }

When one of these algorithms identifiers is used, the parameters field MUST be absent; not NULL but absent.

### Key Derivation Functions

This RFC only specifies the use of HKDF from [RFC5869].
The HKDF can be bypassed if the key encaspulation mechanism outputs a shared secret *SS* of size *kekLen*. kdf is then equal to *null*.

The object identifier for HKDF depends on the security level (128 bits, 192 bits or 256 bits).

For SHA2 algorithms, the following object identifiers from [RFC8619] should be used:

      id-alg-hkdf-with-sha256 OID ::= { OID id-alg-hkdf-with-sha256 }
      id-alg-hkdf-with-sha384 OID ::= { OID id-alg-hkdf-with-sha384 }
      id-alg-hkdf-with-sha512 OID ::= { OID id-alg-hkdf-with-sha512 }

For SHA3 algorithms, the following object identifiers from [draft-housley-lamps-cms-sha3-hash] should be used:

      id-alg-hkdf-with-sha3-256 OID ::= { OID id-alg-hkdf-with-sha3-256 }
      id-alg-hkdf-with-sha3-384 OID ::= { OID id-alg-hkdf-with-sha3-384 }
      id-alg-hkdf-with-sha3-512 OID ::= { OID id-alg-hkdf-with-sha3-512 }

When one of these algorithms identifiers is used, the parameters field MUST be absent; not NULL but absent.


### Key Wrapping Schemes

KEM-TRANS can support any wrapping mechanism from [RFC5649].
This RFC only specifies the use of aes256-Wrap.

The object identifiers for the AES Key Wrap depend on the size of the key-encrypting key.

The following object identifiers from [RFC5649] should be used:

      aes128-Wrap ALGORITHM ::= { OID id-aes128-Wrap }
      aes192-Wrap ALGORITHM ::= { OID id-aes192-Wrap }
      aes256-Wrap ALGORITHM ::= { OID id-aes256-Wrap }

When one of these algorithms identifiers is used, the parameters field MUST be absent; not NULL but absent.


## Appendix A3 : Examples

~~~
EDITOR'S NOTE' - TODO
section to be completed
~~~
