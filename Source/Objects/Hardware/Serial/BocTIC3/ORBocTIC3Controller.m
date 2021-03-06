//--------------------------------------------------------
// ORBocTIC3Controller
// Created by Mark  A. Howe on Mon Aug 27 2007
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

#import "ORBocTIC3Controller.h"
#import "ORBocTIC3Model.h"
#import "ORTimeLinePlot.h"
#import "ORCompositePlotView.h"
#import "ORTimeAxis.h"
#import "ORSerialPortList.h"
#import "ORSerialPort.h"
#define __CARBONSOUND__ //temp until undated to >10.3
#import <Carbon/Carbon.h>
#import "ORTimeRate.h"

@interface ORBocTIC3Controller (private)
- (void) populatePortListPopup;
@end

@implementation ORBocTIC3Controller

#pragma mark ***Initialization

- (id) init
{
	self = [super initWithWindowNibName:@"BocTIC3"];
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
    [[plotter0 yAxis] setRngLow:0.0 withHigh:1000.];
	[[plotter0 yAxis] setRngLimitsLow:0.0 withHigh:100000 withMinRng:10];

    [[plotter0 xAxis] setRngLow:0.0 withHigh:10000];
	[[plotter0 xAxis] setRngLimitsLow:0.0 withHigh:200000. withMinRng:200];

	int i;
	for(i=0;i<3;i++){
		ORTimeLinePlot* aPlot;
		aPlot= [[ORTimeLinePlot alloc] initWithTag:i andDataSource:self];
		[plotter0 addPlot: aPlot];
		[aPlot setLineColor:[self colorForDataSet:i]];

		[(ORTimeAxis*)[plotter0 xAxis] setStartTime: [[NSDate date] timeIntervalSince1970]];
		[aPlot release];
	}
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
                         name : ORBocTIC3Lock
                        object: nil];

    [notifyCenter addObserver : self
                     selector : @selector(portNameChanged:)
                         name : ORBocTIC3ModelPortNameChanged
                        object: nil];

    [notifyCenter addObserver : self
                     selector : @selector(portStateChanged:)
                         name : ORSerialPortStateChanged
                       object : nil];
                                              
    [notifyCenter addObserver : self
                     selector : @selector(pressureChanged:)
                         name : ORBocTIC3PressureChanged
                       object : nil];

    [notifyCenter addObserver : self
                     selector : @selector(pollTimeChanged:)
                         name : ORBocTIC3ModelPollTimeChanged
                       object : nil];

    [notifyCenter addObserver : self
                     selector : @selector(shipPressuresChanged:)
                         name : ORBocTIC3ModelShipPressuresChanged
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
                     selector : @selector(pressureScaleChanged:)
                         name : ORBocTIC3ModelPressureScaleChanged
						object: model];

}

- (void) setModel:(id)aModel
{
	[super setModel:aModel];
	[[self window] setTitle:[NSString stringWithFormat:@"BOC TIC (Unit %lu)",[model uniqueIdNumber]]];
}

- (void) updateWindow
{
    [super updateWindow];
    [self lockChanged:nil];
    [self portStateChanged:nil];
    [self portNameChanged:nil];
	[self pressureChanged:nil];
	[self pollTimeChanged:nil];
	[self shipPressuresChanged:nil];
	[self updateTimePlot:nil];
    [self miscAttributesChanged:nil];
	[self pressureScaleChanged:nil];
}

- (void) pressureScaleChanged:(NSNotification*)aNote
{
	[pressureScalePU selectItemAtIndex: [model pressureScale]];
	[plotter0 setNeedsDisplay:YES];
}

