//
//  Utils.m
//  Mensajeria
//
//  Created by Developer on 23/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+(NSDictionary *)URLQueryParameters:(NSURL *)URL
{
    NSString *queryString = [URL query];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *parameters = [queryString componentsSeparatedByString:@"&"];
    for (NSString *parameter in parameters)
    {
        NSArray *parts = [parameter componentsSeparatedByString:@"="];
        if ([parts count] > 1)
        {
            NSString *key = [parts[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *value = [parts[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            result[key] = value;
        }
    }
    return result;
}

@end
