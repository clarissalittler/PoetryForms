;;;; ============================================================================
;;;; Shared Utilities for Poetry Forms Generation
;;;; ============================================================================
;;;; This file contains all the common utility functions that were duplicated
;;;; across the original generator files. Now they live in one place!
;;;;
;;;; Categories:
;;;; - Random variation functions
;;;; - Signal generation (sine waves)
;;;; - List manipulation utilities
;;;; ============================================================================

(in-package #:poetry-forms.utils)

;;; ---------------------------------------------------------------------------
;;; Random Variation Functions
;;; ---------------------------------------------------------------------------

(defun up-down (r)
  "Create a randomization function that varies input by ±r.

   DESIGN DECISION: Return functions instead of values to enable composability.
   up-down returns a function that can be applied to any base value, making it
   reusable across different contexts without re-specifying the range each time.

   DESIGN DECISION: Uniform distribution across [-r, r] range gives equal
   probability to all variations, producing unpredictable but bounded variation.

   Example:
     (funcall (up-down 5) 10)  => returns value in [5, 15]"
  #'(lambda (x) (+ x (- (random (* 2 r)) r))))

(defun up-down-half (r)
  "Apply random variation of ±r/2 to r itself.

   This is commonly used to vary counts (stanza lines, etc.) where you want
   variation around a target but don't want the variation range to be as wide
   as the target value itself.

   Example:
     (up-down-half 10)  => returns value around 10, ±2.5 (i.e., [7, 12])"
  (funcall (up-down (floor (/ r 2))) r))

(defun random-from (i r)
  "Generate random integer in range [i, r).

   Simple utility for picking from a range. Used for selecting constraint
   targets, rotation amounts, etc."
  (+ i (random (- r i))))

;;; ---------------------------------------------------------------------------
;;; Signal Generation (Sine Waves)
;;; ---------------------------------------------------------------------------

(defun sines (&rest args)
  "Create a function that superimposes multiple sine waves.

   DESIGN DECISION: Multiple frequencies create complex, natural-looking patterns.
   Each argument becomes the amplitude of a sine wave at frequency 1/(i+1).
   This allows 'tuning' the visual complexity by adjusting amplitudes.

   Example:
     (sines 3 -3 1 2) creates interference patterns like ripples in water

   The resulting function takes a 'time' parameter and returns the sum of all
   sine waves evaluated at that time.

   Mathematical form:
     f(t) = Σ(args[i] * sin(t / (i+1)))

   Used for:
   - Creating flowing visual patterns in line lengths
   - Generating smooth transitions between states
   - Creating organic-looking variations"
  #'(lambda (time)
      (let ((res 0))
        (dotimes (i (length args))
          (setf res (+ res (* (nth i args) (sin (/ time (+ 1 i)))))))
        res)))

;;; ---------------------------------------------------------------------------
;;; List Manipulation Utilities
;;; ---------------------------------------------------------------------------

(defun rand-list (avg-size low-bound up-bound)
  "Generate random list of integers for parameterizing signals.

   Creates a list of random length (around avg-size, with ±50% variation)
   where each element is a random integer in [low-bound, up-bound).

   Used primarily for generating random sine wave parameters, creating
   unpredictable but interesting wave patterns.

   Example:
     (rand-list 5 -3 3)  => might return (-2 1 -1 0 2 1)"
  (let ((l (up-down-half avg-size)))
    (loop for x from 1 to l
          collecting (+ low-bound (random (- up-bound low-bound))))))

(defun palindrome (l)
  "Create palindrome by appending reversed copy of list.

   DESIGN DECISION: Simple symmetry primitive for creating mirror-image patterns.

   Used for creating symmetric lines in concrete poetry and visual forms.

   Example:
     (palindrome '(a b c))  => (a b c c b a)"
  (append l (reverse l)))

(defun make-list-f (n f)
  "Create list by calling function f exactly n times.

   DESIGN DECISION: Each call to f generates a new value, creating
   variability within structured length. This is like make-list but with
   dynamic generation rather than repeating a single element.

   Example:
     (make-list-f 5 #'rand-foot)  => generates 5 different random feet

   Compare to:
     (make-list 5 :initial-element (rand-foot))  => same foot 5 times"
  (loop for x from 1 to n collecting (funcall f)))

(defun rotate-list (l n)
  "Rotate list l by n positions to the left (cyclically).

   Used for implementing pantoum-like forms where stanzas are rotations
   of each other.

   Example:
     (rotate-list '(a b c d) 1)  => (b c d a)
     (rotate-list '(a b c d) 2)  => (c d a b)

   DESIGN DECISION: Recursive implementation is clean and handles edge cases.
   For n=0, returns original list. For n>0, recursively rotates."
  (if (= n 0)
      l
      (rotate-list (append (cdr l) (cons (car l) nil)) (- n 1))))

(defun rot-array (a n)
  "Rotate array elements by n positions.

   DESIGN DECISION: Cyclic rotation using modular arithmetic.
   Element at index i moves to index (i+n) mod length.

   This implements the 'rotate' constraint, enabling pantoum-like forms
   where stanza patterns permute cyclically.

   This is the array equivalent of rotate-list, used when working with
   the array-based representation in the more sophisticated generators."
  (let* ((l (length a))
         (a-new (make-array l)))
    (dotimes (i l)
      (setf (aref a-new (mod (+ i n) l)) (aref a i)))
    a-new))

;;; ---------------------------------------------------------------------------
;;; Utilities Usage Notes
;;; ---------------------------------------------------------------------------

#|
These utilities form the mathematical and structural foundation of the
poetry generators. Key design principles:

1. COMPOSABILITY: Functions return functions (up-down, sines) to enable
   flexible combination and reuse.

2. RANDOMNESS AS FOUNDATION: All variation is rooted in controlled randomness,
   creating organic-feeling forms that don't feel mechanically regular.

3. SIGNAL PROCESSING INSPIRATION: The sine wave utilities treat poetry
   generation as a kind of signal processing, where visual patterns emerge
   from mathematical functions.

4. SYMMETRY PRIMITIVES: palindrome and rotation functions provide building
   blocks for symmetric and repeating structures.

Usage pattern across generators:
- Early generators (basic, spatial) use mainly up-down and sines
- Middle generators (whitespace, metrical) add list manipulation
- Advanced generators (constrained) use rotation and array utilities
|#
