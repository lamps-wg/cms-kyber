---
v: 3
docname: draft-ietf-lamps-cms-kyber-latest
title: Use of ML-KEM in the Cryptographic Message Syntax (CMS)
abbrev: ML-KEM in CMS
consensus: 'true'
submissiontype: IETF
date: 2024
# <!-- date: 2023-11 -->
# <!-- date: 2023 -->

stand_alone: true # This lets us do fancy auto-generation of references
ipr: trust200902
area: Security
workgroup: LAMPS
keyword:
 - Key Encapsulation Mechanism (KEM)
 - KEMRecipientInfo
 - ML-KEM
 - Kyber
category: std
venue:
  group: "Limited Additional Mechanisms for PKIX and SMIME (lamps)"
  type: "Working Group"
  mail: "spasm@ietf.org"
  arch: "https://mailarchive.ietf.org/arch/browse/spasm/"
  github: "lamps-wg/cms-kyber"

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
      street: 16, Boulevard Saint-Germain
      city: Paris
      country: France
      code: 75005
      email: julien.prat@cryptonext-security.com
    -
      ins: M. Ounsworth
      name: Mike Ounsworth
      org: Entrust Limited
      abbrev: Entrust
      street: 2500 Solandt Road – Suite 100
      city: Ottawa, Ontario
      country: Canada
      code: K2K 3G5
      email: mike.ounsworth@entrust.com
    -
      ins: D. Van Geest
      name: Daniel Van Geest
      org: CryptoNext Security
      street: 16, Boulevard Saint-Germain
      city: Paris
      country: France
      code: 75005
      email: daniel.vangeest@cryptonext-security.com


normative:
  FIPS203: DOI.10.6028/NIST.FIPS.203
  RFC8551:
  X680:
    target: https://www.itu.int/rec/T-REC-X.680
    title: >
      Information technology - Abstract Syntax Notation One (ASN.1):
      Specification of basic notation
    date: 2021-02
    author:
    -  org: ITU-T
    seriesinfo:
      ITU-T Recommendation: X.680
      ISO/IEC: 8824-1:2021

# <!-- EDNOTE: full syntax for this defined here: https://github.com/cabo/kramdown-rfc2629 -->

informative:
  NIST-PQ:
    target: https://csrc.nist.gov/projects/post-quantum-cryptography
    title: Post-Quantum Cryptography Project
    author:
      - org: National Institute of Standards and Technology
    date: 2016-12-20
  CMVP:
    target: https://csrc.nist.gov/projects/cryptographic-module-validation-program
    author:
      org: National Institute of Standards and Technology
    title: "Cryptographic Module Validation Program"
    date: 2016
  RFC5911:

--- abstract

Module-Lattice-Based Key-Encapsulation Mechanism (ML-KEM) is a quantum-resistant key-encapsulation mechanism (KEM). Three parameters sets for the ML-KEM algorithm are specified by NIST in {{FIPS203}}. In order of increasing security strength (and decreasing performance), these parameter sets are ML-KEM-512, ML-KEM-768, and ML-KEM-1024. This document specifies the conventions for using ML-KEM with the Cryptographic Message Syntax (CMS) using KEMRecipientInfo as specified in {{!RFC9629}}.

<!-- End of Abstract -->

--- middle


# Introduction {#sec-introduction}

ML-KEM is an IND-CCA2-secure key-encapsulation mechanism (KEM) standardized in {{FIPS203}} by the US NIST PQC Project {{NIST-PQ}}. Prior to standardization, the algorithm was known as Kyber.  ML-KEM and Kyber are not compatible.

Native support for Key Encapsulation Mechanisms (KEMs) was added to CMS in {{!RFC9629}}, which defines the KEMRecipientInfo structure for the use of KEM algorithms for the CMS enveloped-data content type, the CMS authenticated-data content type, and the CMS authenticated-enveloped-data content type. This document specifies the direct use of ML-KEM in the KEMRecipientInfo structure in CMS using each of the three parameter sets from {{FIPS203}}, namely MK-KEM-512, ML-KEM-768, and ML-KEM-1024.  It does not address or preclude the use of ML-KEM as part of any hybrid scheme.

## Conventions and Terminology {#sec-intro-terminology}

{::boilerplate bcp14-tagged}

<!-- End of terminology section -->

