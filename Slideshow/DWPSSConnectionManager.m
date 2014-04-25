//
//  DWPSSConnectionManager.m
//  PartySlideshowHandheld
//
//  Created by David Walsh on 4/24/14.
//  Copyright (c) 2014 David Walsh. All rights reserved.
//

#import "DWPSSConnectionManager.h"
#import "DWPacket.h"

@implementation DWPSSConnectionManager


/////////////////////////gonna need parts of these////////////////////////


/*-(void)cancel:(id)sender {
    [self stopBrowsing];
    [self dismissViewControllerAnimated:YES completion:nil];
}*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ServiceCell"];
    }
    
    //fetch service
    
    NSNetService *service = [self.services objectAtIndex:[indexPath row]];
    
    // Configure the cell
    
    [cell.textLabel setText:[service name]];
    
    return cell;
}*/

/////////////////////////////////////////////////////////
#pragma mark Wrappers

-(void)sendImageAsData:(NSData*)image {
    DWPacket *packet = [[DWPacket alloc] initWithData:image type:DWPacketTypeImage action:0];
    [self sendPacket:packet];
}


#pragma mark -
#pragma mark Client Methods
- (void) startBrowsing {
    if (self.services) {
        [self.services removeAllObjects];
    } else {
        self.services = [[NSMutableArray alloc] init];
    }
    
    //initialize service browser
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    
    //configure service browser
    [self.serviceBrowser setDelegate:self];
    [self.serviceBrowser searchForServicesOfType:@"_dwpartyslideshow._tcp." inDomain:@"local."];
}

- (void)stopBrowsing {
    if (self.serviceBrowser) {
        [self.serviceBrowser stop];
        [self.serviceBrowser setDelegate:nil];
        [self setServiceBrowser:nil];
    }
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    //update services
    [self.services addObject:aNetService];
    
    if (!moreComing) {
        //sort services
        [self.services sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        //update table view
        //[self.tableView reloadData];
        
        //for now just connect to first service
        NSNetService *service = [self.services objectAtIndex:0];
        [service setDelegate:self];
        [service resolveWithTimeout:20.0];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    //update services
    [self.services removeObject:aNetService];
    
    if (!moreComing) {
        //update table view
        //[self.tableView reloadData];
    }
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)serviceBrowser {
    [self stopBrowsing];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didNotSearch:(NSDictionary *)userInfo {
    [self stopBrowsing];
}


- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
    [service setDelegate:nil];
}


- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    //connect with service
    if ([self connectWithService:sender]) {
        NSLog(@"Did Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [sender domain], [sender type], [sender name], (int)[sender port]);
    } else {
        NSLog(@"Unable to Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [sender domain], [sender type], [sender name], (int)[sender port]);
    }
    if (_delegate) {
        [_delegate connectedToService:sender];
    }
}

- (BOOL)connectWithService:(NSNetService *)service {
    BOOL _isConnected = NO;
    
    // Copy Service Address
    NSArray *addresses = [[service addresses] mutableCopy];
    if (!self.socket || ![self.socket isConnected]) {
        // Initialize Socket
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        // Connect
        while (!_isConnected && [addresses count]) {
            NSData *address = [addresses objectAtIndex:0];
            
            NSError *error = nil;
            if ([self.socket connectToAddress:address error:&error]) {
                _isConnected = YES;
                
            } else if (error) {
                NSLog(@"Unable to connect to address. Error %@ with user info %@.", error, [error userInfo]);
            }
        }
        
    } else {
        _isConnected = [self.socket isConnected];
    }
    
    return _isConnected;
}

- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"Socket Did Connect to Host: %@ Port: %hu", host, port);
    
    // Start Reading
    [socket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
}

- (void)socket:(GCDAsyncSocket *)socket didReadData:(NSData *)data withTag:(long)tag  {
    if (tag == 0) {
        uint64_t bodyLength = [self parseHeader:data];
        [socket readDataToLength:bodyLength withTimeout:-1.0 tag:1];
    } else if (tag == 1 ) {
        [self parseBody:data];
        [socket readDataToLength:sizeof(uint64_t) withTimeout:30.0 tag:0];
    }
}

- (uint64_t)parseHeader:(NSData *)data {
    uint64_t headerLength = 0;
    memcpy(&headerLength, [data bytes], sizeof(uint64_t));
    
    return headerLength;
}

- (void)parseBody:(NSData *)data {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    DWPacket *packet = [unarchiver decodeObjectForKey:@"packet"];
    [unarchiver finishDecoding];
    
    NSLog(@"Packet Data > %@", packet.data);
    NSLog(@"Packet Type > %i", packet.type);
    NSLog(@"Packet Action > %i", packet.action);
    
    
    if (packet.type == DWPacketTypeImage) {
        NSData *JPGImage = packet.data;
        [_delegate connectionRecievedImageData:JPGImage];
    }
}

#pragma mark -
#pragma mark Server Methods




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
    
    // Create Packet
    NSString *message = @"This is a proof of concept.";
    DWPacket *packet = [[DWPacket alloc] initWithData:message type:DWPacketTypeMessage action:0];
    
    [self sendPacket: packet];
}


#pragma mark -
#pragma mark Common Methods

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (self.socket == socket) {
        [self.socket setDelegate:nil];
        [self setSocket:nil];
    }
}

- (void)sendPacket:(DWPacket *)packet {
    // Encode packet data
    NSMutableData *packetData = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:packetData];
    [archiver encodeObject:packet forKey:@"packet"];
    [archiver finishEncoding];
    
    // Initialize Buffer
    NSMutableData *buffer = [[NSMutableData alloc] init];
    
    // Fill Buffer
    uint64_t headerLength = [packetData length];
    [buffer appendBytes:&headerLength length:sizeof(uint64_t)];
    [buffer appendBytes:[packetData bytes] length:[packetData length]];
    
    // Write Buffer
    [self.socket writeData:buffer withTimeout:-1.0 tag:0];
}

@end
