//
//  DKParser.m
//  PixD
//
//  Created by Devarshi Kulshreshtha on 18/06/12.
//  Copyright (c) 2012 DaemonConstruction. All rights reserved.
//

#import "DKParser.h"
#import "NSString+DKStringExtension.h"


@interface DKParser ()
/* 
 Parser instance
 */
@property (readwrite, retain) NSXMLParser *urlParser;

/*
 String found between identification tag
 */
@property (readwrite, retain) NSMutableString *foundCharacters;

/*
 Mutable array to hold parsed data
 */
@property (readwrite, retain) NSMutableArray *tempArray;

@end


@implementation DKParser

@synthesize identificationTag = _identificationTag;
@synthesize urlParser = _urlParser;
@synthesize foundCharacters = _foundCharacters;
@synthesize tempArray = _tempArray;
@synthesize resultArray = _resultArray;

- (id)init
{
    if (self = [super init]) {
        _foundCharacters = [[NSMutableString alloc] initWithCapacity:2];
		_tempArray = [[NSMutableArray alloc] initWithCapacity:2];
    }
    
    return self;
}
- (void)parseXMLURL:(NSURL *)xmlURL
{
    _urlParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
	[_urlParser setDelegate:self];
	
	[_urlParser parse];
}

#pragma mark NSXMLParser delegate methods implementation

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	NSLog(@"ErrorOccurred: %@",parseError);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:self.identificationTag]) {
		
		[self.foundCharacters setString:@""];
	}
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	[self.foundCharacters appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
	if ([elementName isEqualToString:self.identificationTag]) {
		
		NSString *identifiedString = [self.foundCharacters substringBetweenFirstString:@"\"" andSecondString:@"\""];
		
		if (![identifiedString isEqualToString:@""]) {
			[self.tempArray addObject:identifiedString];
		}
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	//FIXME: KVO is not working :-(
	[self setResultArray:self.tempArray];
	
	// using notification center
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ImageLinksParsed" object:self];
	
}
@end
