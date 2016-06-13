//
//  AdvertisementHelper.h
//  AdvertisementDemo
//
//  Created by lixiaohu on 16/6/14.
//  Copyright © 2016年 lixiaohu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface STAdvertisementHelper : NSObject
+ (instancetype)st_shareInstance;

+ (void)configureAdWithLaunchImageAnimation:(BOOL)animation;

+ (UIView *)configureLaunchImageAnimation;
@end
