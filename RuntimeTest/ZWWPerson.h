//
//  ZWWPerson.h
//  RuntimeTest
//
//  Created by mac on 2018/5/17.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZWWPersonDelegate <NSObject>
- (void)eat;
@end

@interface ZWWPerson : NSObject{
    @public
   NSInteger height;
}

@property (nonatomic, copy)     NSString    *name;
@property (nonatomic, assign)   NSInteger   age;
@property (nonatomic, weak)id   <ZWWPersonDelegate>  delegate;
//- (void)method1;
- (void)method2WithParam:(NSDictionary *)dic;
+ (void)method3;

/**
 *  判断类中是否有该属性
 *
 *  @param property 属性名称
 *
 *  @return 判断结果
 */
-(BOOL)hasProperty:(NSString *)property;

//测试利用运行时动态交换方法实现
+(void)run;
+(void)study;
@end


