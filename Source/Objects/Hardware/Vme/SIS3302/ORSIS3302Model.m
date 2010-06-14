//-------------------------------------------------------------------------
//  ORSIS3302.h
//
//  Created by Mark A. Howe on Wednesday 9/30/08.
//  Copyright (c) 2008 CENPA. University of Washington. All rights reserved.
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
#import "ORSIS3302Model.h"
#import "ORDataTypeAssigner.h"
#import "ORHWWizParam.h"
#import "ORHWWizSelection.h"
#import "ORVmeCrateModel.h"
#import "ORRateGroup.h"
#import "ORTimer.h"
#import "VME_HW_Definitions.h"
#import "ORVmeTests.h"
#import "ORVmeReadWriteCommand.h"
#import "ORCommandList.h"

NSString* ORSIS3302ModelShipTimeRecordAlsoChanged		= @"ORSIS3302ModelShipTimeRecordAlsoChanged";
NSString* ORSIS3302ModelMcaUseEnergyCalculationChanged  = @"ORSIS3302ModelMcaUseEnergyCalculationChanged";
NSString* ORSIS3302ModelMcaEnergyOffsetChanged			= @"ORSIS3302ModelMcaEnergyOffsetChanged";
NSString* ORSIS3302ModelMcaEnergyMultiplierChanged		= @"ORSIS3302ModelMcaEnergyMultiplierChanged";
NSString* ORSIS3302ModelMcaEnergyDividerChanged			= @"ORSIS3302ModelMcaEnergyDividerChanged";
NSString* ORSIS3302ModelMcaModeChanged					= @"ORSIS3302ModelMcaModeChanged";
NSString* ORSIS3302ModelMcaPileupEnabledChanged			= @"ORSIS3302ModelMcaPileupEnabledChanged";
NSString* ORSIS3302ModelMcaHistoSizeChanged				= @"ORSIS3302ModelMcaHistoSizeChanged";
NSString* ORSIS3302ModelMcaNofScansPresetChanged		= @"ORSIS3302ModelMcaNofScansPresetChanged";
NSString* ORSIS3302ModelMcaAutoClearChanged				= @"ORSIS3302ModelMcaAutoClearChanged";
NSString* ORSIS3302ModelMcaPrescaleFactorChanged		= @"ORSIS3302ModelMcaPrescaleFactorChanged";
NSString* ORSIS3302ModelMcaLNESetupChanged				= @"ORSIS3302ModelMcaLNESetupChanged";
NSString* ORSIS3302ModelMcaNofHistoPresetChanged		= @"ORSIS3302ModelMcaNofHistoPresetChanged";

NSString* ORSIS3302ModelInternalExternalTriggersOredChanged = @"ORSIS3302ModelInternalExternalTriggersOredChanged";
NSString* ORSIS3302ModelLemoInEnabledMaskChanged		= @"ORSIS3302ModelLemoInEnabledMaskChanged";
NSString* ORSIS3302ModelEnergyGateLengthChanged			= @"ORSIS3302ModelEnergyGateLengthChanged";
NSString* ORSIS3302ModelRunModeChanged					= @"ORSIS3302ModelRunModeChanged";
NSString* ORSIS3302ModelEndAddressThresholdChanged		= @"ORSIS3302ModelEndAddressThresholdChanged";
NSString* ORSIS3302ModelEnergySampleStartIndex3Changed	= @"ORSIS3302ModelEnergySampleStartIndex3Changed";
NSString* ORSIS3302ModelEnergyTauFactorChanged			= @"ORSIS3302ModelEnergyTauFactorChanged";
NSString* ORSIS3302ModelEnergySampleStartIndex2Changed	= @"ORSIS3302ModelEnergySampleStartIndex2Changed";
NSString* ORSIS3302ModelEnergySampleStartIndex1Changed	= @"ORSIS3302ModelEnergySampleStartIndex1Changed";
NSString* ORSIS3302ModelEnergySampleLengthChanged		= @"ORSIS3302ModelEnergySampleLengthChanged";
NSString* ORSIS3302ModelEnergyGapTimeChanged	 = @"ORSIS3302ModelEnergyGapTimeChanged";
NSString* ORSIS3302ModelEnergyPeakingTimeChanged = @"ORSIS3302ModelEnergyPeakingTimeChanged";
NSString* ORSIS3302ModelTriggerGateLengthChanged = @"ORSIS3302ModelTriggerGateLengthChanged";
NSString* ORSIS3302ModelPreTriggerDelayChanged  = @"ORSIS3302ModelPreTriggerDelayChanged";
NSString* ORSIS3302SampleStartIndexChanged		= @"ORSIS3302SampleStartIndexChanged";
NSString* ORSIS3302SampleLengthChanged			= @"ORSIS3302SampleLengthChanged";
NSString* ORSIS3302DacOffsetChanged				= @"ORSIS3302DacOffsetChanged";
NSString* ORSIS3302LemoInModeChanged			= @"ORSIS3302LemoInModeChanged";
NSString* ORSIS3302LemoOutModeChanged			= @"ORSIS3302LemoOutModeChanged";
NSString* ORSIS3302AcqRegChanged				= @"ORSIS3302AcqRegChanged";
NSString* ORSIS3302EventConfigChanged			= @"ORSIS3302EventConfigChanged";
NSString* ORSIS3302InputInvertedChanged			= @"ORSIS3302InputInvertedChanged";
NSString* ORSIS3302InternalTriggerEnabledChanged = @"ORSIS3302InternalTriggerEnabledChanged";
NSString* ORSIS3302ExternalTriggerEnabledChanged = @"ORSIS3302ExternalTriggerEnabledChanged";
NSString* ORSIS3302InternalGateEnabledChanged	= @"ORSIS3302InternalGateEnabledChanged";
NSString* ORSIS3302ExternalGateEnabledChanged	= @"ORSIS3302ExternalGateEnabledChanged";
NSString* ORSIS3302ExtendedThresholdEnabledChanged = @"ORSIS3302ExtendedThresholdEnabledChanged";

NSString* ORSIS3302ClockSourceChanged			= @"ORSIS3302ClockSourceChanged";

NSString* ORSIS3302RateGroupChangedNotification	= @"ORSIS3302RateGroupChangedNotification";
NSString* ORSIS3302SettingsLock					= @"ORSIS3302SettingsLock";

NSString* ORSIS3302TriggerOutEnabledChanged		= @"ORSIS3302TriggerOutEnabledChanged";
NSString* ORSIS3302ThresholdChanged				= @"ORSIS3302ThresholdChanged";
NSString* ORSIS3302ThresholdArrayChanged		= @"ORSIS3302ThresholdArrayChanged";
NSString* ORSIS3302GtChanged					= @"ORSIS3302GtChanged";
NSString* ORSIS3302SampleDone					= @"ORSIS3302SampleDone";
NSString* ORSIS3302IDChanged					= @"ORSIS3302IDChanged";
NSString* ORSIS3302GateLengthChanged			= @"ORSIS3302GateLengthChanged";
NSString* ORSIS3302PulseLengthChanged			= @"ORSIS3302PulseLengthChanged";
NSString* ORSIS3302SumGChanged					= @"ORSIS3302SumGChanged";
NSString* ORSIS3302PeakingTimeChanged			= @"ORSIS3302PeakingTimeChanged";
NSString* ORSIS3302InternalTriggerDelayChanged	= @"ORSIS3302InternalTriggerDelayChanged";
NSString* ORSIS3302TriggerDecimationChanged		= @"ORSIS3302TriggerDecimationChanged";
NSString* ORSIS3302EnergyDecimationChanged		= @"ORSIS3302EnergyDecimationChanged";
NSString* ORSIS3302SetShipWaveformChanged		= @"ORSIS3302SetShipWaveformChanged";
NSString* ORSIS3302Adc50KTriggerEnabledChanged	= @"ORSIS3302Adc50KTriggerEnabledChanged";
NSString* ORSIS3302McaStatusChanged				= @"ORSIS3302McaStatusChanged";




@interface ORSIS3302Model (private)
- (void) writeDacOffsets;
- (void) setUpArrays;
- (void) pollMcaStatus;
- (NSMutableArray*) arrayOfLength:(int)len;
@end

@implementation ORSIS3302Model
#pragma mark •••Static Declarations
//offsets from the base address
typedef struct {
	unsigned long offset;
	NSString* name;
} SIS3302GammaRegisterInformation;

#define kNumSIS3302ReadRegs 173

static SIS3302GammaRegisterInformation register_information[kNumSIS3302ReadRegs] = {
	{0x00000000,  @"Control/Status"},                         
	{0x00000004,  @"Module Id. and Firmware Revision"},                         
	{0x00000008,  @"Interrupt configuration"},                         
	{0x00000000,  @"Interrupt control"},     
	{0x0000000C,  @"Acquisition control/status"}, 
	{0x00000030,  @"Broadcast Setup register"},                         
	{0x00000034,  @"ADC Memory Page register"},  
	{0x00000050,  @"DAC Control Status register"},                         
	{0x00000054,  @"DAC Data register"},    
	{0x00000060,  @"XILINX JTAG_TEST/JTAG_DATA_IN"},
	{0x00000080,  @"MCA Scan Nof Histograms preset"},    
	{0x00000084,  @"MCA Scan Histogram counter"},    
	{0x00000088,  @"MCA Scan LNE Setup and Prescaler Factor"},    
	{0x0000008C,  @"MCA Scan Control register"},   
	{0x00000090,  @"MCA Multiscan Nof Scans prese"},    
	{0x00000094,  @"MCA Multiscan Scan counter"},    
	{0x00000098,  @"MCA Multiscan last Scan Histogram count"},    

	//group 1
	{0x02000000,  @"Event configuration (ADC1, ADC2)"},    
	{0x02000004,  @"End Address Threshold (ADC1, ADC2)"},    
	{0x02000008,  @"Pretrigger Delay and Trigger Gate Length (ADC1, ADC2)"},    
	{0x0200000C,  @"Raw Data Buffer Configuration (ADC1, ADC2)"},    
	{0x02000010,  @"Actual Sample address ADC1"},    
	{0x02000014,  @"Actual Next Sample address ADC2"},    
	{0x02000018,  @"Pretrigger Delay and Trigger Gate Length (ADC1, ADC2)"},    
	{0x0200001C,  @"Previous Bank Sample address ADC2"},    
	{0x02000020,  @"Actual Sample Value (ADC1, ADC2)"},    
	{0x02000024,  @"internal Test"},    
	{0x02000028,  @"DDR2 Memory Logic Verification (ADC1, ADC2)"},    
	{0x02000030,  @"Trigger Setup ADC1"},    
	{0x02000034,  @"Trigger Threshold ADC1"},    
	{0x02000038,  @"Trigger Setup ADC2"},    
	{0x0200003C,  @"Trigger Threshold ADC2"},    
	{0x02000040,  @"Energy Setup GP (ADC1, ADC2)"},    
	{0x02000044,  @"Energy Gate Length (ADC1, ADC2)"},    
	{0x02000048,  @"Energy Sample Length (ADC1, ADC2)"},    
	{0x0200004C,  @"Energy Sample Start Index1 (ADC1, ADC2)"},    
	{0x02000050,  @"Energy Sample Start Index2 (ADC1, ADC2)"},    
	{0x02000054,  @"Energy Sample Start Index3 (ADC1, ADC2)"},    
	{0x02000058,  @"Energy Tau Factor ADC1"},    
	{0x0200005C,  @"Energy Tau Factor ADC2"},    
	{0x02000060,  @"MCA Energy to Histogram Calculation Parameter ADC1"},    
	{0x02000064,  @"MCA Energy to Histogram Calculation Parameter ADC2"},    
	{0x02000068,  @"MCA Histogram Parameters (ADC1, ADC2)"},    
	{0x02000070,  @"Event Extended configuration (ADC1, ADC2)"},    
	{0x02000078,  @"Trigger Extended Setup ADC1"},    
	{0x0200007C,  @"Trigger Extended Setup ADC2"},    
	{0x02000080,  @"MCA Trigger Start Counter ADC1"},    
	{0x02000084,  @"MCA Pileup Counter ADC1"},    
	{0x02000088,  @"MCA 'Energy to high' counter ADC1"},    
	{0x0200008C,  @"MCA 'Energy to low' counter ADC1"},    
	{0x02000090,  @"MCA Trigger Start Counter ADC2"},    
	{0x02000094,  @"MCA Pileup Counter ADC2"},    
	{0x02000098,  @"MCA 'Energy to high' counter ADC2"},    
	{0x0200009C,  @"MCA 'Energy to low' counter ADC2"},    
	{0x020000A0,  @"Trigger Extended Threshold ADC1"},    
	{0x020000A4,  @"Trigger Extended Threshold ADC2"},   
	
	//group 2
	{0x02800000,  @"Event configuration (ADC3, ADC4)"},    
	{0x02800004,  @"End Address Threshold (ADC13, ADC4)"},    
	{0x02800008,  @"Pretrigger Delay and Trigger Gate Length (ADC3, ADC4)"},    
	{0x0280000C,  @"Raw Data Buffer Configuration (ADC3, ADC4)"},    
	{0x02800010,  @"Actual Sample address ADC3"},    
	{0x02800014,  @"Actual Next Sample address ADC4"},    
	{0x02800018,  @"Pretrigger Delay and Trigger Gate Length (ADC3, ADC4)"},    
	{0x0280001C,  @"Previous Bank Sample address ADC4"},    
	{0x02800020,  @"Actual Sample Value (ADC3, ADC4)"},    
	{0x02800024,  @"internal Test"},    
	{0x02800028,  @"DDR2 Memory Logic Verification (ADC3, ADC4)"},    
	{0x02800030,  @"Trigger Setup ADC3"},    
	{0x02800034,  @"Trigger Threshold ADC3"},    
	{0x02800038,  @"Trigger Setup ADC4"},    
	{0x0280003C,  @"Trigger Threshold ADC4"},    
	{0x02800040,  @"Energy Setup GP (ADC3, ADC4)"},    
	{0x02800044,  @"Energy Gate Length (ADC3, ADC4)"},    
	{0x02800048,  @"Energy Sample Length (ADC3, ADC4)"},    
	{0x0280004C,  @"Energy Sample Start Index1 (ADC3, ADC4)"},    
	{0x02800050,  @"Energy Sample Start Index2 (ADC3, ADC4)"},    
	{0x02800054,  @"Energy Sample Start Index3 (ADC3, ADC4)"},    
	{0x02800058,  @"Energy Tau Factor ADC3"},    
	{0x0280005C,  @"Energy Tau Factor ADC4"},    
	{0x02800060,  @"MCA Energy to Histogram Calculation Parameter ADC3"},    
	{0x02800064,  @"MCA Energy to Histogram Calculation Parameter ADC4"},    
	{0x02800068,  @"MCA Histogram Parameters (ADC3, ADC4)"},   
	{0x02800070,  @"Event Extended configuration (ADC3, ADC4)"},    
	{0x02800078,  @"Trigger Extended Setup ADC3"},    
	{0x0280007C,  @"Trigger Extended Setup ADC4"},    
	{0x02800080,  @"MCA Trigger Start Counter ADC3"},    
	{0x02800084,  @"MCA Pileup Counter ADC3"},    
	{0x02800088,  @"MCA 'Energy to high' counter ADC3"},    
	{0x0280008C,  @"MCA 'Energy to low' counter ADC3"},    
	{0x02800090,  @"MCA Trigger Start Counter ADC4"},    
	{0x02800094,  @"MCA Pileup Counter ADC4"},    
	{0x02800098,  @"MCA 'Energy to high' counter ADC4"},    
	{0x0280009C,  @"MCA 'Energy to low' counter ADC4"},    
	{0x028000A0,  @"Trigger Extended Threshold ADC3"},    
	{0x028000A4,  @"Trigger Extended Threshold ADC4"},    
	
	//group 3
	{0x3000000,  @"Event configuration (ADC5, ADC6)"},    
	{0x3000004,  @"End Address Threshold (ADC5, ADC6)"},    
	{0x3000008,  @"Pretrigger Delay and Trigger Gate Length (ADC5, ADC6)"},    
	{0x300000C,  @"Raw Data Buffer Configuration (ADC5, ADC6)"},    
	{0x3000010,  @"Actual Sample address ADC5"},    
	{0x3000014,  @"Actual Next Sample address ADC6"},    
	{0x3000018,  @"Pretrigger Delay and Trigger Gate Length (ADC5, ADC6)"},    
	{0x300001C,  @"Previous Bank Sample address ADC6"},    
	{0x3000020,  @"Actual Sample Value (ADC5, ADC6)"},    
	{0x3000024,  @"internal Test"},    
	{0x3000028,  @"DDR2 Memory Logic Verification (ADC5, ADC6)"},    
	{0x3000030,  @"Trigger Setup ADC5"},    
	{0x3000034,  @"Trigger Threshold ADC5"},    
	{0x3000038,  @"Trigger Setup ADC6"},    
	{0x300003C,  @"Trigger Threshold ADC6"},    
	{0x3000040,  @"Energy Setup GP (ADC5, ADC6)"},    
	{0x3000044,  @"Energy Gate Length (ADC5, ADC6)"},    
	{0x3000048,  @"Energy Sample Length (ADC5, ADC6)"},    
	{0x300004C,  @"Energy Sample Start Index1 (ADC5, ADC6)"},    
	{0x3000050,  @"Energy Sample Start Index2 (ADC5, ADC6)"},    
	{0x3000054,  @"Energy Sample Start Index3 (ADC5, ADC6)"},    
	{0x3000058,  @"Energy Tau Factor ADC5"},    
	{0x300005C,  @"Energy Tau Factor ADC6"},    
	{0x3000060,  @"MCA Energy to Histogram Calculation Parameter ADC5"},    
	{0x3000064,  @"MCA Energy to Histogram Calculation Parameter ADC6"},    
	{0x3000068,  @"MCA Histogram Parameters (ADC5, ADC6)"},   
	{0x3000070,  @"Event Extended configuration (ADC5, ADC6)"},    
	{0x3000078,  @"Trigger Extended Setup ADC5"},    
	{0x300007C,  @"Trigger Extended Setup ADC6"},    
	{0x3000080,  @"MCA Trigger Start Counter ADC5"},    
	{0x3000084,  @"MCA Pileup Counter ADC5"},    
	{0x3000088,  @"MCA 'Energy to high' counter ADC5"},    
	{0x300008C,  @"MCA 'Energy to low' counter ADC5"},    
	{0x3000090,  @"MCA Trigger Start Counter ADC6"},    
	{0x3000094,  @"MCA Pileup Counter ADC6"},    
	{0x3000098,  @"MCA 'Energy to high' counter ADC6"},    
	{0x300009C,  @"MCA 'Energy to low' counter ADC6"},    
	{0x30000A0,  @"Trigger Extended Threshold ADC5"},    
	{0x30000A4,  @"Trigger Extended Threshold ADC6"},    
	
	//group 4
	{0x3800000,  @"Event configuration (ADC7, ADC8)"},    
	{0x3800004,  @"End Address Threshold (ADC7, ADC8)"},    
	{0x3800008,  @"Pretrigger Delay and Trigger Gate Length (ADC7, ADC8)"},    
	{0x380000C,  @"Raw Data Buffer Configuration (ADC7, ADC8)"},    
	{0x3800010,  @"Actual Sample address ADC7"},    
	{0x3800014,  @"Actual Next Sample address ADC8"},    
	{0x3800018,  @"Pretrigger Delay and Trigger Gate Length (ADC7, ADC8)"},    
	{0x380001C,  @"Previous Bank Sample address ADC8"},    
	{0x3800020,  @"Actual Sample Value (ADC7, ADC8)"},    
	{0x3800024,  @"internal Test"},    
	{0x3800028,  @"DDR2 Memory Logic Verification (ADC7, ADC8)"},    
	{0x3800030,  @"Trigger Setup ADC7"},    
	{0x3800034,  @"Trigger Threshold ADC7"},    
	{0x3800038,  @"Trigger Setup ADC8"},    
	{0x380003C,  @"Trigger Threshold ADC8"},    
	{0x3800040,  @"Energy Setup GP (ADC7, ADC8)"},    
	{0x3800044,  @"Energy Gate Length (ADC7, ADC8)"},    
	{0x3800048,  @"Energy Sample Length (ADC7, ADC8)"},    
	{0x380004C,  @"Energy Sample Start Index1 (ADC7, ADC8)"},    
	{0x3800050,  @"Energy Sample Start Index2 (ADC7, ADC8)"},    
	{0x3800054,  @"Energy Sample Start Index3 (ADC7, ADC8)"},    
	{0x3800058,  @"Energy Tau Factor ADC7"},    
	{0x380005C,  @"Energy Tau Factor ADC8"},    
	{0x3800060,  @"MCA Energy to Histogram Calculation Parameter ADC7"},    
	{0x3800064,  @"MCA Energy to Histogram Calculation Parameter ADC8"},    
	{0x3800068,  @"MCA Histogram Parameters (ADC7, ADC8)"},   
	{0x3800070,  @"Event Extended configuration (ADC7, ADC8)"},    
	{0x3800078,  @"Trigger Extended Setup ADC7"},    
	{0x380007C,  @"Trigger Extended Setup ADC8"},    
	{0x3800080,  @"MCA Trigger Start Counter ADC7"},    
	{0x3800084,  @"MCA Pileup Counter ADC7"},    
	{0x3800088,  @"MCA 'Energy to high' counter ADC7"},    
	{0x380008C,  @"MCA 'Energy to low' counter ADC7"},    
	{0x3800090,  @"MCA Trigger Start Counter ADC8"},    
	{0x3800094,  @"MCA Pileup Counter ADC8"},    
	{0x3800098,  @"MCA 'Energy to high' counter ADC8"},    
	{0x380009C,  @"MCA 'Energy to low' counter ADC8"},    
	{0x38000A0,  @"Trigger Extended Threshold ADC7"},    
	{0x38000A4,  @"Trigger Extended Threshold ADC8"}
};

