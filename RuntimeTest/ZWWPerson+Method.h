//
//  ZWWPerson+Method.h
//  RuntimeTest
//
//  Created by mac on 2018/5/18.
//  Copyright © 2018年 mac. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ZWWPerson.h"

@interface ZWWPerson (Method)

//会出现在类的Property列表中，但不会出现在Ivar列表中
@property (nonatomic, assign) CGFloat weight;

@end
