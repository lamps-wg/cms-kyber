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
  github: "lamps-wg/kyber-certificates"

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
  FIPS203: # TODO: just use NIST.FIPS.203 when bib.ietf.org is updated
      title: "Module-Lattice-based Key-Encapsulation Mechanism Standard"
      date: 2024-08-13
      target: https://doi.org/10.6028/NIST.FIPS.203
      author:
        org: National Institute of Standards and Technology (NIST)
      seriesinfo: FIPS PUB 203
  RFC8551:

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
--- abstract

The Module-Lattice-based Key-Encapsulation Mechanism (ML-KEM) algorithm is a one-pass (store-and-forward) cryptographic mechanism for an originator to securely send keying material to a recipient using the recipient's ML-KEM public key. Three parameters sets for the ML-KEM algorithm are specified by NIST in {{FIPS203}}. In order of increasing security strength (and decreasing performance), these parameter sets are ML-KEM-512, ML-KEM-768, and ML-KEM-1024. This document specifies the conventions for using ML-KEM with the Cryptographic Message Syntax (CMS) using KEMRecipientInfo as specified in {{!RFC9629}}.

<!-- End of Abstract -->

--- middle


# Introduction {#sec-introduction}

ML-KEM is an IND-CCA2-secure key-encapsulation mechanism (KEM) standardized in {{FIPS203}} by the US NIST PQC Project {{NIST-PQ}}.

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

All identifiers used by ML-KEM in CMS are defined elsewhere but reproduced here for convenience:

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

The ML-KEM variant and the underlying components need to be selected consistent with the desired security level. Several security levels have been identified in NIST SP 800-57 Part 1 {{?NIST.SP.800-57pt1r5}}. To achieve 128-bit security, ML-KEM-512 SHOULD be used, the key-derivation function SHOULD provide at least 128 bits of preimage strength, and the symmetric key-encryption algorithm SHOULD have a security strength of at least 128 bits. To achieve 192-bit security, ML-KEM-768 SHOULD be used, the key-derivation function SHOULD provide at least 192 bits of preimage strength, and the symmetric key-encryption algorithm SHOULD have a security strength of at least 192 bits. In the case of AES Key Wrap, a 256-bit key is typically used because AES-192 is not as commonly deployed. To achieve 256-bit security, ML-KEM-1024 SHOULD be used, the key-derivation function SHOULD provide at least 256 bits of preimage strength, and the symmetric key-encryption algorithm SHOULD have a security strength of at least 256 bits.

Provided all inputs are well-formed, the key establishment procedure of ML-KEM will never explicitly fail. Specifically, the ML-KEM.Encaps and ML-KEM.Decaps algorithms from {{FIPS203}} will always output a value with the same data type as a shared secret key, and will never output an error or failure symbol. However, it is possible (though extremely unlikely) that the process will fail in the sense that ML-KEM.Encaps and ML-KEM.Decaps will produce different outputs, even though both of them are behaving honestly and no adversarial interference is present. In this case, the sender and recipient clearly did not succeed in producing a shared
secret key. This event is called a decapsulation failure. Estimates for the decapsulation failure probability (or rate) for each of the ML-KEM parameter sets are provided in Table 1 of {{FIPS203}} and reproduced here in {{tab-fail}}.

