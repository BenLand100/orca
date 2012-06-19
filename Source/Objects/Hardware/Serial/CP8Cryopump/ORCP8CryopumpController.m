//--------------------------------------------------------
// ORCP8CryopumpController
// Created by Mark Howe Tuesday, March 20,2012
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2012, University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//North Carolina sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//North Carolina reserve all rights in the program. Neither the authors,
//University of North Carolina, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------

#pragma mark ***Imported Files

#import "ORCP8CryopumpController.h"
#import "ORCP8CryopumpModel.h"
#import "ORTimeLinePlot.h"
#import "ORCompositePlotView.h"
#import "ORTimeAxis.h"
#import "ORSerialPortList.h"
#import "ORSerialPort.h"
#import "ORTimeRate.h"
#import "BiStateView.h"

@interface ORCP8CryopumpController (private)
- (void) populatePortListPopup;
@end

@implementation ORCP8CryopumpController

#pragma mark ***Initialization

- (id) init
{
	self = [super initWithWindowNibName:@"CP8Cryopump"];
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void) awakeFromNib
{
    [self populatePortListPopup];
    [[plotter0 yAxis] setRngLow:-1000. withHigh:1000.];
	[[plotter0 yAxis] setRngLimitsLow:-100000 withHigh:100000 withMinRng:10];
	[plotter0 setUseGradient:YES];

    [[plotter0 xAxis] setRngLow:0.0 withHigh:10000];
	[[plotter0 xAxis] setRngLimitsLow:0.0 withHigh:200000. withMinRng:200];

	ORTimeLinePlot* aPlot;
	aPlot= [[ORTimeLinePlot alloc] initWithTag:0 andDataSource:self];
	[plotter0 addPlot: aPlot];
    [aPlot setName:@"First Stage"];
	[aPlot setLineColor:[NSColor redColor]];

	aPlot= [[ORTimeLinePlot alloc] initWithTag:1 andDataSource:self];
	[plotter0 addPlot: aPlot];
    [aPlot setName:@"Second Stage"];
	[aPlot setLineColor:[NSColor blueColor]];
    
	[plotter0 setPlotTitle:@"Temperatures"];
	[plotter0 setShowLegend:YES];

    
	[(ORTimeAxis*)[plotter0 xAxis] setStartTime: [[NSDate date] timeIntervalSince1970]];
	[aPlot release];
	
	//NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	//[numberFormatter setFormat:@"#0.0"];	
	[super awakeFromNib];
}

