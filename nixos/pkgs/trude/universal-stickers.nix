{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  cargo,
  rustc,
  rustPlatform,
  qt6,
  kdePackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "universal-stickers";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "TrudeEH";
    repo = "universal-stickers";
    rev = "eb1f555a1b3e17a60102f54642d65ed041e560f5";
    hash = "sha256-kIDl7SANn+ZVwnic/XXwzREsQAcv1ttgJgOCOMi8jDw=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-IjD40TcPL2TypZiIxAi/v8sD3Lq0OUjnjs0o/OfjfAo=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    cargo
    rustc
    rustPlatform.cargoSetupHook
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    kdePackages.kglobalaccel
  ];

  strictDeps = true;

  configurePhase = ''
    runHook preConfigure

    cmake -S desktop -B build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=$out

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    cmake --build build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cmake --install build
    runHook postInstall
  '';

  meta = {
    description = "Sticker and GIF picker built with Qt and Rust";
    homepage = "https://github.com/TrudeEH/universal-stickers";
    license = lib.licenses.mit;
    mainProgram = "universal-stickers";
    platforms = lib.platforms.linux;
  };
})
