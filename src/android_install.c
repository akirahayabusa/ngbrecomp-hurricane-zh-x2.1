/*
 * The first start on Android: the player's disc image chosen with the system's file picker and installed
 * (src/install.c, ngb_find_game), as the desktop's file picker does. No storage permission is asked for: the
 * picker gives the app the one file chosen (NgbActivity.java), by its path where the app can read it there, else
 * as an open file (/proc/self/fd/N, read through the descriptor). Xbox disc images (.iso, .xiso) only: an archive
 * (.7z, .zip) has to be unpacked first, there is no unpacker on the phone. With an SD card in, the game (about
 * 6 GB) can go there instead of the phone's storage. The install shows its progress in the system's small notes
 * (toasts).
 */
#include <errno.h>
#include <jni.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/stat.h>
#include <sys/statvfs.h>
#include <unistd.h>

#include <SDL.h>
#include <SDL_system.h>

#include "install.h"


/* NgbActivity's method by name (no arguments): its boolean, or for a void one 1 when it could be called */
static int activity_call(const char *name, const char *sig)
{
    JNIEnv *env = SDL_AndroidGetJNIEnv();
    jobject act = SDL_AndroidGetActivity();
    if (!env || !act)
        return 0;
    jclass cls = (*env)->GetObjectClass(env, act);
    jmethodID m = (*env)->GetMethodID(env, cls, name, sig);
    int r = 0;
    if (m) {
        if (sig[2] == 'Z')
            r = (*env)->CallBooleanMethod(env, act, m);
        else {
            (*env)->CallVoidMethod(env, act, m);
            r = 1;
        }
    }
    if ((*env)->ExceptionCheck(env)) {
        (*env)->ExceptionClear(env);
        r = 0;
    }
    (*env)->DeleteLocalRef(env, cls);
    (*env)->DeleteLocalRef(env, act);
    return r;
}

/* NgbActivity's method returning a String (no arguments), into out: 1 when it gave one */
static int activity_string(const char *name, char *out, size_t n)
{
    JNIEnv *env = SDL_AndroidGetJNIEnv();
    jobject act = SDL_AndroidGetActivity();
    int r = 0;
    if (!env || !act)
        return 0;
    jclass cls = (*env)->GetObjectClass(env, act);
    jmethodID m = (*env)->GetMethodID(env, cls, name, "()Ljava/lang/String;");
    jstring s = m ? (jstring)(*env)->CallObjectMethod(env, act, m) : NULL;
    if ((*env)->ExceptionCheck(env)) {
        (*env)->ExceptionClear(env);
        s = NULL;
    }
    if (s) {
        const char *c = (*env)->GetStringUTFChars(env, s, NULL);
        if (c) {
            snprintf(out, n, "%s", c);
            r = out[0] != 0;
            (*env)->ReleaseStringUTFChars(env, s, c);
        }
        (*env)->DeleteLocalRef(env, s);
    }
    (*env)->DeleteLocalRef(env, cls);
    (*env)->DeleteLocalRef(env, act);
    return r;
}

/* The system's file picker: the file's path into out, 1; 0 when closed without one */
static int pick_file(char *out, size_t n)
{
    if (!activity_call("pickDisc", "()V"))
        return 0;
    while (!activity_call("pickDone", "()Z")) {   /* (the app's events kept going: closed meanwhile, give up) */
        SDL_PumpEvents();
        if (SDL_QuitRequested())
            return 0;
        SDL_Delay(100);
    }
    return activity_string("pickedPath", out, n);
}

/* 0 continue, 1 the second button... (buttons in order, the first the default) */
static int ask(const char *title, const char *text, const char **buttons, int n)
{
    SDL_MessageBoxButtonData b[5];
    for (int i = 0; i < n && i < 5; i++) {
        b[i].flags = i == 0 ? SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT : 0;
        b[i].buttonid = i;
        b[i].text = buttons[i];
    }
    SDL_MessageBoxData d = { SDL_MESSAGEBOX_INFORMATION, NULL, title, text, n, b, NULL };
    int hit = -1;
    if (SDL_ShowMessageBox(&d, &hit) != 0)
        return -1;
    return hit;
}

/* The disc image to install from, into out: 1, or 0 when the player quit */
int ngb_android_pick_disc(char *out, size_t n)
{
    for (;;) {
        static const char *b[] = { "选择文件 / Choose file...", "退出 / Quit" };
        if (ask("NGB Hurricane x2.1",   /* Hurricane x2.1: its image, in Chinese too (user 2026-11-03) */
                "安装游戏：请选择「忍者龙剑传 黑之章 飓风版[中英] vb-zh-x2.1」镜像（.iso，美版原版镜像打上 vb-zh-x2.1 补丁）。"
                ".7z / .zip 要先解压。游戏约占 6 GB，装好后可删除镜像。\n\n"
                "To install the game, choose your vb-zh-x2.1 disc image (.iso: the retail USA image with the "
                "vb-zh-x2.1 patch). A .7z or .zip has to be unpacked first. The game takes about 6 GB; the image "
                "can be deleted afterwards.", b, 2) != 0)
            return 0;
        if (pick_file(out, n))
            return 1;
    }
}