#pragma mark ***Notifications
- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
    [super registerNotificationObservers];
    [notifyCenter addObserver : self
                     selector : @selector(lockChanged:)
                         name : ORRunStatusChangedNotification
                       object : nil];
    
    [notifyCenter addObserver : self
                     selector : @selector(lockChanged:)
                         name : ORCP8CryopumpLock
                        object: nil];

    [notifyCenter addObserver : self
                     selector : @selector(portNameChanged:)
                         name : ORCP8CryopumpPortNameChanged
                        object: nil];

    [notifyCenter addObserver : self
                     selector : @selector(portStateChanged:)
                         name : ORSerialPortStateChanged
                       object : nil];
                                                   
    [notifyCenter addObserver : self
                     selector : @selector(pollTimeChanged:)
                         name : ORCP8CryopumpPollTimeChanged
                       object : nil];

    [notifyCenter addObserver : self
                     selector : @selector(shipTemperaturesChanged:)
                         name : ORCP8CryopumpShipTemperaturesChanged
						object: model];

    [notifyCenter addObserver : self
					 selector : @selector(scaleAction:)
						 name : ORAxisRangeChangedNotification
					   object : nil];

    [notifyCenter addObserver : self
					 selector : @selector(miscAttributesChanged:)
						 name : ORMiscAttributesChanged
					   object : model];

    [notifyCenter addObserver : self
					 selector : @selector(updateTimePlot:)
						 name : ORRateAverageChangedNotification
					   object : nil];
    [notifyCenter addObserver : self
                     selector : @selector(dutyCycleChanged:)
                         name : ORCP8CryopumpModelDutyCycleChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(elapsedTimeChanged:)
                         name : ORCP8CryopumpModelElapsedTimeChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(failedRateRiseCyclesChanged:)
                         name : ORCP8CryopumpModelFailedRateRiseCyclesChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(failedRepurgeCyclesChanged:)
                         name : ORCP8CryopumpModelFailedRepurgeCyclesChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(firstStageTempChanged:)
                         name : ORCP8CryopumpModelFirstStageTempChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(firstStageControlTempChanged:)
                         name : ORCP8CryopumpModelFirstStageControlTempChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(firstStageControlMethodChanged:)
                         name : ORCP8CryopumpModelFirstStageControlMethodChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(lastRateOfRaiseChanged:)
                         name : ORCP8CryopumpModelLastRateOfRaiseChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(moduleVersionChanged:)
                         name : ORCP8CryopumpModelModuleVersionChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(powerFailureRecoveryChanged:)
                         name : ORCP8CryopumpModelPowerFailureRecoveryChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(powerFailureRecoveryStatusChanged:)
                         name : ORCP8CryopumpModelPowerFailureRecoveryStatusChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(pumpStatusChanged:)
                         name : ORCP8CryopumpModelPumpStatusChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(purgeStatusChanged:)
                         name : ORCP8CryopumpModelPurgeStatusChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(regenerationCyclesChanged:)
                         name : ORCP8CryopumpModelRegenerationCyclesChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(regenerationErrorChanged:)
                         name : ORCP8CryopumpModelRegenerationErrorChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(regenerationSequenceChanged:)
                         name : ORCP8CryopumpModelRegenerationSequenceChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(regenerationStartDelayChanged:)
                         name : ORCP8CryopumpModelRegenerationStartDelayChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(regenerationStepTimerChanged:)
                         name : ORCP8CryopumpModelRegenerationStepTimerChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(regenerationTimeChanged:)
                         name : ORCP8CryopumpModelRegenerationTimeChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(roughValveStatusChanged:)
                         name : ORCP8CryopumpModelRoughValveStatusChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(roughValveInterlockChanged:)
                         name : ORCP8CryopumpModelRoughValveInterlockChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(secondStageTempChanged:)
                         name : ORCP8CryopumpModelSecondStageTempChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(statusChanged:)
                         name : ORCP8CryopumpModelStatusChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(thermocoupleStatusChanged:)
                         name : ORCP8CryopumpModelThermocoupleStatusChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(thermocouplePressureChanged:)
                         name : ORCP8CryopumpModelThermocouplePressureChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(thermocouplePressureChanged:)
                         name : ORCP8CryopumpModelThermocouplePressureChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(pumpRestartDelayChanged:)
                         name : ORCP8CryopumpModelPumpRestartDelayChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(extendedPurgeTimeChanged:)
                         name : ORCP8CryopumpModelExtendedPurgeTimeChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(repurgeCyclesChanged:)
                         name : ORCP8CryopumpModelRepurgeCyclesChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(roughToPressureChanged:)
                         name : ORCP8CryopumpModelRoughToPressureChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(rateOfRiseChanged:)
                         name : ORCP8CryopumpModelRateOfRiseChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(rateOfRiseCyclesChanged:)
                         name : ORCP8CryopumpModelRateOfRiseCyclesChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(restartTemperatureChanged:)
                         name : ORCP8CryopumpModelRestartTemperatureChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(roughingInterlockStatusChanged:)
                         name : ORCP8CryopumpModelRoughingInterlockStatusChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(pumpsPerCompressorChanged:)
                         name : ORCP8CryopumpModelPumpsPerCompressorChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(repurgeTimeChanged:)
                         name : ORCP8CryopumpModelRepurgeTimeChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(standbyModeChanged:)
                         name : ORCP8CryopumpModelStandbyModeChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(roughingInterlockChanged:)
                         name : ORCP8CryopumpModelRoughingInterlockChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(secondStageTempControlChanged:)
                         name : ORCP8CryopumpModelSecondStageTempControlChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(cmdErrorChanged:)
                         name : ORCP8CryopumpModelCmdErrorChanged
						object: model];
    
    [notifyCenter addObserver : self
                     selector : @selector(wasPowerFailureChanged:)
                         name : ORCP8CryopumpModelWasPowerFailireChanged
						object: model];
   
	[notifyCenter addObserver : self
                     selector : @selector(involvedInProcessChanged:)
                         name : ORCP8CryopumpModelInvolvedInProcessChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(firstStageControlMethodRBChanged:)
                         name : ORCP8CryopumpModelFirstStageControlMethodRBChanged
						object: model];

}

- (void) involvedInProcessChanged:(NSNotification*)aNote
{
	[self lockChanged:nil];
}

- (void) setModel:(id)aModel
{
	[super setModel:aModel];
	[[self window] setTitle:[NSString stringWithFormat:@"CP-8 (Unit %d)",[model uniqueIdNumber]]];
}

