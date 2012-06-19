//
//  DKAppDelegate.m
//  PixD
//
//  Created by Devarshi Kulshreshtha on 18/06/12.
//  Copyright (c) 2012 DaemonConstruction. All rights reserved.
//

#import "DKAppDelegate.h"
#import "DKParser.h"

@interface DKAppDelegate ()
/*
 The method is invoked when result from parsing is obtained
 */
- (void)resultObtained:(NSNotification *)notification;

/*
 A dispatch source timer - property
 */
@property (readwrite, assign) dispatch_source_t timer;

/*
 Currrent desktop wallpaper url - property
 */
@property (readwrite, retain) NSURL *currentDesktopWallpaperURL;

/*
 Current desktop wallpaper path - property
 */
@property (readwrite, retain) NSString *currentDesktopWallpaperPath;

@end

@implementation DKAppDelegate
{
    DKParser *_parser;
}

@synthesize window = _window;
@synthesize timer = _timer;
@synthesize currentDesktopWallpaperURL = _currentDesktopWallpaperURL;
@synthesize currentDesktopWallpaperPath = _currentDesktopWallpaperPath;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    // Insert code here to initialize your application
    
    //TODO: below code is obtaining time from standardUserDefaults so that later preferences pan can be added to it
    //FIXME: below code is commented because it is not used, to be used later
    /*
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"timeInterval"]) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:10] forKey:@"timeInterval"];
	}
    */
    
    // initialization of parser and its properties
    _parser = [[DKParser alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resultObtained:) name:@"ImageLinksParsed" object:_parser];
	[_parser setIdentificationTag:@"description"];
    
    //TODO: implementing it with private concurrent queue
	dispatch_async(dispatch_get_global_queue(0, 0), 
				   ^{
                       [_parser parseXMLURL:[NSURL URLWithString:@"http://pixdaus.com/pixdaus/items/rss/main/"]];  
				   });
}

- (void)resultObtained:(NSNotification *)notification
{
    NSArray *resultsArrayObtained = [[notification object] resultArray];
    
    // data is not obtained so return
    if (!resultsArrayObtained) {
        return;
    }
    
    // Picking random image in dispatch timer and setting it as desktop image
    
    // initializing dispatch timer
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
	if (!self.timer) return;
    
    // FIXME: Right now 10 is hardcoded but should be taken from standardUserDefaults
    // [[[NSUserDefaults standardUserDefaults] objectForKey:@"timeInterval"] intValue]
    dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), 10 * NSEC_PER_SEC, 5 * NSEC_PER_SEC);
    
    // creting folder where image will be saved
	NSString *imageFolder = [@"~/Library/Application Support/PixD" stringByExpandingTildeInPath];
	NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:imageFolder]) {
		[fileManager createDirectoryAtPath:imageFolder withIntermediateDirectories:YES attributes:nil error:nil];
	}
    
    __block NSInteger imageIndex = 0;
    // changing image in dispatch event handler
    dispatch_source_set_event_handler(self.timer, ^{
        
        ++ imageIndex;
        
        if (imageIndex == [resultsArrayObtained count]) {
            imageIndex = 0;
        }
        
        // De-comment below line and comment above line to change wallpaper randomly
        // NSInteger imageIndex = arc4random() % [resultsArrayObtained count];
		
		NSString *stringURL = [resultsArrayObtained objectAtIndex:imageIndex];
		
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:stringURL]];
		
		NSString *imagePath = [NSString stringWithFormat:@"%@/%@",imageFolder,[stringURL lastPathComponent]];
        
        [imageData writeToFile:imagePath  atomically:YES];
		
		NSError *error = nil;
		
		if ([self.currentDesktopWallpaperURL isEqual:[[NSWorkspace sharedWorkspace] desktopImageURLForScreen:[NSScreen mainScreen]]]) {
			[fileManager removeItemAtPath:self.currentDesktopWallpaperPath error:&error];
		}
		
		NSURL *imagePathURL = [NSURL fileURLWithPath:imagePath];
		[[NSWorkspace sharedWorkspace] setDesktopImageURL:imagePathURL
												forScreen:[NSScreen mainScreen] 
												  options:nil 
													error:&error];
		//FIXME: store below in standardUserDefaults
        // and delete file after obtaining path from it
        // so that it does not populate PixD folder
		self.currentDesktopWallpaperPath = imagePath;
		self.currentDesktopWallpaperURL  = imagePathURL;
		
	});
    
    // invoking dispatch timer
    dispatch_resume(self.timer);
}
@end
