#!/usr/bin/env bash
# The Linux build VM (Ubuntu 22.04, for the AppImage and the APK): portable QEMU with WHPX, all files here.
# SSH: ssh -i ssh/id_ed25519 -p 2222 ngb@127.0.0.1   Serial log: vm/serial.log
# The first boot reads cloud-init from the seed folder over HTTP (serve_seed.sh must be running then).
V=$(cygpath -m "$(cd "$(dirname "$0")" && pwd)")
exec "$V/qemu/qemu-system-x86_64.exe" \
  -accel whpx,kernel-irqchip=off -cpu qemu64,+ssse3,+sse4.1,+sse4.2,+popcnt -smp 10 -m 8192 \
  -drive file="$V/vm/disk.qcow2",if=virtio,cache=writeback \
  -netdev user,id=n0,hostfwd=tcp:127.0.0.1:2222-:22 -device virtio-net-pci,netdev=n0 \
  -smbios "type=1,serial=ds=nocloud;s=http://10.0.2.2:8765/" \
  -display none -serial file:"$V/vm/serial.log" -monitor none