- (void) updateWindow
{
    [super updateWindow];
    [self wasPowerFailureChanged:nil];
    [self cmdErrorChanged:nil];
    [self lockChanged:nil];
    [self portStateChanged:nil];
    [self portNameChanged:nil];
	[self pollTimeChanged:nil];
	[self shipTemperaturesChanged:nil];
	[self updateTimePlot:nil];
    [self miscAttributesChanged:nil];
	[self dutyCycleChanged:nil];
	[self elapsedTimeChanged:nil];
	[self failedRateRiseCyclesChanged:nil];
	[self failedRepurgeCyclesChanged:nil];
	[self firstStageTempChanged:nil];
	[self firstStageControlTempChanged:nil];
	[self firstStageControlMethodChanged:nil];
	[self lastRateOfRaiseChanged:nil];
	[self moduleVersionChanged:nil];
	[self powerFailureRecoveryChanged:nil];
	[self powerFailureRecoveryStatusChanged:nil];
	[self pumpStatusChanged:nil];
	[self purgeStatusChanged:nil];
	[self regenerationCyclesChanged:nil];
	[self regenerationErrorChanged:nil];
	[self regenerationSequenceChanged:nil];
	[self regenerationStartDelayChanged:nil];
	[self regenerationStepTimerChanged:nil];
	[self regenerationTimeChanged:nil];
	[self roughValveStatusChanged:nil];
	[self roughValveInterlockChanged:nil];
	[self secondStageTempChanged:nil];
	[self statusChanged:nil];
	[self thermocoupleStatusChanged:nil];
	[self thermocouplePressureChanged:nil];
	[self thermocouplePressureChanged:nil];
	[self pumpRestartDelayChanged:nil];
	[self extendedPurgeTimeChanged:nil];
	[self repurgeCyclesChanged:nil];
	[self roughToPressureChanged:nil];
	[self rateOfRiseChanged:nil];
	[self rateOfRiseCyclesChanged:nil];
	[self restartTemperatureChanged:nil];
	[self roughingInterlockStatusChanged:nil];
	[self pumpsPerCompressorChanged:nil];
	[self repurgeTimeChanged:nil];
	[self standbyModeChanged:nil];
	[self roughingInterlockChanged:nil];
	[self secondStageTempControlChanged:nil];
	[self firstStageControlMethodRBChanged:nil];
}

- (void) firstStageControlMethodRBChanged:(NSNotification*)aNote
{
	[firstStageControlMethodRBField setStringValue: [model firstStageControlMethodString]];
}

- (void) wasPowerFailureChanged:(NSNotification*)aNote
{
	[wasPowerFailureField setStringValue: [model wasPowerFailure]?@"There was a Power Failure":@"" ];
}

- (void) cmdErrorChanged:(NSNotification*)aNote
{
	[cmdErrorField setIntValue: [model cmdError]];
}

- (void) secondStageTempControlChanged:(NSNotification*)aNote
{
	[secondStageTempControlField setIntValue: [model secondStageTempControl]];
}

- (void) roughingInterlockChanged:(NSNotification*)aNote
{
	[roughingInterlockPU selectItemAtIndex: [model roughingInterlock]];
}

- (void) standbyModeChanged:(NSNotification*)aNote
{
	[standbyModePU selectItemAtIndex: [model standbyMode]];
}

- (void) repurgeTimeChanged:(NSNotification*)aNote
{
	[repurgeTimeField setIntValue: [model repurgeTime]];
}

- (void) pumpsPerCompressorChanged:(NSNotification*)aNote
{
	[pumpsPerCompressorField setIntValue: [model pumpsPerCompressor]];
}

- (void) roughingInterlockStatusChanged:(NSNotification*)aNote
{
	int mask = [model roughingInterlockStatus];
	[roughingInterlockStatusField setStringValue:  (mask & 0x1) ? @"Has Permission"         : @"Not Using/No Permission"];
	[roughingInterlockStatusField1 setStringValue: (mask & 0x2) ? @"Needs Roughing Manifold": @""];	
	[roughingInterlockStatusField2 setStringValue: (mask & 0x4) ? @"Cryopump running"       : @""];
}

- (void) restartTemperatureChanged:(NSNotification*)aNote
{
	[restartTemperatureField setIntValue: [model restartTemperature]];
}

- (void) rateOfRiseCyclesChanged:(NSNotification*)aNote
{
	[rateOfRiseCyclesField setIntValue: [model rateOfRiseCycles]];
}

- (void) rateOfRiseChanged:(NSNotification*)aNote
{
	[rateOfRiseField setIntValue: [model rateOfRise]];
}

- (void) roughToPressureChanged:(NSNotification*)aNote
{
	[roughToPressureField setIntValue: [model roughToPressure]];
}

- (void) repurgeCyclesChanged:(NSNotification*)aNote
{
	[repurgeCyclesField setIntValue: [model repurgeCycles]];
}

- (void) extendedPurgeTimeChanged:(NSNotification*)aNote
{
	[extendedPurgeTimeField setIntValue: [model extendedPurgeTime]];
}

