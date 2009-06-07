//--------------------------------------------------------
// ORGateElementModel
// Created by Mark  A. Howe on Fri Jan 21 2005
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2005 CENPA, University of Washington. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//Washington at the Center for Experimental Nuclear Physics and 
//Astrophysics (CENPA) sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//Washington reserve all rights in the program. Neither the authors,
//University of Washington, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------

#pragma mark ***Imported Files

#import "ORGate.h"

#pragma mark ***Forward Declarations
@class ORDataSet;
@class ORGateGroup;

typedef  enum {
    kAcceptIfOutsideGate,
    kAcceptIfInGate
}gateAcceptType;



@interface ORGateElement : NSObject
{
    @protected
        NSString*       decoderTarget;
        int  crateNumber;
        unsigned short  card;
        unsigned short  channel;
        ORGate*         gate;
        ORGateGroup*    gateGroup;
}

#pragma mark ***Initialization

+ (id) gateWithCrate:(unsigned short)aCrate 
                card:(unsigned short)aCard 
             channel:(unsigned short)aChannel;

- (id) initWithCrate:(unsigned short)aCrate 
                card:(unsigned short)aCard 
             channel:(unsigned short)aChannel;

- (void) dealloc;
- (NSUndoManager *)undoManager;

#pragma mark ***Accessors
- (ORGate *) gate;
- (void) setGate: (ORGate *) aGate;
- (NSString *) decoderTarget;
- (void) setDecoderTarget: (NSString *) aDecoderTarget;
- (int) crateNumber;
- (void) setCrateNumber:(int)aNewCrate;
- (unsigned short) card;
- (void) setCard:(unsigned short)aNewCard;
- (unsigned short ) channel;
- (void) setChannel:(unsigned short )aNewChannel;

- (BOOL) prepareData:(ORDataSet*)aDataSet
                    crate:(unsigned short)aCrate 
                    card:(unsigned short)aCard 
                 channel:(unsigned short)aChannel 
                   value:(unsigned long)aValue;
- (void) installGates:(id)obj;

- (NSMutableDictionary*) addParametersToDictionary:(NSMutableDictionary*)dictionary;
#pragma mark ***Achival
- (void) encodeWithCoder: (NSCoder *)coder;
- (id)   initWithCoder: (NSCoder *)coder;

@end

extern NSString* ORGateDecoderTargetChangedNotification;
extern NSString* ORGateCrateChangedNotification;
extern NSString* ORGateCardChangedNotification;
extern NSString* ORGateChannelChangedNotification;
