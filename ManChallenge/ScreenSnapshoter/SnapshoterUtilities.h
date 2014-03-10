//
//  SnapshoterUtilities.h
//  ManChallenge
//
//  Created by Littlebox222 on 14-3-10.
//  Copyright (c) 2014年 Littlebox222. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

@interface SnapshoterUtilities : NSObject

+ (void)mergeVideo:(NSString *)videoPath andAudio:(NSString *)audioPath andTarget:(id)target andAction:(SEL)action;

@end