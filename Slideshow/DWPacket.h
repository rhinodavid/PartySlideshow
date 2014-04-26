//
//  DWPacket.h
//  PartySlideshow
//
//  Created by David Walsh on 4/24/14.
//  Copyright (c) 2014 David Walsh. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const DWPacketKeyData;
extern NSString * const DWPacketKeyType;
extern NSString * const MTPacketKeyAction;

typedef enum {
    DWPacketTypeUnknown = -1,
    DWPacketTypeNone = 0,
    DWPacketTypeImage,
    DWPacketTypeMessage,
    DWPacketTypeConnection,
    DWPacketTypeConnectionReply,
    DWPacketTypeImageName
} DWPacketType;

typedef enum {
    DWPacketActionUnknown = -1,
    DWPacketActionNone = 0,
    DWPacketActionHidePhoto, //NSString of photo name to hide as packet data
    DWPacketActionNext,
    DWPacketActionPrevious,
} DWPacketAction;

@interface DWPacket : NSObject

@property (strong, nonatomic) id data;
@property (assign, nonatomic) DWPacketType type;
@property (assign, nonatomic) DWPacketAction action;

#pragma mark -
#pragma mark Initialization

- (id)initWithData:(id)data type:(DWPacketType)type action:(DWPacketAction)action;

@end
