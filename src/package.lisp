;;;; ============================================================================
;;;; Package Definitions for Poetry Forms Generator
;;;; ============================================================================

(defpackage #:poetry-forms.utils
  (:documentation "Shared utilities for poetry form generation")
  (:use #:common-lisp)
  (:export
   ;; Random variation functions
   #:up-down
   #:up-down-half

   ;; Signal generation
   #:sines

   ;; List utilities
   #:rand-list
   #:palindrome
   #:make-list-f
   #:rotate-list

   ;; Random utilities
   #:random-from))

(defpackage #:poetry-forms.generators
  (:documentation "Core poetry form generators")
  (:use #:common-lisp #:poetry-forms.utils)
  (:export
   ;; Generator state
   #:*poem-line*
   #:*poem-stanza*
   #:*avg-line*
   #:*line-number*
   #:*total-lines*
   #:*stanza-array*

   ;; Basic generators (from PoetryGen.lisp)
   #:gen-line-f
   #:gen-line-rand
   #:gen-line-sine
   #:gen-stanza
   #:gen-poem

   ;; Output functions
   #:print-line
   #:print-poem

   ;; Line generation strategies
   #:gen-line-half-space
   #:gen-line-signal
   #:gen-line-signal-sym
   #:gen-line-horiz-sines
   #:gen-line-horiz-sines-sym

   ;; Metrical functions
   #:rand-foot

   ;; Rhyme functions
   #:rhyme-to-rep
   #:choose-line-con
   #:add-rhymes
   #:total-lengths

   ;; Constraint functions
   #:get-stanza-length
   #:choose-stanza-con
   #:gen-stanza-constrained
   #:gen-lines
   #:gen-lines-free
   #:gen-lines-cons
   #:rot-array))

(defpackage #:poetry-forms
  (:documentation "Main package for poetry forms generation")
  (:use #:common-lisp
        #:poetry-forms.utils
        #:poetry-forms.generators)
  (:export
   ;; Re-export key functions
   #:gen-poem
   #:print-poem
   #:gen-line-rand
   #:gen-line-sine
   #:gen-line-horiz-sines
   #:gen-line-horiz-sines-sym

   ;; High-level API
   #:generate-basic-poem
   #:generate-spatial-poem
   #:generate-metrical-poem
   #:generate-constrained-poem))
