(define-module (wayland util)
  #:use-module (wayland config)
  #:use-module (bytestructures guile)
  #:use-module (bytestructure-class)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:use-module (srfi srfi-26)
  #:use-module ((system foreign) #:select (null-pointer?
                                           bytevector->pointer
                                           make-pointer
                                           procedure->pointer
                                           pointer->procedure
                                           pointer->bytevector
                                           pointer->string
                                           string->pointer
                                           sizeof
                                           %null-pointer
                                           dereference-pointer
                                           define-wrapped-pointer-type
                                           pointer-address
                                           void))
  #:re-export (bytestructure->pointer
               pointer->bytestructure)
  #:export (char*
            wayland-server->pointer
            wayland-client->pointer
            wayland-client->procedure
            wayland-server->procedure

            make-pointer->string
            string->pointer-address
            %wl-array-struct
            wl-container-of
            wl-log-set-handler-server)
  #:export-syntax (define-wl-server-procedure))

;; (define-syntax-rule (define-callback name)
;;   (define name ))

(define (wayland-server->pointer name)
  (dynamic-func name (dynamic-link %libwayland-server)))

(define (wayland-client->pointer name)
  (dynamic-func name (dynamic-link %libwayland-client)))
(define (wayland-server->procedure return name params)
  (let ((ptr (wayland-server->pointer name)))
    (pointer->procedure return ptr params)))

(define (wayland-client->procedure return name params)
  (let ((ptr (wayland-client->pointer name)))
    (pointer->procedure return ptr params)))

(define-syntax define-wl-server-procedure
  (lambda (x)
    (syntax-case x ()
      ((_ (name args ...) (return-type cname arg-types) body ...)
       (with-syntax ((% (datum->syntax x '%)))
         #'(begin
             (define name
               (let ((% (wayland-server->procedure return-type cname arg-types)))
                 (lambda* (args ...)
                   body ...))))))
      ((o-name (name args ...) (return-type cname arg-types))
       #'(o-name (name args ...) (return-type cname arg-types) (% args ...))))))

(define char* (bs:pointer int8))

(define make-pointer->string (compose (lambda (a) (if (null-pointer? a)
                                                      ""
                                                      (pointer->string a))) make-pointer))

(define string->pointer-address (compose pointer-address string->pointer))

(define %wl-array-struct
  (bs:struct `((size ,size_t)
               (alloc ,size_t)
               (data ,(bs:pointer 'void)))))

(define (wl-log-set-handler-server proc)
  (wayland-server->procedure void "wl_log_set_handler_server" '(*))
  (procedure->pointer 'void (lambda (a b) (proc (pointer->string a) b)) (list '* '*)))

(define (wl-container-of ptr sample member)
  (pointer->bytestructure
   (make-pointer
    (- (pointer-address ptr)
       (bytestructure-offset
        (bytestructure-ref
         (bytestructure sample)
         member))))
   sample))
