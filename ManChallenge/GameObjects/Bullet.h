//
//  Bullet.h
//  ManChallenge
//
//  Created by Littlebox222 on 14-3-7.
//  Copyright (c) 2014年 Littlebox222. All rights reserved.
//

#import "GameObject.h"
#import "Cannon.h"

@interface Bullet : GameObject {
    
    NSMutableArray *_containArray;
}


- (id)initWithFile:(NSString *)filename andContainArray:(NSMutableArray *)containArray;

- (id)initWithFile:(NSString *)filename andContainArray:(NSMutableArray *)containArray fromCannon:(Cannon *)cannon;

@end
