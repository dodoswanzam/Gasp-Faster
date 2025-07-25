;; proof-of-donation.clar
;;
;; This contract provides a transparent way for organizations to register
;; and for donors to receive a proof-of-donation non-fungible token (NFT).

;; ---
;; Constants and Errors
;; ---
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ORG-ALREADY-REGISTERED (err u101))
(define-constant ERR-ORG-NOT-REGISTERED (err u102))
(define-constant ERR-DONATION-FAILED (err u103))

;; ---
;; Data Structures
;; ---

;; A map to store registered organizations.
;; key: organization's principal, value: organization's name
(define-map organizations principal (string-ascii 256))

;; A non-fungible token to represent proof of donation.
(define-non-fungible-token proof-of-donation-nft uint)

;; The last token ID used for the NFT.
(define-data-var last-token-id uint u0)

;; ---
;; Public Functions
;; ---

;; @desc Registers a new charitable organization.
;; @param name: The name of the organization.
;; @returns (ok bool) or (err uint)
(define-public (register-organization (name (string-ascii 256)))
  (begin
    (asserts! (is-none (map-get? organizations tx-sender)) ERR-ORG-ALREADY-REGISTERED)
    (map-set organizations tx-sender name)
    (ok true)
  )
)

;; @desc Records a donation to a registered organization and mints an NFT to the donor.
;; @param org-principal: The principal of the organization receiving the donation.
;; @param memo: A public memo for the donation.
;; @returns (ok uint) with the new token ID or (err uint)
(define-public (donate (org-principal principal) (memo (string-ascii 256)))
  (begin
    (asserts! (is-some (map-get? organizations org-principal)) ERR-ORG-NOT-REGISTERED)
    (let ((token-id (+ (var-get last-token-id) u1)))
      (try! (nft-mint? proof-of-donation-nft token-id tx-sender))
      (var-set last-token-id token-id)
      (print { donor: tx-sender, organization: org-principal, memo: memo, tokenId: token-id })
      (ok token-id)
    )
  )
)

;; @desc Read-only function to get an organization's name.
;; @param org-principal: The principal of the organization.
;; @returns (response (string-ascii 256) or none)
(define-read-only (get-organization-name (org-principal principal))
  (map-get? organizations org-principal)
)