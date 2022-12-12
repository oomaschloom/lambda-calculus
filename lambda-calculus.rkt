#lang pl schlac

;;; I'm using the language schlac, a racket #lang, created by Eli Barzilay.
;;; It models the base lambda calculus and details can be found at
;;; https://pl.barzilay.org/lec13#lambda-calculus-----schlac

;;; I'm working through Introduction to Functional Programming through Lambda Calculus
;;; by Michaelson

;;;; IDENTITY
;;; The identity function returns the argument to which it is applied.
;;; λx.x
(define identity (λ(x) x))

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
(define self-apply (λ(s) (s s)))

;;; Applying the identity function to the self-application function
;;; (λx.x λs.(s s))
;;; The function expression is λx.x
;;; The argument expression is λs.(s s)
;;; When the application is evaluated the bound variable x is replaced by λs.(s s)
;;; (λx.x λs.(s s)) => λs.(s s)
(test (identity self-apply) => self-apply)

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
(test (self-apply identity) => (identity identity)) ; One step evaluation
(test (self-apply identity) => identity) ; Complete evaluation

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

;;;; FUNCTION APPLICATION FUNCTION
;;; λfunc.λarg.(func arg)
(define apply (λ(func) (λ(arg) (func arg))))
;;; The bound variable is func
;;; The body expression is the function λarg.(func arg)
;;; Which has the bound variable arg
;;; and the body expression (func arg)
;;; The function application function returns a second function that applies the
;;; first function's argument to the second function's argument.

;;; Applying the identity function to the self-application function
;;; ((λfunc.λarg.(func arg) λx.x) λs.(s s))
;;; The function expression is (λfunc.λarg.(func arg) λx.x)
;;; The bound variable func is replaced by λx.x
;;; λarg.(λx.x arg)
;;; This returns a function which applies the identity to its argument.
;;; Now we're here (λarg.(λx.x arg) λs.(s s))
;;; The bound variable arg is replaced by λs.(s s)
;;; (λx.x λs.(s s))
(test (apply identity self-apply) => (identity self-apply)) ; partial evaluation

;;; The bound variable x is replaced by λs.(s s)
;;; λs.(s s)
(test (apply identity self-apply) => self-apply) ; full evaluation

;;;; ANOTHER IDENTITY FUNCTION
(define identity2 (λ(x) ((apply identity) x)))

;;; Apply identity2 to the identity function
;;; (identity2 identity)
;;; (λx.((apply identity) x) identity)
;;; ((apply identity) identity)
(test (identity2 identity) => ((apply identity) identity))
;;; ((λfunc.λarg.(func arg) identity) identity)
;;; (λarg.(identity arg) identity)
;;; (identity identity)
(test (identity2 identity) => (identity identity))
;;; identity
(test (identity2 identity) => identity)

(test (identity2 identity) => (identity identity))

;;;; ANOTHER SELF-APPLY FUNCTION
(define self-apply2 (λ(s) ((apply s) s)))

;;; Apply self-apply2 to the identity function
;;; (self-apply2 identity)
;;; (λs.((apply s) s) identity)
;;; ((apply identity) identity)
(test (self-apply2 identity) => ((apply identity) identity))
;;; (identity identity)
(test (self-apply2 identity) => (identity identity))
;;; identity
(test (self-apply2 identity) => identity)

(test (self-apply2 identity) => (self-apply identity))
