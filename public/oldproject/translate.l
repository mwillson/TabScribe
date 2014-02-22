;;;; AUTHOR - Mark Willson (mwillson)

;;;; DESCRIPTION - Translation code that takes our proprietary tab descriptions
;;;; and regurgitates new ones of the desired instruments.
;;;; First line of inputfile is origin instrument tuning scheme.
;;;; Second line of inputfile is outgoing instrument tuning scheme.
;;;; Third line is list representation of original tab.
 
;;;; example inputfile: 
;;;; (g c e a)
;;;; (((e 1)(g 2)(d 1))(d 3)((g 7h9)(d 5))(d 7)(d 5h7))    

;;;;     Comes from this original tab
;;;;     e|-1----------------|
;;;;     g|-2-----7h9--------|
;;;;     d|-1--3--5--7--5h7--|
;;;;     b|------------------|
;;;;     a|------------------|
;;;;     e|------------------|

;;;; CONVENTION NOTE - All functions deeper in the call hierarchy are higher up
;;;;                   (i.e. closer to the top) in the file.
;;;;                   For example, alt-note calls circular, which is defined 
;;;;                   above it.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   FUNCTION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; SNOC
;; append something to the END of a list

(defun snoc (s l)
  (cond
    ((null l)
      (list s)
    )
    (t
      (cons (car l) (snoc s (cdr l)))
    )
  )
)

;; CIRCULAR
;; define a circular list, given a regular list

(defun circular (items)
  (setf (cdr (last items)) items)
  items
)

;; ALT-NOTE
;; give a string (i.e. on the guitar), a number of halfsteps, and a string to
;; put that note on, and get back a duple (e.g. (g 7)) representing the new
;; place to play the original note

