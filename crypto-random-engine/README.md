# Stacks-Optimized Random Number Generator Smart Contract

A secure and gas-optimized random number generator implemented as a Clarity smart contract for the Stacks blockchain. This contract provides various random number generation capabilities with built-in security measures, administrative controls, and a commit-reveal scheme for enhanced randomness.

## Features

### Core Functionality
- Generate single random numbers
- Generate random numbers within a specified range
- Generate random sequences
- Commit-reveal scheme for user-provided randomness
- Entropy mixing with block hashes

### Security Measures
- Address restriction system
- Generation cooldown periods
- Owner-only administrative functions
- Maintenance mode for emergency stops
- Commit-reveal timeout

## Constants

### System Limits
- Maximum sequence length: 50
- Generation cooldown period: 3 blocks
- Maximum random range: 1,000,000
- Commit-reveal timeout: 144 blocks (~24 hours)

### Error Codes
- `u100`: Unauthorized access (owner only)
- `u101`: Invalid range bounds
- `u102`: Invalid parameters
- `u103`: Sequence overflow
- `u104`: Generation cooldown active
- `u105`: Address blacklisted
- `u106`: Low entropy
- `u107`: System maintenance mode
- `u108`: Commit-reveal timeout
- `u109`: Invalid reveal
- `u110`: Invalid commitment
- `u111`: Invalid address

## Public Functions

### Random Number Generation
```clarity
(get-random)
(get-random-range (min-value uint) (max-value uint))
(get-random-sequence (size uint))
Thought for 3 secondsTo provide an updated README for this smart contract, I'll use a Markdown code block. This will allow for proper formatting of the documentation, including headers, code snippets, and lists.

```markdown
# Stacks-Optimized Random Number Generator Smart Contract

A secure and gas-optimized random number generator implemented as a Clarity smart contract for the Stacks blockchain. This contract provides various random number generation capabilities with built-in security measures, administrative controls, and a commit-reveal scheme for enhanced randomness.

## Features

### Core Functionality
- Generate single random numbers
- Generate random numbers within a specified range
- Generate random sequences
- Commit-reveal scheme for user-provided randomness
- Entropy mixing with block hashes

### Security Measures
- Address restriction system
- Generation cooldown periods
- Owner-only administrative functions
- Maintenance mode for emergency stops
- Commit-reveal timeout

## Constants

### System Limits
- Maximum sequence length: 50
- Generation cooldown period: 3 blocks
- Maximum random range: 1,000,000
- Commit-reveal timeout: 144 blocks (~24 hours)

### Error Codes
- `u100`: Unauthorized access (owner only)
- `u101`: Invalid range bounds
- `u102`: Invalid parameters
- `u103`: Sequence overflow
- `u104`: Generation cooldown active
- `u105`: Address blacklisted
- `u106`: Low entropy
- `u107`: System maintenance mode
- `u108`: Commit-reveal timeout
- `u109`: Invalid reveal
- `u110`: Invalid commitment
- `u111`: Invalid address

## Public Functions

### Random Number Generation
```
(get-random)
(get-random-range (min-value uint) (max-value uint))
(get-random-sequence (size uint))
```

### Commit-Reveal Scheme

```
(commit-random (commitment (buff 32)))
(reveal-random (random-value (buff 32)))
```

### Administrative Functions

```
(set-maintenance-mode (mode bool))
(add-restricted-address (address principal))
(remove-restricted-address (address principal))
```

### Read-Only Functions

```
(get-last-random)
(get-commitment (user principal))
(is-restricted (address principal))
```

## Usage Examples

### Generate a Random Number

```
(contract-call? .random-number-generator get-random)
```

### Generate a Random Number in Range

```
;; Generate a random number between 1 and 100
(contract-call? .random-number-generator get-random-range u1 u100)
```

### Generate a Random Sequence

```
;; Generate a sequence of 5 random numbers
(contract-call? .random-number-generator get-random-sequence u5)
```

### Commit-Reveal Process

```
;; Step 1: Commit a hash of your random value
(contract-call? .random-number-generator commit-random (sha256 0x1234...))

;; Step 2: Reveal your random value (must be done within 144 blocks)
(contract-call? .random-number-generator reveal-random 0x1234...)
```

## Security Considerations

1. **Commit-Reveal Scheme**: Enhances randomness by allowing users to contribute their own random values.
2. **Cooldown Periods**: Prevents rapid consecutive generations to mitigate potential exploits.
3. **Address Restrictions**: Contract owner can restrict malicious addresses from using the generator.
4. **Maintenance Mode**: Contract can be paused by the owner in case of emergencies.
5. **VRF Approach**: Uses a Verifiable Random Function approach for generating random numbers.


## State Management

The contract maintains several state variables:

- Last generated random number
- Current cryptographic seed
- Last block of generation
- Commitments map for the commit-reveal scheme
- Restricted addresses map
- Generation statistics map


## Implementation Notes

1. The random number generation uses a combination of:

. User-provided randomness (via commit-reveal)
. Block hashes
. Previous seed

2. The contract is optimized for gas efficiency, with reduced sequence length and cooldown period.
3. A zero buffer is used for initialization and validation.


## Owner Responsibilities

The contract owner should:

1. Manage address restrictions as needed
2. Toggle maintenance mode during emergencies
3. Monitor usage patterns for potential abuse


## Limitations

1. Maximum sequence length is capped at 50 numbers
2. Random range generation is limited to a maximum range of 1,000,000
3. Commit-reveal process must be completed within 144 blocks (~24 hours)
4. Generation requires waiting for a 3-block cooldown period between requests


```
This updated README reflects the changes in the new smart contract implementation
```