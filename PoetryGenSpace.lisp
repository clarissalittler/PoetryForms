;; ============================================================================
;; PoetryGenSpace.lisp - Poetry Form Generator with Indentation (Version 2)
;; ============================================================================
;; This version extends the basic generator by adding INDENTATION as a structural
;; element, enabling concrete poetry and visual effects.
;;
;; DESIGN DECISION: Lines are now (spaces . syllables) pairs instead of just integers.
;; This adds a second dimension to the poem's structure, allowing control over
;; horizontal positioning on the page, not just line length. This is crucial for:
;; - Concrete poetry where visual shape conveys meaning
;; - Stepped or cascading effects
;; - Symmetry and visual rhythm
;;
;; DESIGN EVOLUTION: Building on PoetryGen.lisp by enriching the line representation
;; while keeping the same overall generation architecture (global state, pluggable
;; line functions, stanza-based structure).
;; ============================================================================

;; let's consider the possibility of interesting indentation as a part of the form
;; each line will be represented by a data structure, at first just a pair
;; of (spaces . syllables)

(defvar *poem-line* 0)
(defvar *poem-stanza* 0)
(defvar *constraints* nil)
(defvar *avg-line* 0)


(defun up-down (r)
  #'(lambda (x) (+ x (- (random (* 2 r)) r ))))

;; this is really a stub for what will probably get more complicated
(defun gen-line-f (f)
 (funcall f *poem-line*))

;; ============================================================================
;; LINE GENERATION STRATEGIES WITH INDENTATION
;; ============================================================================

(defun gen-line-rand (i)
  "Generate line with random indentation and random length.
   DESIGN DECISION: Indentation is independent from line length (random 0-5 spaces).
   This creates organic, unpredictable spatial layouts. The 5-space limit keeps
   indentation readable without excessive horizontal offset."
  (cons (random 5)
	(funcall (up-down (floor (/ *avg-line* 2))) *avg-line*)))

(defun gen-line-sine (i)
  "Generate line where indentation is coupled to line length.
   DESIGN DECISION: Indentation = length/2 creates a 'pyramid' or 'diamond' effect
   where longer lines are more indented. This produces visually symmetric forms
   where the poem's shape is more deliberate and architectural."
  (let ((n (max (floor (+ *avg-line* (funcall (sines 3 -3 1 2) i))) 2)))
    (cons (floor (/ n 2)) n)))

(defun gen-line-rand-linspace (i)
  "Generate line where indentation increases with line position.
   DESIGN DECISION: Indentation = line_number/2 creates a 'cascade' or 'staircase'
   effect as the poem progresses. This adds temporal progression to the visual form,
   with early lines left-aligned and later lines increasingly indented."
  (cons (floor (/ i 2))
	(funcall (up-down (floor (/ *avg-line* 2))) *avg-line*)))

(defun sines (&rest args)
  #'(lambda (time)
      (let ((res 0))
	(dotimes (i (length args))
	  (setf res (+ res (* (nth i args) (sin (/ time (+ 1 i)))))))
	res)))

(defun gen-stanza (avg-stanza line-fun)
  (loop for x from 1 to (funcall (up-down 3) avg-stanza)
        do (incf *poem-line*)
	collect (gen-line-f line-fun)))


(defun gen-poem (num-stanza avg-stanza line-fun)
  (loop for x from 1 to (funcall (up-down 2) num-stanza)
	collect (gen-stanza avg-stanza line-fun)))

(defun print-line (l)
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

;; takes a list of stanzas and prints it
(defun print-poem (poem)
  (dolist (s poem)
    (dolist (l s)
      (print-line l))
    (format t "~%")))

(defun main (argv)
  "Command-line interface with three indentation strategies.
   DESIGN DECISION: Add third option (gen-line-rand-linspace) to explore
   position-dependent indentation. The three strategies offer distinct aesthetics:
   0 = random (organic chaos)
   1 = sine-coupled (architectural symmetry)
   2 = progressive (temporal flow)"
  (let* ((fun-choice (parse-integer (nth 1 argv)))
	 (num-stanza (parse-integer (nth 2 argv)))
	 (avg-stanza (parse-integer (nth 3 argv)))
	 (*avg-line* (parse-integer (nth 4 argv)))
	 (line-fun
	  (cond ((= fun-choice 0) #'gen-line-rand)
		((= fun-choice 1) #'gen-line-sine)
	        ((= fun-choice 2) #'gen-line-rand-linspace))))
    (setf *random-state* (make-random-state t))
    (print-poem (gen-poem num-stanza avg-stanza line-fun))))
  
