//
//  DWPhotoWindowController.m
//  PartySlideshow
//
//  Created by David Walsh on 3/31/14.
//  Copyright (c) 2014 David Walsh. All rights reserved.
//

#import "DWPhotoWindowController.h"

@interface DWPhotoWindowController ()

@end

@implementation DWPhotoWindowController
{
    @private
    CATransition    *transition;
    NSImageView     *currentImageView;

}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        NSLog(@"initwithwindow called");
        
    }
    return self;
}

- (void)windowWillLoad {
    [super windowWillLoad];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setBackgroundColor:self.backgroundColor];
    [self.window setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
    NSView *contentView = [[self window] contentView];
    [contentView setWantsLayer:YES];
    transition = [CATransition animation];
    [transition setType:kCATransitionFade];
    [transition setDelegate:self];
    [transition setDuration:1.0];
    NSDictionary *ani = [NSDictionary dictionaryWithObject: transition forKey:@"subviews"];
    [contentView setAnimations:ani];
    [self.window setLevel: NSMainMenuWindowLevel];
    

}

-(void)updateImage: (NSImage*) newImage {
    NSView *contentView = [[self window] contentView];
    NSImage *resizedImage = [DWPhotoWindowController imageResize:newImage newSize:NSMakeSize(1200, 1200)];
    NSImageView *newImageView = nil;
    if (newImage) {
        newImageView = [[NSImageView alloc] initWithFrame:[contentView bounds]];
        [newImageView setImageScaling:NSImageScaleProportionallyUpOrDown];
        [newImageView setImage:resizedImage];
        [newImageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    }
    if (currentImageView && newImageView) {
        NSLog(@"if branch");
        [[contentView animator] replaceSubview:currentImageView with:newImageView];
    } else {
        NSLog(@"else branch");
        if (currentImageView) {
            NSLog(@"currentImageView branch");
            [[currentImageView animator] removeFromSuperview];
        }
        if (newImageView) {
            NSLog(@"newImageView branch");
            [[contentView animator] addSubview:newImageView];
        }
    }
    currentImageView = newImageView;
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if(flag) {
        NSLog(@"animation stopped yes");
       // [sourceImageView setImage:[destinationImageView image]];
       // [destinationImageView removeFromSuperview];
    } else {
        NSLog(@"animation stopped no");
    }
}

+ (NSImage *)imageResize:(NSImage*)anImage newSize:(NSSize)newSize {
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

@end
