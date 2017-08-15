# ListeningBooks
简易听书AVSpeechSynthesizer 耳机控制 锁屏界面 耳机插拔  打断处理 后台播放
http://www.jianshu.com/p/c78722b1566a
![mainView](https://github.com/jeffinzhang/ListeningBooks/blob/master/简易听书AVSpeechSynthesizer/IMG_23380.PNG)

##界面样式
![听书界面](http://upload-images.jianshu.io/upload_images/1857051-c64e629c2ef1319b.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
##简易听书的demo主要包含一下几部分内容
![主要功能](http://upload-images.jianshu.io/upload_images/1857051-60dfbd6d17e2e1b3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#####开始
- (void)speakUtterance:(AVSpeechUtterance *)utterance;
#####停止
- (BOOL)stopSpeakingAtBoundary:(AVSpeechBoundary)boundary;
#####暂停
- (BOOL)pauseSpeakingAtBoundary:(AVSpeechBoundary)boundary;
#####继续
- (BOOL)continueSpeaking;
#####语速
@property(nonatomic) float rate;
#####音色
@property(nonatomic) float pitchMultiplier;
#####音量
@property(nonatomic) float volume; 

代码
```
/**
 *  开始
 */
- (void)speechStart2{
   
    //要合成的文字内容
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:[JeffinSpeechModel sharedSpeechPlayerModel].SpeechWords];
   
    //合成的语言(有好多种语言,需要自己选择)
    AVSpeechSynthesisVoice *voiceType = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    
    utterance.voice = voiceType;
    
    utterance.rate  = 0.50;//语速
    
    utterance.pitchMultiplier = 1;//音色
    
    [self.synthesizer speakUtterance:utterance];//开始
}


/**
 *  停止
 */
- (void)speechStop{
    
    [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
   
}

/**
 *  暂停/继续
 */
- (void)speechPauseOrContinue{
    
    if (self.synthesizer.isPaused == YES) {
        
        [self.synthesizer continueSpeaking];
      
    }else{
        
        [self.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
      
    }
}
```

#####锁屏信息

![锁屏信息](http://upload-images.jianshu.io/upload_images/1857051-32f5adab36bb693b.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


先设置开始后台播放功能
![后台播放设置](http://upload-images.jianshu.io/upload_images/1857051-bd0d74a542d4f387.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

开启后台,代码实现
```
    //开启后台
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    //接受远程控制
    [self becomeFirstResponder];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
```

锁屏界面,代码实现
```
- (void)speechScreenInfo{
    
    UIImage *image = [UIImage  imageNamed: [JeffinSpeechModel sharedSpeechPlayerModel].coverName];//
    
    NSString *novelName = [JeffinSpeechModel sharedSpeechPlayerModel].novelName;
    
    NSString *authorName = [JeffinSpeechModel sharedSpeechPlayerModel].authorName;
    
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:image];
    
    NSDictionary *dic = @{MPMediaItemPropertyTitle:novelName,
                          MPMediaItemPropertyArtist:authorName,
                          MPMediaItemPropertyArtwork:artWork
                          };
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dic];
    
}
```

远程控制,代码实现

```
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
```

耳机控制也在上面代码里,  耳机插拔事件处理代码
```
  //耳机监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];


//耳机监听事件处理
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

```
打断事件监听处理
```
//通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:nil];


//事件处理
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
```
[demo在此](https://github.com/jeffinzhang/ListeningBooks)
