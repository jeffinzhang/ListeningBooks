//
//  ViewController.m
//  简易听书AVSpeechSynthesizer
//
//  Created by 张建飞 on 2017/8/10.
//  Copyright © 2017年 JeffinZhang. All rights reserved.
//

#import "ViewController.h"
#import "JeffinSpeechPalyer.h"
#import "JeffinSpeechView.h"
#import "JeffinSpeechModel.h"

#define  WIDTH  [UIScreen mainScreen].bounds.size.width
#define  HEIGHT  [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<JeffinSpeechViewDelegate, JeffinSpeechPalyerDelegate>
@property (nonatomic,strong) JeffinSpeechView *SpeechView;
@property (nonatomic,strong) JeffinSpeechPalyer *SpeechPalyer;

@property (nonatomic,strong) UILabel *lab;
@property (nonatomic,assign) NSInteger pageNum;
@property (nonatomic,strong) NSArray *pageArry;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.SpeechView = [[JeffinSpeechView alloc]initWithFrame:CGRectMake(0, HEIGHT - 250, WIDTH, 250)];
    self.SpeechView.delegate = self;
    [self.view addSubview:self.SpeechView];
    
    
    self.SpeechPalyer = [[JeffinSpeechPalyer alloc]init];
    self.SpeechPalyer.delegate = self;
    self.lab.text = @"只是实现功能,具体代码没有优化,\n\n如果使用,请自行优化\n\n 点击开始听书";
    [self.view addSubview:self.lab];
    
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"BookContent" ofType:@"plist"];
    self.pageArry = [NSArray arrayWithContentsOfFile:path];
    
    
    [self addInterruptionNotification];
    
}

- (void)SpeechViewSpeechLast{
    
    if (self.pageNum>=1) {
        
        self.pageNum = self.pageNum - 1;
        
        [JeffinSpeechModel sharedSpeechPlayerModel].SpeechWords = [self.pageArry objectAtIndex:self.pageNum];
        
        self.lab.text = [JeffinSpeechModel sharedSpeechPlayerModel].SpeechWords;
        
        [self.SpeechPalyer speechLast];
        
    }else{
        
        [self SpeechViewSpeechStop];
        
        self.lab.text = @"已经是第一页了\n退出听书";
        
    }
    
    
}

- (void)SpeechViewSpeechNext{
    
    if (self.pageNum < self.pageArry.count - 1 ) {
        
        self.pageNum = self.pageNum + 1;
        
        [JeffinSpeechModel sharedSpeechPlayerModel].SpeechWords = [self.pageArry objectAtIndex:self.pageNum];
        self.lab.text = [JeffinSpeechModel sharedSpeechPlayerModel].SpeechWords;
        
        [self.SpeechPalyer speechNext];
        
    }else{
        
        [self SpeechViewSpeechStop];
        self.lab.text = @"这是最后一页了\n退出听书";
        
    }
    
    
}

//暂停继续
- (void)SpeechViewPauseOrContinue{
    
    [self.SpeechPalyer speechPauseOrContinue];
    
}
//语速
- (void)SpeechViewSpeedValueChanged{
    
    [self.SpeechPalyer speechSpeed];
    
}
//定时
- (void)SpeechViewSpeechTime{
    
    [self.SpeechPalyer speechTime];
    
}
//发音人
- (void)SpeechViewSpeechSpeaker{
    
    [self.SpeechPalyer speechSpeaker];
    
}

//开始
- (void)SpeechViewSpeechStart{
    
    //开启后台
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    //接受远程控制
    [self becomeFirstResponder];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    
    [JeffinSpeechModel sharedSpeechPlayerModel].coverName = @"cover";
    [JeffinSpeechModel sharedSpeechPlayerModel].novelName = @"一只特立独行的猪";
    [JeffinSpeechModel sharedSpeechPlayerModel].authorName = @"王小波";
    
    
    self.pageNum = 0;
    [JeffinSpeechModel sharedSpeechPlayerModel].SpeechWords = [self.pageArry objectAtIndex:self.pageNum];
    self.lab.text = [JeffinSpeechModel sharedSpeechPlayerModel].SpeechWords;
    [JeffinSpeechModel sharedSpeechPlayerModel].speaker = girlOne;
    [JeffinSpeechModel sharedSpeechPlayerModel].speed = 5;
    
    [self.SpeechPalyer speechStop];
    
    [self.SpeechPalyer speechStart];
    
    [self.SpeechPalyer speechScreenInfo];
    
}

