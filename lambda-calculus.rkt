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

;;;; SELECT-FIRST FUNCTION
(define select-first (λ(first) (λ(second) first)))

;;; The bound variable for function select-first is first
;;; The body is λsecond.first

;;; When applied to an argument, select-first returns a new function, which,
;;; when applied to another argument, returns the first argument.

;;; ((select-first identity) apply)
;;; ((λfirst.λsecond.first identity) apply)
;;; (λsecond.identity apply)
;;; identity
(test ((select-first identity) apply) => identity)
(test (select-first self-apply apply) => self-apply)

;;;; SELECT-SECOND FUNCTION
(define select-second (λ(first) (λ(second) second)))

;;; The bound variable for function select-first is second
;;; The body is λsecond.second

;;; When applied to an argument, select-second returns a new function, which,
;;; when applied to another argument, returns the second argument.

;;; ((select-second identity) apply)
;;; ((λfirst.λsecond.second identity) apply)
;;; (λsecond.second apply)
;;; apply
(test ((select-second identity) apply) => apply)
(test (select-second apply self-apply) => self-apply)

;;;; MAKE-PAIR FUNCTION
;;; make-pair applies argument func to argument first to build a new function
;;; which may be applied to argument second.
(define make-pair (λ(first) (λ(second) (λ(func) ((func first) second)))))

;;; ((make-pair identity) apply)
;;; ((λfirst.λsecond.λfunc.((func first) second) identity) apply)
;;; (λsecond.λfunc.((func identity) second) apply)
;;; λfunc.((func identity) apply)
;;; So we have a lambda carrying around a pair.

;;; If this returned function is applied to select-first we get the first of the pair.
;;; (λfunc.((func identity) apply) select-first)
;;; ((select-first identity) apply)
;;; ((λfirst.λsecond.first identity) apply)
;;; (λsecond.identity apply)
;;; identity
(test ((make-pair identity apply) select-first)
      => identity)

;;; If this returned function is applied to select-second we get the second of the pair.
;;; (λfunc.((func identity) apply) select-second)
;;; ((select-second identity) apply)
;;; ((λfirst.λsecond.second identity) apply)
;;; (λsecond.second apply)
;;; apply
(test ((make-pair identity apply) select-second)
      => apply)

;;;; EXERCISES

;;;; 2.2 Evaluate the following λ expressions

;;; a)
;; ((λx.λy.(y x) λp.λq.p) λi.i)
;; (λy.(y λp.λq.p) λi.i)
;; (λi.i λp.λq.p)
;; λp.λq.p

;;; b)
;; (((λx.λy.λz.((x y) z) λf.λa.(f a)) λi.i) λj.j)
;; ((λy.λz.((λf.λa.(f a) y) z) λi.i) λj.j)
;; (λz.((λf.λa.(f a) λi.i) z) λj.j)
;; ((λf.λa.(f a) λi.i) λj.j)
;; (λa.(λi.i a) λj.j)
;; (λi.i λj.j)
;; λj.j

;;; c)
;; (λh.((λa.λf.(f a) h) h) λf.(f f))
;; ((λa.λf.(f a) λf.(f f)) λf.(f f))
;; (λf.(f λf.(f f)) λf.(f f))
;; (λf.(f f) λf.(f f))
;; (λf.(f f) λf.(f f))
;; λf.(f f) is the self-application function. This evaluation will never terminate.

;;; d)
;; ((λp.λq.(p q) (λx.x λa.λb.a)) λk.k)
;; (λq.((λx.x λa.λb.a) q) λk.k)
;; ((λx.x λa.λb.a) λk.k)
;; (λa.λb.a λk.k)
;; λb.λk.k

;;; e)
;; (((λf.λg.λx.(f (g x)) λs.(s s)) λa.λb.b) λx.λy.x)
;; ((λg.λx.(λs.(s s) (g x)) λa.λb.b) λx.λy.x)
;; (λx.(λs.(s s) (λa.λb.b x)) λx.λy.x)
;; ((λa.λb.b λx.λy.x) (λa.λb.b λx.λy.x))
;; (λb.b (λa.λb.b λx.λy.x))
;; (λa.λb.b λx.λy.x)
;; λb.b

;;; 2.3

;; a) i)
;; (identity <argument>)
;; <argument>

;; ((apply (apply identity)) <argument>)
;; ((apply identity) <argument>)
;; (identity <argument>)
;; <argument>

;; I just chose select-first as an arbitrary argument
(test (identity select-first)
      => (apply (apply identity) select-first))

;; b) i)
;; ((apply <function>) <argument>)
;; ((apply <function>) <argument>)
;; (<function> <argument>)

;; ii)
;; ((λx.λy.(((make_pair x) y) identity) <function>) <argument>)
;; (λy.(((make_pair <function>) y) identity) <argument>)
;; (((make_pair <function>) <argument>) identity)
;; ((identity <function>) <argument>)
;; (<function> <argument>)

;; c) i)
;; (identity <argument)
;; <argument>

;; ii)
;; ((self-apply (self-apply select-second)) <argument>)
;; ((self-apply select-second) (self-apply select-second) <argument>)
;; ((select-second select-second) (self-apply select-second) <argument>)
;; ((λsecond.second (self-apply select-second)) <argument>)
;; ((self-apply select-second) <argument>)
;; ((select-second select-second) <argument>)
;; (λsecond.second <argument>)
;; <argument>

;; Apply is an "arbitrary" argument
(test (identity apply)
      => ((self-apply (self-apply select-second)) apply))
