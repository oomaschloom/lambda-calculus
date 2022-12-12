#lang pl schlac

;;; I'm using the language schlac, a racket #lang, created by Eli Barzilay.
;;; It models the base lambda calculus and details can be found at
;;; https://pl.barzilay.org/lec13#lambda-calculus-----schlac

;;; I'm working through Introduction to Functional Programming through Lambda Calculus
;;; by Michaelson

;;;; IDENTITY
;;; The identity function returns the argument to which it is applied.
;;; λx.x
(define identity (λ (x) x))

;;; If we apply the identity function to the identity function.
;;; (λx.x λx.x)
;;; The function expression is λx.x
;;; The argument expression is λx.x
;;; When this function application is evaluated, the bound variable x is replaced with
;;; the argument expression in the body expression.
;;; (λx.x λx.x) => λx.x
(test (identity identity) => identity)

;;;; SELF-APPLICATION
;;; The self application function applies its argument to its argument.
;;; λs.(s s)
(define self-application (λ (s) (s s)))

;;; Applying the identity function to the self-application function
;;; (λx.x λs.(s s))
;;; The function expression is λx.x
;;; The argument expression is λs.(s s)
;;; When the application is evaluated the bound variable x is replaced by λs.(s s)
;;; (λx.x λs.(s s)) => λs.(s s)
(test (identity self-application) => self-application)

;;; Applying the self-application function to the identity function
;;; (λs.(s s) λx.x)
;;; The function expression is λs.(s s)
;;; The argument expression is λx.x
;;; When the application is evaluated, the bound variable s is replaced by λx.x
;;; (λs.(s s) λx.x) => (λx.x λx.x)
;;; The function expression is λx.x
;;; The argument expression is λx.x
;;; When the application is evaluated, the bound variable x is replaced by λx.x
;;; (λx.x λx.x) => λx.x
;;; Fully expanded:
;;; (λs.(s s) λx.x) => (λx.x λx.x) => λx.x
(test (self-application identity) => (identity identity)) ; One step evaluation
(test (self-application identity) => identity) ; Complete evaluation

;;; Applying the self-application function to itself
;;;(λs.(s s) λs.(s s))
;;; The function expression is λs.(s s)
;;; The argument expression is λs.(s s)
;;; When the application is evaluated, the bound variable s is replaced by λs.(s s)
;;; (λs.(s s) λs.(s s)) => (λs.(s s) λs.(s s))
;;; The function expression is λs.(s s)
;;; The argument expression is λs.(s s)
;;; When the application is evaluated, the bound variable s is replaced by λs.(s s)
;;; (λs.(s s) λs.(s s)) => (λs.(s s) λs.(s s))

;;; UH OH. This will never terminate. No testing for this!