- (void) scaleAction:(NSNotification*)aNotification
{
	if(aNotification == nil || [aNotification object] == [plotter0 xAxis]){
		[model setMiscAttributes:[(ORAxis*)[plotter0 xAxis]attributes] forKey:@"XAttributes0"];
	};
	
	if(aNotification == nil || [aNotification object] == [plotter0 yAxis]){
		[model setMiscAttributes:[(ORAxis*)[plotter0 yAxis]attributes] forKey:@"YAttributes0"];
	};

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

- (void) shipPressuresChanged:(NSNotification*)aNote
{
	[shipPressuresButton setIntValue: [model shipPressures]];
}

- (void) pressureChanged:(NSNotification*)aNote
{
	if(aNote){
		int index = [[[aNote userInfo] objectForKey:@"Index"] intValue];
		[self loadPressureTimeValuesForIndex:index];
	}
	else {
		int i;
		for(i=0;i<3;i++){
			[self loadPressureTimeValuesForIndex:i];
		}
	}
}

- (void) loadPressureTimeValuesForIndex:(int)index
{
	NSString* pressureAsString = [NSString stringWithFormat:@"%.2E",[model pressure:index]];
	[[pressureMatrix cellWithTag:index] setStringValue:pressureAsString];
	[[pressure1Matrix cellWithTag:index] setStringValue:pressureAsString];
	unsigned long t = [model timeMeasured:index];
	NSDate* theDate;
	if(t){
		theDate = [NSDate dateWithTimeIntervalSince1970:t];
		[[timeMatrix cellWithTag:index] setObjectValue:[theDate descriptionFromTemplate:@"MM/dd HH:mm:ss"]];
	}
	else [[timeMatrix cellWithTag:index] setObjectValue:@"--"];
}

- (void) checkGlobalSecurity
{
    BOOL secure = [[[NSUserDefaults standardUserDefaults] objectForKey:OROrcaSecurityEnabled] boolValue];
    [gSecurity setLock:ORBocTIC3Lock to:secure];
    [lockButton setEnabled:secure];
}

- (void) lockChanged:(NSNotification*)aNotification
{

    BOOL runInProgress = [gOrcaGlobals runInProgress];
    BOOL lockedOrRunningMaintenance = [gSecurity runInProgressButNotType:eMaintenanceRunType orIsLocked:ORBocTIC3Lock];
    BOOL locked = [gSecurity isLocked:ORBocTIC3Lock];

    [lockButton setState: locked];

    [portListPopup setEnabled:!locked];
    [openPortButton setEnabled:!locked];
    [pollTimePopup setEnabled:!locked];
    [shipPressuresButton setEnabled:!locked];
    
    NSString* s = @"";
    if(lockedOrRunningMaintenance){
        if(runInProgress && ![gSecurity isLocked:ORBocTIC3Lock])s = @"Not in Maintenance Run.";
    }
    [lockDocField setStringValue:s];

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

- (void) pressureScaleAction:(id)sender
{
	[model setPressureScale:[sender indexOfSelectedItem]];	
}

- (void) shipPressuresAction:(id)sender
{
	[model setShipPressures:[sender intValue]];	
}

- (IBAction) lockAction:(id) sender
{
    [gSecurity tryToSetLock:ORBocTIC3Lock to:[sender intValue] forWindow:[self window]];
}

- (IBAction) portListAction:(id) sender
{
    [model setPortName: [portListPopup titleOfSelectedItem]];
}

- (IBAction) openPortAction:(id)sender
{
    [model openPort:![[model serialPort] isOpen]];
}

- (IBAction) readPressuresAction:(id)sender
{
	[model readPressures];
}

- (IBAction) pollTimeAction:(id)sender
{
	[model setPollTime:[[sender selectedItem] tag]];
}


#pragma mark ���Data Source

- (NSColor*) colorForDataSet:(int)set
{
	if(set==0)return [NSColor redColor];
	else if(set==1)return [NSColor orangeColor];
	else if(set==2)return [NSColor blueColor];
	else return [NSColor blackColor];
}

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
	*xValue = [[model timeRate:set] timeSampledAtIndex:index];
	*yValue = [[model timeRate:set] valueAtIndex:index] * [model pressureScaleValue];
}

@end

@implementation ORBocTIC3Controller (private)

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

