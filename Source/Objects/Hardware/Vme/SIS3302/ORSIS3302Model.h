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
#import "ORVmeIOCard.h"
#import "ORDataTaker.h"
#import "ORHWWizard.h"
#import "SBC_Config.h"
#import "AutoTesting.h"
#import "ORSISRegisterDefs.h"

#define kNumMcaStatusRequests 35 //don't change this unless you know what you are doing....

@class ORRateGroup;
@class ORAlarm;
@class ORCommandList;

@interface ORSIS3302Model : ORVmeIOCard <ORDataTaker,ORHWWizard,ORHWRamping,AutoTesting>
{
  @private
	BOOL			isRunning;
	 	
	//clocks and delays (Acquistion control reg)
	int	 clockSource;
	
	unsigned long   dataId;
	unsigned long   mcaStatusResults[kNumMcaStatusRequests];

	short			internalTriggerEnabledMask;
	short			externalTriggerEnabledMask;
	short			internalGateEnabledMask;
	short			externalGateEnabledMask;
	short			inputInvertedMask;
	short			triggerOutEnabledMask;
	short			adc50KTriggerEnabledMask;
	short			gtMask;
	short			triggerDecimation;
	short			energyDecimation;
	NSMutableArray* thresholds;
    NSMutableArray* dacOffsets;
	NSMutableArray* gateLengths;
	NSMutableArray* pulseLengths;
	NSMutableArray* sumGs;
	NSMutableArray* peakingTimes;
	NSMutableArray* internalTriggerDelays;
	
	ORRateGroup*	waveFormRateGroup;
	unsigned long 	waveFormCount[kNumSIS3302Channels];

	//cach to speed takedata
	unsigned long location;
	id theController;
	int currentBank;
	unsigned long dataWord[4][16*1024];					
	long count;
    short lemoOutMode;
    short lemoInMode;
    unsigned short sampleLength;
    unsigned short sampleStartIndex;
	BOOL bankOneArmed;
	BOOL firstTime;
	BOOL shipEnergyWaveform;
	
    int preTriggerDelay;
    int triggerGateLength;
    int energyGateLength;
    int energyPeakingTime;
    int energyGapTime;
    int energySampleLength;
    int energySampleStartIndex1;
    int energySampleStartIndex2;
    int energySampleStartIndex3;
    int energyTauFactor;
    int endAddressThreshold;
    int runMode;
    unsigned short lemoInEnabledMask;
    BOOL internalExternalTriggersOred;
	
	unsigned long* dataRecord;
	unsigned long  dataRecordlength;
	
	//calculated values
	unsigned long numEnergyValues;
	unsigned long numRawDataLongWords;
	unsigned long rawDataIndex;
	unsigned long energyIndex;
	unsigned long energyMaxIndex;
	unsigned long eventLengthLongWords;
    unsigned long mcaNofHistoPreset;
    BOOL			mcaLNESetup;
    unsigned long	mcaPrescaleFactor;
    BOOL			mcaAutoClear;
    unsigned long	mcaNofScansPreset;
    int				mcaHistoSize;
    BOOL			mcaPileupEnabled;
    BOOL			mcaScanBank2Flag;
    int mcaMode;
}

- (id) init;
- (void) dealloc;
- (void) setUpImage;
- (void) makeMainController;

