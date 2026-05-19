#include "pharovm/pharo.h"
#include "pharovm/pharoClient.h"
#include "pharovm/imageAccess.h"
#include "loading_window.h"

SDL_Window* splashWindow = NULL;
SDL_Surface* splashSurface = NULL;
SDL_Renderer* splashWindowRenderer = NULL;
SDL_Texture* splashTexture = NULL;

SDL_WindowShapeMode splashShapeMode;

int percentage = 0;
int previousShownPercentage = 0;

int barX = LOADING_BAR_X;
int barY = LOADING_BAR_Y;
int barWidth =  LOADING_BAR_WIDTH;
int barHeight = LOADING_BAR_HEIGHT;
int margin = LOADING_BAR_MARGIN;

int firstX; 
int firstY;
int usableWidth;
int usableHeight;
int numberOfSquares;
int minimunChangeUpdate;

SDL_Color blockColor = { LOADING_BAR_COLOR_R, LOADING_BAR_COLOR_G, LOADING_BAR_COLOR_B, LOADING_BAR_COLOR_A }; 

void releaseResources(){
	if(splashTexture){
		SDL_DestroyTexture(splashTexture);
		splashTexture = NULL;
	}

	if(splashWindowRenderer){
		SDL_DestroyRenderer(splashWindowRenderer);
		splashWindowRenderer = NULL;
	}

	if(splashSurface){
		SDL_FreeSurface(splashSurface);
		splashSurface = NULL;
	}

	if(splashWindow){
		SDL_DestroyWindow(splashWindow);
		splashWindow = NULL;
	}
}

void waitUntilWindowOpen(SDL_Window* window){

	SDL_Event event;
	
	Uint32 windowID = SDL_GetWindowID(window);
		
	int numEvents = 0;
	
	while(true){
		SDL_WaitEvent(&event);
				
		if(event.type == SDL_WINDOWEVENT 
			&& event.window.windowID == windowID
			&& event.window.event == SDL_WINDOWEVENT_EXPOSED)
			break;
	}

	while(SDL_WaitEventTimeout(&event, 500));	
}

void drawSplashWindow(){
	SDL_SetRenderDrawColor(splashWindowRenderer, 0, 0, 0, 0);
	SDL_RenderClear(splashWindowRenderer);
	
	SDL_RenderCopy(splashWindowRenderer, splashTexture, NULL, NULL);
	
	SDL_SetRenderDrawColor(splashWindowRenderer, blockColor.r, blockColor.g, blockColor.b, blockColor.a);

	int squaresToRender = numberOfSquares * percentage / 100;

	for(int i=0; i < squaresToRender; i++){
		SDL_Rect rect;
		
		//The lastone is special
		if (i == (numberOfSquares - 1)){
			rect.x = firstX + (usableHeight + margin) * i;
			rect.y = firstY;
			rect.h = usableHeight;
			rect.w = (firstX + usableWidth) - rect.x;
		} else {
			rect.x = firstX + (usableHeight + margin) * i;
			rect.y = firstY;
			rect.w = usableHeight;
			rect.h = usableHeight;
		}
		SDL_RenderFillRect(splashWindowRenderer, &rect);		
	}
	
	SDL_RenderPresent(splashWindowRenderer);
}

EXPORT(void) loading_window_open(){
	
	SDL_Init(SDL_INIT_VIDEO);

	loadLoadingWindowImage();
	
	if(splashSurface == NULL)
		return;

	splashWindow = SDL_CreateWindow("Loading...", 
		SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 
		splashSurface->w, splashSurface->h, 
		SDL_WINDOW_BORDERLESS | SDL_WINDOW_ALLOW_HIGHDPI);

	splashShapeMode.mode = ShapeModeBinarizeAlpha;
	splashShapeMode.parameters.binarizationCutoff = 1;

	SDL_SetWindowShape(splashWindow, splashSurface, &splashShapeMode);

	splashWindowRenderer = SDL_CreateRenderer(splashWindow, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
	
	if(!splashWindowRenderer){
		releaseResources();
		return;
	}
	
	splashTexture = SDL_CreateTextureFromSurface(splashWindowRenderer, splashSurface);
	if(!splashTexture){
		releaseResources();
		return;
	}
	
	int outputWidth, outputHeight;
	
	SDL_GetRendererOutputSize(splashWindowRenderer, &outputWidth, &outputHeight);
	SDL_RenderSetScale(splashWindowRenderer, outputWidth / splashSurface->w, outputHeight / splashSurface->h );

	firstX = barX + margin; 
	firstY = barY + margin;
	usableWidth = barWidth - (margin * 2);
	usableHeight = barHeight - (margin * 2);

	numberOfSquares = (usableWidth / (usableHeight + margin)) + 1;

	minimunChangeUpdate = 100 / numberOfSquares;
	
	drawSplashWindow();

	SDL_ShowWindow(splashWindow);
	SDL_RaiseWindow(splashWindow);
	
	waitUntilWindowOpen(splashWindow);	
}

EXPORT(void) loading_window_setPercentage(sqInt newPercentage){
	percentage = newPercentage;
	
	if(percentage >= (previousShownPercentage + minimunChangeUpdate)){
		previousShownPercentage = percentage;
		drawSplashWindow();
	}
	
}

EXPORT(void) loading_window_destroy(){
	releaseResources();
}

EXPORT(void) loading_window_imageReportProgress(size_t totalSize, size_t currentSize){
	int newPercentage = LOADING_BAR_IMAGE_LOADING_PERCENTAGE * ((float)currentSize / totalSize);
	loading_window_setPercentage(newPercentage);
} 

