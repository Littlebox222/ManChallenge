//
//  Snapshoter.m
//  ManChallenge
//
//  Created by Littlebox222 on 14-3-10.
//  Copyright (c) 2014年 Littlebox222. All rights reserved.
//

#import "Snapshoter.h"
#import "CCRenderTexture+GLubyte.h"

static NSString* const kFileName=@"output.mp4";

@interface Snapshoter()

- (BOOL)setUpWriter;
- (void)cleanupWriter;
- (void)completeRecordingSession;
- (void)drawFrame;
@end

@implementation Snapshoter

@synthesize frameRate = _frameRate;
@synthesize delegate = _delegate;
@synthesize spriteBufferCache = _spriteBufferCache;
@synthesize shouldStopRecording = _shouldStopRecording;

static Snapshoter *sharedSnapshoter;

+ (Snapshoter *)sharedSnapshoter {
    
    return sharedSnapshoter;
}

- (void)dealloc {
    
    [_spriteBufferCache release];
    
	[self cleanupWriter];
	[super dealloc];
}

- (id)init
{
    self = [super init];
    
    if (self) {
        
        _frameRate = 1;
        _shouldStopRecording = NO;
        _recording = NO;
        
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        self.spriteBufferCache = [[[CCSprite alloc] initWithFile:@"Default-568h@2x.png" rect:CGRectMake(0, 0, winSize.width, winSize.height)] autorelease];
        _spriteBufferCache.position = ccp(winSize.width/2, winSize.height/2);
        
        const GLchar * fragmentSource = (GLchar*) [[NSString stringWithContentsOfFile:[CCFileUtils fullPathFromRelativePath:@"CSEColorRamp.fsh"]
                                                                             encoding:NSUTF8StringEncoding error:nil] UTF8String];
        
        _spriteBufferCache.shaderProgram = [[[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureA8Color_vert fragmentShaderByteArray:fragmentSource] autorelease];
        [_spriteBufferCache.shaderProgram addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
        [_spriteBufferCache.shaderProgram addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
        [_spriteBufferCache.shaderProgram link];
        [_spriteBufferCache.shaderProgram updateUniforms];
        
        [_spriteBufferCache.shaderProgram use];
        glActiveTexture(GL_TEXTURE0);
        
        qt = dispatch_queue_create("com.sunsetlakesoftware.GPUImage.movieWritingQueue", NULL);
        
        sharedSnapshoter = self;
    }
    
    return self;
}

#pragma mark - CustomMethod

- (bool)startRecording
{
    bool result = NO;
    
    if (!_recording) {
        
        result = [self setUpWriter];
        
        if (result) {
            
            startedAt = [[NSDate date] retain];
            _recording = true;
            _writing = false;
            

            NSDate *nowDate = [NSDate date];
            timer = [[[NSTimer alloc] initWithFireDate:nowDate interval:1.0/_frameRate
                                               target:self
                                             selector:@selector(drawFrame)
                                             userInfo:nil
                                              repeats:YES] autorelease];
            
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
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
    CCRenderTexture* render1 = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height];
    
    [render1 beginWithClear:0.0f g:0.0f b:0.0f a:1.0f];
    [[CCDirector sharedDirector] drawScene];
    [render1 end];

    
    [self.spriteBufferCache setTexture:render1.sprite.texture];
    
    
    [render begin];
    [_spriteBufferCache visit];
    [render end];
    
    return render;
}


- (void)drawFrame
{
    if (!_writing) {
        
        _writing = true;
        

        CCRenderTexture* render = [self saveScreenToRenderTexture];

        
        if (_recording) {
            
            float millisElapsed = [[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0;
            CMTime time = CMTimeMake((int)millisElapsed, 1000);
            

            if (![videoWriterInput isReadyForMoreMediaData]) {
                
                NSLog(@"Not ready for video data");
                
            }else {
                
                CVPixelBufferRef pixelBuffer = NULL;
                
                int status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, avAdaptor.pixelBufferPool, &pixelBuffer);
                if(status != 0) {
                    NSLog(@"Error creating pixel buffer:  status=%d", status);
                }
                
                
                CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
                GLubyte* destPixels = (GLubyte *)CVPixelBufferGetBaseAddress(pixelBuffer);
                
                
                [render newGLubyteBuffer:destPixels];
                
                dispatch_async(qt, ^{
                    
                    if(status == 0) {
                        
                        BOOL success = [avAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:time];
                        if (!success)
                            NSLog(@"Warning:  Unable to write buffer to video");
                    }
                    
                    CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
                    CVPixelBufferRelease( pixelBuffer );
                    
                });
            }
        }
        
        _writing = false;
    }
}


- (NSString*)tempFilePath {
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:kFileName] retain];
	
	return [filePath autorelease];
}

-(BOOL) setUpWriter {
    
    CGSize size = [CCDirector sharedDirector].winSize;
    int screenScale = [UIScreen mainScreen].scale;
    size.width *= screenScale;
    size.height *= screenScale;
    

	NSError  *error = nil;
    NSString *filePath=[self tempFilePath];
    NSFileManager* fileManager = [NSFileManager defaultManager];
	
    if ([fileManager fileExistsAtPath:filePath]) {
        
		if ([fileManager removeItemAtPath:filePath error:&error] == NO) {
            
			NSLog(@"Could not delete old recording file at path:  %@", filePath);
            return NO;
		}
	}
    

    NSURL   *fileUrl=[NSURL fileURLWithPath:filePath];
	videoWriter = [[AVAssetWriter alloc] initWithURL:fileUrl fileType:AVFileTypeQuickTimeMovie error:&error];
	NSParameterAssert(videoWriter);
	

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
	
	int status = videoWriter.status;
    
	while (status == AVAssetWriterStatusUnknown) {
        
		NSLog(@"Waiting...");
		[NSThread sleepForTimeInterval:0.5f];
		status = videoWriter.status;
	}
	
    BOOL success = [videoWriter finishWriting];
    if (!success) {
    
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