static void toast_progress(uint64_t done, uint64_t total, void *ud)
{
    int *last = ud;
    if (!total)
        return;
    int pct = (int)(done * 100 / total);
    if (pct / 10 != *last / 10) {   /* (a note every tenth: each stays a couple of seconds) */
        char msg[96];
        snprintf(msg, sizeof msg, "正在安装 / Installing: %d%%", pct);
        SDL_AndroidShowToast(msg, 0, -1, 0, 0);
        *last = pct;
    }
}

static double free_gb(const char *dir)
{
    struct statvfs v;
    return statvfs(dir, &v) == 0 ? (double)v.f_bavail * v.f_frsize / 1e9 : 0;
}

/* ngb_install with its progress in toasts, and its failure said: 0 when installed, -1 when it failed, -2 when
 * the player quit. With an SD card in, the player chooses where the game goes (the folder found there next
 * start: install.c's remember_game). */
int ngb_android_install(const char *src, const char *installed, char *out, size_t n)
{
    char sd[1024], sd_game[1100], phone_dir[1100];
    struct stat st;
    int folder = stat(src, &st) == 0 && S_ISDIR(st.st_mode);   /* (a game folder runs where it is) */
    while (!folder && activity_string("sdCardFolder", sd, sizeof sd)) {
        char phone[64], card[64];
        snprintf(phone_dir, sizeof phone_dir, "%s", installed);
        char *slash = strrchr(phone_dir, '/');
        if (slash)
            *slash = 0;
        snprintf(phone, sizeof phone, "手机 / Phone (%.1f GB)", free_gb(phone_dir));
        snprintf(card, sizeof card, "SD 卡 / SD card (%.1f GB)", free_gb(sd));
        const char *b[] = { phone, card, "退出 / Quit" };
        int hit = ask("NGB Hurricane x2.1", "游戏装在哪里？约占 6 GB（括号内为剩余空间）。\n\nWhere should the game go? It takes about 6 GB "
                      "(free space in brackets).", b, 3);
        if (hit < 0 || hit > 1)
            return -2;
        if (free_gb(hit ? sd : phone_dir) < 6.5) {
            static const char *ok[] = { "重新选择 / Choose again" };
            ask("NGB Hurricane x2.1", "那里空间不足：游戏需要约 6.5 GB。\n\nThere is not enough free space there: the game needs "
                "about 6.5 GB.", ok, 1);
            continue;
        }
        if (hit == 1) {
            snprintf(sd_game, sizeof sd_game, "%s/game", sd);
            installed = sd_game;
        }
        break;
    }
    int last = -10;
    SDL_AndroidShowToast("正在安装游戏，需要几分钟 / Installing the game: a few minutes", 1, -1, 0, 0);
    ngb_install_set_progress(toast_progress, &last);
    int rc = ngb_install(src, installed, out, n);
    ngb_install_set_progress(NULL, NULL);
    if (rc != 0) {
        char msg[1400];
        snprintf(msg, sizeof msg, "游戏没能安装 / The game could not be installed.\n\n%s", ngb_install_error());
        SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "NGB Hurricane x2.1", msg, NULL);
    } else {
        SDL_AndroidShowToast("安装完成，现在可以删除镜像 / Installed. You can delete the disc image now if you like.", 1, -1, 0, 0);
    }
    if (!strncmp(src, "/proc/self/fd/", 14))   /* (the picker's descriptor, given to us) */
        close(atoi(src + 14));
    return rc;
}

/* The game was installed on an SD card that is not in now (install.c): 1 look again, 0 install it again, -1 quit */
int ngb_android_missing_card(const char *where)
{
    char msg[1400];
    snprintf(msg, sizeof msg, "游戏装在一张现在不在手机里的 SD 卡上：\n%s\n\n请插回 SD 卡后按「再找一次」，或重新安装。\n\n"
             "The game was installed on an SD card that is not in the phone now. Put the card back and press "
             "Look again, or install the game again.", where);
    static const char *b[] = { "再找一次 / Look again", "重新安装 / Install again", "退出 / Quit" };
    int hit = ask("NGB Hurricane x2.1", msg, b, 3);
    return hit == 0 ? 1 : hit == 1 ? 0 : -1;
}
