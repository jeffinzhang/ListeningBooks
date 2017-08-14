//
//  JeffinSpeechView.h
//  简易听书AVSpeechSynthesizer
//
//  Created by 张建飞 on 2017/8/10.
//  Copyright © 2017年 JeffinZhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JeffinSpeechViewDelegate <NSObject>

@optional

- (void)SpeechViewPauseOrContinue;

- (void)SpeechViewSpeedValueChanged;

- (void)SpeechViewSpeechTime;

- (void)SpeechViewSpeechSpeaker;

- (void)SpeechViewSpeechStart;

- (void)SpeechViewSpeechStop;

- (void)SpeechViewSpeechLast;

- (void)SpeechViewSpeechNext;

@end

@interface JeffinSpeechView : UIView

@property (nonatomic,assign) id <JeffinSpeechViewDelegate> delegate;

@property (nonatomic,strong) UIButton *pauseButn;

@end
