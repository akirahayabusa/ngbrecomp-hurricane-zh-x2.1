#!/usr/bin/env bash
# The Android build environment in the VM (upstream's packaging/android/build.sh needs): JDK 17, bison, flex,
# python3-venv, and the Android SDK with an NDK, build-tools and a platform in ~/Android/Sdk.
# The SDK licence accepted with the user's consent (2026-11-03).
set -euxo pipefail
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openjdk-17-jdk-headless bison flex python3-venv unzip curl xz-utils
sdk=$HOME/Android/Sdk
mkdir -p "$sdk/cmdline-tools" && cd "$sdk"
zip=commandlinetools-linux-15859902_latest.zip
[ -f "$zip" ] || curl -fsSL -o "$zip" "https://dl.google.com/android/repository/$zip"
echo "4e4c464f145a7512b57d088ac6c278c03c9eea610886b35a5e0804e74eedf583  $zip" | sha256sum -c -
rm -rf cmdline-tools/latest cmdline-tools/cmdline-tools
unzip -q "$zip" -d cmdline-tools && mv cmdline-tools/cmdline-tools cmdline-tools/latest
sm=$sdk/cmdline-tools/latest/bin/sdkmanager
yes | "$sm" --licenses > /dev/null || true
# the versions this was built with (2026-11-03): targetSdk 35 as upstream's manifest
"$sm" --install "ndk;29.0.14206865" "build-tools;35.0.1" "platforms;android-35" > ~/sdk_install.log
# Mesa (Turnip) needs a host glslangValidator >= 12.2; Ubuntu 22.04 has 11.8: built from glslang's source (the one
# packaging/android/build.sh fetches, run it once first if build/android-deps/src/glslang is not there yet)
S=$HOME/ngb/build/android-deps/src/glslang
if [ -d "$S" ] && ! glslangValidator --version 2>/dev/null | grep -q ':1[2-9]\.\|:[2-9][0-9]\.'; then
    cmake -S "$S" -B ~/hostglslang -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++         -DENABLE_OPT=OFF -DGLSLANG_TESTS=OFF -DENABLE_GLSLANG_BINARIES=ON -DBUILD_SHARED_LIBS=OFF
    ninja -C ~/hostglslang glslang-standalone
    sudo cp ~/hostglslang/StandAlone/glslang /usr/local/bin/glslangValidator
fi
ls "$sdk"/ndk "$sdk"/build-tools "$sdk"/platforms
echo ANDROID-SETUP-DONE
