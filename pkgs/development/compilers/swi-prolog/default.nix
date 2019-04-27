{ stdenv, fetchurl, jdk, gmp, readline, openssl, libjpeg, unixODBC, zlib
, libXinerama, libarchive, db, pcre, libedit, libossp_uuid, libXft, libXpm
, libSM, libXt, freetype, pkgconfig, fontconfig, cmake, libXext, makeWrapper ? stdenv.isDarwin
}:

let
  version = "8.0.2";
in
stdenv.mkDerivation {
  name = "swi-prolog-${version}";

  src = fetchurl {
    url = "http://www.swi-prolog.org/download/stable/src/swipl-${version}.tar.gz";
    sha256 = "abb81b55ac5f2c90997c0005b1f15b74ed046638b64e784840a139fe21d0a735";
  };

  buildInputs = [ jdk gmp readline openssl libjpeg unixODBC libXinerama
    libarchive db pcre libedit libossp_uuid libXft libXpm libSM libXt libXext
    zlib freetype pkgconfig fontconfig cmake ]
  ++ stdenv.lib.optional stdenv.isDarwin makeWrapper;

  # hardeningDisable = [ "format" ];

  cmakeFlags = "-DCMAKE_BUILD_TYPE=Release";

  checkPhase = ''
    ctest -j $NIX_BUILD_CORES --output-on-failure
  '';

  # For macOS: still not fixed in upstream: "abort trap 6" when called
  # through symlink, so wrap binary.
  # We reinvent wrapProgram here but omit argv0 pass in order to not
  # break PAKCS package build. This is also safe for SWI-Prolog, since
  # there is no wrapping environment and hence no need to spoof $0
  postInstall = stdenv.lib.optionalString stdenv.isDarwin ''
    local prog="$out/bin/swipl"
    local hidden="$(dirname "$prog")/.$(basename "$prog")"-wrapped
    mv $prog $hidden
    makeWrapper $hidden $prog
  '';

  meta = {
    homepage = http://www.swi-prolog.org/;
    description = "A Prolog compiler and interpreter";
    license = stdenv.lib.licenses.bsd2;

    platforms = stdenv.lib.platforms.unix;
    maintainers = [ stdenv.lib.maintainers.meditans stdenv.lib.maintainers.atnnn ];
  };
}
