//
//  AdvertisementHelper.m
//  AdvertisementDemo
//
//  Created by lixiaohu on 16/6/14.
//  Copyright © 2016年 lixiaohu. All rights reserved.
//

#import "STAdvertisementHelper.h"
#import "AppDelegate.h"
#import "STAdervitisementView.h"

#define KUserDefaults [NSUserDefaults standardUserDefaults]
static NSString *const adImageName = @"STADImageName";
static NSString *const adDetailUrl = @"STADDetailUrl";

@implementation STAdvertisementHelper
+ (instancetype)st_shareInstance{
   static STAdvertisementHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[STAdvertisementHelper alloc] init];
    });
    
    return helper;
}

+ (void)configureAdWithLaunchImageAnimation:(BOOL)animation{
    UIView *lauchImageView = nil;
    if (animation) {
        lauchImageView = [STAdvertisementHelper configureLaunchImageAnimation];
    }
    // 1.判断沙盒中是否存在广告图片，如果存在，直接显示
    NSString *filePath = [[STAdvertisementHelper st_shareInstance] getFilePathWithImageName:[KUserDefaults valueForKey:adImageName]];
    
    BOOL isExist = [[STAdvertisementHelper st_shareInstance] isFileExistWithFilePath:filePath];
    
    if (isExist) {// 图片存在
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        STAdervitisementView *advertiseView = [[STAdervitisementView alloc] initWithFrame:appDelegate.window.bounds];
        advertiseView.filePath = filePath;
        [advertiseView showUnderView:lauchImageView];
        
    }
    
    // 2.无论沙盒中是否存在广告图片，都需要重新调用广告接口，判断广告是否更新
    [[STAdvertisementHelper st_shareInstance] getAdvertisingImage];

}
+ (UIView *)configureLaunchImageAnimation{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CGSize viewSize = appDelegate.window.bounds.size;
    NSString *viewOrientation = @"Portrait";    //横屏请设置成 @"Landscape"
    NSString *launchImage = nil;
    
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImage = dict[@"UILaunchImageName"];
        }
    }
    
    UIImageView *launchView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:launchImage]];
    launchView.frame = appDelegate.window.bounds;
    launchView.contentMode = UIViewContentModeScaleAspectFill;
    [appDelegate.window addSubview:launchView];
    
    [UIView animateWithDuration:0.8f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         launchView.alpha = 0.0f;
                         launchView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.2, 1.2, 1);
                         
                     }
                     completion:^(BOOL finished) {
                         
                         [launchView removeFromSuperview];
                         
                     }];
    
    return launchView;

}

#pragma mark - Private medthod

/**
 *  根据图片名拼接文件路径
 */
- (NSString *)getFilePathWithImageName:(NSString *)imageName
{
    if (imageName) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
        
        return filePath;
    }
    
    return nil;
}

/**
 *  判断文件是否存在
 */
- (BOOL)isFileExistWithFilePath:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = FALSE;
    return [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
}

/**
 *  初始化广告页面
 */
- (void)getAdvertisingImage
{
    
    NSArray *imageArray = @[@"http://img5.duitang.com/uploads/blog/201407/11/20140711171118_FxyTW.jpeg"];
    NSString *imageUrl = imageArray[arc4random() % imageArray.count];
    
    // 获取图片名:43-130P5122Z60-50.jpg
    NSArray *stringArr = [imageUrl componentsSeparatedByString:@"/"];
    NSString *imageName = stringArr.lastObject;
    
    // 拼接沙盒路径
    NSString *filePath = [self getFilePathWithImageName:imageName];
    BOOL isExist = [self isFileExistWithFilePath:filePath];
    if (!isExist){// 如果该图片不存在，则删除老图片，下载新图片
        
        [self downloadAdImageWithUrl:imageUrl imageName:imageName];
        
    }
    
}

/**
 *  下载新图片
 */
- (void)downloadAdImageWithUrl:(NSString *)imageUrl imageName:(NSString *)imageName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        UIImage *image = [UIImage imageWithData:data];
        
        NSString *filePath = [self getFilePathWithImageName:imageName]; // 保存文件的名称
        
        if ([UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES]) {// 保存成功
            NSLog(@"保存成功");
            [self deleteOldImage];
            [KUserDefaults setValue:imageName forKey:adImageName];
            [KUserDefaults synchronize];
            // 如果有广告链接，将广告链接也保存下来
        }else{
            NSLog(@"保存失败");
            [self deleteOldImage];
        }
        
    });
}

/**
 *  删除旧图片
 */
- (void)deleteOldImage
{
    NSString *imageName = [KUserDefaults valueForKey:adImageName];
    if (imageName) {
        NSString *filePath = [self getFilePathWithImageName:imageName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:nil];
    }
}
@end
