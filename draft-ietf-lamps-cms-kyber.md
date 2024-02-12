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

stand_alone: true
ipr: trust200902
area: Security
workgroup: LAMPS
keyword:
 - Key Encapsulation Mechanism (KEM)
 - KEMRecipientInfo
 - ML-KEM
 - Kyber
submissionType: IETF
category: std
venue:
  group: "Limited Additional Mechanisms for PKIX and SMIME (lamps)"
  type: "Working Group"
  mail: "spasm@ietf.org"
  arch: "https://mailarchive.ietf.org/arch/browse/spasm/"
  github: "https://github.com/JulienPrat/draft-ietf-lamps-cms-kyber"

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
      email: daniel.vangeest.ietf@gmail.com


normative:
  FIPS203:
      title: TBD
  FIPS203-ipd:
      title: "Module-Lattice-based Key-Encapsulation Mechanism Standard"
      date: 2023-08-24
      target: https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.203.ipd.pdf
      author:
        org: National Institute of Standards and Technology (NIST)

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

The Module-Lattice-based Key-Encapsulation Mechanism (ML-KEM) Algorithm is a one-pass (store-and-forward) cryptographic mechanism for an originator to securely send keying material to a recipient using the recipient's ML-KEM public key. Three parameters sets for the ML-KEM Algorithm is specified by NIST in {{FIPS203-ipd}} \[EDNOTE: Change to {{FIPS203}} when it is published\]. In order of increasing security strength (and decreasing performance), these parameter sets are ML-KEM-512, ML-KEM-768, and ML-KEM-1024. This document specifies the conventions for using ML-KEM with the Cryptographic Message Syntax (CMS) using KEMRecipientInfo as specified in {{!I-D.ietf-lamps-cms-kemri}}.

<!-- End of Abstract -->

--- middle


# Introduction {#sec-introduction}

ML-KEM is an IND-CCA2-secure key-encapsulation mechanism (KEM) standardized in {{FIPS203}} by the US NIST PQC Project {{NIST-PQ}}.

{{!I-D.ietf-lamps-cms-kemri}} defines the KEMRecipientInfo structure for the use of KEM algorithms for the CMS enveloped-data content type, the CMS authenticated-data content type, and the CMS authenticated-enveloped-data content type. This document specifies the use of ML-KEM in the KEMRecipientInfo structure in CMS at three security levels: MK-KEM-512, ML-KEM-768, ML-KEM-1024.

## KEMs {#sec-intro-kems}

All KEM algorithms provides three functions: KeyGen(), Encapsulate(), and Decapsulate():

KeyGen() -> (pk, sk):

> Generate the public key (pk) and a private key (sk).

Encapsulate(pk) -> (ct, ss):

> Given the recipient's public key (pk), produce a ciphertext (ct) to be passed to the recipient and a shared secret (ss) for use by the originator.

Decapsulate(sk, ct) -> ss:

> Given the private key (sk) and the ciphertext (ct), produce the shared secret (ss) for the recipient.

The main security property for KEMs standardized in the NIST Post-Quantum Cryptography Standardization Project {{NIST-PQ}} is indistinguishability under adaptive chosen ciphertext attacks (IND-CCA2), which means that shared secret values should be indistinguishable from random strings even given the ability to have arbitrary ciphertexts decapsulated. IND-CCA2 corresponds to security against an active attacker, and the public key / secret key pair can be treated as a long-term key or reused. A weaker security notion is indistinguishability under chosen plaintext attacks (IND-CPA), which means that the shared secret values should be indistinguishable from random strings given a copy of the public key. IND-CPA roughly corresponds to security against a passive attacker, and sometimes corresponds to one-time key exchange.

<!-- End of KEMs section -->

## ML-KEM {#sec-intro-ml-kem}

ML-KEM is a recently standardized lattice-based key encapsulation mechanism defined in {{FIPS203}}.
\[EDNOTE: Not actually standardized yet, but will be by publication]

ML-KEM is using Module Learning with Errors as its underlying primitive which is a structured lattices variant that offers good performance and relatively small and balanced key and ciphertext sizes. ML-KEM was standardized with three parameters, ML-KEM-512, ML-KEM-768, and ML-KEM-1024. These were mapped by NIST to the three security levels defined in the NIST PQC Project, Level 1, 3, and 5. These levels correspond to the hardness of breaking AES-128, AES-192 and AES-256 respectively.

The KEM functions defined above correspond to the following functions in {{FIPS203}}:

> KeyGen(): ML-KEM.KeyGen() from section 6.1.

> Encapsulate(): ML-KEM.Encaps() from section 6.2.

> Decapsulate(): ML-KEM.Decaps() from section 6.3.

