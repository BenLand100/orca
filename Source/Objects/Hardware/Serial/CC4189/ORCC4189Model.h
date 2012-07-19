//--------------------------------------------------------
// ORCC4189Model
// Created by Mark  A. Howe on Fri Jul 22 2005
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

#import "ORAdcProcessing.h"
#import "ORSerialPortModel.h"

@class ORTimeRate;

@interface ORCC4189Model : ORSerialPortModel <ORAdcProcessing>
{
    @private
        unsigned long	dataId;
		float		    temperature;
		float		    humidity;
		unsigned long	timeMeasured;
        NSMutableString*  buffer;
		BOOL			shipValues;
		ORTimeRate*		timeRates[2];
		BOOL            readOnce;
		double			lowLimit0;
		double			lowLimit1;
		double			highLimit0;
		double			highLimit1;
}

#pragma mark ***Initialization

- (id)   init;
- (void) dealloc;

- (void) dataReceived:(NSNotification*)note;

#pragma mark ***Accessors
- (double) highLimit1;
- (void) setHighLimit1:(double)aHighLimit1;
- (double) highLimit0;
- (void) setHighLimit0:(double)aHighLimit0;
- (double) lowLimit1;
- (void) setLowLimit1:(double)aLowLimit1;
- (double) lowLimit0;
- (void) setLowLimit0:(double)aLowLimit0;
- (ORTimeRate*)timeRate:(int)index;
- (BOOL) shipValues;
- (void) setShipValues:(BOOL)aFlag;
- (void) openPort:(BOOL)state;
- (unsigned long) timeMeasured;
- (float) temperature;
- (void) setTemperature:(float)aValue;
- (float) humidity;
- (void) setHumidity:(float)aValue;

#pragma mark ***Data Records
- (void) appendDataDescription:(ORDataPacket*)aDataPacket userInfo:(id)userInfo;
- (NSDictionary*) dataRecordDescription;
- (unsigned long) dataId;
- (void) setDataId: (unsigned long) DataId;
- (void) setDataIds:(id)assigner;
- (void) syncDataIdsWith:(id)anotherCC4189;

- (void) shipAllValues;

- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;

#pragma mark •••Adc Processing Protocol
- (void)processIsStarting;
- (void)processIsStopping;
- (void) startProcessCycle;
- (void) endProcessCycle;
- (BOOL) processValue:(int)channel;
- (void) setProcessOutput:(int)channel value:(int)value;
- (NSString*) processingTitle;
- (void) getAlarmRangeLow:(double*)theLowLimit high:(double*)theHighLimit  channel:(int)channel;
- (double) convertedValue:(int)channel;
- (double) maxValueForChan:(int)channel;
@end


extern NSString* ORCC4189ModelHighLimit1Changed;
extern NSString* ORCC4189ModelHighLimit0Changed;
extern NSString* ORCC4189ModelLowLimit1Changed;
extern NSString* ORCC4189ModelLowLimit0Changed;
extern NSString* ORCC4189ModelShipValuesChanged;
extern NSString* ORCC4189ModelPollTimeChanged;
extern NSString* ORCC4189Lock;
extern NSString* ORCC4189TemperatureChanged;
extern NSString* ORCC4189HumidityChanged;
