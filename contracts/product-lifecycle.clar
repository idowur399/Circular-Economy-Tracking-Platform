;; Product Lifecycle Contract

(define-non-fungible-token product-nft uint)

(define-map product-info
  { product-id: uint }
  {
    name: (string-ascii 50),
    manufacturer: principal,
    creation-date: uint,
    materials: (list 10 (string-ascii 20)),
    current-owner: principal,
    status: (string-ascii 20)
  }
)

(define-data-var product-nonce uint u0)

(define-public (register-product
  (name (string-ascii 50))
  (materials (list 10 (string-ascii 20))))
  (let
    ((new-id (+ (var-get product-nonce) u1)))
    (try! (nft-mint? product-nft new-id tx-sender))
    (map-set product-info
      { product-id: new-id }
      {
        name: name,
        manufacturer: tx-sender,
        creation-date: block-height,
        materials: materials,
        current-owner: tx-sender,
        status: "active"
      }
    )
    (var-set product-nonce new-id)
    (ok new-id)
  )
)

(define-public (transfer-product (product-id uint) (new-owner principal))
  (let
    ((product (unwrap! (map-get? product-info { product-id: product-id }) (err u404))))
    (asserts! (is-eq tx-sender (get current-owner product)) (err u403))
    (try! (nft-transfer? product-nft product-id tx-sender new-owner))
    (map-set product-info
      { product-id: product-id }
      (merge product { current-owner: new-owner })
    )
    (ok true)
  )
)

(define-public (update-product-status (product-id uint) (new-status (string-ascii 20)))
  (let
    ((product (unwrap! (map-get? product-info { product-id: product-id }) (err u404))))
    (asserts! (is-eq tx-sender (get current-owner product)) (err u403))
    (map-set product-info
      { product-id: product-id }
      (merge product { status: new-status })
    )
    (ok true)
  )
)

(define-read-only (get-product-info (product-id uint))
  (map-get? product-info { product-id: product-id })
)

