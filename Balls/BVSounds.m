//
//  BVSounds.m
//  BallSpectrum
//
//  Created by Bhawan Virk on 2/9/16.
//  Copyright © 2016 Bhawan Virk. All rights reserved.
//

#import "BVSounds.h"
#import "BVGameData.h"

@interface BVSounds () <AVAudioPlayerDelegate>

@property (nonatomic) AVAudioPlayer *backgroundMusicPlayer;
@property (nonatomic) AVAudioPlayer *secondaryMusicPlayer;

@end

@implementation BVSounds
{
    AVAudioPlayer *_lastPlayer;
}

+ (BVSounds *)sharedInstance
{
    static dispatch_once_t onceToken;
    static BVSounds * storeManagerSharedInstance;
    
    dispatch_once(&onceToken, ^{
        storeManagerSharedInstance = [[BVSounds alloc] init];
    });
    return storeManagerSharedInstance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        // setup main loop if sound enabled by user
        if ([[BVGameData sharedGameData] isSoundOn]) {
            [self setupBackgroundMusicPlayer];
            [self setupSecondaryMusicPlayer];
            _lastPlayer = _backgroundMusicPlayer;
        }
    }
    
    return self;
}

#pragma mark - Music Player Controls

- (void)playMusic
{
    if (_lastPlayer == _backgroundMusicPlayer) {
        [self playBackgroundMusicIfEnabled];
    }
    else {
        [self playSecondaryMusicIfEnabled];
    }
}

- (void)stopMusic
{
    if (_backgroundMusicPlayer.playing) {
        [self stopBackgroundMusic];
        _lastPlayer = _backgroundMusicPlayer;
    }
    else {
        [self stopSecondaryMusic];
        _lastPlayer = _secondaryMusicPlayer;
    }
}

#pragma mark - Background Music Player

- (void)setupBackgroundMusicPlayer
{
    NSError *error;
    NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"main-loop" withExtension:@"mp3"];
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    self.backgroundMusicPlayer.numberOfLoops = 3;
    self.backgroundMusicPlayer.delegate = self;
    [self.backgroundMusicPlayer prepareToPlay];
}

- (void)playBackgroundMusicIfEnabled
{
    if ([[BVGameData sharedGameData] isSoundOn]) {
        if (!self.backgroundMusicPlayer) {
            [self setupBackgroundMusicPlayer];
            [self setupSecondaryMusicPlayer];
        }
        
        [self.backgroundMusicPlayer play];
    }
}

- (void)stopBackgroundMusic
{
    [self.backgroundMusicPlayer stop];
}

#pragma mark - Music Player Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"loop finished: %@", player);
    
    if (player == _backgroundMusicPlayer) {
        // start playing secondary music player
        [self playSecondaryMusicIfEnabled];
    }
    else {
        // start playing main music player
        [self playBackgroundMusicIfEnabled];
    }
}

#pragma mark - Secondary Music Player

- (void)setupSecondaryMusicPlayer
{
    NSError *error;
    NSURL *secondaryMusicURL = [[NSBundle mainBundle] URLForResource:@"birds-loop" withExtension:@"mp3"];
    self.secondaryMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:secondaryMusicURL error:&error];
    self.secondaryMusicPlayer.numberOfLoops = 4;
    self.secondaryMusicPlayer.delegate = self;
    [self.secondaryMusicPlayer prepareToPlay];
}

- (void)playSecondaryMusicIfEnabled
{
    if ([[BVGameData sharedGameData] isSoundOn]) {
        [self.secondaryMusicPlayer play];
    }
}

- (void)stopSecondaryMusic
{
    [self.secondaryMusicPlayer stop];
}

#pragma mark - Level Sounds
+ (SKAction *)levelPassed
{
    return [BVSounds giveSoundAction:@"level-passed.caf"];
}

+ (SKAction *)targetBucketHit
{
    return [BVSounds giveSoundAction:@"target-bucket-hit.caf"];
}

+ (SKAction *)bomb
{
    return [BVSounds giveSoundAction:@"bomb.caf"];
}

+ (SKAction *)ballPops
{
    return [BVSounds giveSoundAction:@"ball-pops.caf"];
}

+ (SKAction *)ballTap
{
    return [BVSounds giveSoundAction:@"ball-tap.caf"];
}

+ (SKAction *)bucketLaser
{
    return [BVSounds giveSoundAction:@"bucket-laser.caf"];
}

+ (SKAction *)ballDropInBucket
{
    return [BVSounds giveSoundAction:@"ball-drop-into-bucket.caf"];
}

+ (SKAction *)flyingObjectBanner
{
    return [BVSounds giveSoundAction:@"flying-object-banners.caf"];
}

#pragma mark - Playground Sounds
+ (SKAction *)playgroundPlayerJump
{
    return [BVSounds giveSoundAction:@"jump.caf"];
}

+ (SKAction *)coin
{
    return [BVSounds giveSoundAction:@"coin.caf"];
}

+ (SKAction *)playgroundCollision
{
    return [BVSounds giveSoundAction:@"punch.caf"];
}

#pragma mark - Misc Sounds
+ (SKAction *)tap
{
    return [BVSounds giveSoundAction:@"tap.caf"];
}

#pragma mark - Utility Methods
+ (SKAction *)giveSoundAction:(NSString *)soundName
{
    SKAction *sound;
    if ([[BVGameData sharedGameData] isSoundOn]) {
        sound = [SKAction playSoundFileNamed:soundName waitForCompletion:NO];
    }
    
    return sound;
}

@end