## ML-KEM {#sec-intro-ml-kem}

ML-KEM is a lattice-based key encapsulation mechanism using Module Learning with Errors as its underlying primitive, which is a structured lattices variant that offers good performance and relatively small and balanced key and ciphertext sizes. ML-KEM was standardized with three parameter sets: ML-KEM-512, ML-KEM-768, and ML-KEM-1024. The parameters for each of the security levels were chosen to be at least as secure as a generic block cipher of 128, 192, or 256 bits, respectively.

Like all KEM algorithms, ML-KEM provides three functions: KeyGen(), Encapsulate(), and Decapsulate().

KeyGen() -> (pk, sk):
: Generate the public key (pk) and a private key (sk).

Encapsulate(pk) -> (ct, ss):
: Given the recipient's public key (pk), produce a ciphertext (ct) to be passed to the recipient and a shared secret (ss) for use by the originator.

Decapsulate(sk, ct) -> ss:
: Given the private key (sk) and the ciphertext (ct), produce the shared secret (ss) for the recipient.

The KEM functions defined above correspond to the following functions in {{FIPS203}}:

KeyGen():
: ML-KEM.KeyGen() from section 7.1.

Encapsulate():
: ML-KEM.Encaps() from section 7.2.

Decapsulate():
: ML-KEM.Decaps() from section 7.3.

All security levels of ML-KEM use SHA3-256, SHA3-512, SHAKE256, and SHAKE512 internally.

<!-- End of ML-KEM section -->

<!-- End of introduction section -->

# Use of the ML-KEM Algorithm in CMS {#sec-using}

The ML-KEM algorithm MAY be employed for one or more recipients in the CMS enveloped-data content type {{!RFC5652}}, the CMS authenticated-data content type {{!RFC5652}}, or the CMS authenticated-enveloped-data content type {{!RFC5083}}. In each case, the KEMRecipientInfo {{!RFC9629}} is used with the ML-KEM algorithm to securely transfer the content-encryption key from the originator to the recipient.

Processing ML-KEM with KEMRecipientInfo follows the same steps as {{Section 2 of RFC9629}}. To support the ML-KEM algorithm, a CMS originator MUST implement the Encapsulate() function and a CMS responder MUST implement the Decapsulate() function.

## RecipientInfo Conventions {#sec-using-recipientInfo}

When the ML-KEM algorithm is employed for a recipient, the RecipientInfo alternative for that recipient MUST be OtherRecipientInfo using the KEMRecipientInfo structure as defined in {{!RFC9629}}.

The fields of the KEMRecipientInfo MUST have the following values:

> version is the syntax version number; it MUST be 0.

> rid identifies the recipient's certificate or public key.

> kem identifies the KEM algorithm; it MUST contain one of id-alg-ml-kem-512, id-alg-ml-kem-768, or id-alg-ml-kem-1024. These identifiers are reproduced in {{sec-identifiers}}.

> kemct is the ciphertext produced for this recipient.

> kdf identifies the key-derivation algorithm. Note that the Key Derivation Function (KDF) used for CMS RecipientInfo process MAY be different than the KDF used within the ML-KEM algorithm.

> kekLength is the size of the key-encryption key in octets.

> ukm is an optional random input to the key-derivation function. ML-KEM doesn't place any requirements on the ukm contents.

> wrap identifies a key-encryption algorithm used to encrypt the content-encryption key.

<!-- End of recipientinfo conventions section -->

## Underlying Components {#sec-using-components}

When ML-KEM is employed in CMS, the security levels of the different underlying components used within the KEMRecipientInfo structure SHOULD be consistent.

### Use of the HKDF-based Key Derivation Function

The HMAC-based Extract-and-Expand Key Derivation Function (HKDF) is defined in {{!RFC5869}}.

The HKDF function is a composition of the HKDF-Extract and HKDF-Expand functions.

~~~
HKDF(salt, IKM, info, L)
  = HKDF-Expand(HKDF-Extract(salt, IKM), info, L)
~~~

HKDF(salt, IKM, info, L) takes the following parameters:

salt:
: optional salt value (a non-secret random value). In this document this parameter is unused, that is it is the zero-length string "".

IKM:
: input keying material. In this document this is the shared secret outputted from the Encapsulate() or Decapsulate() functions.  This corresponds to the IKM KDF input from {{Section 5 of RFC9629}}.

