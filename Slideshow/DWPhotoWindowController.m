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
    CATransition *transition;
    NSImageView *sourceImageView;
    NSImageView *destinationImageView;
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

- (void)windowDidLoad
{
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSView *contentView = [[self window] contentView];
    [contentView setWantsLayer:YES];
    transition = [CATransition animation];
    [transition setType:kCATransitionFade];
    [transition setDelegate:self];
    NSDictionary *ani = [NSDictionary dictionaryWithObject: transition forKey:@"subviews"];
    [contentView setAnimations:ani];

}

-(void)updateImage: (NSImage*) newImage {
    
   // [_sourcePhoto setImage:newImage];
    if (!sourceImageView) {
        //first run.  no source.  make a blank one
        sourceImageView = [[NSImageView alloc] initWithFrame:[[[self window] contentView] frame]];
        [[[self window] contentView] addSubview: sourceImageView];
    }
    if (!destinationImageView) {
        //first run.  no destination.  make one.
        destinationImageView = [[NSImageView alloc] initWithFrame:[[[self window] contentView] frame]];
        //[[[self window] contentView] addSubview: sourceImageView];
    }
    [sourceImageView setImage:[destinationImageView image]]; //may not work the first time

    NSView *contentView = [[self window] contentView];
    [destinationImageView setImage:newImage];
    [[contentView animator] replaceSubview:sourceImageView with:destinationImageView];

}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if(flag) {
        NSLog(@"animation stopped yes");
        NSView *contentView = [[self window] contentView];
        //[sourceImageView setHidden:YES];
        [sourceImageView setImage:[destinationImageView image]];
        [contentView replaceSubview:destinationImageView with:sourceImageView];
    } else {
        NSLog(@"animation stopped no");
    }
}

@end
