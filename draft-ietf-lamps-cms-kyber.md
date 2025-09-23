---
v: 3
docname: draft-ietf-lamps-cms-kyber-latest
title: Use of ML-KEM in the Cryptographic Message Syntax (CMS)
abbrev: ML-KEM in the CMS
consensus: 'true'
submissiontype: IETF
date:
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
  RFC5911:
  CSOR:
    target: https://csrc.nist.gov/projects/computer-security-objects-register/algorithm-registration
    title: Computer Security Objects Register
    author:
      name: National Institute of Standards and Technology
      ins: NIST
    date: 2024-08-20

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

Module-Lattice-Based Key-Encapsulation Mechanism (ML-KEM) is a quantum-resistant key-encapsulation mechanism (KEM). Three parameter sets for the ML-KEM algorithm are specified by the US National Institute of Standards and Technology (NIST) in FIPS 203. In order of increasing security strength (and decreasing performance), these parameter sets are ML-KEM-512, ML-KEM-768, and ML-KEM-1024. This document specifies the conventions for using ML-KEM with the Cryptographic Message Syntax (CMS) using the KEMRecipientInfo structure defined in “Using Key Encapsulation
Mechanism (KEM) Algorithms in the Cryptographic Message Syntax (CMS)” (RFC 9629).

<!-- End of Abstract -->

--- middle


# Introduction {#sec-introduction}

The Module Lattice Key Encapsulation Mechanism (ML-KEM) is an IND-CCA2-secure Key Encapsulation Mechanism (KEM) standardized in {{FIPS203}} by the NIST PQC Project {{NIST-PQ}}. ML-KEM is the name given to the final standardized version and is incompatible with pre-standards versions, often called "Kyber".

{{!RFC9629}} defines the KEMRecipientInfo structure for the use of KEM algorithms for the CMS enveloped-data content type, the CMS authenticated-data content type, and the CMS authenticated-enveloped-data content type. This document specifies the direct use of ML-KEM in the KEMRecipientInfo structure using each of the three parameter sets from {{FIPS203}}, namely MK-KEM-512, ML-KEM-768, and ML-KEM-1024.  It does not address or preclude the use of ML-KEM as part of any hybrid scheme.

## Conventions and Terminology {#sec-intro-terminology}

{::boilerplate bcp14-tagged}

<!-- End of terminology section -->

## ML-KEM {#sec-intro-ml-kem}

ML-KEM is a lattice-based key encapsulation mechanism using Module Learning with Errors as its underlying primitive, which is a structured lattices variant that offers good performance and relatively small and balanced key and ciphertext sizes. ML-KEM was standardized with three parameter sets: ML-KEM-512, ML-KEM-768, and ML-KEM-1024. The parameters for each of the security levels were chosen to be at least as secure as a generic block cipher of 128, 192, or 256 bits, respectively.
{{arnold}} provides more information on ML-KEM security levels and sizes.

All KEM algorithms provide three functions: KeyGen(), Encapsulate(), and Decapsulate().

The following summarizes these three functions for the ML-KEM algorithm, referencing corresponding functions in {{FIPS203}}:

KeyGen() -> (ek, dk):
: Generate the public encapsulation key (ek) and a private decapsulation key (dk).  {{FIPS203}} specifies two formats for an ML-KEM private key: a 64-octet seed (d,z) and an (expanded) private decapsulation key (dk). Algorithm 19 (`ML-KEM.KeyGen()`) from {{FIPS203}} generates the public encapsulation key (ek) and the private decapsulation key (dk). As an alternative, when a seed (d,z) is generated first and then the seed is expanded to get the keys, algorithm 16 (`ML-KEM.KeyGen_internal(d,z)`) from {{FIPS203}} expands the seed to ek and dk. See {{Section 6 of I-D.ietf-lamps-kyber-certificates}} for private key encoding considerations.

Encapsulate(ek) -> (c, ss):
: Given the recipient's public key (ek), produce both a ciphertext (c) to be passed to the recipient and a shared secret (ss) for use by the originator. Algorithm 20 (`ML-KEM.Encaps(ek)`) from {{FIPS203}} is the encapsulation function for ML-KEM.

Decapsulate(dk, c) -> ss:
: Given the private key (dk) and the ciphertext (c), produce the shared secret (ss) for the recipient.  Algorithm 21 (`ML-KEM.Decaps(dk,c)`) from {{FIPS203}} is the decapsulation function for ML-KEM. If the private key is stored in seed form, `ML-KEM.KeyGen_internal(d,z)` may be needed as a first step to compute dk. See {{Section 8 of I-D.ietf-lamps-kyber-certificates}} for consistency considerations if the private key was stored in both seed and expanded formats.

