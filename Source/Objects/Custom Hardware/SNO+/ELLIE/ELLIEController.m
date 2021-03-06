//
//  ELLIEController.m
//  Orca
//
//  Created by Chris Jones on 01/04/2014.
//
//  Revision history:
//  Ed Leming 04/01/2016 -  Removed global variables to move logic to
//                          ELLIEModel
//

#import "ELLIEController.h"
#import "ELLIEModel.h"
#import "SNOPModel.h"
#import "SNOP_Run_Constants.h"
#import "ORRunModel.h"

NSString* ORTELLIERunStart = @"ORTELLIERunStarted";

@implementation ELLIEController
    NSMutableDictionary *configForSmellie;
    BOOL *laserHeadSelected;
    BOOL *fibreSwitchOutputSelected;
//smellie maxiumum trigger frequency

@synthesize nodeMapWC = _nodeMapWC;
@synthesize guiFireSettings = _guiFireSettings;
@synthesize tellieThread = _tellieThread;
@synthesize smellieThread = _smellieThread;

//Set up functions
-(id)init
{
    self = [super initWithWindowNibName:@"ellie"];
    //[smellieConfigAttenutationFactor setKeyboardType:UIKeyboardTypeNumberPad]
    
    laserHeadSelected = NO;
    fibreSwitchOutputSelected = NO;
    
    @try{

        // Check there is an ELLIE model in the current configuration
        NSArray*  ellieModels = [[(ORAppDelegate*)[NSApp delegate] document] collectObjectsOfClass:NSClassFromString(@"ELLIEModel")];
        if(![ellieModels count]){
            NSLogColor([NSColor redColor], @"Must have an ELLIE object in the configuration\n");
            return nil;
        }
        ELLIEModel* anELLIEModel = [ellieModels objectAtIndex:0];
     
        NSNumber *currentConfigurationVersion = [[NSNumber alloc] initWithInt:0];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //fetch the data associated with the current configuration
            configForSmellie = [[anELLIEModel fetchConfigurationFile:
                                    [anELLIEModel fetchRecentConfigVersion]] mutableCopy];
        });
    
        //increment the current version of the incrementation
        currentConfigurationVersion = [NSNumber numberWithInt:[currentConfigurationVersion intValue] + 1];

        [configForSmellie setObject:currentConfigurationVersion forKey:@"configuration_version"];
    
        //SMELLIE Configuration file
        //Make sure these buttons are working on start up for Smellie
        [smellieNumIntensitySteps setEnabled:YES];
        [smellieMaxIntensity setEnabled:YES];
        [smellieMinIntensity setEnabled:YES];
        [smellieNumTriggersPerLoop setEnabled:YES];
        [smellieOperationMode setEnabled:YES];
        [smellieOperatorName setEnabled:YES];
        [smellieTriggerFrequency setEnabled:YES];
        [smellieRunName setEnabled:YES];
        [smellie405nmLaserButton setEnabled:YES];
        [smellie375nmLaserButton setEnabled:YES];
        [smellie440nmLaserButton setEnabled:YES];
        [smellie500nmLaserButton setEnabled:YES];
        [smellieFibreButtonFS007 setEnabled:YES];
        [smellieFibreButtonFS107 setEnabled:YES];
        [smellieFibreButtonFS207 setEnabled:YES];
        [smellieFibreButtonFS025 setEnabled:YES];
        [smellieFibreButtonFS125 setEnabled:YES];
        [smellieFibreButtonFS225 setEnabled:YES];
        [smellieFibreButtonFS037 setEnabled:YES];
        [smellieFibreButtonFS137 setEnabled:YES];
        [smellieFibreButtonFS237 setEnabled:YES];
        [smellieFibreButtonFS055 setEnabled:YES];
        [smellieFibreButtonFS155 setEnabled:YES];
        [smellieFibreButtonFS255 setEnabled:YES];
        [smellieAllFibresButton setEnabled:YES];
        [smellieAllLasersButton setEnabled:YES];
        [smellieMakeNewRunButton setEnabled:NO];
    }
    @catch (NSException *e) {
        NSLog(@"CouchDB for ELLIE isn't connected properly. Please reload the ELLIE Gui and check the database connections\n");
        NSLog(@"Reason for error %@ \n",e);
    }

    /*Setting up TELLIE GUI */
    [self initialiseTellie];
    
    return self;
}

-(void) awakeFromNib
{
    [super awakeFromNib];
    [super updateWindow];
    [self initialiseTellie];
}

- (void)dealloc
{
    [super dealloc];
}

- (void) updateWindow
{
	[super updateWindow];
}

- (void) registerNotificationObservers
{
    NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
    
	[super registerNotificationObservers];
    
	[notifyCenter removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
    
    [notifyCenter addObserver : self
					 selector : @selector(setAllLasersAction:)
						 name : ELLIEAllLasersChanged
					   object : model];
    
    [notifyCenter addObserver : self
					 selector : @selector(setAllFibresAction:)
						 name : ELLIEAllFibresChanged
					   object : model];
    
    [notifyCenter addObserver:self
                     selector:@selector(loadCurrentInformationForLaserHead)
                         name:NSComboBoxSelectionDidChangeNotification
                       object:smellieConfigLaserHeadField];

    [notifyCenter addObserver : self
                     selector : @selector(tellieRunFinished:)
                         name : ORTELLIERunFinished
                        object: nil];
    
    [notifyCenter addObserver : self
                     selector : @selector(tellieRunStarted:)
                         name : ORTELLIERunStart
                        object: nil];
    
}

///////////////////////////////////////////
// TELLIE Functions
///////////////////////////////////////////
-(void)initialiseTellie
{
    // Load static (calibration and mapping) parameters from DB.
    // May take a while so try to run asyncronously
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [model loadTELLIEStaticsFromDB];
    });
    
    //Make sure sensible tabs are selected to begin with
    [ellieTabView selectTabViewItem:tellieTViewItem];
    [tellieTabView selectTabViewItem:tellieFireFibreTViewItem];
    [tellieOperatorTabView selectTabViewItem:tellieGeneralOpTViewItem];
    
    //Set slave mode operation as default for both tabs
    [tellieGeneralOperationModePb removeAllItems];
    [tellieGeneralOperationModePb addItemsWithTitles:@[@"Slave", @"Master"]];
    [tellieGeneralOperationModePb selectItemAtIndex:0];

    [tellieExpertOperationModePb removeAllItems];
    [tellieExpertOperationModePb addItemsWithTitles:@[@"Slave", @"Master"]];
    [tellieExpertOperationModePb selectItemAtIndex:0];
    
    //Grey out fibre until node is given
    [tellieGeneralFibreSelectPb setTarget:self];
    [tellieGeneralFibreSelectPb setEnabled:NO];
    
    [tellieExpertFibreSelectPb setTarget:self];
    [tellieExpertFibreSelectPb setEnabled:NO];

    //Set pulse height to full as default
    //**Might be sensible to remove this field completely, needs discussion.
    [telliePulseHeightTf setStringValue:@"16383"];
    
    //Disable Fire / stop buttons
    [tellieExpertFireButton setEnabled:NO];
    [tellieExpertStopButton setEnabled:NO];
    [tellieGeneralFireButton setEnabled:NO];
    [tellieGeneralStopButton setEnabled:NO];
    
    //Set this object as delegate for textFields
    //This means we get notified when someone's edited
    //a field.
    [tellieGeneralNodeTf setDelegate:self];
    [tellieGeneralPhotonsTf setDelegate:self];
    [tellieGeneralTriggerDelayTf setDelegate:self];
    [tellieGeneralNoPulsesTf setDelegate:self];
    [tellieGeneralFreqTf setDelegate:self];
    [tellieGeneralTriggerDelayTf setStringValue:@"700"];


    [tellieChannelTf setDelegate:self];
    [telliePulseWidthTf setDelegate:self];
    [telliePulseFreqTf setDelegate:self];
    [telliePulseHeightTf setDelegate:self];
    [tellieFibreDelayTf setDelegate:self];
    [tellieTriggerDelayTf setDelegate:self];
    [tellieNoPulsesTf setDelegate:self];
    [tellieExpertNodeTf setDelegate:self];
    [telliePhotonsTf setDelegate:self];
    [tellieTriggerDelayTf setStringValue:@"700"];
}

-(IBAction)tellieGeneralFireAction:(id)sender
{
    ////////////
    // Check a run isn't ongoing
    if([model ellieFireFlag]){
        NSLogColor([NSColor redColor], @"[TELLIE]: Fire button will not work while an ELLIE run is underway\n");
        return;
    }
    
    [tellieGeneralFireButton setEnabled:NO];
    [tellieGeneralStopButton setEnabled:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORTELLIERunStart object:nil userInfo:[self guiFireSettings]];
    [tellieGeneralValidationStatusTf setStringValue:@""];

}

-(IBAction)tellieExpertFireAction:(id)sender
{
    ////////////
    // Check a run isn't ongoing
    if([model ellieFireFlag]){
        NSLogColor([NSColor redColor], @"[TELLIE]: Fire button will not work while an ELLIE run is underway\n");
        return;
    }
    
    [tellieExpertStopButton setEnabled:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORTELLIERunStart object:nil userInfo:[self guiFireSettings]];
    [tellieExpertFireButton setEnabled:NO];
    [tellieExpertValidationStatusTf setStringValue:@""];
}

-(IBAction)tellieGeneralStopAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ORTELLIERunFinished object:nil];
}

-(IBAction)tellieExpertStopAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ORTELLIERunFinished object:nil];
}

-(void)tellieRunFinished:(NSNotification *)aNote
{
    [tellieGeneralStopButton setEnabled:NO];
    [tellieExpertStopButton setEnabled:NO];
    [tellieExpertRunStatusTf setStringValue:@"No light"];
    [tellieGeneralRunStatusTf setStringValue:@"No light"];
}

-(void)tellieRunStarted:(NSNotification *)aNote
{
    [tellieExpertRunStatusTf setStringValue:@"Firing!"];
    [tellieGeneralRunStatusTf setStringValue:@"Firing!"];

}

- (BOOL) isNumeric:(NSString *)s{
    NSScanner *sc = [NSScanner scannerWithString: s];
    if( [sc scanFloat:NULL] )
    {
        return [sc isAtEnd];
    }
    return NO;
}

