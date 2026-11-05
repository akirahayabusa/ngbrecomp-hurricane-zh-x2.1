/* The Hurricane build's version: the upstream ngbrecomp version it is based on, plus "-1", "-2", ... for our own
 * releases on top of it. Shown in the window title; packaging/windows/ngb.rc carries the same number. */
#pragma once
#define NGB_HURRICANE_VERSION "0.9.57"
#define NGB_WINDOW_TITLE "Ninja Gaiden Black Hurricane_x2.1_v" NGB_HURRICANE_VERSION
/* The folders of the installed game, saves, settings and shader cache (%LOCALAPPDATA%, %APPDATA%, XDG): its own,
 * so ngbrecomp's retail install beside it is never taken for this one (user 2026-10-17). */
#define NGB_DATA_NAME "ngb-hurricane-zh-x2.1"
/* The game's program (CMakeLists.txt NGB_EXE_NAME): src/launch.c starts it again when the arcade hands back. */
#define NGB_EXE_NAME "ngb-hurricane-zh-x2.1"
