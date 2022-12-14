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

;;;; TRIPLET FUNCTIONS
;;; ex 2.4

;;; MAKE-TRIPLET
(define make-triplet
  (λ(first) (λ(second) (λ(third) (λ(func) (((func first) second) third))))))

;;; (((make-triplet identity) apply) self-apply)
;;; (((λfirst.λsecond.λthird.λfunc.(((func first) second) third) identity) apply) self-apply)
;;; ((λsecond.λthird.λfunc.(((func identity) second) third) apply) self-apply)
;;; (λthird.λfunc.(((func identity) apply) third) self-apply)
;;; λfunc.(((func identity) apply) self-apply)

;;;; TRIPLET-FIRST FUNCTION
(define triplet-first (λ(first) (λ(second) (λ(third) first))))

;;; (((triplet-first identity) apply) self-apply)
;;; (((λfirst.λsecond.λthird.first identity) apply) self-apply)
;;; (((λsecond.λthird.identity) apply) self-apply)
;;; ((λthird.identity) self-apply)
;;; identity
(test (((triplet-first identity) apply) self-apply) => identity)
(test (triplet-first self-apply apply identity) => self-apply)

;;;; TRIPLET-SECOND FUNCTION
(define triplet-second (λ(first) (λ(second) (λ(third) second))))

;;; (((triplet-second identity) apply) self-apply)
;;; (((λfirst.λsecond.λthird.second identity) apply) self-apply)
;;; ((λsecond.λthird.second apply) self-apply)
;;; ((λthird.apply) self-apply)
;;; ((λthird.apply) self-apply)
;;; apply
(test (((triplet-second identity) apply) self-apply) => apply)
(test (triplet-second apply self-apply identity) => self-apply)

;;;; TRIPLET-THIRD FUNCTION
(define triplet-third (λ(first) (λ(second) (λ(third) third))))

;;; (((triplet-second identity) apply) self-apply)
;;; (((λfirst.λsecond.λthird.second identity) apply) self-apply)
;;; ((λsecond.λthird.second apply) self-apply)
;;; ((λthird.apply) self-apply)
;;; apply
(test (((triplet-third identity) apply) self-apply) => self-apply)
(test (triplet-third apply self-apply identity) => identity)

;;;; ex 2.5

;; a)
;; λx.λy.(λx.y λy.{x}) === x bound at {x}

;; λy.(λx.y λy.{x}) === x free at {x}
;; (λx.y λy.{x}) === x free at {x}
;; λy.{x} === x free at {x}
;; {x} === x free at {x}
;; λx.λy.(λx.{y} λy.x) === y bound at {y}
;; λy.(λx.{y} λy.x) === y bound at {y}
;; (λx.{y} λy.x) === y free at {y}
;; λx.{y} === y free at {y}
;; {y} === y free at {y}

;;; b)
;; λx.({x} (λy.(λx.x y) {x})) === x bound at {x}
;; ({x} (λy.(λx.x y) {x})) === x free at {x}
;; {x} === x free at {x}
;; (λy.(λx.x y) {x}) === x free at {x}
;; {x} === x free at {x}
;; (λy.(λx.{x} y) x) === x bound at {x}
;; (λx.{x} y) === x bound at {x}
;; λx.{x} === x bound at {x}
;; {x} === x free at {x}

;; λx.(x (λy.(λx.x {y}) x)) === y bound at {y}
;; (x (λy.(λx.x {y}) x)) === y bound at {y}
;; (λy.(λx.x {y}) x) === y bound at {y}
;; (λy.(λx.x {y})) === y bound at {y}

;; (λx.x {y}) === y free at {y}
;; {y} === y free at {y}

;; c)
;; λa.(λb.{a} λb.(λa.{a} b)) === {a} bound at {a}
;; (λb.a λb.(λa.{a} b)) === {a} bound at {a}
;; λb.(λa.{a} b) === {a} bound at {a}
;; (λa.{a} b) === {a} bound at {a}
;; λa.{a} === {a} bound at {a}

;; (λb.{a} λb.(λa.a b)) === {a} free at {a}
;; {a} === {a} free at {a}

;; λa.(λb.a λb.(λa.a {b})) === {b} bound at {b}
;; (λb.a λb.(λa.a {b})) === {b} bound at {b}
;; λb.(λa.a {b}) === {b} bound at {b}

;; (λa.a {b}) === {b} free at {b}
;; {b} === {b} free at {b}

;; d)
;; (λfree.bound λbound.(λfree.{free} bound)) === free bound at {free}
;; λbound.(λfree.{free} bound) === free bound at {free}
;; (λfree.{free} bound) === free bound at {free}
;; λfree.{free} === free bound at {free}

;; {free} === free free at {free}

;; (λfree.bound λbound.(λfree.free {bound})) === bound bound at {bound}
;; λbound.(λfree.free {bound}) === bound bound at {bound}

;; (λfree.{bound} λbound.(λfree.free bound)) === bound free at {bound}
;; (λfree.free {bound}) === bound free at {bound}
;; {bound} === bound free at {bound}

;; e)
;; λp.λq.(λr.({p} (λq.(λp.(r q)))) (q {p})) === p bound at {p}

