# Elan8 domain and method libraries — licence and provenance

The `spec42` binary in this package has two Elan8 SysML v2 library bundles compiled
into it by the `embed-kpar-libraries` cargo feature. Neither source repository
contains a `LICENSE` file, and neither states terms in its `README.md`, so this file
records the licence grant that the distributed archives themselves declare.

## Domain libraries

Fetched from
<https://github.com/elan8/sysml-domain-libraries/releases/download/v0.3.0/elan8-domain-libraries-0.3.0.kpar>
(sha256 `af457fb32a158a38c0a7513a0bf2397b99659bafcb8e3e5d735f491e8de09735`).

Its `.project.json` declares, verbatim:

```json
{
  "name": "elan8-domain-libraries",
  "version": "0.3.0",
  "description": "Elan8 SysML v2 domain libraries",
  "license": "MIT",
  "publisher": "elan8"
}
```

## Method libraries

Fetched from
<https://github.com/elan8/mbse-methodology/releases/download/v0.2.0/elan8-method-libraries-0.2.0.kpar>
(sha256 `31b9a04d53f4ebd7e4a48f1ee1f45b25586d9bebb536cc807915b6e6442882c9`).

Its `.project.json` declares, verbatim:

```json
{
  "name": "elan8-method-libraries",
  "version": "0.2.0",
  "description": "Elan8 SysML v2 domain libraries",
  "license": "MIT",
  "publisher": "elan8"
}
```

## Terms

Both bundles declare `MIT` with `elan8` as publisher — the same licence and the same
copyright holder as spec42 itself, whose `LICENSE` file in this package reads
`Copyright (c) 2026 Elan8`. That MIT text therefore states the terms for these
bundles as well, and is not duplicated here.

No copyright year is asserted for the bundles independently, because neither the
archives nor their source repositories state one.
