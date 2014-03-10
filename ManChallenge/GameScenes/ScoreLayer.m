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
@synthesize isGameOver = _isGameOver;

- (NSString*)filePath:(NSString*)fileName {
    
    NSArray* myPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* myDocPath = [myPaths objectAtIndex:0];
    NSString* filePath = [myDocPath stringByAppendingPathComponent:fileName];
    return filePath;
}

-(id)init {
    
    if ((self = [super init])) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        _labelLivingTime = [CCLabelTTF labelWithString:@"AppleGothic" fontName:@"AppleGothic" fontSize:14];
        _labelLivingTime.color = ccc3(255,255,255);
        int margin = 10;
        _labelLivingTime.position = ccp(winSize.width - (_labelLivingTime.contentSize.width/2) - margin - 20, _labelLivingTime.contentSize.height/2 + margin);
        [self addChild:_labelLivingTime];
        
        
        _livingTime = 0.0f;
        
        _labelBestTime = [CCLabelTTF labelWithString:@"AppleGothic" fontName:@"AppleGothic" fontSize:14];
        _labelBestTime.color = ccc3(255,255,255);
        _labelBestTime.position = ccp(55, _labelBestTime.contentSize.height/2 + margin);
        [self addChild:_labelBestTime];
        
        NSString* fileName = [self filePath:@"bestTime.plist"];
        if ([[NSFileManager defaultManager]fileExistsAtPath:fileName]) {
            
            NSArray* data = [[NSArray alloc]initWithContentsOfFile:fileName];
            _bestTime = [[data objectAtIndex:0] floatValue];
            [data release];
            
            [_labelBestTime setString:[NSString stringWithFormat:@"Best time: %.1f", _bestTime]];
        }
        
        _isGameOver = NO;
        
        [self scheduleUpdate];
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    
    if (!_isGameOver) {
        
        _livingTime += delta;
        
        [_labelLivingTime setString:[NSString stringWithFormat:@"Living time: %.1f", _livingTime]];
    }
}

@end