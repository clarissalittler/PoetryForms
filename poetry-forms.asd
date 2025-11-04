;;;; ============================================================================
;;;; ASDF System Definition for Poetry Forms Generator
;;;; ============================================================================
;;;; This file defines the Poetry Forms library as an ASDF system, making it
;;;; loadable via Quicklisp or directly with ASDF.
;;;;
;;;; Usage:
;;;;   (asdf:load-system :poetry-forms)
;;;;   or
;;;;   (ql:quickload :poetry-forms)
;;;;
;;;; Then in your code:
;;;;   (use-package :poetry-forms)
;;;;   (let ((poem (generate-basic-poem :stanzas 3 :avg-stanza 4 :avg-line 8)))
;;;;     (print-poem poem))
;;;; ============================================================================

(asdf:defsystem #:poetry-forms
  :description "A procedural poetry form generator for creating diverse poetic structures"
  :long-description
  "Poetry Forms is a system for generating the structural forms of poetry
   (stanzas, line lengths, rhyme schemes, metrical patterns, spatial layout)
   to help poets overcome creative blocks by providing interesting constraints
   to work within.

   The system provides multiple generation strategies ranging from simple
   random variation to complex constraint-based forms with inter-stanza
   relationships, metrical patterns, and sophisticated rhyme schemes.

   Key features:
   - Multiple line generation strategies (random, sine-wave, signal-based)
   - Spatial control (indentation, whitespace patterns)
   - Classical meter (iambic, trochaic, spondaic, pyrrhic feet)
   - Rhyme scheme generation (full rhyme, slant rhyme)
   - Inter-stanza constraints (rotation, line equality, line sharing)
   - Visual/concrete poetry support"

  :author "Clarissa Littler"
  :license "MIT"
  :version "0.2.0"
  :homepage "https://github.com/clarissalittler/PoetryForms"

  :depends-on ()  ; No external dependencies - pure Common Lisp!

  :components
  ((:module "src"
    :components
    ((:file "package")                          ; Package definitions
     (:file "utils" :depends-on ("package"))    ; Shared utilities

     ;; Generators (to be created)
     (:module "generators"
      :depends-on ("package" "utils")
      :components
      ((:file "basic")       ; Basic form generation (PoetryGen.lisp)
       (:file "spatial")     ; Spatial/indentation (PoetryGenSpace.lisp)
       (:file "rhyme-basic") ; Basic rhyme (PoetryGenRhyme3.lisp)
       (:file "whitespace")  ; Fine whitespace control (PoetryWhitespace.lisp)
       (:file "metrical")    ; Metrical feet (PoetryMetre.lisp)
       (:file "constrained")))))) ; Advanced constraints (PoetryRhyme2.lisp)

  ;; Define the main API in a separate component that depends on everything
  (:module "api"
   :depends-on ("src")
   :components
   ((:file "api")))  ; High-level convenience functions

  :in-order-to ((test-op (test-op :poetry-forms/tests))))

;;;; Test system definition
(asdf:defsystem #:poetry-forms/tests
  :description "Test suite for poetry-forms"
  :author "Clarissa Littler"
  :license "MIT"
  :depends-on (#:poetry-forms
               #:fiveam)  ; Popular testing framework
  :components
  ((:module "tests"
    :components
    ((:file "test-utils")
     (:file "test-generators"))))
  :perform (test-op (o c) (symbol-call :fiveam '#:run! :poetry-forms-tests)))

;;;; ============================================================================
;;;; Usage Examples
;;;; ============================================================================

#|
After loading the system, you can use it like this:

;; Load the system
(ql:quickload :poetry-forms)

;; Use the high-level API
(poetry-forms:generate-basic-poem :stanzas 3 :avg-stanza 4 :avg-line 8
                                  :generator :sine)

;; Or use the lower-level API directly
(let ((poetry-forms.generators:*avg-line* 8))
  (poetry-forms.generators:gen-poem
    3  ; num-stanzas
    4  ; avg-stanza-length
    #'poetry-forms.generators:gen-line-sine))

;; Generate with metrical feet
(poetry-forms:generate-metrical-poem :stanzas 4 :avg-line 5)

;; Generate with constraints (villanelle-like forms)
(poetry-forms:generate-constrained-poem :stanzas 6 :avg-stanza 3)
|#
