//
//  Snapshooter.h
//  ManChallenge
//
//  Created by Littlebox222 on 14-2-18.
//  Copyright (c) 2014年 Littlebox222. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAssetWriter.h>
#import <CoreVideo/CVPixelBuffer.h>
#import <CoreMedia/CMTime.h>

#import "cocos2d.h"


@interface Snapshooter : NSObject {
    
    AVAssetWriter *_assetWriter;
    AVAssetWriterInput *_assetWriterInput;
    AVAssetWriterInputPixelBufferAdaptor *_assetWriterPixelBufferAdaptor;
    
    CFAbsoluteTime _firstFrameWallClockTime;
    NSTimer *_assetWriterTimer;
    CCNode *_startNode;
}

- (NSString*)filePath:(NSString*)fileName;

- (UIImage*)screenshotWithStartNode:(CCNode*)startNode;
- (void)startRecording;
- (void)stopRecording;
- (void)writeSample:(NSTimer*)timer;

- (UIImage *)createARGBImageFromRGBAImage:(UIImage*)image;

@end