;; λq.(λr.({p} (λq.(λp.(r q)))) (q {p})) === p free at {p}
;; (λr.({p} (λq.(λp.(r q)))) (q {p})) === p free at {p}
;; λr.({p} (λq.(λp.(r q)))) === p free at {p}
;; ({p} (λq.(λp.(r q)))) === p free at {p}

;; λp.λq.(λr.(p (λq.(λp.(r {q})))) ({q} p)) === q bound at {q}
;; λq.(λr.(p (λq.(λp.(r {q})))) ({q} p)) === q bound at {q}
;; (λr.(p (λq.(λp.(r {q})))) (q p)) === q bound at {q}
;; λr.(p (λq.(λp.(r {q})))) === q bound at {q}
;; (p (λq.(λp.(r {q})))) === q bound at {q}
;; (λq.(λp.(r {q}))) === q bound at {q}
;; λq.(λp.(r {q})) === q bound at {q}

;; (λr.(p (λq.(λp.(r q)))) ({q} p)) === q free at {q}
;; ({q} p) === q free at {q}
;; {q} === q free at {q}

;; (λp.(r {q})) === q free at {q}
;; λp.(r {q}) === q free at {q}
;; (r {q}) === q free at {q}

;; λp.λq.(λr.(p (λq.(λp.({r} q)))) (q p)) === r bound at {r}
;; λq.(λr.(p (λq.(λp.({r} q)))) (q p)) === r bound at {r}
;; (λr.(p (λq.(λp.({r} q)))) (q p)) === r bound at {r}
;; λr.(p (λq.(λp.({r} q)))) === r bound at {r}

;; (p (λq.(λp.({r} q)))) === r free at {r}
;; (λq.(λp.({r} q))) === r free at {r}
;; λq.(λp.({r} q)) === r free at {r}
;; (λp.({r} q)) === r free at {r}
;; λp.({r} q) === r free at {r}
;; ({r} q) === r free at {r}
;; {r} === r free at {r}

;; 2.6

;; a) λx.λy.(λa.y λb.x)
;; b) λx.(x (λy.(λa.a y) x))
;; c) λa.(λb.a λb.(λc.c b))
;; d) (λfree.bound λbound.(λa.a bound))
;; e) λp.λq.(λr.(p (λs.(λt.(r s)))) (q p))

;;;;; CHAPTER 3

;;;; CONDITIONAL FUNCTION
;;; Using make-pair, true is represented by select-first, false is represented by select-second.

;;; <condition>?<expression>:<expression>
;;; X ? true : false

;;; If the condition is true, the first expression is selected for evaluation. If false, the second
;;; expression is selected for evaluation.
;;; For example: max = x>y?x:y

(define cond (λ(e1) (λ(e2) (λ(c) ((c e1) e2)))))

;;; cond applied to <expression1> and <expression2> returns a function.
;; ((cond <expression1>) <expression2>)
;; ((λe1.λe2.λc.((c e1) e2) <expression1>) <expression2>)
;; (λe2.λc.((c <expression1>) e2) <expression2>)
;; λc.((c <expression1>) <expression2>)

;;; If the resulting function is applied to select-first, we get <expression1>
;;; If the resulting function is applied to select-second, we get <expression2>

;;;; TRUE and FALSE
;;; To model the boolean values
(define true select-first)
(define false select-second)

(test (((cond identity) apply) true) => identity)
(test (((cond identity) apply) false) => apply)

;;;; NOT FUNCTION
;;; If the operand is true, then answer is false. If the operand is false, then the answer is true.
;;; X ? false : true

;;; (((cond false) true) x)
;;; (((λe1.λe2.λc.((c e1) e2) false) true) x)
;;; ((λe2.λc.((c false) e2) true) x)
;;; (λc.((c false) true) x)
;;; ((x false) true)

(define not (λ(x) ((x false) true)))

;;; (not true)
;;; (λx.((x false) true)) true)
;;; ((true false) true)
;;; ((select-first false) true)
;;; ((λfirst.λsecond.first false) true)
;;; (λsecond.false true)
;;; false

(test (not true) => false)

;;; (not false)
;;; (λx.((x false) true) false)
;;; ((false false) true)
;;; ((select-second false) true)
;;; ((λfirst.λsecond.second false) true)
;;; (λsecond.second true)
;;; true

(test (not false) => true)

;;;; AND FUNCTION
;;; Boolean and operator, X and Y.
;;; If the left operand (X) is true, then the final result depends on the value of Y.
;;; If the left operand is false, then the final value is false.
;;; X ? Y : false
;;; Using selectors, if the left operand is true, then select the right operand
;;; If the left operand is false, then select false.

; (define and (λ(x) (λ(y) (((cond y) false) x))))
;;; (((cond y) false) x)
;;; (((λe1.λe2.λc.((c e1) e2) y) false) x)
;;; ((λe2.λc.((c y) e2) false) x)
;;; (λc.((c y) false) x)
;;; ((x y) false)

(define and (λ(x) (λ(y) ((x y) false))))

;;; ((and true) false)
;;; ((λx.λy.((x y) false) true) false)
;;; (λy.((true y) false) false)
;;; ((true false) false)
;;; ((select-first false) false)
;;; ((λfirst.λsecond.first false) false)
;;; (λsecond.false false)
;;; false

(test ((and true) false) => false)
(test ((and false) true) => false)
(test ((and false) false) => false)
(test ((and true) true) => true)