All security levels of ML-KEM use SHA3-256, SHA3-512, SHAKE256, and SHAKE512 internally. This informs the choice of KDF within this document.

<!-- End of ML-KEM section -->

## CMS KEMRecipientInfo Processing Summary {#sec-intro-kemri}

To support the ML-KEM algorithm, the CMS originator MUST implement Encapsulate().

Given a content-encryption key CEK, the ML-KEM Algorithm processing by the originator to produce the values that are carried in the CMS KEMRecipientInfo can be summarized as:

>
1\. Obtain the shared secret using the Encapsulate() function of the ML-KEM algorithm and the recipient's ML-KEM public key:

~~~
       (ct, ss) = Encapsulate(pk)
~~~

>
2\. Derive a key-encryption key KEK from the shared secret:

~~~
       KEK = KDF(ss)
~~~

>
3\. Wrap the CEK with the KEK to obtain wrapped keying material WK:

~~~
       WK = WRAP(KEK, CEK)
~~~

>
4\. The originator sends the ciphertext and WK to the recipient in the CMS KEMRecipientInfo structure.

To support the ML-KEM algorithm, the CMS recipient MUST implement Decapsulate().

The ML-KEM algorithm recipient processing of the values obtained from the KEMRecipientInfo structure can be summarized as:

>
1\. Obtain the shared secret using the Decapsulate() function of the
RSA-KEM algorithm and the recipient's ML-KEM private key:

~~~
       ss = Decapsulate(sk, ct)
~~~

>
2\. Derive a key-encryption key KEK from the shared secret:

~~~
       KEK = KDF(ss)
~~~

>
3\. Unwrap the WK with the KEK to obtain content-encryption key CEK:

~~~
       CEK = UNWRAP(KEK, WK)
~~~

Note that the KDF used to process the KEMRecipientInfo structure MAY be different from the KDF used in the ML-KEM algorithm.

<!-- End of processing-summary section -->

## Conventions and Terminology {#sec-intro-terminology}

{::boilerplate bcp14-tagged}

<!-- End of terminology section -->

<!-- End of introduction section -->

# Use of the ML-KEM Algorithm in CMS {#sec-using}

The ML-KEM Algorithm MAY be employed for one or more recipients in the CMS enveloped-data content type {{!RFC5652}}, the CMS authenticated-data content type {{!RFC5652}}, or the CMS authenticated-enveloped-data content type {{!RFC5083}}. In each case, the KEMRecipientInfo {{!I-D.ietf-lamps-cms-kemri}} is used with with the ML-KEM Algorithm to securely transfer the content-encryption key from the originator to the recipient.

## RecipientInfo Conventions {#sec-using-recipientInfo}

When the ML-KEM Algorithm is employed for a recipient, the RecipientInfo alternative for that recipient MUST be OtherRecipientInfo using the KEMRecipientInfo structure as defined in {{!I-D.ietf-lamps-cms-kemri}}.
The fields of the KEMRecipientInfo MUST have the following values:

> version is the syntax version number; it MUST be 0.

> rid identifies the recipient's certificate or public key.

> kem identifies the KEM algorithm ; For ML-KEM-512 it MUST contain id-ML-KEM-512, for ML-KEM-768 it MUST contain id-ML-KEM-768, for ML-KEM-1024 it MUST contain id-ML-KEM-1024. These identifiers are reproduced in {{sec-identifiers}}.

> kemct is the ciphertext produced for this recipient.

> kdf identifies the key-derivation algorithm. Note that the KDF used for CMS RecipientInfo process MAY be different than the KDF used within the ML-KEM Algorithm.

> kekLength is the size of the key-encryption key in octets.

> ukm is an optional random input to the key-derivation function. ML-KEM doesn't place any requirements on the ukm contents.

> wrap identifies a key wrapping algorithm used to encrypt the content-encryption key.

<!-- End of recipientinfo conventions section -->

## Underlying Components {#sec-using-components}

When ML-KEM is employed in CMS, the security levels of the different underlying components used within the KEMRecipientInfo structure should be consistent.

