//
//  DWSlideshowSource.m
//  PartySlideshow
//
//  Created by David Walsh on 3/19/14.
//  Copyright (c) 2014 David Walsh. All rights reserved.
//

#import "DWSlideshowSource.h"

@implementation DWSlideshowSource

{
    @private
    NSMutableArray *photos;
    NSFileManager *localFileManager;
    DWPhoto *lastPhotoSent;
}

- (id)initWithBaseURL:(NSURL*)url{
    self = [super init];
    if (self) {
        _baseURL = url;
        photos = [NSMutableArray new];
        [self syncPhotos];
    }
    return self;
}


- (int)syncPhotos{
    
    int addedPhotos = 0;
    if (!localFileManager){
        localFileManager = [NSFileManager new];
    }
    NSArray *currentFiles = [localFileManager contentsOfDirectoryAtPath:[_baseURL path] error:nil];
    NSPredicate *jpgFilter = [NSPredicate predicateWithFormat:@"(self ENDSWITH '.jpg') OR (self ENDSWITH '.jpeg') OR (self ENDSWITH '.JPG') OR (self ENDSWITH '.JPEG')"];
    NSArray *currentFilesFiltered = [currentFiles filteredArrayUsingPredicate:jpgFilter];
    
    for (NSString* currentFileName in currentFilesFiltered) {
        if (![self havePhotoNamed:currentFileName]) {
            //if the photo isn't in the list, add it
            DWPhoto *newPhoto =[[DWPhoto alloc] initWithFileName:currentFileName baseURL:self.baseURL];
            [photos addObject:newPhoto];
            addedPhotos++;
            
            if (_delegate) {
                [_delegate photoAdded:newPhoto];
            }
        }
    }
    //check to see if we have more pictures than are in the folder (something has been deleted)
    if ([currentFilesFiltered count] != [photos count]) {
        for (DWPhoto* p in photos) {
            if (![self arrary:currentFilesFiltered containsPhoto:p]) {
                [photos removeObject:p];
                addedPhotos--;
            }
        }
    }
    return addedPhotos; //return how many photos have been added/removed
}


- (DWPhoto*)nextPhoto{
    //return nil if there are no photos to display
    if (![self photosToDisplay]) return nil;
    
    //look through the photos.  if any have not ever been displayed, grab the first one and return it
    //if not, just pick a random picture
    for (DWPhoto *photo in photos) {
        if ((photo.displayCount == 0) && photo.display) {
            [photo photoWillBeDisplayed];
            lastPhotoSent = photo;
            return photo;
        }
    }
    
    //no photo has not been displayed but can be displayed
    BOOL goodToDisplay = NO;
    
    DWPhoto* chosenPhoto;
    while (!goodToDisplay) {
        //while you don't have a good photo to display
        int topBound = (int)photos.count - 1;
        int ran = [self getRandomNumberBetween:0 to:topBound];
        chosenPhoto = [photos objectAtIndex:ran];
        if (chosenPhoto.display) goodToDisplay = YES;
    }
    lastPhotoSent = chosenPhoto;
    [chosenPhoto photoWillBeDisplayed];
    return chosenPhoto;
}

- (BOOL)havePhotoNamed:(NSString*)pn {
    for (DWPhoto* thisPhoto in photos) {
        if ([thisPhoto.fileName isEqualToString:pn]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hidePhotoWithFileName:(NSString *)fileName {
    DWPhoto *photo = [self getPhotoWithFileName:fileName];
    if (!photo) {
        //no photos were found
        return NO;
    } else {
        [photo setDisplay:NO];
        return YES;
    }
}

- (DWPhoto *)getPhotoWithFileName:(NSString*)fileName {
    for (DWPhoto* thisPhoto in photos) {
        if ([thisPhoto.fileName isEqualToString:fileName]) {
            return thisPhoto;
        }
    }
    return nil;
}

- (BOOL)photosToDisplay {
    for (DWPhoto* photo in photos) {
        if (photo.display) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)arrary:(NSArray*)a containsPhoto:(DWPhoto*)p {
    for (NSString* n in a) {
        if ([p.fileName isEqualToString:n]) {
            return YES;
        }
    }
    return NO;
}

- (NSString*)returnFullPhotoPath:(DWPhoto*)photo
{
    NSString *basePath = [self.baseURL path];
    return [[basePath stringByAppendingString:@"/"] stringByAppendingString:photo.fileName];
}

- (int) getRandomNumberBetween: (int)from to:(int)to {
    return (int)from + arc4random() % (to-from+1);
}

- (void) hideLastPhotoSent {
    [lastPhotoSent setDisplay:NO];
}

@end
