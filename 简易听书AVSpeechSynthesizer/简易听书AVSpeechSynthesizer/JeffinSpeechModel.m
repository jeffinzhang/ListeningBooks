//
//  JeffinSpeechModel.m
//  简易听书AVSpeechSynthesizer
//
//  Created by 张建飞 on 2017/8/10.
//  Copyright © 2017年 JeffinZhang. All rights reserved.
//

#import "JeffinSpeechModel.h"

@implementation JeffinSpeechModel

+ (instancetype)sharedSpeechPlayerModel {

    static id speechModel;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        speechModel = [[self alloc] init];
    });
    
    return speechModel;
}


@end
