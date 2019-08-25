//
//  AudioRecorder.h
//  ScreenRecDemo
//
//  Created by Modi on 2019/8/23.
//  Copyright © 2019年 modi. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "CallBackInterface.h" //一个通用的CallBack声明头

@interface AudioRecorder : NSObject
    
    @property(nonatomic, copy) CallBackTwo callBack;
    
    @property(nonatomic, copy) CallBackOne canSendCallBack;
    
    @property(nonatomic, assign) NSInteger volume;
    
    @property(readonly, assign) BOOL isRecording;
    
- (BOOL)startRecord:(NSString *)storeFile;
    
- (void)cancelRecord;
    
- (void)endRecord;
    
- (void)resetEnvironment;
    
    @end
