

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

@end