#pragma mark ***Initialization
- (id) init 
{
    self = [super init];
    [[self undoManager] disableUndoRegistration];
    [self setAddressModifier:0x09];
    [self setBaseAddress:0x08000000];
    [self initParams];

    [[self undoManager] enableUndoRegistration];
    return self;
}

- (void) dealloc 
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	[gateLengths release];
	[pulseLengths release];
	[sumGs release];
	[peakingTimes release];
	[internalTriggerDelays release];
	
 	[thresholds release];
	[waveFormRateGroup release];
    [super dealloc];
}

- (void) setUpImage
{
    [self setImage:[NSImage imageNamed:@"SIS3302Card"]];	
}

- (void) makeMainController
{
    [self linkToController:@"ORSIS3302Controller"];
}

- (NSString*) helpURL
{
	return @"VME/SIS3302_(Gamma).html";
}

- (NSRange)	memoryFootprint
{
	return NSMakeRange(baseAddress, 0x00780000 + (8*0x1024*0x1024));
}

#pragma mark ***Accessors

- (BOOL) shipTimeRecordAlso
{
    return shipTimeRecordAlso;
}

- (void) setShipTimeRecordAlso:(BOOL)aShipTimeRecordAlso
{
    [[[self undoManager] prepareWithInvocationTarget:self] setShipTimeRecordAlso:shipTimeRecordAlso];
    
    shipTimeRecordAlso = aShipTimeRecordAlso;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelShipTimeRecordAlsoChanged object:self];
}
- (BOOL) mcaUseEnergyCalculation { return mcaUseEnergyCalculation; }
- (void) setMcaUseEnergyCalculation:(BOOL)aMcaUseEnergyCalculation
{
    [[[self undoManager] prepareWithInvocationTarget:self] setMcaUseEnergyCalculation:mcaUseEnergyCalculation];
    mcaUseEnergyCalculation = aMcaUseEnergyCalculation;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelMcaUseEnergyCalculationChanged object:self];
}

- (int) mcaEnergyOffset { return mcaEnergyOffset; }
- (void) setMcaEnergyOffset:(int)aMcaEnergyOffset
{
    [[[self undoManager] prepareWithInvocationTarget:self] setMcaEnergyOffset:mcaEnergyOffset];
	mcaEnergyOffset = [self limitIntValue:aMcaEnergyOffset min:0 max:0xfffff];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelMcaEnergyOffsetChanged object:self];
}

- (int) mcaEnergyMultiplier { return mcaEnergyMultiplier; }
- (void) setMcaEnergyMultiplier:(int)aMcaEnergyMultiplier
{
    [[[self undoManager] prepareWithInvocationTarget:self] setMcaEnergyMultiplier:mcaEnergyMultiplier];
	mcaEnergyMultiplier = [self limitIntValue:aMcaEnergyMultiplier min:0 max:0xffff];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelMcaEnergyMultiplierChanged object:self];
}

- (int) mcaEnergyDivider { return mcaEnergyDivider; }
- (void) setMcaEnergyDivider:(int)aMcaEnergyDivider
{
    [[[self undoManager] prepareWithInvocationTarget:self] setMcaEnergyDivider:mcaEnergyDivider];
	mcaEnergyDivider = [self limitIntValue:aMcaEnergyDivider min:1 max:16];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelMcaEnergyDividerChanged object:self];
}

- (int) mcaMode { return mcaMode; }
- (void) setMcaMode:(int)aMcaMode
{
    [[[self undoManager] prepareWithInvocationTarget:self] setMcaMode:mcaMode];
    mcaMode = aMcaMode;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelMcaModeChanged object:self];
}

- (BOOL) mcaPileupEnabled { return mcaPileupEnabled; }
- (void) setMcaPileupEnabled:(BOOL)aMcaPileupEnabled
{
    [[[self undoManager] prepareWithInvocationTarget:self] setMcaPileupEnabled:mcaPileupEnabled];
    mcaPileupEnabled = aMcaPileupEnabled;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelMcaPileupEnabledChanged object:self];
}

- (int) mcaHistoSize { return mcaHistoSize; }
- (void) setMcaHistoSize:(int)aMcaHistoSize
{
    [[[self undoManager] prepareWithInvocationTarget:self] setMcaHistoSize:mcaHistoSize];
    mcaHistoSize = aMcaHistoSize;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelMcaHistoSizeChanged object:self];
}

- (unsigned long) mcaNofScansPreset { return mcaNofScansPreset; }
- (void) setMcaNofScansPreset:(unsigned long)aMcaNofScansPreset
{
    [[[self undoManager] prepareWithInvocationTarget:self] setMcaNofScansPreset:mcaNofScansPreset];
    mcaNofScansPreset = aMcaNofScansPreset;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelMcaNofScansPresetChanged object:self];
}

- (BOOL) mcaAutoClear { return mcaAutoClear; }
- (void) setMcaAutoClear:(BOOL)aMcaAutoClear
{
    [[[self undoManager] prepareWithInvocationTarget:self] setMcaAutoClear:mcaAutoClear];
    mcaAutoClear = aMcaAutoClear;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelMcaAutoClearChanged object:self];
}

- (unsigned long) mcaPrescaleFactor { return mcaPrescaleFactor; }
- (void) setMcaPrescaleFactor:(unsigned long)aMcaPrescaleFactor
{
    [[[self undoManager] prepareWithInvocationTarget:self] setMcaPrescaleFactor:mcaPrescaleFactor];
    mcaPrescaleFactor = aMcaPrescaleFactor;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelMcaPrescaleFactorChanged object:self];
}

- (BOOL) mcaLNESetup { return mcaLNESetup; }
- (void) setMcaLNESetup:(BOOL)aMcaLNESetup
{
    [[[self undoManager] prepareWithInvocationTarget:self] setMcaLNESetup:mcaLNESetup];
    mcaLNESetup = aMcaLNESetup;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelMcaLNESetupChanged object:self];
}

- (unsigned long) mcaNofHistoPreset { return mcaNofHistoPreset; }
- (void) setMcaNofHistoPreset:(unsigned long)aMcaNofHistoPreset
{
    [[[self undoManager] prepareWithInvocationTarget:self] setMcaNofHistoPreset:mcaNofHistoPreset];
    mcaNofHistoPreset = aMcaNofHistoPreset;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelMcaNofHistoPresetChanged object:self];
}

- (BOOL) internalExternalTriggersOred { return internalExternalTriggersOred; }
- (void) setInternalExternalTriggersOred:(BOOL)aInternalExternalTriggersOred
{
    [[[self undoManager] prepareWithInvocationTarget:self] setInternalExternalTriggersOred:internalExternalTriggersOred];
    internalExternalTriggersOred = aInternalExternalTriggersOred;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelInternalExternalTriggersOredChanged object:self];
}

- (unsigned short) lemoInEnabledMask { return lemoInEnabledMask; }
- (void) setLemoInEnabledMask:(unsigned short)aMask
{
    [[[self undoManager] prepareWithInvocationTarget:self] setLemoInEnabledMask:lemoInEnabledMask];
    lemoInEnabledMask = aMask;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelLemoInEnabledMaskChanged object:self];
}

- (BOOL) lemoInEnabled:(unsigned short)aBit { return lemoInEnabledMask & (1<<aBit); }
- (void) setLemoInEnabled:(unsigned short)aBit withValue:(BOOL)aState
{
	unsigned short aMask = [self lemoInEnabledMask];
	if(aState)	aMask |= (1<<aBit);
	else		aMask &= ~(1<<aBit);
	[self setLemoInEnabledMask:aMask];
}

- (int) runMode { return runMode; }
- (void) setRunMode:(int)aRunMode
{
    [[[self undoManager] prepareWithInvocationTarget:self] setRunMode:runMode];
    runMode = aRunMode;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelRunModeChanged object:self];
	[self calculateSampleValues];
}

- (int) endAddressThreshold { return endAddressThreshold; }
- (void) setEndAddressThreshold:(int)aEndAddressThreshold
{
    [[[self undoManager] prepareWithInvocationTarget:self] setEndAddressThreshold:endAddressThreshold];
    endAddressThreshold = aEndAddressThreshold;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelEndAddressThresholdChanged object:self];
}

- (int) energySampleStartIndex3 { return energySampleStartIndex3; }
- (void) setEnergySampleStartIndex3:(int)aEnergySampleStartIndex3
{
    [[[self undoManager] prepareWithInvocationTarget:self] setEnergySampleStartIndex3:energySampleStartIndex3];
    energySampleStartIndex3 = aEnergySampleStartIndex3;
	[self calculateSampleValues];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelEnergySampleStartIndex3Changed object:self];
	[self calculateEnergyGateLength];
}

- (int) energySampleStartIndex2 { return energySampleStartIndex2; }
- (void) setEnergySampleStartIndex2:(int)aEnergySampleStartIndex2
{
    [[[self undoManager] prepareWithInvocationTarget:self] setEnergySampleStartIndex2:energySampleStartIndex2];
    energySampleStartIndex2 = aEnergySampleStartIndex2;
	[self calculateSampleValues];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelEnergySampleStartIndex2Changed object:self];
	[self calculateEnergyGateLength];
}

- (int) energySampleStartIndex1 { return energySampleStartIndex1; }
- (void) setEnergySampleStartIndex1:(int)aEnergySampleStartIndex1
{
    [[[self undoManager] prepareWithInvocationTarget:self] setEnergySampleStartIndex1:energySampleStartIndex1];
    energySampleStartIndex1 = aEnergySampleStartIndex1;
	[self calculateSampleValues];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelEnergySampleStartIndex1Changed object:self];
	[self calculateEnergyGateLength];
}

- (int) energySampleLength { return energySampleLength; }
- (void) setEnergySampleLength:(int)aEnergySampleLength
{
    [[[self undoManager] prepareWithInvocationTarget:self] setEnergySampleLength:energySampleLength];
    energySampleLength = [self limitIntValue:aEnergySampleLength min:0 max:kSIS3302MaxEnergyWaveform];
	[self calculateSampleValues];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelEnergySampleLengthChanged object:self];
	[self calculateEnergyGateLength];
}

- (int) energyTauFactor:(short)aChannel 
{ 
	if(aChannel>=8)return 0; 
	return [[energyTauFactors objectAtIndex:aChannel] intValue];
}
- (void) setEnergyTauFactor:(short)aChannel withValue:(int)aValue
{
	if(aChannel>=8)return; 
    [[[self undoManager] prepareWithInvocationTarget:self] setEnergyTauFactor:aChannel withValue:[self energyTauFactor:aChannel]];
    int energyTauFactor = [self limitIntValue:aValue min:0 max:0x3f];
	[energyTauFactors replaceObjectAtIndex:aChannel withObject:[NSNumber numberWithInt:energyTauFactor]];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelEnergyTauFactorChanged object:self];
}
- (int) energyGapTime:(short)aGroup 
{ 
	if(aGroup>=4)return 0; 
	return [[energyGapTimes objectAtIndex:aGroup] intValue]; 
}
- (void) setEnergyGapTime:(short)aGroup withValue:(int)aValue
{
	if(aGroup>=4)return; 
    [[[self undoManager] prepareWithInvocationTarget:self] setEnergyGapTime:aGroup withValue:[self energyGapTime:aGroup]];
    aValue = [self limitIntValue:aValue min:0 max:0xff];
	[energyGapTimes replaceObjectAtIndex:aGroup withObject:[NSNumber numberWithInt:aValue]];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelEnergyGapTimeChanged object:self];
	[self calculateEnergyGateLength];
}

- (int) energyPeakingTime:(short)aGroup 
{ 
	if(aGroup>=4)return 0; 
	return [[energyPeakingTimes objectAtIndex:aGroup] intValue]; 
}
- (void) setEnergyPeakingTime:(short)aGroup withValue:(int)aValue
{
	if(aGroup>=4)return; 
    [[[self undoManager] prepareWithInvocationTarget:self] setEnergyPeakingTime:aGroup withValue:[self energyPeakingTime:aGroup]];
    int energyPeakingTime = [self limitIntValue:aValue min:0 max:0x3ff];
	[energyPeakingTimes replaceObjectAtIndex:aGroup withObject:[NSNumber numberWithInt:energyPeakingTime]];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelEnergyPeakingTimeChanged object:self];
	[self calculateEnergyGateLength];
}

- (int) energyGateLength:(short)aGroup 
{ 
	if(aGroup>=4)return 0; 
	return [[energyGateLengths objectAtIndex:aGroup] intValue]; 
}
- (void) setEnergyGateLength:(short)aGroup withValue:(int)aEnergyGateLength
{
	if(aGroup>=4)return; 
    [[[self undoManager] prepareWithInvocationTarget:self] setEnergyGateLength:aGroup withValue:[self energyGateLength:aGroup]];
	[energyGateLengths replaceObjectAtIndex:aGroup withObject:[NSNumber numberWithInt:aEnergyGateLength]];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelEnergyGateLengthChanged object:self];
}

- (int) triggerGateLength:(short)aGroup 
{
	if(aGroup>=4)return 0; 
	return [[triggerGateLengths objectAtIndex:aGroup] intValue]; 
}
- (void) setTriggerGateLength:(short)aGroup withValue:(int)aTriggerGateLength
{
	if(aGroup>=4)return; 
    [[[self undoManager] prepareWithInvocationTarget:self] setTriggerGateLength:aGroup withValue:[self triggerGateLength:aGroup]];
	if (aTriggerGateLength < [self sampleLength:aGroup]) aTriggerGateLength = [self sampleLength:aGroup];
    int triggerGateLength = [self limitIntValue:aTriggerGateLength min:0 max:65535];
	[triggerGateLengths replaceObjectAtIndex:aGroup withObject:[NSNumber numberWithInt:triggerGateLength]];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelTriggerGateLengthChanged object:self];
}

- (int) preTriggerDelay:(short)aGroup 
{ 
	if(aGroup>=4)return 0; 
	return [[preTriggerDelays objectAtIndex:aGroup]intValue]; 
}
- (void) setPreTriggerDelay:(short)aGroup withValue:(int)aPreTriggerDelay
{
	if(aGroup>=4)return; 
    [[[self undoManager] prepareWithInvocationTarget:self] setPreTriggerDelay:aGroup withValue:[self preTriggerDelay:aGroup]];
    int preTriggerDelay = [self limitIntValue:aPreTriggerDelay min:0 max:1023];
	[preTriggerDelays replaceObjectAtIndex:aGroup withObject:[NSNumber numberWithInt:preTriggerDelay]];

    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelPreTriggerDelayChanged object:self];
	[self calculateEnergyGateLength];
}

