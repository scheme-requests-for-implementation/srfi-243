(import (srfi 243))

(guard (err
        (unreadable-error?
         (let* ((top (unreadable-error-object err))
                (outer (unreadable-object-stand-in (list-ref top 5)))
                (inner (unreadable-object-stand-in (list-ref outer 2))))
           (define (wr msg obj) (display msg) (write obj) (newline))
           (wr "inner stand-in: " inner)
           (wr "outer stand-in: " outer)
           (wr "top object: " top))))

       (read-from-string "(here is an unreadable object #[1 2 #[3 4 5]])"))
