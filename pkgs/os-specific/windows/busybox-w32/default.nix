{ stdenv, buildPackages, fetchurl }:

stdenv.mkDerivation rec {
  name = "busybox-w32-${version}";
  version = "FRP-3128-g241d4d4ac";
  version-tag = "FRP-3128-g241d4d4ac";

  src = fetchurl {
    url = "https://github.com/rmyorston/busybox-w32/archive/${version-tag}.tar.gz";
    sha256 = "169ms3ng2441dn4ikfcf5ynqwbj3s5gxqgsq86hl3923jhgqxycw";
  };

  hardeningDisable = [ "format" "pie" ];

  patches = [ ./install-exe.patch ];

  postPatch = "patchShebangs .";

  configurePhase = ''
    cp configs/mingw64_defconfig .config

    dotconfig () {
      sed -i "/.*$1.*/d" .config
      echo "$1=$2" >> .config
    }

    dotconfig CONFIG_PREFIX "\"$out\""
    dotconfig CONFIG_INSTALL_NO_USR y
    dotconfig CONFIG_CROSS_COMPILER_PREFIX "\"${stdenv.cc.targetPrefix}\""

    export KCONFIG_NOTIMESTAMP=1
    make oldconfig
  '';

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  enableParallelBuilding = true;

  doCheck = false;

  meta = with stdenv.lib; {
    description = "A port of BusyBox to the Microsoft Windows WIN32 API. It brings a subset of the functionality of BusyBox to Windows in a single self-contained native executable.";
    homepage = https://frippery.org/busybox/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ atnnn ];
    platforms = platforms.windows;
    priority = 10;
  };

  passthru.shellPath = "/bin/sh.exe";
}