#pragma mark ***Accessors
- (unsigned long) mcaStatusResult:(int)index;
- (int) mcaMode;
- (void) setMcaMode:(int)aMcaMode;
- (BOOL) mcaScanBank2Flag;
- (void) setMcaScanBank2Flag:(BOOL)aMcaScanBank2Flag;
- (BOOL) mcaPileupEnabled;
- (void) setMcaPileupEnabled:(BOOL)aMcaPileupEnabled;
- (int) mcaHistoSize;
- (void) setMcaHistoSize:(int)aMcaHistoSize;
- (unsigned long) mcaNofScansPreset;
- (void) setMcaNofScansPreset:(unsigned long)aMcaNofScansPreset;
- (BOOL) mcaAutoClear;
- (void) setMcaAutoClear:(BOOL)aMcaAutoClear;
- (unsigned long) mcaPrescaleFactor;
- (void) setMcaPrescaleFactor:(unsigned long)aMcaPrescaleFactor;
- (BOOL) mcaLNESetup;
- (void) setMcaLNESetup:(BOOL)aMcaLNESetup;
- (unsigned long) mcaNofHistoPreset;
- (void) setMcaNofHistoPreset:(unsigned long)aMcaNofHistoPreset;
- (BOOL) internalExternalTriggersOred;
- (void) setInternalExternalTriggersOred:(BOOL)aInternalExternalTriggersOred;
- (unsigned short) lemoInEnabledMask;
- (void) setLemoInEnabledMask:(unsigned short)aLemoInEnableMask;
- (BOOL) lemoInEnabled:(unsigned short)aBit;
- (void) setLemoInEnabled:(unsigned short)aBit withValue:(BOOL)aState;
- (BOOL) lemoInEnabled:(unsigned short)aBit;
- (void) setLemoInEnabled:(unsigned short)aBit withValue:(BOOL)aState;
- (int)  energyGateLength;
- (void) setEnergyGateLength:(int)aEnergyGateLength;
- (int)  runMode;
- (void) setRunMode:(int)aRunMode;
- (int)  endAddressThreshold;
- (void) setEndAddressThreshold:(int)aEndAddressThreshold;
- (int)  energyTauFactor;
- (void) setEnergyTauFactor:(int)aEnergyTauFactor;
- (int)  energySampleStartIndex3;
- (void) setEnergySampleStartIndex3:(int)aEnergySampleStartIndex3;
- (int)  energySampleStartIndex2;
- (void) setEnergySampleStartIndex2:(int)aEnergySampleStartIndex2;
- (int)  energySampleStartIndex1;
- (void) setEnergySampleStartIndex1:(int)aEnergySampleStartIndex1;
- (int)  energySampleLength;
- (void) setEnergySampleLength:(int)aEnergySampleLength;
- (int)  energyGapTime;
- (void) setEnergyGapTime:(int)aEnergyGapTime;
- (int)  energyPeakingTime;
- (void) setEnergyPeakingTime:(int)aEnergyPeakingTime;
- (int)  triggerGateLength;
- (void) setTriggerGateLength:(int)aTriggerGateLength;
- (int)  preTriggerDelay;
- (void) setPreTriggerDelay:(int)aPreTriggerDelay;
- (unsigned long) getThresholdRegOffsets:(int) channel;
- (unsigned long) getTriggerSetupRegOffsets:(int) channel; 
- (unsigned long) getTriggerExtSetupRegOffsets:(int)channel;
- (unsigned long) getEndThresholdRegOffsets:(int)group;
- (unsigned long) getSampleAddress:(int)channel;
- (unsigned long) getAdcMemory:(int)channel;
- (unsigned long) getEventConfigOffsets:(int)group;
- (unsigned long) getExtendedEventConfigOffsets:(int)group;

- (unsigned short) sampleStartIndex;
- (void) setSampleStartIndex:(unsigned short)aSampleStartIndex;
- (unsigned short) sampleLength;
- (void) setSampleLength:(unsigned short)aSampleLength;
- (short) lemoInMode;
- (void) setLemoInMode:(short)aLemoInMode;
- (NSString*) lemoInAssignments;
- (short) lemoOutMode;
- (void) setLemoOutMode:(short)aLemoOutMode;
- (NSString*) lemoOutAssignments;
- (void) setDefaults;

- (int) clockSource;
- (void) setClockSource:(int)aClockSource;

- (short) internalTriggerEnabledMask;
- (void) setInternalTriggerEnabledMask:(short)aMask;
- (BOOL) internalTriggerEnabled:(short)chan;
- (void) setInternalTriggerEnabled:(short)chan withValue:(BOOL)aValue;

- (short) externalTriggerEnabledMask;
- (void) setExternalTriggerEnabledMask:(short)aMask;
- (BOOL) externalTriggerEnabled:(short)chan;
- (void) setExternalTriggerEnabled:(short)chan withValue:(BOOL)aValue;

- (short) internalGateEnabledMask;
- (void) setInternalGateEnabledMask:(short)aMask;
- (BOOL) internalGateEnabled:(short)chan;
- (void) setInternalGateEnabled:(short)chan withValue:(BOOL)aValue;

- (short) externalGateEnabledMask;
- (void) setExternalGateEnabledMask:(short)aMask;
- (BOOL) externalGateEnabled:(short)chan;
- (void) setExternalGateEnabled:(short)chan withValue:(BOOL)aValue;

- (short) inputInvertedMask;
- (void) setInputInvertedMask:(short)aMask;
- (BOOL) inputInverted:(short)chan;
- (void) setInputInverted:(short)chan withValue:(BOOL)aValue;

- (short) triggerOutEnabledMask;
- (void) setTriggerOutEnabledMask:(short)aMask;
- (BOOL) triggerOutEnabled:(short)chan;
- (void) setTriggerOutEnabled:(short)chan withValue:(BOOL)aValue;

- (short) adc50KTriggerEnabledMask;
- (void) setAdc50KTriggerEnabledMask:(short)aMask;
- (BOOL) adc50KTriggerEnabled:(short)chan;
- (void) setAdc50KTriggerEnabled:(short)chan withValue:(BOOL)aValue;

