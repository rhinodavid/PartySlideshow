//
//  DWSlideshowSource.h
//  PartySlideshow
//
//  Created by David Walsh on 3/19/14.
//  Copyright (c) 2014 David Walsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWPhoto.h"


@protocol DWSlideshowSourceDelegate

-(void)photoAdded:(DWPhoto *)addedPhoto;

@end


@interface DWSlideshowSource : NSObject

@property NSURL *baseURL;
@property (nonatomic, assign) id delegate;

- (id)initWithBaseURL:(NSURL*)url;
- (int)syncPhotos;
- (DWPhoto*)nextPhoto;

@end