-(IBAction)tellieNodeMapAction:(id)sender
{
    // Does map window already exist? If so release it and create a new one.
    // I can't find a more elegant way to force the window back to the
    // front of the screen.... Annoying.
    NSWindowController* tmpWc = [[NSWindowController alloc] initWithWindowNibName:@"NodeMap"];
    
    if([self nodeMapWC] != nil){
        //[[self nodeMapWC] release];
        [self setNodeMapWC:nil];
        [self setNodeMapWC:tmpWc];
        [[self nodeMapWC] showWindow:self];
        [tmpWc release];
        return;
    }
    
    // Set member window controller
    [self setNodeMapWC:tmpWc];
    [[self nodeMapWC] showWindow:self];
    [tmpWc release];
}

- (IBAction)tellieGeneralFibreNameAction:(NSPopUpButton *)sender {
    //[tellieGeneralPhotonsTf setStringValue:@""];
    //[tellieGeneralNoPulsesTf setStringValue:@""];
    //[tellieGeneralTriggerDelayTf setStringValue:@""];
    //[tellieGeneralFreqTf setStringValue:@""];
    [tellieGeneralFireButton setEnabled:NO];
    [tellieGeneralStopButton setEnabled:NO];
}

- (IBAction)tellieExpertFibreNameAction:(NSPopUpButton *)sender {
    [tellieChannelTf setStringValue:@""];
    [telliePulseWidthTf setStringValue:@""];
    [telliePulseFreqTf setStringValue:@""];
    [telliePulseHeightTf setStringValue:@"16383"];
    [tellieFibreDelayTf setStringValue:@""];
    [tellieTriggerDelayTf setStringValue:@""];
    [tellieNoPulsesTf setStringValue:@""];
    [tellieGeneralFireButton setEnabled:NO];
}

-(IBAction)tellieGeneralModeAction:(NSPopUpButton *)sender{
    [tellieGeneralFireButton setEnabled:NO];
}

-(IBAction)tellieExpertModeAction:(NSPopUpButton *)sender{
    [tellieExpertFireButton setEnabled:NO];
}

- (IBAction)tellieExpertAutoFillAction:(id)sender {
    
    // Deselect the node text field
    [tellieExpertNodeTf resignFirstResponder];

    // Clear all current values
    [tellieChannelTf setStringValue:@""];
    [telliePulseWidthTf setStringValue:@""];
    [telliePulseFreqTf setStringValue:@""];
    [telliePulseHeightTf setStringValue:@"16383"];
    [tellieFibreDelayTf setStringValue:@""];
    [tellieTriggerDelayTf setStringValue:@""];
    [tellieNoPulsesTf setStringValue:@""];
    [tellieGeneralFireButton setEnabled:NO];
    
    //Check if inputs are valid
    NSString* msg = nil;
    /*
    msg = [self validateExpertTellieNode:[tellieExpertNodeTf stringValue]];
    if ([msg isNotEqualTo:nil]){
        [tellieExpertValidationStatusTf setStringValue:msg];
        return;
    }
    */
    msg = [self validateGeneralTelliePhotons:[telliePhotonsTf stringValue]];
    if ([msg isNotEqualTo:nil]){
        [tellieExpertValidationStatusTf setStringValue:msg];
        return;
    }
    
    // Calulate settings
    BOOL inSlave = YES;
    if([[tellieExpertOperationModePb titleOfSelectedItem] isEqual:@"Master"]){
        inSlave = NO;
    }
    
    ////////////////
    // Find the max safe frequency to flash at, considering requested photons
    float photons = [telliePhotonsTf floatValue];
    float safe_gradient = -1.;
    float safe_intercept = 1e6;
    int freq = round(pow((photons / safe_intercept), safe_gradient));
    if(freq > 1000){
        freq = 1000;
    }
    
    int noPulses = 100;
    if(freq < noPulses){
        noPulses = freq;
    }
    
    NSMutableDictionary* settings = [model returnTellieFireCommands:[tellieExpertFibreSelectPb titleOfSelectedItem] withNPhotons:[telliePhotonsTf integerValue] withFireFrequency:freq withNPulses:noPulses withTriggerDelay:700 inSlave:(BOOL)inSlave];
    if(settings){
        float frequency = (1. / [[settings objectForKey:@"pulse_separation"] floatValue])*1000;
        //Set text fields appropriately
        [tellieChannelTf setStringValue:[[settings objectForKey:@"channel"] stringValue]];
        [telliePulseWidthTf setStringValue:[[settings objectForKey:@"pulse_width"] stringValue]];
        [telliePulseFreqTf setStringValue:[NSString stringWithFormat:@"%f", frequency]];
        [telliePulseHeightTf setStringValue:[[settings objectForKey:@"pulse_height"] stringValue]];
        [tellieFibreDelayTf setStringValue:[[settings objectForKey:@"fibre_delay"] stringValue]];
        [tellieTriggerDelayTf setStringValue:[NSString stringWithFormat:@"%1.2f",[[settings objectForKey:@"trigger_delay"] floatValue]]];
        [tellieNoPulsesTf setStringValue:[[settings objectForKey:@"number_of_shots"] stringValue]];
        [tellieExpertFibreSelectPb selectItemWithTitle:[settings objectForKey:@"fibre"]];
    } else {
        [tellieExpertValidationStatusTf setStringValue:@"Issue generating settings. See orca log for full details."];
        [tellieChannelTf setStringValue:@""];
        [telliePulseWidthTf setStringValue:@""];
        [telliePulseFreqTf setStringValue:@""];
        [telliePulseHeightTf setStringValue:@"16383"];
        [tellieFibreDelayTf setStringValue:@""];
        [tellieTriggerDelayTf setStringValue:@""];
        [tellieNoPulsesTf setStringValue:@""];
    }
    //Set backgrounds back to white
    [tellieChannelTf setBackgroundColor:[NSColor whiteColor]];
    [telliePulseWidthTf setBackgroundColor:[NSColor whiteColor]];
    [telliePulseFreqTf setBackgroundColor:[NSColor whiteColor]];
    [telliePulseHeightTf setBackgroundColor:[NSColor whiteColor]];
    [tellieFibreDelayTf setBackgroundColor:[NSColor whiteColor]];
    [tellieTriggerDelayTf setBackgroundColor:[NSColor whiteColor]];
    [tellieNoPulsesTf setBackgroundColor:[NSColor whiteColor]];
}
////////////////////////////////////////////////////////
//
// TELLIE Validation button functions
//
////////////////////////////////////////////////////////
-(IBAction)tellieExpertValidateSettingsAction:(id)sender
{
    [self setGuiFireSettings:nil];
    [tellieTriggerDelayTf.window makeFirstResponder:nil];
    [tellieFibreDelayTf.window makeFirstResponder:nil];
    [telliePulseWidthTf.window makeFirstResponder:nil];
    [telliePulseHeightTf.window makeFirstResponder:nil];
    [telliePulseFreqTf.window makeFirstResponder:nil];
    [tellieChannelTf.window makeFirstResponder:nil];
    [tellieNoPulsesTf.window makeFirstResponder:nil];
    [tellieExpertOperationModePb.window makeFirstResponder:nil];

    NSString* msg = nil;
    NSMutableArray* msgs = [NSMutableArray arrayWithCapacity:7];
    NSLog(@"---------------------------- Tellie Validation messages ----------------------------\n");
    msg = [self validateTellieTriggerDelay:[tellieTriggerDelayTf stringValue]];
    if(msg){
        [msgs insertObject:msg atIndex:0];
    } else {
        [msgs insertObject:[NSNull null] atIndex:0];
    }
    
    msg = [self validateTellieFibreDelay:[tellieFibreDelayTf stringValue]];
    if(msg){
        [msgs insertObject:msg atIndex:1];
    } else {
        [msgs insertObject:[NSNull null] atIndex:1];
    }

    msg = [self validateTelliePulseWidth:[telliePulseWidthTf stringValue]];
    if(msg){
        [msgs insertObject:msg atIndex:2];
    } else {
        [msgs insertObject:[NSNull null] atIndex:2];
    }

    msg = [self validateTelliePulseHeight:[telliePulseHeightTf stringValue]];
    if(msg){
        [msgs insertObject:msg atIndex:3];
    } else {
        [msgs insertObject:[NSNull null] atIndex:3];
    }

    msg = [self validateTelliePulseFreq:[telliePulseFreqTf stringValue]];
    if(msg){
        [msgs insertObject:msg atIndex:4];
    } else {
        [msgs insertObject:[NSNull null] atIndex:4];
    }

    msg = [self validateTellieChannel:[tellieChannelTf stringValue]];
    if(msg){
        [msgs insertObject:msg atIndex:5];
    } else {
        [msgs insertObject:[NSNull null] atIndex:5];
    }

    msg = [self validateTellieNoPulses:[tellieNoPulsesTf stringValue]];
    if(msg){
        [msgs insertObject:msg atIndex:6];
    } else {
        [msgs insertObject:[NSNull null] atIndex:6];
    }

    // Remove any null objects
    for(int i = 0; i < [msgs count]; i++){
        if([msgs objectAtIndex:i] == [NSNull null]){
            [msgs removeObject:[msgs objectAtIndex:i]];
        }
    }

    // Check if validation passed
    if([msgs count] == 0){
        NSLog(@"[TELLIE]: Expert settings are valid\n");
        //Set backgrounds back to white
        [tellieChannelTf setBackgroundColor:[NSColor whiteColor]];
        [telliePulseWidthTf setBackgroundColor:[NSColor whiteColor]];
        [telliePulseFreqTf setBackgroundColor:[NSColor whiteColor]];
        [telliePulseHeightTf setBackgroundColor:[NSColor whiteColor]];
        [tellieFibreDelayTf setBackgroundColor:[NSColor whiteColor]];
        [tellieTriggerDelayTf setBackgroundColor:[NSColor whiteColor]];
        [tellieNoPulsesTf setBackgroundColor:[NSColor whiteColor]];
        // Make settings dict to pass to fire method
        float pulseSeparation = 1000.*(1./[telliePulseFreqTf floatValue]); // TELLIE accepts pulse rate in ms
        NSMutableDictionary* settingsDict = [NSMutableDictionary dictionaryWithCapacity:100];
        [settingsDict setValue:[tellieExpertFibreSelectPb titleOfSelectedItem] forKey:@"fibre"];
        [settingsDict setValue:[NSNumber numberWithInteger:[tellieChannelTf integerValue]]  forKey:@"channel"];
        [settingsDict setValue:[tellieExpertOperationModePb titleOfSelectedItem] forKey:@"run_mode"];
        //[settingsDict setValue:[NSNumber numberWithInteger:[telliePhotonsTf integerValue]] forKey:@"photons"];
        [settingsDict setValue:[NSNumber numberWithInteger:[telliePulseWidthTf integerValue]] forKey:@"pulse_width"];
        [settingsDict setValue:[NSNumber numberWithFloat:pulseSeparation] forKey:@"pulse_separation"];
        [settingsDict setValue:[NSNumber numberWithInteger:[tellieNoPulsesTf integerValue]] forKey:@"number_of_shots"];
        [settingsDict setValue:[NSNumber numberWithInteger:[tellieTriggerDelayTf integerValue]] forKey:@"trigger_delay"];
        [settingsDict setValue:[NSNumber numberWithFloat:[tellieFibreDelayTf floatValue]] forKey:@"fibre_delay"];
        [settingsDict setValue:[NSNumber numberWithInteger:[telliePulseHeightTf integerValue]] forKey:@"pulse_height"];
        [self setGuiFireSettings:settingsDict];
        [tellieExpertFireButton setEnabled:YES];
        [tellieExpertValidationStatusTf setStringValue:@"Settings are valid. Fire away!"];
    } else {
        [tellieExpertValidationStatusTf setStringValue:@"Validation issues found. See orca log for full description.\n"];
    }
    NSLog(@"---------------------------------------------------------------------------------------------\n");
}

