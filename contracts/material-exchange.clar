;; Material Exchange Contract

(define-map material-listings
  { listing-id: uint }
  {
    seller: principal,
    material: (string-ascii 20),
    quantity: uint,
    price: uint,
    status: (string-ascii 10)
  }
)

(define-data-var listing-nonce uint u0)

(define-public (create-listing
  (material (string-ascii 20))
  (quantity uint)
  (price uint))
  (let
    ((new-id (+ (var-get listing-nonce) u1)))
    (map-set material-listings
      { listing-id: new-id }
      {
        seller: tx-sender,
        material: material,
        quantity: quantity,
        price: price,
        status: "active"
      }
    )
    (var-set listing-nonce new-id)
    (ok new-id)
  )
)

(define-public (purchase-material (listing-id uint))
  (let
    ((listing (unwrap! (map-get? material-listings { listing-id: listing-id }) (err u404))))
    (asserts! (is-eq (get status listing) "active") (err u403))
    (asserts! (not (is-eq tx-sender (get seller listing))) (err u403))
    (try! (stx-transfer? (get price listing) tx-sender (get seller listing)))
    (map-set material-listings
      { listing-id: listing-id }
      (merge listing { status: "sold" })
    )
    (ok true)
  )
)

(define-read-only (get-listing (listing-id uint))
  (map-get? material-listings { listing-id: listing-id })
)

