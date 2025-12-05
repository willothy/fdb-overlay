# { stdenv, autoPatchelfHook, fetchurl, lib, xz, zlib }:
#
# stdenv.mkDerivation (finalAttrs:
# let
#   version = finalAttrs.version;
#   baseUrl = "https://github.com/apple/foundationdb/releases/download/${version}";
# in
# {
#   pname = "libfdb_c";
#   version = "7.4.5";
#   sha256 = "f3eb95d649fc9a2193cfa22d6871ad01c03b23c341f2b6e8e4668a0f5609a1f4";
#   libSha256 = "d2c7b4f4e1f3c8b5e6a1c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8g9h0i1j2k3l4";
#
#
#   # extra file from the same release
#   src = fetchurl {
#     url = "${baseUrl}/fdb-headers-${finalAttrs.version}.tar.gz";
#     sha256 = "${finalAttrs.sha256}";
#   };
#
#   libObject = fetchurl {
#     url = "${baseUrl}/libfdb_c.x86_64.so";
#     sha256 = "${finalAttrs.libSha256}";
#   };
#
#   nativeBuildInputs = [ autoPatchelfHook xz zlib ];
#
#   unpackPhase = ":";
#
#   installPhase = ''
#     runHook preInstall
#
#     mkdir -p $out/include
#
#     cp include/fdb_c.h $out/include/
#
#     # original .so
#     cp ${finalAttrs.libObject} $out/include/libfdb_c.so
#     chmod 555 $out/include/libfdb_c.so
#
#     runHook postInstall
#   '';
# })

{ stdenv, autoPatchelfHook, fetchurl, xz, zlib }:

stdenv.mkDerivation (finalAttrs:
let
  version = "7.4.5";
  baseUrl = "https://github.com/apple/foundationdb/releases/download/${version}";

  # Headers tarball – fetchTarball gives us an already-unpacked directory
  headersSrc = builtins.fetchTarball {
    # adjust name if needed
    url = "${baseUrl}/fdb-headers-${version}.tar.gz";
    # sha256 = "006f3441af279c0a5af38ca6ad2192f41e0c02711005e1295aa650c40f0781d9";
    sha256 = "sha256:0w9f190fsfnay85k1i798sbwk34c850903hbv8a9z0w5x157097f";
  };

  # Prebuilt shared library
  libfdbSo = fetchurl {
    url = "${baseUrl}/libfdb_c.x86_64.so";
    sha256 = "f3eb95d649fc9a2193cfa22d6871ad01c03b23c341f2b6e8e4668a0f5609a1f4";
  };
in
{
  pname = "libfdb_c";
  inherit version;

  # src is "real source": the headers directory
  src = headersSrc;

  # Standard: library in out, headers in dev
  outputs = [ "out" ];

  nativeBuildInputs = [ autoPatchelfHook xz zlib ];

  # src is already a directory, so stdenv just copies it into $PWD;
  # we don't need to touch unpackPhase at all.
  # unpackPhase = ":";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/include"

    # install the shared library
    install -m755 ${libfdbSo} "$out/include/libfdb_c.so"

    # copy headers from the fetched tarball dir
    # adjust this path if the tarball has a prefix dir
    cp "$src/fdb_c.h" "$out/include/fdb_c.h"
    cp "$src/fdb.options" "$out/include/fdb.options"
    cp "$src/fdb_c_apiversion.g.h" "$out/include/fdb_c_apiversion.g.h"
    cp "$src/fdb_c_options.g.h" "$out/include/fdb_c_options.g.h"

    runHook postInstall
  '';
}
)