- (int) sampleStartIndex:(int)aGroup 
{ 
	if(aGroup>=4)return 0; 
	return [[sampleStartIndexes objectAtIndex:aGroup] intValue];
}
- (void) setSampleStartIndex:(int)aGroup withValue:(unsigned short)aSampleStartIndex
{
	if(aGroup>=4)return; 
    [[[self undoManager] prepareWithInvocationTarget:self] setSampleStartIndex:aGroup withValue:[self sampleStartIndex:aGroup]];
    int sampleStartIndex = aSampleStartIndex & 0xfffe;
	[sampleStartIndexes replaceObjectAtIndex:aGroup withObject:[NSNumber numberWithInt:sampleStartIndex]];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302SampleStartIndexChanged object:self];
}

- (short) lemoInMode { return lemoInMode; }
- (void) setLemoInMode:(short)aLemoInMode
{
    [[[self undoManager] prepareWithInvocationTarget:self] setLemoInMode:lemoInMode];
    lemoInMode = aLemoInMode;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302LemoInModeChanged object:self];
}

- (NSString*) lemoInAssignments
{
	if(runMode == kEnergyRunMode){
		if(lemoInMode == 0)      return @"3:Trigger\n2:TimeStamp Clr\n1:Veto";
		else if(lemoInMode == 1) return @"3:Trigger\n2:TimeStamp Clr\n1:Gate";
		else if(lemoInMode == 2) return @"3:Reserved\n2:Reserved\n1:Reserved";
		else if(lemoInMode == 3) return @"3:Reserved\n2:Reserved\n1:Reserved";
		else if(lemoInMode == 4) return @"3:N+1 Trig/Gate In\n2:Trigger\n1:N-1 Trig/Gate In";
		else if(lemoInMode == 5) return @"3:N+1 Trig/Gate In\n2:TimeStamp Clr\n1:N-1 Trig/Gate In";
		else if(lemoInMode == 6) return @"3:N+1 Trig/Gate In\n2:Veto\n1:N-1 Trig/Gate In";
		else if(lemoInMode == 7) return @"3:N+1 Trig/Gate In\n2:Gate\n1:N-1 Trig/Gate In";
		else return @"Undefined";
	} 
	else {
		if(lemoInMode == 0)      return @"3:Reserved\n2:Ext MCA Start\n1:Ext Next Pulse";
		else if(lemoInMode == 1) return @"3:Trigger\n2:Ext MCA Start\n1:Ext Next Pulse";
		else if(lemoInMode == 2) return @"3:Veto\n2:Ext MCA Start\n1:Ext Next Pulse";
		else if(lemoInMode == 3) return @"3:Gate\n2:Ext MCA Start\n1:Ext Next Pulse";
		else if(lemoInMode == 4) return @"3:Reserved\n2:Reserved\n1:Reserved";
		else if(lemoInMode == 5) return @"3:Reserved\n2:Reserved\n1:Reserved";
		else if(lemoInMode == 6) return @"3:Reserved\n2:Reserved\n1:Reserved";
		else if(lemoInMode == 7) return @"3:Reserved\n2:Reserved\n1:Reserved";
		else return @"Undefined";
	}
}

- (short) lemoOutMode { return lemoOutMode; }
- (void) setLemoOutMode:(short)aLemoOutMode
{
    [[[self undoManager] prepareWithInvocationTarget:self] setLemoOutMode:lemoOutMode];
    lemoOutMode = aLemoOutMode;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302LemoOutModeChanged object:self];
}
- (NSString*) lemoOutAssignments
{
	if(runMode == kEnergyRunMode){
		if(lemoOutMode == 0)      return @"3:Sample logic armed\n2:Busy\n1:Trigger output";
		else if(lemoOutMode == 1) return @"3:Sample logic armed\n2:Busy or Veto\n1:Trigger output";
		else if(lemoOutMode == 2) return @"3:N+1 Trig/Gate Out\n2:Trigger output\n1:N-1 Trig/Gate Out";
		else if(lemoOutMode == 3) return @"3:N+1 Trig/Gate Out\n2:Busy or Veto\n1:N-1 Trig/Gate Out";
		else return @"Undefined";
	} 
	else {
		if(lemoOutMode == 0)      return @"3:Sample logic armed\n2:Busy\n1:Trigger output";
		else if(lemoOutMode == 1) return @"3:First Scan Signal\n2:LNE\n1:Scan Enable";
		else if(lemoOutMode == 2) return @"3:Scan Enable\n2:LNE\n1:Trigger Output";
		else if(lemoOutMode == 3) return @"3:Reserved\n2:Reserved\n1:Reserved";
		else return @"Undefined";
	}
}

- (void) setDefaults
{
	[self setRunMode:kEnergyRunMode];
	int i;
	for(i=0;i<8;i++){
		[self setThreshold:i withValue:0x64];
		[self setPeakingTime:i withValue:250];
		[self setSumG:i withValue:263];
		[self setInternalTriggerDelay:i withValue:0];
		[self setDacOffset:i withValue:30000];
	}
	for(i=0;i<4;i++){
		[self setSampleLength:i withValue:2048];
		[self setPreTriggerDelay:i withValue:0];
		[self setTriggerGateLength:i withValue:50000];
		[self setTriggerDecimation:i withValue:0];
		[self setEnergyDecimation:i withValue:0];
		[self setSampleStartIndex:i withValue:0];
		[self setEnergyPeakingTime:i withValue:100];
		[self setEnergyGapTime:i withValue:25];
	}
	
	[self setShipEnergyWaveform:NO];
	[self setGtMask:0xff];
	[self setTriggerOutEnabledMask:0x0];
	[self setInputInvertedMask:0x0];
	[self setAdc50KTriggerEnabledMask:0x00];
	[self setInternalGateEnabledMask:0xff];
	[self setExternalGateEnabledMask:0x00];
	[self setExtendedThresholdEnabledMask:0x00];
	
	[self setInternalTriggerEnabledMask:0xff];
	[self setExternalTriggerEnabledMask:0x0];
	
}

- (int) clockSource
{
    return clockSource;
}

- (void) setClockSource:(int)aClockSource
{
    [[[self undoManager] prepareWithInvocationTarget:self] setClockSource:clockSource];
    clockSource = aClockSource;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ClockSourceChanged object:self];
}

- (ORRateGroup*) waveFormRateGroup
{
    return waveFormRateGroup;
}

- (void) setWaveFormRateGroup:(ORRateGroup*)newRateGroup
{
    [newRateGroup retain];
    [waveFormRateGroup release];
    waveFormRateGroup = newRateGroup;
    
    [[NSNotificationCenter defaultCenter]
	 postNotificationName:ORSIS3302RateGroupChangedNotification
	 object:self];    
}

- (id) rateObject:(int)channel
{
    return [waveFormRateGroup rateObject:channel];
}

- (void) initParams
{
	[self setUpArrays];
	[self setDefaults];
}

- (void) setRateIntegrationTime:(double)newIntegrationTime
{
	//we this here so we have undo/redo on the rate object.
    [[[self undoManager] prepareWithInvocationTarget:self] setRateIntegrationTime:[waveFormRateGroup integrationTime]];
    [waveFormRateGroup setIntegrationTime:newIntegrationTime];
}

#pragma mark •••Rates
- (unsigned long) getCounter:(int)counterTag forGroup:(int)groupTag
{
	if(groupTag == 0){
		if(counterTag>=0 && counterTag<kNumSIS3302Channels){
			return waveFormCount[counterTag];
		}	
		else return 0;
	}
	else return 0;
}


- (short) internalTriggerEnabledMask { return internalTriggerEnabledMask; }
- (void) setInternalTriggerEnabledMask:(short)aMask
{
	[[[self undoManager] prepareWithInvocationTarget:self] setInternalTriggerEnabledMask:internalTriggerEnabledMask];
	internalTriggerEnabledMask = aMask;
	[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302InternalTriggerEnabledChanged object:self];
}

- (BOOL) internalTriggerEnabled:(short)chan { return internalTriggerEnabledMask & (1<<chan); }
- (void) setInternalTriggerEnabled:(short)chan withValue:(BOOL)aValue
{
	unsigned char aMask = internalTriggerEnabledMask;
	if(aValue)aMask |= (1<<chan);
	else aMask &= ~(1<<chan);
	[self setInternalTriggerEnabledMask:aMask];
}

- (short) externalTriggerEnabledMask { return externalTriggerEnabledMask; }
- (void) setExternalTriggerEnabledMask:(short)aMask
{
	[[[self undoManager] prepareWithInvocationTarget:self] setExternalTriggerEnabledMask:externalTriggerEnabledMask];
	externalTriggerEnabledMask = aMask;
	[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ExternalTriggerEnabledChanged object:self];
}

- (BOOL) externalTriggerEnabled:(short)chan { return externalTriggerEnabledMask & (1<<chan); }
- (void) setExternalTriggerEnabled:(short)chan withValue:(BOOL)aValue
{
	unsigned char aMask = externalTriggerEnabledMask;
	if(aValue)aMask |= (1<<chan);
	else aMask &= ~(1<<chan);
	[self setExternalTriggerEnabledMask:aMask];
}

- (short) internalGateEnabledMask { return internalGateEnabledMask; }
- (void) setInternalGateEnabledMask:(short)aMask
{
	[[[self undoManager] prepareWithInvocationTarget:self] setInternalGateEnabledMask:internalGateEnabledMask];
	internalGateEnabledMask = aMask;
	[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302InternalGateEnabledChanged object:self];
}

- (BOOL) internalGateEnabled:(short)chan { return internalGateEnabledMask & (1<<chan); }
- (void) setInternalGateEnabled:(short)chan withValue:(BOOL)aValue
{
	unsigned char aMask = internalGateEnabledMask;
	if(aValue)aMask |= (1<<chan);
	else aMask &= ~(1<<chan);
	[self setInternalGateEnabledMask:aMask];
}

- (short) externalGateEnabledMask { return externalGateEnabledMask; }
- (void) setExternalGateEnabledMask:(short)aMask
{
	[[[self undoManager] prepareWithInvocationTarget:self] setExternalGateEnabledMask:externalGateEnabledMask];
	externalGateEnabledMask = aMask;
	[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ExternalGateEnabledChanged object:self];
}

- (BOOL) externalGateEnabled:(short)chan { return externalGateEnabledMask & (1<<chan); }
- (void) setExternalGateEnabled:(short)chan withValue:(BOOL)aValue
{
	unsigned char aMask = externalGateEnabledMask;
	if(aValue)aMask |= (1<<chan);
	else aMask &= ~(1<<chan);
	[self setExternalGateEnabledMask:aMask];
}

- (short) extendedThresholdEnabledMask { return extendedThresholdEnabledMask; }
- (void) setExtendedThresholdEnabledMask:(short)aMask
{
	[[[self undoManager] prepareWithInvocationTarget:self] setExtendedThresholdEnabledMask:extendedThresholdEnabledMask];
	extendedThresholdEnabledMask = aMask;
	[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ExtendedThresholdEnabledChanged object:self];
}

- (BOOL) extendedThresholdEnabled:(short)chan { return extendedThresholdEnabledMask & (1<<chan); }
- (void) setExtendedThresholdEnabled:(short)chan withValue:(BOOL)aValue
{
	unsigned char aMask = extendedThresholdEnabledMask;
	if(aValue)aMask |= (1<<chan);
	else aMask &= ~(1<<chan);
	[self setExtendedThresholdEnabledMask:aMask];
}


- (short) inputInvertedMask { return inputInvertedMask; }
- (void) setInputInvertedMask:(short)aMask
{
	[[[self undoManager] prepareWithInvocationTarget:self] setInputInvertedMask:inputInvertedMask];
	inputInvertedMask = aMask;
	[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302InputInvertedChanged object:self];
}

- (BOOL) inputInverted:(short)chan { return inputInvertedMask & (1<<chan); }
- (void) setInputInverted:(short)chan withValue:(BOOL)aValue
{
	unsigned char aMask = inputInvertedMask;
	if(aValue)aMask |= (1<<chan);
	else aMask &= ~(1<<chan);
	[self setInputInvertedMask:aMask];
}


- (short) triggerOutEnabledMask { return triggerOutEnabledMask; }
- (void) setTriggerOutEnabledMask:(short)aMask	
{ 
	[[[self undoManager] prepareWithInvocationTarget:self] setTriggerOutEnabledMask:triggerOutEnabledMask];
	triggerOutEnabledMask = aMask;
	[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302TriggerOutEnabledChanged object:self];
}

- (BOOL) triggerOutEnabled:(short)chan { return triggerOutEnabledMask & (1<<chan); }
- (void) setTriggerOutEnabled:(short)chan withValue:(BOOL)aValue		
{ 
	unsigned char aMask = triggerOutEnabledMask;
	if(aValue)aMask |= (1<<chan);
	else aMask &= ~(1<<chan);
	[self setTriggerOutEnabledMask:aMask];
}

- (short) adc50KTriggerEnabledMask { return adc50KTriggerEnabledMask; }

- (void) setAdc50KTriggerEnabledMask:(short)aMask
{
	[[[self undoManager] prepareWithInvocationTarget:self] setAdc50KTriggerEnabledMask:adc50KTriggerEnabledMask];
	adc50KTriggerEnabledMask = aMask;
	[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302Adc50KTriggerEnabledChanged object:self];
}

- (BOOL) adc50KTriggerEnabled:(short)chan { return adc50KTriggerEnabledMask & (1<<chan); }
- (void) setAdc50KTriggerEnabled:(short)chan withValue:(BOOL)aValue
{
	unsigned char aMask = adc50KTriggerEnabledMask;
	if(aValue)aMask |= (1<<chan);
	else aMask &= ~(1<<chan);
	[self setAdc50KTriggerEnabledMask:aMask];
}

- (BOOL) shipEnergyWaveform { return shipEnergyWaveform;}
- (void) setShipEnergyWaveform:(BOOL)aState
{ 
	[[[self undoManager] prepareWithInvocationTarget:self] setShipEnergyWaveform:shipEnergyWaveform];
	shipEnergyWaveform = aState;
	[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302SetShipWaveformChanged object:self];
	if (!shipEnergyWaveform) {
		[self setEnergySampleLength:0];		
	} else {
		[self setEnergySampleLength:kSIS3302MaxEnergyWaveform];
		// The following forces the start indices to calculate automatically.
		// This could avoid some confusion about the special cases of 
		// start indices 2 and 3 being 0.  This forces them to be
		// at least span the max sample length.  (There's a check 
		// in calculateSampleValues.)
		[self setEnergySampleStartIndex2:1];
	}

}

- (short) gtMask { return gtMask; }
- (BOOL) gt:(short)chan	 { return gtMask & (1<<chan); }
- (void) setGtMask:(long)aMask	
{ 
	[[[self undoManager] prepareWithInvocationTarget:self] setGtMask:gtMask];
	gtMask = aMask;
	[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302GtChanged object:self];
}

- (void) setGtBit:(short)chan withValue:(BOOL)aValue		
{ 
	unsigned char aMask = gtMask;
	if(aValue)aMask |= (1<<chan);
	else aMask &= ~(1<<chan);
	[self setGtMask:aMask];
}

- (int) limitIntValue:(int)aValue min:(int)aMin max:(int)aMax
{
	if(aValue<aMin)return aMin;
	else if(aValue>aMax)return aMax;
	else return aValue;
}

- (int) threshold:(short)aChan { return [[thresholds objectAtIndex:aChan]intValue]; }
- (void) setThreshold:(short)aChan withValue:(int)aValue 
{ 
	aValue = [self limitIntValue:aValue min:0 max:0x1FFFF];
    [[[self undoManager] prepareWithInvocationTarget:self] setThreshold:aChan withValue:[self threshold:aChan]];
    [thresholds replaceObjectAtIndex:aChan withObject:[NSNumber numberWithInt:aValue]];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ThresholdChanged object:self];
	//ORAdcInfoProviding protocol requirement
	[self postAdcInfoProvidingValueChanged];
}

//ORAdcInfoProviding protocol requirement
- (unsigned short) gain:(unsigned short) aChan
{
    return 0;
}
- (void) setGain:(unsigned short) aChan withValue:(unsigned short) aGain
{
}
- (BOOL) partOfEvent:(unsigned short)chan
{
	return (gtMask & (1L<<chan)) != 0;
}
- (BOOL)onlineMaskBit:(int)bit
{
	//translate back to the triggerEnabled Bit
	return (gtMask & (1L<<bit)) != 0;
}

- (unsigned short) sampleLength:(short)aChan { return [[sampleLengths objectAtIndex:aChan]unsignedShortValue]; }
- (void) setSampleLength:(short)aChan withValue:(int)aValue 
{
    [[[self undoManager] prepareWithInvocationTarget:self] setSampleLength:aChan withValue:[self sampleLength:aChan]];
    [sampleLengths replaceObjectAtIndex:aChan withObject:[NSNumber numberWithInt:aValue & 0xfffc]];
	[self calculateSampleValues];
	[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302SampleLengthChanged object:self];
}

- (unsigned short) dacOffset:(short)aChan { return [[dacOffsets objectAtIndex:aChan]intValue]; }
- (void) setDacOffset:(short)aChan withValue:(int)aValue 
{
	aValue = [self limitIntValue:aValue min:0 max:0xffff];
    [[[self undoManager] prepareWithInvocationTarget:self] setDacOffset:aChan withValue:[self dacOffset:aChan]];
    [dacOffsets replaceObjectAtIndex:aChan withObject:[NSNumber numberWithInt:aValue]];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302DacOffsetChanged object:self];
}

- (short) gateLength:(short)aChan { return [[gateLengths objectAtIndex:aChan] shortValue]; }
- (void) setGateLength:(short)aChan withValue:(short)aValue 
{ 
	aValue = [self limitIntValue:aValue min:0 max:0x3f];
    [[[self undoManager] prepareWithInvocationTarget:self] setGateLength:aChan withValue:[self gateLength:aChan]];
    [gateLengths replaceObjectAtIndex:aChan withObject:[NSNumber numberWithInt:aValue]];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302GateLengthChanged object:self];
}

