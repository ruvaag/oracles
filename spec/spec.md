# Oracles: A Common Use Specification

## Abstract

The following standard allows for the implementation of a standard API for data feeds providing the relative value of
assets in the Ethereum and EVM-compatible blockchains.

## Motivation

The information required to value assets is scattered over a number of major and minor sources, each one with their own
integration API and security considerations. Many protocols over the years have implemented oracle adapter layers for
their own use to abstract this complexity away from their core implementations, leading to much duplicated effort.

This specification provides a standard API aimed to serve the majority of use cases. Preference is given to ease of
integration and serving the needs of product teams with less knowledge, requirements and resources.

## Specification

### Definitions

- base asset: The asset that the user needs to know the value or price for (e.g: USDC as in "I need to know the value of
  1e6 USDC in ETH terms").
- quote asset: The asset in which the user needs to value or price the `base` (e.g: ETH as in "I need to know the value
  of 1e6 USDC in ETH terms").
- unit: Minimum representable amount of an asset on-chain.
- decimals: The number of positions to move the comma to the left to make a `whole unit` out of a unit (e.g. USDC has 6
  `decimals`).
- scalar: 10 to the power of `decimals` (e.g. USDC's `scalar` is 1e6).
- whole unit: A `scalar` amount of `unit` (e.g. A `whole unit` of USDC is 1e6 `units`).
- value: An amount of `base` in `quote` terms (e.g. The `value` of 1000e6 USDC in ETH terms is 283,969,794,427,307,000
  ETH, and the `value` of 1000e18 ETH in USDC terms is 3,521,501,299,000 USDC).
- price: The `value` of a `whole unit` of `base` in `quote` terms, multiplied by `10**18` and divided by the
  `quote scalar` (e.g. The `price` of USDC in ETH terms is 283,969,794,427,307, and the price of ETH in USDC terms is
  3,521,501,299,167,184,700,000).

### Methods

#### valueOf

Returns the value of `baseAmount` of `base` in `quote` terms.

MUST round down towards 0.

MUST revert with `OracleUnsupportedPair` if not capable to provide data for the specified `base` and `quote` pair.

MUST revert with `OracleUntrustedData` if not capable to provide data within a degree of confidence publicly specified.

```yaml
- name: valueOf
  type: function
  stateMutability: view

  inputs:
    - name: base
      type: address
    - name: quote
      type: address
    - name: baseAmount
      type: uint256

  outputs:
    - name: quoteAmount
      type: uint256
```

#### priceOf

Returns the value of one `whole unit` of `base` in `quote` terms, as a fixed point value with 18 decimals.

MUST round down towards 0.

MUST revert with `OracleUnsupportedPair` if not capable to provide data for the specified `base` and `quote` pair.

MUST revert with `OracleUntrustedData` if not capable to provide data within a degree of confidence publicly specified.

```yaml
- name: priceOf
  type: function
  stateMutability: view

  inputs:
    - name: base
      type: address
    - name: quote
      type: address

  outputs:
    - name: baseQuotePrice
      type: uint256
```

### Special Addresses

Some assets under the scope of this specification don't have an address, such as ETH, BTC and national currencies.

For ETH, ERC-7535 will be applied, using `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE` as its address.

For BTC, the address will be `0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB`.

For assets without an address, but with an ISO 4217 code, the code will be used (e.g. `address(840)` for USD).

### Events

There are no events defined in this specification

### Errors

#### OracleUnsupportedPair

```yaml
- name: OracleUnsupportedPair
  type: error

  inputs:
    - name: base
      type: address
    - name: quote
      type: address
```

#### OracleUntrustedData

```yaml
- name: OracleUntrustedData
  type: error

  inputs:
    - name: base
      type: address
    - name: quote
      type: address
```

### Rationale

The presence of a `decimals` field in assets is intended to ease the representation of large asset amounts by defining a
larger `whole unit`.

The use of `valueOf` doesn't require the consumer to be aware of the `decimals` of the `base` or `quote` and should be
preferred in most data processing cases.

The `priceOf` method provides a value which will be useful in situations where `whole units` are used, for example for
display purposes.

### Backwards Compatibility

Most existing data feeds related to the relative value of pairs of assets should be representable using this standard.

### Reference Implementation

TBA

### Security Considerations

This specification purposefully provides no methods for data consumers to assess the validity of the data they receive.
It is expected of individual implementations using this specification to decide and publish the quality of the data that
they provide, including the conditions in which they will stop providing it.

Consumers should review these guarantees and use them to decide whether to integrate or not with a data provider.

## Copyright

Copyright and related rights waived via [CC0](https://eips.ethereum.org/LICENSE).