//退出
- (void)SpeechViewSpeechStop{
    
    [self.SpeechPalyer speechStop];
    
    self.lab.text = @"只是实现功能,具体代码没有优化,\n\n如果使用,请自行优化\n\n 点击开始听书";

    //取消远程控制
    [self resignFirstResponder];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    [JeffinSpeechModel sharedSpeechPlayerModel].coverName = nil;
    [JeffinSpeechModel sharedSpeechPlayerModel].novelName = nil;
    [JeffinSpeechModel sharedSpeechPlayerModel].authorName = nil;
    
    
}


- (void)SpeechPalyerFinshedCurrentParagraph{
    
    [self SpeechViewSpeechNext];
    
}


- (UILabel *)lab{
    if (_lab == nil) {
        _lab = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, WIDTH - 20, HEIGHT - 250 - 20 )];
        _lab.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        _lab.numberOfLines = 0;
    }
    return _lab;
}



#pragma mark -远程响应控制

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlPlay://播放
                [self SpeechViewPauseOrContinue];
                
                break;
            case UIEventSubtypeRemoteControlPause://暂停
                [self SpeechViewPauseOrContinue];
                
                break;
                
            case UIEventSubtypeRemoteControlTogglePlayPause: //耳机暂停/继续(只适用于耳机)
                [self SpeechViewPauseOrContinue];
                
                break;
                
            case UIEventSubtypeRemoteControlNextTrack://下一曲
                [self SpeechViewSpeechNext];
                
                break;
            case UIEventSubtypeRemoteControlPreviousTrack://上一曲
                [self SpeechViewSpeechLast];
                
                break;
                
            default:
                break;
        }
        
    }
    
}

/**
 听书时被别的app打断通知
 */

- (void)addInterruptionNotification {
    //打断监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
    
    //耳机监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];

    
}
/**
 听书时被别的app打断处理
 
 @param notification 通知内容
 */

- (void)handleInterruption:(NSNotification *) notification{
    
    if (notification.name != AVAudioSessionInterruptionNotification || notification.userInfo == nil) {
        return;
    }
    
    NSDictionary *info = notification.userInfo;
    
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification]) {
        
        if ([[info valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]]) {
            
            NSLog(@"InterruptionTypeBegan");
            
            [self SpeechViewPauseOrContinue];
            
        } else {
            
            NSLog(@"InterruptionTypeEnded");
            
            [self SpeechViewPauseOrContinue];
            
        }
    }
}



- (void)handleRouteChange:(NSNotification *)notification{
    
    /*
     当耳机插入的时候，AVAudioSessionRouteChangeReason等于AVAudioSessionRouteChangeReasonNewDeviceAvailable
     代表一个新外接设备可用，但是插入耳机，我们不需要处理。所以不做判断。
     
     当耳机拔出的时候 AVAudioSessionRouteChangeReason等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable
     代表一个之前外的外接设备不可用了，此时我们需要处理，让他播放器静音 。
     
     AVAudioSessionRouteChangePreviousRouteKey：当之前的线路改变的时候，
     
     获取到线路的描述对象：AVAudioSessionRouteDescription，然后获取到输出设备，判断输出设备的类型是否是耳机,
     如果是就暂停播放
     */
    
    
    NSDictionary *info = notification.userInfo;
    
    AVAudioSessionRouteChangeReason reason = [info[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        
        AVAudioSessionRouteDescription *previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey];
        
        AVAudioSessionPortDescription *previousOutput = previousRoute.outputs[0];
        
        NSString *portType = previousOutput.portType;
        
        if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {
           
            [self SpeechViewPauseOrContinue];
        }
        
    }
//    NSLog(@"%@",info);
    
}


@end