- (short) pulseLength:(short)aChan { return [[pulseLengths objectAtIndex:aChan] shortValue]; }
- (void) setPulseLength:(short)aChan withValue:(short)aValue 
{ 
	aValue = [self limitIntValue:aValue min:0 max:0xff];
    [[[self undoManager] prepareWithInvocationTarget:self] setPulseLength:aChan withValue:[self pulseLength:aChan]];
    [pulseLengths replaceObjectAtIndex:aChan withObject:[NSNumber numberWithInt:aValue]];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302PulseLengthChanged object:self];
}

- (short) sumG:(short)aChan { return [[sumGs objectAtIndex:aChan] shortValue]; }
- (void) setSumG:(short)aChan withValue:(short)aValue 
{ 
	short temp = [self peakingTime:aChan];
	aValue = [self limitIntValue:aValue min:0 max:0x3ff];
    [[[self undoManager] prepareWithInvocationTarget:self] setSumG:aChan withValue:[self sumG:aChan]];
	if (aValue < temp) aValue = temp;
    [sumGs replaceObjectAtIndex:aChan withObject:[NSNumber numberWithInt:aValue]];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302SumGChanged object:self];
}

- (short) peakingTime:(short)aChan { return [[peakingTimes objectAtIndex:aChan] shortValue]; }
- (void) setPeakingTime:(short)aChan withValue:(short)aValue 
{ 
	short temp = [self sumG:aChan];
	aValue = [self limitIntValue:aValue min:0 max:0x3ff];
    [[[self undoManager] prepareWithInvocationTarget:self] setPeakingTime:aChan withValue:[self peakingTime:aChan]];
	if (temp < aValue) [self setSumG:aChan withValue:aValue];
    [peakingTimes replaceObjectAtIndex:aChan withObject:[NSNumber numberWithInt:aValue]];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302PeakingTimeChanged object:self];
}


- (short) internalTriggerDelay:(short)aChan { return [[internalTriggerDelays objectAtIndex:aChan] shortValue]; }
- (void) setInternalTriggerDelay:(short)aChan withValue:(short)aValue 
{ 
	aValue = [self limitIntValue:aValue min:0 max:0x1f];
    [[[self undoManager] prepareWithInvocationTarget:self] setInternalTriggerDelay:aChan withValue:[self internalTriggerDelay:aChan]];
    [internalTriggerDelays replaceObjectAtIndex:aChan withObject:[NSNumber numberWithInt:aValue]];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302InternalTriggerDelayChanged object:self];
}

- (short) energyDecimation:(short)aGroup 
{ 
	if(aGroup>=4)return 0; 
	return [[energyDecimations objectAtIndex:aGroup] intValue]; 
}
- (void) setEnergyDecimation:(short)aGroup withValue:(short)aValue 
{ 
 	if(aGroup>=4)return; 
	[[[self undoManager] prepareWithInvocationTarget:self] setEnergyDecimation:aGroup withValue:[self energyDecimation:aGroup]];
    int energyDecimation = [self limitIntValue:aValue min:0 max:0x3];
	[energyDecimations replaceObjectAtIndex:aGroup withObject:[NSNumber numberWithInt:energyDecimation]];
	[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302EnergyDecimationChanged object:self];
	[self calculateEnergyGateLength];
}

- (int) triggerDecimation:(short)aGroup 
{ 
	if(aGroup>=4)return 0; 
	return [[triggerDecimations objectAtIndex:aGroup] intValue]; 
}
- (void) setTriggerDecimation:(short)aGroup withValue:(short)aValue 
{ 
	if(aGroup>=4)return; 
    [[[self undoManager] prepareWithInvocationTarget:self] setTriggerDecimation:aGroup withValue:[self triggerDecimation:aGroup]];
    int triggerDecimation = [self limitIntValue:aValue min:0 max:0x3];
	[triggerDecimations replaceObjectAtIndex:aGroup withObject:[NSNumber numberWithInt:triggerDecimation]];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302TriggerDecimationChanged object:self];
}

- (void) calculateSampleValues
{
	unsigned long aValue = 0;
	if(runMode == kMcaRunMode)   return;
	else {
		numEnergyValues = energySampleLength;   

		if(numEnergyValues > kSIS3302MaxEnergyWaveform){
			// This should never be happen in the current implementation since we 
			// handle this value internally, but checking nonetheless in case 
			// in the future we modify this.  
			NSLogColor([NSColor redColor],@"Number of energy values is to high (max = %d) ; actual = %d \n",
					   kSIS3302MaxEnergyWaveform, numEnergyValues);
			NSLogColor([NSColor redColor],@"Value forced to %d\n", kSIS3302MaxEnergyWaveform);
			numEnergyValues = kSIS3302MaxEnergyWaveform;
			[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelEnergySampleLengthChanged object:self];
		}

		int group;
		for(group=0;group<4;group++){
			numRawDataLongWords = ([self sampleLength:group]>>1);
			rawDataIndex  = 2 ;
			
			energyIndex    = 2 + numRawDataLongWords ;
			energyMaxIndex = 2 + numEnergyValues + numRawDataLongWords ;
			
			eventLengthLongWords = 2 + 4  ; // Timestamp/Header, MAX, MIN, Trigger-FLags, Trailer
			eventLengthLongWords = eventLengthLongWords + numRawDataLongWords/2  ;  
			eventLengthLongWords = eventLengthLongWords + numEnergyValues  ;   

			[self setEndAddressThreshold:eventLengthLongWords];
			// Check the sample indices
			// Don't call setEnergy* from in here!  Cause stack overflow...
			if (numEnergyValues == 0) {
				// Set all indices to 0
				energySampleStartIndex1 = 1;
				energySampleStartIndex2 = 0;
				energySampleStartIndex3 = 0;
				[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelEnergySampleStartIndex1Changed object:self];
				[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelEnergySampleStartIndex2Changed object:self];
				[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelEnergySampleStartIndex3Changed object:self];
			} 
			else if (energySampleStartIndex2 != 0 || energySampleStartIndex3 != 0) {
				// Means we are requesting different pieces of the waveform.
				// Make sure they are correct.
				if (energySampleStartIndex2 < energySampleStartIndex1 + energySampleLength/3 + 1) {
					aValue = energySampleLength/3 + energySampleStartIndex1 + 1;
					energySampleStartIndex2 = aValue;
					[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelEnergySampleStartIndex2Changed object:self];
					if (energySampleStartIndex3 == 0) {
						// This forces us to also reset the third index if it is set to 0.
						energySampleStartIndex3 = 0;
					}
				}
				
				if (energySampleStartIndex2 == 0 && energySampleStartIndex3 != 0) {
					energySampleStartIndex3 = 0;
				} 
				else if (energySampleStartIndex2 != 0 && 
						   energySampleStartIndex3 < energySampleStartIndex2 + energySampleLength/3 + 1) {
					aValue = energySampleLength/3 + energySampleStartIndex2 + 1;
					energySampleStartIndex3 = aValue;
					[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302ModelEnergySampleStartIndex3Changed object:self];
				}
			}
			
			// Finally check the trigger gate length to make sure it is big enough
			if ([self triggerGateLength:group] < [self sampleLength:group]) {
				[self setTriggerGateLength:group withValue:[self sampleLength:group]];
			}
		}
	}
}

- (void) calculateEnergyGateLength
{
	// Make sure the gate is set appropriately.
	// The Pre-trigger and and Trigger Gate are both in
	// 100 MHz clock ticks, but everything else is in 
	// Decimation clock ticks.  Convert this down to the correct
	// decimation.
	int group;
	for(group=0;group<4;group++){
		int preTriggerDelay = [self preTriggerDelay:group];
		unsigned int delayInDecimationClockTicks = preTriggerDelay >> [self energyDecimation:group];
		unsigned int temp = 0;
		unsigned int temptwo = 0;
		if (energySampleLength == 0) {
			// Means that we are not shipping an energy waveform.
			// Make sure the gate length is long enough
			[self setEnergyGateLength:group withValue:(delayInDecimationClockTicks +
													   2*[self energyPeakingTime:group] +
													   [self energyGapTime:group] + 20)]; // Add the 20 ticks for safety
		} 
		else {
			// We are shipping an energy waveform, we require the waveform to be at least:
			temp = delayInDecimationClockTicks + 
				   energySampleStartIndex3 + 
				   energySampleLength/3 + 20;
			temptwo = delayInDecimationClockTicks +
					  2*[self energyPeakingTime:group] +
						[self energyGapTime:group] + 20;
			// Take the larger of the two.
			if (temp > temptwo ) {
				[self setEnergyGateLength:group withValue:temp];
			} 
			else {
				[self setEnergyGateLength:group withValue:temptwo];			
			}
		}
	}
}

#pragma mark •••Hardware Access
- (void) readModuleID:(BOOL)verbose
{	
	unsigned long result = 0;
	[[self adapter] readLongBlock:&result
                         atAddress:[self baseAddress] + kSIS3302ModID
                        numToRead:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
	unsigned long moduleID = result >> 16;
	unsigned short majorRev = (result >> 8) & 0xff;
	unsigned short minorRev = result & 0xff;
	if(verbose)NSLog(@"SIS3302 ID: %x  Firmware:%x.%x\n",moduleID,majorRev,minorRev);
	
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302IDChanged object:self];
}

