//
//  DWSlideshowController.m
//  PartySlideshow
//
//  Created by David Walsh on 3/20/14.
//  Copyright (c) 2014 David Walsh. All rights reserved.
//

#import "DWSlideshowController.h"
#import <Quartz/Quartz.h>

@implementation DWSlideshowController
{
    @private
    QCRenderer*         _renderer;
    NSOpenGLContext*    _fullScreenContext;
    
    

}

-(id) init {
    self = [super init];
    // do special stuff

    return self;
}

-(void) awakeFromNib {
    NSLog(@"awake");
    
    NSOpenGLPixelFormatAttribute attributes[] = {
        NSOpenGLPFAFullScreen,
        NSOpenGLPFAScreenMask, CGDisplayIDToOpenGLDisplayMask(kCGDirectMainDisplay),
        NSOpenGLPFANoRecovery,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFADepthSize, 24,
        (NSOpenGLPixelFormatAttribute) 0
    };
    NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
    
    
    if (!_renderer) {
        _renderer = [[QCRenderer alloc] initWithOpenGLContext:self.openGLView.openGLContext pixelFormat:[NSOpenGLView defaultPixelFormat] file:[[NSBundle mainBundle] pathForResource:@"sphere" ofType:@"qtz"]];
    
    }
    

    /*if (!_renderer) {
        _renderer = [[QCRenderer alloc] initWithOpenGLContext:self.openGLView.openGLContext pixelFormat:[NSOpenGLView defaultPixelFormat] file:[[NSBundle mainBundle] pathForResource:@"Transition" ofType:@"qtz"]];
        
    }*/
    /*
    CGDisplayCapture(kCGDirectMainDisplay);
    //CGDisplayHideCursor(kCGDirectMainDisplay);
  
    _fullScreenContext = [[NSOpenGLContext alloc] initWithFormat:format shareContext:nil];
    CGColorSpaceRef colorSpace = CGDisplayCopyColorSpace(kCGDirectMainDisplay);
    if (!_renderer) {
       // _renderer [[QCRenderer alloc] initWithCGLContext:[_fullScreenContext CGLContextObj] pixelFormat:[format CGLPixelFormatObj] colorSpace:colorSpace composition:<#(QCComposition *)#>]
        _renderer = [[QCRenderer alloc] initWithOpenGLContext:_fullScreenContext pixelFormat:[format CGLPixelFormatObj] file:[[NSBundle mainBundle] pathForResource:@"Transition" ofType:@"qtz"]];
    }*/
    
    GLenum glErr;
    glErr = glGetError();
    if (glErr != GL_NO_ERROR) {
        NSLog(@"GLerror");
    }

}

-(IBAction)play:(id)sender {

    NSImage *image = [[NSImage alloc] initWithContentsOfFile:[[_slideshowSource nextPhoto] path]];
    [_testView setObjectValue:image];
    [_renderer setValue:[_renderer valueForInputKey:QCCompositionInputDestinationImageKey] forInputKey:QCCompositionInputSourceImageKey];
    [_renderer setValue:image forInputKey:QCCompositionInputDestinationImageKey];
    double time;
    for (time = 0.0; time < 3.0; time += 0.01) {
        if(![_renderer renderAtTime:time arguments:nil]){
            NSLog(@"Rendering failed");
        } else {
            NSLog(@"Rendering at time %.3fs", time);
        }
        [_openGLView.openGLContext flushBuffer];
        
    }
    
    /*NSString *newPath = [[_slideshowSource nextPhoto] path];
    NSLog(newPath);
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:newPath];
    [_renderer setValue:[_renderer valueForInputKey:@"destination"] forInputKey:@"source"];
    [_renderer setValue:image forInputKey:@"destination"];
    
    double time;
     for (time = 0.0; time < 3.0; time += 0.01) {
         if(![_renderer renderAtTime:time arguments:nil]){
             NSLog(@"Rendering failed");
         } else {
             NSLog(@"Rendering at time %.3fs", time);
         }
         GLenum glErr;
         glErr = glGetError();
         if (glErr != GL_NO_ERROR) {
             NSLog(@"GLerror");
         }
         [_openGLView.openGLContext flushBuffer];
     }*/
}



@end
