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
    NSImageView *newImageView = nil;
    if (newImage) {
        newImageView = [[NSImageView alloc] initWithFrame:[contentView bounds]];
        [newImageView setImageScaling:NSImageScaleProportionallyUpOrDown];
        [newImageView setImage:newImage];
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

@end
