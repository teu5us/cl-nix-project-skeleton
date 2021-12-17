# ql-to-nix-shell

This is a skeleton for a Common Lisp project.

The goal is to reuse the facilities provided by nixpkgs to generate expressions
for quicklisp packages.

# Usage

1. Enter required systems line by line in `ql.txt`.
2. Run `nix-shell`:
   - If no expressions have been generated before:
     1. `ql-to-nix.lisp` and `top-package.emb`, the sources for which are
        distributed with nixpkgs, are patched and installed
     2. `quicklisp-to-nix` is called inside `./nix-lisp` with arguments
        `--local` (provided by patching) and `.` for current directory
     3. `nix-shell` exits
   - If expressions have been generated:
     1. `./nix-lisp/lisp.nix`  is imported 
     2. Packages in `ql.txt` are used to create inputs for your shell
     3. A wrapper `lisp` is provided to load `linedit` when it is installed

## Note:

- Overrides in `./nix-lisp/quicklisp-to-nix-overrides.nix` are to be written
  manually.
- Provided `.envrc` uses `lorri`

# What is patched in quickisp-to-nix

1. `quicklisp-to-nix` when called locally should check if requested quicklisp
   package already exists in the nixpkgs tree, that is why we patch
   `ql-to-nix.lisp`
2. `top-package.emb` is the template for final `quicklisp-to-nix.nix` and it
   uses a relative path to the nixpkgs tree to load `define-package.nix`, which
   makes it unusable in a local shell. Instead, we pass `buildLispPackage` as an argument

# TODO

- [ ] Test for bugs