- (void) pumpRestartDelayChanged:(NSNotification*)aNote
{
	[pumpRestartDelayField setIntValue: [model pumpRestartDelay]];
}

- (void) thermocouplePressureChanged:(NSNotification*)aNote
{
	[thermocouplePressureField setFloatValue: [model thermocouplePressure]];
}

- (void) thermocoupleStatusChanged:(NSNotification*)aNote
{
	[thermocoupleStatusField setStringValue: [model thermocoupleStatus]?@"ON":@"OFF"];
	[self updateButtons];
}

- (void) statusChanged:(NSNotification*)aNote
{
	int mask = [model status];
	[pumpOnBiStateView				 setState: mask & (0x1<<0)];
	[roughOpenBiStateView			 setState: (mask & (0x1<<1))>0];
	[purgeOpenBiStateView			 setState: (mask & (0x1<<2))>0];
	[thermocoupleOnBiStateView		 setState: (mask & (0x1<<3))>0];
	[powerFailureOccurredBiStateView setState: (mask & (0x1<<4))>0];
}

- (void) secondStageTempChanged:(NSNotification*)aNote
{
	[secondStageTempField setFloatValue: [model secondStageTemp]];
}

- (void) roughValveInterlockChanged:(NSNotification*)aNote
{
	[roughValveInterlockField setIntValue: [model roughValveInterlock]];
}

- (void) roughValveStatusChanged:(NSNotification*)aNote
{
	[roughValveStatusField setStringValue: [model roughValveStatus]?@"OPEN":@"CLOSED"];
	[self updateButtons];
}

- (void) regenerationTimeChanged:(NSNotification*)aNote
{
	[regenerationTimeField setIntValue: [model regenerationTime]];
}

- (void) regenerationStepTimerChanged:(NSNotification*)aNote
{
	[regenerationStepTimerField setIntValue: [model regenerationStepTimer]];
}

- (void) regenerationStartDelayChanged:(NSNotification*)aNote
{
	[regenerationStartDelayField setIntValue: [model regenerationStartDelay]];
}

- (void) regenerationSequenceChanged:(NSNotification*)aNote
{
	NSString* s = @"--";
	switch([model regenerationSequence]){
		case 'Z': s = @"Start Delay";						break;
		case 'A': s = @"20s cancelation delay";				break;
		case 'B': 
		case 'C': 
		case 'D': 
		case 'E': 
			s = [NSString stringWithFormat:@"Cryopump Warm up: %c",	(char)[model regenerationSequence]];		
		break;
		case 'H': s = @"Extended Purge/Repurge Cycle";		break;
		case 'J': s = @"Waiting on Roughing Clearance";		break;
		case 'L': s = @"Rate of Rise";						break;
		case 'M': s = @"Cool Down";							break;
		case 'P': s = @"Regen Completed";					break;
		case 'T': s = @"Roughging";							break;
		case 'W': s = @"Restart Delay";						break;
		case 'V': s = @"Regen Aborted";						break;
		case 'z': s = @"Pump Ready in Standby Mode";		break;
		case 's': s = @"Cryopump Stopped After Warmup";		break;
	}
	[regenerationSequenceField setStringValue: s];
	[self updateButtons];
}

- (void) regenerationErrorChanged:(NSNotification*)aNote
{
	NSString* s = @"--";
	switch([model regenerationError]){
		case '@': s = @"No Error";					break;
		case 'B': s = @"Warm up Timeout";			break;
		case 'C': s = @"Cool Down Timeout";			break;
		case 'D': s = @"Roughing Error";			break;
		case 'E': s = @"Rate of Rise Limit";		break;
		case 'F': s = @"Manual Abort";				break;
		case 'G': s = @"Rough Valve Timeout";		break;
		case 'H': s = @"Illegal State";				break;
	}
	[regenerationErrorField setStringValue: s];
}

- (void) regenerationCyclesChanged:(NSNotification*)aNote
{
	[regenerationCyclesField setIntValue: [model regenerationCycles]];
}

- (void) purgeStatusChanged:(NSNotification*)aNote
{
	[purgeStatusField setStringValue: [model purgeStatus]?@"OPEN":@"CLOSED"];
	[self updateButtons];
}

- (void) pumpStatusChanged:(NSNotification*)aNote
{
	[pumpStatusField setStringValue: [model pumpStatus]?@"ON":@"OFF"];
	[self updateButtons];
}

- (void) powerFailureRecoveryStatusChanged:(NSNotification*)aNote
{
	NSString* s = @"Status: --";
	switch([model powerFailureRecoveryStatus]){
		case 0: s = @"Status: No pwr fail recovery in progress"; break;
		case 1: s = @"Status: Cool down in progress";			 break;
		case 2: s = @"Status: Regeneration in progress";		 break;
		case 3: s = @"Status: Attempting to cool to 17K";		 break;
		case 4: s = @"Status: Recoverd pump to < 17K";			 break;
		case 5: s = @"Status: 2nd stage not recovering";		 break;
	}
	[powerFailureRecoveryStatusField setStringValue: s];
}

