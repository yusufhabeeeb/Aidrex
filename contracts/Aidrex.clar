
;; Aidrex
;; Define the contract
(define-data-var contract-owner principal tx-sender)

;; Define constants for errors
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-REGISTERED (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-BENEFICIARY-NOT-FOUND (err u104))
(define-constant ERR-UTILIZATION-NOT-FOUND (err u105))
(define-constant ERR-INVALID-INPUT (err u106))

;; Define constants for roles
(define-constant ROLE-ADMIN u1)
(define-constant ROLE-MODERATOR u2)
(define-constant ROLE-BENEFICIARY u3)

;; Define data maps
(define-map roles { user: principal } { role: uint })

(define-map beneficiaries
  { id: uint }
  { 
    name: (string-utf8 50), 
    description: (string-utf8 255), 
    target-amount: uint, 
    received-amount: uint, 
    status: (string-ascii 20)
  })

(define-map donations
  { id: uint }
  { donor: principal, beneficiary-id: uint, amount: uint, timestamp: uint })

(define-map utilization
  { id: uint }
  { 
    beneficiary-id: uint, 
    milestone: uint, 
    description: (string-utf8 255), 
    amount: uint, 
    status: (string-ascii 20)
  })

;; Define data variables
(define-data-var beneficiary-count uint u0)
(define-data-var donation-count uint u0)
(define-data-var utilization-count uint u0)

;; Helper functions
(define-private (is-authorized (user principal) (required-role uint))
  (let ((role-data (default-to { role: u0 } (map-get? roles { user: user }))))
    (>= (get role role-data) required-role)))

(define-private (get-last-milestone (beneficiary-id uint))
  (var-get utilization-count))

;; Role management functions
(define-public (set-role (user principal) (new-role uint))
  (let ((existing-role (default-to u0 (get role (map-get? roles { user: user })))))
    (if (and 
          (is-eq tx-sender (var-get contract-owner))
          (<= new-role ROLE-BENEFICIARY)
          (not (is-eq user tx-sender))  ;; Ensure user is not setting their own role
          (or (is-eq new-role ROLE-ADMIN)
              (is-eq new-role ROLE-MODERATOR)
              (is-eq new-role ROLE-BENEFICIARY)))
        (ok (map-set roles { user: user } { role: new-role }))
        ERR-NOT-AUTHORIZED)))

(define-public (remove-role (user principal))
  (if (and 
        (is-eq tx-sender (var-get contract-owner))
        (is-some (map-get? roles { user: user }))
        (not (is-eq user tx-sender)))  ;; Ensure user is not removing their own role
      (ok (map-delete roles { user: user }))
      ERR-NOT-AUTHORIZED))

;; Main functions
(define-public (register-beneficiary (name (string-utf8 50)) (description (string-utf8 255)) (target-amount uint))
  (let 
    ((beneficiary-id (+ (var-get beneficiary-count) u1)))
    (if (and (is-authorized tx-sender ROLE-MODERATOR)
             (> (len name) u0)
             (> (len description) u0)
             (> target-amount u0))
        (begin
          (map-set beneficiaries
            { id: beneficiary-id }
            { 
              name: name, 
              description: description, 
              target-amount: target-amount, 
              received-amount: u0, 
              status: "active" 
            })
          (var-set beneficiary-count beneficiary-id)
          (ok beneficiary-id))
        ERR-INVALID-INPUT)))

(define-read-only (get-beneficiary (id uint))
  (match (map-get? beneficiaries { id: id })
    beneficiary (ok beneficiary)
    ERR-BENEFICIARY-NOT-FOUND))
