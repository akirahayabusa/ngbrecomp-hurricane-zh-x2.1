#!/usr/bin/env bash
# The AppImage build environment in the VM, as upstream's packaging/appimage/Dockerfile (Ubuntu 22.04), run once
# with sudo. Logs to ~/setup_linux.log.
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive
LLVM_VERSION=22
SDL2_VERSION=2.32.10
GLSLANG_VERSION=16.6.0

apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates wget gnupg lsb-release software-properties-common git file \
    python3 python3-pip pkg-config
add-apt-repository -y ppa:ubuntu-toolchain-r/test
apt-get update
apt-get install -y --no-install-recommends \
    g++-13 libstdc++-13-dev \
    libx11-dev libxext-dev libxrandr-dev libxcursor-dev libxfixes-dev libxi-dev libxss-dev libxtst-dev \
    libxkbcommon-dev libwayland-dev wayland-protocols libdecor-0-dev libegl1-mesa-dev libgl-dev \
    libgbm-dev libdrm-dev libvulkan-dev libpulse-dev libpipewire-0.3-dev libasound2-dev libdbus-1-dev \
    libudev-dev
wget -qO /tmp/llvm.sh https://apt.llvm.org/llvm.sh
bash /tmp/llvm.sh ${LLVM_VERSION}
apt-get install -y --no-install-recommends clang-${LLVM_VERSION} lld-${LLVM_VERSION} llvm-${LLVM_VERSION}
for tool in clang clang++ ld.lld llvm-strip llvm-profdata; do ln -sf /usr/bin/${tool}-${LLVM_VERSION} /usr/local/bin/${tool}; done
python3 -m pip install --no-cache-dir "cmake>=3.25,<4" ninja patchelf
rm -f /tmp/llvm.sh

apt-get install -y --no-install-recommends libglib2.0-dev libepoxy-dev

wget -qO /tmp/sdl.tar.gz https://github.com/libsdl-org/SDL/releases/download/release-${SDL2_VERSION}/SDL2-${SDL2_VERSION}.tar.gz
tar -xzf /tmp/sdl.tar.gz -C /tmp
cmake -S /tmp/SDL2-${SDL2_VERSION} -B /tmp/sdl-build -G Ninja \
     -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=clang -DCMAKE_INSTALL_PREFIX=/usr/local \
     -DSDL_STATIC=OFF -DSDL_SHARED=ON -DSDL_TEST=OFF
cmake --build /tmp/sdl-build && cmake --install /tmp/sdl-build
rm -rf /tmp/sdl.tar.gz /tmp/SDL2-${SDL2_VERSION} /tmp/sdl-build

git clone --depth 1 -b ${GLSLANG_VERSION} https://github.com/KhronosGroup/glslang /tmp/glslang
cmake -S /tmp/glslang -B /tmp/glslang-build -G Ninja -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_INSTALL_PREFIX=/usr/local \
     -DBUILD_SHARED_LIBS=OFF -DENABLE_OPT=OFF -DGLSLANG_TESTS=OFF -DENABLE_GLSLANG_BINARIES=OFF \
     -DCMAKE_POSITION_INDEPENDENT_CODE=ON
cmake --build /tmp/glslang-build && cmake --install /tmp/glslang-build
rm -rf /tmp/glslang /tmp/glslang-build

apt-get install -y --no-install-recommends qt6-base-dev qt6-qpa-plugins qt6-wayland libgl1-mesa-dev
# (the .zsync beside the AppImage; rsync to copy the source in)
apt-get install -y --no-install-recommends zsync rsync
echo SETUP-DONE
