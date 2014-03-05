

#import "CCRenderTexture+GLubyte.h"


@implementation CCRenderTexture (GLubyte)


- (BOOL)newGLubyteBuffer:(GLubyte *)buffer{
    
    NSAssert(_pixelFormat == kCCTexture2DPixelFormat_RGBA8888,@"only RGBA8888 can be saved as image");
	
	
	CGSize s = [_texture contentSizeInPixels];
	int tx = s.width;
	int ty = s.height;
	
	if( !buffer ) {
		CCLOG(@"cocos2d: Get Buffer Error!");
		return NO;
	}
    
	
	[self begin];

	glReadPixels(0,0,tx,ty,GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
	[self end];
    
    
    return YES;
}


-(CGImageRef) newCGImageCustom
{
    NSAssert(_pixelFormat == kCCTexture2DPixelFormat_RGBA8888,@"only RGBA8888 can be saved as image");
	
	
	CGSize s = [_texture contentSizeInPixels];
	int tx = s.width;
	int ty = s.height;
	
	int bitsPerComponent			= 8;
    int bitsPerPixel                = 4 * 8;
    int bytesPerPixel               = bitsPerPixel / 8;
	int bytesPerRow					= bytesPerPixel * tx;
	NSInteger myDataLength			= bytesPerRow * ty;
	
	GLubyte *buffer	= calloc(myDataLength,1);
	GLubyte *pixels	= calloc(myDataLength,1);
	
	
	if( ! (buffer && pixels) ) {
		CCLOG(@"cocos2d: CCRenderTexture#getCGImageFromBuffer: not enough memory");
		free(buffer);
		free(pixels);
		return nil;
	}
	
	[self begin];
	
    
	glReadPixels(0,0,tx,ty,GL_RGBA,GL_UNSIGNED_BYTE, buffer);
    
	[self end];
	
	// make data provider with data.
	
	CGBitmapInfo bitmapInfo	= kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, myDataLength, NULL);
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGImageRef iref	= CGImageCreate(tx, ty,
									bitsPerComponent, bitsPerPixel, bytesPerRow,
									colorSpaceRef, bitmapInfo, provider,
									NULL, false,
									kCGRenderingIntentDefault);
	
	CGContextRef context = CGBitmapContextCreate(pixels, tx,
												 ty, CGImageGetBitsPerComponent(iref),
												 CGImageGetBytesPerRow(iref), CGImageGetColorSpace(iref),
												 bitmapInfo);
	
	// vertically flipped
	if( YES ) {
		CGContextTranslateCTM(context, 0.0f, ty);
		CGContextScaleCTM(context, 1.0f, -1.0f);
	}
    
	//CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, tx, ty), iref);
	//CGImageRef image = CGBitmapContextCreateImage(context);
	
    CGImageRef image = nil;
    
	CGContextRelease(context);
	CGImageRelease(iref);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	
	free(pixels);
	free(buffer);
	
	return image;
}

@end