- (void) writeAcquistionRegister
{
	// The register is set up as a J/K flip/flop -- 1 bit to set a function and 1 bit to disable.	
	unsigned long aMask = 0x0;
	BOOL inMcaMode = (runMode == kMcaRunMode);
	aMask |= ((clockSource & 0x7)<< 12);
	aMask |= (lemoInEnabledMask & 0x7) << 8;
	aMask |= internalExternalTriggersOred << 6;
	aMask |= (lemoOutMode & 0x3) << 4;
	aMask |= (inMcaMode&0x1)       << 3;
	aMask |= (lemoInMode & 0x7)  << 0;
	
	//put the inverse in the top bits to turn off everything else
	aMask = ((~aMask & 0x0000ffff)<<16) | aMask;
	
	[[self adapter] writeLongBlock:&aMask
                         atAddress:[self baseAddress] + kSIS3302AcquisitionControl
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}


- (void) setLed:(BOOL)state
{
	unsigned long aValue = CSRMask(state,kSISLed);
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kSIS3302ControlStatus
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) forceTrigger
{
	unsigned long aValue = 0;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kSIS3302KeyTrigger
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) clearTimeStamp
{
	unsigned long aValue = 0;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kSIS3302KeyTimestampClear
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (unsigned long) acqReg
{
 	unsigned long aValue = 0;
	[[self adapter] readLongBlock:&aValue
						atAddress:[self baseAddress] + kSIS3302AcquisitionControl
                        numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];
	return aValue;
}

- (void) writeThresholds
{   
	ORCommandList* aList = [ORCommandList commandList];
	int i;
	unsigned long thresholdMask;
	for(i = 0; i < kNumSIS3302Channels; i++) {
		thresholdMask = 0;
		BOOL enabled   = [self triggerOutEnabled:i];
		BOOL gtEnabled = [self gt:i];
		if(!enabled)	thresholdMask |= (1<<26); //logic is inverted on the hw
		if(gtEnabled)	thresholdMask |= (1<<25);
		if([self extendedThresholdEnabled:i])	thresholdMask |= (1<<23);
		
		thresholdMask |= ([self threshold:i] & 0xffff)+ 0x10000;
		
		[aList addCommand: [ORVmeReadWriteCommand writeLongBlock: &thresholdMask
													   atAddress: [self baseAddress] + [self getThresholdRegOffsets:i]
													   numToWrite: 1
													  withAddMod: [self addressModifier]
												   usingAddSpace: 0x01]];
		if([self extendedThresholdEnabled:i]){
			unsigned long aThresholdValue = [self threshold:i]+0x2000000;
			[aList addCommand: [ORVmeReadWriteCommand writeLongBlock: &aThresholdValue
														   atAddress: [self baseAddress] + [self getExtendedThresholdRegOffsets:i]
														  numToWrite: 1
														  withAddMod: [self addressModifier]
													   usingAddSpace: 0x01]];
		}
		
		
	}
	[self executeCommandList:aList];
}

- (void) writeEventConfiguration
{
	//******the extern/internal gates seem to have an inverted logic, so the extern/internal gate matrixes in IB are swapped.
	int i;
	unsigned long tempIntGateMask  = internalGateEnabledMask;
	unsigned long tempExtGateMask  = externalGateEnabledMask;
	ORCommandList* aList = [ORCommandList commandList];
	for(i=0;i<kNumSIS3302Channels/2;i++){
		unsigned long aValueMask = 0x0;
		aValueMask |= ((internalTriggerEnabledMask & (1<<(i*2)))!=0)     << 2;
		aValueMask |= ((internalTriggerEnabledMask & (1<<((i*2)+1)))!=0) << 10;
		
		aValueMask |= ((externalTriggerEnabledMask & (1<<(i*2)))!=0)     << 3;
		aValueMask |= ((externalTriggerEnabledMask & (1<<((i*2)+1)))!=0) << 11;
	
		aValueMask |= ((tempIntGateMask & (1<<(i*2)))!=0)       << 4;
		aValueMask |= ((tempIntGateMask & (1<<((i*2)+1)))!=0)   << 12;
		
		aValueMask |= ((tempExtGateMask & (1<<(i*2)))!=0)       << 5;
		aValueMask |= ((tempExtGateMask & (1<<((i*2)+1)))!=0)   << 13;
		
		aValueMask |= ((inputInvertedMask & (1<<(i*2)))!=0)       << 0;
		aValueMask |= ((inputInvertedMask & (1<<((i*2)+1)))!=0)   << 8;
				
		[aList addCommand: [ORVmeReadWriteCommand writeLongBlock: &aValueMask
													   atAddress: [self baseAddress] + [self getEventConfigOffsets:i]
													  numToWrite: 1
													  withAddMod: [self addressModifier]
												   usingAddSpace: 0x01]];
	}
	//extended event config reg
	for(i=0;i<kNumSIS3302Channels/2;i++){
		unsigned long aValueMask = 0x0;
		aValueMask |= ((adc50KTriggerEnabledMask & (1<<i*2))!=0)      << 0;
		aValueMask |= ((adc50KTriggerEnabledMask & (1<<((i*2)+1)))!=0)<< 8;
		[aList addCommand: [ORVmeReadWriteCommand writeLongBlock: &aValueMask
													   atAddress: [self baseAddress] + [self getExtendedEventConfigOffsets:i]
													  numToWrite: 1
													  withAddMod: [self addressModifier]
												   usingAddSpace: 0x01]];
	}
	[self executeCommandList:aList];
	
}

- (void) writePreTriggerDelayAndTriggerGateDelay
{
	int i;
	for(i=0;i<kNumSIS3302Channels/2;i++){
		unsigned long aValue = (([self preTriggerDelay:i]&0x01ff)<<16) | [self triggerGateLength:i];
		[[self adapter] writeLongBlock:&aValue
							 atAddress:[self baseAddress] + [self getPreTriggerDelayTriggerGateLengthOffset:i]
							numToWrite:1
							withAddMod:[self addressModifier]
						usingAddSpace:0x01];
	}	
}

- (void) writeEnergyGP
{
	int i;
	for(i=0;i<kNumSIS3302Channels/2;i++){
		unsigned long peakingTimeHi = ([self energyPeakingTime:i] >> 8) & 0x3;
		unsigned long peakingTimeLo = [self energyPeakingTime:i] & 0xff; 
		
		unsigned long aValueMask = (([self energyDecimation:i]  & 0x3)<<28) | 
									(peakingTimeHi <<16)				   | 
									(([self energyGapTime:i]     & 0xff)<<8) | 
									peakingTimeLo;
		
		[[self adapter] writeLongBlock:&aValueMask
							 atAddress:[self baseAddress] + [self getEnergySetupGPOffset:i]
							numToWrite:1
							withAddMod:[self addressModifier]
						 usingAddSpace:0x01];
	}
	
	[self resetSamplingLogic];
}

- (void) writeEndAddressThreshold
{
	unsigned long aValue = 0x1c0;//endAddressThreshold;
	[[self adapter] writeLongBlock:&aValue
						 atAddress:[self baseAddress] + kSIS3302EndAddressThresholdAllAdc
						numToWrite:1
						withAddMod:[self addressModifier]
					 usingAddSpace:0x01];
}

- (void) writeEnergyGateLength
{
	int group;
	for(group=0;group<4;group++){
		unsigned long aValue = [self energyGateLength:group];
		[[self adapter] writeLongBlock:&aValue
							 atAddress:[self baseAddress] + [self getEnergyGateLengthOffsets:group]
							numToWrite:1
							withAddMod:[self addressModifier]
						 usingAddSpace:0x01];
	}
}

- (void) writeEnergyTauFactor
{
	int i;
	for(i=0;i<8;i++){
		unsigned long 	aValue = [self energyTauFactor:i];
		[[self adapter] writeLongBlock:&aValue
							 atAddress:[self baseAddress] + [self getEnergyTauFactorOffset:i]
							numToWrite:1
							withAddMod:[self addressModifier]
						 usingAddSpace:0x01];
	
	}
}

- (void) writeEnergySampleLength
{
	unsigned long aValue = energySampleLength;
	if (energySampleStartIndex2 != 0 || energySampleStartIndex3 != 0) {
		// This means we have multiple registers, divide by three.
		aValue /= 3;
	}
	[[self adapter] writeLongBlock:&aValue
						 atAddress:[self baseAddress] + kSIS3302EnergySampleLengthAllAdc
						numToWrite:1
						withAddMod:[self addressModifier]
					 usingAddSpace:0x01];
}

- (void) writeEnergySampleStartIndexes
{	
	unsigned long aValue = energySampleStartIndex1;
	[[self adapter] writeLongBlock:&aValue
						 atAddress:[self baseAddress] + kSIS3302EnergySampleStartIndex1AllAdc
						numToWrite:1
						withAddMod:[self addressModifier]
					 usingAddSpace:0x01];
	
	aValue = energySampleStartIndex2;
	[[self adapter] writeLongBlock:&aValue
						 atAddress:[self baseAddress] + kSIS3302EnergySampleStartIndex2AllAdc
						numToWrite:1
						withAddMod:[self addressModifier]
					 usingAddSpace:0x01];
	
	aValue = energySampleStartIndex3;
	[[self adapter] writeLongBlock:&aValue
						 atAddress:[self baseAddress] + kSIS3302EnergySampleStartIndex3AllAdc
						numToWrite:1
						withAddMod:[self addressModifier]
					 usingAddSpace:0x01];
	
}
	
- (void) writeTriggerSetups
{
	int i;
	int group;
	for(i = 0; i < 8; i++) {
		group = i/2;
		unsigned long aExtValueMask = (([self internalTriggerDelay:i] & 0x00ffL) << 24) | 
									  (([self triggerDecimation:group]      & 0x0003L) << 16) | 
									  (([self sumG:i]                 & 0x0F00L)) | 
									  (([self peakingTime:i]          & 0x0F00L) >> 8);
		
		[[self adapter] writeLongBlock:&aExtValueMask
							 atAddress:[self baseAddress] + [self getTriggerExtSetupRegOffsets:i]
							numToWrite:1
							withAddMod:[self addressModifier]
						 usingAddSpace:0x01];
		
		unsigned long aTriggerMask =(([self gateLength:i]  & 0xffL) << 24) | 
									(([self pulseLength:i] & 0xffL) << 16) | 
									(([self sumG:i]        & 0xffL) <<  8) | 
									 ([self peakingTime:i] & 0xffL);
		
		[[self adapter] writeLongBlock:&aTriggerMask
							 atAddress:[self baseAddress] + [self getTriggerSetupRegOffsets:i]
							numToWrite:1
							withAddMod:[self addressModifier]
						 usingAddSpace:0x01];
	}
}

- (void) writeRawDataBufferConfiguration
{	
	int group;
	for(group=0;group<4;group++){
		unsigned long sampleLength	   = [self sampleLength:group];
		unsigned long sampleStartIndex = [self sampleStartIndex:group];
		unsigned long aValueMask = ((sampleLength & 0xfffc)<<16) | (sampleStartIndex & 0xfffe);
	
		[[self adapter] writeLongBlock:&aValueMask
							 atAddress:[self baseAddress] + [self getRawDataBufferConfigOffsets:group]
							numToWrite:1
							withAddMod:[self addressModifier]
						 usingAddSpace:0x01];
	}
}

- (void) readThresholds:(BOOL)verbose
{   
	int i;
	if(verbose) NSLog(@"Reading Thresholds:\n");
	
	for(i =0; i < kNumSIS3302Channels; i++) {
		unsigned long aValue;
		[[self adapter] readLongBlock: &aValue
							atAddress: [self baseAddress] + [self getThresholdRegOffsets:i]
							numToRead: 1
						   withAddMod: [self addressModifier]
						usingAddSpace: 0x01];
		
		if(verbose){
			unsigned short thresh = (aValue&0xffff);
			BOOL triggerDisabled  = (aValue>>26) & 0x1;
			BOOL triggerModeGT    = (aValue>>25) & 0x1;
			NSLog(@"%d: %8s %2s 0x%4x\n",i, triggerDisabled ? "Trig Out Disabled": "Trig Out Enabled",  triggerModeGT?"GT":"  " ,thresh);
		}
	}
}

- (void) writeMcaLNESetupAndPrescalFactor
{
	
	unsigned long aValue = ((mcaLNESetup & 0x3)<<28) | (mcaPrescaleFactor & 0x0ffffff);
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kSIS3302McaScanSetupPrescaleFactor
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) writeMcaScanControl
{
	
	unsigned long aValue = (mcaScanBank2Flag<<4) | !mcaAutoClear;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kSIS3302McaScanControl
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}


- (void) writeMcaNofHistoPreset
{
	[[self adapter] writeLongBlock:&mcaNofHistoPreset
                         atAddress:[self baseAddress] + kSIS3302McaScanNumOfHistogramsPreset
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) writeMcaLNEPulse
{
	unsigned long aValue= 0;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kSIS3302KeyMcaScanLnePulse
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) writeMcaArm
{
	unsigned long aValue= 0;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kSIS3302KeyMcaScanArm
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) writeMcaScanEnable
{
	unsigned long aValue= 0;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kSIS3302KeyMcaScanStart
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) writeMcaScanDisable
{
	unsigned long aValue= 0;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kSIS3302KeyMcaScanStop
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) writeMcaMultiScanStartReset
{
	unsigned long aValue= 0;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kSIS3302KeyMcaMultiScanStartResetPulse
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) writeMcaMultiScanArmScanArm
{
	unsigned long aValue= 0;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kSIS3302KeyMcaMultiScanArmScanArm
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) writeMcaMultiScanArmScanEnable
{
	unsigned long aValue= 0;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kSIS3302KeyMcaMultiScanArmScanEnable
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) writeMcaMultiScanDisable
{
	unsigned long aValue= 0;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kSIS3302KeyMcaMultiScanDisable
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) writeMcaMultiScanNofScansPreset
{
	unsigned long aValue= mcaNofScansPreset;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kSIS3302McaMultiScanNumOfScansPreset
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}


- (void) writeMcaArmMode
{
	unsigned long addrOffset = 0;
	switch (mcaMode) {
		case 0: addrOffset = kSIS3302KeyMcaScanStart;				break;
		case 1: addrOffset = kSIS3302KeyMcaScanArm;					break;
		case 2: addrOffset = kSIS3302KeyMcaMultiScanArmScanEnable;	break;
		case 3: addrOffset = kSIS3302KeyMcaMultiScanArmScanArm;		break;
	}
	
	if(addrOffset!=0){
		unsigned long aValue= 0;
		[[self adapter] writeLongBlock:&aValue
							 atAddress:[self baseAddress] + addrOffset
							numToWrite:1
							withAddMod:[self addressModifier]
						 usingAddSpace:0x01];
	}
}	


- (void) writeMcaCalculationFactors
{   
	unsigned long calculationParm;
	if(!mcaUseEnergyCalculation){
		calculationParm = ((long)mcaEnergyDivider<<28) | ((long)mcaEnergyMultiplier<<20) | ((long)mcaEnergyOffset);
	}
	else {
		//defaults
		switch(mcaHistoSize) {
			case 0: calculationParm = 0x68000000; break;	// 16bit value -> 1K
			case 1: calculationParm = 0x58000000; break;	// 16bit value -> 2K
			case 2: calculationParm = 0x48000000; break;	// 16bit value -> 4K
			case 3: calculationParm = 0x38000000; break;	// 16bit value -> 8K histo
		} 
	}
	
	[[self adapter] writeLongBlock:&calculationParm
						 atAddress:[self baseAddress] + kSIS3302McaEnergy2HistogramParamAdc1357
						numToWrite:1
						withAddMod:[self addressModifier]
					 usingAddSpace:0x01];	
	
	[[self adapter] writeLongBlock:&calculationParm
						 atAddress:[self baseAddress] + kSIS3302McaEnergy2HistogramParamAdc2468
						numToWrite:1
						withAddMod:[self addressModifier]
					 usingAddSpace:0x01];	
}

- (void) regDump
{
	@try {
		NSFont* font = [NSFont fontWithName:@"Monaco" size:11];
		NSLogFont(font,@"Reg Dump for SIS3302 (Slot %d)\n",[self slot]);
		NSLogFont(font,@"-----------------------------------\n");
		NSLogFont(font,@"[Add Offset]   Value        Name\n");
		NSLogFont(font,@"-----------------------------------\n");
		
		ORCommandList* aList = [ORCommandList commandList];
		int i;
		for(i=0;i<kNumSIS3302ReadRegs;i++){
			[aList addCommand: [ORVmeReadWriteCommand readLongBlockAtAddress: [self baseAddress] + register_information[i].offset
																   numToRead: 1
																  withAddMod: [self addressModifier]
															   usingAddSpace: 0x01]];
		}
		[self executeCommandList:aList];
		
		//if we get here, the results can retrieved in the same order as sent
		for(i=0;i<kNumSIS3302ReadRegs;i++){
			NSLogFont(font, @"[0x%08x] 0x%08x    %@\n",register_information[i].offset,[aList longValueForCmd:i],register_information[i].name);
		}

	}
	@catch(NSException* localException) {
        NSLog(@"SIS3302 Reg Dump FAILED.\n");
        NSRunAlertPanel([localException name], @"%@\nSIS3302 Reg Dump FAILED", @"OK", nil, nil,
                        localException);
    }
}

- (void) briefReport
{
	[self readThresholds:YES];
	
	unsigned long EventConfig = 0;
	[[self adapter] readLongBlock:&EventConfig
						atAddress:[self baseAddress] +kSIS3302EventConfigAdc12
						numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];	
	NSLog(@"EventConfig: 0x%08x\n",EventConfig);
	
	unsigned long pretrigger = 0;
	[[self adapter] readLongBlock:&pretrigger
						atAddress:[self baseAddress] + kSIS3302PreTriggerDelayTriggerGateLengthAdc12
						numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];	
	
	NSLog(@"pretrigger: 0x%08x\n",pretrigger);
	
	unsigned long rawDataBufferConfig = 0;
	[[self adapter] readLongBlock:&rawDataBufferConfig
						atAddress:[self baseAddress] + kSIS3302RawDataBufferConfigAdc12
						numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];	
	
	NSLog(@"rawDataBufferConfig: 0x%08x\n",rawDataBufferConfig);
	
	unsigned long actualNextSampleAddress1 = 0;
	[[self adapter] readLongBlock:&actualNextSampleAddress1
						atAddress:[self baseAddress] + kSIS3302ActualSampleAddressAdc1
						numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];	
	
	NSLog(@"actualNextSampleAddress1: 0x%08x\n",actualNextSampleAddress1);
	
	unsigned long actualNextSampleAddress2 = 0;
	[[self adapter] readLongBlock:&actualNextSampleAddress2
						atAddress:[self baseAddress] + kSIS3302ActualSampleAddressAdc2
						numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];	
	
	NSLog(@"actualNextSampleAddress2: 0x%08x\n",actualNextSampleAddress2);
	
	unsigned long prevNextSampleAddress1 = 0;
	[[self adapter] readLongBlock:&prevNextSampleAddress1
						atAddress:[self baseAddress] + kSIS3302PreviousBankSampleAddressAdc1
						numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];	
	
	NSLog(@"prevNextSampleAddress1: 0x%08x\n",prevNextSampleAddress1);
	
	unsigned long prevNextSampleAddress2 = 0;
	[[self adapter] readLongBlock:&prevNextSampleAddress2
						atAddress:[self baseAddress] + kSIS3302PreviousBankSampleAddressAdc2
						numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];	
	
	NSLog(@"prevNextSampleAddress2: 0x%08x\n",prevNextSampleAddress2);
	
	unsigned long triggerSetup1 = 0;
	[[self adapter] readLongBlock:&triggerSetup1
						atAddress:[self baseAddress] + kSIS3302TriggerSetupAdc1
						numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];	
	
	NSLog(@"triggerSetup1: 0x%08x\n",triggerSetup1);
	
	unsigned long triggerSetup2 = 0;
	[[self adapter] readLongBlock:&triggerSetup2
						atAddress:[self baseAddress] + kSIS3302TriggerSetupAdc2
						numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];	
	
	NSLog(@"triggerSetup2: 0x%08x\n",triggerSetup2);
	
	unsigned long energySetupGP = 0;
	[[self adapter] readLongBlock:&energySetupGP
						atAddress:[self baseAddress] + kSIS3302EnergySetupGPAdc12
						numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];	
	
	NSLog(@"energySetupGP: 0x%08x\n",energySetupGP);
	
	unsigned long EnergyGateLen = 0;
	[[self adapter] readLongBlock:&EnergyGateLen
						atAddress:[self baseAddress] + kSIS3302EnergyGateLengthAdc12
						numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];	
	
	NSLog(@"EnergyGateLen: 0x%08x\n",EnergyGateLen);
	
	unsigned long EnergySampleLen = 0;
	[[self adapter] readLongBlock:&EnergySampleLen
						atAddress:[self baseAddress] + kSIS3302EnergySampleLengthAdc12
						numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];	
	
	NSLog(@"EnergySampleLen: 0x%08x\n",EnergySampleLen);
	
	unsigned long EnergySampleStartIndex = 0;
	[[self adapter] readLongBlock:&EnergySampleStartIndex
						atAddress:[self baseAddress] + kSIS3302EnergySampleStartIndex1Adc12
						numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];	
	
	NSLog(@"EnergySampleStartIndex: 0x%08x\n",EnergySampleStartIndex);
}


- (void) readMcaStatus
{
	static unsigned long mcaStatusAddress[kNumMcaStatusRequests] = {
		//order is important here....
		kSIS3302AcquisitionControl,
		kSIS3302McaScanHistogramCounter,
		kSIS3302McaMultiScanScanCounter,
		
		kSIS3302McaTriggerStartCounterAdc1,
		kSIS3302McaPileupCounterAdc1,
		kSIS3302McaEnergy2LowCounterAdc1,
		kSIS3302McaEnergy2HighCounterAdc1,
		
		kSIS3302McaTriggerStartCounterAdc2,
		kSIS3302McaPileupCounterAdc2,
		kSIS3302McaEnergy2LowCounterAdc2,
		kSIS3302McaEnergy2HighCounterAdc2,
		
		kSIS3302McaTriggerStartCounterAdc3,
		kSIS3302McaPileupCounterAdc3,
		kSIS3302McaEnergy2LowCounterAdc3,
		kSIS3302McaEnergy2HighCounterAdc3,

		kSIS3302McaTriggerStartCounterAdc4,
		kSIS3302McaPileupCounterAdc4,
		kSIS3302McaEnergy2LowCounterAdc4,
		kSIS3302McaEnergy2HighCounterAdc4,
		
		kSIS3302McaTriggerStartCounterAdc5,
		kSIS3302McaPileupCounterAdc5,
		kSIS3302McaEnergy2LowCounterAdc5,
		kSIS3302McaEnergy2HighCounterAdc5,
		
		kSIS3302McaTriggerStartCounterAdc6,
		kSIS3302McaPileupCounterAdc6,
		kSIS3302McaEnergy2LowCounterAdc6,
		kSIS3302McaEnergy2HighCounterAdc6,
		
		kSIS3302McaTriggerStartCounterAdc7,
		kSIS3302McaPileupCounterAdc7,
		kSIS3302McaEnergy2LowCounterAdc7,
		kSIS3302McaEnergy2HighCounterAdc7,
		
		kSIS3302McaTriggerStartCounterAdc8,
		kSIS3302McaPileupCounterAdc8,
		kSIS3302McaEnergy2LowCounterAdc8,
		kSIS3302McaEnergy2HighCounterAdc8
		//order is important here....
	};
	
	ORCommandList* aList = [ORCommandList commandList];
	int i;
	for(i=0;i<kNumMcaStatusRequests;i++){
		[aList addCommand: [ORVmeReadWriteCommand readLongBlockAtAddress: [self baseAddress] + mcaStatusAddress[i]
															   numToRead: 1
															  withAddMod: [self addressModifier]
														   usingAddSpace: 0x01]];
	}
	[self executeCommandList:aList];
	
	//if we get here, the results can retrieved in the same order as sent
	for(i=0;i<kNumMcaStatusRequests;i++){
		mcaStatusResults[i] = [aList longValueForCmd:i];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3302McaStatusChanged object:self];
} 

- (unsigned long) mcaStatusResult:(int)index
{
	if(index>=0 && index<kNumMcaStatusRequests){
		return mcaStatusResults[index];
	}
	else return 0;
}

- (void) executeCommandList:(ORCommandList*) aList
{
	[[self adapter] executeCommandList:aList];
}
	
- (void) initBoard
{  
	[self writeEventConfiguration];
	[self writeEndAddressThreshold];
	[self writePreTriggerDelayAndTriggerGateDelay];
	[self writeEnergyGateLength];
	[self writeEnergyGP];
	[self writeEnergyTauFactor];
	[self writeRawDataBufferConfiguration];
	[self writeEnergySampleLength];
	[self writeEnergySampleStartIndexes];
	[self writeTriggerSetups];
	[self writeThresholds];
	[self writeDacOffsets];
	[self resetSamplingLogic];
	
	if(runMode == kMcaRunMode){
		[self writeHistogramParams];
		[self writeMcaScanControl];
		[self writeMcaNofHistoPreset];
		[self writeMcaLNESetupAndPrescalFactor];
		[self writeMcaNofHistoPreset];
		[self writeMcaLNESetupAndPrescalFactor];
		[self writeMcaMultiScanNofScansPreset];
		[self writeMcaCalculationFactors];
	}
	[self writeAcquistionRegister];			//set up the Acquisition Register
	
	if([gOrcaGlobals runInProgress]){
		if(runMode == kMcaRunMode){
			[self writeMcaArmMode];
		}
		//else {
		//	[self disarmAndArmBank:0];
		//}
	}
}

- (unsigned long) getPreviousBankSampleRegisterOffset:(int) channel 
{
    switch (channel) {
        case 0: return kSIS3302PreviousBankSampleAddressAdc1;
        case 1: return kSIS3302PreviousBankSampleAddressAdc2;
        case 2: return kSIS3302PreviousBankSampleAddressAdc3;
        case 3: return kSIS3302PreviousBankSampleAddressAdc4;
        case 4: return kSIS3302PreviousBankSampleAddressAdc5;
        case 5: return kSIS3302PreviousBankSampleAddressAdc6;
        case 6: return kSIS3302PreviousBankSampleAddressAdc7;
        case 7: return kSIS3302PreviousBankSampleAddressAdc8;
    }
    return (unsigned long)-1;
}

- (unsigned long) getEnergyTauFactorOffset:(int) channel 
{
    switch (channel) {
        case 0: return kSIS3302EnergyTauFactorAdc1;
        case 1: return kSIS3302EnergyTauFactorAdc2;
        case 2: return kSIS3302EnergyTauFactorAdc3;
        case 3: return kSIS3302EnergyTauFactorAdc4;
        case 4: return kSIS3302EnergyTauFactorAdc5;
        case 5: return kSIS3302EnergyTauFactorAdc6;
        case 6: return kSIS3302EnergyTauFactorAdc7;
        case 7: return kSIS3302EnergyTauFactorAdc8;
    }
    return (unsigned long)-1;
}

- (unsigned long) getPreTriggerDelayTriggerGateLengthOffset:(int) aGroup 
{
    switch (aGroup) {
        case 0: return kSIS3302PreTriggerDelayTriggerGateLengthAdc12;
        case 1: return kSIS3302PreTriggerDelayTriggerGateLengthAdc34;
        case 2: return kSIS3302PreTriggerDelayTriggerGateLengthAdc56;
        case 3: return kSIS3302PreTriggerDelayTriggerGateLengthAdc78;
    }
    return (unsigned long)-1;
}

- (unsigned long) getADCBufferRegisterOffset:(int) channel 
{
    switch (channel) {
        case 0: return kSIS3302Adc1Offset;
        case 1: return kSIS3302Adc2Offset;
        case 2: return kSIS3302Adc3Offset;
        case 3: return kSIS3302Adc4Offset;
        case 4: return kSIS3302Adc5Offset;
        case 5: return kSIS3302Adc6Offset;
        case 6: return kSIS3302Adc7Offset;
        case 7: return kSIS3302Adc8Offset;
    }
    return (unsigned long) -1;
}

#pragma mark •••Static Declarations
- (unsigned long) getThresholdRegOffsets:(int) channel 
{
    switch (channel) {
        case 0: return 	kSIS3302TriggerThresholdAdc1;
		case 1: return 	kSIS3302TriggerThresholdAdc2;
		case 2: return 	kSIS3302TriggerThresholdAdc3;
		case 3: return 	kSIS3302TriggerThresholdAdc4;
		case 4:	return 	kSIS3302TriggerThresholdAdc5;
		case 5: return 	kSIS3302TriggerThresholdAdc6;
		case 6: return 	kSIS3302TriggerThresholdAdc7;
		case 7: return 	kSIS3302TriggerThresholdAdc8;
    }
    return (unsigned long) -1;
}

- (unsigned long) getExtendedThresholdRegOffsets:(int) channel 
{
    switch (channel) {
        case 0: return 	kSIS3302TriggerExtendedThresholdAdc1;
		case 1: return 	kSIS3302TriggerExtendedThresholdAdc2;
		case 2: return 	kSIS3302TriggerExtendedThresholdAdc3;
		case 3: return 	kSIS3302TriggerExtendedThresholdAdc4;
		case 4:	return 	kSIS3302TriggerExtendedThresholdAdc5;
		case 5: return 	kSIS3302TriggerExtendedThresholdAdc6;
		case 6: return 	kSIS3302TriggerExtendedThresholdAdc7;
		case 7: return 	kSIS3302TriggerExtendedThresholdAdc8;
    }
    return (unsigned long) -1;
}




- (unsigned long) getTriggerSetupRegOffsets:(int) channel 
{
    switch (channel) {
		case 0: return 	kSIS3302TriggerSetupAdc1;
		case 1: return 	kSIS3302TriggerSetupAdc2;
		case 2: return 	kSIS3302TriggerSetupAdc3;
		case 3: return 	kSIS3302TriggerSetupAdc4;
		case 4: return 	kSIS3302TriggerSetupAdc5;
		case 5: return 	kSIS3302TriggerSetupAdc6;
		case 6: return 	kSIS3302TriggerSetupAdc7;
		case 7: return 	kSIS3302TriggerSetupAdc8;
    }
    return (unsigned long) -1;
}

- (unsigned long) getTriggerExtSetupRegOffsets:(int)channel
{
    switch (channel) {	
		case 0: return 	kSIS3302TriggerExtendedSetupAdc1;
		case 1: return 	kSIS3302TriggerExtendedSetupAdc2;
		case 2: return 	kSIS3302TriggerExtendedSetupAdc3;
		case 3: return 	kSIS3302TriggerExtendedSetupAdc4;
		case 4: return 	kSIS3302TriggerExtendedSetupAdc5;
		case 5: return 	kSIS3302TriggerExtendedSetupAdc6;
		case 6: return 	kSIS3302TriggerExtendedSetupAdc7;
		case 7: return 	kSIS3302TriggerExtendedSetupAdc8;
	}
    return (unsigned long) -1;	
}


- (unsigned long) getEndThresholdRegOffsets:(int)group
{
	switch (group) {	
		case 0: return 	 kSIS3302EndAddressThresholdAdc12;
		case 1: return 	 kSIS3302EndAddressThresholdAdc34;
		case 2: return 	 kSIS3302EndAddressThresholdAdc56;
		case 3: return 	 kSIS3302EndAddressThresholdAdc78;
	}
	return (unsigned long) -1;	 
}

- (unsigned long) getRawDataBufferConfigOffsets:(int) channel 
{
    switch (channel) {
        case 0: return kSIS3302RawDataBufferConfigAdc12;
        case 1: return kSIS3302RawDataBufferConfigAdc34;
        case 2: return kSIS3302RawDataBufferConfigAdc56;
        case 3: return kSIS3302RawDataBufferConfigAdc78;
    }
    return (unsigned long)-1;
}

- (unsigned long) getSampleAddress:(int)channel
{
    switch (channel) {
		case 0: return 	kSIS3302ActualSampleAddressAdc1;
		case 1: return 	kSIS3302ActualSampleAddressAdc2;
		case 2: return 	kSIS3302ActualSampleAddressAdc3;
		case 3: return 	kSIS3302ActualSampleAddressAdc4;
		case 4: return 	kSIS3302ActualSampleAddressAdc5;
		case 5: return 	kSIS3302ActualSampleAddressAdc6;
		case 6: return 	kSIS3302ActualSampleAddressAdc7;
		case 7: return 	kSIS3302ActualSampleAddressAdc8;
 	}
	return (unsigned long) -1;	 
}
		 
- (unsigned long) getEventConfigOffsets:(int)group
{
	 switch (group) {
		 case 0: return kSIS3302EventConfigAdc12;
		 case 1: return kSIS3302EventConfigAdc34;
		 case 2: return kSIS3302EventConfigAdc56;
		 case 3: return kSIS3302EventConfigAdc78;
	 }
	return (unsigned long) -1;	 
}
	
- (unsigned long) getEnergyGateLengthOffsets:(int)group
{
	switch (group) {
		case 0: return kSIS3302EnergyGateLengthAdc12;
		case 1: return kSIS3302EnergyGateLengthAdc34;
		case 2: return kSIS3302EnergyGateLengthAdc56;
		case 3: return kSIS3302EnergyGateLengthAdc78;
	}
	return (unsigned long) -1;	 
}

- (unsigned long) getExtendedEventConfigOffsets:(int)group
{
	switch (group) {
		case 0: return kSIS3302EventExtendedConfigAdc12;
		case 1: return kSIS3302EventExtendedConfigAdc34;
		case 2: return kSIS3302EventExtendedConfigAdc56;
		case 3: return kSIS3302EventExtendedConfigAdc78;
	}
	return (unsigned long) -1;	 
}
		 
- (unsigned long) getAdcMemory:(int)channel
{
    switch (channel) {			
		case 0: return 	kSIS3302Adc1Offset;
		case 1: return 	kSIS3302Adc2Offset;
		case 2: return 	kSIS3302Adc3Offset;
		case 3: return 	kSIS3302Adc4Offset;
		case 4: return 	kSIS3302Adc5Offset;
		case 5: return 	kSIS3302Adc6Offset;
		case 6: return 	kSIS3302Adc7Offset;
		case 7: return 	kSIS3302Adc8Offset;
 	}
   return (unsigned long) -1;	 
}

- (unsigned long) getEnergySetupGPOffset:(int)group
{
	switch (group) {
		case 0: return kSIS3302EnergySetupGPAdc12;
		case 1: return kSIS3302EnergySetupGPAdc34;
		case 2: return kSIS3302EnergySetupGPAdc56;
		case 3: return kSIS3302EnergySetupGPAdc78;
	}
	return (unsigned long) -1;	 
}

- (BOOL) isEvent
{
	unsigned long data_rd = 0;
	[[self adapter] readLongBlock:&data_rd
						atAddress:[self baseAddress] + kSIS3302AcquisitionControl
						numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];

	if ((data_rd & 0x80000) != 0x80000)return NO;
	else return YES;
}

- (void) disarmSampleLogic
{
	unsigned long aValue = 0;
	[[self adapter] writeLongBlock:&aValue
						 atAddress:[self baseAddress] + kSIS3302KeyDisarm
						numToWrite:1
						withAddMod:[self addressModifier]
					 usingAddSpace:0x01];
}

- (void) disarmAndArmBank:(int) bank 
{
    if (bank==0) bankOneArmed = YES;
    else		 bankOneArmed = NO;
	
    unsigned long addr = [self baseAddress] + ((bank == 0) ? kSIS3302KeyDisarmAndArmBank1 : kSIS3302KeyDisarmAndArmBank2);
	unsigned long aValue= 0;
	[[self adapter] writeLongBlock:&aValue
						atAddress:addr
						numToWrite:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];	
}

- (void) disarmAndArmNextBank
{ 
	return (bankOneArmed) ? [self disarmAndArmBank:1] : [self disarmAndArmBank:0]; 
}

- (void) writePageRegister:(int) aPage 
{	
	unsigned long aValue = aPage & 0xf;
	[[self adapter] writeLongBlock:&aValue
						 atAddress:[self baseAddress] + kSIS3302AdcMemoryPageRegister
						numToWrite:1
						withAddMod:[self addressModifier]
					 usingAddSpace:0x01];	
}

- (NSString*) runSummary
{
	NSString* summary;
	if(runMode == kMcaRunMode){
		return @"MCA Spectrum";
	}
	else {
		BOOL tracesShipped = ([self sampleLength:0] || [self sampleLength:1] || [self sampleLength:2] || [self sampleLength:3]);
		summary = @"Energy";
		if(tracesShipped) summary = [summary stringByAppendingString:@" + Traces"];
		if(shipEnergyWaveform) summary = [summary stringByAppendingString:@" + Energy Filter"];
		summary = [summary stringByAppendingString:@"\n"];
		if(tracesShipped){
			summary = [summary stringByAppendingFormat:@"Traces 0:%d  1:%d  2:%d  3:%d\n", [self sampleLength:0],[self sampleLength:1],[self sampleLength:2],[self sampleLength:3]];
		}
		if(shipEnergyWaveform) summary = [summary stringByAppendingFormat:@"Energy Filter: 510 values\n"];
		return summary;
	}
}

- (void) writeHistogramParams
{
	unsigned long aValue =   kSIS3302McaEnable2468 | kSIS3302McaEnable1357 | (mcaPileupEnabled << 3) + mcaHistoSize;
	[[self adapter] writeLongBlock:&aValue
						 atAddress:[self baseAddress] + kSIS3302McaHistogramParamAllAdc
						numToWrite:1
						withAddMod:[self addressModifier]
					 usingAddSpace:0x01];	
}


#pragma mark •••Data Taker
- (unsigned long) mcaId { return mcaId; }
- (void) setMcaId: (unsigned long) anId
{
    mcaId = anId;
}

- (unsigned long) dataId { return dataId; }
- (void) setDataId: (unsigned long) DataId
{
    dataId = DataId;
}
- (void) setDataIds:(id)assigner
{
    dataId   = [assigner assignDataIds:kLongForm];
    mcaId    = [assigner assignDataIds:kLongForm]; 
}

- (void) syncDataIdsWith:(id)anotherCard
{
    [self setDataId:[anotherCard dataId]];
    [self setMcaId:[anotherCard mcaId]];
}

- (NSDictionary*) dataRecordDescription
{
    NSMutableDictionary* dataDictionary = [NSMutableDictionary dictionary];
	NSDictionary* aDictionary;
    aDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"ORSIS3302DecoderForEnergy",				@"decoder",
						   [NSNumber numberWithLong:dataId],@"dataId",
						   [NSNumber numberWithBool:YES],   @"variable",
						   [NSNumber numberWithLong:-1],	@"length",
						   nil];
    [dataDictionary setObject:aDictionary forKey:@"Energy"];
	
	aDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"ORSIS3302DecoderForMca",			@"decoder",
						   [NSNumber numberWithLong:mcaId], @"dataId",
						   [NSNumber numberWithBool:YES],   @"variable",
						   [NSNumber numberWithLong:-1],	@"length",
						   nil];
    [dataDictionary setObject:aDictionary forKey:@"MCA"];
	
    return dataDictionary;
}

#pragma mark •••HW Wizard
-(BOOL) hasParmetersToRamp
{
	return YES;
}
- (int) numberOfChannels
{
    return kNumSIS3302Channels;
}

- (NSArray*) wizardParameters
{
    NSMutableArray* a = [NSMutableArray array];
    ORHWWizParam* p;
  	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Run Mode"];
    [p setFormat:@"##0" upperLimit:1 lowerLimit:0 stepSize:1 units:@"BOOL"];
    [p setSetMethod:@selector(setRunMode:withValue:) getMethod:@selector(runMode:)];
    [a addObject:p];
	
	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Extra Time Record"];
    [p setFormat:@"##0" upperLimit:1 lowerLimit:0 stepSize:1 units:@"BOOL"];
    [p setSetMethod:@selector(setShipTimeRecordAlso:) getMethod:@selector(shipTimeRecordAlso)];
    [a addObject:p];
	
	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"GT"];
    [p setFormat:@"##0" upperLimit:1 lowerLimit:0 stepSize:1 units:@"BOOL"];
    [p setSetMethod:@selector(setGtBit:withValue:) getMethod:@selector(gt:)];
    [a addObject:p];

	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"ADC50K Trigger"];
    [p setFormat:@"##0" upperLimit:1 lowerLimit:0 stepSize:1 units:@"BOOL"];
    [p setSetMethod:@selector(setAdc50KTriggerEnabled:withValue:) getMethod:@selector(adc50KTriggerEnabled:)];
    [a addObject:p];

	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Input Inverted"];
    [p setFormat:@"##0" upperLimit:1 lowerLimit:0 stepSize:1 units:@"BOOL"];
    [p setSetMethod:@selector(setInputInverted:withValue:) getMethod:@selector(inputInverted:)];
    [a addObject:p];

	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Internal Trigger Enable"];
    [p setFormat:@"##0" upperLimit:1 lowerLimit:0 stepSize:1 units:@"BOOL"];
    [p setSetMethod:@selector(setInternalTriggerEnabled:withValue:) getMethod:@selector(internalTriggerEnabled:)];
    [a addObject:p];

	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"External Trigger Enable"];
    [p setFormat:@"##0" upperLimit:1 lowerLimit:0 stepSize:1 units:@"BOOL"];
    [p setSetMethod:@selector(setExternalTriggerEnabled:withValue:) getMethod:@selector(externalTriggerEnabled:)];
    [a addObject:p];
	
	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Internal Gate Enable"];
    [p setFormat:@"##0" upperLimit:1 lowerLimit:0 stepSize:1 units:@"BOOL"];
    [p setSetMethod:@selector(setInternalGateEnabled:withValue:) getMethod:@selector(internalGateEnabled:)];
    [a addObject:p];
	
	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"External Gate Enable"];
    [p setFormat:@"##0" upperLimit:1 lowerLimit:0 stepSize:1 units:@"BOOL"];
    [p setSetMethod:@selector(setExternalGateEnabled:withValue:) getMethod:@selector(externalGateEnabled:)];
    [a addObject:p];

	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Extended Threshold Enable"];
    [p setFormat:@"##0" upperLimit:1 lowerLimit:0 stepSize:1 units:@"BOOL"];
    [p setSetMethod:@selector(setExtendedThresholdEnabled:withValue:) getMethod:@selector(extendedThresholdEnabled:)];
    [a addObject:p];
	
	
    p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Clock Source"];
    [p setFormat:@"##0" upperLimit:7 lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setClockSource:) getMethod:@selector(clockSource)];
    [p setActionMask:kAction_Set_Mask];
    [a addObject:p];
		
    p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Threshold"];
    [p setFormat:@"##0" upperLimit:0xffff lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setThreshold:withValue:) getMethod:@selector(threshold:)];
	[p setCanBeRamped:YES];
    [a addObject:p];
 
	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Gate Length"];
    [p setFormat:@"##0" upperLimit:0x3f lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setGateLength:withValue:) getMethod:@selector(gateLength:)];
    [a addObject:p];
	
	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Pulse Length"];
    [p setFormat:@"##0" upperLimit:0xff lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setPulseLength:withValue:) getMethod:@selector(pulseLength:)];
    [a addObject:p];
	
	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Sum G"];
    [p setFormat:@"##0" upperLimit:0x3ff lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setSumG:withValue:) getMethod:@selector(sumG:)];
    [a addObject:p];
		
	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Peaking Time"];
    [p setFormat:@"##0" upperLimit:0x3ff lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setPeakingTime:withValue:) getMethod:@selector(peakingTime:)];
    [a addObject:p];

	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Dac Offset"];
    [p setFormat:@"##0" upperLimit:0xffff lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setDacOffset:withValue:) getMethod:@selector(dacOffset:)];
    [a addObject:p];
	
	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"InternalTriggerDelay"];
    [p setFormat:@"##0" upperLimit:0xffff lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setInternalTriggerDelay:withValue:) getMethod:@selector(internalTriggerDelay:)];
    [a addObject:p];

	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Energy Decimation"];
    [p setFormat:@"##0" upperLimit:3 lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setEnergyDecimation:) getMethod:@selector(energyDecimation)];
    [a addObject:p];
	
	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Trigger Decimation"];
    [p setFormat:@"##0" upperLimit:3 lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setTriggerDecimation:) getMethod:@selector(triggerDecimation)];
    [a addObject:p];
	
	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Sample Length"];
    [p setFormat:@"##0" upperLimit:0xffff lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setSampleLength:withValue:) getMethod:@selector(sampleLength:)];
    [a addObject:p];

	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Pretrigger Delay"];
    [p setFormat:@"##0" upperLimit:0xffff lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setPreTriggerDelay:withValue:) getMethod:@selector(preTriggerDelay:)];
    [a addObject:p];

	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Trigger Gate Length"];
    [p setFormat:@"##0" upperLimit:0xffff lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setTriggerGateLength:withValue:) getMethod:@selector(triggerGateLength:)];
    [a addObject:p];

	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Energy Gate Length"];
    [p setFormat:@"##0" upperLimit:0xffff lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setEnergyGateLength:withValue:) getMethod:@selector(energyGateLength:)];
    [a addObject:p];
	
	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Energy Gap Time"];
    [p setFormat:@"##0" upperLimit:0xffff lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setEnergyGapTime:withValue:) getMethod:@selector(energyGapTime:)];
    [a addObject:p];

	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Energy Peaking Time"];
    [p setFormat:@"##0" upperLimit:0xffff lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setEnergyPeakingTime:withValue:) getMethod:@selector(energyPeakingTime:)];
    [a addObject:p];

	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Energy Sample Length"];
    [p setFormat:@"##0" upperLimit:0xffff lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setEnergySampleLength:) getMethod:@selector(energySampleLength)];
    [a addObject:p];
	
	p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Energy Tau Factor"];
    [p setFormat:@"##0" upperLimit:0xffff lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setEnergyTauFactor:withValue:) getMethod:@selector(energyTauFactor:)];
    [a addObject:p];
	
    p = [[[ORHWWizParam alloc] init] autorelease];
    [p setUseValue:NO];
    [p setName:@"Init"];
    [p setSetMethodSelector:@selector(initBoard)];
    [a addObject:p];
    
    return a;
}


