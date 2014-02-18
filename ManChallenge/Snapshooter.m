//
//  Snapshooter.m
//  ManChallenge
//
//  Created by Littlebox222 on 14-2-18.
//  Copyright (c) 2014年 Littlebox222. All rights reserved.
//

#import "Snapshooter.h"

#define TIME_SCALE 24 // frames per second

@implementation Snapshooter

- (void)dealloc {
    
    [_assetWriter release];
    [_assetWriterInput release];
    [_assetWriterPixelBufferAdaptor release];    
    [_assetWriterTimer release];

    [super dealloc];
}

- (id)initWithFileName:(NSString *)fileName {
    
    if (self = [super init]) {
        
        NSString *moviePath = [self filePath:fileName];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:moviePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:moviePath error:nil];
        }
        
        NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
        NSError *movieError = nil;
        
        [_assetWriter release];
        _assetWriter = [[AVAssetWriter alloc] initWithURL:movieURL
                                                 fileType:AVFileTypeQuickTimeMovie
                                                    error:&movieError];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        NSDictionary *assetWriterInputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  AVVideoCodecH264, AVVideoCodecKey,
                                                  [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                                  [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                                  nil];
        
        _assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                               outputSettings:assetWriterInputSettings];
        _assetWriterInput.expectsMediaDataInRealTime = YES;
        [_assetWriter addInput:_assetWriterInput];
        
        [_assetWriterPixelBufferAdaptor release];
        _assetWriterPixelBufferAdaptor =  [[AVAssetWriterInputPixelBufferAdaptor  alloc] initWithAssetWriterInput:_assetWriterInput
                                                                                      sourcePixelBufferAttributes:nil];
    }
    
    return self;
}

- (NSString*)filePath:(NSString *)fileName {
    
    NSArray* myPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* myDocPath = [myPaths objectAtIndex:0];
    NSString* filePath = [myDocPath stringByAppendingPathComponent:fileName];
    return filePath;
}

- (UIImage*)screenshotWithStartNode:(CCNode*)startNode {
    
    [CCDirector sharedDirector].nextDeltaTimeZero = YES;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    CCRenderTexture* rtx = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height];
    [rtx begin];
    [startNode visit];
    [rtx end];
    
    return [rtx getUIImage];
}

- (void)startRecording {
    
    // create the AVAssetWriter
    
    [_assetWriter startWriting];
    
    _firstFrameWallClockTime = CFAbsoluteTimeGetCurrent();
    [_assetWriter startSessionAtSourceTime: CMTimeMake(0, TIME_SCALE)];
    
    // start writing samples to it
    [_assetWriterTimer release];
    _assetWriterTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                        target:self
                                                      selector:@selector(writeSample:)
                                                      userInfo:nil
                                                       repeats:YES] ;
    
}

- (void)stopRecording {
    
    [_assetWriterTimer invalidate];
    _assetWriterTimer = nil;
    
    [_assetWriter finishWriting];
}

- (void)writeSample:(NSTimer*)timer {
    
    if (_assetWriterInput.readyForMoreMediaData) {
        
        CVReturn cvErr = kCVReturnSuccess;
        
        // get screenshot image!
        CGImageRef image = (CGImageRef) [[self createARGBImageFromRGBAImage:[self screenshotWithStartNode:_startNode]] CGImage];
        
        // prepare the pixel buffer
        CVPixelBufferRef pixelBuffer = NULL;
        CFDataRef imageData= CGDataProviderCopyData(CGImageGetDataProvider(image));
        cvErr = CVPixelBufferCreateWithBytes(kCFAllocatorDefault,
                                             FRAME_WIDTH,
                                             FRAME_HEIGHT,
                                             kCVPixelFormatType_32ARGB,
                                             (void*)CFDataGetBytePtr(imageData),
                                             CGImageGetBytesPerRow(image),
                                             NULL,
                                             NULL,
                                             NULL,
                                             &pixelBuffer);
        
        // calculate the time
        CFAbsoluteTime thisFrameWallClockTime = CFAbsoluteTimeGetCurrent();
        CFTimeInterval elapsedTime = thisFrameWallClockTime - _firstFrameWallClockTime;
        //NSLog (@”elapsedTime: %f”, elapsedTime);
        CMTime presentationTime =  CMTimeMake (elapsedTime * TIME_SCALE, TIME_SCALE);
        
        // write the sample
        BOOL appended = [_assetWriterPixelBufferAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:presentationTime];
        
        if (appended)
        {   NSLog (@"appended sample at time %lf", CMTimeGetSeconds(presentationTime));
        } else
        {   NSLog (@"failed to append");
            [self stopRecording];
        }
    }
}
                     
- (UIImage *)createARGBImageFromRGBAImage:(UIImage*)image {
    
    CGSize dimensions = [image size];
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * dimensions.width;
    NSUInteger bitsPerComponent = 8;
    
    unsigned char *rgba = malloc(bytesPerPixel * dimensions.width * dimensions.height);
    unsigned char *argb = malloc(bytesPerPixel * dimensions.width * dimensions.height);
    
    CGColorSpaceRef colorSpace = NULL;
    CGContextRef context = NULL;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate(rgba, dimensions.width, dimensions.height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault); // kCGBitmapByteOrder32Big
    CGContextDrawImage(context, CGRectMake(0, 0, dimensions.width, dimensions.height), [image CGImage]);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    for (int x = 0; x < dimensions.width; x++) {
        for (int y = 0; y < dimensions.height; y++) {
            NSUInteger offset = ((dimensions.width * y) + x) * bytesPerPixel;
            argb[offset + 0] = rgba[offset + 3];
            argb[offset + 1] = rgba[offset + 0];
            argb[offset + 2] = rgba[offset + 1];
            argb[offset + 3] = rgba[offset + 2];
        }
    }
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate(argb, dimensions.width, dimensions.height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrderDefault); // kCGBitmapByteOrder32Big
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    image = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    free(rgba);
    free(argb);
    
    return image;
}

@end
