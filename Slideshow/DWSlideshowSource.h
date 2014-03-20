//
//  DWSlideshowSource.h
//  PartySlideshow
//
//  Created by David Walsh on 3/19/14.
//  Copyright (c) 2014 David Walsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWPhoto.h"

@interface DWSlideshowSource : NSObject

@property NSURL *baseURL;

- (id)initWithBaseURL:(NSURL*)url;
- (int)syncPhotos;
- (DWPhoto*)nextPhoto;

@end
