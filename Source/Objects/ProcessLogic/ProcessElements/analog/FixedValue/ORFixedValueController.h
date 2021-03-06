//
//  ORFixedValueController.h
//  Orca
//
//  Created by Mark Howe on Jan 29 2013.
//  Copyright (c) 2013  University of North Carolina. All rights reserved.
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

#pragma mark •••Imported Files
#import "ORProcessHwAccessorController.h"

@interface ORFixedValueController : ORProcessElementController {
	IBOutlet NSTextField*	fixedValueField;
	IBOutlet NSButton*      lockButton;
}

#pragma mark •••Initialization
- (id)init;

#pragma mark ***Interface Management
- (void) fixedValueChanged:(NSNotification*)aNote;
- (void) lockChanged:(NSNotification*)note;

#pragma mark ***Actions
- (IBAction) fixedValueAction:(id)sender;
- (IBAction) lockButtonAction:(id)sender;
@end

