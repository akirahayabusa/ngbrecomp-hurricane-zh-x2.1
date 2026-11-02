# Linux AppImage and Android APK of the Hurricane x2.1 build

Built on Windows in a portable Ubuntu 22.04 VM (QEMU with WHPX, nothing installed on the host), from the same
generated code as the Windows build (`src/recomp/gen*`, made by `tools/pipeline_win.sh` with the Hurricane
recompiler options): upstream's Linux pipeline is not used.

- `start_vm.sh` -- the VM: QEMU 11.1 for Windows, `-accel whpx,kernel-irqchip=off` and a qemu64 CPU with SSE4
  (`-cpu max` stops with "Unexpected VP exit code 4"); SSH on 127.0.0.1:2222. The Ubuntu cloud image is set up once
  with cloud-init (NoCloud over HTTP, `-smbios ... ds=nocloud;s=http://10.0.2.2:8765/`); afterwards
  `/etc/cloud/cloud-init.disabled`, or each boot waits for that server.
- `setup_linux.sh` -- the AppImage environment, as upstream's `packaging/appimage/Dockerfile` (run with sudo).
- `appimage_hurricane.sh <version>` -- upstream's `packaging/appimage/build.sh` with this fork's names and update
  information (`gh-releases-zsync|akirahayabusa|ngbrecomp-hurricane-zh-x2.1|latest|NGB_Hurricane_PC_*_x86_64.AppImage.zsync`),
  after `cmake`/`ninja` of the game in `~/out/build` (clang, `-static-libstdc++ -static-libgcc -fuse-ld=lld`).
- `setup_android.sh` -- JDK 17, the Android SDK (NDK 29.0.14206865, build-tools 35.0.1, android-35), and a host
  `glslangValidator` >= 12.2 for Mesa (Ubuntu's is 11.8).
- `run_android.sh` -- upstream's `packaging/android/build.sh`, detached (`setsid nohup bash run_android.sh`).

Copying the source in: `xboxrecomp/src/nv2a_vk/shim/hw/xbox/nv2a` is a symbolic link to `../../../xemu` in git (a
junction on Windows); recreate it after copying the tree.

The APK is signed with the key in `build/android-deps/debug.keystore` of the VM, kept outside the repository: every
later APK must be signed with the same key, or it cannot be installed over the one before.
