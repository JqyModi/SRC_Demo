//
//  AudioRecorder.m
//  ScreenRecDemo
//
//  Created by Modi on 2019/8/23.
//  Copyright © 2019年 modi. All rights reserved.
//

#import "AudioRecorder.h"

#import <ReactiveCocoa.h>
#import <AVFoundation/AVFoundation.h>

#import "UALogger.h"
#import "PermissionUtils.h" //一些手机权限调用类，包括这次的micro权限请求
#import "HWWeakTimer.h" //这个就不说了搜一下
#import "NSFileManager+Message.h" //录音文件管理


@interface AudioRecorder () <AVAudioRecorderDelegate>
    
    @property(nonatomic, strong) NSString *storeFile;
    @property(nonatomic, strong) AVAudioRecorder *recorder;
    
    @property(nonatomic, strong) NSTimer *timer;
    @property(nonatomic, assign) NSTimeInterval time; ///<  记录当前录音时间
    
    
    @end


@implementation AudioRecorder
    
- (void)dealloc {
    [self endRecord];
}
    
- (BOOL)startRecord:(NSString *)storeFile {
    self.storeFile = storeFile;
    __block BOOL checkAuth = NO;
    __block BOOL success = NO;
    @weakify(self);
    //录音权限打开
    [PermissionUtils openMic:^(BOOL auth) {
        @strongify(self);
        if (auth) {
            [self setActive];
            success = [self.recorder prepareToRecord];
            [self.recorder record];
            [self timer];
        }
        checkAuth = YES;
    }];
    //可以看看这种方式处理线程等待，这儿想起了一个故事，就略了
    while (!checkAuth) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.05]];
    }
    return success;
}
    
- (void)setActive {
    @try {
        NSError *error;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];
        if (error) {
            UALog(@"[AudioRecorder][ERROR][StartRecord] %@", error);
        }
        error = nil;
        
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        if (error) {
            UALog(@"[AudioRecorder][ERROR][CallBack] %@", error);
        }
        
    } @catch (NSException *e) {
        
    }
}
    
- (void)cancelRecord {
    self.callBack = NULL;
    [self endRecord];
    _recorder.delegate = nil; // cancel 时快速释放，避免引用造成的AVAudioSession Deactive失败
    [self resetEnvironment];
}
    
- (void)endRecord {
    self.canSendCallBack = NULL;
    [self invalidateTimer];
    if (_recorder) {
        [self.recorder stop];
        [self deactivedAudioSession];
        _recorder = nil;
    }
}
    
- (void)deactivedAudioSession {
    NSError *error = nil;
    if (![[AVAudioSession sharedInstance] setActive:NO error:&error]) {
        NSLog(@"%@: AVAudioSession.setDeActive failed: %@\n", NSStringFromClass(self.class), error ? [error localizedDescription] : @"nil");
    }
}
    
- (void)resetEnvironment {
    //check doc path
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:self.storeFile]) {
        NSError *error;
        //        [fm removeItemAtPath:self.storeFile error:&error];
        if (error) {
            UALog(@"[AudioRecorder][FM]ERROR %@", error);
        }
    }
    self.time = 0.0f;
}
    
    
#pragma mark - AVAudioRecorderDelegate
    
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (self.callBack) {
        self.callBack(@(flag), nil);
    }
}
    
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *__nullable)error {
    if (self.callBack) {
        self.callBack(@(NO), error);
    }
}
    
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder {
    
}
    
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags {
    
}
    
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withFlags:(NSUInteger)flags {
    
}
    
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder {
    
}
    
    
#pragma mark - getter
    
- (AVAudioRecorder *)recorder {
    if (!_recorder) {
        //录音设置
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
        [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
        //录音通道数  1 或 2
        [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        //线性采样位数  8、16、24、32
        [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        //录音的质量
        [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
        
        NSError *err;
        [self resetEnvironment];
        _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.storeFile] settings:recordSetting error:&err];
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
        if (err) {
            UALog(@"[AudioRecorder][Error] %@", err);
        }
    }
    return _recorder;
}
    
- (NSString *)storeFile {
    if (!_storeFile) {
        _storeFile = [[NSFileManager defaultManager] temRecordAudioFile];
    }
    return _storeFile;
}
    
- (BOOL)isRecording {
    return self.recorder.isRecording;
}
    
- (NSTimer *)timer {
    if (!_timer) {
        @weakify(self);
        _timer = [HWWeakTimer scheduledTimerWithTimeInterval:.05 block:^(id userInfo) {
            @strongify(self);
            self.time += .05;
            [self log];
            if (self.canSendCallBack) {
                self.canSendCallBack(@(self.time));
            }
            if (self.time >= 30.0f) {
                [self endRecord];
            }
        }                                           userInfo:nil repeats:YES];
    }
    return _timer;
}
    
- (void)log {
    [_recorder updateMeters];
    self.volume = (NSInteger) (pow(10, 0.05 * [_recorder peakPowerForChannel:0]) * 100);
}
    
- (void)invalidateTimer {
    if (!_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}
    
    @end
