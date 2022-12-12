#lang pl schlac

;;; I'm using the language schlac, a racket #lang, created by Eli Barzilay.
;;; It models the base lambda calculus and details can be found at
;;; https://pl.barzilay.org/lec13#lambda-calculus-----schlac

;;; I'm working through Introduction to Functional Programming through Lambda Calculus
;;; by Michaelson

;;; The identity function returns the argument to which it is applied
(define identity (λ (x) x))

;;; If we apply the identity function to the identity function.
;;; (λx.x λx.x)
;;; The function expression is λx.x
;;; The argument expression is λx.x
;;; When this function application is evaluated, the bound variable x is replaced with
;;; the argument expression in the body expression.
;;; (λx.x λx.x) => λx.x
(test (identity identity) => identity)