-(IBAction)tellieGeneralValidateSettingsAction:(id)sender
{
    [self setGuiFireSettings:nil];
    [tellieGeneralNodeTf.window makeFirstResponder:nil];
    [tellieGeneralNoPulsesTf.window makeFirstResponder:nil];
    [tellieGeneralPhotonsTf.window makeFirstResponder:nil];
    [tellieGeneralTriggerDelayTf.window makeFirstResponder:nil];
    [tellieGeneralFreqTf.window makeFirstResponder:nil];
    [tellieGeneralOperationModePb.window makeFirstResponder:nil];

    NSString* msg = nil;
    NSMutableArray* msgs = [NSMutableArray arrayWithCapacity:4];

    ///////////////
    // Run checks
    NSLog(@"---------------------------- Tellie Validation messages ----------------------------\n");
    //msg = [self validateGeneralTellieNode:[tellieGeneralNodeTf stringValue]];
    //if(msg){
    //    [msgs insertObject:msg atIndex:0];
    //} else {
    //  [msgs insertObject:[NSNull null] atIndex:0];
    //}

    msg = [self validateGeneralTellieNoPulses:[tellieGeneralNoPulsesTf stringValue]];
    if(msg){
        [msgs insertObject:msg atIndex:0];
    } else {
        [msgs insertObject:[NSNull null] atIndex:0];
    }

    msg = [self validateGeneralTelliePhotons:[tellieGeneralPhotonsTf stringValue]];
    if(msg){
        [msgs insertObject:msg atIndex:1];
    } else {
        [msgs insertObject:[NSNull null] atIndex:1];
    }

    msg = [self validateGeneralTellieTriggerDelay:[tellieGeneralTriggerDelayTf stringValue]];
    if(msg){
        [msgs insertObject:msg atIndex:2];
    } else {
        [msgs insertObject:[NSNull null] atIndex:2];
    }

    msg = [self validateGeneralTelliePulseFreq:[tellieGeneralFreqTf stringValue]];
    if(msg){
        [msgs insertObject:msg atIndex:3];
    } else {
        [msgs insertObject:[NSNull null] atIndex:3];
    }
    
    // Calculate settings and check any issues in
    BOOL inSlave = YES;
    if([[tellieGeneralOperationModePb titleOfSelectedItem] isEqualToString:@"Master"]){
        inSlave = NO;
    }
    
    NSMutableDictionary* settings = [model returnTellieFireCommands:[tellieGeneralFibreSelectPb titleOfSelectedItem] withNPhotons:[tellieGeneralPhotonsTf integerValue] withFireFrequency:[tellieGeneralFreqTf integerValue] withNPulses:[tellieGeneralNoPulsesTf integerValue] withTriggerDelay:[tellieGeneralTriggerDelayTf integerValue] inSlave:inSlave];
    
    if(settings){
        [self setGuiFireSettings:settings];
    } else if(settings == nil){
        [msgs insertObject:@"[TELLIE]: Settings dict not created\n" atIndex:4];
    }
    
    // Remove any null objects
    for(int i = 0; i < [msgs count]; i++){
        if([msgs objectAtIndex:i] == [NSNull null]){
            [msgs removeObject:[msgs objectAtIndex:i]];
        }
    }
    
    // Check validations passed
    if([msgs count] == 0){
        NSLog(@"[TELLIE]: Expert settings are valid\n");
        [tellieGeneralValidationStatusTf setStringValue:@"Settings are valid. Fire away!"];
        [tellieGeneralFireButton setEnabled:YES];
    } else {
        //NSLog(@"Invalidity problems in Tellie general gui: %@\n", msgs);
        [tellieGeneralValidationStatusTf setStringValue:@"Validation issues found. See orca log for full description.\n"];
    }
    NSLog(@"---------------------------------------------------------------------------------------------\n");
}

///////////////////////////////////////////
// Delagate funcs waiting to observe edits
////////////////////////////////////////////
-(void)controlTextDidBeginEditing:(NSNotification *)note {
    /* If someone edits the photons field automatically clear the IPW field
    */
    if ([note object] == telliePhotonsTf) {
        [telliePulseWidthTf setStringValue:@""];
    }

    if([note object] == tellieExpertNodeTf){
        [tellieChannelTf setStringValue:@""];
        [tellieTriggerDelayTf setStringValue:@""];
        [telliePulseFreqTf setStringValue:@""];
        [telliePulseHeightTf setStringValue:@"16383"];
        [telliePulseWidthTf setStringValue:@""];
        [tellieNoPulsesTf setStringValue:@""];
        [tellieFibreDelayTf setStringValue:@""];
        [tellieExpertFireButton setEnabled:NO];
    }
    
    [tellieExpertFireButton setEnabled:NO];
    [tellieGeneralValidationStatusTf setStringValue:@""];

    [tellieGeneralFireButton setEnabled:NO];
    [tellieExpertValidationStatusTf setStringValue:@""];

}

-(void)controlTextDidEndEditing:(NSNotification *)note {
    /* This method catches notifications sent when a control with editable text 
     finishes editing a field.
     
     Validation checks are made on the new text input dependent on which field was
     edited.
     */
    //Get a reference to whichever field was changed
    NSTextField * editedField = [note object];
    NSString* currentString = [editedField stringValue];
    
    NSString* expertMsg = nil;
    NSString* generalMsg = nil;
    BOOL gotInside = NO;
    
    //Make sure background gets drawn
    [editedField setDrawsBackground:YES];
    //[tellieExpertStopButton setEnabled:NO];
    //[tellieGeneralStopButton setEnabled:NO];

    //check if this notification originated from the expert tab
    if([note object] == tellieExpertNodeTf){
        expertMsg = [self validateExpertTellieNode:currentString];
        gotInside = YES;
        if([[telliePhotonsTf stringValue] isEqualToString:@""]){
            [telliePhotonsTf setStringValue:@"1000"];
        }
    } else if ([note object] == telliePhotonsTf) {
        expertMsg = [self validateGeneralTelliePhotons:currentString];
        gotInside = YES;
        [tellieExpertFireButton setEnabled:NO];
        [tellieExpertStopButton setEnabled:NO];
    } else if ([note object] == tellieChannelTf){
        expertMsg = [self validateTellieChannel:currentString];
        gotInside = YES;
        [tellieTriggerDelayTf setStringValue:@""];
        [telliePulseFreqTf setStringValue:@""];
        [telliePulseHeightTf setStringValue:@"16383"];
        [telliePulseWidthTf setStringValue:@""];
        [tellieNoPulsesTf setStringValue:@""];
        [tellieFibreDelayTf setStringValue:@""];
        [tellieExpertNodeTf setStringValue:@""];
        [telliePhotonsTf setStringValue:@""];
        [tellieExpertFibreSelectPb removeAllItems];
        [tellieExpertFibreSelectPb setEnabled:NO];
        [tellieExpertFireButton setEnabled:NO];
        [tellieExpertStopButton setEnabled:NO];
    } else if([note object] == tellieTriggerDelayTf){
        expertMsg = [self validateTellieTriggerDelay:currentString];
        gotInside = YES;
    } else if ([note object] == tellieFibreDelayTf){
        expertMsg = [self validateTellieFibreDelay:currentString];
        gotInside = YES;
    } else if ([note object] == telliePulseFreqTf){
        expertMsg = [self validateTelliePulseFreq:currentString];
        gotInside = YES;
    } else if ([note object] == telliePulseHeightTf){
        expertMsg = [self validateTelliePulseHeight:currentString];
        gotInside = YES;
    } else if ([note object] == telliePulseWidthTf){
        expertMsg = [self validateTelliePulseWidth:currentString];
        gotInside = YES;
        // Calculate what this new Value may equate to in photons
        if(expertMsg == nil){
            if([tellieChannelTf integerValue]){
                BOOL inSlave = YES;
                if([[tellieExpertOperationModePb titleOfSelectedItem] isEqual:@"Master"]){
                    inSlave = NO;
                }
                NSNumber* photons = [model calcPhotonsForIPW:[telliePulseWidthTf integerValue] forChannel:[tellieChannelTf integerValue] inSlave:inSlave];
                [telliePhotonsTf setStringValue:[NSString stringWithFormat:@"%@", photons]];
            }
        }
    } else if ([note object] == tellieNoPulsesTf){
        expertMsg = [self validateTellieNoPulses:currentString];
        gotInside = YES;
    }
    
    if(expertMsg){
        [tellieExpertFireButton setEnabled:NO];
        [tellieExpertValidationStatusTf setStringValue:expertMsg];
        [editedField setBackgroundColor:[NSColor orangeColor]];
        [editedField setNeedsDisplay:YES];
        return;
    } else if(expertMsg == nil && gotInside == YES){
        [tellieExpertFireButton setEnabled:NO];
        [tellieExpertValidationStatusTf setStringValue:@""];
        [editedField setBackgroundColor:[NSColor whiteColor]];
        [editedField setNeedsDisplay:YES];
        return;
    }
    
    //Re-set got inside.
    gotInside = NO;
    
    //check if this notification originated from the general tab
    if([note object] == tellieGeneralNodeTf){
        generalMsg = [self validateGeneralTellieNode:currentString];
        gotInside = YES;
    } else if ([note object] == tellieGeneralFreqTf){
        generalMsg = [self validateGeneralTelliePulseFreq:currentString];
        gotInside = YES;
    } else if ([note object] == tellieGeneralNoPulsesTf){
        generalMsg = [self validateGeneralTellieNoPulses:currentString];
        gotInside = YES;
    } else if ([note object] == tellieGeneralPhotonsTf){
        generalMsg = [self validateGeneralTelliePhotons:currentString];
        gotInside = YES;
    } else if ([note object] == tellieGeneralTriggerDelayTf){
        generalMsg = [self validateTellieTriggerDelay:currentString];
        gotInside = YES;
    }
    
    // If we get a message back, change textField color and pass validation status
    if(generalMsg){
        [tellieGeneralFireButton setEnabled:NO];
        [tellieGeneralValidationStatusTf setStringValue:generalMsg];
        [editedField setBackgroundColor:[NSColor orangeColor]];
        [editedField setNeedsDisplay:YES];
        return;
    } else if(generalMsg == nil && gotInside == YES){
        [tellieGeneralFireButton setEnabled:NO];
        [tellieGeneralValidationStatusTf setStringValue:@""];
        [editedField setBackgroundColor:[NSColor whiteColor]];
        [editedField setNeedsDisplay:YES];
        return;
    }
}

