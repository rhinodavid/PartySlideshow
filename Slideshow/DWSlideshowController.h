//
//  DWSlideshowController.h
//  PartySlideshow
//
//  Created by David Walsh on 3/20/14.
//  Copyright (c) 2014 David Walsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWSlideshowSource.h"

@interface DWSlideshowController : NSObject

@property DWSlideshowSource *slideshowSource;


-(IBAction)play:(id)sender;
-(void)stop;

@end