- (NSArray*) wizardSelections
{
    NSMutableArray* a = [NSMutableArray array];
    [a addObject:[ORHWWizSelection itemAtLevel:kContainerLevel name:@"Crate" className:@"ORVmeCrateModel"]];
    [a addObject:[ORHWWizSelection itemAtLevel:kObjectLevel name:@"Card" className:@"ORSIS3302Model"]];
    [a addObject:[ORHWWizSelection itemAtLevel:kChannelLevel name:@"Channel" className:@"ORSIS3302Model"]];
    return a;
}

- (NSNumber*) extractParam:(NSString*)param from:(NSDictionary*)fileHeader forChannel:(int)aChannel
{
	NSDictionary* cardDictionary = [self findCardDictionaryInHeader:fileHeader];
	if([param isEqualToString:@"Threshold"])						return [[cardDictionary objectForKey:@"thresholds"] objectAtIndex:aChannel];
	else if([param isEqualToString:@"GateLength"])					return [[cardDictionary objectForKey:@"gateLengths"] objectAtIndex:aChannel];
	else if([param isEqualToString:@"PulseLength"])					return [[cardDictionary objectForKey:@"pulseLengths"] objectAtIndex:aChannel];
	else if([param isEqualToString:@"SumG"])						return [[cardDictionary objectForKey:@"sumGs"] objectAtIndex:aChannel];
	else if([param isEqualToString:@"PeakingTime"])					return [[cardDictionary objectForKey:@"peakingTimes"] objectAtIndex:aChannel];
	else if([param isEqualToString:@"InternalTriggerDelay"])		return [[cardDictionary objectForKey:@"internalTriggerDelays"] objectAtIndex:aChannel];
	else if([param isEqualToString:@"Dac Offset"])					return [[cardDictionary objectForKey:@"dacOffsets"] objectAtIndex:aChannel];
	else if([param isEqualToString:@"TriggerDecimation"])			return [cardDictionary objectForKey:@"triggerDecimation"];
	else if([param isEqualToString:@"EnergyDecimation"])			return [cardDictionary objectForKey:@"energyDecimation"];
    else if([param isEqualToString:@"Clock Source"])				return [cardDictionary objectForKey:@"clockSource"];
    else if([param isEqualToString:@"Run Mode"])					return [cardDictionary objectForKey:@"runMode"];
    else if([param isEqualToString:@"Extra Time Record"])			return [cardDictionary objectForKey:@"shipTimeRecordAlso"];
    else if([param isEqualToString:@"GT"])							return [cardDictionary objectForKey:@"gtMask"];
    else if([param isEqualToString:@"ADC50K Trigger"])				return [cardDictionary objectForKey:@"adc50KtriggerEnabledMask"];
    else if([param isEqualToString:@"Input Inverted"])				return [cardDictionary objectForKey:@"inputInvertedMask"];
    else if([param isEqualToString:@"Internal Trigger Enabled"])	return [cardDictionary objectForKey:@"internalTriggerEnabledMask"];
    else if([param isEqualToString:@"External Trigger Enabled"])	return [cardDictionary objectForKey:@"externalTriggerEnabledMask"];
    else if([param isEqualToString:@"Internal Gate Enabled"])		return [cardDictionary objectForKey:@"internalGateEnabledMask"];
    else if([param isEqualToString:@"External Gate Enabled"])		return [cardDictionary objectForKey:@"externalGateEnabledMask"];
    else if([param isEqualToString:@"Trigger Decimation"])			return [cardDictionary objectForKey:@"triggerDecimation"];
    else if([param isEqualToString:@"Energy Decimation"])			return [cardDictionary objectForKey:@"energyDecimation"];
    else if([param isEqualToString:@"Energy Gate Length"])			return [cardDictionary objectForKey:@"energyGateLength"];
    else if([param isEqualToString:@"Energy Tau Factor"])			return [cardDictionary objectForKey:@"energyTauFactor"];
    else if([param isEqualToString:@"Energy Sample Length"])		return [cardDictionary objectForKey:@"energySampleLength"];
    else if([param isEqualToString:@"Energy Gap Time"])				return [cardDictionary objectForKey:@"energyGapTime"];
    else if([param isEqualToString:@"Energy Peaking Time"])			return [cardDictionary objectForKey:@"energyPeakingTime"];
    else if([param isEqualToString:@"Trigger Gate Delay"])			return [cardDictionary objectForKey:@"triggerGateLength"];
    else if([param isEqualToString:@"Pretrigger Delay"])			return [cardDictionary objectForKey:@"preTriggerDelay"];
    else if([param isEqualToString:@"Sample Length"])				return [cardDictionary objectForKey:@"sampleLength"];
    else if([param isEqualToString:@"Extended Threshold Enabled"])	return [cardDictionary objectForKey:@"extendedThresholdEnabledMask"];
	
	else return nil;
}

