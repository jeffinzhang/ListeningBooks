//
//  JeffinSpeechPalyer.m
//  简易听书AVSpeechSynthesizer
//
//  Created by 张建飞 on 2017/8/10.
//  Copyright © 2017年 JeffinZhang. All rights reserved.
//

#import "JeffinSpeechPalyer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "JeffinSpeechModel.h"
#import "JeffinSpeechView.h"

@interface JeffinSpeechPalyer ( )<AVSpeechSynthesizerDelegate>

/** 当前播放的索引 */
@property (nonatomic, assign) NSInteger currentIndex;

/** 当前正在播放的播放器对象*/

@property (nonatomic ,weak) AVAudioPlayer *currentPlayer;

@end

@implementation JeffinSpeechPalyer

- (AVSpeechSynthesizer *)synthesizer{
    
    if (_synthesizer == nil){
        
        _synthesizer = [[AVSpeechSynthesizer alloc]init];
        _synthesizer.delegate = self;
    }
    return _synthesizer;
}


+(instancetype)shareSpeechSynthesis{
    
    static id shareSpeechSynthesis;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        shareSpeechSynthesis = [[self alloc] init];
    });
    
    return shareSpeechSynthesis;
}

/**
 *  开始
 */
- (void)speechStart{
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:[JeffinSpeechModel sharedSpeechPlayerModel].SpeechWords];
    
    AVSpeechSynthesisVoice *voiceType = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    
    utterance.voice = voiceType;
    
    switch ((NSInteger)[JeffinSpeechModel sharedSpeechPlayerModel].speed){
            
        case 0:
            utterance.rate  = 0.4;
            break;
        case 1:
            utterance.rate  = 0.45;
            break;
        case 2:
            utterance.rate  = 0.50;
            break;
        case 3:
            utterance.rate  = 0.52;
            break;
        case 4:
            utterance.rate  = 0.54;
            break;
        case 5:
            utterance.rate  = 0.56;
            break;
        case 6:
            utterance.rate  = 0.58;
            break;
        case 7:
            utterance.rate  = 0.60;
            break;
        case 8:
            utterance.rate  = 0.63;
            break;
        case 9:
            utterance.rate  = 0.67;
            break;
            
        default:
            break;
    }
    
    if([JeffinSpeechModel sharedSpeechPlayerModel].speaker == girlOne ){
        
        utterance.pitchMultiplier = 1;
        
    }else{
        
        utterance.pitchMultiplier = 0.77;
        
    }
    
    [self.synthesizer speakUtterance:utterance];
    
    [JeffinSpeechModel sharedSpeechPlayerModel].isWorking = YES;
    
}


/**
 *  停止
 */
- (void)speechStop{
    
    [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    
    [JeffinSpeechModel sharedSpeechPlayerModel].isWorking = NO;
    [JeffinSpeechModel sharedSpeechPlayerModel].isPaused = NO;
    
}

/**
 *  暂停/继续
 */
- (void)speechPauseOrContinue{
    
    
    JeffinSpeechView *SpeechV = [[JeffinSpeechView alloc]init];
    

    if (self.synthesizer.isPaused == YES) {
        
        [self.synthesizer continueSpeaking];
        [JeffinSpeechModel sharedSpeechPlayerModel].isPaused = NO;
       
        [SpeechV.pauseButn setImage:[UIImage imageNamed:@"page_playing"] forState:UIControlStateNormal];

        
    }else{
        
        [self.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        [JeffinSpeechModel sharedSpeechPlayerModel].isPaused = YES;
        [SpeechV.pauseButn setImage:[UIImage imageNamed:@"page_pause"] forState:UIControlStateNormal];

    }
}


/**
 *  下一页
 */
- (void)speechNext{
    
    [JeffinSpeechModel sharedSpeechPlayerModel].isPaused = NO;

    [self speechStop];
    [self speechStart];
    
}

/**
 *  上一页
 */
- (void)speechLast{
    
    [JeffinSpeechModel sharedSpeechPlayerModel].isPaused = NO;
    
    [self speechStop];
    [self speechStart];
}

/**
 *  语速
 */
- (void)speechSpeed{
    
    [self speechStop];
    [self speechStart];

}

/**
 *  定时
 */
- (void)speechTime{
    
    [self speechStop];
}

/**
 发音人
 */
- (void)speechSpeaker{
    
    [self speechStop];
    [self speechStart];
    
}

/**
 *  锁屏信息
 */
- (void)speechScreenInfo{
    
    UIImage *image = [UIImage  imageNamed: [JeffinSpeechModel sharedSpeechPlayerModel].coverName];
    
    NSString *novelName = [JeffinSpeechModel sharedSpeechPlayerModel].novelName;
    
    NSString *authorName = [JeffinSpeechModel sharedSpeechPlayerModel].authorName;
    
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:image];
    
    NSDictionary *dic = @{MPMediaItemPropertyTitle:novelName,
                          MPMediaItemPropertyArtist:authorName,
                          MPMediaItemPropertyArtwork:artWork
                          };
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dic];
    
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    
    
    if ([_delegate respondsToSelector:@selector(SpeechPalyerFinshedCurrentParagraph)]) {
        [_delegate SpeechPalyerFinshedCurrentParagraph];
    }
    
}


@end
