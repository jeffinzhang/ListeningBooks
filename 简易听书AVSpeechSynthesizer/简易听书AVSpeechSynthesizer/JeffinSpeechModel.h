//
//  JeffinSpeechModel.h
//  简易听书AVSpeechSynthesizer
//
//  Created by 张建飞 on 2017/8/10.
//  Copyright © 2017年 JeffinZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    girlOne = 1,
    girlTwo = 2,
}Speaker;

@interface JeffinSpeechModel : NSObject

@property (nonatomic , strong) NSString *authorName;
@property (nonatomic , strong) NSString *novelName;
@property (nonatomic , strong) NSString *coverName;


@property (nonatomic,copy) NSString *SpeechWords;
@property (nonatomic,assign) CGFloat speed;
@property (nonatomic,assign) Speaker speaker;
@property (nonatomic , assign) NSInteger SpeechTime;//听书时间

@property (nonatomic , assign) BOOL isPaused;//暂停播放tag值
@property (nonatomic, assign) BOOL isWorking;//听书正在执行(暂停也是执行中)


//锁屏信息
+(instancetype)sharedSpeechPlayerModel;


@end
