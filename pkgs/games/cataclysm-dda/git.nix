{ stdenv, callPackage, CoreFoundation
, tiles ? true, Cocoa
, debug ? false
}:

let
  inherit (stdenv.lib) substring;
  inherit (callPackage ./common.nix { inherit tiles CoreFoundation Cocoa debug; }) common utils;
  inherit (utils) fetchFromCleverRaven;
in

stdenv.mkDerivation (common // rec {
  pname = common.pname + "-git";
  version = "2019-11-22";

  src = fetchFromCleverRaven {
    rev = "a6c8ece992bffeae3788425dd4b3b5871e66a9cd";
    sha256 = "0ww2q5gykxm802z1kffmnrfahjlx123j1gfszklpsv0b1fccm1ab";
  };

  makeFlags = common.makeFlags ++ [
    "VERSION=git-${version}-${substring 0 8 src.rev}"
  ];

  meta = with stdenv.lib.maintainers; common.meta // {
    maintainers = common.meta.maintainers ++ [ rardiol ];
  };
})
