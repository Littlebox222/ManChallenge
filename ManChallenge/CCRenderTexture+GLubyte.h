
#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCRenderTexture (GLubyte)

- (BOOL)newGLubyteBuffer:(GLubyte *)buffer;

-(CGImageRef) newCGImageCustom;

@end