\[EDNOTE: if we get OIDs for KMAC-based KDFs, use those. If we don't, do we want to use KDF3 with SHA3 <!--{{!ANS-X9.44=ANSI.X9-44.1993}}--> instead? ]

For ML-KEM-512, the following underlying components MUST be supported:

> KDF: id-alg-hkdf-with-sha3-256 {{!I-D.ietf-lamps-cms-sha3-hash}}

> Key wrapping: id-aes128-wrap {{!RFC3565}}

For ML-KEM-768, the following underlying components MUST be supported:

> KDF: id-alg-hkdf-with-sha3-384 {{!I-D.ietf-lamps-cms-sha3-hash}}

> Key wrapping: id-aes256-wrap {{!RFC3565}}

For ML-KEM-1024, the following underlying components MUST be supported:

> KDF: id-alg-hkdf-with-sha3-512 {{!I-D.ietf-lamps-cms-sha3-hash}}

> Key wrapping: id-aes256-wrap {{!RFC3565}}

The above object identifiers are reproduced for convenience in {{sec-identifiers}}.

An implementation MAY also support other key-derivation functions and other key-encryption algorithms as well.

If underlying components other than those specified above are used, then:

> ML-KEM-512 SHOULD be used with a KDF capable of outputting a key with at least 128 bits of security and with a key wrapping algorithm with a key length of at least 128 bits.

> ML-KEM-768 SHOULD be used with a KDF capable of outputting a key with at least 192 bits of security and with a key wrapping algorithm with a key length of at least 192 bits.

> ML-KEM-1024 SHOULD be used with a KDF capable of outputting a key with at least 256 bits of security and with a key wrapping algorithm with a key length of at least 256 bits.

<!-- End of Underlying Components section -->

## Certificate Conventions {#sec-using-certs}

The conventions specified in this section augment {{!RFC5280}}.

A recipient who employs the ML-KEM Algorithm with a certificate MUST identify the public key in the certificate using the id-ML-KEM-512, id-ML-KEM-768, or id-ML-KEM-1024 object identifiers following the conventions specified in {{!I-D.ietf-lamps-kyber-certificates}} and reproduced in {{sec-identifiers}}.

In particular, the key usage certificate extension MUST only contain keyEncipherment (Section 4.2.1.3 of {{!RFC5280}}).

A key intended to be employed with KEMRecipientInfo SHOULD NOT also be employed for any other purpose. Good cryptographic practice employs a given key pair in only one scheme. This practice avoids the risk that vulnerability in one scheme may compromise the security of the other, and may be essential to maintain provable security.

## SMIME Capabilities Attribute Conventions {#sec-using-smime-caps}

Section 2.5.2 of {{!RFC8551}} defines the SMIMECapabilities attribute to announce a partial list of algorithms that an S/MIME implementation can support. When constructing a CMS signed-data content type {{!RFC5652}}, a compliant implementation MAY include the SMIMECapabilities attribute that announces support for one or more of the ML-KEM Algorithm identifiers.

The SMIMECapability SEQUENCE representing the ML-KEM Algorithm MUST include one of the ML-KEM object identifiers in the capabilityID field. When the one of the ML-KEM object identifiers appear in the capabilityID field, the parameters MUST NOT be present.

<!-- End of smime-capabilities-attribute-conventions section -->

<!-- End of use-in-cms section -->

# Identifiers {#sec-identifiers}

All identifiers used by ML-KEM in CMS are defined elsewhere but reproduced here for convenience:

      id-TBD-NIST-KEM OBJECT IDENTIFIER ::= { TBD }

      id-ML-KEM-512 OBJECT IDENTIFIER ::= { id-TBD-NIST-KEM TBD }
      id-ML-KEM-768 OBJECT IDENTIFIER ::= { id-TBD-NIST-KEM TBD }
      id-ML-KEM-1024 OBJECT IDENTIFIER ::= { id-TBD-NIST-KEM TBD }

      id-alg OBJECT IDENTIFIER ::= { iso(1) member-body(2)
               us(840) rsadsi(113549) pkcs(1) pkcs-9(9) smime(16) 3 }

      id-alg-hkdf-with-sha3-256 OBJECT IDENTIFIER ::= { id-alg TBD }
      id-alg-hkdf-with-sha3-384 OBJECT IDENTIFIER ::= { id-alg TBD }
      id-alg-hkdf-with-sha3-512 OBJECT IDENTIFIER ::= { id-alg TBD }

      aes OBJECT IDENTIFIER ::= { joint-iso-itu-t(2) country(16) us(840)
               organization(1) gov(101) csor(3)_ nistAlgorithms(4) 1 }

      id-aes128-wrap OBJECT IDENTIFIER ::= { aes 5 }
      id-aes256-wrap OBJECT IDENTIFIER ::= { aes 45 }

# Security Considerations {#sec-security-considerations}

The Security Considerations section of {{!I-D.ietf-lamps-kyber-certificates}} applies to this specification as well.

The ML-KEM variant and the underlying components need to be selected consistent with the desired security level. Several security levels have been identified in the NIST SP 800-57 Part 1 {{?NIST.SP.800-57pt1r5}}. To achieve 128-bit security, ML-KEM-512 SHOULD be used, the key-derivation function SHOULD make use of SHA3-256, and the symmetric key-encryption algorithm SHOULD be AES Key Wrap with a 128-bit key. To achieve 192-bit security, ML-KEM-768 SHOULD be used, the key-derivation function SHOULD make use of SHA3-384, and the symmetric key-encryption algorithm SHOULD be AES Key Wrap with a 192-bit key or larger. In this case AES Key Wrap with a 256-bit key is typically used because AES-192 is not as commonly deployed. To achieve 256-bit security, ML-KEM-1024 SHOULD be used, the key-derivation function SHOULD make use of SHA3-512, and the symmetric key-encryption algorithm SHOULD be AES Key Wrap with a 256-bit key.

Provided all inputs are well-formed, the key establishment procedure of ML-KEM will never explicitly fail. Specifically, the ML-KEM.Encaps and ML-KEM.Decaps algorithms from {{FIPS203}} will always output a value with the same data type as a shared secret key, and will never output an error or failure symbol. However, it is possible (though extremely unlikely) that the process will fail in the sense that ML-KEM.Encaps and ML-KEM.Decaps will produce different outputs, even though both of them are behaving honestly and no adversarial interference is present. In this case, the sender and recipient clearly did not succeed in producing a shared
secret key. This event is called a decapsulation failure. Estimates for the decapsulation failure probability (or rate) for each of the ML-KEM parameter sets are given here:

~~~
+--------------+----------------------------+
|Parameter set | Decapsulation failure rate |
+--------------+----------------------------+
| ML-KEM-512   | 2^(−139)                   |
| ML-KEM-768   | 2^(−164)                   |
| ML-KEM-1024  | 2^(−174)                   |
+--------------+----------------------------+
~~~

Implementations MUST protect the ML-KEM private key, the key-encryption key, the content-encryption key, message-authentication key, and the content-authenticated-encryption key. Disclosure of the ML-KEM private key could result in the compromise of all messages protected with that key. Disclosure of the key-encryption key, the content- encryption key, or the content-authenticated-encryption key could result in compromise of the associated encrypted content. Disclosure of the key-encryption key, the message-authentication key, or the content-authenticated-encryption key could allow modification of the associated authenticated content.

Additional considerations related to key management may be found in {{?NIST.SP.800-57pt1r5}}.

The security of the ML-KEM Algorithm depends on a quality random number generator. For further discussion on random number generation, see {{?RFC4086}}.

ML-KEM encapsulation and decapsulation only outputs a shared secret and ciphertext. Implementations SHOULD NOT use intermediate values directly for any purpose.

Implementations SHOULD NOT reveal information about intermediate values or calculations, whether by timing or other "side channels", otherwise an opponent may be able to determine information about the keying data and/or the recipient's private key. Although not all intermediate information may be useful to an opponent, it is preferable to conceal as much information as is practical, unless analysis specifically indicates that the information would not be useful to an opponent.

Generally, good cryptographic practice employs a given ML-KEM key pair in only one scheme. This practice avoids the risk that vulnerability in one scheme may compromise the security of the other, and may be essential to maintain provable security.

Parties MAY gain assurance that implementations are correct through formal implementation validation, such as the NIST Cryptographic Module Validation Program (CMVP) {{CMVP}}.

<!-- End of security-considerations section -->

# IANA Considerations {#sec-iana-considerations}

Within the CMS, algorithms are identified by object identifiers (OIDs). All of the OIDs used in this document were assigned in other IETF documents, in ISO/IEC standards documents, by the National Institute of Standards and Technology (NIST).

<!-- End of iana-considerations section -->

# Acknowledgements {#sec-acknowledgements}

This document borrows heavily from {{?I-D.ietf-lamps-rfc5990bis}}, {{FIPS203}}, and {{?I-D.kampanakis-ml-kem-ikev2}}. Thanks go to the authors of those documents. "Copying always makes things easier and less error prone" - RFC8411.

<!-- End of acknowledgements section -->

--- back

# ASN.1 Module

\[EDNOTE: Do we need an ASN.1 module? We haven't defined any new ASN.1]

## Examples

~~~
EDITOR'S NOTE' - TODO
section to be completed
~~~

# Revision History {#sec-version-changes}

\[EDNOTE: remove before publishing\]

- draft-ietf-lamps-cms-kyber-02:
   - Rearrange and rewrite to align with rfc5990bis and I-D.ietf-lamps-cms-kemri
   - Move Revision History to end to avoid renumbering later
   - Add Security Considerations
- draft-ietf-lamps-cms-kyber-01:
   - Details of the KEMRecipientInfo content when using Kyber;
   - Editorial changes.
- draft-ietf-lamps-cms-kyber-00:
   - Use of KEMRecipientInfo to communicate algorithm info;
   - Editorial changes.
