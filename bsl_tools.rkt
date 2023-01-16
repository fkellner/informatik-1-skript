#lang racket/base
(require racket/contract)
(require racket/list)
(require racket/string)
(require racket/format)
(require scriblib/render-cond)
(require scribble/core
         scribble/html-properties
         (only-in xml cdata))
(require scribble/latex-properties)
(require scribble/base)
(require syntax/to-string)
(require syntax/stx)
(provide bsltree jsontree stepper)

(define implemented-language (or/c "en" "de"))
(define value (or/c boolean? string? number? '()))
(define name (or/c symbol?))
(struct/contract bsl-string-container (
  [bsl-content (or/c value syntax?)])
  #:transparent)

; predicate function value
(define (value? value)
  (cond
    [(boolean? value) #t]
    [(string? value) #t]
    [(number? value) #t]
    [(empty? value) #t]
    [(symbol? value) #t]
    [else #f]
  )
)
; HTML
(define
  (bsl-tag-wrapper quiz lang)
  (style #f (list
    (alt-tag "bsltree")
    (js-addition "bsl_tools.js")
    (attributes (list (cons 'quiz (if quiz "true" "false"))
                      (cons 'lang lang)))
  ))
)
(define
  (jsontree-tag-wrapper quiz lang)
  (style #f (list
    (alt-tag "jsontree")
    (js-addition "bsl_tools.js")
    (attributes (list (cons 'quiz (if quiz "true" "false"))
                      (cons 'lang lang)))
  ))
)
(define
  (stepper-tag-wrapper lang)
  (style #f (list
    (alt-tag "stepper")
    (js-addition "bsl_tools.js")
    (attributes (list (cons 'lang lang)))
  ))
)
(define
  style-tag-wrapper
  (style #f (list
    (alt-tag "style")))
)

; Either (List of Syntax) or (Value)-> Either (List of String) or (String)
(define (synlst-or-val->strlist-or-str lst)
  (cond
    [(or (number? lst) (boolean? lst)(symbol? lst))
    (string-append (~a lst) " \n")]
    [(string? lst) (string-append "\"" lst "\" \n")]
    [(empty? lst) " '() \n"]
    [(stx-list? lst)(stx-map
      (lambda (x)
      (string-append "(" (syntax->string x) ") \n "))lst)]
    [(syntax? lst) (syntax->string lst)]
  )
)

;Either (List-of-String) or (String) -> String
(define (strlist-or-str->str lst)
  (cond
    [(string? lst) lst]
    [(empty? lst) ""]
    [else (string-append (first lst) (strlist-or-str->str (rest lst)))]
  )
)

; helper for "nothing" in order to not break pdf rendering by outputting nothing
(define nothing (nested-flow (style #f '()) '()))

; helper for inline styles
(define (inline-style s) (elem #:style style-tag-wrapper s))

; render bsl-string
(define
  (bsltree stx #:quiz [quiz #f] #:lang [lang "en"])
  (cond
  [(not (or (syntax? stx) (value? stx)))
   (raise-argument-error 'bsltree "BSL-Tree only accepts Syntax-Expressions or Values" stx)]
  [(not (boolean? quiz))
   (raise-argument-error 'quiz "BSL-Tree #:quiz toggle has to be a boolean!" quiz)]
  [(not (implemented-language lang))
   (raise-argument-error 'lang "BSL-Tree #:lang needs to be an implemented language, currently either 'en' or 'de'" lang)]
  [(cond-block
      [html (paragraph (bsl-tag-wrapper quiz lang)
      (strlist-or-str->str
        (synlst-or-val->strlist-or-str stx))
      )]
      [else nothing]
     ;[latex (paragraph (style #f '()) (strlist-or-str->str(synlst-or-val->strlist-or-str stx)))]
  )]
  )
)

; render bsl-string
(define
  (jsontree #:quiz [quiz #f] #:lang [lang "en"] #:extrastyle [extrastyle ""] . json)
  (cond
  [(not (boolean? quiz))
   (raise-argument-error 'quiz "JSON-Tree #:quiz toggle has to be a boolean!" quiz)]
  [(not (implemented-language lang))
   (raise-argument-error 'lang "JSON-Tree #:lang needs to be an implemented language, currently either 'en' or 'de'" lang)]
  [(cond-block
      [html (paragraph (style #f '())
              (list
                (inline-style extrastyle)
                (elem #:style (jsontree-tag-wrapper quiz lang) json))
            )]
      [else nothing]
     ;[latex (paragraph (style #f '()) (strlist-or-str->str(synlst-or-val->strlist-or-str stx)))]
  )]
  )
)

; render bsl-stepper
(define
  (stepper stx #:lang [lang "en"])
  (cond
  [(not (or (syntax? stx) (value? stx)))
   (raise-argument-error 'bsltree "Stepper only accepts Syntax-Expressions or Values" stx)]
  [(not (implemented-language lang))
   (raise-argument-error 'lang "Stepper #:lang needs to be an implemented language, currently either 'en' or 'de'" lang)]
  [(cond-block
      [html (paragraph (stepper-tag-wrapper lang)
      (strlist-or-str->str
        (synlst-or-val->strlist-or-str stx))
      )]
      [else nothing]
     ;[latex (paragraph (style #f '()) (strlist-or-str->str(synlst-or-val->strlist-or-str stx)))]
  )]
  )
)


; OLD


; predicate function sexpr
;;; (define (sexpr? sexpr)
;;;   (cond
;;;     [(boolean? sexpr) #t]
;;;     [(string? sexpr) #t]
;;;     [(symbol? sexpr) #t]
;;;     [(number? sexpr) #t]
;;;     [(empty? sexpr) #t]
;;;     [(and (string? (~a sexpr))
;;;         (string-prefix? (~a sexpr) "((")
;;;         (string-suffix? (~a sexpr) "))")
;;;     )#t]
;;;     [else #f]
;;;   )
;;; )


; helper: add substring
; sexpr->string
;;; (define (sexpr->string sexpr)
;;;   (cond
;;;     [(boolean? sexpr) (string-append "\n" (~a sexpr) "\n")]
;;;     [(string? sexpr) (string-append "\n" "\"" sexpr "\"" "\n")]
;;;     [(number? sexpr) (string-append "\n" (~a sexpr) "\n")]
;;;     [(empty? sexpr) (string-append "\n" "'()" "\n")]
;;;     [(symbol? sexpr) (string-append "\n" (~a sexpr)"\n")]
;;;     [else (string-append "\n" (substring (~a sexpr) 1 (- (string-length (~a sexpr)) 1)) "\n")]
;;;   )
;;; )


;;; NOT USED
;;;
;;; #lang racket/base
;;; (require racket/contract)
;;; (require racket/list)
;;; (require scribble/core
;;;          scribble/html-properties
;;;          (only-in xml cdata))
;;; (require scribble/latex-properties)
;;; (require scribble/base)

;;; ;
;;; ; <bsl-tree>
;;; ; (expression-or-def)
;;; ; (expression-or-def)
;;; ; (expression-or-def)
;;; ;<\bsl-tree>


;;; ; BSL-Tree data definitions

;;; (define bsl-tree (
;;;   flat-rec-contract tree-of()
;;; ))
;;; ; Value types
;;; (define v (or/c boolean? string? number? '()))

;;; ; name is a keyword
;;; (define name (or/c string?))

;;; ; Expr is call or cond or name or v
;;; ;(define expr (or/c call cond name v))

;;; (define expr (flat-rec-contract expr (or/c call cond name v)))


;;; ; clause is a pair of expr
;;; (define clause (cons/c expr expr))

;;; ; Cond: List of clauses
;;; (define cond (listof clause))

;;; ; call is a name and list of expr
;;; (define call (cons/c name (listof (or/c call cond name v))))

;;; ; funDef is a name a list of names and a expr
;;; (define funDef (cons/c name (cons/c (listof name) expr)))

;;; ; constDef is a name and a expr
;;; (define constDef (cons/c name expr))

;;; ; structDef is a name and a list of names
;;; (define structDef (cons/c name (listof name)))

;;; ; definition is either a funDef or constDef or structDef
;;; (define definition (or/c funDef constDef structDef))

;;; ;defOrExpr
;;; (define defOrExpr (or/c definition expr))

;;; ; program type
;;; (define program (listof defOrExpr))



;;; ; Example program
;;; ;
;;; (program (list (definition (funDef (cons (name "f") (list (name "x")) (expr (name ("x"))))))
;;;                 ))