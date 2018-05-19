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

//写一个c语言的函数
void TestMetaClassM(id self,SEL _cmd){
    NSLog(@"当前类对象地址%p",self);
    NSLog(@"当前类名%@，父类名%@",[self class],[self superclass]);
    
    //当前类
    Class currentClass = [self class];
    const char *a = object_getClassName(currentClass);
    for (int i = 0 ; i<4; i++) {
        NSLog(@"Following the isa pointer %d times gives %p---%s", i, currentClass,a);
        currentClass = object_getClass(currentClass);
        a = object_getClassName(currentClass);
    }
    
    NSLog(@"NSObject类地址%p",[NSObject class]);
    NSLog(@"元类地址%p",object_getClass([NSObject class]));
    
    
}

//1.测试元类
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
    class_addMethod(newclass, @selector(testMetaClass), (IMP)TestMetaClassM, "v@:");
    
    //注册类
    objc_registerClassPair(newclass);
    
    //初始化实例-调用函数
    id instance = [[newclass alloc]initWithDomain:@"do something" code:0 userInfo:nil];
    [instance performSelector:@selector(testMetaClass)];
}

//测试：swizzling
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //确保交换方法只执行一次
        SEL originalSEL = @selector(viewWillAppear:);
        SEL swizzlingSEL = @selector(zww_viewWillAppear:);
        
        Method originalMethod = class_getInstanceMethod(self, originalSEL);
        Method swizzlingMethod = class_getInstanceMethod(self, swizzlingSEL);
        
        BOOL success = class_addMethod(self, originalSEL, method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));
        if (success) {//之前原始方法的实现不存在：因为此时originalSEL的实现已经被替换为swizzlingSEL的实现，所以这里再拿回来就可以了
            class_replaceMethod(self, swizzlingSEL, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            //交换函数指针
            method_exchangeImplementations(originalMethod, swizzlingMethod);
        }
        
       
    });
}

- (void)zww_viewWillAppear:(BOOL)animated{
    NSLog(@"要替换的方法");
}



@end
