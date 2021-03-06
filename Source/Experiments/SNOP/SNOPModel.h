//
//  SNOPModel.h
//  Orca
//
//  Created by Mark Howe on Tue Apr 20, 2010.
//  Copyright (c) 2010  University of North Carolina. All rights reserved.
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


#pragma mark 짜짜짜Imported Files
#import "ORExperimentModel.h"
#import "ORVmeCardDecoder.h"
#import "RedisClient.h"

@class ORDataPacket;
@class ORDataSet;
@class ORCouchDB;
@class ORRunModel;

@protocol snotDbDelegate <NSObject>
@required
- (ORCouchDB*) orcaDbRef:(id)aCouchDelegate;
- (ORCouchDB*) debugDBRef:(id)aCouchDelegate;
- (ORCouchDB*) orcaDbRefWithEntryDB:(id)aCouchDelegate withDB:(NSString*)entryDB;
@end

#define kUseTubeView	0
#define kUseCrateView	1
#define kUsePSUPView	2
#define kNumTubes	20 //XL3s
#define kNumOfCrates 19 //number of Crates in SNO+

@interface SNOPModel: ORExperimentModel <snotDbDelegate>
{
	int viewType;

    NSString* _orcaDBUserName;
    NSString* _orcaDBPassword;
    NSString* _orcaDBName;
    unsigned int _orcaDBPort;
    NSString* _orcaDBIPAddress;
    NSMutableArray* _orcaDBConnectionHistory;
    NSUInteger _orcaDBIPNumberIndex;
    NSTask*	_orcaDBPingTask;
    
    NSString* _debugDBUserName;
    NSString* _debugDBPassword;
    NSString* _debugDBName;
    NSString* _smellieRunNameLabel;
    unsigned int _debugDBPort;
    NSString* _debugDBIPAddress;
    NSMutableArray* _debugDBConnectionHistory;
    NSUInteger _debugDBIPNumberIndex;
    NSTask*	_debugDBPingTask;
    
    unsigned long	_epedDataId;
    unsigned long	_rhdrDataId;
    
    struct {
        unsigned long coarseDelay;
        unsigned long fineDelay;
        unsigned long chargePulseAmp;
        unsigned long pedestalWidth;
        unsigned long calType; // pattern ID (1 to 4) + 10 * (1 ped, 2 tslope, 3 qslope)
        unsigned long stepNumber;
        unsigned long nTSlopePoints;
    } _epedStruct;
    
    struct {
        unsigned long date;
        unsigned long time;
        unsigned long daqCodeVersion;
        unsigned long runNumber;
        unsigned long calibrationTrialNumber;
        unsigned long sourceMask;
        unsigned long long runMask;
        unsigned long gtCrateMask;
    } _rhdrStruct;
    

    NSDictionary* _runDocument;
    NSDictionary* _configDocument;
    NSDictionary* _mtcConfigDoc;
    NSMutableDictionary* _runTypeDocumentPhysics;
    NSMutableDictionary* smellieRunFiles;
    
    bool _smellieDBReadInProgress;
    bool _smellieDocUploaded;
    NSString * standardRunType;
    NSString * standardRunVersion;
    NSString * lastStandardRunType;
    NSString * lastStandardRunVersion;
    
    bool rolloverRun;

    NSString *mtcHost;
    int mtcPort;

    NSString *xl3Host;
    int xl3Port;

    NSString *dataHost;
    int dataPort;

    NSString *logHost;
    int logPort;

    RedisClient *mtc_server;
    RedisClient *xl3_server;

    int state;
    int start;
    bool resync;

    @private
        //Run type word
        unsigned long runTypeWord;
        unsigned long lastRunTypeWord;
        NSString* lastRunTypeWordHex;
        //ECA stuff
        int ECA_pattern;
        NSString* ECA_type;
        int ECA_tslope_pattern;
        int ECA_nevents;
        NSNumber* ECA_rate;
    
}

@property (nonatomic,retain) NSMutableDictionary* smellieRunFiles;

