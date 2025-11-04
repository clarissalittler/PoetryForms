;;;; ============================================================================
;;;; Spatial Poetry Generator (Refactored)
;;;; ============================================================================
;;;; This is the refactored version of PoetryGenSpace.lisp.
;;;;
;;;; Extends basic generation by adding INDENTATION as a structural element,
;;;; enabling concrete poetry and visual effects.
;;;;
;;;; DESIGN DECISION: Lines are (spaces . syllables) pairs instead of integers.
;;;; This adds a second dimension to the poem's structure, allowing control over
;;;; horizontal positioning on the page, not just line length.
;;;;
;;;; CHANGES FROM ORIGINAL:
;;;; - Uses shared utilities (no duplication)
;;;; - Cleaner package structure
;;;; - Added high-level API
;;;; ============================================================================

(in-package #:poetry-forms.generators)

;;; ---------------------------------------------------------------------------
;;; LINE GENERATION STRATEGIES WITH INDENTATION
;;; ---------------------------------------------------------------------------
;;; Each function returns a (spaces . syllables) cons cell

(defun gen-line-rand-spatial (i)
  "Generate line with random indentation and random length.

   DESIGN DECISION: Indentation is independent from line length (random 0-5 spaces).
   This creates organic, unpredictable spatial layouts. The 5-space limit keeps
   indentation readable without excessive horizontal offset.

   Returns: (indent . length) where indent ∈ [0,5], length varies around *avg-line*"
  (declare (ignore i))
  (cons (random 5)
        (funcall (up-down (floor (/ *avg-line* 2))) *avg-line*)))

(defun gen-line-sine-spatial (i)
  "Generate line where indentation is coupled to line length.

   DESIGN DECISION: Indentation = length/2 creates a 'pyramid' or 'diamond' effect
   where longer lines are more indented. This produces visually symmetric forms
   where the poem's shape is more deliberate and architectural.

   Example visual effect:
       ----     (short, little indent)
         ------  (longer, more indent)
           -------- (longest, most indent)

   Returns: (indent . length) where indent = length/2"
  (let ((n (max (floor (+ *avg-line* (funcall (sines 3 -3 1 2) i))) 2)))
    (cons (floor (/ n 2)) n)))

(defun gen-line-rand-linspace (i)
  "Generate line where indentation increases with line position.

   DESIGN DECISION: Indentation = line_number/2 creates a 'cascade' or 'staircase'
   effect as the poem progresses. This adds temporal progression to the visual form,
   with early lines left-aligned and later lines increasingly indented.

   Example:
     Line 0: no indent
     Line 2: 1 space indent
     Line 4: 2 spaces indent
     (creates a descending staircase effect)

   Returns: (indent . length) where indent = i/2"
  (cons (floor (/ i 2))
        (funcall (up-down (floor (/ *avg-line* 2))) *avg-line*)))

;;; ---------------------------------------------------------------------------
;;; POEM STRUCTURE GENERATION (reuses from basic.lisp)
;;; ---------------------------------------------------------------------------
;;; gen-stanza and gen-poem work the same way, but now operate on
;;; (indent . length) pairs instead of plain integers

;;; ---------------------------------------------------------------------------
;;; OUTPUT/VISUALIZATION FOR SPATIAL POEMS
;;; ---------------------------------------------------------------------------

(defun print-line-spatial (l)
  "Print line with indentation visualization.

   Format: '(indent,length): [spaces]------'

   DESIGN DECISION: Show the pair structure explicitly in output.
   - The (indent,length) prefix gives precise numeric values for reference
   - Leading spaces show actual indentation visually
   - Dashes show line content length

   This dual representation (numeric + visual) helps users understand both
   the abstract structure and its concrete visual appearance."
  (let ((s "")
        (llen (cdr l))
        (slen (car l)))
    (dotimes (i slen)
      (setf s (concatenate 'string " " s)))
    (dotimes (i llen)
      (setf s (concatenate 'string s "-")))
    (format t "(~a,~a): ~a~%" slen llen s)))

(defun print-poem-spatial (poem)
  "Print spatial poem with blank lines between stanzas."
  (dolist (s poem)
    (dolist (l s)
      (print-line-spatial l))
    (format t "~%")))

;;; ---------------------------------------------------------------------------
;;; CONVENIENCE API
;;; ---------------------------------------------------------------------------

(defun generate-spatial-poem (&key (stanzas 3) (avg-stanza 4) (avg-line 8)
                                   (generator :random))
  "High-level API for generating spatial poems with indentation.

   Keyword arguments:
     :stanzas     - Target number of stanzas (default 3)
     :avg-stanza  - Target lines per stanza (default 4)
     :avg-line    - Target syllables per line (default 8)
     :generator   - Generation strategy (default :random)
                    Options: :random         (random independent indent)
                             :sine           (indent coupled to length)
                             :progressive    (indent increases over time)

   Returns: Generated poem structure (list of stanzas of (indent . length) pairs)

   Example:
     ;; Random indentation
     (generate-spatial-poem :stanzas 3 :generator :random)

     ;; Pyramid/diamond effect
     (generate-spatial-poem :stanzas 2 :generator :sine)

     ;; Cascading/staircase effect
     (generate-spatial-poem :avg-stanza 8 :generator :progressive)"
  (let ((*avg-line* avg-line)
        (*poem-line* 0)
        (*poem-stanza* 0)
        (*random-state* (make-random-state t)))
    (gen-poem stanzas
              avg-stanza
              (ecase generator
                (:random #'gen-line-rand-spatial)
                (:sine #'gen-line-sine-spatial)
                (:progressive #'gen-line-rand-linspace)))))

;;; ---------------------------------------------------------------------------
;;; Example Usage
;;; ---------------------------------------------------------------------------

#|
;; Generate and print a spatial poem with random indentation
(let ((poem (generate-spatial-poem :stanzas 3 :avg-stanza 5)))
  (print-poem-spatial poem))

;; Generate pyramid-shaped poem
(let ((poem (generate-spatial-poem :stanzas 2 :avg-line 6 :generator :sine)))
  (print-poem-spatial poem))

;; Generate cascading poem (staircase effect)
(let ((poem (generate-spatial-poem :avg-stanza 10 :generator :progressive)))
  (print-poem-spatial poem))

Example output (pyramid effect):
(3,6):    ------
(4,8):     --------
(5,10):      ----------
(3,6):    ------

Example output (cascade effect):
(0,7): -------
(1,8):  --------
(2,9):   ---------
(3,7):    -------
|#
