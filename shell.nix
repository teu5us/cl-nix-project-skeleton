{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  inputs = [];
in
import ./nix-lisp/shell-builder.nix { inherit pkgs inputs; }
