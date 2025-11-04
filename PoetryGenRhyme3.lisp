;; ============================================================================
;; PoetryGenRhyme3.lisp - Poetry Form Generator with Basic Rhyme Schemes
;; ============================================================================
;; This version extends the indentation system by adding RHYME SCHEME GENERATION.
;;
;; DESIGN DECISION: Lines are now triples (rhyme . (spaces . syllables)).
;; The rhyme is represented as an integer that maps to a letter (0='a', 1='b', etc.).
;; This enables generation of traditional poetic forms with rhyme patterns like
;; ABAB, AABB, ABCABC, etc.
;;
;; DESIGN DECISION: Generate rhyme scheme AFTER structure generation.
;; First we build the poem structure (stanzas, lines, indentation), then we
;; overlay a rhyme scheme on top. This separation of concerns allows independent
;; variation of structure and rhyme, and enables consistent rhyme schemes across
;; complex structures.
;;
;; DESIGN DECISION: Random rhyme assignment based on total line count.
;; The number of distinct rhymes is 1 to (total_lines/2), ensuring enough variety
;; without making every line unique. This probabilistically creates both repeated
;; and unique rhymes.
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

(defun gen-line-rand (i)
  (cons (random 5)
	(funcall (up-down (floor (/ *avg-line* 2))) *avg-line*)))

(defun gen-line-sine (i)
  (let ((n (max (floor (+ *avg-line* (funcall (sines 3 -3 1 2) i))) 2)))
    (cons (floor (/ n 2)) n)))

(defun gen-line-rand-linspace (i)
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

;; ============================================================================
;; RHYME SCHEME GENERATION
;; ============================================================================

(defun total-lengths (p)
  "Count total number of lines across all stanzas.
   DESIGN DECISION: Use reduce for functional composition. This enables
   pure calculation without mutating state or using loops."
  (reduce #'(lambda (x y) (+ x (length y))) p :initial-value 0))

(defun add-rhymes (p)
  "Add rhyme scheme to existing poem structure.
   DESIGN DECISION: Two-level mapping to preserve stanza structure.
   - Outer mapcar: iterate over stanzas, preserving stanza boundaries
   - Inner mapcar: iterate over lines within each stanza
   - Each line gets a random rhyme index from [0, rhymes-1]

   DESIGN DECISION: rhymes = random(1, total_lines/2)
   This creates variety: short poems may have all different rhymes (no pattern),
   longer poems will have repeated rhymes (forming patterns). The randomness
   means each generation produces different rhyme densities, from sparse rhyming
   (many unique rhymes) to dense rhyming (few rhymes, much repetition)."
  (let ((rhymes (+ 1 (random (floor (/ (total-lengths p) 2))))))
    (mapcar
     #'(lambda (s)
	 (mapcar #'(lambda (l) (cons (random rhymes) l)) s)) p)))

(defun print-line (l)
  "Print line with rhyme scheme annotation.
   Format: '(indent,length) R: [spaces]------'
   where R is the rhyme letter (a, b, c, ...)

   DESIGN DECISION: Rhyme letter appears between structure and visualization.
   This shows the abstract rhyme scheme (letters) alongside the concrete
   spatial form (indentation and dashes).

   DESIGN DECISION: Use ASCII lowercase letters starting at 'a' (code 97).
   This matches standard poetry notation (e.g., 'sonnet = ABAB CDCD EFEF GG').
   Limitation: poems with >26 distinct rhymes will wrap to non-letter characters,
   but this is acceptable as most traditional forms use <10 rhyme sounds."
  (let ((s "")
	(rhyme (car l))
	(llen (cddr l))
	(slen (cadr l)))
    (dotimes (i slen)
      (setf s (concatenate 'string " " s)))
    (dotimes (i llen)
      (setf s (concatenate 'string s "-")))
    (format t "(~a,~a) ~a: ~a~%" slen llen (code-char (+ 97 rhyme)) s)))

;; takes a list of stanzas and prints it
(defun print-poem (poem)
  (dolist (s poem)
    (dolist (l s)
      (print-line l))
    (format t "~%")))

(defun main (argv)
  "Command-line interface with rhyme scheme generation.
   DESIGN DECISION: Pipeline architecture: structure generation → rhyme addition → printing
   (gen-poem ...) creates the spatial/structural form
   (add-rhymes ...) overlays the rhyme scheme
   (print-poem ...) renders the complete form

   This pipeline separation enables:
   - Reusing existing structure generators unchanged
   - Experimenting with different rhyme algorithms independently
   - Potential future: save intermediate representations for further processing"
  (let* ((fun-choice (parse-integer (nth 1 argv)))
	 (num-stanza (parse-integer (nth 2 argv)))
	 (avg-stanza (parse-integer (nth 3 argv)))
	 (*avg-line* (parse-integer (nth 4 argv)))
	 (line-fun
	  (cond ((= fun-choice 0) #'gen-line-rand)
		((= fun-choice 1) #'gen-line-sine)
	        ((= fun-choice 2) #'gen-line-rand-linspace))))
    (setf *random-state* (make-random-state t))
    (print-poem (add-rhymes (gen-poem num-stanza avg-stanza line-fun)))))
  
