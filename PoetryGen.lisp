;; ============================================================================
;; PoetryGen.lisp - Basic Poetry Form Generator (Version 1)
;; ============================================================================
;; This is the foundational version of the poetry form generator.
;;
;; DESIGN DECISION: Focus on structural form generation, not content generation.
;; The goal is to generate the SHAPE of poems (line lengths, stanza patterns)
;; that writers can fill with their own words. This helps overcome writer's block
;; by providing interesting structural constraints to work within.
;;
;; DESIGN DECISION: Use line lengths (syllable counts) as the primary representation.
;; Lines are represented simply as integers (number of syllables), which allows
;; for quick generation and clear visualization using dashes.
;; ============================================================================

;; generating match constraints
;; there are line matching constraints, where the lines need to be the same length and
;; ending matching constraints
;; there's also the possibility of generating line lengths according to a function

;; Global state variables track position within the poem being generated
;; DESIGN DECISION: Use global state rather than threading state through all functions.
;; This simplifies the code for what is essentially a batch generation process
;; where we generate one complete poem at a time, then reset for the next.
(defvar *poem-line* 0)       ; Current line number (absolute position across all stanzas)
(defvar *poem-stanza* 0)     ; Current stanza number
(defvar *constraints* nil)   ; Future: will hold inter-line and inter-stanza constraints
(defvar *avg-line* 0)        ; Target average line length (set per poem)


;; ============================================================================
;; UTILITY FUNCTIONS: Random Variation and Signal Generation
;; ============================================================================

;; DESIGN DECISION: Return functions instead of values to enable composability.
;; up-down returns a function that can be applied to any base value, making it
;; reusable across different contexts without re-specifying the range each time.
(defun up-down (r)
  "Create a randomization function that varies input by ±r.
   DESIGN DECISION: Uniform distribution across [-r, r] range gives equal
   probability to all variations, producing unpredictable but bounded variation."
  #'(lambda (x) (+ x (- (random (* 2 r)) r ))))

;; DESIGN DECISION: Indirection layer for future extensibility.
;; This stub allows line generation functions to be plugged in without changing
;; the structure of gen-stanza. Future versions could add context-awareness here.
(defun gen-line-f (f)
  "Apply line generation function f to current line number.
   The line number parameter enables position-dependent generation."
 (funcall f *poem-line*))

;; ============================================================================
;; LINE GENERATION STRATEGIES
;; ============================================================================
;; DESIGN DECISION: Multiple generation strategies for variety.
;; Different generators create different aesthetic effects:
;; - Random: organic, unpredictable forms
;; - Sine-based: wave-like visual patterns, rhythmic feel

(defun gen-line-rand (i)
  "Generate random line length around *avg-line* with ±50% variation.
   DESIGN DECISION: 50% variation (±half of average) provides good balance
   between structure and variety. Too little variation feels monotonous,
   too much loses coherent form."
  (funcall (up-down (floor (/ *avg-line* 2))) *avg-line*))

(defun gen-line-sine (i)
  "Generate line length using sine wave for smooth, flowing transitions.
   DESIGN DECISION: Sine wave creates visual patterns when lines are printed,
   producing aesthetically pleasing 'shapes' on the page. The minimum of 2
   ensures lines are always readable (at least 2 syllables)."
  (max (floor (+ *avg-line* (funcall (sines 3 -3 1 2) i))) 2))

(defun sines (&rest args)
  "Create a function that superimposes multiple sine waves.
   DESIGN DECISION: Multiple frequencies create complex, natural-looking patterns.
   Each argument becomes the amplitude of a sine wave at frequency 1/(i+1).
   This allows 'tuning' the visual complexity by adjusting amplitudes.
   Example: (sines 3 -3 1 2) creates interference patterns like ripples in water."
  #'(lambda (time)
      (let ((res 0))
	(dotimes (i (length args))
	  (setf res (+ res (* (nth i args) (sin (/ time (+ 1 i)))))))
	res)))

;; ============================================================================
;; POEM STRUCTURE GENERATION
;; ============================================================================

(defun gen-stanza (avg-stanza line-fun)
  "Generate one stanza with variable number of lines.
   DESIGN DECISION: Vary stanza length by ±3 lines to create organic variation
   between stanzas. The ±3 range prevents too much uniformity while keeping
   stanzas recognizable as related units. Side effect: increments *poem-line*
   to track absolute line position for context-aware generation."
  (loop for x from 1 to (funcall (up-down 3) avg-stanza)
        do (incf *poem-line*)
	collect (gen-line-f line-fun)))

(defun gen-poem (num-stanza avg-stanza line-fun)
  "Generate complete poem structure (list of stanzas).
   DESIGN DECISION: Vary total stanza count by ±2 from target. This is smaller
   variation than line counts because poem-level structure should be more stable.
   Each stanza gets the same line-generation function, creating cohesive style."
  (loop for x from 1 to (funcall (up-down 2) num-stanza)
	collect (gen-stanza avg-stanza line-fun)))

;; ============================================================================
;; OUTPUT/VISUALIZATION
;; ============================================================================
;; DESIGN DECISION: Visual representation using dashes to show poem structure.
;; This creates an immediate visual impression of the poem's shape without
;; requiring actual words. Writers can see the form before filling it.

(defun print-line (l)
  "Print line as visual representation: dashes for syllables.
   Format: 'length: ------'
   DESIGN DECISION: Show both numeric length and visual dashes because:
   - Numbers enable precise counting for syllabic poetry
   - Dashes enable gestalt perception of overall form/shape"
  (let ((s ""))
    (dotimes (i l)
      (setf s (concatenate 'string "-" s)))
    (format t "~a: ~a~%" l s)))

(defun print-poem (poem)
  "Print complete poem with blank lines between stanzas.
   DESIGN DECISION: Blank lines between stanzas create visual separation,
   making the multi-stanza structure immediately apparent."
  (dolist (s poem)
    (dolist (l s)
      (print-line l))
    (format t "~%")))  ; Blank line after each stanza

;; ============================================================================
;; COMMAND-LINE INTERFACE
;; ============================================================================

(defun main (argv)
  "Entry point for command-line usage.
   Arguments: fun-choice num-stanza avg-stanza avg-line
   DESIGN DECISION: Simple numeric interface for quick experimentation.
   fun-choice selects generation strategy (0=random, 1=sine).
   This allows rapid exploration of different structural styles."
  (let* ((fun-choice (parse-integer (nth 1 argv)))
	 (num-stanza (parse-integer (nth 2 argv)))
	 (avg-stanza (parse-integer (nth 3 argv)))
	 (*avg-line* (parse-integer (nth 4 argv)))
	 (line-fun
	  (cond ((= fun-choice 0) #'gen-line-rand)
		((= fun-choice 1) #'gen-line-sine))))
    ;; DESIGN DECISION: Reset random state from system time for true randomness
    ;; each run, ensuring different output every execution.
    (setf *random-state* (make-random-state t))
    (print-poem (gen-poem num-stanza avg-stanza line-fun))))
  
