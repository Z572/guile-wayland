(use-modules
 (guix packages)
 ((guix licenses) #:prefix license:)
 (guix download)
 (gnu packages freedesktop)
 (guix git-download)
 (guix gexp)
 (guix build-system gnu)
 (gnu packages)
 (gnu packages autotools)
 (gnu packages guile)
 (gnu packages guile-xyz)
 (gnu packages ibus)
 (gnu packages pkg-config)
 (gnu packages texinfo)
 (gnu packages file)
 (gnu packages build-tools))
(define %srcdir
  (dirname (current-filename)))
(package
  (name "guile-wayland")
  (version "0.1")
  (source (local-file "." "guile-wayland-checkout"
                      #:recursive? #t
                      #:select? (git-predicate %srcdir)))
  (build-system gnu-build-system)
  (arguments `(#:make-flags '("GUILE_AUTO_COMPILE=0")))
  (native-inputs
   (list autoconf
         automake-1.16.5
         libtool
         pkg-config
         texinfo
         ))
  (inputs (list guile-3.0 wayland))
  (synopsis "")
  (description "")
  (home-page "")
  (license license:gpl3+))

;; (list
;;  info-reader
;;  bear)