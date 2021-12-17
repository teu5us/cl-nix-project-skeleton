{ pkgs, inputs }:

with pkgs;

if builtins.pathExists ./quicklisp-to-nix.nix
  then
    let
      lispInputs = import ./lisp.nix { inherit pkgs; };
    in
    mkShell {
      buildInputs = lispInputs ++ inputs ++ [
        sbcl
      ];
    }
  else
    mkShell {
      shellHook = ''
        trap "echo -e \"\n\nquicklisp-to-nix exited\n\"" EXIT
        cd ./nix-lisp
        echo -e "\n Running quicklisp-to-nix\n"
        nix-shell --pure --run "quicklisp-to-nix --local . && exit"
        exit
      '';
    }
