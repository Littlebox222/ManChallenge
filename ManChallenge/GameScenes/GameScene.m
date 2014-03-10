//
//  GameScene.m
//  ManChallenge
//
//  Created by Littlebox222 on 14-3-7.
//  Copyright (c) 2014年 Littlebox222. All rights reserved.
//

#import "GameScene.h"
#import "SimpleAudioEngine.h"
#import "GameOverScene.h"

#define kWinSizeHeight [[CCDirector sharedDirector] winSize].height
#define kWinSizeWidth [[CCDirector sharedDirector] winSize].width
#define kPicMoveBy [CCMoveBy actionWithDuration:1.0f position:ccp(0, -kWinSizeHeight)]

static GameScene *sharedScene;

@implementation GameScene

@synthesize levelLayer = _levelLayer;
@synthesize scoreLayer = _scoreLayer;
@synthesize background1 = _background1;
@synthesize background2 = _background2;
@synthesize snapshorer = _snapshorer;

- (NSString*)filePath:(NSString*)fileName {
    
    NSArray* myPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* myDocPath = [myPaths objectAtIndex:0];
    NSString* filePath = [myDocPath stringByAppendingPathComponent:fileName];
    return filePath;
}

- (void)dealloc {
    
    [_snapshorer release];
    
    [_scoreLayer release];
    [_levelLayer release];
    
    [super dealloc];
}

+ (GameScene *)sharedScene {
    
    return sharedScene;
}

- (void)actionFinishedWithSprite:(CCSprite *)theSprite {
    
    if (theSprite.position.y == -kWinSizeHeight){
        
        [theSprite setPosition:ccp(0, kWinSizeHeight)];
    }
    
    CCCallBlock *picFinish = [CCCallBlock actionWithBlock:^(void){[self actionFinishedWithSprite:theSprite];}];
    [theSprite runAction:[CCSequence actions:kPicMoveBy, picFinish, nil]];
}

- (id)initWithBackgroundFile:(NSString *)filename {
    
    if (self = [super init]) {
        
        _background1 = [CCSprite spriteWithFile:filename rect:(CGRect){{0, 0}, {kWinSizeWidth, kWinSizeHeight}}];
        _background2 = [CCSprite spriteWithFile:filename rect:(CGRect){{0, 0}, {kWinSizeWidth, kWinSizeHeight}}];
        
        _background1.anchorPoint = ccp(0, 0);
        _background2.anchorPoint = ccp(0, 0);
        
        _background1.position = ccp(0, 0);
        _background2.position = ccp(0, kWinSizeHeight);
        
//        [self addChild:_background1];
//        [self addChild:_background2];
        
        
        CCCallBlock *pic1Finish = [CCCallBlock actionWithBlock:^(void){[self actionFinishedWithSprite:_background1];}];
        CCCallBlock *pic2Finish = [CCCallBlock actionWithBlock:^(void){[self actionFinishedWithSprite:_background2];}];
        
        [_background1 runAction:[CCSequence actions:kPicMoveBy, pic1Finish, nil]];
        [_background2 runAction:[CCSequence actions:kPicMoveBy, pic2Finish, nil]];
        
        self.levelLayer = [LevelLayer node];
        [self addChild:_levelLayer];
        self.scoreLayer = [ScoreLayer node];
        [self addChild:_scoreLayer];
        
        self.snapshorer = [[[Snapshoter alloc] init] autorelease];
        _snapshorer.frameRate = 60;
        _snapshorer.delegate = self;
        [_snapshorer startRecording];
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"game_music.mp3"];
        
        sharedScene = self;
    }
    
    return self;
}

- (void)handleGameOver {
    
    [_snapshorer stopRecording];
    
    _scoreLayer.isGameOver = YES;
    
    CCScene *gameOverScene = [GameOverScene sceneInitWithScore:_scoreLayer.livingTime andBestScore:_scoreLayer.bestTime];
    [[CCDirector sharedDirector] replaceScene:gameOverScene];
    
    if (_scoreLayer.bestTime < _scoreLayer.livingTime) {
        
        NSString* fileName = [self filePath:@"bestTime.plist"];
        
        NSMutableArray* data = [[[NSMutableArray alloc] init] autorelease];
        
        [data addObject:[NSString stringWithFormat:@"%f", _scoreLayer.livingTime]];
        [data writeToFile:fileName atomically:YES];
    }
}

- (void)handleLevelChanged {
    
    
}

#pragma mark - CustomMethod

- (void)video: (NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo{
    
	if (error) {
		NSLog(@"%@",[error localizedDescription]);
	}
}

- (void)mergedidFinish:(NSString *)videoPath WithError:(NSError *)error
{
    //音频与视频合并结束，存入相册中
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath)) {
		UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
	}
}

#pragma mark - SnapshoterDelegate

- (void)recordingFinished:(NSString*)outputPath
{
    NSLog(@"%@", outputPath);
}

- (void)recordingFaild:(NSError *)error
{
    NSLog(@"%@", error);
}

@end
