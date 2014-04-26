//
//  DWPSSConnectionManager.h
//  PartySlideshowHandheld
//
//  Created by David Walsh on 4/24/14.
//  Copyright (c) 2014 David Walsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaAsyncSocket/GCDAsyncSocket.h"

@protocol DWPSSConnectionManagerDelegate

-(void)connectedToService:(NSNetService *)service;
-(void)connectionRecievedImageData:(NSData *)imageData;
-(void)connectionRecievedImageName:(NSString *)name;
-(void)connectionRecievedHidePhotoNamedCommand:(NSString *)name;


@end

@interface DWPSSConnectionManager : NSObject <NSNetServiceDelegate, NSNetServiceBrowserDelegate, GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (strong, nonatomic) NSNetService *service; //server has one connected service
@property (strong, nonatomic) NSMutableArray *services; //clients have an array of possible servers
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;

@property (nonatomic, assign) id delegate;

- (void)startBrowsing;
- (void)startBroadcast;
- (void)sendImageAsData:(NSData*)image;
- (void)sendImageName:(NSString*)name;
- (void)sendHidePhotoNamedCommand:(NSString *)name;

@end
