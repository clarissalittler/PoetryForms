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

(defun total-lengths (p)
  (reduce #'(lambda (x y) (+ x (length y))) p :initial-value 0))

(defun add-rhymes (p)
  (let ((rhymes (+ 1 (random (floor (/ (total-lengths p) 2))))))
    (mapcar
     #'(lambda (s)
	 (mapcar #'(lambda (l) (cons (random rhymes) l)) s)) p)))

(defun print-line (l)
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
  
