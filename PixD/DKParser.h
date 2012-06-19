//
//  DKParser.h
//  PixD
//
//  Created by Devarshi Kulshreshtha on 18/06/12.
//  Copyright (c) 2012 DaemonConstruction. All rights reserved.

/*  
 This class performs event driven parsing.
 */

#import <Foundation/Foundation.h>

@interface DKParser : NSObject <NSXMLParserDelegate> 

/*
 Result array will be prepared based on this identification tag
 */
@property (readwrite, retain) NSString *identificationTag;

/*
 Result values are returned in this array
 */
@property (readwrite, retain) NSArray *resultArray;

/*
 Method inoked to start parsing
 */
- (void)parseXMLURL:(NSURL *)xmlURL;
@end
