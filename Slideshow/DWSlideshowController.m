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

    if (!controllerWindow) {
        controllerWindow = [[DWPhotoWindowController alloc] initWithWindowNibName:@"DWSlideWindow"];
        [controllerWindow showWindow:self];
    }
    NSString *nextPath = [[_slideshowSource nextPhoto] path];
    NSLog(nextPath);
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:nextPath];
    [controllerWindow updateImage:image];
    

}



@end