/////////////////////////////////////////////
// Validation functions for each tab / field
/////////////////////////////////////////////

///////////////
// General gui
///////////////
-(NSString*)validateGeneralTellieNode:(NSString *)currentText
{
    //Check if fibre mapping has been loaded from the tellieDB
    if(![model tellieNodeMapping]){
        [model loadTELLIEStaticsFromDB];
    }
    //Clear out any old data
    [tellieGeneralFibreSelectPb removeAllItems];
    [tellieGeneralFibreSelectPb setEnabled:NO];

    //Use already implemented function in the ELLIEModel to check if Fibre is patched.
    NSMutableDictionary* nodeInfo = [[model tellieNodeMapping] objectForKey:[NSString stringWithFormat:@"panel_%d",[currentText intValue]]];
    if(nodeInfo == nil){
        NSString* msg = [NSString stringWithFormat:@"[TELLIE_VALIDATION]: Node map does not include a reference to node: %@\n", currentText];
        NSLog(msg);
        return msg;
    }
    
    BOOL check = NO;
    for(NSString* key in nodeInfo){
        if([[nodeInfo objectForKey:key] intValue] ==  0 || [[nodeInfo objectForKey:key] intValue] ==  1){
            [tellieGeneralFibreSelectPb addItemWithTitle:key];
            check = YES;
        }
    }
    
    if(check == NO){
        NSString* msg = [NSString stringWithFormat:@"[TELLIE_VALIDATION]: No active fibres available at node: %@\n", currentText];
        NSLog(msg);
        [tellieGeneralFibreSelectPb removeAllItems];
        [tellieGeneralFibreSelectPb setEnabled:NO];
        return msg;
    }
    
    NSString* optimalFibre = [model calcTellieFibreForNode:[currentText intValue]];
    [tellieGeneralFibreSelectPb selectItemWithTitle:optimalFibre];
    [tellieGeneralFibreSelectPb setEnabled:YES];
    return nil;
}

-(NSString*)validateGeneralTelliePhotons:(NSString *)currentText
{
    NSScanner* scanner = [NSScanner scannerWithString:currentText];
    int photons = [currentText intValue];
    int maxPhotons = 1e5;
    
    NSString* msg = @"[TELLIE_VALIDATION]: Valid Photons per pulse range: 0-1e5\n";
    if (![scanner scanInt:nil]){
        NSLog(msg);
        return msg;
    } else if(photons < 0){
        NSLog(msg);
        return msg;
    } else if(photons > maxPhotons){
        NSLog(msg);
        return msg;
    }
    return nil;
}

-(NSString*)validateGeneralTelliePulseFreq:(NSString *)currentText
{
    // Constraints are the same for both tabs
    NSString* msg = [self validateTelliePulseFreq:currentText];
    if(msg){
        return msg;
    }
    return nil;
}

-(NSString*)validateGeneralTellieNoPulses:(NSString *)currentText
{
    // Constraints are the same for both tabs
    return [self validateTellieNoPulses:currentText];
}

-(NSString*)validateGeneralTellieTriggerDelay:(NSString *)currentText
{
    //This will need updateing. I need to ask Eric about the specs of Tubii's trigger delay.
    return [self validateTellieTriggerDelay:currentText];
}

/////////////
//Expert gui
/////////////
-(NSString*)validateExpertTellieNode:(NSString *)currentText
{
    //Check if fibre mapping has been loaded from the tellieDB
    if(![model tellieNodeMapping]){
        [model loadTELLIEStaticsFromDB];
    }
    //Clear out any old data
    [tellieExpertFibreSelectPb removeAllItems];
    [tellieExpertFibreSelectPb setEnabled:NO];

    //Use already implemented function in the ELLIEModel to check if Fibre is patched.
    NSMutableDictionary* nodeInfo = [[model tellieNodeMapping] objectForKey:[NSString stringWithFormat:@"panel_%d",[currentText intValue]]];
    if(nodeInfo == nil){
        NSString* msg = [NSString stringWithFormat:@"[TELLIE_VALIDATION]: Node map does not include a reference to node: %@\n", currentText];
        NSLog(msg);
        return msg;
    }
    
    BOOL check = NO;
    for(NSString* key in nodeInfo){
        if([[nodeInfo objectForKey:key] intValue] ==  0 || [[nodeInfo objectForKey:key] intValue] ==  1){
            [tellieExpertFibreSelectPb addItemWithTitle:key];
            check = YES;
        }
    }
    
    if(check == NO){
        NSString* msg = [NSString stringWithFormat:@"[TELLIE_VALIDATION]: No active fibres available at node: %@\n", currentText];
        [tellieExpertFibreSelectPb removeAllItems];
        [tellieExpertFibreSelectPb setEnabled:NO];
        NSLog(msg);
        return msg;
    }
    
    NSString* optimalFibre = [model calcTellieFibreForNode:[currentText intValue]];
    [tellieExpertFibreSelectPb selectItemWithTitle:optimalFibre];
    [tellieExpertFibreSelectPb setEnabled:YES];
    return nil;
}

-(NSString*)validateTellieChannel:(NSString *)currentText
{
    NSScanner* scanner = [NSScanner scannerWithString:currentText];
    int currentChannelNumber = [currentText intValue];
    int minimumChannelNumber = 1;
    int maxmiumChannelNumber = 95;
    
    NSString* msg = [NSString stringWithFormat:@"[TELLIE_VALIDATION]: Valid channel numbers are 1-95\n"];
    if(currentChannelNumber  > maxmiumChannelNumber){
        NSLog(msg);
        return msg;
    } else if (currentChannelNumber  < minimumChannelNumber){
        NSLog(msg);
        return msg;
    } else if (![scanner scanInt:nil]){
        NSLog(msg);
        return msg;
    }
    
    return nil;
}

-(NSString*)validateTelliePulseWidth:(NSString *)currentText
{
    NSScanner* scanner = [NSScanner scannerWithString:currentText];
    int currentValue = [currentText intValue];
    int minimumValue = 0;
    int maxmiumValue = 16383;
    
    NSString* msg = @"[TELLIE_VALIDATION]: Valid pulse width settings: 0-16383 in integer steps\n";
    if(currentValue  > maxmiumValue){
        NSLog(msg);
        return msg;
    } else if (currentValue  < minimumValue){
        NSLog(msg);
        return msg;
    } else if (![scanner scanInt:nil]){
        NSLog(msg);
        return msg;
    }
        
    return nil;
}

-(NSString*)validateTelliePulseHeight:(NSString *)currentText
{
    NSScanner* scanner = [NSScanner scannerWithString:currentText];
    int currentValue = [currentText intValue];
    int minimumValue = 0;
    int maxmiumValue = 16383;
    
    NSString* msg = @"[TELLIE_VALIDATION]: Valid pulse width settings: 0-16383 in integer steps\n";
    if(currentValue  > maxmiumValue){
        NSLog(msg);
        return msg;
    } else if (currentValue  < minimumValue){
        NSLog(msg);
        return msg;
    } else if (![scanner scanInt:nil]){
        NSLog(msg);
        return msg;
    }
    
    return nil;
}


-(NSString*)validateTelliePulseFreq:(NSString *)currentText
{
    NSScanner* scanner = [NSScanner scannerWithString:currentText];
    float frequency = [currentText floatValue];
    float maxFreq = 1e4;

    NSString* msg = @"[TELLIE_VALIDATION]: Valid frequency settings: 0-10kHz\n";
    if (![scanner scanFloat:nil]){
        NSLog(msg);
        return msg;
    } else if(frequency  > maxFreq){
        NSLog(msg);
        return msg;
    } else if (frequency < 0) {
        NSLog(msg);
        return msg;
    }
    return nil;
}

-(NSString*)validateTellieFibreDelay:(NSString *)currentText
{
    NSScanner* scanner = [NSScanner scannerWithString:currentText];
    float fibreDelayNumber = [currentText floatValue];
    //0.25ns discrete steps
    float minimumNumberFibreDelaySteps = 0.25;      //in ns
    float minimumFibreDelay = 0;                    //in ns
    float maxmiumFibreDelay = 63.75;                //in ns
    int fibreDelayRemainder = (int)(fibreDelayNumber*100)  % (int)(minimumNumberFibreDelaySteps*100);
    
    NSString* msg = @"[TELLIE_VALIDATION]: Valid fibre delay settings: 0-63.75ns in steps of 0.25ns.\n";
    if (![scanner scanFloat:nil]){
        NSLog(msg);
        return msg;
    } else if(fibreDelayNumber  > maxmiumFibreDelay){
        NSLog(msg);
        return msg;
    } else if (fibreDelayNumber  < minimumFibreDelay){
        NSLog(msg);
        return msg;
    } else if (fibreDelayRemainder != 0){
        NSLog(msg);
        return msg;
    }
    
    return nil;
}

