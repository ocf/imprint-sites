{
  description = "OCF Imprint site manifests";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    systems.url = "github:nix-systems/default/main";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
    }:
    let
      forAllSystems =
        fn: nixpkgs.lib.genAttrs (import systems) (system: fn (import nixpkgs { inherit system; }));
    in
    {
      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            fluxcd
            sops
            age
            age-plugin-yubikey
          ];

          shellHook = ''
            export SOPS_AGE_KEY_CMD="age-plugin-yubikey -i"
          '';
        };
      });
    };
}
