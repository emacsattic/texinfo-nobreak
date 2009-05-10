;;; texinfo-nobreak.el --- texinfo line break workarounds

;; Copyright 2006, 2007, 2008 Kevin Ryde
;;
;; Author: Kevin Ryde <user42@zip.com.au>
;; Version: 3
;; Keywords: tex
;; URL: http://www.geocities.com/user42_kevin/texinfo-nobreak/index.html
;;
;; texinfo-nobreak.el is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; texinfo-nobreak.el is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
;; Public License for more details.
;;
;; You can get a copy of the GNU General Public License online at
;; <http://www.gnu.org/licenses>.


;;; Commentary:
;;
;; This is a spot of code to avoid line breaks in texinfo source files at
;; places makeinfo doesn't handle quite right, by setting
;; fill-nobreak-predicate to avoid bad breaks with fill-paragraph etc
;; (including when using filladapt.el).
;;
;; Designed for Emacs 21 and up.

;;; Install:
;;
;; Put texinfo-nobreak.el somewhere in your `load-path', and in .emacs put
;;
;;     (autoload 'texinfo-nobreak-enable "texinfo-nobreak")
;;     (add-hook 'texinfo-mode-hook 'texinfo-nobreak-enable)

;;; History:
;;
;; Version 1 - the first version
;; Version 2 - add some autoloads
;; Version 3 - skip multiple spaces for the benefit of auto-fill


;;; Code:

(defun texinfo-nobreak-p ()
  "Don't break after certain texinfo directives.
This function is for use in `fill-nobreak-predicate' to avoid a
line break after the following two directives, which makeinfo
version 4.7 and 4.8 don't quite handle correctly.

- After \"@:\", since it's not obeyed at the end of a source
  line.

- After \"})\", since an external ref \"(@pxref{Fooing,,, foo,
  Foo Manual})\" at the end of a source line results in two
  spaces after \"...(foo)Fooing.)\".

The easiest workaround for these problems is \"don't do that\" in
the source file, which this line break function ensures.

The \"})\" condition is a lot broader than it needs to be.  Only
an @pxref to an external manual is affected, but it's too hard to
distinguish that from other forms."

  ;; There's no attempt to see if the "@" is actually an escaped "@@" and
  ;; therefore not an "@:" directive, nor likewise "}" actually say "@}".
  ;; It's probably possible to do that, but it'd be tricky and it's unlikely
  ;; an "@@:" or "@})" would be found very often in a real document.

  (save-excursion
    (skip-chars-backward " \t")
    (backward-char 2)
    (or (looking-at "@:\\|})"))))

;;;###autoload
(defun texinfo-nobreak-enable ()
  "Add `texinfo-nobreak-p' to `fill-nobreak-predicate'."

  (cond ((not (boundp 'fill-nobreak-predicate))
         ;; no such feature at all in xemacs 21
         )

        ((get 'fill-nobreak-predicate 'custom-type)
         ;; emacs 22 fill-nobreak-predicate is a hook, add to it buffer-local
         (add-hook 'fill-nobreak-predicate 'texinfo-nobreak-p nil t))

        ;; emacs 21 fill-nobreak-predicate is a variable holding a function
        ((not fill-nobreak-predicate)
         ;; no existing value, plonk our function in
         (set (make-local-variable 'fill-nobreak-predicate)
              'texinfo-nobreak-p))
        (t
         ;; existing value, add ourselves to it (this is a bit nasty)
         (set (make-local-variable 'fill-nobreak-predicate)
              `(lambda ()
                 (or (texinfo-nobreak-p)
                     (,fill-nobreak-predicate)))))))

;; In principle could add texinfo-nobreak-p as a customize option for
;; fill-nobreak-predicate (in emacs 22 where that variable is a hook).  But
;; it's highly texinfo specific and so unlikely to be wanted globally.
;; Instead just show texinfo-nobreak-enable on texinfo-mode-hook.
;;
;; (if (get 'fill-nobreak-predicate 'custom-type)
;;     (custom-add-option 'fill-nobreak-predicate 'texinfo-nobreak-p))

;;;###autoload
(custom-add-option 'texinfo-mode-hook 'texinfo-nobreak-enable)

(provide 'texinfo-nobreak)

;;; texinfo-nobreak.el ends here
