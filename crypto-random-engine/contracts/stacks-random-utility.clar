;; Random Number Generator Contract

;; Constants for contract ownership and error handling
(define-constant contract-owner tx-sender)
(define-constant ERROR_UNAUTHORIZED_ACCESS (err u100))
(define-constant ERROR_INVALID_RANGE_BOUNDS (err u101))
(define-constant ERROR_ZERO_SEED_VALUE (err u102))
(define-constant ERROR_INVALID_GENERATION_PARAMS (err u103))
(define-constant ERROR_RANDOM_SEQUENCE_OVERFLOW (err u104))
(define-constant ERROR_SEQUENCE_LENGTH_EXCEEDED (err u105))
(define-constant ERROR_GENERATION_COOLDOWN_ACTIVE (err u106))
(define-constant ERROR_ADDRESS_BLACKLISTED (err u107))
(define-constant ERROR_INSUFFICIENT_ENTROPY_POOL (err u108))
(define-constant ERROR_SYSTEM_MAINTENANCE_MODE (err u109))
(define-constant ERROR_METRICS_STORAGE_FAILED (err u110))
(define-constant ERROR_MALFORMED_ADDRESS (err u111))
(define-constant ERROR_ENTROPY_VALUE_OUT_OF_BOUNDS (err u112))

;; Response type definitions
(define-constant OPERATION_SUCCESS (ok true))

;; Configuration constants
(define-constant MAX_SEQUENCE_LENGTH u100)
(define-constant MIN_ENTROPY_THRESHOLD u10)
(define-constant GENERATION_COOLDOWN_PERIOD u10)
(define-constant MAX_RANDOM_RANGE u1000000)
(define-constant MAX_ENTROPY_INPUT u1000000)

;; Data variables for maintaining random number state
(define-data-var current-random-number uint u0)
(define-data-var generation-count uint u0)
(define-data-var cryptographic-seed uint u1)
(define-data-var available-entropy uint u0)
(define-data-var maintenance-mode bool false)
(define-data-var last-generation-timestamp uint u0)
(define-data-var total-random-generations uint u0)
(define-data-var consecutive-generation-count uint u0)

;; Maps for advanced features
(define-map restricted-addresses principal bool)
(define-map user-generation-stats principal uint)
(define-map historical-random-numbers uint uint)
(define-map generation-history-timestamps uint uint)

;; Read-only functions to access contract state
(define-read-only (get-current-random-number)
    (ok (var-get current-random-number))
)

(define-read-only (get-generation-count)
    (ok (var-get generation-count))
)

(define-read-only (get-contract-status)
    (ok {
        maintenance-active: (var-get maintenance-mode),
        total-numbers-generated: (var-get total-random-generations),
        current-entropy-level: (var-get available-entropy),
        last-generation-time: (var-get last-generation-timestamp)
    })
)

(define-read-only (get-user-total-generations (user-address principal))
    (ok (default-to u0 (map-get? user-generation-stats user-address)))
)

(define-read-only (check-address-restrictions (target-address principal))
    (ok (default-to false (map-get? restricted-addresses target-address)))
)

;; Private administrative functions
(define-private (verify-owner-access)
    (if (is-eq tx-sender contract-owner)
        OPERATION_SUCCESS
        ERROR_UNAUTHORIZED_ACCESS)
)

(define-private (validate-generation-conditions)
    (begin
        (asserts! (not (var-get maintenance-mode)) ERROR_SYSTEM_MAINTENANCE_MODE)
        (asserts! (not (default-to false (map-get? restricted-addresses tx-sender))) ERROR_ADDRESS_BLACKLISTED)
        (asserts! (>= (var-get available-entropy) MIN_ENTROPY_THRESHOLD) ERROR_INSUFFICIENT_ENTROPY_POOL)
        (asserts! (> block-height (+ (var-get last-generation-timestamp) GENERATION_COOLDOWN_PERIOD)) ERROR_GENERATION_COOLDOWN_ACTIVE)
        OPERATION_SUCCESS
    )
)

(define-private (compute-random-hash (input-value uint))
    (let (
        (combined-input (concat 
            (unwrap-panic (to-consensus-buff? (var-get generation-count)))
            (unwrap-panic (to-consensus-buff? (xor 
                (xor 
                    input-value
                    block-height
                )
                (var-get available-entropy)
            )))
        ))
        (hash-output (sha256 combined-input))
        (truncated-hash (match (slice? hash-output u0 u16)
                slice-output (ok (unwrap-panic (as-max-len? slice-output u16)))
                (err "Failed to slice buffer")))
    )
    (buff-to-uint-be (unwrap-panic truncated-hash))
    )
)