- (void) powerFailureRecoveryChanged:(NSNotification*)aNote
{
	[powerFailureRecoveryPU selectItemAtIndex: [model powerFailureRecovery]];
}

- (void) moduleVersionChanged:(NSNotification*)aNote
{
	[moduleVersionField setStringValue: [model moduleVersion]];
}

- (void) lastRateOfRaiseChanged:(NSNotification*)aNote
{
	[lastRateOfRaiseField setIntValue: [model lastRateOfRaise]];
}

- (void) firstStageControlMethodChanged:(NSNotification*)aNote
{
	[firstStageControlMethodPU selectItemAtIndex: [model firstStageControlMethod]];
}

- (void) firstStageControlTempChanged:(NSNotification*)aNote
{
	[firstStageControlTempField setIntValue: [model firstStageControlTemp]];
}

- (void) firstStageTempChanged:(NSNotification*)aNote
{
	[firstStageTempField setFloatValue: [model firstStageTemp]];
	unsigned long t = [model timeMeasured];
	NSCalendarDate* theDate;
	if(t){
		theDate = [NSCalendarDate dateWithTimeIntervalSince1970:t];
		[theDate setCalendarFormat:@"%m/%d %H:%M:%S"];
		[timeField setObjectValue:theDate];
	}
	else [timeField setObjectValue:@"--"];
}

- (void) failedRepurgeCyclesChanged:(NSNotification*)aNote
{
	[failedRepurgeCyclesField setIntValue: [model failedRepurgeCycles]];
}

- (void) failedRateRiseCyclesChanged:(NSNotification*)aNote
{
	[failedRateRiseCyclesField setIntValue: [model failedRateRiseCycles]];
}

- (void) elapsedTimeChanged:(NSNotification*)aNote
{
	[elapsedTimeField setIntValue: [model elapsedTime]];
}

- (void) dutyCycleChanged:(NSNotification*)aNote
{
	[dutyCycleField setIntValue: [model dutyCycle]];
}

- (void) scaleAction:(NSNotification*)aNotification
{
	if(aNotification == nil || [aNotification object] == [plotter0 xAxis]){
		[model setMiscAttributes:[(ORAxis*)[plotter0 xAxis]attributes] forKey:@"XAttributes0"];
	}
	
	if(aNotification == nil || [aNotification object] == [plotter0 yAxis]){
		[model setMiscAttributes:[(ORAxis*)[plotter0 yAxis]attributes] forKey:@"YAttributes0"];
	}
}

- (void) miscAttributesChanged:(NSNotification*)aNote
{

	NSString*				key = [[aNote userInfo] objectForKey:ORMiscAttributeKey];
	NSMutableDictionary* attrib = [model miscAttributesForKey:key];
	
	if(aNote == nil || [key isEqualToString:@"XAttributes0"]){
		if(aNote==nil)attrib = [model miscAttributesForKey:@"XAttributes0"];
		if(attrib){
			[(ORAxis*)[plotter0 xAxis] setAttributes:attrib];
			[plotter0 setNeedsDisplay:YES];
			[[plotter0 xAxis] setNeedsDisplay:YES];
		}
	}
	if(aNote == nil || [key isEqualToString:@"YAttributes0"]){
		if(aNote==nil)attrib = [model miscAttributesForKey:@"YAttributes0"];
		if(attrib){
			[(ORAxis*)[plotter0 yAxis] setAttributes:attrib];
			[plotter0 setNeedsDisplay:YES];
			[[plotter0 yAxis] setNeedsDisplay:YES];
		}
	}
}

- (void) updateTimePlot:(NSNotification*)aNote
{
	if(!aNote || ([aNote object] == [model timeRate:0])){
		[plotter0 setNeedsDisplay:YES];
	}
}

- (void) shipTemperaturesChanged:(NSNotification*)aNote
{
	[shipTemperaturesButton setIntValue: [model shipTemperatures]];
}


- (void) checkGlobalSecurity
{
    BOOL secure = [[[NSUserDefaults standardUserDefaults] objectForKey:OROrcaSecurityEnabled] boolValue];
    [gSecurity setLock:ORCP8CryopumpLock to:secure];
    [lockButton setEnabled:secure];
}

- (void) lockChanged:(NSNotification*)aNotification
{

    BOOL locked = [gSecurity isLocked:ORCP8CryopumpLock];

    [lockButton setState: locked];
	[self updateButtons];
}

