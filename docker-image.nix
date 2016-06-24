{ pkgs ? import <nixpkgs> {} }:

with pkgs;
let baseImage = dockerTools.pullImage {
      imageName = "ubuntu";
      imageTag = "xenial";
      #imageId  = "fpco/stack-build:latest";
      sha256 = "126sl503r962bfagy5srd1mqyqqx40f3mgpv9cavkxddn7la85k0";
    };
    sparkleShell = import ./shell.nix {};
    deriv = buildEnv {  # dockerTools has a mergeDrvs functions also. Not tested
      name = "sparklenix-container-env";
      paths = sparkleShell.nativeBuildInputs; ## ++ [haskellPackages.stack];
    };
in
dockerTools.buildImage {
  name = "sparklenix-container";
  fromImage = baseImage;
  contents = deriv;

  # runAsRoot = ''
  #    #!${stdenv.shell}
  # '';

  config = {
    Cmd = [ "/bin/bash" ];
    Env = [ "LD_LIBRARY_PATH=${sparkleShell.LD_LIBRARY_PATH}:${gmp.out}/lib"
            "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" ];
            # PATH is necessary because stack will append its own dirs to it
  };
}


### USE IT WITH:
# $   nix-build docker-image.nix && docker load < result
###