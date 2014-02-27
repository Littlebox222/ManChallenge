

#import "CCRenderTexture+GLubyte.h"


@implementation CCRenderTexture (GLubyte)


- (BOOL)newGLubyteBuffer:(GLubyte *)buffer{
    
    NSAssert(_pixelFormat == kCCTexture2DPixelFormat_RGBA8888,@"only RGBA8888 can be saved as image");
	
	
	CGSize s = [_texture contentSizeInPixels];
	int tx = s.width;
	int ty = s.height;
	
	if( !buffer ) {
		CCLOG(@"cocos2d: CCRenderTexture#getCGImageFromBuffer: not enough memory");
		free(buffer);
		return NO;
	}
	
	[self begin];
    
	glReadPixels(0,0,tx,ty,GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
	[self end];
    
    
    float a = buffer[0];
    float b = buffer[1];
    float c = buffer[2];
    float d = buffer[3];
    
    return YES;
}

@end