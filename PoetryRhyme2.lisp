;; ============================================================================
;; PoetryRhyme2.lisp - Advanced Poetry Generator with Inter-Stanza Constraints
;; ============================================================================
;; This is the most sophisticated version, implementing COMPLEX CONSTRAINT SYSTEMS
;; for generating structured poetic forms with rhyme and stanza relationships.
;;
;; DESIGN DECISION: Array-based representation instead of nested lists.
;; Using arrays (*stanza-array*) allows O(1) random access to any stanza,
;; which is essential for implementing inter-stanza constraints like:
;; - Rotational patterns (stanza B's lines are rotation of stanza A's lines)
;; - Line equality (stanza B has same line count as stanza A)
;; - Shared lines (lines are copied between stanzas)
;;
;; DESIGN DECISION: Two-phase generation: structure first, then content.
;; Phase 1: Generate stanza structure (how many stanzas, constraints between them)
;; Phase 2: Generate line content (respecting pre-determined structure)
;; This separation enables complex forms like villanelles, pantoums, etc.
;;
;; DESIGN DECISION: Probabilistic constraint generation.
;; Constraints are randomly chosen with tuned probabilities to create
;; interesting but not overwhelming structure. Not every stanza has constraints.
;;
;; ARCHITECTURE: Three constraint layers:
;; 1. Stanza-level: How stanzas relate (=line, rotate)
;; 2. Line-level: How lines end (rhyme, slant, =word)
;; 3. Content-level: What lines contain (whitespace patterns)
;; ============================================================================

(defvar *line-number* 0)     ; Global line counter across entire poem
(defvar *total-lines* 0)      ; Total lines in poem (calculated during structure gen)
(defvar *stanza-array* nil)   ; Array of stanzas (enables random access for constraints)
(defvar *avg-line* 0)         ; Average line length parameter

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

