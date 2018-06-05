//
//  ZWWTableViewController.m
//  MediaTest
//
//  Created by mac on 2018/5/19.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWTableViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "ZWWTableViewController+method.h"
#import "ZWWPerson.h"
#import "ZWWPerson+Method.h"
@interface ZWWTableViewController ()<NSCoding>

@property (nonatomic, strong) NSArray  *titleArr;


@end

@implementation ZWWTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _titleArr = @[@"测试元类",@"Runtime打印类信息",@"Runtime实际利用：归档/解档",@"消息转发机制"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"baseCell"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_titleArr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"baseCell" forIndexPath:indexPath];
    cell.textLabel.text = _titleArr[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:{//测试元类
            [self testMetaClass];
            break;
        }
        case 1:{//Runtime打印类信息
            [self printClassInfo];
            break;
        }
        case 2:{//Runtime实际利用：归档/解档
            [self archiverAction];
            break;
        }
        case 3:{//消息转发
            [self msgSendAction];
            break;
        }
        default:
            break;
    }
}

//1.利用runtime打印运行时信息
- (void)printClassInfo {
    unsigned int count = 0;// 用于记录列表内的数量，进行循环输出
    
    ZWWPerson *person = [[ZWWPerson alloc]init];
    
    //关联对象成功，可以通过点语法访问属性weight、
    person.weight = 45.0;
    
    Class cls = [person class];
    
    //打印ZWWPerson信息
    const char *clsName = class_getName(cls);
    NSLog(@"person 对象的类名==%s",clsName);
    //打印父类名
    Class fatherClass = class_getSuperclass(cls);
    NSLog(@"person 类对象的父类名==%s",class_getName(fatherClass) );
    
    //cls,fatherClass 都不是元类
    if (class_isMetaClass(cls)) {
        NSLog(@"%s是元类",class_getName(cls));
    }
    NSLog(@"%s不是元类",class_getName(cls));
    
    //cls,fatherClass 都不是元类
    if (class_isMetaClass(objc_getClass(clsName))) {
        NSLog(@"%s是元类",class_getName(objc_getClass(clsName)));
    }
    NSLog(@"%s不是元类",class_getName(objc_getClass(clsName)));
    
    
    [self printPropertyName:cls clsName:class_getName(cls) count:count];
    
    //获取指定属性名称(可获取.m中属性)
    objc_property_t property = class_getProperty(cls, "arr");
    if (property != NULL) {
        const char *propertyName = property_getName(property);
        NSString *arrString = [NSString stringWithUTF8String:propertyName];
        [person setValue:@[@"7",@"9",@"0"] forKey:arrString];
        NSLog(@"kvo 获取arr==%@", [person valueForKey:arrString]);
    }
    
    [self printIvarName:cls clsName:clsName count:count];
    [self printMethodName:cls clsName:clsName count:count];
    //获取类方法+method3
    [self printMethodName:object_getClass(cls) clsName:object_getClassName(object_getClass(cls)) count:count];
    [self printProtocolName:cls clsName:clsName count:count];
}

//2.runtime的实际用处（获取成员变量的实际用处）：归档,解档：
- (void)archiverAction {
    ZWWPerson *person = [[ZWWPerson alloc]init];
    
    person.name = @"zww";
    person ->height = 168;
    person.age = 18;
    
    //归档
    BOOL success =  [NSKeyedArchiver archiveRootObject:person toFile:@"/Users/mac/Desktop/data"];
    if (success) {
        NSLog(@"归档成功");
    }else{
        NSLog(@"归档失败");
    }
    
    //解档
    person = [NSKeyedUnarchiver unarchiveObjectWithFile:@"/Users/mac/Desktop/data"];
    NSLog(@"解档后的变量 name==%@, age==%zd,height==%zd",person.name,person.age,person -> height);
    
}

//获取属性列表
- (void)printPropertyName:(Class)cls clsName:(const char *)clsaName count:(unsigned int)count{
    objc_property_t *propertyList = class_copyPropertyList(cls, &count);
    for (int i = 0; i<count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        NSLog(@"%s property --> %s", clsaName,propertyName);
        //这里可以通过Runtime 拿到原本获取不到的.m文件中的属性
    }
    //释放
    free(propertyList);
}

//获取成员变量列表
- (void)printIvarName:(Class)cls clsName:(const char *)clsaName count:(unsigned int)count{
    Ivar *personIvarList = class_copyIvarList(cls, &count);
    for (int i = 0; i<count; i++) {
        const char *ivarName = ivar_getName(personIvarList[i]);
        NSLog(@"%s ivar == %s",clsaName,ivarName);
    }
}

//获取方法列表
- (void)printMethodName:(Class)cls clsName:(const char *)clsaName count:(unsigned int)count{
    Method *methodList = class_copyMethodList(cls, &count);
    for (int i = 0; i<count; i++) {
        Method method = methodList[i];
        NSString *methodName = NSStringFromSelector(method_getName(method));
        NSLog(@"%s method == %@",clsaName,methodName);
    }
    free(methodList);
}

// 获取协议列表
- (void)printProtocolName:(Class)cls clsName:(const char *)clsaName count:(unsigned int)count{
    
    Protocol * __unsafe_unretained _Nonnull *protocalList = class_copyProtocolList(cls, &count);
    for (int i = 0; i<count; i++) {
        Protocol *protocal = protocalList[i];
        const char *protocolName = protocol_getName(protocal);
        //        NSLog(@"%s protocal == %s",clsaName,protocolName);
        NSLog(@"%s protocal == %@",clsaName, [NSString stringWithUTF8String:protocolName]);
    }
    free(protocalList);
    
}


//消息转发机制
- (void)msgSendAction{
    ZWWPerson *person = [[ZWWPerson alloc]init];
    
    //显式调用方法：只能调用.h文件中暴露出来的方法.
    //    [person method1];
    //隐式调用:可以调用.m中的方法。显式调用方法默认也会转化为隐式调用
    [person performSelector:@selector(method1)];
    
    //c语言消息发送：底层都会转为这种调用方法形式
    //arg1:接受者
    //arg2:SEL
    //注意：这里调用时会提示报错：需要 bulidSetting->Enable strict Checking of objc_msgSend Calls 改为NO
    objc_msgSend(person,@selector(method1));
    
    //消息转发，方法未实现不再会crash
    [person method2WithParam:@{@"result":@"success"}];
    
    
}


@end