@property (nonatomic,copy) NSString* orcaDBUserName;
@property (nonatomic,copy) NSString* orcaDBPassword;
@property (nonatomic,copy) NSString* orcaDBName;
@property (nonatomic,assign) unsigned int orcaDBPort;
@property (nonatomic,copy) NSString* orcaDBIPAddress;
@property (nonatomic,retain) NSMutableArray* orcaDBConnectionHistory;
@property (nonatomic,assign) NSUInteger orcaDBIPNumberIndex;
@property (nonatomic,retain) NSTask* orcaDBPingTask;

@property (nonatomic,copy) NSString* debugDBUserName;
@property (nonatomic,copy) NSString* debugDBPassword;
@property (nonatomic,copy) NSString* debugDBName;
@property (nonatomic,copy) NSString* smellieRunNameLabel;
@property (nonatomic,assign) unsigned int debugDBPort;
@property (nonatomic,copy) NSString* debugDBIPAddress;
@property (nonatomic,retain) NSMutableArray* debugDBConnectionHistory;
@property (nonatomic,assign) NSUInteger debugDBIPNumberIndex;
@property (nonatomic,retain) NSTask* debugDBPingTask;

@property (nonatomic,assign) unsigned long epedDataId;
@property (nonatomic,assign) unsigned long rhdrDataId;

@property (nonatomic,assign) bool smellieDBReadInProgress;
@property (nonatomic,assign) bool smellieDocUploaded;

@property (copy,setter=setDataServerHost:) NSString *dataHost;
@property (setter=setDataServerPort:) int dataPort;

@property (copy,setter=setLogServerHost:) NSString *logHost;
@property (setter=setLogServerPort:) int logPort;
@property (nonatomic,assign) bool resync;

- (id) init;

- (void) setMTCPort: (int) port;
- (int) mtcPort;

- (void) setMTCHost: (NSString *) host;
- (NSString *) mtcHost;

- (void) setXL3Port: (int) port;
- (int) xl3Port;

- (void) setXL3Host: (NSString *) host;
- (NSString *) xl3Host;

- (void) initOrcaDBConnectionHistory;
- (void) clearOrcaDBConnectionHistory;
- (id) orcaDBConnectionHistoryItem:(unsigned int)index;
- (void) orcaDBPing;

- (void) initDebugDBConnectionHistory;
- (void) clearDebugDBConnectionHistory;
- (id) debugDBConnectionHistoryItem:(unsigned int)index;
- (void) debugDBPing;

- (void) taskFinished:(NSTask*)aTask;
- (void) couchDBResult:(id)aResult tag:(NSString*)aTag op:(id)anOp;

- (void) pingCrates;

#pragma mark ⅴorcascript helpers
- (BOOL) isNotRunningOrInMaintenance;
- (void) zeroPedestalMasks;
- (void) updatePedestalMasks:(unsigned int)pattern;
- (void) hvMasterTriggersOFF;

#pragma mark 짜짜짜Notifications
- (void) registerNotificationObservers;

- (void) runInitialization:(NSNotification*)aNote;
- (void) runAboutToStart:(NSNotification*)aNote;
- (void) runStarted:(NSNotification*)aNote;
- (void) runAboutToStop:(NSNotification*)aNote;
- (void) runStopped:(NSNotification*)aNote;

- (void) _waitForBuffers;

- (void) subRunStarted:(NSNotification*)aNote;
- (void) subRunEnded:(NSNotification*)aNote;

- (void) updateEPEDStructWithCoarseDelay: (unsigned long) coarseDelay
                               fineDelay: (unsigned long) fineDelay
                          chargePulseAmp: (unsigned long) chargePulseAmp
                           pedestalWidth: (unsigned long) pedestalWidth
                                 calType: (unsigned long) calType;
- (void) updateEPEDStructWithStepNumber: (unsigned long) stepNumber;
- (void) shipSubRunRecord;
- (void) shipEPEDRecord;
- (void) updateRHDRSruct;
- (void) shipRHDRRecord;

