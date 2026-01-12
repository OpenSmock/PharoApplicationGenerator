#pragma once

#include "loading_window_config.h"

#include <SDL2/SDL.h>

EXPORT(void) loading_window_open();
EXPORT(void) loading_window_setPercentage(sqInt percentage);
EXPORT(void) loading_window_imageReportProgress(size_t totalSize, size_t currentSize);
EXPORT(void) loading_window_destroy();

void waitUntilWindowOpen(SDL_Window* window);
void loadLoadingWindowImage();
