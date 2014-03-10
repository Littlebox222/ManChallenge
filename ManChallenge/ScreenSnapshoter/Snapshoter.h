//
//  Snapshoter.h
//  ManChallenge
//
//  Created by Littlebox222 on 14-3-10.
//  Copyright (c) 2014年 Littlebox222. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnapshoterUtilities.h"
#import "cocos2d.h"

@protocol SnapshoterDelegate;

@interface Snapshoter : NSObject {
    
    AVAssetWriter *videoWriter;
	AVAssetWriterInput *videoWriterInput;
	AVAssetWriterInputPixelBufferAdaptor *avAdaptor;
    
    BOOL _recording;
    BOOL _writing;
	NSDate *startedAt;
    CGContextRef context;
    NSTimer *timer;
    
    NSUInteger _frameRate;
    
    dispatch_queue_t qt;
}

@property (assign) NSUInteger frameRate;
@property (nonatomic, assign) CCScene* ccScene;
@property (nonatomic, assign) id<SnapshoterDelegate> delegate;
@property(assign) BOOL shouldStopRecording;
@property(nonatomic, retain) CCSprite *spriteBufferCache;

+ (Snapshoter *)sharedSnapshoter;

- (bool)startRecording;
- (void)stopRecording;

@end



@protocol SnapshoterDelegate <NSObject>

- (void)recordingFinished:(NSString*)outputPath;
- (void)recordingFaild:(NSError *)error;

@end