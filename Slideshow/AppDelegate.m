//
//  AppDelegate.m
//  Slideshow
//
//  Created by David Walsh on 3/17/14.
//  Copyright (c) 2014 David Walsh. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    _fileList = [NSMutableArray new];
    AppDelegate * __weak weakSelf = self;
    NSOpenGLContext *context = [[weakSelf glView] openGLContext];
    NSOpenGLPixelFormat *format = [[weakSelf glView] pixelFormat];
    _renderer = [[QCRenderer alloc] initWithOpenGLContext:context pixelFormat:format file:nil];

}


- (IBAction)playSlideshow:(id)sender
{

    NSImage *newImage = [[NSImage alloc] initWithContentsOfFile:[self returnFullImagePath:[_fileList firstObject]]];
    [[self topPhoto] setObjectValue: newImage];
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
    }];
}

- (NSString*)returnFullImagePath:(NSString*)fileName
{
    AppDelegate * __weak weakSelf = self;
    NSString *basePath = [[weakSelf.pathControl URL] path];
    return [[basePath stringByAppendingString:@"/"] stringByAppendingString:fileName];
}

@end