(defun gen-line-rand (i)
  (declare (ignore i))
  (loop for x from 1 to (funcall (up-down (floor (/ *avg-line* 2))) *avg-line*)
	collecting (let ((r (random 10)))
		     (cond ((< r 3) 'b)
			   (t '-)))))

(defun rand-list (avg-size low-bound up-bound)
  (let ((l (up-down-half avg-size)))
    (loop for x from 1 to l
	  collecting (+ low-bound (random (- up-bound low-bound))))))

(defun gen-line-half-space (f)
  #'(lambda (i)
      (let ((n (funcall f i)))
	(append
	 (make-list (floor (/ n 2)) :initial-element 'b)
	 (make-list n :initial-element '-)))))

(defun gen-line-sine ()
  (let ((sins (apply #'sines (rand-list 5 -3 3))))
    (gen-line-half-space #'(lambda (x) (floor (+ *avg-line* (funcall sins x)))))))

(defun gen-line-signal (f)
  #'(lambda (i)
      (let ((len (up-down-half *avg-line*)))
	(loop for x from 1 to len
	      collecting (if (> (funcall f (+ (* i *avg-line*) x)) 0)
			     '-
			     'b)))))

(defun palindrome (l)
  (append l (reverse l)))

(defun gen-line-signal-sym (f)
  #'(lambda (i)
      (let ((len (floor (/ (up-down-half *avg-line*) 2))))
	(palindrome (loop for x from 1 to len
	      collecting (if (> (funcall f (+ (* i *avg-line*) x)) 0)
			     '-
			     'b))))))

(defun gen-line-horiz-sines ()
  (let ((sins (apply #'sines (rand-list 5 -3 3))))
    (gen-line-signal sins)))

(defun gen-line-horiz-sines-sym ()
  (let ((sins (apply #'sines (rand-list (+ 3 (random 4)) -3 3))))
    (gen-line-signal-sym sins)))

;; ============================================================================
;; STANZA-LEVEL CONSTRAINT SYSTEM
;; ============================================================================

(defun get-stanza-length (s)
  "Get number of lines in stanza s, following constraint chains if needed.
   DESIGN DECISION: Recursive constraint resolution.
   Stanzas can contain either:
   - An array of lines (actual content): return its length
   - A constraint descriptor: follow the constraint to get the referenced
     stanza's length

   This indirection allows us to generate constraints before generating
   content. Constraints form a DAG (directed acyclic graph) - earlier
   stanzas are 'real', later stanzas can reference earlier ones."
  (let ((st (aref *stanza-array* s)))
    (if (arrayp st)
	(length st)
	(case (car st) ;for the constraints we have they're all the same but not necessarily
	  (=line (get-stanza-length (cadr st)))
	  (rotate (get-stanza-length (cadr st)))))))

(defun choose-stanza-con (s)
  "Probabilistically choose a constraint for stanza s.
   DESIGN DECISION: 40% chance of constraint, 60% chance of free structure.
   - 20% probability: =line (equal line count to previous stanza)
   - 20% probability: rotate (rotated version of previous stanza)
   - 60% probability: nil (no constraint, generate freely)

   The constraint references a random earlier stanza (index < s), ensuring
   forward-only references which prevents circular dependencies.

   DESIGN RATIONALE: These specific constraints enable forms like:
   - =line: Forms with uniform stanza length (sonnets, etc.)
   - rotate: Pantoum-like forms where lines permute between stanzas"
  (let ((rando (random 10))
	(const-st (if (> s 0) (random s) 0)))
    (cond ((< rando 2) (list '=line const-st))
	  ((< rando 4) (list 'rotate const-st (random (get-stanza-length s))))
	  (t nil))))

;; ============================================================================
;; LINE-LEVEL CONSTRAINT SYSTEM (Rhyme and Repetition)
;; ============================================================================

(defun rhyme-to-rep (rhyme)
  "Convert rhyme constraint to human-readable string notation.
   DESIGN DECISION: Different notations for different constraint types:
   - rhyme: 'a', 'b', 'c', ... (standard rhyme scheme notation)
   - slant: 'a/', 'b/', ... (slash indicates approximate/slant rhyme)
   - =word: '=0', '=1', ... (equal-sign + line number indicates repetition)

   This makes the abstract constraint structure immediately readable in output."
  (if (null rhyme)
      ""
      (let ((ty (car rhyme))
	    (rhyme-char (string (code-char (+ 97 (cadr rhyme))))))
	(case ty
	  (rhyme rhyme-char)
	  (slant (concatenate 'string rhyme-char "/"))
	  (=word (format nil "=~a" (cadr rhyme)))))))

(defun choose-line-con (rhymes cur-line)
  "Probabilistically choose an ending constraint for a line.
   DESIGN DECISION: Weighted constraint probabilities for natural variety:
   - 40% rhyme (most common)
   - 40% slant rhyme (near-rhyme, adds subtlety)
   - 20% word repetition (if not first line)

   The rhyme index is random [0, rhymes-1], so the same rhyme sound can
   recur across different lines, creating actual rhyme schemes.

   DESIGN DECISION: =word only available after first line.
   Can't repeat a line that doesn't exist yet. This creates forward
   references to earlier lines in the poem."
  (let ((rando (random 10)))
    (cond ((< rando 4) (list 'rhyme (random rhymes)))
	  ((< rando 8) (list 'slant (random rhymes)))
	  ((> cur-line 0) (list '=word (random cur-line)))
	  (t nil))))

;; ============================================================================
;; STANZA STRUCTURE GENERATION (Phase 1)
;; ============================================================================

(defun gen-stanza (s avg-st)
  "Generate structure for stanza s (without line content).
   DESIGN DECISION: Constraint OR array, never both.
   Either:
   - No constraint: create empty array, size determined by up-down-half
   - Has constraint: store the constraint descriptor itself

   This defers actual line generation until Phase 2, allowing all stanza
   structures to be determined before any content is generated. This is
   essential for inter-stanza constraints.

   Side effect: increments *total-lines* counter, used later to determine
   rhyme scheme density."
  (let ((constr (choose-stanza-con s)))
    (if (not constr)
	(let ((ls (up-down-half avg-st)))
	  (setf (aref *stanza-array* s)
		(make-array ls :initial-element nil))
	  (incf *total-lines* ls))
	(progn
	  (setf (aref *stanza-array* s) constr)
	  (incf *total-lines* (get-stanza-length constr))))))

;; ============================================================================
;; LINE CONTENT GENERATION (Phase 2)
;; ============================================================================

(defun rot-array (a n)
  "Rotate array elements by n positions.
   DESIGN DECISION: Cyclic rotation using modular arithmetic.
   Element at index i moves to index (i+n) mod length.
   This implements the 'rotate' constraint, enabling pantoum-like forms
   where stanza patterns permute cyclically."
  (let* ((l (length a))
	 (a-new (make-array l)))
    (dotimes (i l)
      (setf (aref a-new (mod (+ i n) l)) (aref a i)))
    a-new))

(defun gen-lines-cons (s-index st rhymes)
  "Generate line content for constrained stanza.
   DESIGN DECISION: Two constraint types handled differently:

   =line: Copy structure from referenced stanza but generate new rhyme constraints.
   Takes the FIRST LINE's structure from the referenced stanza and uses it
   for all lines. This creates uniform line structure across stanzas.
   New rhyme constraints mean the stanza can have a different rhyme scheme.

   rotate: Copy the entire referenced stanza and rotate it.
   This creates repeating-line patterns like pantoums, where entire lines
   (including their rhyme constraints) reappear in different positions."
  (let ((fin-st (make-array (get-stanza-length st) :initial-element nil)))
    (setf (aref *stanza-array* s-index) fin-st)
    (case (car st)
      (=line (dotimes (i (get-stanza-length st))
	       (setf (aref fin-st i) (cons (car (aref *stanza-array* (cadr st)))
					   (choose-line-con rhymes *line-number*)))
	       (incf *line-number*)))
      (rotate (progn
		(setf (aref *stanza-array* s-index)
		      (rot-array (aref *stanza-array* (cadr st)) (caddr st)))
		(incf *line-number* (get-stanza-length st)))))))

(defun gen-lines-free (s line-fun rhymes)
  "Generate line content for unconstrained stanza.
   DESIGN DECISION: Fully generative approach.
   Each line gets:
   - Content from line-fun (whitespace pattern generator)
   - Random rhyme constraint
   This creates maximum variety and unpredictability."
  (dotimes (i (length s))
    (let ((constr (choose-line-con rhymes *line-number*)))
      (setf (aref s i) (cons (funcall line-fun *line-number*) constr))
      (incf *line-number*))))

(defun gen-lines (s line-fun rhymes)
  "Dispatch to appropriate line generation strategy.
   DESIGN DECISION: Type-based dispatch.
   Check if stanza contains an array (actual lines) or a constraint descriptor.
   This polymorphic approach keeps the interface uniform while handling
   two fundamentally different cases."
  (let ((st (aref *stanza-array* s)))
    (if (arrayp (type-of st))
	(gen-lines-free st line-fun rhymes)
	(gen-lines-cons s st rhymes))))
      
;; ============================================================================
;; TOP-LEVEL POEM GENERATION
;; ============================================================================

(defun gen-poem (num-stanzas avg-stanza line-fun)
  "Generate complete poem with two-phase approach.

   DESIGN DECISION: Explicit two-phase architecture:
   Phase 1 (Structure):
   - Create stanza array
   - For each stanza, generate structure (array or constraint)
   - Count total lines
   - Determine rhyme scheme density

   Phase 2 (Content):
   - For each stanza, generate line content
   - Respect previously-determined constraints

   DESIGN RATIONALE: Why two phases?
   1. Inter-stanza constraints require knowing all stanza structures first
   2. Rhyme scheme density depends on total line count
   3. Separation of structure from content enables easier debugging and
      potential future features (e.g., saving/loading structures)

   DESIGN DECISION: Rhyme count = random(0, total_lines-1)
   More lines = more potential rhyme sounds = denser rhyme schemes.
   Random selection means some poems will be rhyme-heavy, others sparse."
  (let* ((total-stanzas (funcall (up-down 2) num-stanzas))
	 (*stanza-array* (make-array total-stanzas :initial-element nil))
	 (rhymes 0))
    ;; Phase 1: Generate stanza structures
    (dotimes (i total-stanzas)
      (gen-stanza i avg-stanza))
    ;; Determine rhyme scheme density
    (setf rhymes (random *total-lines*))
    ;; Phase 2: Generate line content
    (dotimes (i total-stanzas)
      (gen-lines i line-fun rhymes))))

;; ============================================================================
;; OUTPUT/VISUALIZATION
;; ============================================================================

(defun print-line (l)
  "Print line with rhyme annotation and whitespace structure.
   Format: 'rhyme: | |-|-| |'

   DESIGN DECISION: Rhyme annotation first, then visual structure.
   The rhyme scheme (a, b/, =3, etc.) appears as a prefix, making it easy
   to read the rhyme pattern vertically down the poem. The visual structure
   follows, showing the spatial/content pattern."
  (let ((s "")
	(line-struct (car l))
	(rhyme (rhyme-to-rep (cdr l))))
    (dolist (c line-struct)
      (setf s (concatenate 'string s "|"
			   (case c
			     (b " ")
			     (- "-")))))
    (format t "~a: ~a~%" rhyme s)))

(defun print-poem ()
  "Print complete poem from global *stanza-array*.
   DESIGN DECISION: Access global state rather than parameter passing.
   This matches the two-phase generation model where the array is built
   globally. Blank lines separate stanzas for readability."
  (dotimes (i (length *stanza-array*))
    (let ((st (aref *stanza-array* i)))
      (dotimes (j (length st))
	(print-line (aref st j))))
    (format t "~%")))

;; ============================================================================
;; COMMAND-LINE INTERFACE
;; ============================================================================

(defun main (argv)
  "Entry point for constrained poetry generation.
   DESIGN DECISION: Same line-fun options as PoetryWhitespace.lisp.
   This maintains consistency across versions - the content generation
   strategies remain the same, but now they're embedded in a sophisticated
   constraint system that controls stanza and rhyme relationships.

   The separation between line-fun (how to make content) and the constraint
   system (how to structure relationships) is a key architectural strength,
   allowing independent variation of content style and structural complexity.

   DESIGN DECISION: Call gen-poem then print-poem separately.
   This makes it explicit that generation and output are separate phases,
   and would allow intermediate processing if needed in the future."
  (let* ((fun-choice (parse-integer (nth 1 argv)))
	 (num-stanza (parse-integer (nth 2 argv)))
	 (avg-stanza (parse-integer (nth 3 argv)))
	 (*avg-line* (parse-integer (nth 4 argv)))
	 (line-fun (cond ((= fun-choice 0) #'gen-line-rand)
			 ((= fun-choice 1) (gen-line-sine))
			 ((= fun-choice 2) (gen-line-horiz-sines))
			 ((= fun-choice 3) (gen-line-horiz-sines-sym)))))
    (setf *random-state* (make-random-state t))
    (gen-poem num-stanza avg-stanza line-fun)
    (print-poem)))
