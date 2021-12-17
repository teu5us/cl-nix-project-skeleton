{pkgs, clwrapper, quicklisp-to-nix-packages}:
let
  addNativeLibs = libs: x: { propagatedBuildInputs = libs; };
  skipBuildPhase = x: {
    overrides = y: ((x.overrides y) // { buildPhase = "true"; });
  };
  multiOverride = l: x: if l == [] then {} else
    ((builtins.head l) x) // (multiOverride (builtins.tail l) x);
  lispName = (clwrapper.lisp.pname or (builtins.parseDrvName clwrapper.lisp.name).name);
  ifLispIn = l: f: if (pkgs.lib.elem lispName l) then f else (x: {});
  ifLispNotIn = l: f: if ! (pkgs.lib.elem lispName l) then f else (x: {});
  extraLispDeps = l: x: { deps = x.deps ++ l; };
in
{}
