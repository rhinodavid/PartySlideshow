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
    NSTimer                 *slideshowTimer;
    NSTimeInterval          timeInterval;
    

}

-(id) init {
    self = [super init];
    // do special stuff
    timeInterval = 6.0;
    _currentPhoto = nil;
    return self;
}

-(void) awakeFromNib {
    NSLog(@"awake");
    _connectionManager = [[DWPSSConnectionManager alloc] init];
    [_connectionManager setDelegate:self];
    [_connectionManager startBroadcast];
    

}

-(void)setSlideshowSource:(DWSlideshowSource *)slideshowSource {
    _slideshowSource = slideshowSource;
    [_slideshowSource setDelegate:self];
}

-(void)play {
    //show window
    if (!controllerWindow) {
        controllerWindow = [[DWPhotoWindowController alloc] initWithWindowNibName:@"DWSlideWindow"];
    }
    if (self.backgroundColor) {
        [controllerWindow setBackgroundColor:self.backgroundColor];
    } else {
        [controllerWindow setBackgroundColor:NSColor.blackColor];
    }
    [controllerWindow showWindow:self];
    [controllerWindow.window setDelegate:self];
    //make a timer at the correct interval
    [self showNextImage:nil];
    slideshowTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(showNextImage:) userInfo:nil repeats:YES];
    [slideshowTimer setTolerance:0.4];


}
-(void)updateTimeInterval:(double)newTimeInterval {
    if (newTimeInterval < 2.0) {
        newTimeInterval = 2.0;
    }
    if (newTimeInterval > 60.0) {
        newTimeInterval = 60.0;
    }
    NSLog(@"Time interval changed to: %4.2f", newTimeInterval);
    timeInterval = (NSTimeInterval)newTimeInterval;
    if (slideshowTimer) {
        [slideshowTimer invalidate];
        slideshowTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(showNextImage:) userInfo:nil repeats:YES];
        [slideshowTimer setTolerance:0.5];
    }
    
}

-(void)stop {
    [slideshowTimer invalidate];
    [controllerWindow close];
}

-(void)windowWillClose:(NSNotification *)notification {
    //stop the timer if the window will close
    [slideshowTimer invalidate];
}

-(void)showNextImage:(NSTimer*)timer {
    _currentPhoto = [_slideshowSource nextPhoto];
    NSString *nextPath = [_currentPhoto path];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:nextPath];
    if (!image) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"waiting1" ofType:@"jpg"];
        image = [[NSImage alloc] initWithContentsOfFile:path];
    }
    [controllerWindow updateImage:image];
}

-(void)photoAdded:(DWPhoto *)addedPhoto {
    // if a new photo is added, send it to the connected handheld
    
        NSString *path = [addedPhoto path];
        NSImage *image  = [[NSImage alloc] initWithContentsOfFile:path];
        if (image) {
            NSLog(@"Sending newly found image");
            NSImage *resizedImage = [self imageResize:image newSize:NSMakeSize(600, 600)];
            NSData *imageJPGData = [self JPGRepresentationOfImage:resizedImage];
            [_connectionManager sendImageAsData:imageJPGData];
            [_connectionManager sendImageName:addedPhoto.fileName];
        }
    
}

- (void)hideCurrentPhoto {
    [_currentPhoto setDisplay:NO];
}

#pragma mark -
#pragma mark Image Utility

 - (NSData *) JPGRepresentationOfImage:(NSImage *) image {
         // Create a bitmap representation from the current image
         [image lockFocus];
         NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, image.size.width, image.size.height)];
         [image unlockFocus];
    
         return [bitmapRep representationUsingType:NSJPEGFileType properties:Nil];
    }

- (NSImage *)imageResize:(NSImage*)anImage newSize:(NSSize)newSize {
    NSImage *sourceImage = anImage;
    [sourceImage setScalesWhenResized:YES];
    NSSize oldSize = [sourceImage size];
    double widthRatio = newSize.width / oldSize.width;
    double heightRatio = newSize.height / oldSize.height;
    // if ratios are less than 1 than the image needs to be resized
    double resizeRatio = widthRatio < heightRatio ? widthRatio : heightRatio;
    
    // Report an error if the source isn't a valid image
    if (![sourceImage isValid])
    {
        NSLog(@"Invalid Image");
    } else if (resizeRatio > 1) {
        //specified newSize is greater than the input image size; don't resize
        return sourceImage;
    } else {
        //specified image needs to be resized
        NSSize resizedSize = NSMakeSize(oldSize.width * resizeRatio, oldSize.height * resizeRatio);
        NSImage *smallImage = [[NSImage alloc] initWithSize: resizedSize];
        [smallImage lockFocus];
        [sourceImage setSize: resizedSize];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, resizedSize.width, resizedSize.height) operation:NSCompositeCopy fraction:1.0];
        [smallImage unlockFocus];
        return smallImage;
    }
    return nil;
}

#pragma mark -
#pragma mark Networking

- (void)connectionRecievedHidePhotoNamedCommand:(NSString *)name {
    [self.slideshowSource hidePhotoWithFileName:name];
}

@end