- (void) runTaskStarted:(ORDataPacket*)aDataPacket userInfo:(id)userInfo
{
    if(![[self adapter] controllerCard]){
        [NSException raise:@"Not Connected" format:@"You must connect to a PCI Controller (i.e. a 617)."];
    }
    
    //----------------------------------------------------------------------------------------
    // first add our description to the data description
    
    [aDataPacket addDataDescriptionItem:[self dataRecordDescription] forKey:@"ORSIS3302"];    
    
    //cache some stuff
    location        = (([self crateNumber]&0x0000000f)<<21) | (([self slot]& 0x0000001f)<<16);
    theController   = [self adapter];
    
	[self reset];
    [self initBoard];
	[self setLed:YES];
	
	firstTime	= YES;
	currentBank = 0;
	isRunning	= NO;
	count=0;
	
    [self startRates];
	
	int group;
	for(group=0;group<4;group++){
		dataRecord[group] = nil;
	}
	
	if(runMode == kMcaRunMode){
		mcaScanBank2Flag = NO;
		[self writeMcaArmMode];
		[self pollMcaStatus];
	}
}

//**************************************************************************************
// Function:	TakeData
// Description: Read data from a card
//**************************************************************************************
- (void) takeData:(ORDataPacket*)aDataPacket userInfo:(id)userInfo
{
    @try {
		if(runMode == kMcaRunMode){
			//do nothing.. read out mca spectrum at end
		}
		else {
			if(firstTime){
				int group;
				for(group=0;group<4;group++){
					dataRecordlength[group] = 4+2+[self sampleLength:group]/2+energySampleLength+4; //Orca header+sisheader+samples+energy+sistrailer
					dataRecord[group]		= malloc(dataRecordlength[group]*sizeof(long));
				}
				isRunning = YES;
				firstTime = NO;
				[self disarmAndArmBank:0];
			}
			else {
				if([self isEvent]) {
					[self disarmAndArmNextBank];
					if(bankOneArmed)[self writePageRegister:0x4]; //bank one is armed, so bank2 (page 4) has to be readout
					else			[self writePageRegister:0x0]; //Bank2 is armed and Bank1 (page 0) has to be readout
					int channel;
					for( channel=0;channel<kNumSIS3302Channels;channel++) {
						unsigned long endSampleAddress = 0;
						[[self adapter] readLongBlock:&endSampleAddress
											atAddress:[self baseAddress] +  [self getPreviousBankSampleRegisterOffset:channel]
											numToRead:1
										   withAddMod:[self addressModifier]
										usingAddSpace:0x01];
					
						endSampleAddress &= 0xffffff ; // mask bank2 address bit (bit 24)
					
						if (endSampleAddress > 0x3fffff) {   // more than 1 page memory buffer is used
							// count up as Warnings?
						}
					
						if (endSampleAddress != 0) {
							unsigned long addrOffset = 0;
							int group = channel/2;
							do {
								BOOL goodRecord = NO;
								long cachedEnergy;
								long cachedTime0;
								long cachedTime1;
								int index = 0;
								dataRecord[group][index++] =   dataId | dataRecordlength[group];
								dataRecord[group][index++] =   (([self crateNumber]&0x0000000f)<<21) | 
															   (([self slot] & 0x0000001f)<<16)      |
														       ((channel & 0x000000ff)<<8);
								dataRecord[group][index++] = [self sampleLength:group]/2;
								dataRecord[group][index++] = energySampleLength;
								unsigned long* p = &dataRecord[group][index];
								[[self adapter] readLongBlock: p
													atAddress: [self baseAddress] + [self getADCBufferRegisterOffset:channel] + addrOffset
													numToRead: dataRecordlength[group]-4
												   withAddMod: [self addressModifier]
												usingAddSpace: 0x01];
		
								if(dataRecord[group][dataRecordlength[group]-1] == 0xdeadbeef){
									cachedTime0  = dataRecord[group][0];
									cachedTime1  = dataRecord[group][1];
									cachedEnergy = dataRecord[group][dataRecordlength[group]-4];
									[aDataPacket addLongsToFrameBuffer:dataRecord[group] length:dataRecordlength[group]];
									goodRecord = YES;
								}
																
								addrOffset += (dataRecordlength[group]-4)*4;
							}while (addrOffset < endSampleAddress);
						}
					}
				}
			}
		}
	}
	@catch(NSException* localException) {
		[self incExceptionCount];
		[localException raise];
	}
}

- (void) runIsStopping:(ORDataPacket*)aDataPacket userInfo:(id)userInfo
{
	if(runMode == kMcaRunMode){
		unsigned long mcaLength;
		switch (mcaHistoSize) {
			case 0:  mcaLength = 1024; break;
			case 1:  mcaLength = 2048; break;
			case 2:  mcaLength = 4096; break;
			case 3:  mcaLength = 8192; break;
			default: mcaLength = 2048; break;
		}
		unsigned long pageOffset = 0x0;
		if(mcaScanBank2Flag) pageOffset = 8 * 0x1024 * 0x1024;
		
		int channel;
		for(channel=0;channel<kNumSIS3302Channels;channel++){
			if(gtMask & (1<<channel)){
				NSMutableData* mcaData = [NSMutableData dataWithLength:(mcaLength + 2)*sizeof(long)];
				unsigned long* mcaBytes = (unsigned long*)[mcaData bytes];
				mcaBytes[0] = mcaId | (mcaLength+2);
				mcaBytes[1] =	(([self crateNumber]&0x0000000f)<<21) | 
								(([self slot] & 0x0000001f)<<16)      |
								((channel & 0x000000ff)<<8);
				
				[[self adapter] readLongBlock: &mcaBytes[2]
									atAddress: [self baseAddress] + [self getADCBufferRegisterOffset:channel] + pageOffset
									numToRead: mcaLength
								   withAddMod: [self addressModifier]
								usingAddSpace: 0x01];
				[aDataPacket addData:mcaData];
			}
		}
	}
}

- (void) runTaskStopped:(ORDataPacket*)aDataPacket userInfo:(id)userInfo
{
	if(runMode == kMcaRunMode){	
		unsigned long aValue = 0;
		[[self adapter] writeLongBlock:&aValue
							 atAddress:[self baseAddress] + kSIS3302KeyMcaMultiScanDisable
							numToWrite:1
							withAddMod:[self addressModifier]
						 usingAddSpace:0x01];	

		[[self adapter] writeLongBlock:&aValue
						 atAddress:[self baseAddress] + kSIS3302KeyMcaScanStop
						numToWrite:1
						withAddMod:[self addressModifier]
					 usingAddSpace:0x01];	
		
		[self readMcaStatus];
	}
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollMcaStatus) object:nil];

	int group;
	for(group=0;group<4;group++){
		if(dataRecord){
			free(dataRecord[group]);
			dataRecord[group] = nil;
		}
	}
	[self disarmSampleLogic];
    isRunning = NO;
    [waveFormRateGroup stop];
	[self setLed:NO];
}

//this is the data structure for the new SBCs (i.e. VX704 from Concurrent)
- (int) load_HW_Config_Structure:(SBC_crate_config*)configStruct index:(int)index
{
	if(runMode == kMcaRunMode){
		//in MCA mode there is nothing for the SBC to do... so don't ship any card config data to it.
		return index; 
	}
	else {
		configStruct->total_cards++;
		configStruct->card_info[index].hw_type_id				= kSIS3302; //should be unique
		configStruct->card_info[index].hw_mask[0]				= dataId;	//better be unique
		configStruct->card_info[index].slot						= [self slot];
		configStruct->card_info[index].crate					= [self crateNumber];
		configStruct->card_info[index].add_mod					= [self addressModifier];
		configStruct->card_info[index].base_add					= [self baseAddress];
		configStruct->card_info[index].deviceSpecificData[0]	= [self sampleLength:0]/2;
		configStruct->card_info[index].deviceSpecificData[1]	= [self sampleLength:1]/2;
		configStruct->card_info[index].deviceSpecificData[2]	= [self sampleLength:2]/2;
		configStruct->card_info[index].deviceSpecificData[3]	= [self sampleLength:3]/2;
		configStruct->card_info[index].deviceSpecificData[4]	= [self energySampleLength];
		
		configStruct->card_info[index].num_Trigger_Indexes		= 0;
		
		configStruct->card_info[index].next_Card_Index 	= index+1;	
		
		return index+1;
	}
}

