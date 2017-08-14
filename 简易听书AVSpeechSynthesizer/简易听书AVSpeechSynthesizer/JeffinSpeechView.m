//
//  JeffinSpeechView.m
//  简易听书AVSpeechSynthesizer
//
//  Created by 张建飞 on 2017/8/10.
//  Copyright © 2017年 JeffinZhang. All rights reserved.
//

#import "JeffinSpeechView.h"
#import "JeffinSpeechModel.h"


#define JFRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define  WIDTH  [UIScreen mainScreen].bounds.size.width
#define  HEIGHT  [UIScreen mainScreen].bounds.size.height

#define normalSliderIndex  4
#define normalTimerBtngtage 1200
#define normalSpeakerTag 4001

@interface JeffinSpeechView()

@property (nonatomic,strong) UIButton *nextPageBtn;
@property (nonatomic,strong) UIButton *lastPageBtn;

@property (nonatomic,strong) UIButton *girlOneBtn;//音色
@property (nonatomic,strong) UIButton *girlTwoBtn;

@property (nonatomic,strong) UISlider *slider;//语速

@property (nonatomic,strong) UIButton *startBtn;//开始
@property (nonatomic,strong) UIButton *stopBtn;

@property (nonatomic, strong) NSArray *pauseBtnArr;


@property (nonatomic,strong) NSArray *numbers;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) int timeDown;




//@property (nonatomic,strong) UIButton *lastPageBtn;
//@property (nonatomic,strong) UIButton *lastPageBtn;
//@property (nonatomic,strong) UIButton *lastPageBtn;
//@property (nonatomic,strong) UIButton *lastPageBtn;
//@property (nonatomic,strong) UIButton *lastPageBtn;
//

@end

@implementation JeffinSpeechView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:59/255.0 green:59/255.0 blue:59/255.0 alpha:1.0];
        [self configUI];
    }
    return self;
    
}