- (BOOL) shipEnergyWaveform;
- (void) setShipEnergyWaveform:(BOOL)aState;

- (short) gtMask;
- (void) setGtMask:(long)aMask;
- (BOOL) gt:(short)chan;
- (void) setGtBit:(short)chan withValue:(BOOL)aValue;
- (short) peakingTime:(short)chan;
- (void) setPeakingTime:(short)chan withValue:(short)aValue;
- (short) internalTriggerDelay:(short)chan;
- (void) setInternalTriggerDelay:(short)chan withValue:(short)aValue;
- (short) triggerDecimation;
- (void) setTriggerDecimation:(short)aValue;
- (short) energyDecimation;
- (void) setEnergyDecimation:(short)aValue;

- (int) threshold:(short)chan;
- (void) setThreshold:(short)chan withValue:(int)aValue;
- (unsigned short) dacOffset:(short)chan;
- (void) setDacOffset:(short)aChan withValue:(int)aValue;
- (void) setPulseLength:(short)aChan withValue:(short)aValue;
- (short) pulseLength:(short)chan;
- (void) setGateLength:(short)aChan withValue:(short)aValue;
- (short) gateLength:(short)chan;
- (void) setSumG:(short)aChan withValue:(short)aValue;
- (short) sumG:(short)chan;
- (short) peakingTime:(short)aChan;
- (void) setPeakingTime:(short)aChan withValue:(short)aValue;

- (void) initParams;

- (ORRateGroup*)    waveFormRateGroup;
- (void)			setWaveFormRateGroup:(ORRateGroup*)newRateGroup;
- (id)              rateObject:(int)channel;
- (void)            setRateIntegrationTime:(double)newIntegrationTime;
- (BOOL)			bumpRateFromDecodeStage:(short)channel;

- (void) calculateSampleValues;
- (void) calculateEnergyGateLength;

#pragma mark •••Hardware Access
- (int) limitIntValue:(int)aValue min:(int)aMin max:(int)aMax;
- (void) initBoard;
- (void) readModuleID:(BOOL)verbose;
- (void) writeAcquistionRegister;
- (void) writeEventConfiguration;
- (void) writeThresholds;
- (void) readThresholds:(BOOL)verbose;
- (void) setLed:(BOOL)state;
- (void) report;
- (void) resetSamplingLogic;
- (void) writePageRegister:(int) aPage;
- (void) writePreTriggerDelayAndTriggerGateDelay;
- (void) writeEnergyGP;
- (void) writeRawDataBufferConfiguration;
- (void) writeEndAddressThreshold;
- (void) writeEnergyGateLength;
- (void) writeEnergyTauFactor;
- (void) writeEnergySampleLength;
- (void) writeEnergySampleStartIndexes;

- (void) disarmSampleLogic;
- (void) clearTimeStamp;
- (void) writeTriggerSetups;

- (void) writeMcaLNESetupAndPrescalFactor;
- (void) writeMcaScanControl;
- (void) writeMcaNofHistoPreset;
- (void) writeMcaLNEPulse;
- (void) writeMcaArm;
- (void) writeMcaScanEnable;
- (void) writeMcaScanDisable;
- (void) writeMcaMultiScanStartReset;
- (void) writeMcaMultiScanArmScanArm;
- (void) writeMcaMultiScanArmScanEnable;
- (void) writeMcaMultiScanDisable;
- (void) writeHistogramParams;
- (void) writeMcaMultiScanNofScansPreset;
- (void) writeMcaArmMode;
- (void) executeCommandList:(ORCommandList*) aList;

- (unsigned long) acqReg;
- (unsigned long) getPreviousBankSampleRegisterOffset:(int) channel;
- (unsigned long) getADCBufferRegisterOffset:(int) channel;
- (void) disarmAndArmBank:(int) bank;
- (void) disarmAndArmNextBank;
- (void) forceTrigger;
- (NSString*) runSummary;

#pragma mark •••Data Taker
- (unsigned long) dataId;
- (void) setDataId: (unsigned long) DataId;
- (void) setDataIds:(id)assigner;
- (void) syncDataIdsWith:(id)anotherShaper;
- (NSDictionary*) dataRecordDescription;
- (void) runTaskStarted:(ORDataPacket*)aDataPacket userInfo:(id)userInfo;
- (void) takeData:(ORDataPacket*)aDataPacket userInfo:(id)userInfo;
- (void) runTaskStopped:(ORDataPacket*)aDataPacket userInfo:(id)userInfo;
- (unsigned long) waveFormCount:(int)aChannel;
- (void)   startRates;
- (void) clearWaveFormCounts;
- (unsigned long) getCounter:(int)counterTag forGroup:(int)groupTag;
- (int) load_HW_Config_Structure:(SBC_crate_config*)configStruct index:(int)index;
- (BOOL) isEvent;