- (void) reset
{
 	unsigned long aValue = 0; //value doesn't matter 
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kSIS3302KeyReset
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) resetSamplingLogic
{
 	unsigned long aValue = 0; //value doesn't matter 
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kSIS3302KeySampleLogicReset
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (BOOL) bumpRateFromDecodeStage:(short)channel
{
    if(isRunning)return NO;
    
    ++waveFormCount[channel];
    return YES;
}

- (unsigned long) waveFormCount:(int)aChannel
{
    return waveFormCount[aChannel];
}

-(void) startRates
{
    [self clearWaveFormCounts];
    [waveFormRateGroup start:self];
}

- (void) clearWaveFormCounts
{
    int i;
    for(i=0;i<kNumSIS3302Channels;i++){
        waveFormCount[i]=0;
    }
}

#pragma mark •••Archival
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
    [[self undoManager] disableUndoRegistration];
	
    [self setShipTimeRecordAlso:		[decoder decodeBoolForKey:@"shipTimeRecordAlso"]];
    [self setMcaUseEnergyCalculation:	[decoder decodeBoolForKey:@"mcaUseEnergyCalculation"]];
    [self setMcaEnergyOffset:			[decoder decodeIntForKey:@"mcaEnergyOffset"]];
    [self setMcaEnergyMultiplier:		[decoder decodeIntForKey:@"mcaEnergyMultiplier"]];
    [self setMcaEnergyDivider:			[decoder decodeIntForKey:@"mcaEnergyDivider"]];
    [self setMcaMode:					[decoder decodeIntForKey:@"mcaMode"]];
    [self setMcaPileupEnabled:			[decoder decodeBoolForKey:@"mcaPileupEnabled"]];
    [self setMcaHistoSize:				[decoder decodeIntForKey:@"mcaHistoSize"]];
    [self setMcaNofScansPreset:			[decoder decodeInt32ForKey:@"mcaNofScansPreset"]];
    [self setMcaAutoClear:				[decoder decodeBoolForKey:@"mcaAutoClear"]];
    [self setMcaPrescaleFactor:			[decoder decodeInt32ForKey:@"mcaPrescaleFactor"]];
    [self setMcaLNESetup:				[decoder decodeBoolForKey:@"mcaLNESetup"]];
    [self setMcaNofHistoPreset:			[decoder decodeInt32ForKey:@"mcaNofHistoPreset"]];
	
    [self setRunMode:					[decoder decodeIntForKey:@"runMode"]];
    [self setInternalExternalTriggersOred:[decoder decodeBoolForKey:@"internalExternalTriggersOred"]];
    [self setLemoInEnabledMask:			[decoder decodeIntForKey:@"lemoInEnabledMask"]];
    [self setEnergySampleStartIndex3:	[decoder decodeIntForKey:@"energySampleStartIndex3"]];
    [self setEnergySampleStartIndex2:	[decoder decodeIntForKey:@"energySampleStartIndex2"]];
    [self setEnergySampleStartIndex1:	[decoder decodeIntForKey:@"energySampleStartIndex1"]];
    [self setEnergySampleLength:		[decoder decodeIntForKey:@"energySampleLength"]];
    [self setLemoInMode:				[decoder decodeIntForKey:@"lemoInMode"]];
    [self setLemoOutMode:				[decoder decodeIntForKey:@"lemoOutMode"]];
	
    [self setClockSource:				[decoder decodeIntForKey:@"clockSource"]];
    [self setTriggerOutEnabledMask:		[decoder decodeInt32ForKey:@"triggerOutEnabledMask"]];
    [self setInputInvertedMask:			[decoder decodeInt32ForKey:@"inputInvertedMask"]];
    [self setInternalTriggerEnabledMask:[decoder decodeInt32ForKey:@"internalTriggerEnabledMask"]];
    [self setExternalTriggerEnabledMask:[decoder decodeInt32ForKey:@"externalTriggerEnabledMask"]];
    [self setExtendedThresholdEnabledMask:[decoder decodeInt32ForKey:@"extendedThresholdEnabledMask"]];
    [self setInternalGateEnabledMask:	[decoder decodeInt32ForKey:@"internalGateEnabledMask"]];
    [self setExternalGateEnabledMask:	[decoder decodeInt32ForKey:@"externalGateEnabledMask"]];
    [self setAdc50KTriggerEnabledMask:	[decoder decodeInt32ForKey:@"adc50KtriggerEnabledMask"]];
	[self setGtMask:					[decoder decodeIntForKey:@"gtMask"]];
	[self setShipEnergyWaveform:		[decoder decodeBoolForKey:@"shipEnergyWaveform"]];
    [self setWaveFormRateGroup:			[decoder decodeObjectForKey:@"waveFormRateGroup"]];
		
    sampleLengths = 			[[decoder decodeObjectForKey:@"sampleLengths"]retain];
	thresholds  =				[[decoder decodeObjectForKey:@"thresholds"] retain];
    dacOffsets  =				[[decoder decodeObjectForKey:@"dacOffsets"] retain];
	gateLengths =				[[decoder decodeObjectForKey:@"gateLengths"] retain];
	pulseLengths =				[[decoder decodeObjectForKey:@"pulseLengths"] retain];
	sumGs =						[[decoder decodeObjectForKey:@"sumGs"] retain];
	peakingTimes =				[[decoder decodeObjectForKey:@"peakingTimes"] retain];
	internalTriggerDelays =		[[decoder decodeObjectForKey:@"internalTriggerDelays"] retain];
	triggerDecimations = 		[[decoder decodeObjectForKey:@"triggerDecimations"] retain];
    triggerGateLengths =		[[decoder decodeObjectForKey:@"triggerGateLengths"] retain];
    preTriggerDelays =			[[decoder decodeObjectForKey:@"preTriggerDelays"] retain];
    sampleStartIndexes =		[[decoder decodeObjectForKey:@"sampleStartIndexes"] retain];
    energyTauFactors =			[[decoder decodeObjectForKey:@"energyTauFactors"] retain];
	energyDecimations=			[[decoder decodeObjectForKey:@"energyDecimations"]retain];
	energyGapTimes = 			[[decoder decodeObjectForKey:@"energyGapTimes"]retain];
    energyPeakingTimes =		[[decoder decodeObjectForKey:@"energyPeakingTimes"]retain];

	if(!waveFormRateGroup){
		[self setWaveFormRateGroup:[[[ORRateGroup alloc] initGroup:kNumSIS3302Channels groupTag:0] autorelease]];
	    [waveFormRateGroup setIntegrationTime:5];
    }
    [waveFormRateGroup resetRates];
    [waveFormRateGroup calcRates];
	
	[self setUpArrays];

	
    [[self undoManager] enableUndoRegistration];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
	
	[encoder encodeBool:shipTimeRecordAlso		forKey:@"shipTimeRecordAlso"];
	[encoder encodeBool:mcaUseEnergyCalculation forKey:@"mcaUseEnergyCalculation"];
	[encoder encodeInt:mcaEnergyOffset			forKey:@"mcaEnergyOffset"];
	[encoder encodeInt:mcaEnergyMultiplier		forKey:@"mcaEnergyMultiplier"];
	[encoder encodeInt:mcaEnergyDivider			forKey:@"mcaEnergyDivider"];
	[encoder encodeInt:mcaMode					forKey:@"mcaMode"];
	[encoder encodeBool:mcaPileupEnabled		forKey:@"mcaPileupEnabled"];
	[encoder encodeInt:mcaHistoSize				forKey:@"mcaHistoSize"];
	[encoder encodeInt32:mcaNofScansPreset		forKey:@"mcaNofScansPreset"];
	[encoder encodeBool:mcaAutoClear			forKey:@"mcaAutoClear"];
	[encoder encodeInt32:mcaPrescaleFactor		forKey:@"mcaPrescaleFactor"];
	[encoder encodeBool:mcaLNESetup				forKey:@"mcaLNESetup"];
	[encoder encodeInt32:mcaNofHistoPreset		forKey:@"mcaNofHistoPreset"];
	
	[encoder encodeInt:runMode					forKey:@"runMode"];
    [encoder encodeInt:gtMask					forKey:@"gtMask"];
    [encoder encodeInt:clockSource				forKey:@"clockSource"];
	[encoder encodeInt:lemoInEnabledMask		forKey:@"lemoInEnabledMask"];
	[encoder encodeInt:energySampleStartIndex3	forKey:@"energySampleStartIndex3"];
	[encoder encodeInt:energySampleStartIndex2	forKey:@"energySampleStartIndex2"];
	[encoder encodeInt:energySampleStartIndex1	forKey:@"energySampleStartIndex1"];
	[encoder encodeInt:energySampleLength		forKey:@"energySampleLength"];
	[encoder encodeInt:lemoInMode				forKey:@"lemoInMode"];
	[encoder encodeInt:lemoOutMode				forKey:@"lemoOutMode"];
	[encoder encodeBool:shipEnergyWaveform		forKey:@"shipEnergyWaveform"];

	[encoder encodeBool:internalExternalTriggersOred	forKey:@"internalExternalTriggersOred"];
	[encoder encodeInt32:triggerOutEnabledMask			forKey:@"triggerOutEnabledMask"];
	[encoder encodeInt32:inputInvertedMask				forKey:@"inputInvertedMask"];
	[encoder encodeInt32:internalTriggerEnabledMask		forKey:@"internalTriggerEnabledMask"];
	[encoder encodeInt32:externalTriggerEnabledMask		forKey:@"externalTriggerEnabledMask"];
	[encoder encodeInt32:extendedThresholdEnabledMask	forKey:@"extendedThresholdEnabledMask"];
	[encoder encodeInt32:internalGateEnabledMask		forKey:@"internalGateEnabledMask"];
	[encoder encodeInt32:externalGateEnabledMask		forKey:@"externalGateEnabledMask"];
	[encoder encodeInt32:adc50KTriggerEnabledMask		forKey:@"adc50KtriggerEnabledMask"];
	
	[encoder encodeObject:energyDecimations		forKey:@"energyDecimations"];
	[encoder encodeObject:energyGapTimes		forKey:@"energyGapTimes"];
	[encoder encodeObject:energyPeakingTimes	forKey:@"energyPeakingTimes"];
    [encoder encodeObject:waveFormRateGroup		forKey:@"waveFormRateGroup"];
	[encoder encodeObject:sampleLengths			forKey:@"sampleLengths"];
	[encoder encodeObject:thresholds			forKey:@"thresholds"];
	[encoder encodeObject:dacOffsets			forKey:@"dacOffsets"];
	[encoder encodeObject:gateLengths			forKey:@"gateLengths"];
	[encoder encodeObject:pulseLengths			forKey:@"pulseLengths"];
	[encoder encodeObject:sumGs					forKey:@"sumGs"];
	[encoder encodeObject:peakingTimes			forKey:@"peakingTimes"];
	[encoder encodeObject:internalTriggerDelays	forKey:@"internalTriggerDelays"];
	[encoder encodeObject:triggerGateLengths	forKey:@"triggerGateLengths"];
	[encoder encodeObject:preTriggerDelays		forKey:@"preTriggerDelays"];
	[encoder encodeObject:sampleStartIndexes	forKey:@"sampleStartIndexes"];
	[encoder encodeObject:triggerDecimations	forKey:@"triggerDecimations"];
	[encoder encodeObject:energyTauFactors		forKey:@"energyTauFactors"];
	
}

- (NSMutableDictionary*) addParametersToDictionary:(NSMutableDictionary*)dictionary
{
    NSMutableDictionary* objDictionary = [super addParametersToDictionary:dictionary];

    [objDictionary setObject: [NSNumber numberWithLong:gtMask]						forKey:@"gtMask"];	
	[objDictionary setObject: [NSNumber numberWithInt:clockSource]					forKey:@"clockSource"];
	[objDictionary setObject: [NSNumber numberWithLong:adc50KTriggerEnabledMask]	forKey:@"adc50KtriggerEnabledMask"];
	[objDictionary setObject: [NSNumber numberWithLong:triggerOutEnabledMask]		forKey:@"triggerOutEnabledMask"];
	[objDictionary setObject: [NSNumber numberWithLong:inputInvertedMask]			forKey:@"inputInvertedMask"];
	[objDictionary setObject: [NSNumber numberWithLong:internalTriggerEnabledMask]	forKey:@"internalTriggerEnabledMask"];
	[objDictionary setObject: [NSNumber numberWithLong:externalTriggerEnabledMask]	forKey:@"externalTriggerEnabledMask"];
	[objDictionary setObject: [NSNumber numberWithLong:internalGateEnabledMask]		forKey:@"internalGateEnabledMask"];
	[objDictionary setObject: [NSNumber numberWithLong:externalGateEnabledMask]		forKey:@"externalGateEnabledMask"];
	[objDictionary setObject: [NSNumber numberWithLong:extendedThresholdEnabledMask]	forKey:@"extendedThresholdEnabledMask"];
    [objDictionary setObject: internalTriggerDelays									forKey:@"internalTriggerDelays"];	
    [objDictionary setObject: energyDecimations										forKey:@"energyDecimations"];	
	
	[objDictionary setObject:[NSNumber numberWithInt:runMode]						forKey:@"runMode"];
	[objDictionary setObject:[NSNumber numberWithInt:shipTimeRecordAlso]			forKey:@"shipTimeRecordAlso"];

	[objDictionary setObject:[NSNumber numberWithInt:lemoInEnabledMask]				forKey:@"lemoInEnabledMask"];
	[objDictionary setObject:[NSNumber numberWithInt:energySampleStartIndex3]		forKey:@"energySampleStartIndex3"];
	[objDictionary setObject:[NSNumber numberWithInt:energySampleStartIndex2]		forKey:@"energySampleStartIndex2"];
	[objDictionary setObject:[NSNumber numberWithInt:energySampleStartIndex1]		forKey:@"energySampleStartIndex1"];
	[objDictionary setObject:[NSNumber numberWithInt:energySampleLength]			forKey:@"energySampleLength"];
	[objDictionary setObject:[NSNumber numberWithInt:lemoInMode]					forKey:@"lemoInMode"];
	[objDictionary setObject:[NSNumber numberWithInt:lemoOutMode]					forKey:@"lemoOutMode"];
	[objDictionary setObject:[NSNumber numberWithBool:shipEnergyWaveform]			forKey:@"shipEnergyWaveform"];
	[objDictionary setObject:[NSNumber numberWithBool:internalExternalTriggersOred]	forKey:@"internalExternalTriggersOred"];
	
	[objDictionary setObject:energyTauFactors	forKey:@"energyTauFactors"];
	[objDictionary setObject:energyGapTimes		forKey:@"energyGapTimes"];
	[objDictionary setObject:energyPeakingTimes	forKey:@"energyPeakingTimes"];
	[objDictionary setObject:sampleLengths		forKey:@"sampleLengths"];
	[objDictionary setObject: dacOffsets		forKey:@"dacOffsets"];
    [objDictionary setObject: thresholds		forKey:@"thresholds"];	
    [objDictionary setObject: gateLengths		forKey:@"gateLengths"];	
    [objDictionary setObject: pulseLengths		forKey:@"pulseLengths"];	
    [objDictionary setObject: sumGs				forKey:@"sumGs"];	
    [objDictionary setObject: peakingTimes		forKey:@"peakingTimes"];	
	[objDictionary setObject: triggerGateLengths	forKey:@"triggerGateLengths"];
	[objDictionary setObject: preTriggerDelays		forKey:@"preTriggerDelays"];
	[objDictionary setObject: sampleStartIndexes	forKey:@"sampleStartIndexes"];
    [objDictionary setObject: triggerDecimations	forKey:@"triggerDecimations"];	
	[objDictionary setObject: energyGateLengths		forKey:@"energyGateLengths"];
	
    return objDictionary;
}

- (NSArray*) autoTests 
{
	NSMutableArray* myTests = [NSMutableArray array];
	[myTests addObject:[ORVmeReadOnlyTest test:kSIS3302AcquisitionControl wordSize:4 name:@"Acquistion Reg"]];
	[myTests addObject:[ORVmeWriteOnlyTest test:kSIS3302KeyReset wordSize:4 name:@"Reset"]];
	//TO DO.. add more tests
	
	int i;
	for(i=0;i<8;i++){
		[myTests addObject:[ORVmeReadWriteTest test:[self getThresholdRegOffsets:i] wordSize:4 validMask:0x1ffff name:@"Threshold"]];
	}
	return myTests;
}

//ORAdcInfoProviding protocol requirement
- (void) postAdcInfoProvidingValueChanged
{
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:ORAdcInfoProvidingValueChanged
	 object:self
	 userInfo: nil];
}
//for adcProvidingProtocol... but not used for now
- (unsigned long) eventCount:(int)channel
{
	return 0;
}
- (void) clearEventCounts
{
}
- (unsigned long) thresholdForDisplay:(unsigned short) aChan
{
	return [self threshold:aChan];
}
- (unsigned short) gainForDisplay:(unsigned short) aChan
{
	return [self gain:aChan];
}
@end

@implementation ORSIS3302Model (private)
- (NSMutableArray*) arrayOfLength:(int)len
{
	int i;
	NSMutableArray* anArray = [NSMutableArray arrayWithCapacity:kNumSIS3302Channels];
	for(i=0;i<len;i++)[anArray addObject:[NSNumber numberWithInt:0]];
	return anArray;
}

- (void) setUpArrays
{
	if(!thresholds)				thresholds			  = [[self arrayOfLength:kNumSIS3302Channels] retain];
	if(!dacOffsets)				dacOffsets			  = [[self arrayOfLength:kNumSIS3302Channels] retain];
	if(!gateLengths)			gateLengths			  = [[self arrayOfLength:kNumSIS3302Channels] retain];
	if(!pulseLengths)			pulseLengths		  = [[self arrayOfLength:kNumSIS3302Channels] retain];
	if(!sumGs)					sumGs				  = [[self arrayOfLength:kNumSIS3302Channels] retain];
	if(!peakingTimes)			peakingTimes		  = [[self arrayOfLength:kNumSIS3302Channels] retain];
	if(!internalTriggerDelays)	internalTriggerDelays = [[self arrayOfLength:kNumSIS3302Channels] retain];
	if(!energyTauFactors)		energyTauFactors	  = [[self arrayOfLength:kNumSIS3302Channels] retain];
		
	if(!sampleLengths)		sampleLengths		= [[self arrayOfLength:kNumSIS3302Groups] retain];
	if(!preTriggerDelays)	preTriggerDelays	= [[self arrayOfLength:kNumSIS3302Groups] retain];
	if(!triggerGateLengths)	triggerGateLengths	= [[self arrayOfLength:kNumSIS3302Groups] retain];
	if(!triggerDecimations)	triggerDecimations	= [[self arrayOfLength:kNumSIS3302Groups] retain];
	if(!energyGateLengths)	energyGateLengths	= [[self arrayOfLength:kNumSIS3302Groups] retain];
	if(!energyPeakingTimes)	energyPeakingTimes	= [[self arrayOfLength:kNumSIS3302Groups] retain];
	if(!energyDecimations)	energyDecimations	= [[self arrayOfLength:kNumSIS3302Groups] retain];
	if(!energyGapTimes)		energyGapTimes		= [[self arrayOfLength:kNumSIS3302Groups] retain];
	if(!sampleStartIndexes)	sampleStartIndexes	= [[self arrayOfLength:kNumSIS3302Groups] retain];

	if(!waveFormRateGroup){
        [self setWaveFormRateGroup:[[[ORRateGroup alloc] initGroup:kNumSIS3302Channels groupTag:0] autorelease]];
        [waveFormRateGroup setIntegrationTime:5];
    }
	
}

- (void) writeDacOffsets
{
	
	unsigned int max_timeout, timeout_cnt;
	
	int i;
	for (i=0;i<kNumSIS3302Channels;i++) {
		unsigned long data =  [self dacOffset:i];
		unsigned long addr = [self baseAddress] + kSIS3302DacData  ;
		
		// Set the Data in the DAC Register
		[[self adapter] writeLongBlock:&data
							 atAddress:addr
							numToWrite:1
							withAddMod:addressModifier
						 usingAddSpace:0x01];
	
		
		data =  1 + (i << 4); // write to DAC Register
		addr = [self baseAddress] + kSIS3302DacControlStatus  ;
		// Tell card to set the DAC shift Register
		[[self adapter] writeLongBlock:&data
							 atAddress:addr
							numToWrite:1
							withAddMod:addressModifier
						 usingAddSpace:0x01];
		
		max_timeout = 5000 ;
		timeout_cnt = 0 ;
		addr = [self baseAddress] + kSIS3302DacControlStatus  ;
		// Wait until done.
		do {
			[[self adapter] readLongBlock:&data
								 atAddress:addr
								numToRead:1
								withAddMod:addressModifier
							 usingAddSpace:0x01];
			
			timeout_cnt++;
		} while ( ((data & 0x8000) == 0x8000) && (timeout_cnt <  max_timeout) )    ;
		
		if (timeout_cnt >=  max_timeout) {
			NSLog(@"%@ Failed programing the DAC offset for channel %d\n",[self fullID],i); 
			return;
		}
		
		[[self adapter] writeLongBlock:&data
							atAddress:addr
							numToWrite:1
						   withAddMod:addressModifier
						usingAddSpace:0x01];
		
		
		data =  2 + (i << 4); // Load DACs 
		addr = [self baseAddress] + kSIS3302DacControlStatus  ;
		[[self adapter] writeLongBlock:&data
							 atAddress:addr
							numToWrite:1
							withAddMod:addressModifier
						 usingAddSpace:0x01];

		timeout_cnt = 0 ;
		addr = [self baseAddress] + kSIS3302DacControlStatus  ;
		do {
			[[self adapter] readLongBlock:&data
								atAddress:addr
								numToRead:1
							   withAddMod:addressModifier
							usingAddSpace:0x01];
			timeout_cnt++;
		} while ( ((data & 0x8000) == 0x8000) && (timeout_cnt <  max_timeout) )    ;
		
		if (timeout_cnt >=  max_timeout) {
			NSLog(@"%@ Failed programing the DAC offset for channel %d\n",[self fullID],i); 
			return;
		}
	}
}

- (void) pollMcaStatus
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollMcaStatus) object:nil];
	if([gOrcaGlobals runInProgress]){
		[self readMcaStatus];
		[self performSelector:@selector(pollMcaStatus) withObject:self afterDelay:2];
	}
}

@end
