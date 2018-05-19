//
//  ZWWPerson+Method.m
//  RuntimeTest
//
//  Created by mac on 2018/5/18.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWPerson+Method.h"
#import <objc/runtime.h>
@implementation ZWWPerson (Method)

//测试为Category动态添加属性
- (void)setWeight:(CGFloat)weight{
    /*
     关联方法：
     objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy);
     
     参数：
     * id object 给哪个对象的属性赋值
     const void *key 属性对应的key
     id value  设置属性值为value
     objc_AssociationPolicy policy  使用的策略，是一个枚举值，和copy，retain，assign是一样的，手机开发一般都选择NONATOMIC
     */
    objc_setAssociatedObject(self, @selector(weight), @(weight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//获取关联对象
- (CGFloat)weight{
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

@end