-(NSString*)validateTellieTriggerDelay:(NSString *)currentText
{
    NSScanner* scanner = [NSScanner scannerWithString:currentText];
    int triggerDelayNumber = [currentText intValue];
    //5ns discrete steps, so again, adjustment needed if user enters e.g. 1.0 ns)
    int minimumNumberTriggerDelaySteps = 5;     //in ns
    int minimumTriggerDelay = 0;                //in ns
    int maxmiumTriggerDelay = 1275;             //in ns
    int triggerDelayRemainder = (triggerDelayNumber  % minimumNumberTriggerDelaySteps);
    
    NSString* msg = @"[TELLIE_VALIDATION]: Valid trigger delay settings: 0-1275ns in steps of 5ns.\n";
    if (![scanner scanInt:nil]){
        NSLog(msg);
        return msg;
    } else if(triggerDelayNumber  > maxmiumTriggerDelay){
        NSLog(msg);
        return msg;
    } else if (triggerDelayNumber  < minimumTriggerDelay){
        NSLog(msg);
        return msg;
    } else if (triggerDelayRemainder != 0){
        NSLog(msg);
        return msg;
    }
    return nil;
}

-(NSString*)validateTellieNoPulses:(NSString *)currentText
{
    NSScanner* scanner = [NSScanner scannerWithString:currentText];
    int noPulses = [currentText intValue];

    NSString* msg = @"[TELLIE_VALIDATION]: Number of pulses has to be a positive integer\n";
    if (![scanner scanInt:nil]){
        NSLog(msg);
        return msg;
    } else if (noPulses < 0){
        NSLog(msg);
        return msg;
    }
    return nil;
}

//SMELLIE functions -------------------------


-(void) loadCurrentInformationForLaserHead
{
    //load information from a configArray
    [smellieConfigAttenuatorField selectItemWithObjectValue:nil];
    [smellieConfigFsInputCh selectItemWithObjectValue:nil];
    [smellieConfigFsOutputCh selectItemWithObjectValue:nil];
    [smellieConfigDetectorFibreRef selectItemWithObjectValue:nil];
}

//enables all lasers if the "all lasers" box is enabled 
-(IBAction)setAllLasersAction:(id)sender;
{
    if([smellieAllLasersButton state] == 1){
        //Set the state of all Lasers to 1
        [smellieSuperkLaserButton setState:1];
        [smellie375nmLaserButton setState:1];
        [smellie405nmLaserButton setState:1];
        [smellie440nmLaserButton setState:1];
        [smellie500nmLaserButton setState:1];
    }
}

//enables all fibres if the "all fibres" box is enabled 
-(IBAction)setAllFibresAction:(id)sender;
{
    if([smellieAllFibresButton state] == 1){
        [smellieFibreButtonFS007 setState:1];
        [smellieFibreButtonFS107 setState:1];
        [smellieFibreButtonFS207 setState:1];
        [smellieFibreButtonFS025 setState:1];
        [smellieFibreButtonFS125 setState:1];
        [smellieFibreButtonFS225 setState:1];
        [smellieFibreButtonFS037 setState:1];
        [smellieFibreButtonFS137 setState:1];
        [smellieFibreButtonFS237 setState:1];
        [smellieFibreButtonFS055 setState:1];
        [smellieFibreButtonFS155 setState:1];
        [smellieFibreButtonFS255 setState:1];
    }
}

//removes the tick in case for "all lasers" if any of the lasers and not pressed
-(IBAction)allLaserValidator:(id)sender
{
    if( ([smellie375nmLaserButton state] != 1) || ([smellie405nmLaserButton state] != 1) || ([smellie440nmLaserButton state] != 1) || ([smellie500nmLaserButton state] != 1))
    {
        [smellieAllLasersButton setState:0];
    }
    
}

//removes the tick in case for "all fibres" if any of the lasers and not pressed
-(IBAction)allFibreValidator:(id)sender
{
    if( ([smellieFibreButtonFS007 state] != 1) || ([smellieFibreButtonFS107 state] != 1) || ([smellieFibreButtonFS025 state] != 1) || ([smellieFibreButtonFS125 state] != 1) || ([smellieFibreButtonFS225 state] != 1) || ([smellieFibreButtonFS037 state] != 1) || ([smellieFibreButtonFS137 state] != 1) || ([smellieFibreButtonFS237 state] != 1) || ([smellieFibreButtonFS055 state] != 1) || ([smellieFibreButtonFS155 state] != 1) || ([smellieFibreButtonFS255 state] != 1))
    {
        [smellieAllFibresButton setState:0];
    }
    
}

//Force the string value to be less than 100 and a valid value
-(IBAction)validateLaserMaxIntensity:(id)sender;
{
    NSString* maxLaserIntString = [smellieMaxIntensity stringValue];
    int maxLaserIntensity;
    
    @try{
        maxLaserIntensity  = [maxLaserIntString intValue];
    }
    @catch (NSException *e) {
        maxLaserIntensity = 100;
        [smellieMaxIntensity setIntValue:maxLaserIntensity];
        NSLog(@"SMELLIE_RUN_BUILDER: Maximum Laser intensity is invalid. Setting to 100%% by Default\n");
    }
    
    if((maxLaserIntensity < 0) ||(maxLaserIntensity > 100))
    {
        maxLaserIntensity = 100;
        [smellieMaxIntensity setIntValue:maxLaserIntensity];
        NSLog(@"SMELLIE_RUN_BUILDER: Maximum Laser intensity is too high (or too low). Setting to 100%% by Default\n");
    }
}

-(IBAction)validateLaserMinIntensity:(id)sender;
{
    NSString* minLaserIntString = [smellieMinIntensity stringValue];
    int minLaserIntensity;
    
    @try{
        minLaserIntensity  = [minLaserIntString intValue];
    }
    @catch (NSException *e) {
        minLaserIntensity = 20;
        [smellieMinIntensity setIntValue:minLaserIntensity];
        NSLog(@"SMELLIE_RUN_BUILDER: Minimum Laser intensity is invalid. Setting to 20%% by Default\n");
    }
    
    if((minLaserIntensity < 0) || (minLaserIntensity > 100))
    {
        minLaserIntensity = 0;
        [smellieMinIntensity setIntValue:minLaserIntensity];
        NSLog(@"SMELLIE_RUN_BUILDER: Minimum Laser intensity is too low or high. Setting to 0%% by Default\n");
    }
}

//The number of intensity steps cannot be more than the maximum intensity less minimum intensity 
-(IBAction)validateIntensitySteps:(id)sender;
{
    int numberOfIntensitySteps;
    int maxNumberOfSteps;
    
    @try{
        numberOfIntensitySteps = [smellieNumIntensitySteps intValue];
        maxNumberOfSteps = [smellieMaxIntensity intValue] - [smellieMinIntensity intValue];
    }
    @catch(NSException *e){
        NSLog(@"SMELLIE_RUN_BUILDER: Number of Intensity steps is invalid. Setting the number of steps to 1\n");
        numberOfIntensitySteps = 1;
        [smellieNumIntensitySteps setIntValue:numberOfIntensitySteps];
    }
    
    if( (numberOfIntensitySteps > maxNumberOfSteps)|| (numberOfIntensitySteps < 1) || (remainderf((1.0*maxNumberOfSteps),(1.0*numberOfIntensitySteps)) != 0)){
        numberOfIntensitySteps = 1;
        [smellieNumIntensitySteps setIntValue:numberOfIntensitySteps];
        NSLog(@"SMELLIE_RUN_BUILDER: Number of Intensity steps is invalid. Setting the the maximum correct value\n");
    }
    
}

//checks to make sure the trigger frequency isn't too high
-(IBAction)validateSmellieTriggerFrequency:(id)sender;
{
    int triggerFrequency;
    //maxmium allowed trigger frequency in the GUI
    int maxmiumTriggerFrequency = 1000;
    
    @try{
        triggerFrequency = [smellieTriggerFrequency intValue];
    }
    @catch(NSException *e){
        NSLog(@"SMELLIE_RUN_BUILDER: Trigger Frequency is invalid. Setting the frequency to 10 Hz\n");
        triggerFrequency = 10;
        [smellieTriggerFrequency setIntValue:triggerFrequency];
    }
    
    if( (triggerFrequency > maxmiumTriggerFrequency) || (triggerFrequency < 0)){
        [smellieTriggerFrequency setIntValue:10];
        NSLog(@"SMELLIE_RUN_BUILDER: Trigger Frequency is invalid. Setting the frequency to 10 Hz\n");
    }
}

-(IBAction)validateNumTriggersPerStep:(id)sender;
{
    int numberTriggersPerStep;
    //maxmium allowed number of triggers per loop
    int maximumNumberTriggersPerStep = 100000;
    
    @try{
        numberTriggersPerStep = [smellieNumTriggersPerLoop intValue];
    }
    @catch(NSException *e){
        NSLog(@"SMELLIE_RUN_BUILDER: Triggers per loop is invalid. Setting to 100\n");
        [smellieNumTriggersPerLoop setIntValue:100];
    }
    
    if( (numberTriggersPerStep > maximumNumberTriggersPerStep) || (numberTriggersPerStep < 0)){
        NSLog(@"SMELLIE_RUN_BUILDER: Triggers per loop is invalid. Setting to 100\n");
        [smellieNumTriggersPerLoop setIntValue:100];
    }
}

