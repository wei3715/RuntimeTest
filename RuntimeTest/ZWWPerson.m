//
//  ZWWPerson.m
//  RuntimeTest
//
//  Created by mac on 2018/5/17.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWPerson.h"
#import <objc/runtime.h>
#import "ZWWPersonForward.h"
@interface ZWWPerson()<ZWWPersonDelegate>

@property (nonatomic, strong)NSArray *arr;
- (NSArray *)method4;

@end

@implementation ZWWPerson

- (void)method1{
    NSLog(@"测试方法%s",__func__);
}

/*********************************************消息转发机制start************************************************/

//- (void)method2WithParam:(NSDictionary *)dic{
//    NSLog(@"方法正常实现方式==%s",__func__);
//}

#pragma mark 1.动态解析转发方法
//方法转发机制1：动态解析转发方法:方法未实现时先执行 1.动态解析，2.备用接受者转发 3.完全消息转发
//将原本要调用的方法的实现，改为了一个新的实现。class_addMethod 方法的第二个参数是要重写的方法，这里用的就是传进来的参数sel，第三个参数就是重写后的实现。第四个参数是方法的类型。
//调用不存在的类方法时触发，默认返回NO，可以加上自己的处理后返回YES
+(BOOL)resolveInstanceMethod:(SEL)sel{
    if (sel == @selector(method2WithParam:)) {
          //通过添加一个c语言的函数来转发方法的实现
          class_addMethod([self class], sel, (IMP)runAddMethod, "v@:");
          //通过block来转发方法的实现
//        class_addMethod([self class], sel, imp_implementationWithBlock(^(id self,NSDictionary *dic){
//            NSLog(@"未实现的方法通过动态解析转发为一个block实现函数%@",dic);
//        }), "v@:");
        
    }
    return YES;
}

// 要动态添加的IMP，这是一个C方法
void runAddMethod(id self, SEL _cmd, NSDictionary *dic) {
     NSLog(@"未实现的方法通过动态解析转发为一个c语言的函数%s.%@",__func__,dic);
}


#pragma mark 2.备用接受者（ZWWPersonForward）转发方法
//2.这个方法返回你需要转发消息的对象
-(id)forwardingTargetForSelector:(SEL)aSelector{
    if (aSelector == @selector(method2WithParam:)) {
        ZWWPersonForward *fastForword = [[ZWWPersonForward alloc]init];
        return fastForword;
    }
    return nil;
}

#pragma mark 3.完全消息转发
//3.用来生成方法签名，这个签名就是给forwardInvocation中的参数NSInvocation调用的
-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    if (aSelector == @selector(method2WithParam:)) {
        //生成新的方法签名
        NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:"v@:"];
        return methodSignature;
    }
    //正常情况old为nil
    NSMethodSignature *old = [super methodSignatureForSelector:aSelector];
    return old;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    ZWWPersonForward *forwad = [[ZWWPersonForward alloc]init];
    if ([forwad respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:forwad];
    }
}
/*********************************************消息转发机制end************************************************/

+ (void)method3{
    
}

//测试利用Runtime修改属性值
- (NSArray *)method4{
    _arr = [[NSArray alloc]initWithObjects:@"1",@"2", nil];
    return _arr;
}

//解档
- (id)initWithCoder:(NSCoder *)decoder{
//    if (self = [super init]) {
//        unsigned int count = 0;
//        Ivar *ivarList = class_copyIvarList([ZWWPerson class], &count);
//        //获取类中所有成员变量
//        for (int i = 0; i<count; i++) {
//            Ivar ivar = ivarList[i];
//            const char *ivarName = ivar_getName(ivar);
//            NSString *strIvarName = [NSString stringWithUTF8String:ivarName];
//            //进行解档取值
//            id value = [decoder decodeObjectForKey:strIvarName];
//            //利用KVC对属性赋值
//            [self setValue:value forKey:strIvarName];
//        }
//        free(ivarList);
//
//    }
//    return self;
    initWithRuntime(ZWWPerson);
}

//归档
- (void)encodeWithCoder:(NSCoder *)encoder{
//    unsigned int count = 0;
//    Ivar *ivarList = class_copyIvarList([ZWWPerson class], &count);
//    for (int i = 0; i<count; i++) {
//
//        const char *ivarName = ivar_getName(ivarList[i]);
//        NSString *strIvarName = [NSString stringWithUTF8String:ivarName];
//        //利用KVC取值
//        id value = [self valueForKey:strIvarName];
//        [encoder encodeObject:value forKey:strIvarName];
//
//    }
//    free(ivarList);
      encodeRuntime(ZWWPerson) ;
}

//在NSObject的分类中增加方法判断来避免使用KVC赋值的时候出现崩溃
-(BOOL)hasProperty:(NSString *)property{
    BOOL flag = false;
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList([self class], &count);
    for (int i = 0; i<count; i++) {
        const char *ivarName = ivar_getName(ivarList[i]);
        NSString *strIvarName = [NSString stringWithUTF8String:ivarName];
        if ([strIvarName isEqualToString:property]) {
            flag = true;
        }
    }
    return flag;
}

+(void)run{
    ZWWLog(@"跑步");
    
}
+(void)study{
    ZWWLog(@"学习");
    
}
@end
