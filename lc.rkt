#lang pl schlac

(define identity (λ(x) x))
(define self-apply (λ(s) (s s)))
(define apply (λ(func) (λ(arg) (func arg))))

(define make-pair (λ(first) (λ(second) (λ(func) ((func first) second)))))
(define select-first (λ(first) (λ(second) first)))
(define select-second (λ(first) (λ(second) second)))

(define make-triplet
  (λ(first) (λ(second) (λ(third) (λ(func) (((func first) second) third))))))
(define triplet-first (λ(first) (λ(second) (λ(third) first))))
(define triplet-second (λ(first) (λ(second) (λ(third) second))))
(define triplet-third (λ(first) (λ(second) (λ(third) third))))

(define cond (λ(e1) (λ(e2) (λ(c) ((c e1) e2)))))
(define true select-first)
(define false select-second)

(define not (λ(x) ((x false) true)))
(define and (λ(x) (λ(y) ((x y) false))))
(define or (λ(x) (λ(y) ((x true) y))))
