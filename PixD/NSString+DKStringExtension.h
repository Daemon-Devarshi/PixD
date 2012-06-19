//
//  NSString+DKStringExtension.h
//  PixD
//
//  Created by Devarshi Kulshreshtha on 18/06/12.
//  Copyright (c) 2012 DaemonConstruction. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DKStringExtension)

/* 
 Returns string between two strings
 */
- (NSString *)substringBetweenFirstString:(NSString *)firstString andSecondString:(NSString *)secondString;

@end
