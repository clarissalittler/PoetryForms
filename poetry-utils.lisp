;;;; poetry-utils.lisp
;;;; Common utilities for poetry form generation
;;;; Extracted from multiple generator versions to eliminate duplication

;;; =============================================================================
;;; Random Number Utilities
;;; =============================================================================

(defun up-down (r)
  "Creates a function that returns a value with random variation.
   Given a radius r, returns a function that adds random variation
   in the range [-r, r) to its input."
  #'(lambda (x) (+ x (- (random (* 2 r)) r))))

(defun up-down-half (r)
  "Returns a random value around r with variation of +/- r/2."
  (funcall (up-down (floor (/ r 2))) r))

;;; =============================================================================
;;; Signal Generation (for shaped poetry)
;;; =============================================================================

(defun sines (&rest args)
  "Creates a composite sine wave function from multiple components.
   Each argument in args is a coefficient for a sine wave of different frequency.
   Returns a function that takes time and returns the sum of all sine waves."
  #'(lambda (time)
      (let ((res 0))
        (dotimes (i (length args))
          (setf res (+ res (* (nth i args) (sin (/ time (+ 1 i)))))))
        res)))

(defun rand-list (avg-size low-bound up-bound)
  "Generates a random list of numbers.
   The list length varies around avg-size, and each element is
   a random number between low-bound and up-bound."
  (let ((l (up-down-half avg-size)))
    (loop for x from 1 to l
          collecting (+ low-bound (random (- up-bound low-bound))))))

;;; =============================================================================
;;; List Manipulation Utilities
;;; =============================================================================

(defun palindrome (l)
  "Creates a palindrome by appending a list to its reverse.
   Example: (palindrome '(a b c)) => (a b c c b a)"
  (append l (reverse l)))

(defun rotate-list (l n)
  "Rotates a list l by n positions to the left.
   Example: (rotate-list '(a b c d) 1) => (b c d a)"
  (if (= n 0)
      l
      (rotate-list (append (cdr l) (cons (car l) nil)) (- n 1))))

(defun rot-array (a n)
  "Rotates an array a by n positions.
   Returns a new array with elements rotated."
  (let* ((l (length a))
         (a-new (make-array l)))
    (dotimes (i l)
      (setf (aref a-new (mod (+ i n) l)) (aref a i)))
    a-new))

;;; =============================================================================
;;; Random Selection Utilities
;;; =============================================================================

(defun random-from (i r)
  "Returns a random integer in the range [i, r)."
  (+ i (random (- r i))))

(defun make-list-f (n f)
  "Creates a list of n elements by repeatedly calling function f."
  (loop for x from 1 to n collecting (funcall f)))

;;; =============================================================================
;;; Aggregate Functions
;;; =============================================================================

(defun total-lengths (p)
  "Calculates the total number of lines across all stanzas in poem p."
  (reduce #'(lambda (x y) (+ x (length y))) p :initial-value 0))
