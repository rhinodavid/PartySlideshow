//
//  DWPhotoWindowController.h
//  PartySlideshow
//
//  Created by David Walsh on 3/31/14.
//  Copyright (c) 2014 David Walsh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface DWPhotoWindowController : NSWindowController

-(void)updateImage: (NSImage*) newImage;

@end

typedef enum {
    k
} TransitionStyle;