- (void) updateButtons
{
    BOOL locked = [gSecurity isLocked:ORCP8CryopumpLock];
	BOOL inProcess = [model involvedInProcess];
	
    [pollTimePopup					setEnabled:!locked && !inProcess];
    [portListPopup					setEnabled:!locked];
    [openPortButton					setEnabled:!locked];
    [shipTemperaturesButton			setEnabled:!locked];
 
	[secondStageTempControlField	setEnabled:!locked];
	[roughingInterlockPU			setEnabled:!locked];
	[standbyModePU					setEnabled:!locked];
	[repurgeTimeField				setEnabled:!locked];
	[pumpsPerCompressorField		setEnabled:!locked];
	[restartTemperatureField		setEnabled:!locked];
	[rateOfRiseCyclesField			setEnabled:!locked];
	[rateOfRiseField				setEnabled:!locked];
	[roughToPressureField			setEnabled:!locked];
	[repurgeCyclesField				setEnabled:!locked];
	[extendedPurgeTimeField			setEnabled:!locked];
	[pumpRestartDelayField			setEnabled:!locked];
	[regenerationTimeField			setEnabled:!locked];
	[regenerationStepTimerField		setEnabled:!locked];
	[regenerationStartDelayField	setEnabled:!locked];
	[powerFailureRecoveryPU			setEnabled:!locked];
	[firstStageControlMethodPU		setEnabled:!locked];
	[firstStageControlTempField		setEnabled:!locked];
    [initHardwareButton				setEnabled:!locked];
	[regenAbortButton				setEnabled:!locked];
	[regenStartFullButton			setEnabled:!locked];
	[regenStartFastButton			setEnabled:!locked];
	[regenActivateNormalPumpingButton setEnabled:!locked];
	[regenWarmAndStopButton			setEnabled:!locked];
	[initHardwareButton				setEnabled:!locked];
	
	int mask = [model roughingInterlockStatus];
	
	[roughValveInterlockButton		setEnabled:!locked && (mask & 0x2)];

	[pumpOnButton					setEnabled:!locked && [model pumpStatus]==NO];
	[pumpOffButton					setEnabled:!locked && [model pumpStatus]==YES];
	[purgeOnButton					setEnabled:!locked && [model purgeStatus]==NO];
	[purgeOffButton					setEnabled:!locked && [model purgeStatus]==YES];
	[roughingValveOpenButton		setEnabled:!locked && [model roughValveStatus]==NO];
	[roughingValveClosedButton		setEnabled:!locked && [model roughValveStatus]==YES];
	[thermocoupleOnButton			setEnabled:!locked  && [model thermocoupleStatus]==NO];
	[thermocoupleOffButton			setEnabled:!locked  && [model thermocoupleStatus]==YES];
	
}

- (void) portStateChanged:(NSNotification*)aNotification
{
    if(aNotification == nil || [aNotification object] == [model serialPort]){
        if([model serialPort]){
            [openPortButton setEnabled:YES];

            if([[model serialPort] isOpen]){
                [openPortButton setTitle:@"Close"];
                [portStateField setTextColor:[NSColor colorWithCalibratedRed:0.0 green:.8 blue:0.0 alpha:1.0]];
                [portStateField setStringValue:@"Open"];
            }
            else {
                [openPortButton setTitle:@"Open"];
                [portStateField setStringValue:@"Closed"];
                [portStateField setTextColor:[NSColor redColor]];
            }
        }
        else {
            [openPortButton setEnabled:NO];
            [portStateField setTextColor:[NSColor blackColor]];
            [portStateField setStringValue:@"---"];
            [openPortButton setTitle:@"---"];
        }
    }
}

- (void) pollTimeChanged:(NSNotification*)aNotification
{
	[pollTimePopup selectItemWithTag:[model pollTime]];
}

- (void) portNameChanged:(NSNotification*)aNotification
{
    NSString* portName = [model portName];
    
	NSEnumerator *enumerator = [ORSerialPortList portEnumerator];
	ORSerialPort *aPort;

    [portListPopup selectItemAtIndex:0]; //the default
    while (aPort = [enumerator nextObject]) {
        if([portName isEqualToString:[aPort name]]){
            [portListPopup selectItemWithTitle:portName];
            break;
        }
	}  
    [self portStateChanged:nil];
}

