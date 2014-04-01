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
@property (strong) IBOutlet NSOpenGLView *openGLView;
@property (weak)   IBOutlet NSImageCell *testView;


-(IBAction)play:(id)sender;

@end
