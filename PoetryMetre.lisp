;;============================================================================
;; PoetryMetre.lisp - Poetry Generator with Metrical Feet
;;============================================================================
;; This version adds CLASSICAL METER as a structural element, building on the
;; whitespace model by giving semantic meaning to content symbols.
;;
;; DESIGN DECISION: Introduce metrical feet as atomic units of rhythm.
;; Instead of generic content ('- symbols), we now use specific foot types
;; representing classical patterns of stressed/unstressed syllables:
;;   'py = pyrrhic  (unstressed-unstressed)  --
;;   'ia = iambic   (unstressed-stressed)    -*
;;   'tr = trochee  (stressed-unstressed)    *-
;;   'sp = spondee  (stressed-stressed)      **
;;   'b  = blank    (space)
;;
;; DESIGN RATIONALE: This enables generation of:
;; - Classical poetic forms (iambic pentameter, trochaic tetrameter, etc.)
;; - Mixed meter poems with controlled rhythmic variation
;; - Visual representation of metrical patterns
;;
;; DESIGN DECISION: Probabilistic foot selection weighted toward iambic.
;; English naturally tends toward iambic rhythm, so we weight it at 50%,
;; with trochaic at 40% and rare feet (pyrrhic/spondee) at 10%.
;; This produces more natural-sounding metrical patterns.
;;============================================================================

;;Okay so what we're going to be doing here in this version is treating
;;line structure as a thing that is a mix of blank space and word space
;;so a line will now be a list like
;; (#\SPACE #\- #\* #- #\SPACE #\SPACE)
;; our first stab will be to have a random choice of disyllables
;; 'py is pyrrhic
;; 'ia is iambic
;; 'tr is trochee
;; 'sp is spondee


(defvar *poem-line* 0)
(defvar *poem-stanza* 0)
(defvar *avg-line* 0)

(defun up-down (r)
  #'(lambda (x) (+ x (- (random (* 2 r)) r ))))

(defun up-down-half (r)
  (funcall (up-down (floor (/ r 2))) r))

(defun sines (&rest args)
  #'(lambda (time)
      (let ((res 0))
	(dotimes (i (length args))
	  (setf res (+ res (* (nth i args) (sin (/ time (+ 1 i)))))))
	res)))

;; this is really a stub for what will probably get more complicated
(defun gen-line-f (f)
 (funcall f *poem-line*))

;; ============================================================================
;; METRICAL FOOT GENERATION
;; ============================================================================

(defun rand-foot ()
  "Generate random metrical foot with weighted probabilities.
   DESIGN DECISION: Probability distribution reflects natural English rhythm:
   - 50% iambic (most common in English, natural speech rhythm)
   - 40% trochaic (second most common, gives variety)
   - 9% pyrrhic (rare, creates light flowing effect)
   - 1% spondee (rare, creates emphasis and weight)

   This weighting produces rhythmically diverse but natural-sounding patterns
   that don't sound forced or artificial."
  (let ((rando (random 10)))
    (cond ((< rando 5) 'ia)
	  ((< rando 9) 'tr)
	  ((< rando 10) 'py)
	  (t 'sp))))

(defun gen-line-rand (i)
  "Generate line with random mixture of blanks and metrical feet.
   DESIGN DECISION: Extend whitespace randomization with metrical feet.
   30% chance of blank creates spatial variation (like PoetryWhitespace.lisp),
   but now the 70% content is metrically structured feet rather than
   undifferentiated syllables. This combines spatial and rhythmic variety."
  (declare (ignore i))
  (loop for x from 1 to (funcall (up-down (floor (/ *avg-line* 2))) *avg-line*)
	collecting (let ((r (random 10)))
		     (cond ((< r 3) 'b)
			   (t (rand-foot))))))

(defun rand-list (avg-size low-bound up-bound)
  "Generate random integer list for parameterizing signals."
  (let ((l (up-down-half avg-size)))
    (loop for x from 1 to l
	  collecting (+ low-bound (random (- up-bound low-bound))))))

(defun make-list-f (n f)
  "Create list by calling function f exactly n times.
   DESIGN DECISION: Each call to f generates a new random foot, creating
   variability within structured length. This is like make-list but with
   dynamic generation rather than repeating a single element."
  (loop for x from 1 to n collecting (funcall f)))

(defun gen-line-half-space (f)
  "Create line with leading blanks and metrical feet.
   DESIGN DECISION: Structured indentation (first half blank) combined with
   metrical feet (second half). The length function f controls visual shape,
   while rand-foot provides rhythmic variety within that shape."
  #'(lambda (i)
      (let ((n (funcall f i)))
	(append
	 (make-list (floor (/ n 2)) :initial-element 'b)
	 (make-list-f n #'rand-foot)))))

(defun gen-line-sine ()
  "Generate metrically structured lines with sine wave length variation.
   DESIGN DECISION: Combine smooth visual patterns (sine wave) with
   metrical content. The visual form flows smoothly while the rhythm varies
   stochastically, creating tension between predictable form and varied meter."
  (let ((sins (apply #'sines (rand-list 5 -3 3))))
    (gen-line-half-space #'(lambda (x) (floor (+ *avg-line* (funcall sins x)))))))

(defun gen-line-signal (f)
  "Generate line where signal determines blank vs. metrical foot.
   DESIGN DECISION: Signal-based spatial control (like PoetryWhitespace.lisp)
   but with metrical feet instead of generic content. Positive signal = foot,
   negative = blank. This creates flowing patterns of rhythm and silence."
  #'(lambda (i)
      (let ((len (up-down-half *avg-line*)))
	(loop for x from 1 to len
	      collecting (if (> (funcall f (+ (* i *avg-line*) x)) 0)
			     (rand-foot)
			     'b)))))

(defun palindrome (l)
  "Create symmetric palindrome for mirror-image patterns."
  (append l (reverse l)))

(defun gen-line-signal-sym (f)
  "Generate symmetric metrical lines using signal function.
   DESIGN DECISION: Combine three concepts:
   1. Signal-based spatial patterning
   2. Metrical foot variety
   3. Palindromic symmetry

   Result: Lines with symmetric visual shape and metrical structure,
   creating formal balance appropriate for ceremonial or structured verse."
  #'(lambda (i)
      (let ((len (floor (/ (up-down-half *avg-line*) 2))))
	(palindrome (loop for x from 1 to len
	      collecting (if (> (funcall f (+ (* i *avg-line*) x)) 0)
			     (rand-foot)
			     'b))))))

(defun gen-line-horiz-sines ()
  "Generate metrically structured lines with horizontal sine wave patterns."
  (let ((sins (apply #'sines (rand-list 5 -3 3))))
    (gen-line-signal sins)))

(defun gen-line-horiz-sines-sym ()
  "Generate symmetric metrical lines with sine wave-based spacing.
   DESIGN DECISION: Maximum complexity - combines smooth wave patterns,
   metrical variety, and palindromic symmetry. This creates highly
   structured, visually balanced forms with rich rhythmic texture."
  (let ((sins (apply #'sines (rand-list (+ 3 (random 4)) -3 3))))
    (gen-line-signal-sym sins)))

(defun gen-stanza (avg-stanza line-fun)
  (loop for x from 1 to (funcall (up-down 3) avg-stanza)
        do (incf *poem-line*)
	collect (gen-line-f line-fun)))


(defun gen-poem (num-stanza avg-stanza line-fun)
  (loop for x from 1 to (funcall (up-down 2) num-stanza)
	collect (gen-stanza avg-stanza line-fun)))

(defun print-line (l)
  "Print line with metrical foot notation.
   Format: '| |-*|**|-|--| |' where:
     ' ' = blank (b)
     '-*' = iambic (ia) - unstressed-stressed
     '*-' = trochaic (tr) - stressed-unstressed
     '**' = spondee (sp) - stressed-stressed
     '--' = pyrrhic (py) - unstressed-unstressed

   DESIGN DECISION: Use * for stress, - for unstressed.
   This visual notation matches traditional scansion marks and makes
   the metrical pattern immediately apparent. The | separators create
   clear foot boundaries, essential for seeing the rhythmic structure.

   DESIGN DECISION: Two-character representation for each foot.
   All feet are disyllabic (two syllables), maintaining uniform visual
   spacing and making it easy to count feet (e.g., iambic pentameter =
   5 iambic feet visible as 5 pairs of characters)."
  (let ((s ""))
    (dolist (c l)
      (setf s (concatenate 'string s "|"
			   (case c
			     (b " ")
			     (- "-")
			     (tr "*-")
			     (sp "**")
			     (py "--")
			     (ia "-*")))))
    (format t "~a~%" s)))

;; takes a list of stanzas and prints it
(defun print-poem (poem)
  (dolist (s poem)
    (dolist (l s)
      (print-line l))
    (format t "~%")))

(defun main (argv)
  "Command-line interface for metrical poetry generation.
   DESIGN DECISION: Four generation strategies covering different approaches
   to combining meter with visual form:

   0 = random (meter + random spatial variation)
   1 = sine-based (meter + smooth flowing shapes)
   2 = signal-horizontal (meter + wave-based spatial patterns)
   3 = signal-symmetric (meter + palindromic symmetry)

   These cover a spectrum from chaos to order, allowing exploration of
   how metrical structure interacts with visual form. Each produces
   qualitatively different aesthetic effects suitable for different
   poetic traditions (free verse, formal verse, concrete poetry, etc.)."
  (let* ((fun-choice (parse-integer (nth 1 argv)))
	 (num-stanza (parse-integer (nth 2 argv)))
	 (avg-stanza (parse-integer (nth 3 argv)))
	 (*avg-line* (parse-integer (nth 4 argv)))
	 (line-fun
	  (cond ((= fun-choice 0) #'gen-line-rand)
		((= fun-choice 1) (gen-line-sine))
		((= fun-choice 2) (gen-line-horiz-sines))
		((= fun-choice 3) (gen-line-horiz-sines-sym)))))
    (setf *random-state* (make-random-state t))
    (print-poem (gen-poem num-stanza avg-stanza line-fun))))