-(IBAction)validationSmellieRunAction:(id)sender;
{
    //NSLog(@" output: %@",[model callPythonScript:@"/Users/jonesc/testScript.py" withCmdLineArgs:nil]);
    [smellieMakeNewRunButton setEnabled:NO];
    
    //Error messages
    NSString* smellieRunErrorString = [[NSString alloc] initWithString:@"Unable to Validate. Check all fields are entered and see Status and Error Log" ];
    
    NSNumber* validationErrorFlag = [NSNumber numberWithInt:1];
    //validationErrorFlag = [NSNumber numberWithInt:1];
    
    //check the Operator has entered their name 
    if([[smellieOperatorName stringValue] length] == 0){
        NSLog(@"SMELLIE_RUN_BUILDER:Please enter a Operator Name \n");
    }

    //TODO:Check there are no files with the same name (although each will have a unique id)
    //check the Operator has a valid run name 
    else if([[smellieRunName stringValue] length] == 0){
        NSLog(@"SMELLIE_RUN_BUILDER:Please enter a Run Name\n");
    }
    
    //check that an operation mode has been given 
    else if([[smellieOperationMode stringValue] length] == 0){
        NSLog(@"SMELLIE_RUN_BUILDER:Please enter an Operation Mode \n");
    }
    
    //check the maximum laser intensity is given
    else if([[smellieMaxIntensity stringValue] length] == 0){
        NSLog(@"SMELLIE_RUN_BUILDER:Please enter an Maxmium Laser Intensity\n");
    }
    
    //check the minimum laser intensity is given
    else if([[smellieMinIntensity stringValue] length] == 0){
        NSLog(@"SMELLIE_RUN_BUILDER:Please enter an Minimum Laser Intensity\n");
    }
    
    //check the intensity step is given 
    else if([[smellieNumIntensitySteps stringValue] length] == 0){
        NSLog(@"SMELLIE_RUN_BUILDER:Please enter a number of intensity steps\n");
    }
    
    //check the trigger frequency is given 
    else if([[smellieTriggerFrequency stringValue] length] == 0){
        NSLog(@"SMELLIE_RUN_BUILDER:Please enter a trigger frequency\n");
    }
    
    //check the trigger frequency is given
    else if([[smellieNumTriggersPerLoop stringValue] length] == 0){
        NSLog(@"SMELLIE_RUN_BUILDER:Please enter a number of triggers per loop\n");
    }
    
    else{
        validationErrorFlag = [NSNumber numberWithInt:2];
    }
    
    //If any errors has been detected in the validation 
    if([validationErrorFlag intValue] == 1){
        [smellieRunErrorTextField setStringValue:smellieRunErrorString];
        [smellieMakeNewRunButton setEnabled:NO]; //Disable the user from this button
    }
    else if ([validationErrorFlag intValue] == 2){
        [smellieRunErrorTextField setStringValue:@"No Error"];
        [smellieMakeNewRunButton setEnabled:YES]; //Enable the user from this button

        //We need to block out all the textFields until the run has been submitted!
        [smellieNumIntensitySteps setEnabled:NO];
        [smellieMaxIntensity setEnabled:NO];
        [smellieMinIntensity setEnabled:NO];
        [smellieNumTriggersPerLoop setEnabled:NO];
        [smellieOperationMode setEnabled:NO];
        [smellieOperatorName setEnabled:NO];
        [smellieTriggerFrequency setEnabled:NO];
        [smellieRunName setEnabled:NO];
        [smellie405nmLaserButton setEnabled:NO];
        [smellie375nmLaserButton setEnabled:NO];
        [smellie440nmLaserButton setEnabled:NO];
        [smellie500nmLaserButton setEnabled:NO];
        [smellieFibreButtonFS007 setEnabled:NO];
        [smellieFibreButtonFS107 setEnabled:NO];
        [smellieFibreButtonFS207 setEnabled:NO];
        [smellieFibreButtonFS025 setEnabled:NO];
        [smellieFibreButtonFS125 setEnabled:NO];
        [smellieFibreButtonFS225 setEnabled:NO];
        [smellieFibreButtonFS037 setEnabled:NO];
        [smellieFibreButtonFS137 setEnabled:NO];
        [smellieFibreButtonFS237 setEnabled:NO];
        [smellieFibreButtonFS055 setEnabled:NO];
        [smellieFibreButtonFS155 setEnabled:NO];
        [smellieFibreButtonFS255 setEnabled:NO];
        [smellieAllFibresButton setEnabled:NO];
        [smellieAllLasersButton setEnabled:NO];
        
    }
    else{
        NSLog(@"SMELLIE_BUILD_RUN: Unknown invalid Entry or no entries sent\n");
    }
    
    [smellieRunErrorString release];
    
    //Example functions of how this values can be pulled 
    //state 1 is ON, state 0 is OFF for these buttons
    //NSLog(@"375 laser setting %i \n",[smellie375nmLaserButton state]);
    //NSLog(@"Entry into the Operator Field %@ \n",[smellieOperationMode stringValue]);
    
    //[model validationSmellieSettings];
}

-(IBAction)makeNewSmellieRun:(id)sender
{
    NSAutoreleasePool* smellieSettingsPool = [[NSAutoreleasePool alloc] init];
    
    NSMutableDictionary * smellieRunSettingsFromGUI = [NSMutableDictionary dictionaryWithCapacity:100];
    
    //Build Objects to store values
    NSString * smellieOperatorNameString = [NSString stringWithString:[smellieOperatorName stringValue]];
    NSString * smellieRunNameString = [NSString stringWithString:[smellieRunName stringValue]];
    NSString * smellieOperatorModeString = [NSString stringWithString:[smellieOperationMode stringValue]];
    
    NSNumber * smellieMaxIntensityNum = [NSNumber numberWithInt:[smellieMaxIntensity intValue]];
    NSNumber * smellieMinIntensityNum = [NSNumber numberWithInt:[smellieMinIntensity intValue]];
    NSNumber * smellieNumIntensityStepsNum = [NSNumber numberWithInt:[smellieNumIntensitySteps intValue]];
    NSNumber * smellieTriggerFrequencyNum = [NSNumber numberWithInt:[smellieTriggerFrequency intValue]];
    NSNumber * smellieNumTriggersPerLoopNum = [NSNumber numberWithInt:[smellieNumTriggersPerLoop intValue]];
    
    NSNumber * smellie405nmLaserButtonNum = [NSNumber numberWithInteger:[smellie405nmLaserButton state]];
    NSNumber * smellie375nmLaserButtonNum = [NSNumber numberWithInteger:[smellie375nmLaserButton state]];
    NSNumber * smellie440nmLaserButtonNum = [NSNumber numberWithInteger:[smellie440nmLaserButton state]];
    NSNumber * smellie500nmLaserButtonNum = [NSNumber numberWithInteger:[smellie500nmLaserButton state]];
    
    NSNumber * smellieFibreButtonFS007Num = [NSNumber numberWithInteger:[smellieFibreButtonFS007 state]];
    NSNumber * smellieFibreButtonFS107Num = [NSNumber numberWithInteger:[smellieFibreButtonFS107 state]];
    NSNumber * smellieFibreButtonFS207Num = [NSNumber numberWithInteger:[smellieFibreButtonFS207 state]];
    NSNumber * smellieFibreButtonFS025Num = [NSNumber numberWithInteger:[smellieFibreButtonFS025 state]];
    NSNumber * smellieFibreButtonFS125Num = [NSNumber numberWithInteger:[smellieFibreButtonFS125 state]];
    NSNumber * smellieFibreButtonFS225Num = [NSNumber numberWithInteger:[smellieFibreButtonFS225 state]];
    NSNumber * smellieFibreButtonFS037Num = [NSNumber numberWithInteger:[smellieFibreButtonFS037 state]];
    NSNumber * smellieFibreButtonFS137Num = [NSNumber numberWithInteger:[smellieFibreButtonFS137 state]];
    NSNumber * smellieFibreButtonFS237Num = [NSNumber numberWithInteger:[smellieFibreButtonFS237 state]];
    NSNumber * smellieFibreButtonFS055Num = [NSNumber numberWithInteger:[smellieFibreButtonFS055 state]];
    NSNumber * smellieFibreButtonFS155Num = [NSNumber numberWithInteger:[smellieFibreButtonFS155 state]];
    NSNumber * smellieFibreButtonFS255Num = [NSNumber numberWithInteger:[smellieFibreButtonFS255 state]];
    
    
    [smellieRunSettingsFromGUI setObject:smellieOperatorNameString forKey:@"operator_name"];
    [smellieRunSettingsFromGUI setObject:smellieRunNameString forKey:@"run_name"];
    [smellieRunSettingsFromGUI setObject:smellieOperatorModeString forKey:@"operation_mode"];
    [smellieRunSettingsFromGUI setObject:smellieMaxIntensityNum forKey:@"max_laser_intensity"];
    [smellieRunSettingsFromGUI setObject:smellieMinIntensityNum forKey:@"min_laser_intensity"];
    [smellieRunSettingsFromGUI setObject:smellieNumIntensityStepsNum forKey:@"num_intensity_steps"];
    [smellieRunSettingsFromGUI setObject:smellieTriggerFrequencyNum forKey:@"trigger_frequency"];
    [smellieRunSettingsFromGUI setObject:smellieNumTriggersPerLoopNum forKey:@"triggers_per_loop"];
    [smellieRunSettingsFromGUI setObject:smellie375nmLaserButtonNum forKey:@"375nm_laser_on"];
    [smellieRunSettingsFromGUI setObject:smellie405nmLaserButtonNum forKey:@"405nm_laser_on"];
    [smellieRunSettingsFromGUI setObject:smellie440nmLaserButtonNum forKey:@"440nm_laser_on"];
    [smellieRunSettingsFromGUI setObject:smellie500nmLaserButtonNum forKey:@"500nm_laser_on"];
    
    //Fill the SMELLIE Fibre Array information
    [smellieRunSettingsFromGUI setObject:smellieFibreButtonFS007Num forKey:@"FS007"];
    [smellieRunSettingsFromGUI setObject:smellieFibreButtonFS107Num forKey:@"FS107"];
    [smellieRunSettingsFromGUI setObject:smellieFibreButtonFS207Num forKey:@"FS207"];
    [smellieRunSettingsFromGUI setObject:smellieFibreButtonFS025Num forKey:@"FS025"];
    [smellieRunSettingsFromGUI setObject:smellieFibreButtonFS125Num forKey:@"FS125"];
    [smellieRunSettingsFromGUI setObject:smellieFibreButtonFS225Num forKey:@"FS225"];
    [smellieRunSettingsFromGUI setObject:smellieFibreButtonFS037Num forKey:@"FS037"];
    [smellieRunSettingsFromGUI setObject:smellieFibreButtonFS137Num forKey:@"FS137"];
    [smellieRunSettingsFromGUI setObject:smellieFibreButtonFS237Num forKey:@"FS237"];
    [smellieRunSettingsFromGUI setObject:smellieFibreButtonFS055Num forKey:@"FS055"];
    [smellieRunSettingsFromGUI setObject:smellieFibreButtonFS155Num forKey:@"FS155"];
    [smellieRunSettingsFromGUI setObject:smellieFibreButtonFS255Num forKey:@"FS255"];
    
    NSLog(@" operator_name (string) %@\n",[smellieRunSettingsFromGUI objectForKey:@"operator_name"]);
    NSLog(@" max intensity (string) %@\n",[smellieRunSettingsFromGUI objectForKey:@"max_laser_intensity"]);
    NSLog(@" laser state (string) %@\n",[smellieRunSettingsFromGUI objectForKey:@"405nm_laser_on"]);
    
    [model smellieDBpush:smellieRunSettingsFromGUI];
    
    //Re-enable these buttons for editing
    [smellieNumIntensitySteps setEnabled:YES];
    [smellieMaxIntensity setEnabled:YES];
    [smellieMinIntensity setEnabled:YES];
    [smellieNumTriggersPerLoop setEnabled:YES];
    [smellieOperationMode setEnabled:YES];
    [smellieOperatorName setEnabled:YES];
    [smellieTriggerFrequency setEnabled:YES];
    [smellieRunName setEnabled:YES];
    [smellie405nmLaserButton setEnabled:YES];
    [smellie375nmLaserButton setEnabled:YES];
    [smellie440nmLaserButton setEnabled:YES];
    [smellie500nmLaserButton setEnabled:YES];
    [smellieFibreButtonFS007 setEnabled:YES];
    [smellieFibreButtonFS107 setEnabled:YES];
    [smellieFibreButtonFS207 setEnabled:YES];
    [smellieFibreButtonFS025 setEnabled:YES];
    [smellieFibreButtonFS125 setEnabled:YES];
    [smellieFibreButtonFS225 setEnabled:YES];
    [smellieFibreButtonFS037 setEnabled:YES];
    [smellieFibreButtonFS137 setEnabled:YES];
    [smellieFibreButtonFS237 setEnabled:YES];
    [smellieFibreButtonFS055 setEnabled:YES];
    [smellieFibreButtonFS155 setEnabled:YES];
    [smellieFibreButtonFS255 setEnabled:YES];
    [smellieAllFibresButton setEnabled:YES];
    [smellieAllLasersButton setEnabled:YES];
    [smellieMakeNewRunButton setEnabled:NO];
    
    [smellieSettingsPool drain];
    
}

