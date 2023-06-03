(import (srfi 243))

(guard (err
        (unreadable-error?
         (display "unreadable: ")
         (write (unreadable-object-stand-in
                 (unreadable-error-object err)))
         (newline)))

       (read-from-string "(here is an unreadable object #[1 2 #[3 4 5]])"))
