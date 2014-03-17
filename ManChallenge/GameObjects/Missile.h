//
//  Missile.h
//  ManChallenge
//
//  Created by Littlebox on 14-3-17.
//  Copyright (c) 2014年 Littlebox222. All rights reserved.
//

#import "GameObject.h"

@interface Missile : GameObject {
    
    NSMutableArray *_containArray;
}

- (id)initWithFile:(NSString *)filename andContainArray:(NSMutableArray *)containArray targetObject:(GameObject *)target;

@end
