# Random Number Generator Smart Contract

A secure and feature-rich random number generator implemented as a Clarity smart contract for the Stacks blockchain. This contract provides various random number generation capabilities with built-in security measures, administrative controls, and usage monitoring.

## Features

### Core Functionality
- Generate single random numbers
- Generate random numbers within a specified range
- Generate random sequences
- Generate percentage values (0-100)
- Entropy pool management
- Historical tracking of generated numbers

### Security Measures
- Address restriction system
- Generation cooldown periods
- Minimum entropy threshold requirements
- Owner-only administrative functions
- Maintenance mode for emergency stops
- Usage monitoring and statistics

## Constants

### System Limits
- Maximum sequence length: 100
- Minimum entropy threshold: 10
- Generation cooldown period: 10 blocks
- Maximum random range: 1,000,000
- Maximum entropy input: 1,000,000

### Error Codes
- `u100`: Unauthorized access
- `u101`: Invalid range bounds
- `u102`: Zero seed value
- `u103`: Invalid generation parameters
- `u104`: Random sequence overflow
- `u105`: Sequence length exceeded
- `u106`: Generation cooldown active
- `u107`: Address blacklisted
- `u108`: Insufficient entropy pool
- `u109`: System maintenance mode
- `u110`: Metrics storage failed
- `u111`: Malformed address
- `u112`: Entropy value out of bounds

## Public Functions

### Random Number Generation
```clarity
(generate-random-number)
(generate-random-range (min-value uint) (max-value uint))
(generate-random-sequence (sequence-size uint))
(generate-percentage)
```

### Administrative Functions
```clarity
(toggle-maintenance-mode)
(restrict-address (target-address principal))
(remove-address-restriction (target-address principal))
(add-entropy-to-pool (entropy-input uint))
```

### Read-Only Functions
```clarity
(get-current-random-number)
(get-generation-count)
(get-contract-status)
(get-user-total-generations (user-address principal))
(check-address-restrictions (target-address principal))
```

## Usage Examples

### Generate a Random Number
```clarity
(contract-call? .random-number-generator generate-random-number)
```

### Generate a Random Number in Range
```clarity
;; Generate a random number between 1 and 100
(contract-call? .random-number-generator generate-random-range u1 u100)
```

### Generate a Random Sequence
```clarity
;; Generate a sequence of 5 random numbers
(contract-call? .random-number-generator generate-random-sequence u5)
```

### Generate a Percentage
```clarity
(contract-call? .random-number-generator generate-percentage)
```

## Security Considerations

1. **Entropy Management**: The contract maintains an entropy pool that must be above the minimum threshold for generation to work. Users can contribute to the entropy pool using `add-entropy-to-pool`.

2. **Cooldown Periods**: To prevent abuse, there's a mandatory cooldown period between generations.

3. **Address Restrictions**: Contract owner can restrict malicious addresses from using the generator.

4. **Maintenance Mode**: Contract can be paused by the owner in case of emergencies.

## State Management

The contract maintains several state variables:
- Current random number
- Generation count
- Cryptographic seed
- Available entropy
- Maintenance mode status
- Last generation timestamp
- Total random generations
- User generation statistics
- Historical random numbers

## Implementation Notes

1. The random number generation uses a combination of:
   - Block height
   - Previous generation count
   - Available entropy
   - Cryptographic seed
   
2. All generated numbers are stored in the historical records for transparency.

3. User statistics are automatically updated with each generation.

## Owner Responsibilities

The contract owner should:
1. Monitor the entropy pool levels
2. Manage address restrictions as needed
3. Toggle maintenance mode during emergencies
4. Monitor usage patterns for potential abuse

## Limitations

1. Maximum sequence length is capped at 100 numbers
2. Random range generation is limited to a maximum range of 1,000,000
3. Entropy contributions are capped at 1,000,000 per transaction
4. Generation requires waiting for the cooldown period between requests