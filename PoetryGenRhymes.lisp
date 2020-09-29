;; let's consider the possibility of interesting indentation as a part of the form
;; each line will be represented by a data structure, at first just a pair
;; of (spaces . syllables)

;;; okay so first we need to generate the number of stanzas,
;;; then we need /stanza/ constraints
;;; stanza constraints are thing like
;;; `(rotate 4 2 3) which means that 2 is relate to three by rotating four lines
;;; or
;;; `(eq-stanza 4 5) which means that 4 and 5 are equal in lines and constraints
;;;
;;; line constraints/rhymes
;;; (rhyme #'b)
;;; and when we generate new lines we can either attach a previous rhyme or create a new
;;; one.
;;; Caution: doing this would weight lines improperly, we need to do something like
;;; generate the number of rhyming schema in accordance with how many unique line-endings
;;; we have (so then we have to generate equality constraints first)
;;; and we can have a probability of generating slant rhymes (10%?)
;;; So to summarize what we need to do
;;; generate the number of stanzas
;;; generate the stanza constraints
;;; generate the number of lines per stanza given constraints
;;; generate the set of rhyming schema
;;; generate the lines in each stanza along with constraints
;;;   sub-step: propagate constraints based on stanzas
;;; PRINT

(defvar *poem-line* 0)
(defvar *poem-stanza* 0)
(defvar *stanza-constraints* nil)
(defvar *lineconstraints* nil)
(defvar *avg-line* 0)
(defvar *total-lines* 0)
;; (defvar *total-stanzas* 0)
(defvar *next-rhyme-name* 96) ;; we start with #\a by adding one
(defvar *stanza-array* nil)


(defun get-name ()
  (incf *next-rhyme-name*)
  (code-char *next-rhyme-name*))

(defun up-down (r)
  #'(lambda (x) (+ x (- (random (* 2 r)) r ))))

(defun up-down-half (r)
  (funcall (up-down (floor (/ r 2))) r))

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

;; format for stanzas are (constraint . line-list)
;; stanza constraints are either (=line s1 s2)  or (rotate s1 s2 n)
;; we're hardcoding probabilities to start
;; write rand-cond macro later, it'll be useful

(defun random-from (i r)
  (+ i (random (- r i))))

(defun rotate-list (l n)
  (if (= n 0)
      l
      (rotate-list (append (cdr l) (cons (car l) nil)) (- n 1))))

(defun choose-stanza-constraint (s total-stanzas)
  (let ((rando (random 10)))
    (cond ((< rando 2) (list '=line (random-from 0 s)))
	  ((< rando 4) (list 'rotate (random-from 0 s) (+ 1 (length 
	  (t nil))))

;; ;; we'll see if it makes more sense to thread the data or have a global
;; (defun gen-stanza (total-stanzas stanza-length)
;;   (dotimes (i total-stanzas)
;;     (let ((sc (choose-stanza-constraint i total-stanzas)))
;;       (setf *stanza-list* (cons (cons sc  (list nil)) *stanza-list*))))
;;   (setf *stanza-list* (reverse *stanza-list*)))

;;; stanza-length should average around the length +/- 1/2 length
;;; steps: check if there's a constraint for this stanza on this already,
;;;        if there is then grab the previously made stanza and perform the constraints
;;;        and generate the lines
;;;        if not then

(defun gen-stanza (s avg-sl total-stanzas)
  (let ((const (choose-stanza-constraint s total-stanzas)))
    (if (not const)
	(let ((ls (up-down-half avg-sl)))
	  (setf (aref *stanza-array* s)
		(make-array ls :initial-element nil))
	  (incf *total-lines* ls))
	(


(defun gen-poem (avg-stanzas stanza-length)
  (let* ((total-stanzas (funcall (up-down 2) avg-stanzas))
	 (*stanza-array* (make-array total-stanzas :initial-element nil)))
    (dotimes (i total-stanzas)
      (gen-stanza i stanza-length))
    (dotimes (i total-stanzas)
      (gen-lines i))))
      

;; (defun gen-stanza (avg-stanza line-fun)
;;   (loop for x from 1 to (funcall (up-down 3) avg-stanza)
;;         do (incf *poem-line*)
;; 	collect (gen-line-f line-fun)))


;; (defun gen-poem (num-stanza avg-stanza line-fun)
;;   (loop for x from 1 to (funcall (up-down 2) num-stanza)
;; 	collect (gen-stanza avg-stanza line-fun)))

;; (defun print-line (l)
;;   (let ((s "")
;; 	(llen (cdr l))
;; 	(slen (car l)))
;;     (dotimes (i slen)
;;       (setf s (concatenate 'string " " s)))
;;     (dotimes (i llen)
;;       (setf s (concatenate 'string s "-")))
;;     (format t "(~a,~a): ~a~%" slen llen s)))

;; ;; takes a list of stanzas and prints it
;; (defun print-poem (poem)
;;   (dolist (s poem)
;;     (dolist (l s)
;;       (print-line l))
;;     (format t "~%")))

;; (defun main (argv)
;;   (let* ((fun-choice (parse-integer (nth 1 argv)))
;; 	 (num-stanza (parse-integer (nth 2 argv)))
;; 	 (avg-stanza (parse-integer (nth 3 argv)))
;; 	 (*avg-line* (parse-integer (nth 4 argv)))
;; 	 (line-fun
;; 	  (cond ((= fun-choice 0) #'gen-line-rand)
;; 		((= fun-choice 1) #'gen-line-sine)
;; 	        ((= fun-choice 2) #'gen-line-rand-linspace))))
;;     (setf *random-state* (make-random-state t))
;;     (print-poem (gen-poem num-stanza avg-stanza line-fun))))
  
