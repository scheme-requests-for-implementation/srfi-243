(import (scheme base)
        (scheme char)
        (scheme read)
        (scheme write))

;; (port-position port)
;; (set-port-position! port position)
(cond-expand
 (gauche
  (import (only (gauche base) port-position set-port-position!))))

(define (with-input-from-string string thunk)
  (call-with-port (open-input-string string)
    (lambda (port)
      (parameterize ((current-input-port port))
        (thunk)))))

(define (writeln object)
  (write object)
  (newline))

(define (skip-whitespace)
  (let loop ()
    (let ((char (peek-char)))
      (unless (or (eof-object? char) (not (char-whitespace? char)))
        (read-char)
        (loop)))))

(define (skip-unreadable-object)
  (skip-whitespace)
  (unless (eqv? #\# (read-char))
    (error "Nope"))
  (unless (eqv? #\< (read-char))
    (error "Nope"))
  (let loop ((items '()))
    (let ((item (read)))
      (cond ((eof-object? item)
             (error "Missing >"))
            ((eqv? '|>| item)
             (cons '|<unreadable>| (reverse items)))
            (else
             (loop (cons item items)))))))

(define (read-with-skip)
  (let ((start (port-position (current-input-port))))
    (define (rewind)
      (set-port-position! (current-input-port) start))
    (guard (err
            (read-error?
             (rewind)
             (guard (err
                     (read-error?
                      (rewind)
                      (read)))
                    (skip-unreadable-object))))
           (read))))

(define (read-all-with-skip)
  (let loop ((items '()))
    (let ((item (read-with-skip)))
      (if (eof-object? item)
          (reverse items)
          (loop (cons item items))))))

(define (main)
  (define input
    "123 #<this is an (unreadable . object)> 456")
  (with-input-from-string input
    (lambda () (for-each writeln (read-all-with-skip)))))

(main)
