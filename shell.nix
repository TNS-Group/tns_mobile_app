{ pkgs ? import <nixpkgs> {
    config = {
      allowUnfree = true;
    };
  }
}:

let

  # Required libraries for Flutter Linux Desktop
  libraries = with pkgs; [
    gtk3
    glib
    libepoxy
    libGL
    fontconfig
    harfbuzz
    at-spi2-core
    pango
    cairo
    gdk-pixbuf
    libsysprof-capture # Added to fix sysprof-capture-4.pc error
  ];
in
pkgs.mkShell {
  name = "flutter-env";

  nativeBuildInputs = with pkgs; [
    fvm
    cmake
    ninja
    pkg-config
    clang
  ];

  buildInputs = libraries;

  shellHook = ''
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath libraries}:$LD_LIBRARY_PATH"
    
    # Crucial fix: Include libsysprof-capture in the pkg-config path
    export PKG_CONFIG_PATH="${pkgs.lib.makeSearchPath "lib/pkgconfig" libraries}"

    echo Environment Ready
  '';
}
