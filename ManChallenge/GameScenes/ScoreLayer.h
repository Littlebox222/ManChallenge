//
//  ScoreLayer.h
//  ManChallenge
//
//  Created by Littlebox222 on 14-2-12.
//  Copyright 2014年 Littlebox222. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ScoreLayer : CCLayer {
    
    CCLabelTTF *_labelLivingTime;
    CCLabelTTF *_labelBestTime;
}

@property (nonatomic, assign) double livingTime;
@property (nonatomic, assign) double bestTime;
@property (nonatomic, assign) BOOL isGameOver;


@end
