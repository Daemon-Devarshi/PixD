//
//  NSString+DKStringExtension.m
//  PixD
//
//  Created by Devarshi Kulshreshtha on 18/06/12.
//  Copyright (c) 2012 DaemonConstruction. All rights reserved.
//

#import "NSString+DKStringExtension.h"

@implementation NSString (DKStringExtension)

//TODO: implementing below methods using blocks :-)
- (NSString *)substringBetweenFirstString:(NSString *)firstString andSecondString:(NSString *)secondString
{
	NSString *stringToReturn;
	@try {
		//finding location of firstString
		NSRange range = [self rangeOfString:firstString];
		NSUInteger firstStringLocation = range.location;
		
		//finding location of secondString from the substring
		NSString *substring = [self substringFromIndex:firstStringLocation + 1];
		range = [substring rangeOfString:secondString];
		NSUInteger secondStringLocation = range.location;
		
		stringToReturn =  [self substringWithRange:NSMakeRange(firstStringLocation + 1, secondStringLocation)];
	}
	@catch (NSException * e) {
		stringToReturn = @"";
	}
	@finally {
		return stringToReturn;
	}
	
}

@end
