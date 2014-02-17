//
//  GameOverLayer.m
//  ManChallenge
//
//  Created by Littlebox222 on 14-2-13.
//  Copyright 2014年 Littlebox222. All rights reserved.
//

#import "GameOverLayer.h"
#import "HelloWorldLayer.h"

@implementation GameOverLayer

+(CCScene *) sceneInitWithScore:(double)score andBestScore:(double)bestScore {
    
    CCScene *scene = [CCScene node];
    GameOverLayer *layer = [[[GameOverLayer alloc] initWithScore:score andBestScore:bestScore] autorelease];
    [scene addChild: layer];
    return scene;
}

-(id) initWithScore:(double)score andBestScore:(double)bestScore {
    
    if ((self = [super initWithColor:ccc4(0, 0, 0, 0)])) {
        
        NSString * message = @"You Lose !";
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCLabelTTF * label = [CCLabelTTF labelWithString:message fontName:@"Arial" fontSize:32];
        label.color = ccc3(255,255,255);
        label.position = ccp(winSize.width/2, winSize.height/2 + 35);
        [self addChild:label];
        
        
        
        CCLabelTTF * labelScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"存活时间: %.1f", score] fontName:@"Arial" fontSize:24];
        labelScore.color = ccc3(255,255,255);
        labelScore.position = ccp(winSize.width/2, winSize.height/2 - 35);
        [self addChild:labelScore];
        
        
        CCLabelTTF * labelBestScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"最好成绩: %.1f", bestScore] fontName:@"Arial" fontSize:16];
        labelBestScore.color = ccc3(255,255,255);
        labelBestScore.position = ccp(winSize.width/2, winSize.height/2 - 95);
        [self addChild:labelBestScore];
        
        
        [self runAction:
         [CCSequence actions:
          [CCDelayTime actionWithDuration:3],
          [CCCallBlockN actionWithBlock:^(CCNode *node) {
             [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
         }],
          nil]];
    }
    return self;
}

@end