-(void) fetchCurrentTellieSubRunFile
{
    NSArray*  objs = [[(ORAppDelegate*)[NSApp delegate] document] collectObjectsOfClass:NSClassFromString(@"SNOPModel")];
    SNOPModel* aSnotModel = [objs objectAtIndex:0];
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%u/smellie/_design/smellieMainQuery/_view/fetchMostRecentConfigVersion?descending=True&limit=1",[aSnotModel orcaDBIPAddress],[aSnotModel orcaDBPort]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSNumber *currentVersionNumber;
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSError *error =  nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[ret dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if(!error){
        @try{
            //format the json response
            NSString *stringValueOfCurrentVersion = [NSString stringWithFormat:@"%@",[[[json valueForKey:@"rows"] valueForKey:@"value"]objectAtIndex:0]];
            currentVersionNumber = [NSNumber numberWithInt:[stringValueOfCurrentVersion intValue]];
        }
        @catch (NSException *e) {
            NSLog(@"Error in fetching from the TellieDb: %@",e);
        }
    }
    else{
        NSLog(@"Error querying couchDB, please check the connection is correct %@",error);
    }

}

//Submit Smellie configuration file to the Database
-(IBAction)onSelectOfSepiaInput:(id)sender
{
    
    //TODO: Read in current information about that Sepia Input and to the detector
    //[self fetchRecentVersion];
    //Download the most recent smellie configuration - this is implemented by run number
    //NSArray*  objs = [[[NSApp delegate] document] collectObjectsOfClass:NSClassFromString(@"ELLIEModel")];
    //ELLIEModel* anELLIEModel = [objs objectAtIndex:0];
    //[anELLIEModel fetchSmellieConfigurationInformation];
    
    //print down the current self-test pmt values
    [smellieConfigSelfTestNoOfPulses setStringValue:[configForSmellie objectForKey:@"selfTestNumOfPulses"]];
    [smellieConfigSelfTestLaserTriggerFreq setStringValue:[configForSmellie objectForKey:@"selfTestLaserTrigFrequency"]];
    [smellieConfigSelfTestPmtSampleRate setStringValue:[configForSmellie objectForKey:@"selfTestPmtSamplerRate"]];
    [smellieConfigSelfTestNoOfPulsesPerLaser setStringValue:[configForSmellie objectForKey:@"selfTestNumOfPulsesPerLaser"]];
    [smellieConfigSelfTestNiTriggerOutputPin setStringValue:[configForSmellie objectForKey:@"selfTestNiTriggerOutputPin"]];
    [smellieConfigSelfTestNiTriggerInputPin setStringValue:[configForSmellie objectForKey:@"selfTestNiTriggerInputPin"]];
    
    
    int laserHeadIndex = [sender indexOfSelectedItem];
    
    for (id specificConfigValue in configForSmellie){
        if([specificConfigValue isEqualToString:[NSString stringWithFormat:@"laserInput%i",laserHeadIndex]]){
            
            //Get the values of the configuration
            NSString *laserHeadConnected = [NSString stringWithFormat:@"%@",[[configForSmellie objectForKey:specificConfigValue] objectForKey:@"laserHeadConnected"]];
            NSString *attentuatorConnected = [NSString stringWithFormat:@"%@",[[configForSmellie objectForKey:specificConfigValue] objectForKey:@"splitterTypeConnected"]];
            NSString *fibreSwitchInputConnected = [NSString stringWithFormat:@"%@",[[configForSmellie objectForKey:specificConfigValue] objectForKey:@"fibreSwitchInputConnected"]];
            NSString *attenutationFactor = [NSString stringWithFormat:@"%@",[[configForSmellie objectForKey:specificConfigValue] objectForKey:@"attenuationFactor"]];
            NSString *gainControlFactor = [NSString stringWithFormat:@"%@",[[configForSmellie objectForKey:specificConfigValue] objectForKey:@"gainControlFactor"]];
            
            @try{
                //try and select the correct index of the combo boxes to make this work 
                [smellieConfigLaserHeadField selectItemAtIndex:[smellieConfigLaserHeadField indexOfItemWithObjectValue:laserHeadConnected]];
                [smellieConfigAttenuatorField selectItemAtIndex:[smellieConfigAttenuatorField indexOfItemWithObjectValue:attentuatorConnected]];
                [smellieConfigFsInputCh selectItemAtIndex:[smellieConfigFsInputCh indexOfItemWithObjectValue:fibreSwitchInputConnected]];
                [smellieConfigAttenutationFactor setStringValue:attenutationFactor];
                [smellieConfigGainControl setStringValue:gainControlFactor];
                laserHeadSelected = YES;
            }
            @catch (NSException * error) {
                NSLog(@"Error Parsing Configuration File: %@",error);
            }
            
        }
    }
}

-(IBAction)onClickLaserHead:(id)sender
{
    if(laserHeadSelected){
        //update the correct value which is selected
        NSString *currentSepiaInputChannel = [NSString stringWithFormat:@"laserInput%@",[smellieConfigSepiaInputChannel objectValueOfSelectedItem]];
        
        //copy the current object into an array
        NSMutableDictionary *currentSmellieConfigForSepiaInput = [[[configForSmellie objectForKey:currentSepiaInputChannel] mutableCopy] autorelease];
        
        //update with new value
        [currentSmellieConfigForSepiaInput setObject:[smellieConfigLaserHeadField objectValueOfSelectedItem] forKey:@"laserHeadConnected"];
        [configForSmellie setObject:currentSmellieConfigForSepiaInput forKey:currentSepiaInputChannel];

    }
}


- (IBAction)onClickAttenuator:(id)sender
{
    if(laserHeadSelected){
        //update the correct value which is selected
        NSString *currentSepiaInputChannel = [NSString stringWithFormat:@"laserInput%@",[smellieConfigSepiaInputChannel objectValueOfSelectedItem]];
        
        //copy the current object into an array
        NSMutableDictionary *currentSmellieConfigForSepiaInput = [[[configForSmellie objectForKey:currentSepiaInputChannel] mutableCopy] autorelease];
        
        //update with new value
        [currentSmellieConfigForSepiaInput setObject:[smellieConfigAttenuatorField objectValueOfSelectedItem] forKey:@"splitterTypeConnected"];
        [configForSmellie setObject:currentSmellieConfigForSepiaInput forKey:currentSepiaInputChannel];
    
    }
}

- (IBAction)onClickFibreSwithInput:(id)sender
{
    if(laserHeadSelected){
        //update the correct value which is selected
        NSString *currentSepiaInputChannel = [NSString stringWithFormat:@"laserInput%@",[smellieConfigSepiaInputChannel objectValueOfSelectedItem]];
        
        //copy the current object into an array
        NSMutableDictionary *currentSmellieConfigForSepiaInput = [[[configForSmellie objectForKey:currentSepiaInputChannel] mutableCopy] autorelease];
        
        //update with new value
        [currentSmellieConfigForSepiaInput setObject:[smellieConfigFsInputCh objectValueOfSelectedItem] forKey:@"fibreSwitchInputConnected"];
        [configForSmellie setObject:currentSmellieConfigForSepiaInput forKey:currentSepiaInputChannel];
        
    }
}
- (IBAction)onClickFibeSwitchOutput:(id)sender
{
    //TODO: Read in current information about that Sepia Input and to the detector
    for (id specificConfigValue in configForSmellie){
        if([specificConfigValue isEqualToString:[NSString stringWithFormat:@"%@",[sender objectValueOfSelectedItem]]]){
            
            //Get the values of the configuration
            NSString *detectorFibreReference = [NSString stringWithFormat:@"%@",[[configForSmellie objectForKey:specificConfigValue] objectForKey:@"detectorFibreReference"]];
            
            
            @try{
                //try and select the correct index of the combo boxes to make this work
                [smellieConfigDetectorFibreRef selectItemAtIndex:[smellieConfigDetectorFibreRef indexOfItemWithObjectValue:detectorFibreReference]];
                fibreSwitchOutputSelected = YES;
            }
            @catch (NSException * error) {
                NSLog(@"Error Parsing Configuration File: %@",error);
            }
            
        }
    }
}

- (IBAction)onClickDetectorFibreReference:(id)sender
{
    if(fibreSwitchOutputSelected){
        //update the correct value which is selected
        NSString *currentSepiaInputChannel = [NSString stringWithFormat:@"%@",[smellieConfigFsOutputCh objectValueOfSelectedItem]];
        
        //copy the current object into an array
        NSMutableDictionary *currentSmellieConfigForSepiaInput = [[[configForSmellie objectForKey:currentSepiaInputChannel] mutableCopy] autorelease];
        
        //update with new value
        [currentSmellieConfigForSepiaInput setObject:[smellieConfigDetectorFibreRef objectValueOfSelectedItem] forKey:@"detectorFibreReference"];
        [configForSmellie setObject:currentSmellieConfigForSepiaInput forKey:currentSepiaInputChannel];
    }
}


BOOL isNumeric(NSString *s)
{
    NSScanner *sc = [NSScanner scannerWithString: s];
    if ( [sc scanFloat:NULL] )
    {
        return [sc isAtEnd];
    }
    return NO;
}


- (IBAction)onChangeAttenuationFactor:(id)sender
{
    if(laserHeadSelected){
        
        float attenutationFactor = [smellieConfigAttenutationFactor floatValue];
        
        BOOL isAttenutationFactorNumeric = isNumeric([smellieConfigAttenutationFactor stringValue]);
        
        if(isAttenutationFactorNumeric == YES){
            
            //check the attenuation factor makes sense
            if((attenutationFactor < 0.0) || (attenutationFactor > 100.0)){
                NSLog(@"SMELLIE_CONFIGURATION_BUILDER: Please enter an attentuation factor between 0.0 and 100.0\n");
                [smellieConfigAttenutationFactor setFloatValue:0.0];
            }
            else{
                NSString *currentSepiaInputChannel = [NSString stringWithFormat:@"laserInput%@",[smellieConfigSepiaInputChannel objectValueOfSelectedItem]];
                //copy the current object into an array
                NSMutableDictionary *currentSmellieConfigForSepiaInput = [[[configForSmellie objectForKey:currentSepiaInputChannel] mutableCopy] autorelease];
                [currentSmellieConfigForSepiaInput
                    setObject:[NSString stringWithString:[smellieConfigAttenutationFactor stringValue]]
                    forKey:@"attenuationFactor"];
        
        
                [configForSmellie setObject:currentSmellieConfigForSepiaInput forKey:currentSepiaInputChannel];
            }
        }
        else{
            NSLog(@"SMELLIE_CONFIGURATION_BUILDER: Please enter a numerical value for the attenutation Factor\n");
            [smellieConfigAttenutationFactor setFloatValue:0.0];
        }
    }
}

-(IBAction)onChangeGainControlVoltage:(id)sender
{
    if(laserHeadSelected){
        float gainVoltageFactor = [smellieConfigGainControl floatValue];
        BOOL isGainVoltageFactorNumeric = isNumeric([smellieConfigAttenutationFactor stringValue]);
        if(isGainVoltageFactorNumeric == YES){
            //check the gain control factor makes sense
            if((gainVoltageFactor < 0.0) || (gainVoltageFactor > 0.5)){
                NSLog(@"SMELLIE_CONFIGURATION_BUILDER: Please enter an attentuation factor between 0.0 and 0.5\n");
                [smellieConfigAttenutationFactor setFloatValue:0.0];
            }
            else{
                NSString *currentSepiaInputChannel = [NSString stringWithFormat:@"laserInput%@",[smellieConfigSepiaInputChannel objectValueOfSelectedItem]];
                //copy the current object into an array
                NSMutableDictionary *currentSmellieConfigForSepiaInput = [[[configForSmellie objectForKey:currentSepiaInputChannel] mutableCopy] autorelease];
                [currentSmellieConfigForSepiaInput
                 setObject:[NSString stringWithString:[smellieConfigGainControl stringValue]]
                 forKey:@"gainControlFactor"];
                
                [configForSmellie setObject:currentSmellieConfigForSepiaInput forKey:currentSepiaInputChannel];
            }
        }
        else{
            NSLog(@"SMELLIE_CONFIGURATION_BUILDER: Please enter a numerical value for the gain Control Factor\n");
            [smellieConfigGainControl setFloatValue:0.0];
        }
    }
}

- (IBAction)onClickNumOfPulses:(id)sender
{
    //copy the current object into an array
    NSMutableDictionary *currentSmellieConfig = [[configForSmellie mutableCopy] autorelease];
    
    BOOL isNumOfPulsesNumeric = isNumeric([smellieConfigSelfTestNoOfPulses stringValue]);
    
    if(isNumOfPulsesNumeric == YES){
        [currentSmellieConfig setObject:[NSString stringWithString:[smellieConfigSelfTestNoOfPulses stringValue]]
                                 forKey:@"selfTestNumOfPulses"];
        configForSmellie = [currentSmellieConfig mutableCopy];
    }
    else{
        NSLog(@"SMELLIE_CONFIGURATION_BUILDER: Please enter a numerical value for the number of pulses\n");
        [smellieConfigSelfTestNoOfPulses setFloatValue:10.0];
    }
}

- (IBAction)onClickSelfTestLasertTrigFreq:(id)sender
{
    //copy the current object into an array
    NSMutableDictionary *currentSmellieConfig = [[configForSmellie mutableCopy] autorelease];
    
    BOOL isLaserFreqNumeric = isNumeric([smellieConfigSelfTestLaserTriggerFreq stringValue]);
    
    if(isLaserFreqNumeric == YES){
    
        float selfTestlaserFreq = [smellieConfigSelfTestLaserTriggerFreq floatValue];
        
        //PMT monitoring system cannot deal with a frequency that is greater than 17Khz.
        //Also it is dangerous to try and trigger the laser at high rates
        if((selfTestlaserFreq < 0.0) || (selfTestlaserFreq > 17000.0)){
            NSLog(@"SMELLIE_CONFIGURATION_BUILDER: Laser self test frequency has to be between 0.0 and 17000 Hz\n");
            [smellieConfigSelfTestNoOfPulses setFloatValue:10.0];
        }
        else{
            [currentSmellieConfig setObject:[NSString stringWithString:[smellieConfigSelfTestLaserTriggerFreq stringValue]]
                                     forKey:@"selfTestLaserTrigFrequency"];
            configForSmellie = [currentSmellieConfig mutableCopy];
        }
    }
    else{
        NSLog(@"SMELLIE_CONFIGURATION_BUILDER: Please enter a numerical value for the Self test laser frequency\n");
    }
}

- (IBAction)onClickSelfTestPmtSampleRate:(id)sender
{
    //copy the current object into an array
    NSMutableDictionary *currentSmellieConfig = [[configForSmellie mutableCopy] autorelease];
    
    BOOL isSelfTestPmtSampleRateNumeric = isNumeric([smellieConfigSelfTestPmtSampleRate stringValue]);
    
    if(isSelfTestPmtSampleRateNumeric == YES){
    
        [currentSmellieConfig setObject:[NSString stringWithString:[smellieConfigSelfTestPmtSampleRate stringValue]]
                                 forKey:@"selfTestPmtSamplerRate"];
    
        configForSmellie = [currentSmellieConfig mutableCopy];
    }
    else{
        NSLog(@"SMELLIE_CONFIGURATION_BUILDER: Please enter a numerical value for the Self test Pmt sample rate\n");
    }
}

//PMT samples to take per Laser
- (IBAction)onClickNumOfPulsesPerLaser:(id)sender
{
    NSMutableDictionary *currentSmellieConfig = [[configForSmellie mutableCopy] autorelease];
    
    BOOL isNumberOfPulsesPerLaserNumeric = isNumeric([smellieConfigSelfTestNoOfPulsesPerLaser stringValue]);
    
    if(isNumberOfPulsesPerLaserNumeric == YES){
    
        [currentSmellieConfig setObject:[NSString stringWithString:[smellieConfigSelfTestNoOfPulsesPerLaser stringValue]]
                                 forKey:@"selfTestNumOfPulsesPerLaser"];
    
        configForSmellie = [currentSmellieConfig mutableCopy];
    }
    else{
        NSLog(@"SMELLIE_CONFIGURATION_BUILDER: Please enter a numerical value for the Self test Pmt samples per laser\n");
    }
}

- (IBAction)onClickNiTriggerOutputPin:(id)sender
{
    NSMutableDictionary *currentSmellieConfig = [[configForSmellie mutableCopy] autorelease];
    
    [currentSmellieConfig setObject:[NSString stringWithString:[smellieConfigSelfTestNiTriggerOutputPin stringValue]]
                             forKey:@"selfTestNiTriggerOutputPin"];
    
    configForSmellie = [currentSmellieConfig mutableCopy];
}
- (IBAction)onClickNiTriggerInputPin:(id)sender
{
    NSMutableDictionary *currentSmellieConfig = [[configForSmellie mutableCopy] autorelease];
    
    [currentSmellieConfig setObject:[NSString stringWithString:[smellieConfigSelfTestNiTriggerInputPin stringValue]]
                             forKey:@"selfTestNiTriggerInputPin"];
    
    configForSmellie = [currentSmellieConfig mutableCopy];
}

-(IBAction)onClickValidateSmellieConfig:(id)sender
{
    //TODO: Check the file is correct and send a message to the user
    
    [smellieConfigSubmitButton setEnabled:YES];
}

- (IBAction)onClickSubmitButton:(id)sender
{
    
    //add a version number to the smellie configuration also add a run number 
    
    //post to the database
    [model smellieConfigurationDBpush:configForSmellie];
    [self close];
}


//Custom Command for Smellie
-(IBAction)executeSmellieCmdDirectAction:(id)sender
{
    NSString * cmd = [[[NSString alloc] init] autorelease];
    NSLog(@"CMD %@",[executeCmdBox stringValue]);
    NSLog(@"CMD %i",[executeCmdBox indexOfSelectedItem]);
    
    int cmdIndex = [executeCmdBox indexOfSelectedItem];
    
    if(cmdIndex == 0){
        cmd = @"10";
    }
    else if (cmdIndex == 1){
        cmd = @"20";
    }
    else if (cmdIndex == 2){
        cmd = @"30";
    }
    else if (cmdIndex == 3){
        cmd = @"2050";
    }
    else if (cmdIndex == 4){
        cmd = @"40";
    }
    else if (cmdIndex == 5){
        cmd = @"50";
    }
    else if(cmdIndex == 6){
        cmd = @"60";
    }
    else if(cmdIndex == 7){
        cmd = @"70";
    }
    else if(cmdIndex == 8){
        [model setSmellieMasterMode:[NSString stringWithString:[smellieDirectArg1 stringValue]] withNumOfPulses:[NSString stringWithString:[smellieDirectArg2 stringValue]]];
        //cmd = @"80";
    }
    else if(cmdIndex == 9){
        //hardcoded command to kill external software on SNODROp (SMELLIE DAQ software)
        cmd = @"110";
    }
    else if(cmdIndex == 10){
        cmd = @"22110"; //c
    }
    else{
        cmd = @"0"; //not sure what is going on here
    }
    
    
    //NSString * cmd = [NSString stringWithString:[smellieDirectCmd stringValue]];
    NSString * arg1 = [NSString stringWithString:[smellieDirectArg1 stringValue]];
    NSString * arg2 = [NSString stringWithString:[smellieDirectArg2 stringValue]];
    if(arg1 == NULL){
        arg1 = @"0";
    }
    
    if(arg2 == NULL){
        arg2 = @"0";
    }
    
    [model sendCustomSmellieCmd:cmd withArgs:@[arg1, arg2]];
}
//TELLIE functions -------------------------


@end
