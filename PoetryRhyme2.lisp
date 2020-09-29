(defvar *line-number* 0)
(defvar *total-lines* 0)
(defvar *stanza-array* nil)
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

(defun get-stanza-length (s)
  (let ((st (aref *stanza-array* s)))
    (if (arrayp st)
	(length st)
	(case (car st) ;for the constraints we have they're all the same but not necessarily
	  (=line (get-stanza-length (cadr st)))
	  (rotate (get-stanza-length (cadr st)))))))

(defun choose-stanza-con (s)
  (let ((rando (random 10))
	(const-st (if (> s 0) (random s) 0)))
    (cond ((< rando 2) (list '=line const-st))
	  ((< rando 4) (list 'rotate const-st (random (get-stanza-length s))))
	  (t nil))))

(defun rhyme-to-rep (rhyme)
  (if (null rhyme)
      ""
      (let ((ty (car rhyme))
	    (rhyme-char (string (code-char (+ 97 (cadr rhyme))))))
	(case ty
	  (rhyme rhyme-char)
	  (slant (concatenate 'string rhyme-char "/"))
	  (=word (format nil "=~a" (cadr rhyme)))))))
  
(defun choose-line-con (rhymes cur-line)
  (let ((rando (random 10)))
    (cond ((< rando 4) (list 'rhyme (random rhymes)))
	  ((< rando 8) (list 'slant (random rhymes)))
	  ((> cur-line 0) (list '=word (random cur-line)))
	  (t nil))))

(defun gen-stanza (s avg-st)
  (let ((constr (choose-stanza-con s)))
    (if (not constr)
	(let ((ls (up-down-half avg-st)))
	  (setf (aref *stanza-array* s)
		(make-array ls :initial-element nil))
	  (incf *total-lines* ls))
	(progn
	  (setf (aref *stanza-array* s) constr)
	  (incf *total-lines* (get-stanza-length constr))))))

(defun rot-array (a n)
  (let* ((l (length a))
	 (a-new (make-array l)))
    (dotimes (i l)
      (setf (aref a-new (mod (+ i n) l)) (aref a i)))
    a-new))

(defun gen-lines-cons (s-index st rhymes)
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
  (dotimes (i (length s)) 
    (let ((constr (choose-line-con rhymes *line-number*)))
      (setf (aref s i) (cons (funcall line-fun *line-number*) constr))
      (incf *line-number*))))

(defun gen-lines (s line-fun rhymes)
  (let ((st (aref *stanza-array* s)))
    (if (arrayp (type-of st))
	(gen-lines-free st line-fun rhymes)
	(gen-lines-cons s st rhymes))))
      
(defun gen-poem (num-stanzas avg-stanza line-fun)
  (let* ((total-stanzas (funcall (up-down 2) num-stanzas))
	 (*stanza-array* (make-array total-stanzas :initial-element nil))
	 (rhymes 0))
    (dotimes (i total-stanzas)
      (gen-stanza i avg-stanza))
    (setf rhymes (random *total-lines*))
    (dotimes (i total-stanzas)
      (gen-lines i line-fun rhymes))))

(defun print-line (l)
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
  (dotimes (i (length *stanza-array*))
    (let ((st (aref *stanza-array* i))) 
      (dotimes (j (length st))
	(print-line (aref st j))))
    (format t "~%")))

(defun main (argv)
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
