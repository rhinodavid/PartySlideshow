//
//  DWPacket.m
//  PartySlideshow
//
//  Created by David Walsh on 4/24/14.
//  Copyright (c) 2014 David Walsh. All rights reserved.
//

#import "DWPacket.h"

NSString * const DWPacketKeyData = @"data";
NSString * const DWPacketKeyType = @"type";
NSString * const DWPacketKeyAction = @"action";

@implementation DWPacket

#pragma mark -
#pragma mark Initialization
- (id)initWithData:(id)data type:(DWPacketType)type action:(DWPacketAction)action {
    self = [super init];
    
    if (self) {
        self.data = data;
        self.type = type;
        self.action = action;
    }
    
    return self;
}

#pragma mark -
#pragma mark NSCoding Protocol
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.data forKey:DWPacketKeyData];
    [coder encodeInteger:self.type forKey:DWPacketKeyType];
    [coder encodeInteger:self.action forKey:DWPacketKeyAction];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        [self setData:[decoder decodeObjectForKey:DWPacketKeyData]];
        [self setType:[decoder decodeIntegerForKey:DWPacketKeyType]];
        [self setAction:[decoder decodeIntegerForKey:DWPacketKeyAction]];
    }
    
    return self;
}

@end
