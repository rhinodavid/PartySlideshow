//
//  DWSlideshowController.m
//  PartySlideshow
//
//  Created by David Walsh on 3/20/14.
//  Copyright (c) 2014 David Walsh. All rights reserved.
//

#import "DWSlideshowController.h"
#import "DWPhotoWindowController.h"
#import <Quartz/Quartz.h>

@implementation DWSlideshowController
{
    @private
    DWPhotoWindowController *controllerWindow;
    NSTimer                 *slideshowTimer;

}

-(id) init {
    self = [super init];
    // do special stuff

    return self;
}

-(void) awakeFromNib {
    NSLog(@"awake");

}

-(IBAction)play:(id)sender {
    //show window
    if (!controllerWindow) {
        controllerWindow = [[DWPhotoWindowController alloc] initWithWindowNibName:@"DWSlideWindow"];
    }
    [controllerWindow showWindow:self];
    //make a timer at the correct interval
    [self showNextImage:nil];
    slideshowTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(showNextImage:) userInfo:nil repeats:YES];
    [slideshowTimer setTolerance:0.5];

}

-(void)stop {
    [slideshowTimer invalidate];
    [controllerWindow close];
}

-(void)showNextImage:(NSTimer*)timer {
    NSString *nextPath = [[_slideshowSource nextPhoto] path];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:nextPath];
    [controllerWindow updateImage:image];
}

@end
