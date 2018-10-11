//
//  NSObject+ZJExtension.h
//  Cache
//
//  Created by LD on 2018/5/28.
//  Copyright © 2018年 LD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ZJExtension)
/*
 * 本ZJExtension只适用于OC的类，对swift不行
 */
/**传入json字典返回model*/
+(id)objectWithJson:(NSDictionary *)json;
/** 传入装有json字典的数组，返回model数字*/
+ (NSArray *)objectArrayWithJsonArray:(NSArray *)jsonArray;

/** 将自定义的对象转换成字典对象，属性名为键，属性值为值*/
- (NSDictionary *)dictionaryRepresentation;
/** 将自定义对象转换成json字符串*/
- (NSString *)jsonStringRepresentation;

/** model里数组内存放的model*/
-(NSDictionary *)objectClassInArray;
/** model里存放的model类型*/
-(NSDictionary *)objectClassInobject;
@end
