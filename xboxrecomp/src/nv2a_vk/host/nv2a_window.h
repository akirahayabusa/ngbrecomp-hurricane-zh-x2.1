/* The game window the NV2A renderer presents to. Created and pumped by the
 * host's main thread. */
#ifndef NV2A_WINDOW_H
#define NV2A_WINDOW_H
#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* aspect: displayed width/height (4:3 or 16:9), negative to stretch to the
 * window; vsync: FIFO presentation
 * instead of mailbox. Call before nv2a_vk_init. */
int nv2a_window_create(const char *title, int width, int height,
                       int fullscreen, double aspect, int vsync);   /* fullscreen: 0 window, 1 fullscreen, 2 borderless */
/* Handle pending window events; false once the user closed the window. */
bool nv2a_window_pump(void);
/* Each pump, on the window's thread (weak). */
void nv2a_window_tick(void);
/* Every SDL_Event also goes here (weak; define it to see input). */
void nv2a_window_event_hook(const void *sdl_event);

/* Mouse motion the player did not make. SDL reports a motion whenever the pointer's place in a window changes,
 * also when it is the window that changed under a pointer at rest: a display mode switch (window, borderless,
 * fullscreen), the window resized or moved, a fullscreen display mode, the window coming to the front or the
 * pointer entering it. Taken for a move, that one selected the menu row under the resting pointer (the next press
 * then changed that row's setting) and made the mouse the device in use while a controller was. An event filter,
 * ahead of every watcher and of the queue, marks those events: their mouse id becomes NV2A_MOUSEID_NOT_PLAYER and
 * their xrel/yrel 0 (no camera turn, no switch of device). Install once SDL's video is up (again after it was
 * shut down: SDL drops its filter then); the window and the settings screen both do. */
#define NV2A_MOUSEID_NOT_PLAYER ((uint32_t)-2)
/* A motion a test script makes (SDL_PushEvent, the pointer itself unmoved): the player's (its id becomes 0). */
#define NV2A_MOUSEID_SCRIPTED ((uint32_t)-3)
void nv2a_mouse_filter_install(void);
/* A motion (SDL_MOUSEMOTION) the player made: false for one the filter marked. */
bool nv2a_mouse_motion_by_player(const void *sdl_event);

/* A host overlay over the paused game (a settings menu). The presenter asks
 * nv2a_overlay_wanted() at every frame; once it says yes, the game is held
 * at that frame (its next flip waits) and nv2a_overlay_frame() draws the
 * window's whole picture into px (w x h, 0xAARRGGBB), given the last frame
 * fitted to the window in backdrop, until it returns false. Both weak; run
 * on the renderer's thread. */
bool nv2a_overlay_wanted(void);
bool nv2a_overlay_frame(uint32_t *px, int w, int h, const uint32_t *backdrop);

/* Settings the overlay can change; they take effect as it closes. aspect as
 * for nv2a_window_create; width/height 0 keep the size. */
void nv2a_window_request(int width, int height, int fullscreen);
/* The window as it is now: 0 window, 1 fullscreen, 2 borderless (as nv2a_window_create), and its size
 * when windowed (left alone otherwise); -1 with no window. */
int nv2a_window_mode(int *width, int *height);
/* The picture's size in the window now (its swapchain's, in pixels); -1 before there is one. */
int nv2a_window_extent(int *width, int *height);
void nv2a_present_set_aspect(double aspect);
/* Where the game's picture is in a window (drawable pixels) ww x wh. */
void nv2a_present_picture_rect(int ww, int wh, int *x0, int *y0, int *dw, int *dh);
void nv2a_present_set_vsync(int vsync);   /* 0 off, 1 on, 2 adaptive */
void nv2a_present_set_show_fps(bool show);
/* While set, the window shows black instead of the game's picture (a
 * screen the host skips, kept out of sight). */
void nv2a_present_set_blank(bool blank);
/* Render scale (1-10); anisotropic filtering (0: the console's filtering;
 * 2, 4, 8 or 16: trilinear and anisotropic at that level); shadow map scale
 * (1-8); MSAA samples (1, 2, 4 or 8; the Direct3D renderer's only). */
void nv2a_set_quality(int render_scale, int anisotropy, int shadow_scale, int msaa);

#ifdef __cplusplus
}
#endif
#endif
