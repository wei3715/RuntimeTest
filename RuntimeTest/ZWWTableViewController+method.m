//
//  ZWWTableViewController+method.m
//  MediaTest
//
//  Created by mac on 2018/5/19.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWTableViewController+method.h"
#import <objc/runtime.h>
@interface ZWWTableViewController ()

@end
@implementation ZWWTableViewController (method)
//写一个c语言的函数
void TestMetaClassM(id self,SEL _cmd){
    NSLog(@"当前类对象地址%p",self);
    NSLog(@"当前类名%@，父类名%@",[self class],[self superclass]);
    
    //当前类
    Class currentClass = [self class];
    const char *a = object_getClassName(currentClass);
    for (int i = 0 ; i<4; i++) {
        NSLog(@"current class isa pointer %d, %p---%s", i, currentClass,a);
        //得到当前类的isa指针
        currentClass = object_getClass(currentClass);
        a = object_getClassName(currentClass);
    }
    
    NSLog(@"NSObject类地址%p",[NSObject class]);
    NSLog(@"NSObject元类地址%p",object_getClass([NSObject class]));
    
    
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
    //4.types:函数类型 v:void,@带代表对象id,:代表SEL 去搜索关键字 “iOS types encode”  http://nshipster.com/type-encodings/
    class_addMethod(newclass, @selector(testMetaClass), (IMP)TestMetaClassM, "v@:");
    
    //注册类
    objc_registerClassPair(newclass);
    
    //初始化实例-调用函数
    id instance = [[newclass alloc]initWithDomain:@"do something" code:0 userInfo:nil];
    [instance performSelector:@selector(testMetaClass)];
}

//测试：swizzling（hook）
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //用单例确保交换方法只执行一次
        SEL originalSEL = @selector(viewWillAppear:);
        SEL swizzlingSEL = @selector(zww_viewWillAppear:);
        
        Method originalMethod = class_getInstanceMethod(self, originalSEL);
        Method swizzlingMethod = class_getInstanceMethod(self, swizzlingSEL);
        
        IMP originalIMP = method_getImplementation(originalMethod);
        IMP swizzlingIMP = method_getImplementation(swizzlingMethod);
        
//        周全起见，有两种情况要考虑一下。
//        第一种情况是要复写的方法(overridden)并没有在目标类中实现(notimplemented)，而是在其父类中实现了。
//        第二种情况是这个方法已经存在于目标类中(does existin the class itself)。这两种情况要区别对待。 (译注: 这个地方有点要明确一下，它的目的是为了使用一个重写的方法替换掉原来的方法。但重写的方法可能是在父类中重写的，也可能是在子类中重写的。) 对于第一种情况，应当先在目标类增加一个新的实现方法(override)，然后将复写的方法替换为原先(的实现(original one)。 对于第二情况(在目标类重写的方法)。这时可以通过method_exchangeImplementations来完成交换."
//    viewWillAppear:被替换方法zww_viewWillAppear:替换方法
//    class_addMethod:如果发现方法已经存在，会失败返回，也可以用来做检查用,我们这里是为了避免源方法没有实现的情况;如果方法没有存在,我们则先尝试添加被替换的方法的实现
//    1.如果返回成功:则说明被替换方法没有存在.也就是被替换的方法没有被实现,我们需要先把这个方法实现,然后再执行我们想要的效果,用我们自定义的方法去替换被替换的方法. 这里使用到的是class_replaceMethod这个方法. class_replaceMethod本身会尝试调用class_addMethod和method_setImplementation，所以直接调用class_replaceMethod就可以了)
        
        //动态添加方法：更严谨的做法，防止原始方法没有或没有具体实现；这里success值=NO，因为原本系统中有viewWillAppear方法
        BOOL success = class_addMethod(self, originalSEL, swizzlingIMP, method_getTypeEncoding(swizzlingMethod));
        if (success) {//添加成功表明之前原始方法没有实现，因为此时originalSEL的实现已经被替换为swizzlingSEL的实现，所以这里再拿回来就可以了
            class_replaceMethod(self, swizzlingSEL, originalIMP, method_getTypeEncoding(originalMethod));
        } else {
            //交换函数指针:一般情况，要替换的原始方法viewWillAppear存在，并且有实现
            method_exchangeImplementations(originalMethod, swizzlingMethod);
        }
    });
}

- (void)zww_viewWillAppear:(BOOL)animated{
    NSLog(@"利用runtime swizzling黑魔法实现交换系统方法  %s %@",__FUNCTION__,[self class]);
}

//动态添加一个了类
- (void)createClassUseRuntime{
    // 创建一个类(size_t extraBytes该参数通常指定为0, 该参数是分配给类和元类对象尾部的索引ivars的字节数。)
    Class clazz = objc_allocateClassPair([NSObject class], "GoodPerson", 0);
    // 添加ivar
    // @encode(aType) : 返回该类型的C字符串
    class_addIvar(clazz, "_name", sizeof(NSString *), log2(sizeof(NSString *)), @encode(NSString *));
    class_addIvar(clazz, "_age", sizeof(NSUInteger), log2(sizeof(NSUInteger)), @encode(NSUInteger));
    //注册该类
    objc_registerClassPair(clazz);
    
    //创建实例对象
    id object = [[clazz alloc]init];
    
    //设置ivar
    [object setValue:@"zww" forKey:@"name"];

    Ivar ageIvar = class_getInstanceVariable(clazz, "_age");
    object_setIvar(object, ageIvar, @18);
    
    //打印对象的类和内存地址
    ZWWLog(@"%@",object);
    
    //打印对象的属性值
    ZWWLog(@"name = %@,age = %@",[object valueForKey:@"name"],object_getIvar(object, ageIvar));
    
    //当类或者它的子类的实例还存在，则不能调用objc_disposeClassPair方法
    object = nil;
    
    //销毁类
    objc_disposeClassPair(clazz);
    
    
//    这样, 我们就在程序运行时动态添加了一个继承自NSObject的GoodPerson类, 并为该类添加了name和age成员变量.
    
}


@end
