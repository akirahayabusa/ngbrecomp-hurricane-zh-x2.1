# 忍者龙剑传 黑之章 飓风版 PC 版 — vb-zh-x2.1

[English](README.md) · [ngbrecomp 原版说明（英文）](docs/README-ngbrecomp.md)

把哈雅布撒的汉化补丁 **「忍者龙剑传 黑之章 飓风版[中英] vb-zh-x2.1」** 移植到 Windows PC，
基于 gamboozino 的 [ngbrecomp](https://github.com/gamboozino/ngbrecomp)。
游戏代码（含 x2.1 补丁的全部改动）从打过补丁的 `default.xbe` 静态重编译成原生程序，不是模拟器。

## 截图

![标题画面](docs/images/zh-title.jpg)

| | |
|---|---|
| ![主菜单](docs/images/zh-menu.jpg) | ![PC版设置](docs/images/zh-settings.jpg) |
| ![读档](docs/images/zh-load.jpg) | ![游戏中](docs/images/zh-gameplay.jpg) |

## 支持哪个镜像

**目前只支持 `vb-zh-x2.1`**：美版原版镜像（NTSC-U，游戏 ID `5443000D`）打上 vb-zh-x2.1 补丁后的版本。
程序会校验打过补丁的 `default.xbe`，其他镜像一律拒绝：

| 镜像 | 本程序 |
|---|---|
| vb-zh-x2.1（飓风版，中英） | **支持** |
| vb-jp-x2.1（飓风版，日英） | 暂不支持，**后续会建立单独的分支支持** |
| va-zh-x2（基本版）、更早的 x / x2 等版本 | 不支持 |
| 美版原版（未打补丁） | 不支持，请用原项目 [ngbrecomp](https://github.com/gamboozino/ngbrecomp) |

本程序不含任何游戏数据，需要你自己的游戏镜像和 x2.1 补丁。

## 内容

- vb-zh-x2.1 的全部内容：中文汉化、交差之法切换（飓风包 / 黑之章）、宁静腕轮、妖刀鬼彻扣血、
  带全部金圣甲虫开新一轮、还魂护符开关、扳机选服装、弓箭准星、第三人称视角设定等。
- ngbrecomp 的 PC 功能：高渲染分辨率、16:9 / 16:10 / 21:9 / 32:9、键鼠与改键、按键提示（自动 / Xbox / PlayStation / PC）、
  多重采样抗锯齿、各向异性过滤、稳定帧率、镜头灵敏度、柔和泛光、高负载时降低画质与多线程渲染（默认关闭）；
  “玩法”中的快速菜单（仿《忍者龙剑传 2》，用十字键选择武器、忍法与道具）、只用精魂蓄力、跳过任何过场、即时反应（均默认关闭）；
  作弊（含无限道具：恢复道具、还魂护符与各种珠不消耗；无限飞行道具；一击必杀）与“解锁”页（难度、服装、任务模式、街机版、影像鉴赏；
  全部武器、全部腕轮、全部秘传书）；
  “显示”中的界面显示开关，“音效”中的立体声定位（关 / 主机原版 / 清晰，默认清晰）；声音改在 PC 上混音（游戏的 DirectSound 交给 PC 混音器：3D 定位、主机的房间混响，声道选“自动 / 立体声 / 5.1”可出 5.1 环绕声）；默认设置下只占约 250 MB 显存（0.9.27 之前超过 3 GB），30 秒没用到的贴图会释放显存，长时间游玩不再耗尽显存。
- 汉斯酒吧街机台与主菜单（解锁后）的街机版忍者龙剑传：另外重编译成独立程序（`NinjaTrilogy.exe`、`NinjaTomoe.exe`，上游 #18），
  游戏会切换过去、玩完再切回来。文字为中文时游戏启动的是日文版街机，与 Xbox 上相同。
- 重编译版自己的菜单（PC版设置、暂停菜单的“设置”页、F1 设置、退出页与确认框）在游戏文字语言为“亚洲”时显示中文（x2.1 默认即是）。

不包含：SFC 忍者龙剑传三部曲（`NinjaFCJ.xbe` / `NinjaFCU.xbe`）。它是另外的程序，没有重编译，主菜单中不显示这一项。

## 使用方法（Windows）

1. 从 [Releases](../../releases) 下载 zip，解压到任意位置。
2. 运行 `ngb-hurricane-zh-x2.1.exe`，选择 vb-zh-x2.1 镜像（`.iso`）或其解压出的文件夹。
   镜像只需安装一次（约 6 GB），默认装到 `%LOCALAPPDATA%\ngb-hurricane-zh-x2.1`；
   便携模式（勾选对话框里的选项，或在 exe 旁放一个 `portable.txt`）则全部放在程序旁边。

需要 Windows 10 / 11（64 位）和支持 Vulkan 1.3 的显卡（或以扩展提供 dynamic rendering 与 synchronization2 的旧版驱动）。按键：F1 游戏中的设置，F10 帧率显示，F11 或 Alt+Enter 全屏。
存档与 Xbox / xemu 的存档分开。数据文件夹（`%LOCALAPPDATA%`、`%APPDATA%` 下的 `ngb-hurricane-zh-x2.1`）独立，可与 ngbrecomp 原版共存。

## 版本号

发布版本与所基于的 ngbrecomp 版本一致（`hurricane-v0.9.9` 即基于 ngbrecomp 0.9.9）；在同一版本上我们自己的更新加 `-1`、`-2`……
窗口标题会显示版本：`Ninja Gaiden Black Hurricane_x2.1_v0.9.50`。

## 与 ngbrecomp 的区别

`hurricane` 分支，随上游更新合并：

- `src/install.c`：接受 x2.1 的 `default.xbe`（按大小与各段哈希校验）；安装提示改为中英双语。
- 重编译器（`xboxrecomp/tools/recomp`）：支持 pushad / popad / pushfd / popfd，并为补丁写入 XBE 的代码新增三个选项——
  `--flags-after-call`、`--flags-out`（把标志位交还调用方的挂钩）和 `--ebp-to-callee`（读取调用方 ebp 的挂钩）。
  清单在 `src/*.json`，测试在 `xboxrecomp/tools/recomp/test_*.py`。
- ngbrecomp 手写的函数与其中的 x2.1 改动合并（`src/pc_menu.c`、`src/menu_mouse.c`、`src/hurricane_hint.c`；脚本在 `tools/hurricane/`），
  包括上游手写改写的游戏函数：`src/camera.c` 的镜头（x2.1 在 0x47A92、0x4FA22 的视角设定调用）与 `src/cheats.c` 的道具计数
  （x2.1 在 0x1543B9 清除还魂护符开关）。
- 重编译版自身文字的中文：`tools/hurricane/zh_text.tsv` → `src/hurricane_zh_data.c`（`tools/hurricane/make_zh.py`）；
  x2.1 字库缺的 9 个字在运行时补进字库页的空格（`src/hurricane_zh.c`）。
- 金龙图标（`tools/hurricane/make_icon.py`）、带版本号的窗口标题、高 DPI 支持；街机程序按本程序的文件名切回（`src/launch.c`）。
  不加入上游的“反转镜头”“第一人称反转”“读档后第三人称”：x2.1 已有自己的视角设定，读档后也一律是第三人称镜头。
  只改变速度的“镜头灵敏度”保留。
- 不加入上游“玩法”里的“交差之法”选项（#109）：x2.1 已在游戏自己的控制器设置里切换交差之法（飓风包 / 黑之章），上游为它手写的函数是原版的。

## 从源码构建（Windows）

本分支只使用并测试过下面的 Windows 构建流程。上游的 `tools/pipeline.sh`（Linux）不带飓风版需要的重编译选项，此处不支持。
上游 ngbrecomp 另外支持 Linux 与 Apple Silicon macOS（实验性），见其说明 [docs/README-ngbrecomp.md](docs/README-ngbrecomp.md)；本分支均不支持。

需要：llvm-mingw（UCRT，x86_64 Windows 宿主版）、`packaging/windows/deps.txt` 列出的 MSYS2 CLANG64 包（解压到 `<deps>/sysroot/clang64`）、
CMake、Ninja、Git Bash，以及装有 `capstone` 的 Python。在 Git Bash 中：

```sh
xboxrecomp/third_party/fetch.sh                          # 只需一次：Vulkan 头文件、volk、VMA 等
NGB_PY=/path/to/python.exe tools/pipeline_win.sh /path/to/x2.1/default.xbe   # 翻译成 C（几分钟）
NGB_PY=/path/to/python.exe tools/pipeline_trilogy_win.sh /path/to/x2.1/NinjaTrilogy.xbe        # 街机版
NGB_PY=/path/to/python.exe tools/pipeline_trilogy_win.sh /path/to/x2.1/NinjaTomoe.xbe tomoe    # 街机日文版
cmake -S . -B build/x21 -G Ninja -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/windows-x64-llvm-mingw-native.cmake \
      -DNGB_WIN_DEPS=<deps：包含 llvm-mingw-*-ucrt-x86_64 和 sysroot/clang64>
ninja -C build/x21 ninja_gaiden_black
```

`default.xbe` 取自你的 vb-zh-x2.1 镜像。生成的中文数据（`src/hurricane_zh_data.c`、`assets/fonts/NGBHanzi-Bold.ttf`）
已提交；重新生成需要汉化项目的码表与字形渲染工具。

## 作者与授权

- x2.1 补丁的 PC 移植：哈雅布撒 / akirahayabusa（b站；QQ 2682557218）。
- [ngbrecomp](https://github.com/gamboozino/ngbrecomp)：gamboozino；[xboxrecomp](https://github.com/sp00nznet/xboxrecomp)：sp00nznet。
  详见 [THIRD_PARTY.md](THIRD_PARTY.md) 与发布包中的 `licenses/`。
- 中文字体：思源黑体 CN Bold 子集（SIL OFL 1.1），已改名 NGB Hanzi（`assets/fonts/OFL-NGBHanzi.txt`）。
  菜单美术字为用鼎猎宋刻体预先绘制的图片，字体本身不包含在内。
- 与 ngbrecomp 相同，采用 GPL-3.0-or-later（ngbrecomp 自 0.9.25 起；[LICENSE](LICENSE)）。

本作品为爱好者非盈利作品，仅供已拥有正版游戏的玩家学习交流，请勿用于商业用途。NINJA GAIDEN © KOEI TECMO GAMES / Team NINJA。
