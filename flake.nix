{
  description = "Paper Blossoms - L5R Character Manager (Qt6)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Qt6 core (includes core, gui, widgets, sql, xml, printsupport, etc.)
            qt6.qtbase

            # Qt6 WebEngine (for webenginewidgets module)
            qt6.qtwebengine

            # Qt6 tools (uic, rcc, moc, lrelease, lupdate, etc.)
            qt6.qttools

            # Build tools
            cmake
            pkg-config
          ];

          nativeBuildInputs = with pkgs; [
            # Wrap Qt apps so they find plugins, translations, etc.
            qt6.wrapQtAppsHook
          ];

          shellHook = ''
            echo "======================================"
            echo " Paper Blossoms - Qt6 Dev Shell"
            echo "======================================"
            echo ""
            echo "Qt version: $(qmake -query QT_VERSION 2>/dev/null || qmake6 -query QT_VERSION 2>/dev/null)"
            echo ""
            echo "Available Qt6 tools:"
            echo "  moc    : $(command -v moc   || echo 'not found')"
            echo "  uic    : $(command -v uic   || echo 'not found')"
            echo "  rcc    : $(command -v rcc   || echo 'not found')"
            echo "  qmake  : $(command -v qmake || echo 'not found')"
            echo "  lrelease: $(command -v lrelease || echo 'not found')"
            echo ""
            echo "To build the project:"
            echo "  qmake PaperBlossomsSolution.pro && make"
            echo ""
            echo "To build just the app:"
            echo "  cd PaperBlossoms && qmake PaperBlossoms.pro && make"
            echo ""
            echo "To build just the tests:"
            echo "  cd TestPaperBlossoms && qmake TestPaperBlossoms.pro && make"
            echo ""
            echo "To run the application:"
            echo "  ./PaperBlossoms/PaperBlossoms"
            echo ""
            echo "To run the tests:"
            echo "  ./TestPaperBlossoms/TestPaperBlossoms"
            echo ""
            echo "======================================"
          '';
        };
      }
    );
}
