//
//  ScoreLayer.m
//  ManChallenge
//
//  Created by Littlebox222 on 14-2-12.
//  Copyright 2014年 Littlebox222. All rights reserved.
//

#import "ScoreLayer.h"


@implementation ScoreLayer

@synthesize livingTime = _livingTime;
@synthesize bestTime = _bestTime;

- (NSString*)filePath:(NSString*)fileName {
    
    NSArray* myPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* myDocPath = [myPaths objectAtIndex:0];
    NSString* filePath = [myDocPath stringByAppendingPathComponent:fileName];
    return filePath;
}

-(id)init {
    
    if ((self = [super init])) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        labelLivingTime = [CCLabelTTF labelWithString:@"AppleGothic" fontName:@"AppleGothic" fontSize:14];
        labelLivingTime.color = ccc3(255,255,255);
        int margin = 10;
        labelLivingTime.position = ccp(winSize.width - (labelLivingTime.contentSize.width/2) - margin - 20, labelLivingTime.contentSize.height/2 + margin);
        [self addChild:labelLivingTime];
        
        
        _livingTime = 0.0f;
        
        labelBestTime = [CCLabelTTF labelWithString:@"AppleGothic" fontName:@"AppleGothic" fontSize:14];
        labelBestTime.color = ccc3(255,255,255);
        labelBestTime.position = ccp(55, labelBestTime.contentSize.height/2 + margin);
        [self addChild:labelBestTime];
        
        NSString* fileName = [self filePath:@"bestTime.plist"];
        if ([[NSFileManager defaultManager]fileExistsAtPath:fileName]) {
            
            NSArray* data = [[NSArray alloc]initWithContentsOfFile:fileName];
            _bestTime = [[data objectAtIndex:0] floatValue];
            [data release];
            
            [labelBestTime setString:[NSString stringWithFormat:@"Best time: %.1f", _bestTime]];
        }
        
        //TODO:错误处理
    }
    
    return self;
}

- (void)scoreTimeChanged:(ccTime)dt {
    
    _livingTime += dt;
    
    [labelLivingTime setString:[NSString stringWithFormat:@"Living time: %.1f", _livingTime]];
}

@end