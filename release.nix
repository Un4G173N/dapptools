{ ... }:

let
  system = (system: (import ./default.nix { inherit system; }));
  linux = system "x86_64-linux";
  darwin = system "x86_64-darwin";

  ethereum-test-suite = pkgs: pkgs.fetchFromGitHub {
    owner = "ethereum";
    repo = "tests";
    rev = "7e361956bd68f5cac72fe41f29e5734ee94ae2de";
    sha256 = "0l5qalgbscr77vjhyf7b542055wnp4pddpfslnypp5sqws5w940w";
  };

  hevmTestReport = pkgs: pkgs.runCommand "hevm-test-report" {} ''
    mkdir -p $out/nix-support
    export PATH=${pkgs.hevm}/bin:$PATH
    ${pkgs.hevm}/bin/hevm vm-test-report \
      --tests ${ethereum-test-suite pkgs} > $out/index.html
    echo report testlog $out index.html > $out/nix-support/hydra-build-products
  '';

in rec {
  dapphub.linux.stable = with linux.pkgs; {
    inherit dapp;
    inherit seth;
    inherit hevm;
    inherit keeper;
    inherit setzer;
    inherit solc-versions;
    inherit go-ethereum;
    inherit go-ethereum-unlimited;

    hevm-test-report = hevmTestReport linux.pkgs;
  };

  dapphub.linux.master = with linux.pkgs.master; {
    inherit dapp;
    inherit seth;
    inherit hevm;

    hevm-test-report = hevmTestReport linux.pkgs.master;
  };

  dapphub.darwin.stable = with darwin.pkgs; {
    inherit dapp;
    inherit seth;
    inherit hevm;
    # inherit keeper;
    inherit setzer;
    inherit solc-versions;
    inherit go-ethereum;
    inherit go-ethereum-unlimited;
  };

  dapphub.darwin.master = with darwin.pkgs.master; {
    inherit dapp;
    inherit seth;
    inherit hevm;
    inherit dappsys;
    inherit dappsys-legacy;
  };
}
