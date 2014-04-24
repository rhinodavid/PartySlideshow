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
    timeInterval = 8.0;
    return self;
}

-(void) awakeFromNib {
    NSLog(@"awake");
    [self startBroadcast];

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
    NSString *nextPath = [[_slideshowSource nextPhoto] path];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:nextPath];
    if (!image) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"waiting1" ofType:@"jpg"];
        image = [[NSImage alloc] initWithContentsOfFile:path];
    }
    [controllerWindow updateImage:image];
}

- (void)startBroadcast {
    // Initialize GCDAsyncSocket
    NSLog(@"Initializing broadcast....");
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //start listening for incoming connnections
    NSError *error = nil;
    if ([self.socket acceptOnPort:0 error:&error]) {
        //initialize service
        self.service = [[NSNetService alloc] initWithDomain:@"local." type:@"_dwpartyslideshow._tcp." name:@"" port:[self.socket localPort]];
        // Configure service
        [self.service setDelegate:self];
        // Publish Service
        [self.service publish];
    } else {
        NSLog(@"Unable to create socket. Error %@ with user info %@.", error, [error userInfo]);
    }
}

- (void)netServiceDidPublish:(NSNetService *)service {
    NSLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
}

- (void)netService:(NSNetService *)service didNotPublish:(NSDictionary *)errorDict {
    NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@", [service domain], [service type], [service name], errorDict);
}

- (void)socket:(GCDAsyncSocket *)socket didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"Accepted New Socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
    
    // Socket
    [self setSocket:newSocket];
    
    // Read Data from Socket
    [newSocket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (self.socket == socket) {
        [self.socket setDelegate:nil];
        [self setSocket:nil];
    }
}

@end
