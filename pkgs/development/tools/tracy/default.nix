{ lib
, stdenv
, fetchFromGitHub

, capstone
, darwin
, dbus
, freetype
, glfw
, hicolor-icon-theme
, pkg-config
, tbb
}:

stdenv.mkDerivation rec {
  pname = "tracy";
  version = "0.10";

  src = fetchFromGitHub {
    owner = "wolfpld";
    repo = "tracy";
    rev = "v${version}";
    sha256 = "sha256-DN1ExvQ5wcIUyhMAfiakFbZkDsx+5l8VMtYGvSdboPA=";
  };

  patches = lib.optionals (stdenv.isDarwin && !(lib.versionAtLeast stdenv.hostPlatform.darwinMinVersion "11")) [
    ./0001-remove-unifiedtypeidentifiers-framework
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    capstone
    freetype
    glfw
  ] ++ lib.optionals stdenv.isLinux [
    dbus
    hicolor-icon-theme
    tbb
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.AppKit
    darwin.apple_sdk.frameworks.Carbon
  ] ++ lib.optionals (stdenv.isDarwin && lib.versionAtLeast stdenv.hostPlatform.darwinMinVersion "11") [
    darwin.apple_sdk.frameworks.UniformTypeIdentifiers
  ];

  env.NIX_CFLAGS_COMPILE = toString ([ ]
    # Apple's compiler finds a format string security error on
    # ../../../server/TracyView.cpp:649:34, preventing building.
    ++ lib.optional stdenv.isDarwin "-Wno-format-security"
    ++ lib.optional stdenv.isLinux "-ltbb"
    ++ lib.optional stdenv.cc.isClang "-faligned-allocation"
    # workaround issue #19098
    ++ lib.optional (stdenv.cc.isClang && stdenv.isDarwin) "-fno-lto");

  buildPhase = ''
    runHook preBuild

    make -j $NIX_BUILD_CORES -C profiler/build/unix release LEGACY=1
    make -j $NIX_BUILD_CORES -C import-chrome/build/unix/ release
    make -j $NIX_BUILD_CORES -C capture/build/unix/ release
    make -j $NIX_BUILD_CORES -C update/build/unix/ release

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D ./profiler/build/unix/Tracy-release $out/bin/Tracy
    install -D ./import-chrome/build/unix/import-chrome-release $out/bin/import-chrome
    install -D ./capture/build/unix/capture-release $out/bin/capture
    install -D ./update/build/unix/update-release $out/bin/update

    runHook postInstall
  '';

  postFixup = lib.optionalString stdenv.isDarwin ''
    install_name_tool -change libcapstone.4.dylib ${capstone}/lib/libcapstone.4.dylib $out/bin/Tracy
  '';

  meta = with lib; {
    description = "A real time, nanosecond resolution, remote telemetry frame profiler for games and other applications";
    homepage = "https://github.com/wolfpld/tracy";
    platforms = platforms.linux ++ platforms.darwin;
    license = licenses.bsd3;
    mainProgram = "Tracy";
    maintainers = with maintainers; [ mpickering nagisa paveloom ];
  };
}
