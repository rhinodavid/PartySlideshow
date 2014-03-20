//
//  AppDelegate.h
//  Slideshow
//
//  Created by David Walsh on 3/17/14.
//  Copyright (c) 2014 David Walsh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    @private
    NSMutableArray* _fileList;
    QCRenderer* _renderer;
}

@property (assign) IBOutlet NSWindow *controlWindow;
@property (assign) IBOutlet NSWindow *playWindow;

@property (weak) IBOutlet NSPathControl *pathControl;
@property (weak) IBOutlet NSButton *setPathButton;
@property (weak) IBOutlet NSTextField *textField;
@property (weak) IBOutlet NSSlider *durationSlider;
@property (weak) IBOutlet NSImageCell *topPhoto;
@property (weak) IBOutlet NSOpenGLView *glView;

@end
