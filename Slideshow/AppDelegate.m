//
//  AppDelegate.m
//  Slideshow
//
//  Created by David Walsh on 3/17/14.
//  Copyright (c) 2014 David Walsh. All rights reserved.
//

#import "AppDelegate.h"
#import "DWSlideshowSource.h"
#import "DWPhoto.h"
#include <CoreServices/CoreServices.h>


void myCallbackFunction (ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents,
                                 void *eventPaths,
                                 const FSEventStreamEventFlags eventFlags[],
                                 const FSEventStreamEventId eventIds[]) {
    //DWSlideshowSource * slideshowSource = CFBridgingRelease(clientCallBackInfo);
    DWSlideshowSource * slideshowSource = (__bridge DWSlideshowSource *)(clientCallBackInfo);
    [slideshowSource syncPhotos];
}

@implementation AppDelegate
{
    DWSlideshowSource *slideshowSource;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application

}


- (IBAction)playSlideshow:(id)sender
{

}


- (IBAction)showPathOpenPanel:(id)sender
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    [openPanel setResolvesAliases:YES];
    NSString *panelTitle = NSLocalizedString(@"Choose a directory of photos", @"Title for the open panel");
    [openPanel setTitle:panelTitle];
    
    NSString *promptString = NSLocalizedString(@"Choose", @"Prompt for the open panel");
    [openPanel setPrompt:promptString];
    
    AppDelegate * __weak weakSelf = self;

    [openPanel beginSheetModalForWindow:[self controlWindow] completionHandler: ^(NSInteger result) {
        //hide the open panel
        [openPanel orderOut: self];
        
        //If the code wasn't ok, don't do anything
        if (result != NSOKButton) {
            return;
        }
        
        //Get the first URL returned from the open panel and set it at the first path component of the control.
        NSURL *url  = [[openPanel URLs] objectAtIndex:0];
        [weakSelf.pathControl setURL:url];
        [self updateSlideshowSourceWithURL:url];
    }];
}

- (void) updateSlideshowSourceWithURL:(NSURL*)url {
    slideshowSource = [[DWSlideshowSource alloc] initWithBaseURL:url];
    [_slideshowController setSlideshowSource:slideshowSource];
    [self establishListenerForURL:url];
}

- (void) establishListenerForURL:(NSURL*)url {
    
    CFStringRef mypath = (CFStringRef)CFBridgingRetain(url.path);
    CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
    void *slideshowSourcePointer = (__bridge void *)slideshowSource;
    FSEventStreamContext context = {0, slideshowSourcePointer, NULL, NULL, NULL};
    //void *callbackInfo = (void *)CFBridgingRetain(slideshowSource);
    //void * callbackInfo = NULL;
    //void * callbackInfo = (__bridge void *)(myString);
    FSEventStreamRef stream;
    CFAbsoluteTime latency = 3.0;
    stream = FSEventStreamCreate(NULL,
                                 &myCallbackFunction,
                                 &context,
                                 pathsToWatch,
                                 kFSEventStreamEventIdSinceNow,
                                 latency,
                                 kFSEventStreamCreateFlagFileEvents); //could FlagNone?
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(stream);
    CFRunLoopRun();
}


-(void)keyDown:(NSEvent *)theEvent {
    if ([theEvent keyCode] == 0x35 ) {
        [NSApp terminate:nil];
    }
}

@end