info:
: optional context and application specific information. In this document this corresponds to the info KDF input from {{Section 5 of RFC9629}}. This is the ASN.1 DER encoding of CMSORIforKEMOtherInfo.

L:
: length of output keying material in octets. This corresponds to the L KDF input from {{Section 5 of RFC9629}}, which is identified in the kekLength value from KEMRecipientInfo. Implementations MUST confirm that this value is consistent with the key size of the key-encryption algorithm.

HKDF may be used with different hash functions, including SHA-256 {{?FIPS180=NIST.FIPS.180-4}}. The object identifier id-alg-hkdf-with-sha256 is defined in {{!RFC8619}}, and specifies the use of HKDF with SHA-256. The parameter field MUST be absent when this algorithm identifier is used to specify the KDF for ML-KEM in KemRecipientInfo.

### Components for ML-KEM in CMS

A compliant implementation MUST support HKDF with SHA-256, using the id-alg-hkdf-with-sha256 KDF object identifier, as the KemRecipientInfo KDF for all ML-KEM parameter sets. Note that the KDF used to process the KEMRecipientInfo structure MAY be different from the KDF used in the ML-KEM algorithm.

For ML-KEM-512, an implementation must support the AES-Wrap-128 {{!RFC3394}} key-encryption algorithm using the id-aes128-wrap key-encryption algorithm object identifier {{!RFC3565}}.

For ML-KEM-768 and ML-KEM-1024, an implementation must support the AES-Wrap-256 {{!RFC3394}} key-encryption algorithm using the id-aes256-wrap key-encryption algorithm object identifier {{!RFC3565}}.

The above object identifiers are reproduced for convenience in {{sec-identifiers}}.

An implementation MAY also support other key-derivation functions and other key-encryption algorithms.

If underlying components other than those specified above are used, then the following KDF requirements are in effect in addition to those asserted in {{!RFC9629}}:

> ML-KEM-512 SHOULD be used with a KDF capable of outputting a key with at least 128 bits of preimage strength and with a key wrapping algorithm with a key length of at least 128 bits.

> ML-KEM-768 SHOULD be used with a KDF capable of outputting a key with at least 192 bits of preimage strength and with a key wrapping algorithm with a key length of at least 192 bits.

> ML-KEM-1024 SHOULD be used with a KDF capable of outputting a key with at least 256 bits of preimage strength and with a key wrapping algorithm with a key length of at least 256 bits.

<!-- End of Underlying Components section -->

## Certificate Conventions {#sec-using-certs}

The conventions specified in this section augment {{!RFC5280}}.

A recipient who employs the ML-KEM algorithm with a certificate MUST identify the public key in the certificate using the id-alg-ml-kem-512, id-alg-ml-kem-768, or id-alg-ml-kem-1024 object identifiers following the conventions specified in {{!I-D.ietf-lamps-kyber-certificates}}.

In particular, the key usage certificate extension MUST only contain keyEncipherment ({{Section 4.2.1.3 of RFC5280}}).

## SMIME Capabilities Attribute Conventions {#sec-using-smime-caps}

{{Section 2.5.2 of RFC8551}} defines the SMIMECapabilities attribute to announce a partial list of algorithms that an S/MIME implementation can support. When constructing a CMS signed-data content type {{!RFC5652}}, a compliant implementation MAY include the SMIMECapabilities attribute that announces support for one or more of the ML-KEM algorithm identifiers.

The SMIMECapability SEQUENCE representing the ML-KEM algorithm MUST include one of the ML-KEM object identifiers in the capabilityID field. When the one of the ML-KEM object identifiers appears in the capabilityID field, the parameters MUST NOT be present.

<!-- End of smime-capabilities-attribute-conventions section -->

<!-- End of use-in-cms section -->

# Identifiers {#sec-identifiers}

All identifiers used to indicate ML-KEM within CMS are defined elsewhere but reproduced here for convenience:

