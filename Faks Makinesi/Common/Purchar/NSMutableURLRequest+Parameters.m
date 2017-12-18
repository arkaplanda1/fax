//
//  NSMutableURLRequest+Parameters.m
//  GetFollowers
//
//  Created by Антон Буков on 16.09.15.
//  Copyright © 2015 Codeless Solutions. All rights reserved.
//

#import "NSMutableURLRequest+Parameters.h"

static NSString *Boundary = @"-----------------------------------0xCoCoaouTHeBouNDaRy";

@implementation NSMutableURLRequest (Parameters)

- (BOOL)isMultipart
{
    return [[self valueForHTTPHeaderField:@"Content-Type"] hasPrefix:@"multipart/form-data"];
}

- (NSString *)encodedParameters
{
    if (self.isMultipart)
        return nil;
    
    if ([[self HTTPMethod] isEqualToString:@"GET"] ||
        [[self HTTPMethod] isEqualToString:@"DELETE"])
        return self.URL.query;

    return [[NSString alloc] initWithData:self.HTTPBody encoding:NSASCIIStringEncoding];
    
}

- (NSDictionary *)parameters
{
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionary];
    for (NSString *encodedPair in [[self encodedParameters] componentsSeparatedByString:@"&"])
    {
        NSArray *encodedPairElements = [encodedPair componentsSeparatedByString:@"="];
        NSString *key = [encodedPairElements.firstObject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *value = [encodedPairElements.lastObject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        requestParameters[key] = value;
    }
    
    return requestParameters;
}

- (void)setParameters:(NSDictionary *)parameters
{
    NSMutableArray *pairs = [[NSMutableArray alloc] initWithCapacity:parameters.count];
    for (NSString *requestParameter in parameters) {
        NSString *key = [requestParameter stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
        NSString *value = [parameters[requestParameter] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
        [pairs addObject:[@[key,value] componentsJoinedByString:@"="]];
    }
    
    NSString *encodedParameterPairs = [pairs componentsJoinedByString:@"&"];
    
    if ([[self HTTPMethod] isEqualToString:@"GET"] ||
        [[self HTTPMethod] isEqualToString:@"DELETE"])
    {
        [self setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [self.URL.absoluteString componentsSeparatedByString:@"?"].firstObject, encodedParameterPairs]]];
    } else {
        // POST, PUT
        [self setHTTPBodyWithString:encodedParameterPairs];
        [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
}

- (void)setHTTPBodyWithString:(NSString *)body
{
    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    [self setValue:[NSString stringWithFormat:@"%@", @(bodyData.length)] forHTTPHeaderField:@"Content-Length"];
    self.HTTPBody = bodyData;
}

- (void)attachFileWithName:(NSString *)name filename:(NSString*)filename contentType:(NSString *)contentType data:(NSData*)data {
    
    NSDictionary *parameters = self.parameters;
    [self setValue:[@"multipart/form-data; boundary=" stringByAppendingString:Boundary] forHTTPHeaderField:@"Content-type"];
    
    NSMutableData *bodyData = [NSMutableData new];
    for (NSString *parameter in parameters) {
        NSString *param = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n",
                           Boundary, parameter, parameters[parameter]];
        [bodyData appendData:[param dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSString *filePrefix = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n", Boundary, name, filename, contentType];
    [bodyData appendData:[filePrefix dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:data];
    [bodyData appendData:[[[@"\r\n--" stringByAppendingString:Boundary] stringByAppendingString:@"--"] dataUsingEncoding:NSUTF8StringEncoding]];
    [self setValue:[NSString stringWithFormat:@"%@", @(bodyData.length)] forHTTPHeaderField:@"Content-Length"];
    self.HTTPBody = bodyData;
}

@end
