{ pkgs }:

with pkgs;

let
  buildLispPackage = lispPackages.buildLispPackage;
  qlPkgsFor = clwrapper: callPackage ./quicklisp-to-nix.nix {
    inherit clwrapper buildLispPackage;
  };
  localQlPkgs = dontRecurseIntoAttrs (qlPkgsFor (wrapLisp sbcl));
  qlPkgs = localQlPkgs // quicklispPackagesSBCL;
  lp = recurseIntoAttrs (qlPkgs // (lispPackagesFor (wrapLisp sbcl)));
  sbclrc = writeScript "sbclrc" ''
    (if (member "--no-linedit" sb-ext:*posix-argv* :test 'equal)
        (setf sb-ext:*posix-argv*
              (remove "--no-linedit" sb-ext:*posix-argv* :test 'equal))
        (when (interactive-stream-p *terminal-io*)
          (require :sb-aclrepl)
          (handler-case (prog1
                          (require :linedit)
                          (funcall (intern "INSTALL-REPL" :linedit) :wrap-current t :eof-quits t))
            (sb-int:extension-failure (c) (declare (ignorable c)) (format t "~%Linedit is not installed.~%")))
          ))
  '';
  lisp = writeScriptBin "lisp" ''
    #!${pkgs.bash}/bin/bash
    ${lp.clwrapper}/bin/common-lisp.sh --load ${sbclrc} "$@"
  '';
  lispInputs = let
    asStrings = builtins.filter (x: x != "")
      (lib.splitString "\n" (builtins.readFile ./quicklisp-to-nix-systems.txt));
  in map (x: builtins.getAttr x lp) asStrings;
in
lispInputs ++ [ lisp lp.clwrapper ]
