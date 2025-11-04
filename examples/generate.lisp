;;;; ============================================================================
;;;; Poetry Forms - Example Usage
;;;; ============================================================================
;;;; This file demonstrates how to use the refactored Poetry Forms library.
;;;;
;;;; To run these examples:
;;;;   1. Load the system: (asdf:load-system :poetry-forms)
;;;;      or if using Quicklisp: (ql:quickload :poetry-forms)
;;;;   2. Load this file: (load "examples/generate.lisp")
;;;; ============================================================================

(in-package #:cl-user)

;; Make poetry-forms available
(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package :poetry-forms)
    (asdf:load-system :poetry-forms)))

(use-package :poetry-forms)
(use-package :poetry-forms.generators)

;;; ---------------------------------------------------------------------------
;;; Example 1: Basic Random Poem
;;; ---------------------------------------------------------------------------

(defun example-basic-random ()
  "Generate a simple random poem with default parameters."
  (format t "~%~%=== Example 1: Basic Random Poem ===~%")
  (let ((poem (generate-basic-poem :stanzas 3
                                   :avg-stanza 4
                                   :avg-line 8
                                   :generator :random)))
    (print-poem poem)
    poem))

;;; ---------------------------------------------------------------------------
;;; Example 2: Sine Wave Visual Pattern
;;; ---------------------------------------------------------------------------

(defun example-sine-wave ()
  "Generate a poem with sine wave line length variation."
  (format t "~%~%=== Example 2: Sine Wave Pattern ===~%")
  (format t "Notice how line lengths flow smoothly in a wave pattern~%")
  (let ((poem (generate-basic-poem :stanzas 4
                                   :avg-stanza 6
                                   :avg-line 10
                                   :generator :sine)))
    (print-poem poem)
    poem))

;;; ---------------------------------------------------------------------------
;;; Example 3: Spatial Poem with Random Indentation
;;; ---------------------------------------------------------------------------

(defun example-spatial-random ()
  "Generate a spatial poem with random indentation."
  (format t "~%~%=== Example 3: Spatial Poem (Random Indentation) ===~%")
  (format t "Lines have random indentation for organic layout~%")
  (let ((poem (generate-spatial-poem :stanzas 3
                                     :avg-stanza 5
                                     :avg-line 8
                                     :generator :random)))
    (print-poem-spatial poem)
    poem))

;;; ---------------------------------------------------------------------------
;;; Example 4: Pyramid/Diamond Effect
;;; ---------------------------------------------------------------------------

(defun example-pyramid ()
  "Generate a poem with pyramid/diamond visual effect."
  (format t "~%~%=== Example 4: Pyramid Effect ===~%")
  (format t "Longer lines are more indented, creating a pyramid shape~%")
  (let ((poem (generate-spatial-poem :stanzas 2
                                     :avg-stanza 6
                                     :avg-line 8
                                     :generator :sine)))
    (print-poem-spatial poem)
    poem))

;;; ---------------------------------------------------------------------------
;;; Example 5: Cascading/Staircase Effect
;;; ---------------------------------------------------------------------------

(defun example-cascade ()
  "Generate a poem with cascading staircase effect."
  (format t "~%~%=== Example 5: Cascading Staircase ===~%")
  (format t "Indentation increases as poem progresses~%")
  (let ((poem (generate-spatial-poem :stanzas 2
                                     :avg-stanza 8
                                     :avg-line 7
                                     :generator :progressive)))
    (print-poem-spatial poem)
    poem))

;;; ---------------------------------------------------------------------------
;;; Example 6: Using Low-Level API
;;; ---------------------------------------------------------------------------

(defun example-low-level ()
  "Demonstrate using the low-level API directly."
  (format t "~%~%=== Example 6: Low-Level API ===~%")
  (format t "Using gen-poem directly for more control~%")
  (let ((*avg-line* 12)
        (*poem-line* 0)
        (*poem-stanza* 0)
        (*random-state* (make-random-state t)))
    (let ((poem (gen-poem 3 5 #'gen-line-sine)))
      (print-poem poem)
      poem)))

;;; ---------------------------------------------------------------------------
;;; Example 7: Comparing Generators
;;; ---------------------------------------------------------------------------

(defun example-compare-generators ()
  "Compare different line generation strategies side by side."
  (format t "~%~%=== Example 7: Comparing Generators ===~%")

  (format t "~%Random generation:~%")
  (let ((poem1 (generate-basic-poem :stanzas 2 :avg-stanza 4
                                    :avg-line 8 :generator :random)))
    (print-poem poem1))

  (format t "~%Sine wave generation:~%")
  (let ((poem2 (generate-basic-poem :stanzas 2 :avg-stanza 4
                                    :avg-line 8 :generator :sine)))
    (print-poem poem2)))

;;; ---------------------------------------------------------------------------
;;; Example 8: Varying Parameters
;;; ---------------------------------------------------------------------------

(defun example-parameter-exploration ()
  "Explore how different parameters affect output."
  (format t "~%~%=== Example 8: Parameter Exploration ===~%")

  (format t "~%Short lines (avg-line = 4):~%")
  (print-poem (generate-basic-poem :avg-line 4 :stanzas 2))

  (format t "~%Long lines (avg-line = 16):~%")
  (print-poem (generate-basic-poem :avg-line 16 :stanzas 2))

  (format t "~%Many short stanzas:~%")
  (print-poem (generate-basic-poem :stanzas 6 :avg-stanza 2))

  (format t "~%Few long stanzas:~%")
  (print-poem (generate-basic-poem :stanzas 2 :avg-stanza 8)))

;;; ---------------------------------------------------------------------------
;;; Run All Examples
;;; ---------------------------------------------------------------------------

(defun run-all-examples ()
  "Run all example functions in sequence."
  (format t "~%~%")
  (format t "╔════════════════════════════════════════════════════════════════╗~%")
  (format t "║         POETRY FORMS GENERATOR - EXAMPLE GALLERY              ║~%")
  (format t "╚════════════════════════════════════════════════════════════════╝~%")

  (example-basic-random)
  (example-sine-wave)
  (example-spatial-random)
  (example-pyramid)
  (example-cascade)
  (example-low-level)
  (example-compare-generators)
  (example-parameter-exploration)

  (format t "~%~%")
  (format t "╔════════════════════════════════════════════════════════════════╗~%")
  (format t "║                    EXAMPLES COMPLETE                          ║~%")
  (format t "╚════════════════════════════════════════════════════════════════╝~%")
  (format t "~%Try running individual examples: (example-basic-random)~%")
  (format t "Or experiment with your own parameters!~%~%"))

;;; ---------------------------------------------------------------------------
;;; Quick Test
;;; ---------------------------------------------------------------------------

;; Uncomment to run automatically when loading this file:
;; (run-all-examples)

;; Or run individual examples:
;; (example-basic-random)
;; (example-pyramid)
;; (example-cascade)
