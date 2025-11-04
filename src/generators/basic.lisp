;;;; ============================================================================
;;;; Basic Poetry Form Generator (Refactored)
;;;; ============================================================================
;;;; This is the refactored version of PoetryGen.lisp, cleaned up to use
;;;; shared utilities from poetry-forms.utils.
;;;;
;;;; This module provides the foundational poetry form generation with:
;;;; - Random line length variation
;;;; - Sine wave-based visual patterns
;;;; - Simple stanza and poem structure
;;;;
;;;; CHANGES FROM ORIGINAL:
;;;; - No code duplication (uses shared utilities)
;;;; - Proper package structure
;;;; - Cleaner separation of concerns
;;;; - Same algorithms and output
;;;; ============================================================================

(in-package #:poetry-forms.generators)

;;; ---------------------------------------------------------------------------
;;; Global State Variables
;;; ---------------------------------------------------------------------------
;;; DESIGN DECISION: Use global state rather than threading state through all
;;; functions. This simplifies the code for what is essentially a batch
;;; generation process where we generate one complete poem at a time.

(defvar *poem-line* 0
  "Current line number (absolute position across all stanzas)")

(defvar *poem-stanza* 0
  "Current stanza number")

(defvar *avg-line* 0
  "Target average line length (set per poem)")

;;; ---------------------------------------------------------------------------
;;; LINE GENERATION STRATEGIES
;;; ---------------------------------------------------------------------------

(defun gen-line-f (f)
  "Apply line generation function f to current line number.

   DESIGN DECISION: Indirection layer for future extensibility.
   This stub allows line generation functions to be plugged in without changing
   the structure of gen-stanza. Future versions could add context-awareness here.

   The line number parameter enables position-dependent generation."
  (funcall f *poem-line*))

(defun gen-line-rand (i)
  "Generate random line length around *avg-line* with ±50% variation.

   DESIGN DECISION: 50% variation (±half of average) provides good balance
   between structure and variety. Too little variation feels monotonous,
   too much loses coherent form.

   Example:
     With *avg-line* = 10, generates lines in range [5, 15]"
  (declare (ignore i))  ; Line number not used in random generation
  (funcall (up-down (floor (/ *avg-line* 2))) *avg-line*))

(defun gen-line-sine (i)
  "Generate line length using sine wave for smooth, flowing transitions.

   DESIGN DECISION: Sine wave creates visual patterns when lines are printed,
   producing aesthetically pleasing 'shapes' on the page. The minimum of 2
   ensures lines are always readable (at least 2 syllables).

   The specific amplitudes (3, -3, 1, 2) were chosen experimentally to create
   interesting interference patterns - not too regular, not too chaotic.

   Example visual effect (line lengths):
     8 -> 10 -> 11 -> 9 -> 7 -> 6 -> 7 -> 9 -> 11 (wave-like)"
  (max (floor (+ *avg-line* (funcall (sines 3 -3 1 2) i))) 2))

;;; ---------------------------------------------------------------------------
;;; POEM STRUCTURE GENERATION
;;; ---------------------------------------------------------------------------

(defun gen-stanza (avg-stanza line-fun)
  "Generate one stanza with variable number of lines.

   DESIGN DECISION: Vary stanza length by ±3 lines to create organic variation
   between stanzas. The ±3 range prevents too much uniformity while keeping
   stanzas recognizable as related units.

   Side effect: increments *poem-line* to track absolute line position for
   context-aware generation.

   Returns: List of line lengths (integers)"
  (loop for x from 1 to (funcall (up-down 3) avg-stanza)
        do (incf *poem-line*)
        collect (gen-line-f line-fun)))

(defun gen-poem (num-stanza avg-stanza line-fun)
  "Generate complete poem structure (list of stanzas).

   DESIGN DECISION: Vary total stanza count by ±2 from target. This is smaller
   variation than line counts because poem-level structure should be more stable.
   Each stanza gets the same line-generation function, creating cohesive style.

   Parameters:
     num-stanza  - Target number of stanzas (will vary ±2)
     avg-stanza  - Target lines per stanza (will vary ±3 per stanza)
     line-fun    - Function to generate line lengths

   Returns: List of stanzas, where each stanza is a list of line lengths"
  (loop for x from 1 to (funcall (up-down 2) num-stanza)
        collect (gen-stanza avg-stanza line-fun)))

;;; ---------------------------------------------------------------------------
;;; OUTPUT/VISUALIZATION
;;; ---------------------------------------------------------------------------

(defun print-line (l)
  "Print line as visual representation: dashes for syllables.

   Format: 'length: ------'

   DESIGN DECISION: Show both numeric length and visual dashes because:
   - Numbers enable precise counting for syllabic poetry
   - Dashes enable gestalt perception of overall form/shape

   The visual representation makes the poem's structure immediately apparent
   without requiring the reader to count syllables."
  (let ((s ""))
    (dotimes (i l)
      (setf s (concatenate 'string "-" s)))
    (format t "~a: ~a~%" l s)))

(defun print-poem (poem)
  "Print complete poem with blank lines between stanzas.

   DESIGN DECISION: Blank lines between stanzas create visual separation,
   making the multi-stanza structure immediately apparent.

   This is the standard output format used across all generator versions."
  (dolist (s poem)
    (dolist (l s)
      (print-line l))
    (format t "~%")))  ; Blank line after each stanza

;;; ---------------------------------------------------------------------------
;;; CONVENIENCE API
;;; ---------------------------------------------------------------------------

(defun generate-basic-poem (&key (stanzas 3) (avg-stanza 4) (avg-line 8)
                                 (generator :random))
  "High-level API for generating basic poems.

   Keyword arguments:
     :stanzas     - Target number of stanzas (default 3)
     :avg-stanza  - Target lines per stanza (default 4)
     :avg-line    - Target syllables per line (default 8)
     :generator   - Generation strategy: :random or :sine (default :random)

   Returns: Generated poem structure (list of stanzas)

   Example:
     (generate-basic-poem :stanzas 4 :generator :sine)
     (generate-basic-poem :avg-line 12)  ; Use defaults for other params"
  (let ((*avg-line* avg-line)
        (*poem-line* 0)
        (*poem-stanza* 0)
        (*random-state* (make-random-state t)))  ; Fresh randomness each time
    (gen-poem stanzas
              avg-stanza
              (ecase generator
                (:random #'gen-line-rand)
                (:sine #'gen-line-sine)))))

;;; ---------------------------------------------------------------------------
;;; Example Usage
;;; ---------------------------------------------------------------------------

#|
;; Generate a random poem
(let ((poem (generate-basic-poem :stanzas 3 :avg-stanza 4 :avg-line 8)))
  (print-poem poem))

;; Generate a sine-wave poem with longer lines
(let ((poem (generate-basic-poem :stanzas 4 :avg-line 12 :generator :sine)))
  (print-poem poem))

;; Use the lower-level API directly
(let ((*avg-line* 10))
  (setf *random-state* (make-random-state t))
  (print-poem (gen-poem 3 4 #'gen-line-rand)))
|#
