//
//  GameOverLayer.h
//  ManChallenge
//
//  Created by Littlebox222 on 14-2-13.
//  Copyright 2014年 Littlebox222. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameOverLayer : CCLayerColor {
    
}

+(CCScene *) sceneInitWithScore:(double)score andBestScore:(double)bestScore;
-(id) initWithScore:(double)score andBestScore:(double)bestScore;

@end
