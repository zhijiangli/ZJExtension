//
//  NSObject+ZJExtension.m
//  Cache
//
//  Created by LD on 2018/5/28.
//  Copyright © 2018年 LD. All rights reserved.
//

#import "NSObject+ZJExtension.h"
#import <objc/runtime.h>
@implementation NSObject (ZJExtension)
/** model里数组内存放的model*/
-(NSDictionary *)objectClassInArray{
    return [NSDictionary dictionary];
}
/** model里存放的model*/
-(NSDictionary *)objectClassInobject{
    return [NSDictionary dictionary];
}

/**传入json字典返回model*/
+(id)objectWithJson:(NSDictionary *)json{
    id obj = [[self alloc] init];
    if(obj && [json isKindOfClass:[NSDictionary class]]){
        // 遍历所有属性 采用KVO赋值
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList([self class], &count);
        for(int i=0;i<count;i++){
            objc_property_t property = properties[i];
            NSString *key = [[NSString alloc]initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            if([[json objectForKey:key] isKindOfClass:[NSArray class]]){ // 是否为数组
                obj = [self objectWithArray:[json objectForKey:key] Key:key Obj:obj];
            }else if([[json objectForKey:key] isKindOfClass:[NSDictionary class]]){
                obj = [self objectWithDic:[json objectForKey:key] Key:key Obj:obj];
            }else if([[json objectForKey:key] isKindOfClass:[NSNumber class]]){
                NSString * string = [NSString stringWithFormat:@"%@",[json objectForKey:key]];
                [obj setValue:string forKey:key];
            }else{
                if([json objectForKey:key] == nil){ // 无法判断类型所以不能赋值
                    //[obj setValue:@"" forKey:key];会导致崩溃
                }else{
                    [obj setValue:[json objectForKey:key] forKey:key];
                }
            }
        }
        free(properties);
    }
    return obj;
}
/** 传入装有json字典的数组，返回model数字*/
+ (NSArray *)objectArrayWithJsonArray:(NSArray *)jsonArray {
    NSMutableArray *objects = [NSMutableArray array];
    for (NSDictionary *dict in jsonArray) {
        id instance = [self objectWithJson:dict];
        [objects addObject:instance];
    }
    return objects;
}
/** 将自定义的对象转换成字典对象，属性名为键，属性值为值*/
- (NSDictionary *)dictionaryRepresentation{
    NSMutableDictionary * param = [NSMutableDictionary new];
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for(int i=0;i<count;i++){
        objc_property_t property = properties[i];
        NSString * name = @(property_getName(property));
        id value ;
        if([[self valueForKey:name] isKindOfClass:[NSArray class]]){ // 数组
            value = [NSMutableArray new];
            for(id obj in [self valueForKey:name]){
                [value addObject:[obj dictionaryRepresentation]];
            }
        }else if([[self valueForKey:name] isKindOfClass:[self class]]){ // 对象
           value = [[self valueForKey:name] dictionaryRepresentation];
        }else if([[self valueForKey:name] isKindOfClass:[NSNumber class]]){// NSNumber对象
            value = [NSString stringWithFormat:@"%@",[self valueForKey:name]];
        }else{
            value = [self valueForKey:name]?:@"";
        }
        [param setObject:value forKey:name];
    }
    free(properties);
    return param;
}
/** 将自定义对象转换成json字符串*/
- (NSString *)jsonStringRepresentation{
    NSMutableDictionary *representation = [[self dictionaryRepresentation] mutableCopy];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:representation options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"Error occured when create json string representation, error: %@", error.localizedDescription);
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

#pragma mark -
+(id)objectWithArray:(NSArray *) objs Key:(NSString *)key Obj:(id)obj{
    if(objs.count<1){
        [obj setValue:[NSMutableArray new] forKey:key];
        return obj;
    }
    NSMutableArray * tempArray = [NSMutableArray new];
    NSDictionary * names = [obj objectClassInArray]; // 取出所有对应的对象
    for(NSString * nameKey in names){ //
        if([nameKey isEqual:key]){
            Class class = NSClassFromString([names objectForKey:nameKey]);
            //if(obj isKindOfClass:[class class]]){}
            //if([names[nameKey] isKindOfClass:[class class]]){
                for(int j=0;j<objs.count;j++){
                    NSDictionary * subJson = objs[j];
                    [tempArray addObject:[class objectWithJson:subJson]];
                }
            //}
        }
    }
    [obj setValue:tempArray forKey:key];
    return  obj;
}
+(id)objectWithDic:(NSDictionary *) tempDic Key:(NSString *)key Obj:(id)obj{
    NSDictionary * names = [obj objectClassInobject]; // 取出所有对应的对象
    for(NSString * nameKey in names){
        if([nameKey isEqual:key]){
            Class class = NSClassFromString([names objectForKey:nameKey]);
            //if([obj isKindOfClass:[class class]]){
                [obj setValue:[class objectWithJson:tempDic] forKey:key];
            //}
        }
    }
    return obj;
}
#pragma mark -
/** NSLog 输出model。 不能用po输出*/
//- (NSString *)description
//{
//    NSString * resString = @"\n";
//    NSMutableDictionary * param = [NSMutableDictionary new];
//    unsigned int count;
//    objc_property_t *properties = class_copyPropertyList([self class], &count);
//    for(int i=0;i<count;i++){
//        objc_property_t property = properties[i];
//        NSString * name = @(property_getName(property));
//        NSString * value = [self valueForKey:name]?:@"";
//        [param setObject:value forKey:name];
//        resString = [NSString stringWithFormat:@"%@%@ : %@,\n",resString,name,value];
//    }
//    free(properties);
//    //return [NSString stringWithFormat:@"<%@:%p> -- %@",[self class],self,param];
//    return [NSString stringWithFormat:@"<%@:%p> -- %@",[self class],self,resString];
//}
@end
