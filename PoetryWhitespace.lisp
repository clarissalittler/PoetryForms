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

(defun gen-stanza (avg-stanza line-fun)
  (loop for x from 1 to (funcall (up-down 3) avg-stanza)
        do (incf *poem-line*)
	collect (gen-line-f line-fun)))


(defun gen-poem (num-stanza avg-stanza line-fun)
  (loop for x from 1 to (funcall (up-down 2) num-stanza)
	collect (gen-stanza avg-stanza line-fun)))

(defun print-line (l)
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
