//
//  ViewController.m
//  RuntimeTest
//
//  Created by mac on 2018/1/26.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "UIViewController+Methods.h"
#import "TestMetaClassViewController.h"
@interface ViewController ()

@property (nonatomic, copy) NSString  *test11;
@property (nonatomic, copy) NSString  *test22;
@property (nonatomic, strong) UIButton *logBtn;

- (void)notHas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
     [self testMethod1];
     [self logInfo];
    
    //测试拦截未实现的方法，动态添加方法
    self.logBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 100, 20)];
    [self.logBtn setTitle:@"测 试" forState:UIControlStateNormal];
    [self.logBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    // 添加没有实现的点击事件
    [self.logBtn addTarget:self action:@selector(notHas) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.logBtn];
    
    // 关联对象
    static char associatedObjectKey;
    objc_setAssociatedObject(self, &associatedObjectKey, @"我就是要关联的字符串对象内容", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString *theString = objc_getAssociatedObject(self, &associatedObjectKey);
    NSLog(@"关联对象：%@", theString);
}
- (IBAction)testMetaClass:(id)sender {
    
    [self testMetaClass];
}

//测试category 添加属性
- (void)testMethod1{
    self.test1 = @"测试关联对象";
    NSLog(@"关联对象==%@",self.test1);
}

- (void)testMethod2{
    
}

//打印运行时类信息
- (void)logInfo {
    unsigned int count;// 用于记录列表内的数量，进行循环输出
    
    // 获取属性列表
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (unsigned int i = 0; i < count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        NSLog(@"property --> %@", [NSString stringWithUTF8String:propertyName]);
    }
    
    // 获取方法列表
    Method *methodList = class_copyMethodList([self class], &count);
    for (unsigned int i; i < count; i++) {
        Method method = methodList[i];
        NSLog(@"method --> %@", NSStringFromSelector(method_getName(method)));
    }
    
    // 获取成员变量列表
    Ivar *ivarList = class_copyIvarList([self class], &count);
    for (unsigned int i; i < count; i++) {
        Ivar myIvar = ivarList[i];
        const char *ivarName = ivar_getName(myIvar);
        NSLog(@"Ivar --> %@", [NSString stringWithUTF8String:ivarName]);
    }
    
    // 获取协议列表
    __unsafe_unretained Protocol **protocolList = class_copyProtocolList([self class], &count);
    for (unsigned int i; i < count; i++) {
        Protocol *myProtocal = protocolList[i];
        const char *protocolName = protocol_getName(myProtocal);
        NSLog(@"protocol --> %@", [NSString stringWithUTF8String:protocolName]);
    }
}

//点击按钮后不会崩溃，而是转到了对 runAddMethod 方法的调用。
//其实更明确地说，应该是重现了对要调用的方法的实现，将原本要调用的方法的实现，改为了一个新的实现。class_addMethod 方法的第二个参数是要重写的方法，这里用的就是传进来的参数sel，第三个参数就是重写后的实现。第四个参数是方法的签名。
// 调用不存在的类方法时触发，默认返回NO，可以加上自己的处理后返回YES
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSLog(@"notFind!");
    // 给本类动态添加一个方法
    if ([NSStringFromSelector(sel) isEqualToString:@"notHas"]) {
        class_addMethod(self, sel, (IMP)runAddMethod, "");
    }
    // 注意要返回YES
    return YES;
}

// 要动态添加的方法，这是一个C方法
void runAddMethod(id self, SEL _cmd, NSString *string) {
    NSLog(@"动态添加一个方法来提示");
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
