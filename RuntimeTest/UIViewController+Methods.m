//
//  UIViewController+Methods.m
//  RuntimeTest
//
//  Created by mac on 2018/1/26.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "UIViewController+Methods.h"
#import <objc/runtime.h>
@interface UIViewController ()


@end

@implementation UIViewController (Methods)

- (void)setTest1:(NSString *)test1{
    /*
     关联方法：
     objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy);
     
     参数：
     * id object 给哪个对象的属性赋值
     const void *key 属性对应的key
     id value  设置属性值为value
     objc_AssociationPolicy policy  使用的策略，是一个枚举值，和copy，retain，assign是一样的，手机开发一般都选择NONATOMIC
     */
    
   objc_setAssociatedObject(self, @selector(test1), test1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//获取关联对象
- (NSString *)test1{
   return objc_getAssociatedObject(self, _cmd);
    
}


@end