(defun alt-note (fromstring numsteps tostring &aux curpitch newnum)

  ;; pitch-classes is a circular list of all pitch classes
  (setf pitch-classes
        (circular (list 'a 'a# 'b 'c 'c# 'd 'd# 'e 'f 'f# 'g 'g#))
  )

  ;; set curpitch to the needed pitch class
  (setf curpitch (find-pitch-class fromstring numsteps)) 

  ;; loop, starting at tostring note, until curpitch (the needed note) is found
  (do ((currentpc nil (pop pitch-classes))
      )
      ((equal currentpc tostring) (setf newnum 0))
  )
  (do ((currentpc tostring (pop pitch-classes))
       (currnum 0 (1+ currnum))
      )
      ((equal currentpc curpitch) (setf newnum currnum))
  )
  
  ;; ret a list with the new string and fret num
  (list tostring newnum)
) 

;; FIND-PITCH-CLASS
;; get a pitch class for a given string and fret

(defun find-pitch-class (string fret)
  (setf pitch-classes
        (circular (list 'a 'a# 'b 'c 'c# 'd 'd# 'e 'f 'f# 'g 'g#))
  )  
  ;; pop from pitch-classes till you get the string pitch
  (do ((currentpc nil (pop pitch-classes))
       (currnum 0 (1+ currnum))
      )
      ((equal currentpc string) (setf curpitch currentpc))
  )
  ;; pop from pitch classes 'fret' number of times to get the needed note
  (dotimes (i fret)
    (setf curpitch (pop pitch-classes))
  )
  curpitch
)

; SIMPLE-NOTELIST
;; given a note list of the form ((string fret)(string fret)...), construct
;; a list of simply the pitch classes each of these duples represent

(defun simple-notelist (lst &aux currentpc retval)
  (setf retval nil)
  (dolist (x lst)
    (setf currentpc (find-pitch-class (first x) (second x)))
    (setf retval (snoc currentpc retval))
  )
  retval
)

;; MAKE-FRETLIST
;; make a list of frettings for the chord notes on a given string

(defun make-fretlist (string pitches &aux result)
  (setf pitch-classes
        (circular (list 'a 'a# 'b 'c 'c# 'd 'd# 'e 'f 'f# 'g 'g#))
  )
  (dotimes (i (list-length pitches))
    ;; pop from pitch-classes till you get the string pitch
    (do ((currentpc nil (pop pitch-classes))
         (currnum 0 (1+ currnum))
        )
        ((equal currentpc string) (setf curpitch currentpc))
    )
    (do ((currentpc curpitch (pop pitch-classes))
         (currnum 0 (1+ currnum))
        )
        ((equal currentpc (nth i pitches)) 
         (setf result (snoc currnum result))
        )
    ) 
  )
  result
)

;; PRODUCT
;; The product of two lists, a list and and empty list, or a list and a symbol

(defun product (l1 l2)
  (cond 
    ((null l2)
      l1
    )
    (t
      (let (templist '())
        (dolist (item1 l1)
          (dolist (item2 l2)
            (cond
              ((listp item2)
                (setf templist (snoc (list* item1 item2) templist))
              )
              (t
                (setf templist (snoc (list item1 item2) templist))
              )
            )
          )
        )
        templist
      )
    )
  )
)

;; CART-PRODUCT
;; cartesian product of some list of potential frettings

(defun cart-product (pf)
  (cond
    ((null pf)
      nil
    )
    (t
      (product (car pf) (cart-product (cdr pf)))
    )
  )
)

;; FIND-CHORDS
;; given a tuning scheme and a simple list of pitches, return a list of
;; possible ways to play the chord

(defun find-chords (scheme pitches &aux possfrets currnum)
  (setf possfrets nil)
  (setf currnum 0)
  (dotimes (i (list-length scheme))
    (setf possfrets (snoc (make-fretlist (nth currnum scheme) pitches) 
                          possfrets)
    )
    (setf currnum (+ currnum 1))
  )
  (cart-product possfrets)
)

;; CHORD-ALTS
;; get a list of alternative chords for a given "chord" and tuning scheme

(defun chord-alts (toscheme notelist &aux simpl retlist altslist)
  (setf simpl (simple-notelist notelist))
  (find-chords toscheme simpl)
)

;; NOTE-ALTS
;; get a list of alternatives for a given note and tuning scheme

(defun note-alts (toscheme note &aux retlist)
  (setf retlist nil)
    ;; for each string in new tuning scheme, get the alternate note and add it
    ;; to the list to be returned
  (dolist (x toscheme)
    (setf retlist (cons (alt-note (first note) (second note) x) retlist))
  )
  (reverse retlist)
)

;; RANDOM-ALT
;; get a random alternative note

(defun random-alt (lst)
  (nth (random (list-length lst)) lst)
)

;; ALTS-LIST
;; give back a list which contains, for each note/chord in the tablist, a list
;; of alternatives

(defun translate-line (toscheme tablist &aux retlist) 
  (cond
    ((null tablist)
      nil
    )
    ((listp (caar tablist))  
      (cons (find-best-chord toscheme (chord-alts toscheme (car tablist))) 
            (translate-line toscheme (cdr tablist)))
    )
    ((symbolp (caar tablist))
      (cons (random-alt (note-alts toscheme (car tablist)))
            (translate-line toscheme (cdr tablist))) 
    )
  )
)

;; COMPUTE-FITNESS
;; determines a 'fitness' for a given chord, which is a general measure
;; of its playability

(defun compute-fitness (chord &aux temp prod retval)
  (setf temp (remove 0 chord))
  (setf prod nil)
  (setf retval 0)
  (cond
    ((null temp)
      (setf retval 0)
    )
    ((equal (list-length temp) 1)
      (setf retval 0)
    )
    (t
      (setf prod (cart-product (list temp temp)))
      (setf l1 nil)
      (setf l2 nil)
      (dolist (x prod)
        (setf l1 (snoc (first x) l1))
        (setf l2 (snoc (second x) l2))
      )
      (setf prod (mapcar #'- l1 l2))
      (dolist (x prod)
        (setf retval (+ retval (abs x)))
      )
    )
  )
  retval
)

;; TRANSLATED-CHORD
;; puts chord into useable form

(defun translated-chord (tuning chord)
  (mapcar #'list tuning (first chord))
)

;; FIND-BEST-CHORD
;; goes through the list of possible chords and constantly updates what it
;; thinks is the 'best' one so far, according to a predefined fitness function.

(defun find-best-chord (tuning lst &aux best fitn)
  (setf best '(() 100))
  (dolist (chord lst)
    (setf fitn (compute-fitness chord))
    (cond
      ((< fitn (second best))
        (setf best (list chord fitn))
      )
      (t
        
      )
    )
  )
  (translated-chord tuning best)
)

(defun string-conv (line &aux ret)
  (setf ret "")
  (dolist (x line)
    (cond
      ((listp x)
        (dolist (y x)
          (setf ret (concatenate 'string (coerce y 'character) ret))
        )
      )
      (t
        (setf ret (concatenate 'string (coerce x 'string) ret))
      )
    )
  )
  ret
)

;; PROCESS-TAB-LINE
;; look at a tab line and output its translation to a file

(defun process-tab-line (tuning line &aux linesym output)
  (setf linesym (read-from-string line))
  (setf linesym (translate-line tuning linesym)) 
  (with-open-file (stream "output.txt" :direction :output :if-exists :append)
    (format stream "~A~%" (prin1-to-string linesym))
  )
)

;; READ-AND-PROCESS
;; read an input file and process tab info

(defun read-and-process (&aux currline tuning)
  (setf currline 1)
  (setf tuning nil)
  (let ((in (open "something.txt")))
    (when in
        (loop for line = (read-line in nil)
          while line
          do (cond 
               ((equal currline 1)
                (setf tuning (read-from-string line))
               )
               (t
                (process-tab-line tuning line)
               )
             )
             (setf currline (+ currline 1))      
        )
      (close in)
    )
  )
)
