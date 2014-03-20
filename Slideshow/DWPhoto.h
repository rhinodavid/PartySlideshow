//
//  DWPhoto.h
//  PartySlideshow
//
//  Created by David Walsh on 3/19/14.
//  Copyright (c) 2014 David Walsh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWPhoto : NSObject

{
    @private
}

@property NSString* fileName;
@property BOOL display;
@property (readonly) int displayCount;
@property NSURL* folderURL;


- (id)init;
- (id)initWithFileName:(NSString*)fn baseURL:(NSURL*)url;
- (void)photoWillBeDisplayed;
- (NSString*)path;

@end
