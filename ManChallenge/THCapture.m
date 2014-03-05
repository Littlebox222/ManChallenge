//
//  THCapture.m
//  ScreenCaptureViewTest
//
//  Created by wayne li on 11-8-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "THCapture.h"

#import "CCRenderTexture+GLubyte.h"

static NSString* const kFileName=@"output.mp4";



@interface CustomRenderTexture()


@end


@implementation CustomRenderTexture

- (void)draw {
    
    [super draw];
    
    const GLchar * fragmentSource = (GLchar*) [[NSString stringWithContentsOfFile:[CCFileUtils fullPathFromRelativePath:@"Mask.fsh"] encoding:NSUTF8StringEncoding error:nil] UTF8String];
    self.shaderProgram = [[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureA8Color_vert fragmentShaderByteArray:fragmentSource];
    
    [self.shaderProgram addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
    [self.shaderProgram addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
    [self.shaderProgram link];
    [self.shaderProgram updateUniforms];
    
//    int colorRampUniformLocation = glGetUniformLocation(render.shaderProgram->_program, "inputImageTexture");
//    glUniform1i(colorRampUniformLocation, 1);
    
    [self.shaderProgram use];
    
    NSLog(@"~~~~~");
}

@end



@interface THCapture()
//配置录制环境
- (BOOL)setUpWriter;
//清理录制环境
- (void)cleanupWriter;
//完成录制工作
- (void)completeRecordingSession;
//录制每一帧
- (void)drawFrame;
@end

@implementation THCapture{
    int colorRampUniformLocation;
}
@synthesize frameRate=_frameRate;
@synthesize delegate=_delegate;

@synthesize shouldStopRecording = _shouldStopRecording;

- (id)init
{
    self = [super init];
    if (self) {
        _frameRate=20;//默认帧率为10
        _shouldStopRecording = NO;
        _recording = NO;
    }
    
    return self;
}

- (void)dealloc {
	[self cleanupWriter];
	[super dealloc];
}

#pragma mark -
#pragma mark CustomMethod

- (bool)startRecording
{
    bool result = NO;
    
    //if (! _recording && _captureLayer)
    if (! _recording)
    {
        result = [self setUpWriter];
        if (result)
        {
            startedAt = [[NSDate date] retain];
            _recording = true;
            _writing = false;
            
            //绘屏的定时器
            NSDate *nowDate = [NSDate date];
            timer = [[NSTimer alloc] initWithFireDate:nowDate interval:1.0/_frameRate target:self selector:@selector(drawFrame) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];   
            [timer release];
        }
    }
	return result;
}

- (void)stopRecording
{
    if (_recording) {
        _recording = false;
        [timer invalidate];
        timer = nil;
        [self completeRecordingSession];
        [self cleanupWriter];
    }
}

-(CCRenderTexture*)saveScreenToRenderTexture {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;

    CCRenderTexture* render = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height];
    
    [render beginWithClear:0.2f g:0.2f b:0.2f a:1.0f];
    [[CCDirector sharedDirector] drawScene];
    [render end];
    
    
    //*******************************
    
    CCSprite *tmp = [CCSprite spriteWithTexture:render.sprite.texture];//[[CCSprite alloc] initWithTexture:render.sprite.texture];
    tmp.scaleY = -1;
    tmp.position = ccp(winSize.width/2, winSize.height/2);
    
    //===========================
    const GLchar * fragmentSource = (GLchar*) [[NSString stringWithContentsOfFile:[CCFileUtils fullPathFromRelativePath:@"CSEColorRamp.fsh"]
                                                                         encoding:NSUTF8StringEncoding error:nil] UTF8String];
    tmp.shaderProgram = [[[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureA8Color_vert fragmentShaderByteArray:fragmentSource] autorelease];
    [tmp.shaderProgram addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
    [tmp.shaderProgram addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
    [tmp.shaderProgram link];
    [tmp.shaderProgram updateUniforms];
    
    // 3
    colorRampUniformLocation = glGetUniformLocation(tmp.shaderProgram->_program, "u_colorRampTexture");
    glUniform1i(colorRampUniformLocation, 1);
    
    // 5
    [tmp.shaderProgram use];
    glActiveTexture(GL_TEXTURE1);
    glActiveTexture(GL_TEXTURE0);
    
    //===========================
    
    [render begin];
    [tmp visit];
    [render end];
    
    
    return render;
}



- (void)drawFrame
{
    
    if (!_writing) {
        
        _writing = true;
        
        //CGImageRef cgImage = [self drawSample];
        
        CCRenderTexture* render = [self saveScreenToRenderTexture];

        if (_recording) {
            
            float millisElapsed = [[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0;
            CMTime time = CMTimeMake((int)millisElapsed, 1000);
            
            //write
            if (![videoWriterInput isReadyForMoreMediaData])
            {
                NSLog(@"Not ready for video data");
            }
            else
            {
                CVPixelBufferRef pixelBuffer = NULL;
                //CFDataRef image = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
                
                int status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, avAdaptor.pixelBufferPool, &pixelBuffer);
                if(status != 0)
                {
                    //could not get a buffer from the pool
                    NSLog(@"Error creating pixel buffer:  status=%d", status);
                }
                // set image data into pixel buffer
                CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
                GLubyte* destPixels = (GLubyte *)CVPixelBufferGetBaseAddress(pixelBuffer);


                
                [render newGLubyteBuffer:destPixels];

                
                //CFDataGetBytes(image, CFRangeMake(0, CFDataGetLength(image)), destPixels);
                
                if(status == 0)
                {
                    BOOL success = [avAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:time];
                    if (!success)
                        NSLog(@"Warning:  Unable to write buffer to video");
                }
                
                //clean up
                CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
                CVPixelBufferRelease( pixelBuffer );
                //CFRelease(image);
            }
        }
        
        //CGImageRelease(cgImage);
        
        _writing = false;
    }
}


- (NSString*)tempFilePath {

    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:kFileName] retain];
	
	return [filePath autorelease];
}

-(BOOL) setUpWriter {
    
    //CGSize size = self.captureLayer.frame.size;
    CGSize size = [CCDirector sharedDirector].winSize;
    int screenScale = [UIScreen mainScreen].scale;
    size.width *= screenScale;
    size.height *= screenScale;
    
    //Clear Old TempFile
	NSError  *error = nil;
    NSString *filePath=[self tempFilePath];
    NSFileManager* fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:filePath]) 
    {
		if ([fileManager removeItemAtPath:filePath error:&error] == NO) 
        {
			NSLog(@"Could not delete old recording file at path:  %@", filePath);
            return NO;
		}
	}
    
    //Configure videoWriter
    NSURL   *fileUrl=[NSURL fileURLWithPath:filePath];
	videoWriter = [[AVAssetWriter alloc] initWithURL:fileUrl fileType:AVFileTypeQuickTimeMovie error:&error];
	NSParameterAssert(videoWriter);
	
	//Configure videoWriterInput
	NSDictionary* videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
										   [NSNumber numberWithDouble:size.width*size.height], AVVideoAverageBitRateKey,
										   nil ];
	
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
								   AVVideoCodecH264, AVVideoCodecKey,
								   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
								   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
								   videoCompressionProps, AVVideoCompressionPropertiesKey,
								   nil];
	
	videoWriterInput = [[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings] retain];
	
	NSParameterAssert(videoWriterInput);
	videoWriterInput.expectsMediaDataInRealTime = YES;
	NSDictionary* bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									  [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey, nil];
	
	avAdaptor = [[AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput sourcePixelBufferAttributes:bufferAttributes] retain];
	
	//add input
	[videoWriter addInput:videoWriterInput];
	[videoWriter startWriting];
	[videoWriter startSessionAtSourceTime:CMTimeMake(0, 1000)];
    
	
	return YES;
}

- (void) cleanupWriter {
	[avAdaptor release];
	avAdaptor = nil;
	
	[videoWriterInput release];
	videoWriterInput = nil;
	
	[videoWriter release];
	videoWriter = nil;
	
	[startedAt release];
	startedAt = nil;
    
    CGContextRelease(context);
    context=NULL;
}

- (void) completeRecordingSession {
	
	[videoWriterInput markAsFinished];
	
	// Wait for the video
	int status = videoWriter.status;
	while (status == AVAssetWriterStatusUnknown) 
    {
		NSLog(@"Waiting...");
		[NSThread sleepForTimeInterval:0.5f];
		status = videoWriter.status;
	}
	
    BOOL success = [videoWriter finishWriting];
    if (!success) 
    {
        NSLog(@"finishWriting returned NO");
        if ([_delegate respondsToSelector:@selector(recordingFaild:)]) {
            [_delegate recordingFaild:nil];
        }
        return ;
    }
    
    NSLog(@"Completed recording, file is stored at:  %@", [self tempFilePath]);
    if ([_delegate respondsToSelector:@selector(recordingFinished:)]) {
        [_delegate recordingFinished:[self tempFilePath]];
    }
}


@end