#pragma mark ***Actions
- (IBAction) roughingInterlockAction:(id)sender		  { [model setRoughingInterlock:		[sender indexOfSelectedItem]]; }
- (IBAction) standbyModeAction:(id)sender			  { [model setStandbyMode:				[sender indexOfSelectedItem]]; }
- (IBAction) secondStageTempControlAction:(id)sender  { [model setSecondStageTempControl:	[sender intValue]]; }
- (IBAction) repurgeTimeAction:(id)sender			  { [model setRepurgeTime:				[sender intValue]]; }
- (IBAction) pumpsPerCompressorAction:(id)sender	  { [model setPumpsPerCompressor:		[sender intValue]]; }
- (IBAction) restartTemperatureAction:(id)sender	  { [model setRestartTemperature:		[sender intValue]]; }
- (IBAction) rateOfRiseCyclesAction:(id)sender		  { [model setRateOfRiseCycles:			[sender intValue]]; }
- (IBAction) rateOfRiseAction:(id)sender			  { [model setRateOfRise:				[sender intValue]]; }
- (IBAction) roughToPressureAction:(id)sender		  { [model setRoughToPressure:			[sender intValue]]; }
- (IBAction) repurgeCyclesAction:(id)sender			  { [model setRepurgeCycles:			[sender intValue]]; }
- (IBAction) extendedPurgeTimeAction:(id)sender		  { [model setExtendedPurgeTime:		[sender intValue]]; }
- (IBAction) pumpRestartDelayAction:(id)sender		  { [model setPumpRestartDelay:			[sender intValue]]; }
- (IBAction) thermocoupleStatusAction:(id)sender	  { [model setThermocoupleStatus:		[sender intValue]]; }
- (IBAction) statusAction:(id)sender				  { [model setStatus:					[sender intValue]]; }
- (IBAction) roughValveInterlockAction:(id)sender	  { [model setRoughValveInterlock:		[sender intValue]]; }
- (IBAction) roughValveStatusAction:(id)sender		  { [model setRoughValveStatus:			[sender intValue]]; }
- (IBAction) regenerationStartDelayAction:(id)sender  { [model setRegenerationStartDelay:	[sender intValue]]; }
- (IBAction) powerFailureRecoveryAction:(id)sender	  { [model setPowerFailureRecovery:		[sender indexOfSelectedItem]]; }
- (IBAction) firstStageControlMethodAction:(id)sender { [model setFirstStageControlMethod:	[sender indexOfSelectedItem]]; }
- (IBAction) firstStageControlTempAction:(id)sender   { [model setFirstStageControlTemp:	[sender intValue]]; }
- (IBAction) shipTemperaturesAction:(id)sender		  { [model setShipTemperatures:			[sender intValue]]; }

- (IBAction) lockAction:(id) sender					  { [gSecurity tryToSetLock:ORCP8CryopumpLock to:[sender intValue] forWindow:[self window]];}
- (IBAction) portListAction:(id) sender				  { [model setPortName:	[portListPopup titleOfSelectedItem]];}
- (IBAction) openPortAction:(id)sender				  { [model openPort:![[model serialPort] isOpen]];}
- (IBAction) readTemperaturesAction:(id)sender		  { [model pollHardware];}
- (IBAction) pollTimeAction:(id)sender				  { [model setPollTime:[[sender selectedItem] tag]];}
- (IBAction) pollNowAction:(id)sender				  { [model pollHardware]; }

- (IBAction) initHardwareAction:(id)sender			  
{ 
	[self endEditing];
	[model initHardware];
}

- (IBAction) turnCryoPumpOnAction:(id)sender
{
    [self endEditing];
	NSBeginAlertSheet(@"Turn ON Cryo Pump",
					  @"YES/Turn ON Cryopump",
					  @"Cancel",
					  nil,[self window],
					  self,
					  @selector(turnOnCryoPumpDidFinish:returnCode:contextInfo:),
					  nil,
					  nil,
					  @"Really turn ON the cryopump?");
}

- (void) turnOnCryoPumpDidFinish:(id)sheet returnCode:(int)returnCode contextInfo:(id)userInfo
{
	if(returnCode == NSAlertDefaultReturn)[model writeCryoPumpOn:YES];
}

- (IBAction) turnCryoPumpOffAction:(id)sender
{
    [self endEditing];
	NSBeginAlertSheet(@"Turn OFF Cryo Pump",
					  @"YES/Turn OFF Cryopump",
					  @"Cancel",
					  nil,[self window],
					  self,
					  @selector(turnOffCryoPumpDidFinish:returnCode:contextInfo:),
					  nil,
					  nil,
					  @"Really turn OFF the cryopump?");
}

- (void) turnOffCryoPumpDidFinish:(id)sheet returnCode:(int)returnCode contextInfo:(id)userInfo
{
	if(returnCode == NSAlertDefaultReturn)[model writeCryoPumpOn:NO];
}

- (IBAction) openPurgeValveAction:(id)sender
{
    [self endEditing];
	NSBeginAlertSheet(@"Open Purge Valve",
					  @"YES/OPEN Purge Valve",
					  @"Cancel",
					  nil,[self window],
					  self,
					  @selector(openPurgeValveDidFinish:returnCode:contextInfo:),
					  nil,
					  nil,
					  @"Really OPEN the purge valve?");
}