(define-private (update-generation-statistics) 
    (begin
        (var-set total-random-generations (+ (var-get total-random-generations) u1))
        (var-set last-generation-timestamp block-height)
        (map-set generation-history-timestamps (var-get total-random-generations) block-height)
        (map-set historical-random-numbers (var-get total-random-generations) (var-get current-random-number))
        (map-set user-generation-stats tx-sender 
            (+ (default-to u0 (map-get? user-generation-stats tx-sender)) u1))
        OPERATION_SUCCESS
    )
)

;; Public administrative functions
(define-public (toggle-maintenance-mode)
    (begin
        (try! (verify-owner-access))
        (ok (var-set maintenance-mode (not (var-get maintenance-mode))))
    )
)

(define-public (restrict-address (target-address principal))
    (begin
        (try! (verify-owner-access))
        (match (principal-destruct? target-address)
            success (ok (map-set restricted-addresses target-address true))
            error ERROR_MALFORMED_ADDRESS
        )
    )
)

(define-public (remove-address-restriction (target-address principal))
    (begin
        (try! (verify-owner-access))
        (match (principal-destruct? target-address)
            success (ok (map-delete restricted-addresses target-address))
            error ERROR_MALFORMED_ADDRESS
        )
    )
)

(define-public (add-entropy-to-pool (entropy-input uint))
    (begin
        (asserts! (<= entropy-input MAX_ENTROPY_INPUT) ERROR_ENTROPY_VALUE_OUT_OF_BOUNDS)
        (var-set available-entropy (+ (var-get available-entropy) entropy-input))
        OPERATION_SUCCESS
    )
)

;; Random number generation functions
(define-public (generate-random-number)
    (let
        ((prerequisites-check (validate-generation-conditions)))
        (match prerequisites-check
            success-response 
                (let
                    ((random-result (compute-random-hash (var-get cryptographic-seed))))
                    (begin
                        (var-set generation-count 
                            (+ (var-get generation-count) u1))
                        (var-set current-random-number random-result)
                        (var-set cryptographic-seed random-result)
                        (var-set available-entropy (- (var-get available-entropy) u1))
                        (ok random-result)))
            error-value (err error-value)
        )
    )
)

(define-public (generate-random-range (min-value uint) (max-value uint))
    (begin
        (asserts! (< min-value max-value) ERROR_INVALID_RANGE_BOUNDS)
        (asserts! (<= (- max-value min-value) MAX_RANDOM_RANGE) ERROR_INVALID_RANGE_BOUNDS)
        (let ((random-result (try! (generate-random-number))))
            (ok (+ min-value (mod random-result (- max-value min-value))))
        )
    )
)

(define-public (generate-random-sequence (sequence-size uint))
    (begin
        (asserts! (> sequence-size u0) ERROR_INVALID_GENERATION_PARAMS)
        (asserts! (<= sequence-size MAX_SEQUENCE_LENGTH) ERROR_SEQUENCE_LENGTH_EXCEEDED)
        (try! (validate-generation-conditions))
        (let 
            (
                (sequence-result (fold accumulate-sequence-numbers 
                    (list u1 u2 u3 u4 u5) 
                    {sequence: (list), count: u0, target-size: sequence-size}))
            )
            (ok (get sequence sequence-result))
        )
    )
)

(define-public (generate-percentage)
    (let ((random-result (try! (generate-random-number))))
        (ok (mod random-result u101))
    )
)

(define-private (accumulate-sequence-numbers (position uint) (state {sequence: (list 100 uint), count: uint, target-size: uint}))
    (let 
        (
            (random-result (unwrap-panic (generate-random-number)))
            (updated-sequence (unwrap! (as-max-len? (append (get sequence state) random-result) u100) state))
            (updated-count (+ (get count state) u1))
        )
        (if (< updated-count (get target-size state))
            {sequence: updated-sequence, count: updated-count, target-size: (get target-size state)}
            state
        )
    )
)

;; Contract initialization with default values
(begin
    (var-set current-random-number u1)
    (var-set generation-count u0)
    (var-set cryptographic-seed u1)
    (var-set available-entropy MIN_ENTROPY_THRESHOLD)
    (var-set maintenance-mode false)
)