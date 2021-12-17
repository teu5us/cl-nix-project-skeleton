{ pkgs ? import <nixpkgs> {} }:
with import (pkgs.path + "/default.nix") {};
let
openssl_lib_marked = import (pkgs.path + "/pkgs/development/lisp-modules/openssl-lib-marked.nix");
qltonixSrc = stdenvNoCC.mkDerivation {
  name = "patched_quicklisp-to-nix";
  src = lispPackages.quicklisp-to-nix.src;
  patchPhase = ''
    # patch ql-to-nix.lisp
    sed -i "7 a (defvar *local-invocation* nil)" ql-to-nix.lisp
    sed -i "218 a (when *local-invocation* (dolist (s (mapcar #'(lambda (str) (cl-user::string-left-trim '(#\\\_) str)) '(${pkgs.lib.concatMapStrings (x: "\\\"" + x + "\\\" ") (builtins.attrNames pkgs.lispPackages)}))) (setf (gethash s seen) t)))" ql-to-nix.lisp
    sed -i "295 a ((equal arg \"--local\") (setf *local-invocation* t))" ql-to-nix.lisp

    # patch top-package.emb
    sed -i "1s#\(pkgs,\)\s\(clwrapper\)#\1 buildLispPackage, \2#" top-package.emb
    sed -i "3s#\(clwrapper\)\s\(pkgs\)#\1 buildLispPackage \2#" top-package.emb
    sed -i "/^[[:space:]]*buildLispPackage\s=.*;$/d" top-package.emb
    sed -i "/^};/{s/^\(\}\);/\1 \/\/ pkgs.lispPackages;/}" top-package.emb
  '';
  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';
};
qltonix = lispPackages.quicklisp-to-nix.overrideAttrs (oa: {
  src = qltonixSrc;
});
self = rec {
  name = "ql-to-nix";
  src = ./.;
  env = buildEnv { name = name; paths = buildInputs; };
  buildInputs = [
    gcc stdenv
    openssl fuse libuv libmysqlclient libfixposix libev sqlite
    freetds
    qltonix lispPackages.quicklisp-to-nix-system-info
  ];
  CPATH = lib.makeSearchPath "include"
    [ libfixposix
    ];
  LD_LIBRARY_PATH = lib.makeLibraryPath
    [ cairo
      freetds
      fuse
      gdk-pixbuf
      glib
      gobject-introspection
      gtk3
      libev
      libfixposix
      libmysqlclient
      libuv
      openblas
      openssl
      openssl_lib_marked
      pango
      postgresql
      sqlite
      webkitgtk
    ]
    + ":${libmysqlclient}/lib/mysql";
};
in stdenv.mkDerivation self
