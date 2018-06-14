//
//  UtilsMacros.h
//  MediaTest
//
//  Created by mac on 2018/5/23.
//  Copyright © 2018年 mac. All rights reserved.
//

#ifndef UtilsMacros_h
#define UtilsMacros_h

#ifdef DEBUG
#define ZWWLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define ZWWLog(...)
#endif

#define kWeakSelf(type)     __weak typeof(type) weak##type = type;
#define KScreenWidth        [[UIScreen mainScreen] bounds].size.width
#define KScreenHeight       [[UIScreen mainScreen] bounds].size.height
#define KLocalMP4Url        @"http://cloud.video.taobao.com/play/u/2712925557/p/1/e/6/t/1/40050769.mp4"
#define KFileHandlePath     @"/Users/mac/Desktop/ddd.mp4"

//阿帕奇配置的本地服务器
#define KLocalUploadServer        @"http://192.168.1.113/post/upload.php"

//14. 歌手简介，tinguid为歌手id
#define KTestRequestBaseUrl @"http://tingapi.ting.baidu.com/v1/restserver/ting"


//归档宏
#define encodeRuntime(ClassName)\
\
unsigned int count = 0;\
Ivar *ivarList = class_copyIvarList([ClassName class], &count);\
for (int i = 0; i<count; i++) { \
\
    const char *ivarName = ivar_getName(ivarList[i]);\
    NSString *strIvarName = [NSString stringWithUTF8String:ivarName];\
    id value = [self valueForKey:strIvarName];\
    [encoder encodeObject:value forKey:strIvarName];\
\
}\
free(ivarList);

//解档宏

#define initWithRuntime(ClassName) \
\
if (self = [super init]) {\
unsigned int count = 0;\
Ivar *ivarList = class_copyIvarList([ZWWPerson class], &count);\
for (int i = 0; i<count; i++) {\
    Ivar ivar = ivarList[i];\
    const char *ivarName = ivar_getName(ivar);\
    NSString *strIvarName = [NSString stringWithUTF8String:ivarName];\
    id value = [decoder decodeObjectForKey:strIvarName];\
    [self setValue:value forKey:strIvarName];\
}\
free(ivarList);\
\
}\
return self;

#endif /* UtilsMacros_h */
