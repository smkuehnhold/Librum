{
  description = "librum";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-23.11;
  };

  outputs = { self, nixpkgs }: let 
    pkgs = nixpkgs.legacyPackages."x86_64-linux";

    inherit (pkgs) stdenv cmake qt6 rapidfuzz-cpp;

    mupdf = pkgs.mupdf.override { enableCxx = true; };

    boostDI = builtins.fetchurl { url = "https://raw.githubusercontent.com/boost-ext/di/cpp14/include/boost/di.hpp"; sha256 = "8j3qYL7MrLNkTwshnT7LPaxQyk9rHbn1R1o3+ucsBgU="; };
  in {
    packages."x86_64-linux".default = stdenv.mkDerivation {
      pname = "librum";
      version = "0.11.0";

      src = ./.;

      nativeBuildInputs = [ 
        cmake
        rapidfuzz-cpp
      ];
  
      buildInputs = [
        qt6.full
        mupdf
      ];
  
      cmakeFlags = [
        "-DCMAKE_BUILD_TYPE=Release"
        "-DBUILD_TESTS=Off"
      ];

      postPatch = ''
        substituteInPlace CMakeLists.txt \
          --replace "add_subdirectory(libs/rapidfuzz-cpp)" "find_package(rapidfuzz REQUIRED)"

        substituteInPlace src/application/CMakeLists.txt \
          --replace ''\'''${MUPDF_OUTPUT}' "${mupdf.out}/lib/libmupdfcpp.so"

        substituteInPlace src/application/CMakeLists.txt \
          --replace ''\'''${PROJECT_SOURCE_DIR}/libs/mupdf/include' "${mupdf.dev}/include/mupdf"

        substituteInPlace src/dependency_injection.hpp \
          --replace "../libs/di/include/boost/di.hpp" "${boostDI}"
      '';
    };
  };
}