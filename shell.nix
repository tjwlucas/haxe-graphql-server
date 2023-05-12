with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    php82
    nodejs
  ];
  shellHook = ''
    alias haxe="npm run haxe"
    alias lix="npm run lix"
  '';
}
