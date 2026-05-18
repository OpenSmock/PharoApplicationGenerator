#include "pharovm/pharo.h"
#include "pharovm/pharoClient.h"
#include "pharovm/imageAccess.h"
#include "loading_window.h"

// We need to undefine null because if not, we have a clash with the definition inside AppKit
#undef null

#import <AppKit/AppKit.h>

extern SDL_Surface* splashSurface;

void loadLoadingWindowImage(){
@autoreleasepool{
	
		NSBundle *bundle = [NSBundle mainBundle];
    	NSString *filePath = [bundle pathForResource: @LOADING_WINDOW_IMAGE ofType: nil ];	
	
		NSImage* nsImage = [[NSImage alloc] initWithContentsOfFile:filePath];
		if(!nsImage) return;
		
		NSImageRep* imageRep = [[nsImage representations] firstObject];
		
		if(!imageRep) return;
		
		NSInteger width	 = (NSInteger)[imageRep pixelsWide];
		NSInteger height = (NSInteger)[imageRep pixelsHigh];
		
		// We are going to render the image into the bitmap, we can copy the bitmap to the surface. 
		// It has the same alpha premultiplication, so no need to convert pixels
		NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																		   pixelsWide:width
																		   pixelsHigh:height
																		bitsPerSample:8
																	  samplesPerPixel:4
																			 hasAlpha:YES
																			 isPlanar:NO
																	   colorSpaceName:NSCalibratedRGBColorSpace
																		  bytesPerRow:0	  // let it calculate
																		 bitsPerPixel:32];
		
		if(!bitmap) return;
		
		// Draw the NSImage into our bitmap. We are using the global NSGraphicContext, so better to save it and restore it later.
		
		[NSGraphicsContext saveGraphicsState];
		[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap]];
		[nsImage drawInRect:NSMakeRect(0, 0, width, height)
				   fromRect:NSZeroRect
				  operation:NSCompositingOperationSourceOver
				   fraction:1.0];
		[NSGraphicsContext restoreGraphicsState];


		splashSurface = SDL_CreateRGBSurfaceWithFormat( 0, width, height, 32, SDL_PIXELFORMAT_RGBA32);
	
		if(!splashSurface) return;

		const uint8_t* src = [bitmap bitmapData];
		uint8_t* dst = splashSurface->pixels;
		size_t bytesPerRow = [bitmap bytesPerRow];

		SDL_LockSurface(splashSurface);

		for (NSInteger y = 0; y < height; y++) {
			memcpy(dst + y * splashSurface->pitch, src + y * bytesPerRow, width * 4);	// 4 bytes per pixel
		}
		
		SDL_UnlockSurface(splashSurface);
	}
}
