;; ============================================================================
;; PoetryWhitespace.lisp - Poetry Generator with Fine-Grained Whitespace Control
;; ============================================================================
;; This version treats whitespace as INTEGRAL to the line structure, not just
;; leading indentation. Lines become sequences of blanks and content.
;;
;; DESIGN DECISION: Lines are now lists of symbols representing each position.
;; Each position can be either 'b (blank space) or '- (content syllable).
;; Example: (b b - - b - -) = "  -- - --"
;;
;; DESIGN RATIONALE: This enables:
;; - Internal word spacing (caesuras, gaps within lines)
;; - Concrete poetry where spacing IS the form
;; - Visual patterns with interleaved content and space
;; - Fine control over rhythm and pacing through spatial arrangement
;;
;; DESIGN EVOLUTION: This is more flexible than the (indent . length) pair model
;; because space can appear ANYWHERE in the line, not just at the start.
;; This supports modernist and experimental poetry forms.
;; ============================================================================

;;Okay so what we're going to be doing here in this version is treating
;;line structure as a thing that is a mix of blank space and word space
;;so a line will now be a list like
;; (#\SPACE #\- #\* #- #\SPACE #\SPACE)

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
;; LINE GENERATION STRATEGIES - SPATIAL PATTERNS
;; ============================================================================

(defun gen-line-rand (i)
  "Generate line with random mixture of blanks and content.
   DESIGN DECISION: 30% chance of blank, 70% content at each position.
   This creates irregular but content-heavy lines with occasional gaps.
   The weighting prevents lines from being mostly empty while still
   allowing interesting internal spacing."
  (declare (ignore i))
  (loop for x from 1 to (funcall (up-down (floor (/ *avg-line* 2))) *avg-line*)
	collecting (let ((r (random 10)))
		     (cond ((< r 3) 'b)
			   (t '-)))))

(defun rand-list (avg-size low-bound up-bound)
  "Generate random list of integers for sine wave parameterization.
   Used to create varied, unpredictable wave patterns."
  (let ((l (up-down-half avg-size)))
    (loop for x from 1 to l
	  collecting (+ low-bound (random (- up-bound low-bound))))))

(defun gen-line-half-space (f)
  "Create line generator with leading blank space.
   DESIGN DECISION: First half is blank, second half is content.
   The length-determining function f controls total line length,
   creating variable indentation effects. This is more structured
   than random but less fine-grained than signal-based approaches."
  #'(lambda (i)
      (let ((n (funcall f i)))
	(append
	 (make-list (floor (/ n 2)) :initial-element 'b)
	 (make-list n :initial-element '-)))))

(defun gen-line-sine ()
  "Generate lines with sine-wave-based lengths and half-space indentation.
   DESIGN DECISION: Combine parametric sine waves with structured spacing.
   Random sine parameters create unique visual patterns each run, while
   the half-space structure keeps lines readable and structured."
  (let ((sins (apply #'sines (rand-list 5 -3 3))))
    (gen-line-half-space #'(lambda (x) (floor (+ *avg-line* (funcall sins x)))))))

(defun gen-line-signal (f)
  "Generate line where EACH POSITION is determined by a signal function.
   DESIGN DECISION: Sample signal at each position; positive = content, negative = blank.
   This creates organic, wave-like patterns of content and space flowing through
   the line. The signal can be ANY function (sine, square, noise, etc.), enabling
   infinite variety of spatial patterns.

   The position calculation (i * avg-line + x) gives each line a unique 'window'
   into the signal, creating continuity across lines when appropriate."
  #'(lambda (i)
      (let ((len (up-down-half *avg-line*)))
	(loop for x from 1 to len
	      collecting (if (> (funcall f (+ (* i *avg-line*) x)) 0)
			     '-
			     'b)))))

(defun palindrome (l)
  "Create palindrome by appending reversed copy of list.
   DESIGN DECISION: Simple symmetry primitive for creating mirror-image patterns."
  (append l (reverse l)))

(defun gen-line-signal-sym (f)
  "Like gen-line-signal but creates symmetric (palindromic) lines.
   DESIGN DECISION: Generate half the line, then mirror it.
   This creates visual symmetry and balance, aesthetically pleasing for
   concrete poetry. Every line becomes a symmetric pattern around its center."
  #'(lambda (i)
      (let ((len (floor (/ (up-down-half *avg-line*) 2))))
	(palindrome (loop for x from 1 to len
	      collecting (if (> (funcall f (+ (* i *avg-line*) x)) 0)
			     '-
			     'b))))))

(defun gen-line-horiz-sines ()
  "Generate lines using horizontal sine waves (non-symmetric).
   DESIGN DECISION: Random sine wave parameterization for unpredictable
   but smooth patterns. Each run creates a new 'signature' wave pattern."
  (let ((sins (apply #'sines (rand-list 5 -3 3))))
    (gen-line-signal sins)))

(defun gen-line-horiz-sines-sym ()
  "Generate symmetric lines using horizontal sine waves.
   DESIGN DECISION: Combine smooth sine wave variation with palindromic
   symmetry for aesthetically balanced, organic-looking forms."
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
  "Print line as sequence of spaces and dashes with separator bars.
   Format: '| | |-|-| |'
   DESIGN DECISION: Use '|' separators to make individual positions visible.
   Without separators, multiple adjacent spaces are hard to distinguish.
   The bars create a grid-like structure that reveals the underlying
   spatial pattern clearly. This is essential for understanding the
   fine-grained whitespace structure."
  (let ((s ""))
    (dolist (c l)
      (setf s (concatenate 'string s "|"
			   (case c
			     (b " ")
			     (- "-")))))
    (format t "~a~%" s)))

;; takes a list of stanzas and prints it
(defun print-poem (poem)
  (dolist (s poem)
    (dolist (l s)
      (print-line l))
    (format t "~%")))

(defun main (argv)
  "Command-line interface with four spatial generation strategies.
   DESIGN DECISION: Expose four qualitatively different approaches:
   0 = random per-position (chaotic, varied)
   1 = sine with structured indentation (smooth, traditional-ish)
   2 = signal-based horizontal patterns (flowing, organic)
   3 = symmetric signal-based (balanced, mirror-image)

   Each creates a distinct visual aesthetic appropriate for different
   poetic intentions: chaos vs. order, flow vs. structure, etc."
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

;; DESIGN DECISION: Auto-execute main with command-line arguments.
;; This makes the file directly executable as a script, supporting
;; quick experimentation without needing to load into a REPL.
(main *posix-argv*)
