{ stdenv
, lib
, fetchFromGitHub
, autoreconfHook
, pkg-config
, libev
, libsodium
, libpcap
}:


stdenv.mkDerivation rec {
  pname = "mlvpn";
  version = "2.3.5";

  src = fetchFromGitHub {
    owner = "zehome";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256-foF8sxFJ3ag1/XfzkRnMubI1NpYyv+bw+Ar4rHn8zlY=";
    # fetchSubmodules = true;
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  buildInputs = [
    libev
    libsodium
    libpcap
  ];
}