~~~
  nistAlgorithms OBJECT IDENTIFIER ::= { joint-iso-ccitt(2)
      country(16) us(840) organization(1) gov(101) csor(3)
      nistAlgorithm(4) }
  kems OBJECT IDENTIFIER ::= { nistAlgorithms 4 }

  id-alg-ml-kem-512 OBJECT IDENTIFIER ::= { kems 1 }

  id-alg-ml-kem-768 OBJECT IDENTIFIER ::= { kems 2 }

  id-alg-ml-kem-1024 OBJECT IDENTIFIER ::= { kems 3 }

  hashAlgs OBJECT IDENTIFIER ::= { joint-iso-itu-t(2) country(16)
      us(840) organization(1) gov(101) csor(3) nistAlgorithm(4) 2 }

  id-alg-hkdf-with-sha256 OBJECT IDENTIFIER ::= { iso(1)
      member-body(2) us(840) rsadsi(113549) pkcs(1) pkcs-9(9)
      smime(16) alg(3) 28 }

  aes OBJECT IDENTIFIER ::= { joint-iso-itu-t(2) country(16) us(840)
      organization(1) gov(101) csor(3) nistAlgorithms(4) 1 }

  id-aes128-wrap OBJECT IDENTIFIER ::= { aes 5 }
  id-aes256-wrap OBJECT IDENTIFIER ::= { aes 45 }
~~~

# Security Considerations {#sec-security-considerations}

The Security Considerations sections of {{!I-D.ietf-lamps-kyber-certificates}} and {{!RFC9629}} apply to this specification as well.

For ML-KEM specific security considerations refer to {{?I-D.sfluhrer-cfrg-ml-kem-security-considerations}}.

The ML-KEM variant and the underlying components need to be selected consistent with the desired security level. Several security levels have been identified in NIST SP 800-57 Part 1 {{?NIST.SP.800-57pt1r5}}. To achieve 128-bit security, ML-KEM-512 SHOULD be used, the key-derivation function SHOULD provide at least 128 bits of preimage strength, and the symmetric key-encryption algorithm SHOULD have a security strength of at least 128 bits. To achieve 192-bit security, ML-KEM-768 SHOULD be used, the key-derivation function SHOULD provide at least 192 bits of preimage strength, and the symmetric key-encryption algorithm SHOULD have a security strength of at least 192 bits. In the case of AES Key Wrap, a 256-bit key is typically used because AES-192 is not as commonly deployed. To achieve 256-bit security, ML-KEM-1024 SHOULD be used, the key-derivation function SHOULD provide at least 256 bits of preimage strength, and the symmetric key-encryption algorithm SHOULD have a security strength of at least 256 bits.

Provided all inputs are well-formed, the key establishment procedure of ML-KEM will never explicitly fail. Specifically, the ML-KEM.Encaps and ML-KEM.Decaps algorithms from {{FIPS203}} will always output a value with the same data type as a shared secret key, and will never output an error or failure symbol for well-formed inputs. However, it is possible (though extremely unlikely) that the process will fail in the sense that ML-KEM.Encaps and ML-KEM.Decaps will produce different outputs, even though both of them are behaving honestly and no adversarial interference is present. In this case, the sender and recipient clearly did not succeed in producing a shared
secret key. This event is called a decapsulation failure. Estimates for the decapsulation failure probability (or rate) for each of the ML-KEM parameter sets are provided in Table 1 of {{FIPS203}} and reproduced here in {{tab-fail}}.

