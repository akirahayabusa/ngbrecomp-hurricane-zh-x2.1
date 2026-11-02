#!/usr/bin/env bash
# The Hurricane x2.1 build as an AppImage, in the VM: upstream's packaging/appimage/build.sh (its part inside the
# container, then its packing), with this fork's names and update information.
#   appimage_hurricane.sh <version>      (the build already done in ~/out/build)
set -euo pipefail
ver=$1
repo=$HOME/ngb
toolkit=$repo/xboxrecomp
here=$repo/packaging/appimage
out=$HOME/out
exe=ngb-hurricane-zh-x2.1
name=NGB_Hurricane_PC_v${ver}_x86_64.AppImage
export PATH=/usr/local/bin:$PATH

app=$out/AppDir
rm -rf "$app"
mkdir -p "$app/usr/bin" "$app/usr/lib"
cp "$out/build/$exe" "$out/build/ngb-setup" "$app/usr/bin/"
llvm-strip "$app/usr/bin/$exe" "$app/usr/bin/ngb-setup"
for a in NinjaTrilogy NinjaTomoe; do
    cp "$out/build/$a" "$app/usr/bin/" && llvm-strip "$app/usr/bin/$a"
done

for lib in $(ldd "$app/usr/bin/$exe" | awk '/=>/ {print $3}'); do
    case "$(basename "$lib")" in
    libSDL2-2.0.so*|libglib-2.0.so*|libpcre.so*|libepoxy.so*) cp -L "$lib" "$app/usr/lib/" ;;
    esac
done

qtp=$(dirname "$(dirname "$(find /usr/lib -path "*qt6/plugins/platforms/libqxcb.so" | head -1)")")
mkdir -p "$app/usr/plugins"
for d in platforms/libqxcb.so platforms/libqwayland-generic.so \
         wayland-shell-integration wayland-decoration-client platforminputcontexts; do
    mkdir -p "$app/usr/plugins/$(dirname "$d")"
    cp -rL "$qtp/$d" "$app/usr/plugins/$(dirname "$d")/"
done
printf "[Paths]\nPrefix = ..\nPlugins = plugins\n" > "$app/usr/bin/qt.conf"
system_lib="^(ld-linux|libc|libm|libdl|librt|libpthread|libresolv|libutil|libstdc\+\+|libgcc_s|libGL|libEGL|libGLX|libGLdispatch|libOpenGL|libdrm|libgbm|libvulkan|libX11|libXau|libXdmcp|libXext|libXrender|libxcb\.so|libxcb-(shm|render|xfixes|randr|shape|sync|xkb|xinput|glx|dri2|dri3|present)\.so|libwayland-|libfontconfig|libfreetype|libharfbuzz|libexpat|libz\.|libdbus-1|libudev|libsystemd|libgpg-error|libselinux|libmount|libblkid|libffi|liblzma|liblz4|libzstd|libgcrypt|libcap|libbsd|libmd\.)"
bundle_deps() {
    ldd "$1" | awk '/=>/ {print $3}' | while read -r lib; do
        b=$(basename "$lib")
        echo "$b" | grep -Eq "$system_lib" && continue
        [ -e "$app/usr/lib/$b" ] || cp -L "$lib" "$app/usr/lib/"
    done
}
bundle_deps "$app/usr/bin/ngb-setup"
for so in $(find "$app/usr/plugins" -name "*.so"); do bundle_deps "$so"; done

patchelf --set-rpath '$ORIGIN/../lib' "$app/usr/bin/$exe" "$app/usr/bin/ngb-setup"
for a in NinjaTrilogy NinjaTomoe; do patchelf --set-rpath '$ORIGIN/../lib' "$app/usr/bin/$a"; done
for so in "$app"/usr/lib/*.so*; do patchelf --set-rpath '$ORIGIN' "$so"; done
for so in $(find "$app/usr/plugins" -name "*.so"); do patchelf --set-rpath '$ORIGIN/../../lib' "$so"; done
echo "Bundled:"; ls "$app/usr/lib"
echo "Needs from the system:"; readelf -d "$app/usr/bin/$exe" | sed -n 's/.*NEEDED.*\[\(.*\)\]/  \1/p'

share=$app/usr/share/NinjaGaidenBlack
mkdir -p "$share/shader-seed"
cp "$repo/packaging/d3d-seed.bin" "$share/d3d-seed.bin"
cp "$repo/packaging/shader-seed/states.bin" "$repo/packaging/shader-seed/pipelines.bin" "$share/shader-seed/"
lic=$app/usr/share/licenses/NinjaGaidenBlack
mkdir -p "$lic"
cp "$repo"/assets/fonts/OFL-*.txt "$repo/assets/prompts/License-Xelu.txt" "$lic/"
cp "$repo/LICENSE" "$repo/THIRD_PARTY.md" "$lic/"
cp "$repo/src/d3d/NOTICE" "$lic/NOTICE-renderer.txt"
cp "$repo/src/audio/NOTICE" "$lic/NOTICE-audio.txt"
cp "$toolkit/LICENSE" "$lic/LICENSE-xboxrecomp.txt"
cp "$toolkit/NOTICE" "$lic/NOTICE-xboxrecomp.txt"
cp "$toolkit/LICENSES/LGPL-2.1.txt" "$lic/"
cp "$here/ngb.png" "$app/ngb-hurricane-zh-x2.1.png"
cp "$here/ngb.png" "$app/.DirIcon"
cat > "$app/ngb-hurricane-zh-x2.1.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Ninja Gaiden Black Hurricane x2.1
GenericName=Ninja Gaiden Black Hurricane (static recompilation)
Comment=The Hurricane x2.1 build (Chinese / English), recompiled for Linux with Vulkan; asks for your own vb-zh-x2.1 disc image
Exec=$exe %f
Icon=ngb-hurricane-zh-x2.1
Categories=Game;ActionGame;
Terminal=false
DESKTOP
cat > "$app/AppRun" <<APPRUN
#!/bin/sh
here="\$(dirname "\$(readlink -f "\$0")")"
exec "\$here/usr/bin/$exe" "\$@"
APPRUN
chmod +x "$app/AppRun"

tool=$HOME/tools/appimagetool-x86_64.AppImage
[ -x "$tool" ] || { echo "no appimagetool at $tool" >&2; exit 1; }
cd "$out"
rm -f NGB_Hurricane_PC_*_x86_64.AppImage*
ARCH=x86_64 "$tool" --appimage-extract-and-run --no-appstream \
    -u "gh-releases-zsync|akirahayabusa|ngbrecomp-hurricane-zh-x2.1|latest|NGB_Hurricane_PC_*_x86_64.AppImage.zsync" \
    "$app" "$out/$name" > "$out/appimagetool.log" 2>&1 || { tail -20 "$out/appimagetool.log"; exit 1; }
ls -la "$out/$name" "$out/$name.zsync"
