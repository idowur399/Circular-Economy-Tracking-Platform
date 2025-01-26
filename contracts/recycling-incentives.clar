;; Recycling Incentives Contract

(define-map recycling-points principal uint)
(define-map recycling-history
  { user: principal, action-id: uint }
  { product-id: uint, points: uint, timestamp: uint }
)

(define-data-var action-nonce uint u0)

(define-public (recycle-product (product-id uint))
  (let
    ((product (unwrap! (contract-call? .product-lifecycle get-product-info product-id) (err u404)))
     (points-earned u10)
     (new-action-id (+ (var-get action-nonce) u1)))
    (asserts! (is-eq tx-sender (get current-owner product)) (err u403))
    (try! (contract-call? .product-lifecycle update-product-status product-id "recycled"))
    (map-set recycling-points
      tx-sender
      (+ (default-to u0 (map-get? recycling-points tx-sender)) points-earned)
    )
    (map-set recycling-history
      { user: tx-sender, action-id: new-action-id }
      { product-id: product-id, points: points-earned, timestamp: block-height }
    )
    (var-set action-nonce new-action-id)
    (ok points-earned)
  )
)

(define-read-only (get-recycling-points (user principal))
  (default-to u0 (map-get? recycling-points user))
)

(define-read-only (get-recycling-history (user principal))
  (map-get? recycling-history { user: user, action-id: (var-get action-nonce) })
)