|Parameter set | Decapsulation failure rate |
|---           |---                         |
| ML-KEM-512   | 2^(−138.8)                 |
| ML-KEM-768   | 2^(−164.8)                 |
| ML-KEM-1024  | 2^(−174.8)                 |
{: #tab-fail title="ML-KEM decapsulation failures rates"}

Implementations MUST protect the ML-KEM private key, the key-encryption key, the content-encryption key, message-authentication key, and the content-authenticated-encryption key. Disclosure of the ML-KEM private key could result in the compromise of all messages protected with that key. Disclosure of the key-encryption key, the content-encryption key, or the content-authenticated-encryption key could result in compromise of the associated encrypted content. Disclosure of the key-encryption key, the message-authentication key, or the content-authenticated-encryption key could allow modification of the associated authenticated content.

Additional considerations related to key management may be found in {{?NIST.SP.800-57pt1r5}}.

The security of the ML-KEM algorithm depends on a quality random number generator. For further discussion on random number generation, see {{?RFC4086}}.

ML-KEM encapsulation and decapsulation only outputs a shared secret and ciphertext. Implementations SHOULD NOT use intermediate values directly for any purpose.

Implementations SHOULD NOT reveal information about intermediate values or calculations, whether by timing or other "side channels", otherwise an opponent may be able to determine information about the keying data and/or the recipient's private key. Although not all intermediate information may be useful to an opponent, it is preferable to conceal as much information as is practical, unless analysis specifically indicates that the information would not be useful to an opponent.

Generally, good cryptographic practice employs a given ML-KEM key pair in only one scheme. This practice avoids the risk that vulnerability in one scheme may compromise the security of the other, and may be essential to maintain provable security.

Parties MAY gain assurance that implementations are correct through formal implementation validation, such as the NIST Cryptographic Module Validation Program (CMVP) {{CMVP}}.

<!-- End of security-considerations section -->

# IANA Considerations {#sec-iana-considerations}

None.

Within the CMS, algorithms are identified by object identifiers (OIDs). All of the OIDs used in this document were assigned in other IETF documents, in ISO/IEC standards documents, or by the National Institute of Standards and Technology (NIST).

<!-- End of iana-considerations section -->

# Acknowledgements {#sec-acknowledgements}

This document borrows heavily from {{?I-D.ietf-lamps-rfc5990bis}}, {{FIPS203}}, and {{?I-D.kampanakis-ml-kem-ikev2}}. Thanks go to the authors of those documents. "Copying always makes things easier and less error prone" - RFC8411.

Thanks to Carl Wallace and Jonathan Hammel for the detailed review and Carl Wallace for interoperability testing.

<!-- End of acknowledgements section -->

--- back

# ASN.1 Module

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
  -----BEGIN PUBLIC KEY-----
  MIIDMjALBglghkgBZQMEBAEDggMhACTnc6B5UOyymOxQLDt8PzI2vIHkccIGsy1b
  uI6EZ4UVHbHHpbRRv3mZwW7AEu+YEbpcB6kkZ28jUTHWFfYIIIeUbq6hMa/nRcLT
  UPYcjTwBK+dRU1UbmfTHCdtrF3U0hyB7tXsBo6tTeQWCpP7LBrYxmAFBhp2JuUx6
  MO+TpIWVHVzyzS2UE4MEBQ/HDGWyCgL6WRKGRdrEfBc2Wg7loCc7RDjoOqWGYPcV
  n2HCLPVhemLWAeCRE0wcLUPSvUzhKZsrRk4cfSi5eZB7Dze4olQ8NFGiJ8WMi+Y3
  xjiTW/w6X/Y7bC+zf8JLFcn7jOvQNM85PXp4j3KIiXSnCAv1OEUDZO5peP0QQUU1
  CxvQQjxCj+kGHZ/EaKeFy7QD0Crhl69xccB0dMzZMgQFmynLv5kZd0Z4SuSkANQ8
  ymtoLDvMqyHznseJS68ru+ZRn88KkVMosF4UkhKjphLXASHQU5RyquuBORUGLY/q
  DXQSyCJ8AHAlzCYwEUdpqGzsMo84bB72AyN5LNL3mxZaQnxAuREpQIO8w13IREfG
  HEPbHDJVZBXqCcD2wBWllJk4Fjn3b0uid62UfZLARoNCvakIkT+wUv68FS+WGVoY
  zbvYqqPSpJg5GRrTT8KUDwLscRkBVPIDctMWFD20yppmL9iLSwPkrz/1xhbgEqdA
  HGG2kt8XdkIRmEZ2IeLUJeiDPPGCi4zlywkbNpgIHajQriGcNQnoQWQZG3vWe0n2
  ZGuHoF/lPZ0awi6roL7ZOWaysXSBYRv5DiXTP3EFD2lQGDMDECjQPUw2yMXBDRFY
  pYPAeuEGfXMhl8EDgcuie/06oy45kOxxiud6r8q2b9hnH5YzGjJLYSygm9jAhQrQ
  a80GWUdVHvvElgZLs7uEFHhKtgcFbYmDH4GaiLVLMo70cSpDdDXmdVc0J9mEOsSk
  ac5ztj+mgj7qfCkib6QXeAMCmSnASKugi9iSAEEmXalmN5Jksh75YlozJM0xyDTZ
  k5SqKn5seA97Y+ExjOJXOEzcsXhHV9vc/9HTgFGXNv+Lbj8u+q4i4NDoWIntY5eM
  +u9k28Eo
  -----END PUBLIC KEY-----
~~~

Bob's ML-KEM-512 public key has the following key identifier:

~~~
  5017165E720D05D70CFDA5F47B54BD5008C3ABE1
~~~

Alice generates a shared secret and ciphertext using Bob's ML-KEM-512 public key, derives the key-encryption key from the shared secret and CMSORIforKEMOtherInfo using HKDF with SHA-256, randomly generates a 128-bit content-encryption key, uses AES-128-KEYWRAP to encrypt the content-encryption key with the key-encryption key, encrypts the plaintext content with the content-encryption key and encodes the EnvelopedData (using KEMRecipientInfo) and ContentInfo, and then sends the result to Bob.

The Base64-encoded result is:

~~~
  MIID4AYJKoZIhvcNAQcDoIID0TCCA80CAQMxggOIpIIDhAYLKoZIhvcNAQkQDQMw
  ggNzAgEAgBRQFxZecg0F1wz9pfR7VL1QCMOr4TALBglghkgBZQMEBAEEggMAqXwh
  xkJt/Vd+oSOSIDXM8851hXdyECMaHp2hnWGL2JohQ38wE82Yg4GC3YfU8F/kA6EZ
  yK5p96HnJsXRfg3dzxprhf7QX4/UNo6v7nwk1JEP5cCwmuMOnbZfeKPb1Mr4qilG
  hlwjpq/r6fR9rZmGOyBG0ZDAQVNlNzgPqnlgK1V/DGYf6KAfWscdjRGs8xHMeRJg
  7vLDSz9A/u1Cu2dZWIMKzwK5snTK2FbOAYerTfDDBnYNoQFpcgoWOFN45SYDTvgb
  2n9sUxWHovMRKlF6j6f9UVa0uqHYzoIXaLU3R9f0LxUVSV6bJ3hQp87t2l3E5ysd
  k3pmqsKkHhBWltJSJeRjjELSDUYs8AuW7D0TnLH0Jt/q0XG7zm1C2cWhJ5oTij10
  yr4qf38mwbG9R1dAbkrtchxl8Rl9v0OJZgfUHJLuSVMTYAb6n3Ltc4tN8qIia3cy
  Lg+wan2CjnXA3fKGDMMWhvaH0GRirItKumKBXg11MuG8PjLm/neUX2MIE+3hzDBB
  GBqSI586EZAx+WgWEhn7sLKlbm8wZtY5jfaqobusj3hN/RxCzFtplq6e3H7tEpFv
  mblF9lSPNpeA06Tj+PXZxXjgupj4gRp+fsjcVheG/syt5MuiFuTG7xdDtWyU7K3e
  8ZBo+zSUysipy4QEFlrBo+tMvhyDffyOd/qaaQnT0cv2ctEU6OeshZ1+J+ptDmx7
  6K3WH+k9etrcwUTmblJn8FDM3czM7fC+XScB5CrNyl9C+W1TN/NzMxaXRQcWuDyJ
  3jRWXmtJEGksg489cJAv1QbZXQmDlarrwq/01Tb7PWbE1QjfRQ627p3ZtAmK6zf7
  wZ8m8ZhoVMRA7qoEd3wfDxmdv4AgGvKILntG3WPgEYpF37qJbHbD6FQqhJXN2kx1
  FUDtsYCmiXB/3+MSz3HDbmXJvC7oxVmpM7YQHWYsrmRE1xDZcQl5IOUHo6yjjDvI
  iAsbmd7BCbanMK8Izysi1Whkw/hjQIuBfi6lH4ykkhN1d9U0Ebn3OZ625WmEMA0G
  CyqGSIb3DQEJEAMcAgEgMAsGCWCGSAFlAwQBLQQoxaMpy4QqMaoK3B0wFDbqmvAW
  Kuo1hZIymSqlgVuw9FRNxbWvSMp24TA8BgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEq
  BBB7U/4MxliKkV8ho6ZJIm9UgBDzlQzo0SLI9+VS4VoV1mvr
~~~

This result decodes to:

~~~
    0 992: SEQUENCE {
    4   9:   OBJECT IDENTIFIER envelopedData (1 2 840 113549 1 7 3)
  15 977:   [0] {
  19 973:     SEQUENCE {
  23   1:       INTEGER 3
  26 904:       SET {
  30 900:         [4] {
  34  11:           OBJECT IDENTIFIER '1 2 840 113549 1 9 16 13 3'
  47 883:           SEQUENCE {
  51   1:             INTEGER 0
  54  20:             [0]
        :         50 17 16 5E 72 0D 05 D7 0C FD A5 F4 7B 54 BD 50
        :         08 C3 AB E1
  76  11:             SEQUENCE {
  78   9:               OBJECT IDENTIFIER '2 16 840 1 101 3 4 4 1'
        :               }
  89 768:             OCTET STRING
        :         A9 7C 21 C6 42 6D FD 57 7E A1 23 92 20 35 CC F3
        :         CE 75 85 77 72 10 23 1A 1E 9D A1 9D 61 8B D8 9A
        :         21 43 7F 30 13 CD 98 83 81 82 DD 87 D4 F0 5F E4
        :         03 A1 19 C8 AE 69 F7 A1 E7 26 C5 D1 7E 0D DD CF
        :         1A 6B 85 FE D0 5F 8F D4 36 8E AF EE 7C 24 D4 91
        :         0F E5 C0 B0 9A E3 0E 9D B6 5F 78 A3 DB D4 CA F8
        :         AA 29 46 86 5C 23 A6 AF EB E9 F4 7D AD 99 86 3B
        :         20 46 D1 90 C0 41 53 65 37 38 0F AA 79 60 2B 55
        :         7F 0C 66 1F E8 A0 1F 5A C7 1D 8D 11 AC F3 11 CC
        :         79 12 60 EE F2 C3 4B 3F 40 FE ED 42 BB 67 59 58
        :         83 0A CF 02 B9 B2 74 CA D8 56 CE 01 87 AB 4D F0
        :         C3 06 76 0D A1 01 69 72 0A 16 38 53 78 E5 26 03
        :         4E F8 1B DA 7F 6C 53 15 87 A2 F3 11 2A 51 7A 8F
        :         A7 FD 51 56 B4 BA A1 D8 CE 82 17 68 B5 37 47 D7
        :         F4 2F 15 15 49 5E 9B 27 78 50 A7 CE ED DA 5D C4
        :         E7 2B 1D 93 7A 66 AA C2 A4 1E 10 56 96 D2 52 25
        :         E4 63 8C 42 D2 0D 46 2C F0 0B 96 EC 3D 13 9C B1
        :         F4 26 DF EA D1 71 BB CE 6D 42 D9 C5 A1 27 9A 13
        :         8A 3D 74 CA BE 2A 7F 7F 26 C1 B1 BD 47 57 40 6E
        :         4A ED 72 1C 65 F1 19 7D BF 43 89 66 07 D4 1C 92
        :         EE 49 53 13 60 06 FA 9F 72 ED 73 8B 4D F2 A2 22
        :         6B 77 32 2E 0F B0 6A 7D 82 8E 75 C0 DD F2 86 0C
        :         C3 16 86 F6 87 D0 64 62 AC 8B 4A BA 62 81 5E 0D
        :         75 32 E1 BC 3E 32 E6 FE 77 94 5F 63 08 13 ED E1
        :         CC 30 41 18 1A 92 23 9F 3A 11 90 31 F9 68 16 12
        :         19 FB B0 B2 A5 6E 6F 30 66 D6 39 8D F6 AA A1 BB
        :         AC 8F 78 4D FD 1C 42 CC 5B 69 96 AE 9E DC 7E ED
        :         12 91 6F 99 B9 45 F6 54 8F 36 97 80 D3 A4 E3 F8
        :         F5 D9 C5 78 E0 BA 98 F8 81 1A 7E 7E C8 DC 56 17
        :         86 FE CC AD E4 CB A2 16 E4 C6 EF 17 43 B5 6C 94
        :         EC AD DE F1 90 68 FB 34 94 CA C8 A9 CB 84 04 16
        :         5A C1 A3 EB 4C BE 1C 83 7D FC 8E 77 FA 9A 69 09
        :         D3 D1 CB F6 72 D1 14 E8 E7 AC 85 9D 7E 27 EA 6D
        :         0E 6C 7B E8 AD D6 1F E9 3D 7A DA DC C1 44 E6 6E
        :         52 67 F0 50 CC DD CC CC ED F0 BE 5D 27 01 E4 2A
        :         CD CA 5F 42 F9 6D 53 37 F3 73 33 16 97 45 07 16
        :         B8 3C 89 DE 34 56 5E 6B 49 10 69 2C 83 8F 3D 70
        :         90 2F D5 06 D9 5D 09 83 95 AA EB C2 AF F4 D5 36
        :         FB 3D 66 C4 D5 08 DF 45 0E B6 EE 9D D9 B4 09 8A
        :         EB 37 FB C1 9F 26 F1 98 68 54 C4 40 EE AA 04 77
        :         7C 1F 0F 19 9D BF 80 20 1A F2 88 2E 7B 46 DD 63
        :         E0 11 8A 45 DF BA 89 6C 76 C3 E8 54 2A 84 95 CD
        :         DA 4C 75 15 40 ED B1 80 A6 89 70 7F DF E3 12 CF
        :         71 C3 6E 65 C9 BC 2E E8 C5 59 A9 33 B6 10 1D 66
        :         2C AE 64 44 D7 10 D9 71 09 79 20 E5 07 A3 AC A3
        :         8C 3B C8 88 0B 1B 99 DE C1 09 B6 A7 30 AF 08 CF
        :         2B 22 D5 68 64 C3 F8 63 40 8B 81 7E 2E A5 1F 8C
        :         A4 92 13 75 77 D5 34 11 B9 F7 39 9E B6 E5 69 84
  861  13:             SEQUENCE {
  863  11:               OBJECT IDENTIFIER
        :                 hkdfWithSha256 (1 2 840 113549 1 9 16 3 28)
        :               }
  876   1:             INTEGER 32
  879  11:             SEQUENCE {
  881   9:               OBJECT IDENTIFIER
        :                 aes256-wrap (2 16 840 1 101 3 4 1 45)
        :               }
  892  40:             OCTET STRING
        :         C5 A3 29 CB 84 2A 31 AA 0A DC 1D 30 14 36 EA 9A
        :         F0 16 2A EA 35 85 92 32 99 2A A5 81 5B B0 F4 54
        :         4D C5 B5 AF 48 CA 76 E1
        :             }
        :           }
        :         }
  934  60:       SEQUENCE {
  936   9:         OBJECT IDENTIFIER data (1 2 840 113549 1 7 1)
  947  29:         SEQUENCE {
  949   9:           OBJECT IDENTIFIER
        :             aes256-CBC (2 16 840 1 101 3 4 1 42)
  960  16:           OCTET STRING
        :         7B 53 FE 0C C6 58 8A 91 5F 21 A3 A6 49 22 6F 54
        :           }
  978  16:         [0]
        :         F3 95 0C E8 D1 22 C8 F7 E5 52 E1 5A 15 D6 6B EB
        :         }
        :       }
        :     }
        :   }
~~~

## Recipient CMS Processing

Bob's ML-KEM-512 private key:

~~~
  -----BEGIN PRIVATE KEY-----
  MIIGdAIBADALBglghkgBZQMEBAEEggZgccN7jmIdwnCzfWgVxgIPofRkZ+qPP+Jn
  e7kd/wBvcwFsqygTliNHMixSTSc4OckHLmuehHZcpOc+mKNGyMu+flEy73GrpjrB
  L/Q/WaS7Vxe665MIbDKCqhJJS2AFguuYDBWGOxuCZYSQhawoAfR0OAkA5RoihgMH
  OKAx+6F0V8VJLFyj2yuVpNqOn2J3/bJ+DAMZv/ki2TcNoiEI/ZBfO0iEOKmso1tG
  p0A+96odcQOM0Bw2ATrJBpubaMFsK5y9Trgl6fJjwQI2eidnYcxC0ME6fVqNRWrK
  RDk3+jBiPkBzMOdJIsemNYeIwKu/ZpCbn8guTogI0tscIDiciXQwBbNp0HePdasB
  f4FklaESWfzO2XNyI8x/7nyBn2OJQrup6ec1BjKphuA5saBPnpW4D8UMJaVeCdq7
  7jVBdQwJDcUzWMGe0JpDGAJTqtONrPg0xyplcGQDoiGklDJhEuS5uDUgkaM27bJT
  FiDJxeGM9fZenJG129pCOwcTnud3yjeMsKmQ1joFjPuF4WxJsTE7BZWO9joX3oR+
  BVcrsua7ndarRDmY2LzIXWguTtulaEUkPre5l2dZpnFBv1sBEVASk+RBW8AxckcQ
  ZdIBX8QyRtgZbdVd6gy/nVhWnGcbFKEfEZY69ZlTZHG4SScdALmRfMdV2DB+i+XC
  GQZYVaeamzUa5EFqtGwPi/tz+AeZEHESs/YMamZplGBr5eCTthsZi9NZs5is1dFE
  avMnXKbN7oWBTYyKeOFFDph+RSCNlnnH5hKtFHWsPMZqVVaD7TAT8mYuhOq1gGKE
  mHlPTJNlPom1LbRiUktp9yWB9fQ5c9C5IrLPnMCIhqdcZ/a0zlHELyZ3DPNeSepD
  lBSuUacgClq7FNuV2LMgsbFqiVLD1bSVYzRLAAOac/Z1EZDCyPu9vlglAH3G5SLF
  mypxVtST1XQ91gkurfwksUK13vSif6miRvV9gFwb+5d2kJIjdJAcKilDi5TL7+wQ
  YYN9qGkYCNuVYDMVRCI0VEIHjise4KZaJOdzoHlQ7LKY7FAsO3w/Mja8geRxwgaz
  LVu4joRnhRUdsceltFG/eZnBbsAS75gRulwHqSRnbyNRMdYV9gggh5RurqExr+dF
  wtNQ9hyNPAEr51FTVRuZ9McJ22sXdTSHIHu1ewGjq1N5BYKk/ssGtjGYAUGGnYm5
  THow75OkhZUdXPLNLZQTgwQFD8cMZbIKAvpZEoZF2sR8FzZaDuWgJztEOOg6pYZg
  9xWfYcIs9WF6YtYB4JETTBwtQ9K9TOEpmytGThx9KLl5kHsPN7iiVDw0UaInxYyL
  5jfGOJNb/Dpf9jtsL7N/wksVyfuM69A0zzk9eniPcoiJdKcIC/U4RQNk7ml4/RBB
  RTULG9BCPEKP6QYdn8Rop4XLtAPQKuGXr3FxwHR0zNkyBAWbKcu/mRl3RnhK5KQA
  1DzKa2gsO8yrIfOex4lLryu75lGfzwqRUyiwXhSSEqOmEtcBIdBTlHKq64E5FQYt
  j+oNdBLIInwAcCXMJjARR2mobOwyjzhsHvYDI3ks0vebFlpCfEC5ESlAg7zDXchE
  R8YcQ9scMlVkFeoJwPbAFaWUmTgWOfdvS6J3rZR9ksBGg0K9qQiRP7BS/rwVL5YZ
  WhjNu9iqo9KkmDkZGtNPwpQPAuxxGQFU8gNy0xYUPbTKmmYv2ItLA+SvP/XGFuAS
  p0AcYbaS3xd2QhGYRnYh4tQl6IM88YKLjOXLCRs2mAgdqNCuIZw1CehBZBkbe9Z7
  SfZka4egX+U9nRrCLqugvtk5ZrKxdIFhG/kOJdM/cQUPaVAYMwMQKNA9TDbIxcEN
  EVilg8B64QZ9cyGXwQOBy6J7/TqjLjmQ7HGK53qvyrZv2GcfljMaMkthLKCb2MCF
  CtBrzQZZR1Ue+8SWBkuzu4QUeEq2BwVtiYMfgZqItUsyjvRxKkN0NeZ1VzQn2YQ6
  xKRpznO2P6aCPup8KSJvpBd4AwKZKcBIq6CL2JIAQSZdqWY3kmSyHvliWjMkzTHI
  NNmTlKoqfmx4D3tj4TGM4lc4TNyxeEdX29z/0dOAUZc2/4tuPy76riLg0OhYie1j
  l4z672TbwSjZpZyRy7PJw/1ddylMqPKx+8P8zUDASMuBWGXxUXFXnH57d4puN9tR
  8okk0ej2GS/mY8DijpX4g0XMQ0RECPq4
  -----END PRIVATE KEY-----
~~~

Bob decapsulates the ciphertext in the KEMRecipientInfo to get the ML-KEM-512 shared secret, derives the key-encryption key from the shared secret and CMSORIforKEMOtherInfo using HKDF with SHA-256, uses AES-128-KEYWRAP to decrypt the content-encryption key with the key-encryption key, and decrypts the encrypted contents with the content-encryption key, revealing the plaintext content:

~~~
  Hello, world!
~~~
