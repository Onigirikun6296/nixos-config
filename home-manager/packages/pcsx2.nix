{
  lib,
  appimageTools,
  fetchurl,
  pkgs,
}: let
  version = "2.4.0";
  pname = "pcsx2";

  src = fetchurl {
    url = "https://github.com/PCSX2/pcsx2/releases/download/v${version}/pcsx2-v${version}-linux-appimage-x64-Qt.AppImage";
    hash = "sha256-LVBh9PKQbyK+/HGarDrOvSaZ+wfGEbyQcJeA4o3qjI4=";
  };

  appimageContents = appimageTools.extractType1 {inherit pname src;};

  pcsx2-desktop = pkgs.writeText "PCSX2.desktop" ''
    [Desktop Entry]
    Version=1.0
    Terminal=false
    Type=Application
    Name=PCSX2
    StartupWMClass=PCSX2
    GenericName=PlayStation 2 Emulator
    Comment=Sony PlayStation 2 emulator
    Exec=pcsx2
    Icon=PCSX2
    Keywords=game;emulator;
    Categories=Game;Emulator;
  '';
in
  appimageTools.wrapType2 rec {
    inherit pname version src;

    extraInstallCommands = ''
      mkdir $out/share/
      mkdir $out/share/applications/
      cp ${pcsx2-desktop} $out/share/applications/PCSX2.desktop
    '';

    meta = {
      description = "Playstation 2 emulator";
      homepage = "https://pcsx2.net";
      downloadPage = "https://github.com/PCSX2/pcsx2/";
      license = with lib.licenses; [
        gpl3Plus
        lgpl3Plus
      ];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      mainProgram = "pcsx2-qt";
      maintainers = with lib.maintainers; [];
      platforms = ["x86_64-linux"];
    };
  }
