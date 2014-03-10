//
//  Hero.h
//  ManChallenge
//
//  Created by Littlebox222 on 14-3-7.
//  Copyright (c) 2014年 Littlebox222. All rights reserved.
//

#import "GameObject.h"

@interface Hero : GameObject {
    
    BOOL _destroyed;
    float _posPerSecByAccX;
    float _posPerSecByAccY;
}

@property (nonatomic, assign) BOOL destroyed;
@property (nonatomic, assign) float posPerSecByAccX;
@property (nonatomic, assign) float posPerSecByAccY;


- (id)initWithFile:(NSString *)filename;
- (void)handleCollisionWith:(GameObject *)gameObject;
- (void)update:(ccTime)delta;

@end
