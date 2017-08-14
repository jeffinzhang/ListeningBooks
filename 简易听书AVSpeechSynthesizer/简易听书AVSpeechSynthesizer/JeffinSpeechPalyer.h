//
//  JeffinSpeechPalyer.h
//  简易听书AVSpeechSynthesizer
//
//  Created by 张建飞 on 2017/8/10.
//  Copyright © 2017年 JeffinZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol JeffinSpeechPalyerDelegate <NSObject>

@required

- (void)SpeechPalyerFinshedCurrentParagraph;

@end

@interface JeffinSpeechPalyer : NSObject

@property (nonatomic,assign) id <JeffinSpeechPalyerDelegate> delegate;

@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;//听书



+(instancetype)shareSpeechSynthesis;

/**
 *  开始
 */
- (void)speechStart;

/**
 *  停止
 */
- (void)speechStop;

/**
 *  暂停/继续
 */
- (void)speechPauseOrContinue;

/**
 *  下一页
 */
- (void)speechNext;

/**
 *  上一页
 */
- (void)speechLast;

/**
 *  语速
 */
- (void)speechSpeed;

/**
 *  定时
 */
- (void)speechTime;


/**
 发音人
 */
- (void)speechSpeaker;

/**
 *  锁屏信息
 */
- (void)speechScreenInfo;

@end
