//
//  AdervitisementView.h
//  AdvertisementDemo
//
//  Created by lixiaohu on 16/6/14.
//  Copyright © 2016年 lixiaohu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STAdervitisementView : UIView
/** 显示广告页面方法*/
- (void)showUnderView:(UIView *)view;

/** 图片路径*/
@property (nonatomic, copy) NSString *filePath;
@end
