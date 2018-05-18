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
@end


