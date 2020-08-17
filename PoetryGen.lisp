(defun up-down (r)
  #'(lambda (x) (+ x (- (random (* 2 r)) r ))))

(defun gen-line (avg-line)
  (funcall (up-down (floor (/ avg-line 2))) avg-line))
 
(defun gen-stanza (avg-stanza avg-line)
  (loop for x from 1 to (funcall (up-down 3) avg-stanza)
	collect (gen-line avg-line)))

(defun gen-poem (num-stanza avg-stanza avg-line)
  (loop for x from 1 to (funcall (up-down 2) num-stanza)
	collect (gen-stanza avg-stanza avg-line)))

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
  (let ((num-stanza (parse-integer (nth 1 argv)))
	(avg-stanza (parse-integer (nth 2 argv)))
	(avg-line   (parse-integer (nth 3 argv))))
    (setf *random-state* (make-random-state t))
    (print-poem (gen-poem num-stanza avg-stanza avg-line))))
  
