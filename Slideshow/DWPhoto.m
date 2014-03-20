//
//  DWPhoto.m
//  PartySlideshow
//
//  Created by David Walsh on 3/19/14.
//  Copyright (c) 2014 David Walsh. All rights reserved.
//

#import "DWPhoto.h"

@implementation DWPhoto

- (id)init {
    self = [super init];
    if (self) {
        _display = YES;
        _displayCount = 0;
    }
    return self;
}

- (id)initWithFileName:(NSString*)fn baseURL:(NSURL*)url {
    self = [self init];
    if (self) {
        _fileName = fn;
        _folderURL = url;
    }
    return self;
}
- (void)photoWillBeDisplayed {
    _displayCount++;
}

- (NSString*)path {
    NSString *basePath = [self.folderURL path];
    return [[basePath stringByAppendingString:@"/"] stringByAppendingString:self.fileName];
}

@end