- (void)configUI{
    
    //分割线
    for (int i = 0; i < 4; i++) {
        UIView *lineV = [[UIView alloc]initWithFrame:CGRectMake(0, 50 + i * 50, WIDTH, 1)];
        [self addSubview:lineV];
        lineV.backgroundColor = JFRGBColor(101, 101, 101);
    }
    
    //标题
    for (int i = 0; i < 4 ; i++) {
        NSArray *titleArr = [NSArray arrayWithObjects:@"翻页",@"语速",@"定时",@"发音", nil];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 18 + i* 50, 26, 14)];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:11];
        label.text = [titleArr objectAtIndex:i];
        [self addSubview:label];
    }
    
    
    //翻页控件
    int listenSpace = (WIDTH - 90 - 40) / 2;
    NSArray *listenDefaultImgArr = [NSArray arrayWithObjects:@"page_last",@"page_next", nil];
    
    for (int i = 0; i < 2; i++) {
        UIButton *listenBtn = [[UIButton alloc] initWithFrame:CGRectMake( 51 + 14 + 10 + i * listenSpace * 2 , 10, 30, 30)];
        [listenBtn setImage:[UIImage imageNamed:[listenDefaultImgArr objectAtIndex:i]] forState:UIControlStateNormal];
        [self addSubview:listenBtn];
        
        listenBtn.tag = 5001 + i;
        [listenBtn addTarget:self action:@selector(listenStateChangeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    //播放暂停
    UIButton *pauseButn = [[UIButton alloc]initWithFrame:CGRectMake(51 + 14 + 10 / 2 + listenSpace , 10, 30, 30)];
    NSArray *pauseBtnArr = [NSArray arrayWithObjects:@"page_playing",@"page_pause", nil];
    self.pauseBtnArr = pauseBtnArr;
    [pauseButn setImage:[UIImage imageNamed:[pauseBtnArr objectAtIndex:[JeffinSpeechModel sharedSpeechPlayerModel].isPaused]] forState:UIControlStateNormal];
    [self addSubview:pauseButn];
    self.pauseButn = pauseButn;
    [pauseButn addTarget:self action:@selector(pauseButnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    //语速控件
    UILabel *slowlyLab = [[UILabel alloc]initWithFrame:CGRectMake(15 + 26 + 10 , 68, 14, 14)];
    slowlyLab.font = [UIFont systemFontOfSize:11];
    slowlyLab.textColor = [UIColor whiteColor];
    slowlyLab.text = @"慢";
    [self addSubview:slowlyLab];
    
    UILabel *fastLab = [[UILabel alloc]initWithFrame:CGRectMake( WIDTH - 15 - 14, 68, 14, 14)];
    fastLab.font = [UIFont systemFontOfSize:11];
    fastLab.textColor = [UIColor whiteColor];
    fastLab.text = @"快";
    [self addSubview:fastLab];
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(51 + 14 + 10 , 60, WIDTH - 114, 30)];
    self.slider.minimumTrackTintColor = JFRGBColor(29, 173, 255);
    self.slider.maximumTrackTintColor = [UIColor whiteColor];
    [self addSubview:self.slider];
    
    self.numbers = @[@(0), @(1), @(2), @(3), @(4), @(5), @(6),@(7),@(8),@(9)];
    
    NSInteger numberOfSteps = ((float)[self.numbers count] - 1);
    
    self.slider.maximumValue = numberOfSteps;
    
    self.slider.minimumValue = 0;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"FLListenSliderValue"]){
        
        float useValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"FLListenSliderValue"] floatValue];
        
        self.slider.value = [[self.numbers objectAtIndex: useValue] floatValue ] ;
        
    }else{
        self.slider.value = [[self.numbers objectAtIndex:normalSliderIndex] floatValue];// 设置初始值
    }
    
    self.slider.continuous = YES;
    
    [self.slider addTarget:self action:@selector(speedSliderValueChanged:)
     
          forControlEvents:UIControlEventValueChanged];
    
    
    //定时控件
    int spaceLength = (WIDTH - 247)/4;
    NSArray *timerArr = [NSArray arrayWithObjects:@"无",@"2分",@"30分",@"60分",@"90分", nil];
    for (int i = 0; i < 5; i++) {
        UIButton *timerBtn = [[UIButton alloc] initWithFrame:CGRectMake(56 + i* 35 + i * spaceLength, 113, 35, 24)];
        timerBtn.backgroundColor = JFRGBColor(235, 235, 235);
        [timerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        timerBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        timerBtn.layer.cornerRadius = 12;
        [self addSubview:timerBtn];
        switch (i) {
            case 0:
                timerBtn.tag = 1200;
                break;
            case 1:
                timerBtn.tag = 2;
                break;
            case 2:
                timerBtn.tag = 30;
                break;
            case 3:
                timerBtn.tag = 60;
                break;
            case 4:
                timerBtn.tag = 90;
                break;
            default:
                break;
        }
        
        if ([JeffinSpeechModel sharedSpeechPlayerModel].SpeechTime == 0)
        {
            [JeffinSpeechModel sharedSpeechPlayerModel].SpeechTime  = normalTimerBtngtage;
        }
        
        if (timerBtn.tag == [JeffinSpeechModel sharedSpeechPlayerModel].SpeechTime) {
            
            timerBtn.backgroundColor = JFRGBColor(29, 173, 255);
            [timerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
        }
        [timerBtn setTitle:[timerArr objectAtIndex:i] forState:UIControlStateNormal];
        [timerBtn addTarget:self action:@selector(timerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    
    //发音控件
    NSArray *speakerArr = [NSArray arrayWithObjects:@"小鹿",@"小斐", nil];
    for (int i = 0; i < 2; i++) {
        UIButton *speakerBtn = [[UIButton alloc] initWithFrame:CGRectMake(56 + i* 35 + i * spaceLength, 163, 35, 24)];
        speakerBtn.tag = 4001 +i;
        [speakerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //        speakerBtn.backgroundColor = JFRGBColor(29, 173, 255);
        speakerBtn.backgroundColor = JFRGBColor(235, 235, 235);
        
        
        if([[NSUserDefaults standardUserDefaults] integerForKey:@"listenSpeaker"] != 0)
        {
            if (speakerBtn.tag == [[NSUserDefaults standardUserDefaults] integerForKey:@"listenSpeaker"])
            {
                speakerBtn.backgroundColor = JFRGBColor(29, 173, 255);
                
                [speakerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }else
        {
            if (speakerBtn.tag == normalSpeakerTag)
            {
                speakerBtn.backgroundColor = JFRGBColor(29, 173, 255);
                
                [speakerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            
        }
        
        speakerBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        speakerBtn.layer.cornerRadius = 12;
        [self addSubview:speakerBtn];
        [speakerBtn setTitle:[speakerArr objectAtIndex:i] forState:UIControlStateNormal];
        [speakerBtn addTarget:self action:@selector(speakerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    //开始听书控件
    UIButton *startBtn = [[UIButton alloc]initWithFrame:CGRectMake((WIDTH - 200)/3 , 210, 100, 30)];
    [self addSubview:startBtn];
    [startBtn setTitle:@"开始听书" forState:UIControlStateNormal];
    startBtn.backgroundColor =  JFRGBColor(236, 36, 64);
    startBtn.layer.cornerRadius = 15;
    [startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];

    [startBtn addTarget:self action:@selector(startBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    //退出听书控件
    UIButton *restoreBtn = [[UIButton alloc]initWithFrame:CGRectMake((WIDTH - 200)/3 *2 + 100, 210, 100, 30)];
    [self addSubview:restoreBtn];
    [restoreBtn setTitle:@"退出听书" forState:UIControlStateNormal];
    [restoreBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];

    restoreBtn.backgroundColor =  JFRGBColor(236, 36, 64);
    restoreBtn.layer.cornerRadius = 15;
    [restoreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [restoreBtn addTarget:self action:@selector(restoreBtnClick) forControlEvents:UIControlEventTouchUpInside];

}


//翻页方法
- (void)listenStateChangeBtnClick: (UIButton *)listenStateChangeBtn{
    
    if (![JeffinSpeechModel sharedSpeechPlayerModel].isWorking){
        return;
    }

    [self.pauseButn setImage:[UIImage imageNamed:@"page_playing"] forState:UIControlStateNormal];
    
    if (listenStateChangeBtn.tag == 5001) {
        
        
        if ([_delegate respondsToSelector:@selector(SpeechViewSpeechLast)]) {
            [_delegate SpeechViewSpeechLast];
        }

    }else{
       
        if ([_delegate respondsToSelector:@selector(SpeechViewSpeechNext)]) {
            [_delegate SpeechViewSpeechNext];
        }

        
    }
    
}


//暂停方法

- (void)pauseButnClick: (UIButton *)pauseBtn{
    
    if (![JeffinSpeechModel sharedSpeechPlayerModel].isWorking){
        return;
    }
    
    
    if ([JeffinSpeechModel sharedSpeechPlayerModel].isPaused) {
        [JeffinSpeechModel sharedSpeechPlayerModel].isPaused = NO;
        
    }else{
        
        [JeffinSpeechModel sharedSpeechPlayerModel].isPaused = YES;
        
    }
    
    [pauseBtn setImage:[UIImage imageNamed:[self.pauseBtnArr objectAtIndex:[JeffinSpeechModel sharedSpeechPlayerModel].isPaused]] forState:UIControlStateNormal];
    
    if ([_delegate respondsToSelector:@selector(SpeechViewPauseOrContinue)]) {
        [_delegate SpeechViewPauseOrContinue];
    }
    
}


//语速方法
- (void)speedSliderValueChanged: (UISlider *)sender {
    
    if (![JeffinSpeechModel sharedSpeechPlayerModel].isWorking){
        return;
    }
    
    [self.pauseButn setImage:[UIImage imageNamed:@"page_playing"] forState:UIControlStateNormal];
    
    
    NSUInteger index = (NSUInteger)(self.slider.value + 0.5);
    
    [self.slider setValue:index animated:NO];
    
    NSNumber *number = self.numbers[index];
    
    [JeffinSpeechModel sharedSpeechPlayerModel].speed = [number floatValue];

    
    if ([_delegate respondsToSelector:@selector(SpeechViewSpeedValueChanged)]) {
        [_delegate SpeechViewSpeedValueChanged];
    }
    
}



//定时方法
- (void)timerBtnClick:(UIButton *)btn{
    
    if (![JeffinSpeechModel sharedSpeechPlayerModel].isWorking){
        return;
    }
    
    btn.backgroundColor = JFRGBColor(29, 173, 255);
    
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    for (UIButton *timerBtn in self.subviews) {
        if ([timerBtn isKindOfClass:[UIButton class]]) {
            UIButton *AllBtn = (UIButton *)timerBtn;
            if ((AllBtn.tag >= 2) && (AllBtn.tag <= 1200)) {
                if (![btn isEqual:AllBtn]) {
                    
                    AllBtn.backgroundColor = JFRGBColor(235, 235, 235);
                    [AllBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    
                }
            }
        }
    }
    
    [self speechtimerBtnClick:btn];
    
   // [_delegate speechtimerBtnClick:btn];
    
}


//定时处理
- (void)speechtimerBtnClick: (UIButton *)timerBtn{
    
    [self.timer invalidate];
        
    self.timeDown = (int)timerBtn.tag * 60;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
    
    
}

-(void)handleTimer{
    
    if(self.timeDown < 0){
        
        [self.timer invalidate];
        
        if ([_delegate respondsToSelector:@selector(SpeechViewSpeechTime)]) {
            [_delegate SpeechViewSpeechTime];
        }
    }
    
    self.timeDown = self.timeDown - 1;
}



//发音人方法
- (void)speakerBtnClick: (UIButton *)btn{
   
    if (![JeffinSpeechModel sharedSpeechPlayerModel].isWorking){
        return;
    }
    
    [self.pauseButn setImage:[UIImage imageNamed:@"page_playing"] forState:UIControlStateNormal];
    
    btn.backgroundColor = JFRGBColor(29, 173, 255);
    
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    for (UIButton *timerBtn in self.subviews) {
        
        if ([timerBtn isKindOfClass:[UIButton class]]) {
            
            UIButton *AllBtn = (UIButton *)timerBtn;
            
            if ((AllBtn.tag > 4000) && (AllBtn.tag < 4003)) {
                
                if (![btn isEqual:AllBtn]) {
                    
                    [AllBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    
                    AllBtn.backgroundColor = JFRGBColor(235, 235, 235);
                }
            }
        }
    }

    if (btn.tag ==4001 ) {
        [JeffinSpeechModel sharedSpeechPlayerModel].speaker = girlOne;

    }else{
        [JeffinSpeechModel sharedSpeechPlayerModel].speaker = girlTwo;

    }
    
    if ([_delegate respondsToSelector:@selector(SpeechViewSpeechSpeaker)]) {
        [_delegate SpeechViewSpeechSpeaker];
    }
    
}

//开始
- (void)startBtnClick{
    
    if ([JeffinSpeechModel sharedSpeechPlayerModel].isWorking){
        return;
    }

    if ([_delegate respondsToSelector:@selector(SpeechViewSpeechStart)]) {
        [_delegate SpeechViewSpeechStart];
    }
    
}

//结束
- (void)restoreBtnClick{
    
    if (![JeffinSpeechModel sharedSpeechPlayerModel].isWorking){
        return;
    }

    if ([_delegate respondsToSelector:@selector(SpeechViewSpeechStop)]) {
        [_delegate SpeechViewSpeechStop];
    }
    
}



@end
