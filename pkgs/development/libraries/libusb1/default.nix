{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, autoreconfHook
, pkg-config
, enableUdev ? stdenv.isLinux && !stdenv.hostPlatform.isStatic
, udev
, libobjc
, IOKit
, Security
, withExamples ? false
, withStatic ? false
}:

stdenv.mkDerivation rec {
  pname = "libusb";
  version = "1.0.27";

  src = fetchFromGitHub {
    owner = "libusb";
    repo = "libusb";
    rev = "v${version}";
    sha256 = "sha256-OtzYxWwiba0jRK9X+4deWWDDTeZWlysEt0qMyGUarDo=";
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ pkg-config autoreconfHook ];
  propagatedBuildInputs =
    lib.optional enableUdev udev ++
    lib.optionals stdenv.isDarwin [ libobjc IOKit Security ];

  dontDisableStatic = withStatic;

  # libusb-1.0.rc:11: fatal error: opening dependency file .deps/libusb-1.0.Tpo: No such file or directory
  dontAddDisableDepTrack = stdenv.hostPlatform.isWindows;

  configureFlags =
    lib.optional (!enableUdev) "--disable-udev"
    ++ lib.optional (withExamples) "--enable-examples-build";

  preFixup = lib.optionalString enableUdev ''
    sed 's,-ludev,-L${lib.getLib udev}/lib -ludev,' -i $out/lib/libusb-1.0.la
  '';

  postInstall = lib.optionalString withExamples ''
    mkdir -p $out/{bin,sbin,examples/bin}
    cp -r examples/.libs/* $out/examples/bin
    ln -s $out/examples/bin/fxload $out/sbin/fxload
  '';

  meta = with lib; {
    homepage = "https://libusb.info/";
    description = "cross-platform user-mode USB device library";
    longDescription = ''
      libusb is a cross-platform user-mode library that provides access to USB devices.
    '';
    platforms = platforms.all;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ prusnak realsnick ];
  };
}