- (void) openPurgeValveDidFinish:(id)sheet returnCode:(int)returnCode contextInfo:(id)userInfo
{
	if(returnCode == NSAlertDefaultReturn)[model writePurgeValveOpen:YES];
}

- (IBAction) closePurgeValveAction:(id)sender
{
    [self endEditing];
	NSBeginAlertSheet(@"Close Purge Valve",
					  @"YES/CLOSE Purge Valve",
					  @"Cancel",
					  nil,[self window],
					  self,
					  @selector(closePurgeValveDidFinish:returnCode:contextInfo:),
					  nil,
					  nil,
					  @"Really CLOSE the purge valve?");
}

- (void) closePurgeValveDidFinish:(id)sheet returnCode:(int)returnCode contextInfo:(id)userInfo
{
	if(returnCode == NSAlertDefaultReturn)[model writePurgeValveOpen:NO];
}

- (IBAction) openRoughingValveAction:(id)sender
{
    [self endEditing];
	NSBeginAlertSheet(@"Open Roughing Valve",
					  @"YES/OPEN Roughing Valve",
					  @"Cancel",
					  nil,[self window],
					  self,
					  @selector(openRoughingValveDidFinish:returnCode:contextInfo:),
					  nil,
					  nil,
					  @"Really OPEN the Roughing valve?");
}

- (void) openRoughingValveDidFinish:(id)sheet returnCode:(int)returnCode contextInfo:(id)userInfo
{
	if(returnCode == NSAlertDefaultReturn)[model writeRoughValveOpen:YES];
}

- (IBAction) closeRoughingValveAction:(id)sender
{
    [self endEditing];
	NSBeginAlertSheet(@"Close Roughing Valve",
					  @"YES/CLOSE Roughing Valve",
					  @"Cancel",
					  nil,[self window],
					  self,
					  @selector(closeRoughingValveDidFinish:returnCode:contextInfo:),
					  nil,
					  nil,
					  @"Really CLOSE the Roughing valve?");
}

- (void) closeRoughingValveDidFinish:(id)sheet returnCode:(int)returnCode contextInfo:(id)userInfo
{
	if(returnCode == NSAlertDefaultReturn)[model writeRoughValveOpen:NO];
}

- (IBAction) turnThermocoupleOnAction:(id)sender
{
    [self endEditing];
	NSBeginAlertSheet(@"Turn ON Cryo Pump",
					  @"YES/Turn ON Thermocouple",
					  @"Cancel",
					  nil,[self window],
					  self,
					  @selector(turnOnThermocoupleDidFinish:returnCode:contextInfo:),
					  nil,
					  nil,
					  @"Really turn ON the Thermocouple?");
}

- (void) turnOnThermocoupleDidFinish:(id)sheet returnCode:(int)returnCode contextInfo:(id)userInfo
{
	if(returnCode == NSAlertDefaultReturn)[model writeThermocoupleOn:YES];
}

- (IBAction) turnThermocoupleOffAction:(id)sender
{
    [self endEditing];
	NSBeginAlertSheet(@"Turn OFF Cryo Pump",
					  @"YES/Turn OFF Thermocouple",
					  @"Cancel",
					  nil,[self window],
					  self,
					  @selector(turnOnThermocoupleDidFinish:returnCode:contextInfo:),
					  nil,
					  nil,
					  @"Really turn OFF the Thermocouple?");
}

- (void) turnOffThermocoupleDidFinish:(id)sheet returnCode:(int)returnCode contextInfo:(id)userInfo
{
	if(returnCode == NSAlertDefaultReturn)[model writeThermocoupleOn:NO];
}


#pragma mark ***Data Source
- (int) numberPointsInPlot:(id)aPlotter
{
	int set = [aPlotter tag];
	return [[model timeRate:set] count];
}

- (void) plotter:(id)aPlotter index:(int)i x:(double*)xValue y:(double*)yValue
{
	int set = [aPlotter tag];
	int count = [[model timeRate:set] count];
	int index = count-i-1;
	*xValue = [[model timeRate:set]timeSampledAtIndex:index];
	*yValue = [[model timeRate:set] valueAtIndex:index];
}
@end

@implementation ORCP8CryopumpController (private)

- (void) populatePortListPopup
{
	NSEnumerator *enumerator = [ORSerialPortList portEnumerator];
	ORSerialPort *aPort;
    [portListPopup removeAllItems];
    [portListPopup addItemWithTitle:@"--"];

	while (aPort = [enumerator nextObject]) {
        [portListPopup addItemWithTitle:[aPort name]];
	}    
}
@end