|Parameter set | Decapsulation failure rate |
|---           |---                         |
| ML-KEM-512   | 2^(−138.8)                 |
| ML-KEM-768   | 2^(−164.8)                 |
| ML-KEM-1024  | 2^(−174.8)                 |
{: #tab-fail title="ML-KEM decapsulation failure rates"}

Implementations MUST protect the ML-KEM private key, the key-encryption key, the content-encryption key, message-authentication key, and the content-authenticated-encryption key. Disclosure of the ML-KEM private key could result in the compromise of all messages protected with that key. Disclosure of the key-encryption key, the content-encryption key, or the content-authenticated-encryption key could result in compromise of the associated encrypted content. Disclosure of the key-encryption key, the message-authentication key, or the content-authenticated-encryption key could allow modification of the associated authenticated content.

Additional considerations related to key management may be found in {{?NIST.SP.800-57pt1r5}}.

The security of the ML-KEM algorithm depends on a quality random number generator. For further discussion on random number generation, see {{?RFC4086}}.

ML-KEM encapsulation and decapsulation only outputs a shared secret and ciphertext. Implementations SHOULD NOT use intermediate values directly for any purpose.

Implementations SHOULD NOT reveal information about intermediate values or calculations, whether by timing or other "side channels", otherwise an opponent may be able to determine information about the keying data and/or the recipient's private key. Although not all intermediate information may be useful to an opponent, it is preferable to conceal as much information as is practical, unless analysis specifically indicates that the information would not be useful to an opponent.

Generally, good cryptographic practice employs a given ML-KEM key pair in only one scheme. This practice avoids the risk that vulnerability in one scheme may compromise the security of the other, and may be essential to maintain provable security.

Parties MAY gain assurance that implementations are correct through formal implementation validation, such as the NIST Cryptographic Module Validation Program (CMVP) {{CMVP}}.

<!-- End of security-considerations section -->

# IANA Considerations {#sec-iana-considerations}

For the ASN.1 Module in {{asn1}}, IANA is requested to assign an object identifier (OID) for the module identifier (TBD1) with a Description of "id-mod-cms-ml-kem-2024". The OID for the module should be allocated in the "SMI Security for S/MIME Module Identifier" registry (1.2.840.113549.1.9.16.0).

<!-- End of iana-considerations section -->

# Acknowledgements {#sec-acknowledgements}

This document borrows heavily from {{?I-D.ietf-lamps-rfc5990bis}}, {{FIPS203}}, and {{?I-D.kampanakis-ml-kem-ikev2}}. Thanks go to the authors of those documents. "Copying always makes things easier and less error prone" - RFC8411.

Thanks to Carl Wallace, Jonathan Hammel, and Sean Turner for the detailed review and Carl Wallace for interoperability testing.

<!-- End of acknowledgements section -->

--- back

# ASN.1 Module {#asn1}

This appendix includes the ASN.1 module {{X680}} for ML-KEM. This module imports objects from {{RFC5911}}, {{RFC9629}}, {{RFC8619}}, {{I-D.ietf-lamps-kyber-certificates}}.

RFC EDITOR: Please replace TBD2 with the value assigned by IANA during the publication of [I-D.ietf-lamps-kyber-certificates]. Also please replace [I-D.ietf-lamps-kyber-certificates] in the module with a reference to the published RFC.

~~~
<CODE BEGINS>
{::include CMS-KYBER-2024.asn}
<CODE ENDS>
~~~

# ML-KEM CMS Enveloped-Data Example

This example shows the establishment of an AES-128 content-encryption
key using:

*  ML-DSA-512 and HKDF with SHA-256;

*  KEMRecipientInfo key derivation using HKDF with SHA-256; and

*  KEMRecipientInfo key wrap using AES-128-KEYWRAP.

In real-world use, the originator would encrypt the content-
encryption key in a manner that would allow decryption with their own
private key as well as the recipient's private key.  This is omitted
in an attempt to simplify the example.

## Originator CMS Processing

Alice obtains Bob's ML-KEM-512 public key:

~~~
{::include ./example/ML-KEM-512.pub}
~~~

Bob's ML-KEM-512 public key has the following key identifier:

~~~
{::include ./example/ML-KEM-512.keyid}
~~~

Alice generates a shared secret and ciphertext using Bob's ML-KEM-512 public key, derives the key-encryption key from the shared secret and CMSORIforKEMOtherInfo using HKDF with SHA-256, randomly generates a 128-bit content-encryption key, uses AES-128-KEYWRAP to encrypt the content-encryption key with the key-encryption key, encrypts the plaintext content with the content-encryption key and encodes the EnvelopedData (using KEMRecipientInfo) and ContentInfo, and then sends the result to Bob.

The Base64-encoded result is:

~~~
{::include ./example/ML-KEM-512.cms}
~~~

This result decodes to:

~~~
{::include ./example/ML-KEM-512.cms.txt}
~~~

## Recipient CMS Processing

Bob's ML-KEM-512 private key:

~~~
{::include ./example/ML-KEM-512.priv}
~~~

Bob decapsulates the ciphertext in the KEMRecipientInfo to get the ML-KEM-512 shared secret, derives the key-encryption key from the shared secret and CMSORIforKEMOtherInfo using HKDF with SHA-256, uses AES-128-KEYWRAP to decrypt the content-encryption key with the key-encryption key, and decrypts the encrypted contents with the content-encryption key, revealing the plaintext content:

~~~
{::include ./example/decrypted.txt}
~~~
