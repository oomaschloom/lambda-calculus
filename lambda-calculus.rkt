#lang pl schlac

;;; I'm using the language schlac, a racket #lang, create by Eli Barzilay.
;;; It models the base lambda calculus and details can be found at
;;; https://pl.barzilay.org/lec13#lambda-calculus-----schlac

;;; I'm working through Introduction to Functional Programming through Lambda Calculus
;;; by Michaelson

;;; The identity function returns the argument to which it is applied
(define identity (λ (x) x))

(test (identity 'x) => 'x)
(test (identity 'y) => 'y)