#pragma mark 짜짜짜Accessors
- (void) setViewType:(int)aViewType;
- (int) viewType;
- (unsigned long) runTypeWord;
- (void) setRunTypeWord:(unsigned long)aMask;
- (unsigned long) lastRunTypeWord;
- (void) setLastRunTypeWord:(unsigned long)aMask;
- (NSString*) lastRunTypeWordHex;
- (void) setLastRunTypeWordHex:(NSString*)aValue;
- (NSString*) standardRunType;
- (void) setStandardRunType:(NSString*)aValue;
- (NSString*) standardRunVersion;
- (void) setStandardRunVersion:(NSString*)aValue;
- (NSString*) lastStandardRunType;
- (void) setLastStandardRunType:(NSString*)aValue;
- (NSString*) lastStandardRunVersion;
- (void) setLastStandardRunVersion:(NSString*)aValue;
- (int) ECA_pattern;
- (NSString*) ECA_type;
- (int) ECA_tslope_pattern;
- (int) ECA_nevents;
- (NSNumber*) ECA_rate;
- (void) setECA_pattern:(int)aValue;
- (void) setECA_type:(NSString*)aValue;
- (void) setECA_tslope_pattern:(int)aValue;
- (void) setECA_nevents:(int)aValue;
- (void) setECA_rate:(NSNumber*)aValue;

#pragma mark 짜짜짜Archival
- (id)initWithCoder:(NSCoder*)decoder;
- (void)encodeWithCoder:(NSCoder*)encoder;

#pragma mark 짜짜짜Segment Group Methods
- (void) makeSegmentGroups;

#pragma mark 짜짜짜Specific Dialog Lock Methods
- (NSString*) experimentMapLock;
- (NSString*) experimentDetectorLock;
- (NSString*) experimentDetailsLock;

#pragma mark 짜짜짜DataTaker
- (void) setDataIds:(id)assigner;
- (void) syncDataIdsWith:(id)anotherObj;
- (void) appendDataDescription:(ORDataPacket*)aDataPacket userInfo:(id)userInfo;
- (NSDictionary*) dataRecordDescription;

#pragma mark 짜짜짜SnotDbDelegate
- (ORCouchDB*) orcaDbRef:(id)aCouchDelegate;
- (ORCouchDB*) debugDBRef:(id)aCouchDelegate;
- (ORCouchDB*) orcaDbRefWithEntryDB:(id)aCouchDelegate withDB:(NSString*)entryDB;

//smellie functions -------
-(void) getSmellieRunFiles;

//Standard runs functions
-(BOOL) loadStandardRun:(NSString*)runTypeName withVersion:(NSString*)runVersion;
-(BOOL) saveStandardRun:(NSString*)runTypeName withVersion:(NSString*)runVersion;
-(void) loadSettingsInHW;

@end

@interface SNOPDecoderForRHDR : ORVmeCardDecoder {
}
- (unsigned long) decodeData:(void*)someData fromDecoder:(ORDecoder*)aDecoder intoDataSet:(ORDataSet*)aDataSet;
- (NSString*) dataRecordDescription:(unsigned long*)dataPtr;
@end

@interface SNOPDecoderForEPED : ORVmeCardDecoder {
}
- (unsigned long) decodeData:(void*)someData fromDecoder:(ORDecoder*)aDecoder intoDataSet:(ORDataSet*)aDataSet;
- (NSString*) dataRecordDescription:(unsigned long*)dataPtr;
@end

extern NSString* ORSNOPModelOrcaDBIPAddressChanged;
extern NSString* ORSNOPModelDebugDBIPAddressChanged;
extern NSString* ORSNOPRunTypeWordChangedNotification;
extern NSString* SNOPRunTypeChangedNotification;
extern NSString* ORSNOPRunsLockNotification;
extern NSString* ORSNOPModelRunsECAChangedNotification;
extern NSString* ORSNOPModelSRChangedNotification;
extern NSString* ORSNOPModelSRVersionChangedNotification;
