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

//写一个c语言的函数
void TestMetaClassM(id self,SEL _cmd){
    NSLog(@"当前类对象地址%p",self);
    NSLog(@"当前类名%@，父类名%@",[self class],[self superclass]);
    
    //当前类
    Class currentClass = [self class];
    for (int i = 0 ; i<4; i++) {
        NSLog(@"当前类的序号%d 地址%p",i,currentClass);
        currentClass = object_getClass(currentClass);
    }
    
    NSLog(@"NSObject类地址%p",[NSObject class]);
    NSLog(@"元类地址%p",object_getClass([NSObject class]));
    
    
}

- (void)testMetaClass{
    //创建类
    //1.superclass :父类
    //2.name：本类的名字
    //3.extraBytes:本类所占字节数
    
    Class newclass = objc_allocateClassPair([NSError class],"TestMetaClass", 0);
    
    //给类添加类方法
    //1.cls：类名
    //2.SEL: 方法名
    //3.IMP: 函数指针
    //4.types:函数类型 v:void,@带代表对象id,:代表SEL
    class_addMethod(newclass, @selector(TestMetaClassM), (IMP)TestMetaClassM, "v@:");
    
    //注册类
    objc_registerClassPair(newclass);
    
    //初始化实例-调用函数
    id instance = [[newclass alloc]initWithDomain:@"do something" code:0 userInfo:nil];
    [instance performSelector:@selector(TestMetaClassM)];
}

@end
