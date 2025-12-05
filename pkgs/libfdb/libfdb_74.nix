{ stdenv, autoPatchelfHook, fetchurl, lib, xz, zlib }:

stdenv.mkDerivation (finalAttrs:
let
  version = finalAttrs.version;
  baseUrl = "https://github.com/apple/foundationdb/releases/download/${version}";
in
{
  pname = "libfdb_c";
  version = "7.4.5";
  sha256 = "f3eb95d649fc9a2193cfa22d6871ad01c03b23c341f2b6e8e4668a0f5609a1f4";
  headersSha256 = "d2c7b4f4e1f3c8b5e6a1c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8g9h0i1j2k3l4";

  src = fetchurl {
    url = "${baseUrl}/libfdb_c.x86_64.so";
    sha256 = "${finalAttrs.sha256}";
  };

  # extra file from the same release
  headers = fetchurl {
    url = "${baseUrl}/fdb-headers-${finalAttrs.version}.tar.gz";
    sha256 = "${finalAttrs.headersSha256}";
  };

  nativeBuildInputs = [ autoPatchelfHook xz zlib tar ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/include

    # original .so
    cp $src $out/include/libfdb_c.so
    chmod 555 $out/include/libfdb_c.so

    # untar headers
    tar -xzf ${finalAttrs.extraFile} -C $out/include --strip-components
  '';
})
