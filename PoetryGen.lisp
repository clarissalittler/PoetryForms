;; generating match constraints
;; there are line matching constraints, where the lines need to be the same length and
;; ending matching constraints
;; there's also the possibility of generating line lengths according to a function

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
  (funcall (up-down (floor (/ *avg-line* 2))) *avg-line*))


(defun gen-line-sine (i)
  (max (floor (+ *avg-line* (funcall (sines 3 -3 1 2) i))) 2))

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
  (let ((s ""))
    (dotimes (i l)
      (setf s (concatenate 'string "-" s)))
    (format t "~a: ~a~%" l s)))

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
		((= fun-choice 1) #'gen-line-sine))))
    (setf *random-state* (make-random-state t))
    (print-poem (gen-poem num-stanza avg-stanza line-fun))))
  
