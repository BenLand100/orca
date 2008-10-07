//
//  ORUnivVoltController.h
//  Orca
//
//  Created by Jan Wouters on Tues June 24, 2008
//  Copyright (c) 2008, LANS. All rights reserved.
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

#import "OrcaObjectController.h"
//#import "ORCard.h"


@interface ORUnivVoltController : OrcaObjectController {
	IBOutlet NSTableView*			mChnlTable;
	IBOutlet NSButton*				mChnlEnabled;
	IBOutlet NSStepper*				mChannelStepperField;
	IBOutlet NSTextField*			mChannelNumberField;
	IBOutlet NSTextField*			mDemandHV;
	IBOutlet NSTextField*			mMeasuredHV;
	IBOutlet NSTextField*			mMeasuredCurrent;
	IBOutlet NSTextField*			mTripCurrent;
	IBOutlet NSTextField*			mStatus;
	IBOutlet NSTextField*			mRampUpRate;
	IBOutlet NSTextField*			mRampDownRate;
	IBOutlet NSTextField*			mMVDZ;				// measured HV dead zone.  Reading has to change by more than this amount for measured HV to update.
	IBOutlet NSTextField*			mMCDZ;				// measured current dead zone.  "
	IBOutlet NSTextField*			mHVLimit;
	IBOutlet NSTextField*			mCmdStatus;			// Status of executed command.
	char							mStatusByte;
	int								mCurrentChnl;		// Current channel visible in display.
}

#pragma mark •••Notifications
- (void) updateWindow;
- (void) channelEnabledChanged: (NSNotification*) aNote;
- (void) measuredCurrentChanged: (NSNotification*) aNote;
- (void) measuredHVChanged: (NSNotification*) aNote;
- (void) demandHVChanged: (NSNotification*) aNote;
- (void) rampUpRateChanged: (NSNotification*) aNote;
- (void) rampDownRateChanged: (NSNotification*) aNote;
- (void) tripCurrentChanged: (NSNotification*) aNote;
- (void) statusChanged: (NSNotification*) aNotes;
- (void) MVDZChanged: (NSNotification*) aNote;
- (void) MCDZChanged: (NSNotification*) aNote;
- (void) hvLimitChanged: (NSNotification*) aNote;
- (void) writeErrorMsg: (NSNotification*) aNote;
//- (void) settingsLockChanged:(NSNotification*)aNote;

#pragma mark •••Actions
- (IBAction) setChannelNumberField: (id) aSender;
- (IBAction) setChannelNumberStepper: (id) aSender;
- (IBAction) setDemandHV: (id) aSender;
- (IBAction) setChnlEnabled: (id) aSender;
- (IBAction) setTripCurrent: (id) aSender;
- (IBAction) setRampUpRate: (id) aSender;
- (IBAction) setRampDownRate: (id) aSender;
- (IBAction) setMVDZ: (id) aSender;
- (IBAction) setMCDZ: (id) aSender;
- (IBAction) setHardwareValues: (id) aSender;
- (IBAction) hardwareValues: (id) aSender;
//- (IBAction) updateTable: (id) aSender;

#pragma mark ***Getters
//- (float) demandHV: (int) aChannel;
//- (bool) isChnlEnabled: (int) aChannel;
//- (bool) chnlEnabled: (int) aChannel;
//- (float) measuredCurrent: (int) aChannel;
//- (float) tripCurrent: (int) aChannel;
//- (float) rampUpRate: (int) aChannel;
//- (float) demandHV: (int) aChannel;

#pragma mark ***Data methods
- (int) numberOfRowsInTableView: (NSTableView*) aTableView;
- (void) tableView: (NSTableView*) aTableView
       setObjectValue: (id) anObject
	   forTableColumn: (NSTableColumn*) aTableColumn
	   row: (int) aRowIndex;
- (id) tableView: (NSTableView*) aTableView
	   objectValueForTableColumn: (NSTableColumn*) aTableColumn
	   row: (int) aRowIndex;

#pragma mark ***Accessors

#pragma mark ***Utilities
- (void) setChnlValues: (int) aCurrentChannel;

@end

