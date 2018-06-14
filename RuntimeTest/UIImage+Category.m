//
//  UIImage+Category.m
//  RuntimeTest
//
//  Created by mac on 2018/6/12.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "UIImage+Category.h"
#import <objc/runtime.h>
@implementation UIImage (Category)

//定义一个自定义的方法
+(UIImage *)zww_imageNamed:(NSString *)name{
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if (version >= 7.0) {
        //如果系统版本是7.0以上，使用另外一套文件名结尾是‘_os7’的扁平化图片
        name = [name stringByAppendingString:@"_os7"];
        ZWWLog(@"执行分类交换后的自定义方法");
    }
    return [UIImage zww_imageNamed:name];
}

//分类中重写UIImage的load方法（只要能让其执行一次的方法交换语句，load再合适不过了）
+ (void)load{
    //获取两个类的方法
    Method m1 = class_getClassMethod([UIImage class], @selector(imageNamed:));
    Method m2 = class_getClassMethod([UIImage class], @selector(zww_imageNamed:));
    //开始交换方法实现
    method_exchangeImplementations(m1, m2);
}
@end