#pragma mark •••HW Wizard
- (int) numberOfChannels;
- (NSArray*) wizardParameters;
- (NSArray*) wizardSelections;
- (NSNumber*) extractParam:(NSString*)param from:(NSDictionary*)fileHeader forChannel:(int)aChannel;

#pragma mark •••Archival
- (id)initWithCoder:(NSCoder*)decoder;
- (void)encodeWithCoder:(NSCoder*)encoder;
- (NSMutableDictionary*) addParametersToDictionary:(NSMutableDictionary*)dictionary;

#pragma mark •••AutoTesting
- (NSArray*) autoTests; 
@end

//CSRg
extern NSString* ORSIS3302ModelMcaModeChanged;
extern NSString* ORSIS3302ModelMcaScanBank2FlagChanged;
extern NSString* ORSIS3302ModelMcaPileupEnabledChanged;
extern NSString* ORSIS3302ModelMcaHistoSizeChanged;
extern NSString* ORSIS3302ModelMcaNofScansPresetChanged;
extern NSString* ORSIS3302ModelMcaAutoClearChanged;
extern NSString* ORSIS3302ModelMcaPrescaleFactorChanged;
extern NSString* ORSIS3302ModelMcaLNESetupChanged;
extern NSString* ORSIS3302ModelMcaNofHistoPresetChanged;
extern NSString* ORSIS3302ModelInternalExternalTriggersOredChanged;
extern NSString* ORSIS3302ModelLemoInEnabledMaskChanged;
extern NSString* ORSIS3302ModelEnergyGateLengthChanged;
extern NSString* ORSIS3302ModelRunModeChanged;
extern NSString* ORSIS3302ModelEndAddressThresholdChanged;
extern NSString* ORSIS3302ModelEnergySampleStartIndex3Changed;
extern NSString* ORSIS3302ModelEnergyTauFactorChanged;
extern NSString* ORSIS3302ModelEnergySampleStartIndex2Changed;
extern NSString* ORSIS3302ModelEnergySampleStartIndex1Changed;
extern NSString* ORSIS3302ModelEnergySampleLengthChanged;
extern NSString* ORSIS3302ModelEnergyGapTimeChanged;
extern NSString* ORSIS3302ModelEnergyPeakingTimeChanged;
extern NSString* ORSIS3302ModelTriggerGateLengthChanged;
extern NSString* ORSIS3302ModelPreTriggerDelayChanged;
extern NSString* ORSIS3302SampleStartIndexChanged;
extern NSString* ORSIS3302SampleLengthChanged;
extern NSString* ORSIS3302DacOffsetChanged;
extern NSString* ORSIS3302LemoInModeChanged;
extern NSString* ORSIS3302LemoOutModeChanged;
extern NSString* ORSIS3302AcqRegEnableMaskChanged;

extern NSString* ORSIS3302AcqRegChanged;
extern NSString* ORSIS3302EventConfigChanged;

extern NSString* ORSIS3302ClockSourceChanged;
extern NSString* ORSIS3302TriggerOutEnabledChanged;
extern NSString* ORSIS3302ThresholdChanged;
extern NSString* ORSIS3302ThresholdArrayChanged;
extern NSString* ORSIS3302GtChanged;

extern NSString* ORSIS3302SettingsLock;
extern NSString* ORSIS3302RateGroupChangedNotification;
extern NSString* ORSIS3302SampleDone;
extern NSString* ORSIS3302IDChanged;
extern NSString* ORSIS3302GateLengthChanged;
extern NSString* ORSIS3302PulseLengthChanged;
extern NSString* ORSIS3302SumGChanged;
extern NSString* ORSIS3302PeakingTimeChanged;
extern NSString* ORSIS3302InternalTriggerDelayChanged;
extern NSString* ORSIS3302TriggerDecimationChanged;
extern NSString* ORSIS3302EnergyDecimationChanged;
extern NSString* ORSIS3302SetShipWaveformChanged;
extern NSString* ORSIS3302Adc50KTriggerEnabledChanged;
extern NSString* ORSIS3302InputInvertedChanged;

extern NSString* ORSIS3302InternalTriggerEnabledChanged;
extern NSString* ORSIS3302ExternalTriggerEnabledChanged;
extern NSString* ORSIS3302InternalGateEnabledChanged;
extern NSString* ORSIS3302ExternalGateEnabledChanged;
extern NSString* ORSIS3302McaStatusChanged;