All security levels of ML-KEM use SHA3-256, SHA3-512, SHAKE128, and SHAKE256 internally.

<!-- End of ML-KEM section -->

<!-- End of introduction section -->

# Use of the ML-KEM Algorithm in the CMS {#sec-using}

The ML-KEM algorithm MAY be employed for one or more recipients in the CMS enveloped-data content type {{!RFC5652}}, the CMS authenticated-data content type {{!RFC5652}}, or the CMS authenticated-enveloped-data content type {{!RFC5083}}. In each case, the KEMRecipientInfo {{!RFC9629}} is used with the ML-KEM algorithm to securely transfer the content-encryption key from the originator to the recipient.

Processing ML-KEM with KEMRecipientInfo follows the same steps as {{Section 2 of RFC9629}}. To support the ML-KEM algorithm, a CMS originator MUST implement the Encapsulate() function and a CMS recipient MUST implement the Decapsulate() function.

## RecipientInfo Conventions {#sec-using-recipientInfo}

When the ML-KEM algorithm is employed for a recipient, the RecipientInfo alternative for that recipient MUST be OtherRecipientInfo using the KEMRecipientInfo structure as defined in {{!RFC9629}}.

The fields of the KEMRecipientInfo have the following meanings:

> version is the syntax version number; it MUST be 0.

> rid identifies the recipient's certificate or public key.

> kem identifies the KEM algorithm; it MUST contain one of id-alg-ml-kem-512, id-alg-ml-kem-768, or id-alg-ml-kem-1024. These identifiers are reproduced in {{sec-identifiers}}.

> kemct is the ciphertext produced for this recipient.

> kdf identifies the key-derivation algorithm. Note that the Key Derivation Function (KDF) used for CMS RecipientInfo process MAY be different than the KDF used within the ML-KEM algorithm. Implementations MUST support HKDF {{!RFC5869}} with SHA-256 {{!FIPS180=NIST.FIPS.180-4}}, using the id-alg-hkdf-with-sha256 KDF object identifier {{!RFC8619}}. As specified in {{!RFC8619}}, the parameter field MUST be absent when this object identifier appears within the ASN.1 type AlgorithmIdentifier. Implementations MAY support other KDFs as well.

> kekLength is the size of the key-encryption key in octets.

> ukm is optional input to the key-derivation function. The secure use of ML-KEM in CMS does not depend on the use of a ukm value, so this document does not place any requirements on this value.  See {{Section 3 of RFC9629}} for more information about the ukm parameter.

> wrap identifies a key-encryption algorithm used to encrypt the content-encryption key. Implementations supporting ML-KEM-512 MUST support the AES-Wrap-128 {{!RFC3394}} key-encryption algorithm using the id-aes128-wrap key-encryption algorithm object identifier {{!RFC3565}}. Implementations supporting ML-KEM-768 or ML-KEM-1024 MUST support the AES-Wrap-256 {{!RFC3394}} key-encryption algorithm using the id-aes256-wrap key-encryption algorithm object identifier {{!RFC3565}}. Implementations MAY support other key-encryption algorithms as well.

{{example}} contains an example of establishing a content-encryption key using ML-KEM in the KEMRecipientInfo type.

<!-- End of recipientinfo conventions section -->

## Underlying Components {#sec-using-components}

When ML-KEM is employed in the CMS, the underlying components used within the KEMRecipientInfo structure SHOULD be consistent with a minimum desired security level.
Several security levels have been identified in NIST SP 800-57 Part 1 {{?NIST.SP.800-57pt1r5}}.

If underlying components other than those specified in {{sec-using-recipientInfo}} are used, then the following table gives the minimum requirements on the components used with ML-KEM in the KEMRecipientInfo type in order to satisfy the KDF and key wrapping algorithm requirements from {{Section 7 of RFC9629}}:

| Security Strength | Algorithm   | KDF preimage strength | Symmetric key-encryption strength |
|---                |---          |---                    |---                                |
| 128-bit           | ML-KEM-512  | 128-bit               | 128-bit                           |
| 192-bit           | ML-KEM-768  | 192-bit               | 192-bit (*)                         |
| 256-bit           | ML-KEM-1024 | 256-bit               | 256-bit                           |
{: #tab-strong title="ML-KEM KEMRecipientInfo component security levels"}

(*) In the case of AES Key Wrap, a 256-bit key is typically used because AES-192 is not as commonly deployed.

### Use of the HKDF-based Key Derivation Function

The HKDF function is a composition of the HKDF-Extract and HKDF-Expand functions.

~~~
HKDF(salt, IKM, info, L)
  = HKDF-Expand(HKDF-Extract(salt, IKM), info, L)
~~~

When used with KEMRecipientInfo, the salt parameter is unused, that is it is the zero-length string "". The IKM, info and L parameters correspond to the same KDF inputs from {{Section 5 of RFC9629}}. The info parameter is independently generated by the originator and recipient. Implementations MUST confirm that L is consistent with the key size of the key-encryption algorithm.

<!-- End of Underlying Components section -->

## Certificate Conventions {#sec-using-certs}

RFC 5280 {{!RFC5280}} specifies the profile for using X.509 Certificates in Internet applications.  A recipient static public key is needed
for ML-KEM, and the originator obtains that public key from the recipient's certificate.  The conventions for carrying ML-KEM public keys are specified in [I-D.ietf-lamps-kyber-certificates].

## SMIME Capabilities Attribute Conventions {#sec-using-smime-caps}

{{Section 2.5.2 of RFC8551}} defines the SMIMECapabilities attribute to announce a partial list of algorithms that an S/MIME implementation can support. When constructing a CMS signed-data content type {{!RFC5652}}, a compliant implementation MAY include the SMIMECapabilities attribute that announces support for one or more of the ML-KEM algorithm identifiers.

The SMIMECapability SEQUENCE representing the ML-KEM algorithm MUST include one of the ML-KEM object identifiers in the capabilityID field. When one of the ML-KEM object identifiers appears in the capabilityID field, the parameters MUST NOT be present.

<!-- End of smime-capabilities-attribute-conventions section -->

<!-- End of use-in-cms section -->

# Identifiers {#sec-identifiers}

All identifiers used to indicate ML-KEM within the CMS are defined in [CSOR] and {{!RFC8619}} but reproduced here for convenience:

~~~
  nistAlgorithms OBJECT IDENTIFIER ::= { joint-iso-ccitt(2)
      country(16) us(840) organization(1) gov(101) csor(3)
      nistAlgorithm(4) }
  kems OBJECT IDENTIFIER ::= { nistAlgorithms 4 }

  id-alg-ml-kem-512 OBJECT IDENTIFIER ::= { kems 1 }

  id-alg-ml-kem-768 OBJECT IDENTIFIER ::= { kems 2 }

  id-alg-ml-kem-1024 OBJECT IDENTIFIER ::= { kems 3 }

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

For ongoing discussions of ML-KEM-specific security considerations, refer to {{?I-D.sfluhrer-cfrg-ml-kem-security-considerations}}.

Implementations MUST protect the ML-KEM private key, the key-encryption key, the content-encryption key, message-authentication key, and the content-authenticated-encryption key. Of these keys, all but the private key are ephemeral and MUST be wiped after use. Disclosure of the ML-KEM private key could result in the compromise of all messages protected with that key. Disclosure of the key-encryption key, the content-encryption key, or the content-authenticated-encryption key could result in compromise of the associated encrypted content. Disclosure of the key-encryption key, the message-authentication key, or the content-authenticated-encryption key could allow modification of the associated authenticated content.

Additional considerations related to key management may be found in {{?NIST.SP.800-57pt1r5}}.

The generation of private keys relies on random numbers, as does the encapsulation function of ML-KEM.  The use of inadequate pseudo-random number generators (PRNGs) to generate these values can result in little or no security.  In the case of key generation, a random 32-byte seed is used to deterministically derive the key (with an additional 32 bytes reserved as a rejection value). In the case of encapsulation, a KEM is derived from the underlying ML-KEM public key encryption algorithm by deterministically encrypting a random 32-byte message for the public key.  If the random value is weakly-chosen, then an attacker may find it much easier to reproduce the PRNG environment that produced the keys or ciphertext, searching the resulting small set of possibilities for a matching public key or ciphertext value, rather than performing a more complex algorithmic attack against ML-KEM.  The generation of quality random numbers is difficult; see Section 3.3 of {{FIPS203}} for some additional information.

ML-KEM encapsulation and decapsulation only outputs a shared secret and ciphertext. Implementations MUST NOT use intermediate values directly for any purpose.

Implementations SHOULD NOT reveal information about intermediate values or calculations, whether by timing or other "side channels", otherwise an opponent may be able to determine information about the keying data and/or the recipient's private key. Although not all intermediate information may be useful to an opponent, it is preferable to conceal as much information as is practical, unless analysis specifically indicates that the information would not be useful to an opponent.

Generally, good cryptographic practice employs a given ML-KEM key pair in only one scheme. This practice avoids the risk that vulnerability in one scheme may compromise the security of the other, and may be essential to maintain provable security.

Parties can gain assurance that implementations are correct through formal implementation validation, such as the NIST Cryptographic Module Validation Program (CMVP) {{CMVP}}.

<!-- End of security-considerations section -->

# IANA Considerations {#sec-iana-considerations}

For the ASN.1 Module in {{asn1}}, IANA is requested to assign an object identifier (OID) for the module identifier (TBD1) with a Description of "id-mod-cms-ml-kem-2024". The OID for the module should be allocated in the "SMI Security for S/MIME Module Identifier" registry (1.2.840.113549.1.9.16.0).

<!-- End of iana-considerations section -->

# Acknowledgements {#sec-acknowledgements}

This document borrows heavily from {{?RFC9690}}, {{FIPS203}}, and {{?I-D.kampanakis-ml-kem-ikev2}}. Thanks go to the authors of those documents. "Copying always makes things easier and less error prone" - RFC8411.

Thanks to Carl Wallace, Jonathan Hammel, and Sean Turner for the detailed review and Carl Wallace and Philippe Cece for interoperability testing for the examples.

<!-- End of acknowledgements section -->

--- back

# ASN.1 Module {#asn1}

This appendix includes the ASN.1 module {{X680}} for ML-KEM. This module imports objects from {{RFC5911}}, {{RFC9629}}, {{RFC8619}}, {{I-D.ietf-lamps-kyber-certificates}}.

~~~
<CODE BEGINS>
{::include CMS-KYBER-2024.asn}
<CODE ENDS>
~~~

# Parameter Set Security and Sizes {#arnold}

Instead of defining the strength of a quantum algorithm in a traditional
manner using the imprecise notion of bits of security, NIST has
defined security levels by picking a reference scheme, which
NIST expects to offer notable levels of resistance to both quantum and
classical attack.  To wit, a KEM algorithm that achieves NIST PQC
security must require computational resources to break IND-CCA2
security comparable or greater than that required for key search
on AES-128, AES-192, and AES-256 for Levels 1, 3, and 5, respectively.
Levels 2 and 4 use collision search for SHA-256 and SHA-384 as reference.

| Parameter Set | Level | Encap. Key Size | Decap. Key Size | Ciphertext Size | Shared Secret Size |
|-              |-      |-                |-                |-                |-                   |
| ML-KEM-512    | 1     | 800             | 1632            | 768             | 32                 |
| ML-KEM-768    | 3     | 1184            | 2400            | 1088            | 32                 |
| ML-KEM-1024   | 5     | 1568            | 3168            | 1568            | 32                 |
{: #tab-strengths title="ML-KEM parameter sets, NIST Security Level, and sizes in bytes"}

# ML-KEM CMS Authenticated-Enveloped-Data Example {#example}

This example shows the establishment of an AES-128 content-encryption
key using:

*  ML-KEM-512;

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

Alice generates a shared secret and ciphertext using Bob's ML-KEM-512 public key:

Shared secret:

~~~
{::include ./example/shared_secret.txt}
~~~

Ciphertext:

~~~
{::include ./example/ciphertext.txt}
~~~

Alice encodes the CMSORIforKEMOtherInfo:

~~~
{::include ./example/ori_info.txt}
~~~

Alice derives the key-encryption key from the shared secret and CMSORIforKEMOtherInfo using HKDF with SHA-256:

~~~
{::include ./example/kek.txt}
~~~

Alice randomly generates a 128-bit content-encryption key:

~~~
{::include ./example/cek.txt}
~~~

Alice uses AES-128-KEYWRAP to encrypt the content-encryption key with the key-encryption key:

~~~
{::include ./example/encrypted_cek.txt}
~~~

Alice encrypts the padded content using AES-128-GCM with the content-encryption key and encodes the AuthEnvelopedData (using KEMRecipientInfo) and ContentInfo, and then sends the result to Bob.

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
{::include ./example/ML-KEM-512-seed.priv}
~~~

Bob decapsulates the ciphertext in the KEMRecipientInfo to get the ML-KEM-512 shared secret, encodes the CMSORIforKEMOtherInfo, derives the key-encryption key from the shared secret and the DER-encoded CMSORIforKEMOtherInfo using HKDF with SHA-256, uses AES-128-KEYWRAP to decrypt the content-encryption key with the key-encryption key, and decrypts the encrypted contents with the content-encryption key, revealing the plaintext content:

~~~
{::include ./example/decrypted.txt}
~~~
