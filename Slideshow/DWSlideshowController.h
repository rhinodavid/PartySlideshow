//
//  DWSlideshowController.h
//  PartySlideshow
//
//  Created by David Walsh on 3/20/14.
//  Copyright (c) 2014 David Walsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWSlideshowSource.h"
#import "DWPSSConnectionManager.h"

@interface DWSlideshowController : NSObject <NSWindowDelegate, DWSlideshowSourceDelegate, DWPSSConnectionManagerDelegate>

@property (strong, nonatomic) DWSlideshowSource *slideshowSource;
@property NSColor *backgroundColor;
@property (strong, nonatomic) DWPSSConnectionManager *connectionManager;


-(void)play;
-(void)updateTimeInterval:(double)newTimeInterval;
-(void)stop;

@end
