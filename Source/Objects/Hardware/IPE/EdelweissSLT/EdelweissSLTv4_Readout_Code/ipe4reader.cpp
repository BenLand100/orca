/***************************************************************************
    ipe4reader6.cpp  -  description: readout loop for the IPE4 Edelweiss firmware
    
	history: see below

    begin                : July 07 2011
    copyright            : (C) 2011 by Till Bergmann, KIT
    email                : Till.Bergmann@kit.edu
 ***************************************************************************/

//This is the version of the IPE4 readout code (display is: version/1000, so cew_controle will display 1934003 as 1934.003) -tb-
// VERSION_IPE4_HW is 1934 which means IPE4  (1=I, 9=P, 3=E, 4=4)
// VERSION_IPE4_SW is the version of the readout software (this file)
#define VERSION_IPE4_HW      1934200
#define VERSION_IPE4_SW            9
#define VERSION_IPE4READOUT (VERSION_IPE4_HW + VERSION_IPE4_SW)

/* History:
version 9: 2013 January
           added ipe4reader to Orca svn repository
               in shell use:
               (cd ORCA;make -f Makefile.ipe4reader; cd ..)
               (cd ORCA; ./ipe4reader ; cd ..)
           veto flag setting for ipe4reader config file
           FiberOutMask (FLT register) -> Orca GUI
           
version 8: 2012 October
           SLT now provides one single FIFO for all FLTs
		   Pointer to secondly pattern (0x3117....) in FIFO
		   
version 7: 2012 September
           Ready for using PCI bridge and external processor (rack PC) -> DMA block read
		   
version 6: 2012 April
           Realizes the new 'stream map' (or 'channel map') FLT FPGA design.
           1) Read status bits from FLT buffer.
           2) 1 SLT/HW FIFO corresponds to one or more FLTs (first milestone: 1 FLT = 1 FIFO)
           3) UDP K commands:
               read/write registers
               lines of config file
               commands to the stream loop (start/stop/init/reset)
               
version 5: 2012 January 07
           changed name to ipe4readerX, due to confusion of the name XXXcew
		   parallel readout of several FIFOs (fibre inputs)
		   
version 4: 2011 December 23
           is able to listen on dedicated IP adress (if e.g. 2 network cards are available);
		       to activate 2nd eth1 on PrPMC: activate in BIOS; ifconfig eth1 up; dhcpd eth1
			   
		   use HW (SLT) semaphore to write to command FIFO
		   
		   2012 December 03
		   implemented variable shift of the status bits (config-file option: skip_num_status_bits)
		   
		   2012 December 04
		   use dummy 'status bits' for BBv1
		   
version 3: 2011 November
           receive commands from cew_controle, deliver via command FIFO; 
		   extract status bits out of data stream, opera status from SLT register to deliver correct status UDP packet
		       -> cew_controle + IPE4 crate can be used without OPERA box (TBD: clock signal created by SLT)
		   spike finder (option in config-file
		   default config file: executable name + ".config"
		   ...-write2file is now in the same executable; create symbolic link to use several default config files
		   
version 2: 2011 September(?)
           added writing binary files; configuring with config file (write binary/ascii file, variable debug output, server/client IPs, etc.)
		   
version 1: 2011 July
           first version, which was able to deliver UDP packets to cew_controle
		   
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <time.h>
#include <errno.h>
#include <libgen.h> //for basename
#include <stdint.h>  //for uint32_t etc.



/*--------------------------------------------------------------------
 *    function prototypes
 *       TODO: function prototypes: move to include file somewhen in the future  -tb-
 *--------------------------------------------------------------------*/ //-tb-
void envoie_commande_horloge(void);



#if 0
#ifdef __cplusplus
extern "C" {
#endif
#include "SBC_Cmds.h"
#include "SBC_Config.h"
#include "SBC_Readout.h"
#include "CircularBuffer.h"
#include "SLTv4_HW_Definitions.h"
#ifdef __cplusplus
}
#endif
#endif



#if 0
#ifdef __cplusplus
extern "C" {
#endif
#include "pbusinterface.h"
#ifdef __cplusplus
}
#endif
#endif

/*--------------------------------------------------------------------
  kbhit
  --------------------------------------------------------------------*/
//found at: http://cboard.cprogramming.com/c-programming/63166-kbhit-linux.html
//speed is like kbhit2 (which uses select)
//both are much faster than kbhit3 from below!
//
//you may read the key with getchar() after kbhit() returned 1 -tb-
#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>

int kbhit(void)
{
  struct termios oldt, newt;
  int ch;
  int oldf;

  tcgetattr(STDIN_FILENO, &oldt);
  newt = oldt;
  newt.c_lflag &= ~(ICANON | ECHO);
  tcsetattr(STDIN_FILENO, TCSANOW, &newt);
  oldf = fcntl(STDIN_FILENO, F_GETFL, 0);
  fcntl(STDIN_FILENO, F_SETFL, oldf | O_NONBLOCK);

  ch = getchar();

  tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
  fcntl(STDIN_FILENO, F_SETFL, oldf);

  if(ch != EOF)
  {
    ungetc(ch, stdin);
    return 1;
  }

  return 0;
}


// I don't use kbhit2 and kbhit3; they work but use a lot of CPU power; kbhit is very fast -tb-
#if 0
//-----kbhit2-----  (using select)
// http://ohse.de/uwe/articles/kbhit.html
//Soetwas wie die DOS-Funktion kbhit stellt Unix nicht direkt zur Verfuegung, wohl aber das Mittel es zu emulieren: Die Funktion select.
//Dabei stellen sich folgendes Problem:
//
//    Das Terminal ist moeglicherweise im kanonischen Modus: Eingaben werden Zeile fuer Zeile bearbeitet. 
//      Dies ist der Default unter Unix (was man als Benutzer nicht so recht merkt weil Shells und Editoren als allererstes den nichtkanonischen Modus einstellen). 
//
//Derartige Terminaleingenschaften werden heutzutage mit tcsetattr veraendert. Es folgt eine Beispielimplementation von kbhit: #include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/time.h>
#include <termios.h>

#define MKFLAG(which) \
static int io_tio_set_flag_##which(int fd, int val, int on, int *old) \
{ struct termios tio; \
    if (tcgetattr(fd,&tio)) return -1; \
    if (old) *old=(tio.which & (val)); \
    if (on) tio.which |= (val); \
    else tio.which &= ~(val); \
    if (tcsetattr(fd,TCSADRAIN,&tio)) return -1; \
    return 0; \
} 

#if 0
static int io_tio_get_flag_##which(int fd, int bit, int *value) \
{ struct termios tio; \
    if (tcgetattr(fd,&tio)) return -1; \
    *value=(tio.which & (bit)); \
    return 0; \
}
#endif

MKFLAG(c_lflag)


static int 
io_charavail(int fd)
{
	fd_set set;
	struct timeval zeit;
	int ret;
	int tty=1;	
	int old_ICANON;
	FD_ZERO(&set);
	FD_SET(fd,&set);
	zeit.tv_sec  = 0;
	zeit.tv_usec = 0;
	if (-1==io_tio_set_flag_c_lflag(fd,ICANON,0,&old_ICANON)) {
		if (errno==EINVAL || errno==ENOTTY) 
			tty=0;
		else {
			perror("ICANON");
			return -1;
		}
	}

		
	while (1) {
		ret=select(fd+1,&set,0,0,&zeit);
		if (ret>=0) break;
		if (errno==EINTR) continue;
		perror("select");
		break;
	}
	if (tty)
		io_tio_set_flag_c_lflag(fd,ICANON,old_ICANON,NULL);
	return ret;
}


int kbhit2(void)
{
	char c;
	int r;

	r=io_charavail(0);
	printf("kbhit2: r is %i\n",r);
	if (r==-1) return(0);
	if (r) return 1; /* Zeichen verfuegbar */
	else   return 0; /* kein Zeichen verfuegbar */
	return (0);
}
#endif

#if 0
int kbhit3_main(void)
{
	char c;
	int r;

	r=io_charavail(0);
	if (r==-1) exit(1);
	if (r) exit(0); /* Zeichen verfuegbar */
	else   exit(3); /* kein Zeichen verfuegbar */
	return (0);
}
//-----kbhit3-----
    #include <termios.h>
    int kbhit3(void) {
       struct termios term, oterm;
       int fd = 0;
       int c = 0;
       tcgetattr(fd, &oterm);
       memcpy(&term, &oterm, sizeof(term));
       term.c_lflag = term.c_lflag & (!ICANON);
       term.c_cc[VMIN] = 0;
       term.c_cc[VTIME] = 1;
       tcsetattr(fd, TCSANOW, &term);
       c = getchar();
       tcsetattr(fd, TCSANOW, &oterm);
       if (c != -1)
       ungetc(c, stdin);
       return ((c != -1) ? 1 : 0);
    }
#endif



/*--------------------------------------------------------------------
  includes
  --------------------------------------------------------------------*/
#include "ipe4structure.h"
#include "ipe4reader.h"


/*--------------------------------------------------------------------
  globals and functions for hardware access
  --------------------------------------------------------------------*/
#include <Pbus/Pbus.h>

#pragma warning TODO remove -lkatrinhw4 in Makefile
//#include "hw4/baseregister.h"
//#include "Pbus/pbusimp.h"
//#include "katrinhw4/subrackkatrin.h"
//#include "katrinhw4/sltkatrin.h"
//#include "katrinhw4/fltkatrin.h"


Pbus *pbus=0;              //for register access with fdhwlib
uint32_t presentFLTMap =0; // store a map of the present FLT cards




    //SLT registers
	static const uint32_t SLTControlReg			= 0xa80000 >> 2;
	static const uint32_t SLTStatusReg			= 0xa80004 >> 2;
	static const uint32_t SLTCommandReg			= 0xa80008 >> 2;
	static const uint32_t SLTInterruptMaskReg	= 0xa8000c >> 2;
	static const uint32_t SLTInterruptRequestReg= 0xa80010 >> 2;
	static const uint32_t SLTVersionReg			= 0xa80020 >> 2;

	static const uint32_t SLTPixbusPErrorReg     = 0xa80024 >> 2;
	static const uint32_t SLTPixbusEnableReg     = 0xa80028 >> 2;
	static const uint32_t SLTBBOpenedReg         = 0xa80034 >> 2;

	
	static const uint32_t SLTSemaphoreReg    = 0xb00000 >> 2;
	
	static const uint32_t CmdFIFOReg         = 0xb00004 >> 2;
	static const uint32_t CmdFIFOStatusReg   = 0xb00008 >> 2;
	static const uint32_t OperaStatusReg0    = 0xb0000c >> 2;
	static const uint32_t OperaStatusReg1    = 0xb00010 >> 2;
	static const uint32_t OperaStatusReg2    = 0xb00014 >> 2;
	
	static const uint32_t FIFO0Addr         = 0xd00000 >> 2;
	
	//TODO: multiple FIFOs are obsolete, remove it -tb-
	static const uint32_t FIFO0ModeReg      = 0xe00000 >> 2;//obsolete 2012-10 
	static const uint32_t FIFO0StatusReg    = 0xe00004 >> 2;//obsolete 2012-10
	static const uint32_t BB0PAEOffsetReg   = 0xe00008 >> 2;//obsolete 2012-10
	static const uint32_t BB0PAFOffsetReg   = 0xe0000c >> 2;//obsolete 2012-10
	static const uint32_t BB0csrReg         = 0xe00010 >> 2;//obsolete 2012-10
	
	#if 0
	static const uint32_t FIFOModeReg       = 0xe00000 >> 2;
	static const uint32_t FIFOStatusReg     = 0xe00004 >> 2;
	static const uint32_t PAEOffsetReg      = 0xe00008 >> 2;
	static const uint32_t PAFOffsetReg      = 0xe0000c >> 2;
	static const uint32_t FIFOcsrReg        = 0xe00010 >> 2;
    #endif

	static const uint32_t SLTTimeLowReg     = 0xb00018 >> 2;
	static const uint32_t SLTTimeHighReg    = 0xb0001c >> 2;


	
inline uint32_t FIFOStatusReg(int numFIFO){
    return FIFO0StatusReg | ((numFIFO & 0xf) <<14);  //PCI adress would be <<16, but we use Pbus adress -tb-
}

inline uint32_t FIFOModeReg(int numFIFO){
    return FIFO0ModeReg | ((numFIFO & 0xf) <<14);  //PCI adress would be <<16, but we use Pbus adress -tb-
}

inline uint32_t FIFOAddr(int numFIFO){
    return FIFO0Addr | ((numFIFO & 0xf) <<14);  //PCI adress would be <<16, but we use Pbus adress -tb-
}

inline uint32_t PAEOffsetReg(int numFIFO){
    return BB0PAEOffsetReg | ((numFIFO & 0xf) <<14);  //PCI adress would be <<16, but we use Pbus adress -tb-
}

inline uint32_t PAFOffsetReg(int numFIFO){
    return BB0PAFOffsetReg | ((numFIFO & 0xf) <<14);  //PCI adress would be <<16, but we use Pbus adress -tb-
}

inline uint32_t BBcsrReg(int numFIFO){
    return BB0csrReg | ((numFIFO & 0xf) <<14);  //PCI adress would be <<16, but we use Pbus adress -tb-
}

    //FLT registers
	static const uint32_t FLTStatusRegBase      = 0x000000 >> 2;
	static const uint32_t FLTControlRegBase     = 0x000004 >> 2;
	static const uint32_t FLTCommandRegBase     = 0x000008 >> 2;
	static const uint32_t FLTVersionRegBase     = 0x00000c >> 2;
	
	static const uint32_t FLTFiberSet_1RegBase  = 0x000024 >> 2;
	static const uint32_t FLTFiberSet_2RegBase  = 0x000028 >> 2;
	static const uint32_t FLTStreamMask_1RegBase  = 0x00002c >> 2;
	static const uint32_t FLTStreamMask_2RegBase  = 0x000030 >> 2;
	static const uint32_t FLTTriggerMask_1RegBase  = 0x000034 >> 2;
	static const uint32_t FLTTriggerMask_2RegBase  = 0x000038 >> 2;

	static const uint32_t FLTAccessTestRegBase     = 0x000040 >> 2;
	
	static const uint32_t FLTTotalTriggerNRegBase  = 0x000084 >> 2;

	static const uint32_t FLTBBStatusRegBase    = 0x00001400 >> 2;

	static const uint32_t FLTRAMDataRegBase     = 0x00003000 >> 2;
	
// 
// NOTE: numFLT from 1...20  !!!!!!!!!!!!
//
// (NOT from 0 ... 19!!!)
//
	//TODO: 0x3f or 0x1f?????????????
inline uint32_t FLTStatusReg(int numFLT){
    return FLTStatusRegBase | ((numFLT & 0x3f) <<17);  //PCI adress would be <<16, but we use Pbus adress -tb-
}

inline uint32_t FLTControlReg(int numFLT){
    return FLTControlRegBase | ((numFLT & 0x3f) <<17);  
}

inline uint32_t FLTCommandReg(int numFLT){
    return FLTCommandRegBase | ((numFLT & 0x3f) <<17);  
}

inline uint32_t FLTVersionReg(int numFLT){
    return FLTVersionRegBase | ((numFLT & 0x3f) <<17);  
}

inline uint32_t FLTFiberSet_1Reg(int numFLT){
    return FLTFiberSet_1RegBase | ((numFLT & 0x3f) <<17);  
}

inline uint32_t FLTFiberSet_2Reg(int numFLT){
    return FLTFiberSet_2RegBase | ((numFLT & 0x3f) <<17);  
}

inline uint32_t FLTStreamMask_1Reg(int numFLT){
    return FLTStreamMask_1RegBase | ((numFLT & 0x3f) <<17);  
}

inline uint32_t FLTStreamMask_2Reg(int numFLT){
    return FLTStreamMask_2RegBase | ((numFLT & 0x3f) <<17);  
}

inline uint32_t FLTTriggerMask_1Reg(int numFLT){
    return FLTTriggerMask_1RegBase | ((numFLT & 0x3f) <<17);  
}

inline uint32_t FLTTriggerMask_2Reg(int numFLT){
    return FLTTriggerMask_2RegBase | ((numFLT & 0x3f) <<17);  
}

inline uint32_t FLTAccessTestReg(int numFLT){
    return FLTAccessTestRegBase | ((numFLT & 0x3f) <<17); 
}

inline uint32_t FLTBBStatusReg(int numFLT, int numChan){
    return FLTBBStatusRegBase | ((numFLT & 0x3f) <<17) | ((numChan & 0x1f) <<12); 
}

inline uint32_t FLTTotalTriggerNReg(int numFLT){
    return FLTTotalTriggerNRegBase | ((numFLT & 0x3f) <<17);  
}


inline uint32_t FLTRAMDataReg(int numFLT, int numChan){
    return FLTRAMDataRegBase | ((numFLT & 0x3f) <<17) | ((numChan & 0x1f) <<12); 
}




int runPreRunChecks()
{
  
  
#ifdef __i386
    printf("__i386 is defined!\n");
#endif
#ifdef __i386__
    printf("__i386__ is defined!\n");
#endif
#ifdef __x86_64
    printf("__x86_64 is defined!\n");
#endif

#ifndef __WORDSIZE
#include <limits.h>
#endif
#ifdef __WORDSIZE
    printf("__WORDSIZE is defined!\n");
#endif
#if ( __WORDSIZE == 64 )
    printf("__WORDSIZE is 64!\n");

#endif

    int retval=0;
    printf("    sizeof(UDPStructIPECrateStatus) is %i\n",sizeof(UDPStructIPECrateStatus));
    printf("    sizeof(UDPStructIPECrateStatus2) is %i\n",sizeof(UDPStructIPECrateStatus2));
    if(  (sizeof(UDPStructIPECrateStatus) == SIZEOF_UDPStructIPECrateStatus)   &&   (sizeof(UDPStructIPECrateStatus) == sizeof(UDPStructIPECrateStatus2)) ){
        printf("    OK!\n");
    }
    else
    {
        printf("    NOT matching! You cannot run the stream loop! (Did you change hardware or operating system?\n");
        retval++;
    }
    
    
    return retval;
}

void InitSLTPbus(void)
{
	//open device driver(s), get device driver handles
	
	int err = 0;
	try {
		if (pbus > 0) pbus->free();
		
		pbus = new Pbus();
		pbus->init();
	} catch (PbusError &e){
		err = 1;
	}
	
	if(err) printf("Creating Pbus failed!\n");
	else printf("Pbus initialized!\n");
	
    //FindHardware();//= pbusInit("FE.ini");       TODO: dont use libpbusaccess ... -tb-
    
    std::string getStr, cmdStr;
    cmdStr = "blockmode";
    pbus->get(cmdStr,&getStr);
    printf("   Pbus:: get %s: result: %s \n",cmdStr.c_str(),getStr.c_str());
 
 
    printf("   (Reset) + Init SLT\n");
    //reset SLT and FIFOs
	//pbus->write(SLTCommandReg,0x2);//reset SLT - is this necessary? -tb-
	//usleep(100);
    //reset FIFOs
	int fifo;
	//for(fifo=0; fifo<20; fifo++){
	//TODO: only one FIFO !
	for(fifo=0; fifo<FIFOREADER::maxNumFIFO; fifo++)
	{
		//if(presentFLTMap & bit[fifo])
		{
		    pbus->write(BBcsrReg(fifo),0x8);
	        printf("  Reset FIFO %i - writing BBcsrReg ... reading: 0x%08x\n",fifo,pbus->read(BBcsrReg(fifo)));
		}
    }
    usleep(20);
	//set mask
	pbus->write(SLTInterruptMaskReg,0xffff);//reset SLT
	printf("  Interrupt  mask 0x%08x  (wrote 0xffff) ... \n",pbus->read(SLTInterruptMaskReg));
	
 
 
     //find FLTs
	int flt;
	uint32_t val;
	presentFLTMap = 0;
	//TODO: fix it in firmware, then use 20 instead of 16
	//TODO: fix it in firmware, then use 20 instead of 16
	//TODO: fix it in firmware, then use 20 instead of 16
	//TODO: fix it in firmware, then use 20 instead of 16
	//TODO: fix it in firmware, then use 20 instead of 16
	for(flt=0; flt<MAX_NUM_FLT_CARDS; flt++){
	//for(flt=0; flt<16; flt++){
	    val = pbus->read(FLTVersionReg(flt+1));
	    printf("FLT#%i (idx %i): version 0x%08x\n",flt+1,flt,val);
	    if(val!=0x1f000000 && val!=0xffffffff){
            presentFLTMap |= bit[flt];
            FLTSETTINGS::FLT[flt].isPresent = 1;
        }
    }
    printf("    present FLT map is 0x%08x\n",presentFLTMap);

    //set Pixbus Register --> is in InitHardwareFIFOs()
	

}

void ReleaseSLTPbus(void)
{
    //release / close device driver(s)
    if (pbus > 0) pbus->free();
    delete pbus;
    pbus = 0;
    presentFLTMap = 0;
}

void write_code_horloge(int code_acqi)
{
    pbus->write(CmdFIFOReg ,  0x00ff);
    pbus->write(CmdFIFOReg ,  0x0115);
    pbus->write(CmdFIFOReg ,  0x0108);
    pbus->write(CmdFIFOReg ,  0x0112);//TODO: reg_retard: use Trame_status_udp -tb-
    pbus->write(CmdFIFOReg ,  0x0103);//TODO: mask_BB: use Trame_status_udp -tb-
    pbus->write(CmdFIFOReg ,  0x0100 | (0x00ff & code_acqi));//TODO: code_acqi: use Trame_status_udp? -tb-
    pbus->write(CmdFIFOReg ,  0x010e);//TODO: code syncro: use Trame_status_udp -tb-
    pbus->write(CmdFIFOReg ,  0x0200);
}

/*--------------------------------------------------------------------
  globals and functions for hardware access
  --------------------------------------------------------------------*/

//#include "ipe4structure.h"
//#include "ipe4reader.h"

FIFOREADER *FIFOREADER::FifoReader = 0;//init  static member
SLTSETTINGS *SLTSETTINGS::SLT = 0;//init  static member

FLTSETTINGS *FLTSETTINGS::FLT = 0;//init  static member
int	FIFOREADER::State = frUNDEF;//init  static member
/*state = frUNDEF       = 1: idle
          frIDLE        = 2: initialized
          frINITIALIZED = 3: streaming (streamLoop running)
          frSTREAMING   = 0: undefined (after start)
*/

int	goToState = frUNDEF;   // <---- to change state: set this to the desired state


#if 0
Structure_trame_status		Trame_status_udp;	// la trame de status en memoire TODO: I use the same name as in cew.c -tb-
#endif
 
 
/*--------------------------------------------------------------------
  globals
  --------------------------------------------------------------------*/
	#if 0 // moved to *.h file
	//networking / UDP includes
	#include <arpa/inet.h>
	#include <netinet/in.h>
	//#include <stdio.h>
	#include <sys/types.h>
	#include <sys/socket.h>
	#include <unistd.h>
	#endif
	
	//TODO: GLOBAL VARIABLES LIST
	//globals for config file options
	#if 0
	int numfifo=0;
	int startSecond;
	#endif

int RECORDING_SEC=0;
int simulation_send_dummy_udp=0;
int run_main_readout_loop=1;
int show_debug_info=0;

	#if 0
	int write2file=0;  // 0 = don't write to file; 1 = write file
	int write2file_len_sec=5;
	int write2file_format=0;
	//const int ascii=0, binary=1;
	FILE * pFile =0;
	
	//open port to listen for / server port
	int  MY_UDP_SERVER_SOCKET;
	int  MY_UDP_SERVER_PORT;
	uint32_t  MY_UDP_SERVER_IP = INADDR_ANY;
	#endif

//'static' client, configured in the config file //TODO: (deprecated -tb- 2012-05)
int  use_static_udp_client = 0;
int		MY_UDP_CLIENT_SOCKET;
struct	sockaddr_in cliaddr;
char MY_UDP_CLIENT_IP[1024];
int  MY_UDP_CLIENT_PORT;


	#if 0
	int send_status_udp_packet = 1;
	int skip_num_status_bits = 0; //skip this number of status bits (we observed offsets between 0 and 2)
	
	//for use of dummy status bits
	int use_dummy_status_bits = 0;
	
	Structure_trame_status MY_STATUS;
	Structure_trame_status *myStatusPtr;
	#endif


//spike finder
int use_spike_finder = 0;
int32_t countSpikes=0;
int32_t secCountSpikes=0;
int32_t countSpikesChan[6]={0,0,0,0,0,0};
int32_t countSpikesVal[6]={0,0,0,0,0,0};//250-400, 400-1000, >1000
/*--------------------------------------------------------------------
  globals for FIFO buffer
  --------------------------------------------------------------------*/
//const uint32_t FIFObuf8len = 1200016 * 8;  //1200000 = max. number of ADC data in 1 sec (BB2) + 4 x word32 (sec strobe pattern)
//const uint32_t FIFObuf16len = FIFObuf8len / 2;
//const uint32_t FIFObuf32len = FIFObuf8len / 4;

	#if 0
	char * FIFObuf8[FIFObuf8len];
	int16_t * FIFObuf16 = (int16_t *)FIFObuf8;
	int32_t * FIFObuf32 = (int32_t *)FIFObuf8;
	uint32_t popIndexFIFObuf32=0;
	uint32_t pushIndexFIFObuf32=0;
	uint32_t FIFObuf32avail=0;
	int64_t FIFObuf32counter=0;
	int64_t FIFObuf32counterlast=0;
	
	//uint32_t FIFOBlockSize = 4 * 1024; //TODO: FIFOBlockSize: later go to 8192 -tb-   moved to *.h
	
	uint32_t globalHeaderWordCounter = 0; //TODO: globalHeaderWordCounter for testing -tb- 
	#endif

// globals for sending commands (from cew.c)
//  par defaut, pour l'envoie de la premiere commande horloge : une bbv1 autonome
//  modifie par les valeurs du fichier config		
int	X=21;
int	Retard=16;
int	Masque_BB=2;
int	Nb_mots_lecture=3;					//is 3 for BB2, 2 for BBv21 mode!!!!!!!!!! -tb-    //marche pour un seul bolo	// nombre de mots total relut dans les data de la fifo:   -tb- d.h. Anzahl 32-bit-Worte(FIFO-Worte) pro (Time-)Sample (Sample=alle ADC-Kanaele
//int	Nb_mots_lecture=2;					//marche pour un seul bolo	// nombre de mots total relut dans les data de la fifo:
//int	Code_acqui=code_acqui_EDW_BB1;
int	Code_acqui=code_acqui_EDW_BB2;   // I prefer BB2 -tb-
int	Code_synchro=code_synchro_100000;	//+code_synchro_esclave_synchro+code_synchro_esclave_temps;
int	Nb_synchro=100000;					//  nombre d'echantillons entre 2 synchros

/*--------------------------------------------------------------------
  UDP communication
  --------------------------------------------------------------------*/

/*--------------------------------------------------------------------
  UDP communication - 1.) client communication
  --------------------------------------------------------------------*/
	#if 0  //moved to class FIFOREADER variables
	// 'dynamic' clients ----------
	int		NB_CLIENT_UDP=0;							//  serveur UDP
	//_nb_max_clients_UDP defined in structure.h, default: 20
	int		UDP_CLIENT_SOCKET[_nb_max_clients_UDP];
	struct	sockaddr_in clientaddr_list[_nb_max_clients_UDP];
	int		numPacketsClient[_nb_max_clients_UDP] = {0,0,0,0,0,0,0,0,0,0,    0,0,0,0,0,0,0,0,0,0};
	int		status_client[_nb_max_clients_UDP]    = {0,0,0,0,0,0,0,0,0,0,    0,0,0,0,0,0,0,0,0,0};
	#endif











/*--------------------------------------------------------------------
 *    function:     addUDPClient
 *    purpose:      add new client to the client list or update number of requested packets
 *    author:       taken from void	nouveau_client_udp(in_addr_t adresse_ip,int mon_port,int nb_paquets_demande) from cew.c, modified by Till Bergmann, 2011
 *--------------------------------------------------------------------*/ //-tb-








////////////////////////////////////////////////
//begin of K command socket functions
//
////////////////////////////////////////////////
/*--------------------------------------------------------------------
  Global UDP communication - for K commands 
  1. Receive K commands (server)
  2. Answer read requests (client)
  --------------------------------------------------------------------*/

/*--------------------------------------------------------------------
  K command UDP communication -  client communication
  --------------------------------------------------------------------*/

/*--------------------------------------------------------------------
 *    function:     addGlobalUDPClient
 *    purpose:      add new client to the client list or update number of requested packets
 *    author:       taken from void	nouveau_client_udp(in_addr_t adresse_ip,int mon_port,int nb_paquets_demande) from cew.c, modified by Till Bergmann, 2011
 *--------------------------------------------------------------------*/ //-tb-


int initGlobalUDPClientSocket(void)
{
    int retval=0;
    
    if ((GLOBAL_UDP_CLIENT_SOCKET=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP))==-1){
        fprintf(stderr, "initGlobalUDPClientSocket: socket(...) failed\n");
        //diep("socket");
	    return 1;
    }
  
  #if 1 //do it in sendToGlobalClient3 again
    GLOBAL_sockaddrin_to_len=sizeof(GLOBAL_sockaddrin_to);
  memset((char *) &GLOBAL_sockaddrin_to, 0, sizeof(GLOBAL_sockaddrin_to));
  GLOBAL_sockaddrin_to.sin_family = AF_INET;
  GLOBAL_sockaddrin_to.sin_port = htons(GLOBAL_UDP_CLIENT_PORT); //take global variable MY_UDP_CLIENT_PORT //TODO: was PORT, remove PORT
  if (inet_aton(GLOBAL_UDP_CLIENT_IP_ADDR, &GLOBAL_sockaddrin_to.sin_addr)==0) {
    fprintf(stderr, "inet_aton() failed\n");
	return 2;
    //exit(1);
  }
    fprintf(stderr, "    initGlobalUDPClientSocket: UDP Client: IP: %s, port: %i\n",GLOBAL_UDP_CLIENT_IP_ADDR,GLOBAL_UDP_CLIENT_PORT);
  #endif
  
  
    return retval;
}


int sendtoGlobalClient(const void *buffer, size_t length)
{
	int retval=0;
	retval = sendto(GLOBAL_UDP_CLIENT_SOCKET, buffer, length, 0 /*flags*/, (struct sockaddr *)&GLOBAL_sockaddrin_to, GLOBAL_sockaddrin_to_len);
    return retval;
}

int sendtoGlobalClient2(const void *buffer, size_t length, const struct sockaddr *dest_addr, socklen_t dest_len)
{
	int retval=0;
	retval = sendto(GLOBAL_UDP_CLIENT_SOCKET, buffer, length, 0 /*flags*/, dest_addr, dest_len);
    return retval;
}

int sendtoGlobalClient3(const void *buffer, size_t length, char* receiverIPAddr, uint32_t port)
{

	int retval=0;
	
	if(port==0) port = GLOBAL_UDP_CLIENT_PORT;//use default port
	
  memset((char *) &GLOBAL_sockaddrin_to, 0, sizeof(GLOBAL_sockaddrin_to));
  GLOBAL_sockaddrin_to.sin_family = AF_INET;
  GLOBAL_sockaddrin_to.sin_port = htons(port);
  if (inet_aton(receiverIPAddr, &GLOBAL_sockaddrin_to.sin_addr)==0) {
    fprintf(stderr, "ERROR: sendtoGlobalClient3: inet_aton() failed\n");
	return 2;
    //exit(1);
  }
    fprintf(stderr, "    sendtoGlobalClient3: UDP Client: IP: %s, port: %i\n",receiverIPAddr,port);
    ((char*)buffer)[length]=0;    fprintf(stderr, "    sendtoGlobalClient3: %s\n",buffer); //DEBUG
	
	retval = sendto(GLOBAL_UDP_CLIENT_SOCKET, buffer, length, 0 /*flags*/, (struct sockaddr *)&GLOBAL_sockaddrin_to, GLOBAL_sockaddrin_to_len);
    return retval;
}



void endGlobalUDPClientSocket(void)
{
      if(GLOBAL_UDP_CLIENT_SOCKET>-1) close(GLOBAL_UDP_CLIENT_SOCKET);
      GLOBAL_UDP_CLIENT_SOCKET = -1;
}


/*--------------------------------------------------------------------
  K command UDP communication -   server communication
  --------------------------------------------------------------------*/

#define MY_UDP_LISTEN_MAX_PACKET_SIZE   1500
unsigned char InBuffer[MY_UDP_LISTEN_MAX_PACKET_SIZE];	// took buffer size from CEW_controle,but char instead of unsigned char -tb-
	

int initGlobalUDPServerSocket(void)
{
    int status, retval=0;

	GLOBAL_UDP_SERVER_SOCKET = socket ( AF_INET, SOCK_DGRAM, IPPROTO_UDP );
	if (GLOBAL_UDP_SERVER_SOCKET==-1){
        fprintf(stderr, "initUDPServerSocket: socket(...) failed\n");
        //diep("socket");
	    return 1;
    }
	fprintf(stderr, "initGlobalUDPServerSocket: socket(...) created socket %i\n",GLOBAL_UDP_SERVER_SOCKET);


	GLOBAL_servaddr.sin_family = AF_INET; 
	GLOBAL_servaddr.sin_port = htons (GLOBAL_UDP_SERVER_PORT);
	//GLOBAL_servaddr.sin_addr.s_addr = 0L;
	// maybe check whether GLOBAL_UDP_SERVER_IP_ADDR was set correctly ? -tb-
	retval=inet_aton(GLOBAL_UDP_SERVER_IP_ADDR,&GLOBAL_servaddr.sin_addr);
	GLOBAL_UDP_SERVER_IP=GLOBAL_servaddr.sin_addr.s_addr;//this is already in network byte order!!!
	printf("  inet_aton: retval: %i,IP_ADDR: %s, IP %i (0x%x)\n",retval,GLOBAL_UDP_SERVER_IP_ADDR,GLOBAL_UDP_SERVER_IP,GLOBAL_UDP_SERVER_IP);
	//GLOBAL_servaddr.sin_addr.s_addr =  htonl(GLOBAL_UDP_SERVER_IP);// INADDR_ANY = 0x00000000 = 0  ;   192.168.1.9  = 0xc0a80109  ;   192.168.1.34   = 0xc0a80122
	status = bind(GLOBAL_UDP_SERVER_SOCKET,(struct sockaddr *) &GLOBAL_servaddr,sizeof(GLOBAL_servaddr));
	if (status==-1) {
		printf("  ERROR starting UDP server .. -tb- continue, ignore error -tb-\n");
		//return 2 ; //-tb- continue, ignore error -tb-
	}
	printf("  serveur udp ouvert avec servaddr.sin_addr.s_addr=%s \n",inet_ntoa(GLOBAL_servaddr.sin_addr));
	listen(GLOBAL_UDP_SERVER_SOCKET,5);
 printf("  UDP SERVER is listening for K commands on port %u\n",GLOBAL_UDP_SERVER_PORT);
   if(GLOBAL_UDP_SERVER_PORT<1024){
       printf("  ----WARNING----------------------------------------------------------------------------\n");
       printf("  ****WARNING****************************************************************************\n");
       printf("  ** NOTE,WARNING: initGlobalUDPServerSocket: UDP COMMAND SERVER is listening on port %u,\n  ** using ports below 1024 requires to run as 'root'!\n",GLOBAL_UDP_SERVER_PORT);
       printf("  ****WARNING****************************************************************************\n");
       printf("  ----WARNING----------------------------------------------------------------------------\n");
       if(status==-1) sleep(3);//give the user time to see the message -tb-
   }

retval=0;

    return retval;//retval=0: OK, else error
}


// see http://www.pug.org/mediawiki/index.php/Einf%C3%BChrung_in_die_Netzwerkprogrammierung:udpserver.c
//and http://www.pug.org/mediawiki/index.php/Einf%C3%BChrung_in_die_Netzwerkprogrammierung
// for extracting the IP address of the sender
int recvfromGlobalServer(char *readBuffer, int maxSizeOfReadbuffer)
{
	int retval=-1;
    sockaddr_fromLength = sizeof(sockaddr_from);
    //while( (retval = recvfrom(MY_UDP_SERVER_SOCKET, (char*)InBuffer,sizeof(InBuffer) , MSG_DONTWAIT,(struct sockaddr *) &servaddr, &AddrLength)) >0 ){
    retval = recvfrom(GLOBAL_UDP_SERVER_SOCKET, readBuffer, maxSizeOfReadbuffer, MSG_DONTWAIT,(struct sockaddr *) &sockaddr_from, &sockaddr_fromLength);
	    //printf("recvfromGlobalServer retval:  %i, maxSize %i\n",retval,maxSizeOfReadbuffer);
	    if(retval>=0){
	        //printf("recvfromGlobalServer retval:  %i (bytes), maxSize %i, from IP %s\n",retval,maxSizeOfReadbuffer,inet_ntoa(sockaddr_from.sin_addr));
			printf("Got UDP data from %s\n", inet_ntoa(sockaddr_from.sin_addr));

	    }
	//handle K commands
	if(retval>0){
	    switch(readBuffer[0]){
	    case 'K':
	        readBuffer[retval]='\0';//make null terminated string for printf
	        printf("Received K command: >%s<\n",readBuffer);
	        handleKCommand(readBuffer, retval, &sockaddr_from);
	        break;
	    default:
	        readBuffer[retval]='\0';//make null terminated string for printf
	        printf("Received unknown command: >%s<\n",readBuffer);
	        break;
	    }
	}
    return retval;
}



void endGlobalUDPServerSocket(void)
{
    if(GLOBAL_UDP_SERVER_SOCKET>-1) close(GLOBAL_UDP_SERVER_SOCKET);
    GLOBAL_UDP_SERVER_SOCKET = -1;
}

//end of K command socket functions







int initKCommandSockets()
{
    //begin-----INIT Crate K Command UDP COMMUNICATION---------------------------------------
		//init UDP server socket
		if(initGlobalUDPServerSocket() != 0){
			printf("ERROR: initGlobalUDPServerSocket()  failed!\n");
			exit(1);
		}else printf("OK: initGlobalUDPServerSocket() \n");
		
		//init UDP client socket (for read requests)
		if(initGlobalUDPClientSocket() != 0){
			printf("ERROR: initGlobalUDPClientSocket()  failed!\n");
			exit(1);
		}else printf("OK: initGlobalUDPClientSocket() \n");
    //end-------INIT Crate K Command UDP COMMUNICATION---------------------------------------
    
    return 0;
}


void endKCommandSockets()
{
    endGlobalUDPServerSocket();
    endGlobalUDPClientSocket();
}












/*--------------------------------------------------------------------
 *    function:     FIFOREADER::addUDPClient
 *    purpose:      add new client to the client list or update number of requested packets
 *    author:       taken from void	nouveau_client_udp(in_addr_t adresse_ip,int mon_port,int nb_paquets_demande) from cew.c, modified by Till Bergmann, 2011
 *--------------------------------------------------------------------*/ //-tb-
void	FIFOREADER::addUDPClient(int port,int numRequestedPackets)
{
    in_addr_t ip = servaddr.sin_addr.s_addr; //class variable! was filled in FIFOREADER::recvfromServer(unsigned char *readBuffer, int maxSizeOfReadbuffer)
    printf("DEBUG: addUDPClient(in_addr_t ip=0x%x ,int port  (%i),int numRequestedPackets (%i) ) ...\n", ip, port, numRequestedPackets); //TODO: DEBUG -tb-
    // search IP (AND port?) in the table
    int i;
	for(i=0; i<NB_CLIENT_UDP; i++){
	    	if( ( ip==clientaddr_list[i].sin_addr.s_addr ) && (clientaddr_list[i].sin_port ==  htons (port)) )	break;

	}
	
    if (i>=_nb_max_clients_UDP){ printf("WARNING: cannot connect; too many clients already connected ( > %d ) ",_nb_max_clients_UDP); return; }

    //store the requested number
    numPacketsClient[i] = numRequestedPackets;		// ((si nb_paquets_demande==1 je n'envoe que la trame status)) //TODO: we will handle it like other values! -tb-

    if(i==NB_CLIENT_UDP){	// new client -> create socket, store IP and port
	    UDP_CLIENT_SOCKET[i] = socket ( AF_INET, SOCK_DGRAM, IPPROTO_UDP );
	    if (UDP_CLIENT_SOCKET[i]==-1)	{printf("Erreur de creation de la socket client....\n"); return;	}

	    clientaddr_list[i].sin_family = AF_INET; 
	    clientaddr_list[i].sin_port = htons (port);
 	    clientaddr_list[i].sin_addr.s_addr= ip;
        //	printf("Nouveau client indice %d  : adresse = ",i);print_ip(cliaddr[i].sin_addr.s_addr);printf("  mon_port = %d \n",mon_port);
        //	printf("Nouveau client indice %d  : adresse = %s  port %d\n",i,inet_ntoa(clientaddr_list[i].sin_addr),port);
	    printf("New UDP client connected:index %d , adresse = %s,  port %d\n",i,inet_ntoa(clientaddr_list[i].sin_addr),port);
	 
	    //TODO: --------------------------------------------- -tb-
	    //TODO: use bind to send from specified IP address!!! -tb-
	    //TODO: use bind to send from specified IP address!!! -tb-
	    //TODO: use bind to send from specified IP address!!! -tb-
	    //TODO see FIFOREADER::initUDPServerSocket(void)
	    //TODO: use MY_UDP_SERVER_IP/MY_UDP_SERVER_IP_ADDR
	    
	    
	    servaddr.sin_family = AF_INET; 
	    servaddr.sin_port = 0;//htons (MY_UDP_SERVER_PORT); //SET TO 0 for binding a client (sender) port!!!
	    //servaddr.sin_addr.s_addr = 0L;
	    int retval2 = inet_aton(MY_UDP_SERVER_IP_ADDR, &servaddr.sin_addr);  //bind to same IP
        if(retval2 == 0) printf("ERROR %i starting UDP server ... in addUDPClient .. in  inet_aton(MY_UDP_SERVER_IP_ADDR, &servaddr.sin_addr);-tb-\n",retval2);
printf("    inet_aton(MY_UDP_SERVER_IP_ADDR %s, &servaddr.sin_addr ... 0x%08x );-tb-\n",MY_UDP_SERVER_IP_ADDR, servaddr.sin_addr.s_addr);
	//servaddr.sin_addr.s_addr =  htonl(MY_UDP_SERVER_IP);// INADDR_ANY = 0x00000000 = 0  ;   192.168.1.9  = 0xc0a80109  ;   192.168.1.34   = 0xc0a80122

#if 0
   //THIS WAS NOT NECESSARY; PROBLEM WAS: PORT WAS NOT 0 !!!
/* Enable address reuse */
int on = 1;
int ret = setsockopt( UDP_CLIENT_SOCKET[i], SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on) );
#endif


	int status = bind(UDP_CLIENT_SOCKET[i],(struct sockaddr *) &servaddr,sizeof(servaddr));
	if (status==-1) {
		printf("    ERROR ... in addUDPClient ... starting UDP server .. bind returned with -1 -tb- continue, ignore error -tb-\n");
		printf("    ERROR ... in addUDPClient ... probably port busy or port below 1024? -tb-\n");
        printf( "   bind failed: %s\n", strerror(errno) );
		//return 2 ; //-tb- continue, ignore error -tb-
	}

	    //TODO: use bind to send from specified IP address!!! -tb-
	    //TODO: use bind to send from specified IP address!!! -tb-
	    //TODO: --------------------------------------------- -tb-
	    
	    NB_CLIENT_UDP++;
	}
}

/*--------------------------------------------------------------------
 *    function:     FIFOREADER::endUDPClientSockets
 *    purpose:      clear all sockets (reset)
 *    author:       Till Bergmann, 2012
 *--------------------------------------------------------------------*/ //-tb-
void	FIFOREADER::endUDPClientSockets()
{
    int i;
	for(i=0; i<NB_CLIENT_UDP; i++){
	    close(UDP_CLIENT_SOCKET[i]);
	    UDP_CLIENT_SOCKET[i]=-1;
	}
	NB_CLIENT_UDP=0;
}



void FIFOREADER::endAllUDPClientSockets()
{
    int iFifo;
	for(iFifo=0; iFifo<FIFOREADER::maxNumFIFO; iFifo++) if(FIFOREADER::FifoReader[iFifo].readfifo){
		FIFOREADER &fr=FIFOREADER::FifoReader[iFifo];
		fr.endUDPClientSockets();
	}
}




	#if 0
	//static client ----------
	  struct sockaddr_in si_other;
	  int si_other_len;//=sizeof(si_other);
	#endif


//TODO: deprecated (everything with MY_UDP_CLIENT_SOCKET, MY_UDP_CLIENT_IP, MY_UDP_CLIENT_PORT, use_static_udp_client, udp_client_ip, udp_client_port) -tb-
//TOD: instead use UDP_CLIENT_SOCKET[i], ... -tb-
int FIFOREADER::initUDPClientSocket(void)
{
    int retval=0;
    si_other_len=sizeof(si_other);
    if ((MY_UDP_CLIENT_SOCKET=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP))==-1){
        fprintf(stderr, "socket(...) failed\n");
        //diep("socket");
	    return 1;
    }

  memset((char *) &si_other, 0, sizeof(si_other));
  si_other.sin_family = AF_INET;
  si_other.sin_port = htons(MY_UDP_CLIENT_PORT); //take global variable MY_UDP_CLIENT_PORT //TODO: was PORT, remove PORT
  if (inet_aton(MY_UDP_CLIENT_IP, &si_other.sin_addr)==0) {
    fprintf(stderr, "inet_aton() failed\n");
	return 2;
    //exit(1);
  }
    fprintf(stderr, "UDP Client: IP: %s, port: %i\n",MY_UDP_CLIENT_IP,MY_UDP_CLIENT_PORT);
    return retval;
}


//TODO: deprecated s.o.
int FIFOREADER::sendtoClient(const void *buffer, size_t length)
{
	int retval=0;
	retval = sendto(MY_UDP_CLIENT_SOCKET, buffer, length, 0 /*flags*/, (struct sockaddr *)&si_other, si_other_len);
    return retval;
}


	#if 0
	/*
	sendtoClient2: replaces
		 sendto(MY_UDP_CLIENT_SOCKET, buf_status284, buf_status284_len, 0, (struct sockaddr *)&si_other, slen)
			by
		sendtoClient( buf_status284, buf_status284_len, (struct sockaddr *)&si_other, slen)
	*/
	int sendtoClient2(const void *buffer, size_t length, const struct sockaddr *dest_addr, socklen_t dest_len)
	{
		int retval=0;
		retval = sendto(MY_UDP_CLIENT_SOCKET, buffer, length, 0 /*flags*/, dest_addr, dest_len);
		return retval;
	}
	#endif


//TODO: deprecated s.o.
void FIFOREADER::endUDPClientSocket(void)
{
      close(MY_UDP_CLIENT_SOCKET);
}



int FIFOREADER::sendtoUDPClients(int flag, const void *buffer, size_t length)
{
    /* taken from:  #define	_SEND_UDP_clients(seuil,trame,size)\
	for (i=0;i<NB_CLIENT_UDP;i++)  {if (status_client[i]>seuil){\
	sendto(MY_UDP_CLIENT_SOCKET[i], (char*)(trame),size, 0,(struct sockaddr *) &(cliaddr[i]), sizeof(cliaddr[i]));}}
    */
	
	int retval=0, err=0;
	int i;
	
	for (i=0;i<NB_CLIENT_UDP;i++){
	    if (status_client[i]>flag){
	        //sendto(MY_UDP_CLIENT_SOCKET[i], (char*)(trame),size, 0,(struct sockaddr *) &(cliaddr[i]), sizeof(cliaddr[i]));
		    retval = sendto(UDP_CLIENT_SOCKET[i], buffer, length, 0 /*flags*/, (struct sockaddr *)&clientaddr_list[i], sizeof(clientaddr_list[i]));
			if(retval==-1){
			    printf("ERROR: during sending UDP packet for client index %i\n",i);
				err=-1;
			}
	    }
	}

    return err;
}


/*--------------------------------------------------------------------
  UDP communication - 2.) server communication
  --------------------------------------------------------------------*/
// to class FIFOREADER : struct	sockaddr_in servaddr;

    #if 0
    #define MY_UDP_LISTEN_MAX_PACKET_SIZE   1500
    unsigned char InBuffer[MY_UDP_LISTEN_MAX_PACKET_SIZE];	// took buffer size from CEW_controle,but char instead of unsigned char -tb-
    #endif

int FIFOREADER::initUDPServerSocket(void)
{
    int status, retval=0;

	MY_UDP_SERVER_SOCKET = socket ( AF_INET, SOCK_DGRAM, IPPROTO_UDP );
	if (MY_UDP_SERVER_SOCKET==-1){
        fprintf(stderr, "FIFOREADER::initUDPServerSocket: socket(...) failed\n");
        //diep("socket");
	    return 1;
    }
	fprintf(stderr, "FIFOREADER::initUDPServerSocket: socket(...) created socket %i\n",MY_UDP_SERVER_SOCKET);


	servaddr.sin_family = AF_INET; 
	servaddr.sin_port = htons (MY_UDP_SERVER_PORT); 
	//servaddr.sin_addr.s_addr = 0L;
	int retval2 = inet_aton(MY_UDP_SERVER_IP_ADDR, &servaddr.sin_addr);
MY_UDP_SERVER_IP=servaddr.sin_addr.s_addr;
   if(retval2 == 0) printf("ERROR %i starting UDP server .. in  inet_aton(MY_UDP_SERVER_IP_ADDR, &servaddr.sin_addr);-tb-\n",retval2);
printf("    inet_aton(MY_UDP_SERVER_IP_ADDR %s, &servaddr.sin_addr ... 0x%08x );-tb-\n",MY_UDP_SERVER_IP_ADDR, servaddr.sin_addr.s_addr);
	//servaddr.sin_addr.s_addr =  htonl(MY_UDP_SERVER_IP);// INADDR_ANY = 0x00000000 = 0  ;   192.168.1.9  = 0xc0a80109  ;   192.168.1.34   = 0xc0a80122
	status = bind(MY_UDP_SERVER_SOCKET,(struct sockaddr *) &servaddr,sizeof(servaddr));
	if (status==-1) {
		printf("    ERROR starting UDP server .. bind returned with -1 -tb- continue, ignore error -tb-\n");
		printf("    ERROR probably port busy or port below 1024? -tb-\n");
		//return 2 ; //-tb- continue, ignore error -tb-
	}
	printf("   bind OK; serveur udp ouvert avec servaddr.sin_addr.s_addr=%s \n",inet_ntoa(servaddr.sin_addr));
	listen(MY_UDP_SERVER_SOCKET,5);
 printf("UDP SERVER is listening for commands (from e.g. CEW_controle) on port %u\n",MY_UDP_SERVER_PORT);
   if(MY_UDP_SERVER_PORT<1024){
       printf("  ----WARNING----------------------------------------------------------------------------\n");
       printf("  ****WARNING****************************************************************************\n");
       printf("  ** NOTE,WARNING: initUDPServerSocket: UDP SERVER is listening on port %u,\n  ** using ports below 1024 requires to run as 'root'!\n",MY_UDP_SERVER_PORT);
       printf("  ****WARNING****************************************************************************\n");
       printf("  ----WARNING----------------------------------------------------------------------------\n");
       if(status==-1) sleep(3);//give the user time to see the message -tb-
   }


    return retval;
}


void FIFOREADER::initAllUDPServerSockets(void)
{
    int iFifo;
	for(iFifo=0; iFifo<FIFOREADER::maxNumFIFO; iFifo++) if(FIFOREADER::FifoReader[iFifo].readfifo){
		FIFOREADER &fr=FIFOREADER::FifoReader[iFifo];
		//init UDP server socket
		if(fr.initUDPServerSocket() != 0){
			printf("ERROR: initUDPServerSocket() for FIFO %i failed!\n", iFifo);
			exit(1);
		}else{
		    printf("OK: initUDPServerSocket() for FIFO %i\n", iFifo);
		}
	}
}

int FIFOREADER::recvfromServer(unsigned char *readBuffer, int maxSizeOfReadbuffer)
{
	int retval=-1;
    /*socklen_t*/ AddrLength = sizeof(servaddr);
    //while( (retval = recvfrom(MY_UDP_SERVER_SOCKET, (char*)InBuffer,sizeof(InBuffer) , MSG_DONTWAIT,(struct sockaddr *) &servaddr, &AddrLength)) >0 ){
    retval = recvfrom(MY_UDP_SERVER_SOCKET, readBuffer, maxSizeOfReadbuffer, MSG_DONTWAIT,(struct sockaddr *) &servaddr, &AddrLength);
	    //printf("recvfromServer retval:  %i, maxSize %i\n",retval,maxSizeOfReadbuffer);
	    if(retval!=-1)printf("recvfromServer retval:  %i, maxSize %i\n",retval,maxSizeOfReadbuffer);
    return retval;
}


void FIFOREADER::endUDPServerSocket(void)
{
      close(MY_UDP_SERVER_SOCKET);
}



void FIFOREADER::endAllUDPServerSockets(void)
{
    int iFifo;
	for(iFifo=0; iFifo<FIFOREADER::maxNumFIFO; iFifo++) if(FIFOREADER::FifoReader[iFifo].readfifo){
		FIFOREADER &fr=FIFOREADER::FifoReader[iFifo];
		//close UDP server socket
		fr.endUDPServerSocket();
	}
}







/*--------------------------------------------------------------------
 *    function:     requestHWSemaphore, requestHWSemaphoreWaitUsec, releaseHWSemaphore
 *    purpose:      request/release HW semaphore on SLT to avoid conflicts 
 *                  on writing to command FIFO from 2 or more concurrent processes
 *    author:       Till Bergmann, 2011
 *
 *--------------------------------------------------------------------*/ //-tb-
int requestHWSemaphore(void)
{
    uint32_t sltSemaphore;
    sltSemaphore = pbus->read(SLTSemaphoreReg);
    return sltSemaphore;
 }

//request semaphore, if no succes, wait 1 usec and try again; retry max. usec times
uint32_t requestHWSemaphoreWaitUsec(int usec)
{
    uint32_t sltSemaphore=0;
	int i;
	for(i=0; i<usec; i++){
        sltSemaphore = pbus->read(SLTSemaphoreReg);// or ... = requestHWSemaphore()
		if(sltSemaphore) return sltSemaphore;
		usleep(1);
	}
    
    return sltSemaphore;
}


void releaseHWSemaphore(void)
{
	pbus->write(SLTSemaphoreReg ,  0x00000001);
}

void releaseHWSemaphoreWith(uint32_t bitmap)
{
	pbus->write(SLTSemaphoreReg ,  bitmap);
}

/*--------------------------------------------------------------------
 *    function:     sendCommandFifo
 *    purpose:      write command to command FIFO
 *    author:       taken from envoie_commande from cew.c, modified by Till Bergmann, 2011
 *
 *--------------------------------------------------------------------*/ //-tb-
//write_word to FPGA: Inbuf: will be sent to FPGA, status=number of bytes to be sent -tb-
//this is the counterpart of void	envoie_commande(unsigned char * Inbuf,int status) in cew.c
void sendCommandFifo(unsigned char * buffer, int len)
{

    uint32_t cmdFifoStatus;
    unsigned char Code_Commande;
    uint32_t b;
    int i;
	
	//wait until command FIFO is empty
	const int MAXWAIT=25;
	for(i=0; i< MAXWAIT; i++){
	    cmdFifoStatus = pbus->read(CmdFIFOStatusReg);
		if (cmdFifoStatus & 0x8000) {
			break; //cmd FIFO empty, leave loop
		}
		usleep(10);
	}
	if(i==MAXWAIT){
	    printf("WARNING: cmd FIFO still not empty, continue to send command anyway! This may be caused by a error!\n");
	}
	
    //this errourously was sent out for each FIFO command, removed 2011-12-23
	//pbus->write(CmdFIFOReg ,  0x00f0);
	
	//try to request the HW semaphore
    uint32_t sltSemaphore=0;
    sltSemaphore = requestHWSemaphoreWaitUsec(100);// argument is 'usec': "wait max usec time" (e.g. usec = 100 means wait max. 100 usec = 0.1 msec)
	if(!sltSemaphore){
	    printf("ERROR: HW semaphore request timeout in void sendCommandFifo()! Could not send command! ERROR!\n");//TODO: use debug level setting -tb-
		return;
	}
	
	//now write command to cmd FIFO
    Code_Commande = buffer[1];
 	//  d'abord un mot de 8 bit precede de 0 en bit 9 pour indiquer le 1er mot
	//write_word(driver_fpga,REG_CMD, (unsigned long) Code_Commande);
	pbus->write(CmdFIFOReg ,  Code_Commande);  //this is either 255/0xff or 240/0xf0 (commande 'W')

	printf("cmd %u (%d octets) ",Code_Commande,len-2);//TODO: use debug level setting -tb-
	//  les mots suivants par mots de 8 bit
	for(i=2;i<len;i++){
		b=buffer[i];
        // En fait, c'est le msb d'abors
		printf("%lX ",b);
		b=b+0x0100;
		//write_word(driver_fpga,REG_CMD, b);
		pbus->write(CmdFIFOReg ,  b);
	}
	b=0x200;
	pbus->write(CmdFIFOReg ,  b);
	printf("\n");

    //release semaphore
	//if(sltSemaphore){	    releaseHWSemaphore();	}
	releaseHWSemaphoreWith(sltSemaphore);
}



/*--------------------------------------------------------------------
 *    function:     envoie_commande_standard_BBv2
 *    purpose:      restart bolo box (BB)
 *    author:       from cew.c, modified by Till Bergmann, 2011
 *
 *--------------------------------------------------------------------*/ //-tb-
void envoie_commande_standard_BBv2(void)
{
	//int Table_nb_synchro[8]=_valeur_synchro;
	unsigned char buf[10];
	buf[0]='h';
	buf[1]=255;
	buf[2]=30;		//  valeur de X
	buf[3]=0;		//  poid fort de X 
	buf[4]=0;		// retard
	buf[5]=1;		// masque BB
	buf[6]=code_acqui_EDW_BB2;		// code acqui
	buf[7]=code_synchro_100000;
	//envoie_commande(buf,8);
	sendCommandFifo(buf,8);
}

/*--------------------------------------------------------------------
 *    function:     lecture_data_FIFO_microbbv2  //TODO: what is this function for???? -tb-
 *    purpose:      read back a copy of the micro code????????
 *    author:       from cew.c, modified by Till Bergmann, 2011
 *--------------------------------------------------------------------*/ //-tb-
int  lecture_data_FIFO_microbbv2(void)
{
int i,j;
int status,nmot_lut;
int mot=-1;	// pas de mot = -1

#if 0

for(j=0;j<1000;j++)	// je lit au maxi 1000 fois la fifo pour aller moins vite
	{
	i=waitDataFifoRead(driver_fpga , (unsigned long*)pt_lec_fifo);
	status = (i>>24) & 0x1f;
	nmot_lut=i&0x3ffff;
	pt_lec_fifo+=nmot_lut;

	//if (nmot_lut==0) printf(" stat=%d,%d,%d,%d,%d,%d / timeout=%d\n",stat_f,stat_af,stat_hf,stat_nae,stat_ae,stat_e,timeout_fifo);

	while ( (pt_lec_fifo-pt_data) >  100)
			{
			static int vvv=0;
			for(i=0;i<100;i++)	
					{
					if ( ( pt_data[i] & 0xfff0000)  == 0xf000000) 
						{
						}
					else	
						if ( ( vvv & 0xfff0000)  == 0xf000000)
								{
								mot = (int)pt_data[i] & 0xfff;
								printf("// rs232 -> %d ",mot);
								}
					vvv = pt_data[i];
					}
				
			pt_data+= 100;
			}

	//  pt_data est le pointeur indiquant la fin des donnees transmise, donc le point d'ou je dois partir pour emettre mes trames
	//  par contre, la prochaine lecture fifo se fera au point   pt_lec_fifo
	//  il faut donc conserver les donnes entre pt_data et pt_lec_fifo  que je translate pour les reecrire au debut du buffer
	if ( (pt_data - Data_brute) > _decalage_maxi_data_brute )  // _decalage_maxi_data_brute is   131072  in cew.h  -tb-
		{
	//	printf("je recale le buffer de %d points vers la gauche \n",pt_data-Data_brute);
		for(i=0;i<(pt_lec_fifo-pt_data);i++)	Data_brute[i]=pt_data[i];
		pt_lec_fifo -= (pt_data-Data_brute);
		pt_data = Data_brute;
		}
	}
	
	
#endif
	
	return 3; //TODO: fake return value to continue in programme_bbv2() -tb-
return mot;		// le dernier s'il y en a plusieurs
}


/*--------------------------------------------------------------------
 *    function:     programme_bbv2
 *    purpose:      reload BB FPGA configuration
 *    author:       from cew.c, modified by Till Bergmann, 2011
 *
 *--------------------------------------------------------------------*/ //-tb-
//from constant_fpga.h and cew.c -> remove all -tb-
#define REG_CMD (0x14) 
int		driver_fpga=0;

//TODO: remove write_word ... later ... -tb-
void write_word(int fd, uint32_t offset, uint32_t dataout)
{
#if 0
	fprintf(stdout,"CALLED: void write_word(int fd, unsigned long offset, unsigned long dataout)"
	" with fd=%i, offset=%i,  dataout=%i (0x%x)\n", fd, offset, dataout, dataout);
#endif		
		
	if(REG_CMD==offset){
	    //printf("Write to command FIFO: %i\n",dataout);
	    pbus->write(CmdFIFOReg ,  dataout);
	}
}


int32_t  fsize(FILE* fd)
{
   int32_t size;
   fseek(fd, 0, SEEK_END);       /* aller en fin */
   size = ftell(fd);             /* lire la taille */
   return size;
}


//  programme bbv2 retourne 0 si tout est bon
// sinon retourne un code d'erreur
#if 1


/*
#define _attente_cmd_vide	{int timeout=100; do read_word(driver_fpga,REG_CMD_STATUS,&b);	while ( (!(b&0x8000)) && (timeout--) ) ;\
							if(timeout<1) printf("erreur timeout attente commande vide \n");}
*/

#define _attente_cmd_vide	{int timeout=100; do b=pbus->read(CmdFIFOStatusReg);	while ( (!(b&0x8000)) && (timeout--) ) ;\
							if(timeout<1) printf("erreur timeout attente commande vide \n");}

int programme_bbv2(FILE * fichier,int * numserie);
int programme_bbv2(FILE * fichier,int * numserie)
{
	int i,a,n;
	uint32_t  b;
	unsigned char filebuf[1100];
	uint32_t  size;
	//TODO: needed?   _send_status_programmation(2)
	//#define _send_status_programmation(n)	{kill(pid,SIGUSR1); Trame_status_udp.status_opera.micro_bbv2=n;	_SEND_UDP_clients_status(&Trame_status_udp,sizeof(Structure_trame_status))}
	
	usleep(500000);			// je rajoute 500 msec au debut
	//TODO: needed? vide_data_FIFO();		// pour vider la fifo
	usleep(100000);
	write_word(driver_fpga,REG_CMD, (uint32_t) 235);	//  c'est le code commande pour passer en mode_micro
	printf("\npassage de la BBv2 en mode microprocesseur\n");
	usleep(50000);	write_word(driver_fpga,REG_CMD, (uint32_t) 256);	//  une data a zero
	usleep(50000);	write_word(driver_fpga,REG_CMD, (uint32_t) 256);	//  une data a zero
	usleep(50000);	write_word(driver_fpga,REG_CMD, (uint32_t) 256);	//  une data a zero
	usleep(50000);	write_word(driver_fpga,REG_CMD, (uint32_t) 256);	//  une data a zero
	//TODO: needed? vide_data_FIFO();		// pour vider la fifo
	usleep(100000);	// laisser le temps (0.1sec) pour que le biphase se rende compte que l'horloge est arretee
	//TODO: needed? vide_data_FIFO();		// pour vider la fifo
	b=0x0120;
	
	for(i=0;i<10;i++)	write_word(driver_fpga,REG_CMD,b++);		// ici avec _attente_cmd_vide ca ne marche pas
	for(i=0;i<10;i++)		// je fais une boucle en attendant le numero de serie
	{
		*numserie=lecture_data_FIFO_microbbv2();
		if(*numserie>2) break;
	}
	printf(" ---> (i=%d) nmserie = %d  \n",i,*numserie);
	if(*numserie<3)	return -1;
	
	//TODO: needed?   _send_status_programmation(*numserie)
	
	size = fsize(fichier);
	fseek(fichier, 0, SEEK_SET);       /* aller au debut */
	printf("fichier de programmation : %d octets \n",(int)size);
	b=(size & 0xff) + 0x0100;write_word(driver_fpga,REG_CMD,b);//_attente_cmd_vide
	b=( (size>>8) & 0xff ) + 0x0100;write_word(driver_fpga,REG_CMD,b);//_attente_cmd_vide
	b=( (size>>16) & 0xff ) + 0x0100;write_word(driver_fpga,REG_CMD,b);//_attente_cmd_vide
	b=( (size>>24) & 0xff ) + 0x0100;write_word(driver_fpga,REG_CMD,b);//_attente_cmd_vide
	usleep(10000);	// attente pour mise en mode conf du fpga (10 msec)
	printf("on attend 0 :  ");  
//TODO: test -tb- if(lecture_data_FIFO_microbbv2()!=0) return -2;
	printf("\n");
	
	
	for(a=0;a<1000;a++)
	{
		if(a%25==0){
		    printf("--> %d%c \n",(int)(a/2.5),'%');
			//TODO: needed?   _send_status_programmation(*numserie + (((int)(a/2.5))<<8)) 
		}
//TODO:test -tb-		if(lecture_data_FIFO_microbbv2()!=-1) return -3;		// erreur durant l'emission des data
		n=fread(filebuf,1,1000,fichier);
		if(n<=0)	break;
		//TODO: needed?   if(a%10==0)	led_B(_vert);
		//TODO: needed?   if(a%10==7)	led_B(_rouge);
		for(i=0;i<n;i++)
		{
			b=( (unsigned short) filebuf[i] ) + 0x0100; 
			write_word(driver_fpga,REG_CMD, b); 
			_attente_cmd_vide
		}
	}
	printf(" programmation de la BBv2 terminee \n");
	//TODO: needed?   _send_status_programmation(*numserie+ (100<<8)) 
	usleep(50000);	write_word(driver_fpga,REG_CMD, (uint32_t) 256);	//  une data a zero
	usleep(50000);	write_word(driver_fpga,REG_CMD, (uint32_t) 256);	//  une data a zero
	
	usleep(500000);	// laisser le temps pour lire le message d'erreur eventuel
	b=0x200;  write_word(driver_fpga,REG_CMD, b);  //fin de commande 
	usleep(500000);	// laisser le temps pour lire le message d'erreur eventuel
	printf("on attend 2 pour terminer : ");
//TODO: test -tb-
return 0;
	if(lecture_data_FIFO_microbbv2()!=2) return -4;
	printf("\n");
	printf("\n");
	//TODO: needed?   _send_status_programmation(*numserie+ (101<<8)) 
	return 0;
}

#endif

/*--------------------------------------------------------------------
 *    function:     mise_a_jour_bbv2
 *    purpose:      restart bolo box (BB)
 *                  (calls int programme_bbv2(FILE * fichier,int * numserie) to reload BB FPGA FW)
 *    author:       from cew.c, modified by Till Bergmann, 2011
 *
 *--------------------------------------------------------------------*/ //-tb-
 /* meaning of recharge parameter:
 */
void				mise_a_jour_bbv2(int recharge)
{
FILE *mon_fichier;
int j,err;
int numserie;
//TODO: ? led_B(_rouge);

if(recharge)	{
				//TODO: do we need this?  _send_status_programmation(1)
				//#define _send_status_programmation(n)	{kill(pid,SIGUSR1); Trame_status_udp.status_opera.micro_bbv2=n;	_SEND_UDP_clients_status(&Trame_status_udp,sizeof(Structure_trame_status))}

				printf("mise a jour du fichier BBv2.rbf\n");
				//system("./startup -2");  //TODO: purpose .... ?  I think this just unpacks bbv2.rbf.gz
				//   see file://localhost/Users/bergmann/ipeprojekte/edelweiss/cew-till-2011-07-15/startup-unused
				//        monftpgetpc BBv2/FPGA_BBv2/bbv2.rbf.gz bbv2.rbf.gz
                //        mongzip bbv2.rbf

				//TODO: _send_status_programmation(1)
				usleep(1000000);	// laisser le temps (1 sec) pour que le programme soit charge
				}
				
//TODO: _send_status_programmation(2)
printf("fichier %s ","bbv2.rbf");   // was /var/bbv2.rbf
if( (mon_fichier = fopen("bbv2.rbf","rw")) )
	{
	for(j=0;j<10;j++)		// j'essaye 10 fois
		{
		envoie_commande_standard_BBv2();
		err=programme_bbv2(mon_fichier,&numserie);
		if(!err) break;
		}
	}
printf("***********   bilan de chargement :  numserie=%d  j=%d  err=%d  ********\n",numserie,j,err);
envoie_commande_horloge();
//TODO: led_B(_vert);
return;
}




/*--------------------------------------------------------------------
 *    function:     envoie_commande_horloge
 *    purpose:      send command to OPERA (horloge=send over clock line)
 *    author:       from cew.c, modified by Till Bergmann, 2011
 *
 *--------------------------------------------------------------------*/ //-tb-
void envoie_commande_horloge(void)
{
	int Table_nb_synchro[8]=_valeur_synchro;
	unsigned char buf[10];

/*
	if(x_fixe>0)	x=x_fixe;
	if(retard_fixe>0)	retard=retard_fixe;
	if(masque_BB_fixe>0)	masque_BB=masque_BB_fixe;
	if(code_acqui_fixe>0)	Code_acqui=code_acqui_fixe;
	if(code_synchro_fixe>0)	Code_synchro=code_synchro_fixe;
*/
	buf[0]='h';
	buf[1]=255;
	buf[2]=X&0xff;		//  sur 16 bit 
	buf[3]=X>>8;		//  sur 16 bit 
	buf[4]=Retard;
	buf[5]=Masque_BB;
	buf[6]=Code_acqui;
	buf[7]=Code_synchro;
	
	Nb_synchro=Table_nb_synchro[Code_synchro&0x3];
	printf("\nHorloge: x=%d retard=%d Code_acqui=%d masque_BB=%d  Nb_mots=%d Code_synchro=%d, Nb_synchro=%d\n",X,Retard,Code_acqui,Masque_BB,Nb_mots_lecture,Code_synchro,Nb_synchro);
	sendCommandFifo(buf,8);   //envoie_commande(buf,8);
}


/*--------------------------------------------------------------------
 *    function:     populateIPECrateStatusPacket
 *    purpose:      fill the  IPE CrateS tatus PUD  packet
 *    author:       Till Bergmann, 2011
 *
 *--------------------------------------------------------------------*/ //-tb-
void populateIPECrateStatusPacket()
{
    int flt;
    
    //reset data block
	              memset(&IPECrateStatusPacket, 0x00, sizeof(IPECrateStatusPacket));


	              //identification
	              //IPECrateStatusPacket.id4 = 0x0000FFD0;  // human readable test: 'pqrs' = 0x53525150; 
	              IPECrateStatusPacket.id0 = 0xFFD0;  //for human readable test: 0x5150 is 'PQ'
	              IPECrateStatusPacket.id1 = 0x0000;// reserved
	              
	              //header
	              IPECrateStatusPacket.presentFLTMap = presentFLTMap;
	              
	              //SLT
	              IPECrateStatusPacket.SLT[0] = pbus->read(SLTControlReg);
	              IPECrateStatusPacket.SLT[1] = pbus->read(SLTStatusReg);
	              IPECrateStatusPacket.SLT[2] = pbus->read(SLTVersionReg);
	              IPECrateStatusPacket.SLT[3] = pbus->read(SLTPixbusEnableReg);
	              IPECrateStatusPacket.SLT[4] = pbus->read(SLTTimeLowReg);
	              IPECrateStatusPacket.SLT[5] = pbus->read(SLTTimeHighReg);
	              
	              //FLT
	              for(flt=0; flt<20; flt++){
	                  if(presentFLTMap & bit[flt]){
	                      //printf("populateIPECrateStatusPacket: FLT %i is present\n",flt);
						  IPECrateStatusPacket.FLT[flt][0] = pbus->read(FLTStatusReg(flt+1));
						  IPECrateStatusPacket.FLT[flt][1] = pbus->read(FLTControlReg(flt+1));
						  IPECrateStatusPacket.FLT[flt][2] = pbus->read(FLTVersionReg(flt+1));
						  IPECrateStatusPacket.FLT[flt][3] = pbus->read(FLTFiberSet_1Reg(flt+1));
						  IPECrateStatusPacket.FLT[flt][4] = pbus->read(FLTFiberSet_2Reg(flt+1));
						  IPECrateStatusPacket.FLT[flt][5] = pbus->read(FLTStreamMask_1Reg(flt+1));
						  IPECrateStatusPacket.FLT[flt][6] = pbus->read(FLTStreamMask_2Reg(flt+1));
						  IPECrateStatusPacket.FLT[flt][7] = pbus->read(FLTTriggerMask_1Reg(flt+1));
						  IPECrateStatusPacket.FLT[flt][8] = pbus->read(FLTTriggerMask_2Reg(flt+1));
	                  }
	                  else
	                  {
	                      //printf("populateIPECrateStatusPacket: FLT %i NOT present\n",flt);
						  //IPECrateStatusPacket.FLT[flt][0] = 0x33323130+flt;
						  IPECrateStatusPacket.FLT[flt][0] = 0x1f000000;
	                  }
	              }
	              
	              //IPAdressMap + Port Map
	              for(flt=0; flt<20; flt++){
	                  IPECrateStatusPacket.IPAdressMap[flt] = FIFOREADER::FifoReader[flt].MY_UDP_SERVER_IP;
	                  IPECrateStatusPacket.PortMap[flt] = FIFOREADER::FifoReader[flt].MY_UDP_SERVER_PORT;
	              }



}

/*--------------------------------------------------------------------
 *    function:     handleKCommand
 *    purpose:      handle command sent from cew_controle/Samba in a UDP packet
 *    author:       from cew.c, modified by Till Bergmann, 2011
 *
 *--------------------------------------------------------------------*/ //-tb-
 // For testing use 'netcat' (on Mac Terminals 'nc')
 //   Writer:   nc -u 192.168.1.105 9940
 //   Listener: nc -u -l 9940
 //   then start ipe4reader6 and use 'writer' to send commands e.g. KRA_0x00A80020_P_0x26d4
 //
 //   0x26d4 = 9940
 //
 //   'K' = 0x4B, 'A' = 0x41, 'Z' = 0x5A, 'k' = 0x6B, 'a' = 0x61, 'z' = 0x7A
 //         -> kleinster Wert: 'AA' = 0x4141 = 16705, bzw. 'KA'=0x4B41=19264;   groesster Wert: 'zz' = 0x7a7a = 31354
 //   => max. Paketnummer: ca 833 = 0x0341 dh. Faktor 20 ... 
 void handleKCommand(char *buffer, int len, struct sockaddr_in *sockaddr_from_ptr)
 {
     struct sockaddr_in &sockaddr_from=*sockaddr_from_ptr;//convert to referenz
     
     uint32_t fltID=0;
     uint32_t address=0;
     uint32_t pbusAddress=0;
     uint32_t value=0;
     uint32_t port=0;
     
     char sendBuffer[1500];
     char senderIPAddr[1024]="0.0.0.0";
     
 	 if(len>=0){
		 strncpy(senderIPAddr, inet_ntoa(sockaddr_from.sin_addr), sizeof(senderIPAddr));
	     printf("handleKCommand: Got UDP data from %s\n", senderIPAddr);
	  }
	  
	  //
	  if(len<3 || buffer[0]!='K'){
	      printf("handleKCommand: This is not a valid K command!\n");
	      return;
	  }
	  
	  //buffer[0] is 'K'
	  switch(buffer[1]){
	  case 'W': //--------WRITE Commands---------------------------------
	      printf("handleKCommand: This is a K Write command! len is %i\n",len);
	      if(buffer[2] == 'A'){
	          //KWA: K command, Write Adress - format KWA_0xABCDEFGH_0x12345678 (25 byte)
	          //example: KWA_0x00A80028_0x000f1234
	          //example: KWA_0x00A80028_0x0000008
	          //read it back from console with: ./readword 0x002a000a
              #if 1
              //TODO: make a fuction which scans two uints (ret val: error; two return arguments) -tb-
              //make more flexible and allow omitting leading zeros
              char *startptr, *endptr;
              startptr=&buffer[3];
              // accept other deliminiter than '_' if(*startptr!='_'){printf("handleKCommand:_ This is not a valid KW command!\n"); return; }
              startptr=&buffer[4];
	          address = strtoul((const char *)&buffer[4],&endptr,0);
              if(address==0){printf("handleKCommand:1 This is not a valid KW command!\n"); return; }
        printf("handleKCommand: buffer %p startptr %p endptr %p diff %i  next char: %c\n",buffer,startptr,endptr,endptr-startptr,*endptr);
              // accept other deliminiter than '_' if(*endptr!='_'){printf("handleKCommand:2 This is not a valid KW command!\n"); return; }
	          //value   = strtoul((const char *)&buffer[15],0,0);
              startptr=endptr+1;
	          value   = strtoul(startptr,&endptr,0);
	          printf("handleKCommand: This is a valid KWA command! Write to address 0x%08x (iADD:0x%08x)  value 0x%08x\n",address,(address >> 2),value);
	          pbus->write((address >> 2),value);
              //printf("handleKCommand: This is not a valid KW command!\n");
              
              #else
              //strict syntax
              if(len>=25){
                  address = strtoul((const char *)&buffer[4],0,0);
                  value   = strtoul((const char *)&buffer[15],0,0);
                  printf("handleKCommand: This is a valid KWA command! Write to address 0x%08x (iADD:0x%08x)  value 0x%08x\n",address,(address >> 2),value);
                  pbus->write((address >> 2),value);
              }
              #endif
	      }
	      else
	      if(buffer[2] == 'F' && len>=29){
	          //KWF: K command, Write FLT adress - format  KWF_0xNN_0xABCDEFGH_0x12345678 (29 byte)
	          //example: KWF_0x04_0x00000040_0x2303ACDC
	          //read it back from console with: ./readword 0x00080010
	          fltID   = strtoul((const char *)&buffer[4],0,0);
	          address = strtoul((const char *)&buffer[9],0,0);
	          value   = strtoul((const char *)&buffer[20],0,0);
	          pbusAddress = (    address | (fltID << 19)    )   >> 2;
	          printf("handleKCommand: This is a valid KWF command! Write to FLT %iaddress 0x%08x (pbusAddress:0x%08x)  value 0x%08x\n",fltID,address,pbusAddress,value);
	          pbus->write(pbusAddress,value);
	      }
	      else
	      if(buffer[2] == 'C' && len>=5){
	          printf("handleKCommand: KWC command!\n");
	          char *foundPos=0;
	          //TODO: replace strstr by strnstr (strnstr seems not to exist on SUSE 10.3!!) -tb-
	          //TODO:if( foundPos=strnstr(buffer,"stop", 1024) ){
	          if(  (foundPos=strstr(buffer,"coldStart"))  ){
	              printf("handleKCommand: KWC >%s< command 1!\n",foundPos);//DEBUG
	              goToState = frSTREAMING;
	          }
	          else
	          if(  (foundPos=strstr(buffer,"init"))  ){
	              printf("handleKCommand: KWC >%s< = init command 2!\n",foundPos);//DEBUG
                  if(FIFOREADER::State == frIDLE) goToState = frINITIALIZED;
	          }
	          else
	          if(  (foundPos=strstr(buffer,"startStreamLoop"))  ){
	              printf("handleKCommand: KWC >%s< command 3!\n",foundPos);//DEBUG
	              goToState = frSTREAMING;
	          }
	          else
	          if(  (foundPos=strstr(buffer,"stopStreamLoop"))  ){
	              printf("handleKCommand: KWC >%s< command 4!\n",foundPos);//DEBUG
	              goToState = frINITIALIZED;
	          }
	          else
	          if(  (foundPos=strstr(buffer,"reset"))  ){
	              printf("handleKCommand: KWC >%s< command 5!\n",foundPos);//DEBUG
	              goToState = frIDLE;
	          }
	          else
	          if(  (foundPos=strstr(buffer,"reloadConfigFile"))  ){
	              printf("handleKCommand: KWC >%s< command 6!\n",foundPos);//DEBUG
	          }
	          else
	          if(  (foundPos=strstr(buffer,"exit"))  ){
	              printf("handleKCommand: KWC >%s< command 7!\n",foundPos);//DEBUG
	              run_main_readout_loop = 0;
	          }
	          else
	          if(  (foundPos=strstr(buffer,"restartKCommandSockets"))  ){
	              printf("handleKCommand: KWC >%s< command 8!\n",foundPos);//DEBUG
	              endKCommandSockets();
	              initKCommandSockets();
	          }
	          else {
	              printf("handleKCommand: WARNING KWC >%s< command unknown!\n",buffer);//DEBUG
	          }
	          
	      }
	      else
	      if(buffer[2] == 'L' && len>=5){
	          //KWL: K command, Write config file line
	          //example: KWL_KWL_FLTfiberSet1(3):         0x73737978
	          int success=0;
	          success = parseConfigFileLine((&buffer[4]));
	          printf("handleKCommand: KWL command: %s\n",success ? "successfully parsed!" : "not found");
	      }
	      else{
	          printf("handleKCommand: This is not a valid KW command!\n");
	      }
	      break;
	  case 'R': //--------READ Commands---------------------------------
	      printf("handleKCommand: This is a K Read command!\n");
	      if(buffer[2] == 'A' && len>=14){
	          //KRA: K command, Read Adress - format KRA_0xABCDEFGH (14 byte), optional: ..._P_0xPPPP (23 byte)
	          //format of the answer: KVA_0xABCDEFGH_0x12345678
	          //example: KRA_0x00A80028
	          //example: KRA_0x00A80028_P_0xFFF0
	          //example: KRA_0x00A80028_P_0x26d4
	          //read it back from console with: ./readword 0x002a000a
	          address = strtoul((const char *)&buffer[4],0,0);
	          if(len>=23) port=strtoul((const char *)&buffer[17],0,0);
	          value = pbus->read((address >> 2));
	          printf("handleKCommand: This is a valid KRA command! Read from address 0x%08x (iADD:0x%08x):  value 0x%08x (sendport:0x%04x))\n",address,(address >> 2),value,port);

              //send answer
              memcpy(sendBuffer,buffer,100);
              sendBuffer[len]=0;//for printf ...
              //printf("handleKCommand: sendBuffer: >%s<\n",sendBuffer);
              sprintf(&sendBuffer[14],"_0x%08x",value);
              sendBuffer[1]='V';//is a return Value
              sendBuffer[25]=0;//for printf ...
              printf("handleKCommand: sendBuffer: >%s<\n",sendBuffer);
              
              //send the answer
              sendtoGlobalClient3(sendBuffer, 25, senderIPAddr, port);

	      }
	      else
	      if(buffer[2] == 'F' && len>=19){
	          //KRF: K command, Read FLT adress - format  KRF_0xNN_0xABCDEFGH (19 byte), optional: ..._P_0xPPPP (28 byte)
	          //format of the answer: KVF_0xNN_0xABCDEFGH_0x12345678
	          //example (access test): KRF_0x04_0x00000040
	          //example: KRF_0x04_0x00000040_P_0xFFF0
	          //example: KRF_0x04_0x0000000C_P_0x26d4
	          //example(version): KRF_0x04_0x00000040_P_0x26d4
	          //this works, too!!! KRF_0x04_0x0000000C_P_9940_____
	          fltID   = strtoul((const char *)&buffer[4],0,0);
	          address = strtoul((const char *)&buffer[9],0,0);
	          pbusAddress = (    address | (fltID << 19)    )   >> 2;
	          if(len>=28) port=strtoul((const char *)&buffer[22],0,0);
	          value = pbus->read(pbusAddress);
	          printf("handleKCommand: This is a valid KRF command! Read from address 0x%08x (pbusAddress:0x%08x, fltID %i):  value 0x%08x (sendport:0x%04x))\n",address,pbusAddress,fltID,value,port);

              //send answer
              memcpy(sendBuffer,buffer,100);
              sendBuffer[len]=0;//for printf ...
              sprintf(&sendBuffer[19],"_0x%08x",value);
              sendBuffer[1]='V';//is a return Value
              sendBuffer[30]=0;//for printf ...
              printf("handleKCommand: sendBuffer: >%s<\n",sendBuffer);

              //send the answer
              sendtoGlobalClient3(sendBuffer, 30, senderIPAddr, port);

	      }
	      else
	      if(buffer[2] == 'C' && len>=5){
	          printf("handleKCommand: KRC command!\n");
	          char *foundPos=0;
	          //TODO: replace strstr by strnstr (strnstr seems not to exist on SUSE 10.3!!) -tb-
	          //TODO:if( foundPos=strnstr(buffer,"stop", 1024) ){
	          if(  (foundPos=strstr(buffer,"IPECrateStatus"))  ){
	              //send IPE crate UDP status packet
	              if(len>=22) port=strtoul((const char *)&buffer[21],0,0);
	              printf("handleKCommand: KRC >%s< command 1! (sendport:0x%04x  %s)\n",foundPos,port,&(buffer[21]));//DEBUG
	              
	              //fill IPECrateStatusPacket
	              populateIPECrateStatusPacket();

				  //send the IPECrateStatusPacket
				  sendtoGlobalClient3((char*)(&IPECrateStatusPacket), sizeof(IPECrateStatusPacket), senderIPAddr, port);

	              //printf("handleKCommand: sendtoGlobalClient3: sizeof(IPECrateStatusPacket) %i\n",sizeof(IPECrateStatusPacket));
	              //netcat seems to cut the output after 1000 bytes

	          }
	          else
	          if(  (foundPos=strstr(buffer,"streamLoopStatus"))  ){
	              if(len>=24) port=strtoul((const char *)&buffer[23],0,0);
	              printf("handleKCommand: KRC >%s< command 2! (sendport:0x%04x  %s)\n",foundPos,port,&(buffer[23]));//DEBUG
	              
				  //send answer
				  memcpy(sendBuffer,buffer,100);
				  sendBuffer[len]=0;//for printf ...
				  sprintf(&sendBuffer[20],"_0x%02x ",FIFOREADER::State);
				  sendBuffer[1]='V';//is a return Value
				  sendBuffer[25]=0;//for printf ...
				  printf("handleKCommand: sendBuffer: >%s<\n",sendBuffer);
	
				  //send the answer
				  sendtoGlobalClient3(sendBuffer, 25, senderIPAddr, port);
	          }
	          else 
	          {
	              printf("handleKCommand: WARNING KRC >%s< command unknown!\n",buffer);//DEBUG
	          }
	      }
	      else{
	          printf("handleKCommand: This is not a valid KR command!\n");
	      }
	      break;
	  default:
	      printf("handleKCommand: This is not a valid K command!\n");
	      break;
	  }

 }
 
/*--------------------------------------------------------------------
 *    function:     handleUDPCommandPacket
 *    purpose:      handle command sent from cew_controle/Samba in a UDP packet
 *    author:       from cew.c, modified by Till Bergmann, 2011
 *
 *--------------------------------------------------------------------*/ //-tb-
int handleUDPCommandPacket(unsigned char *buffer, int len, int iFifo)
{
    short * inBuf_mot= (short*)buffer; 


    // handling of commands: see cew.c, function 'traite_une_commande'
    int i;
	if(show_debug_info) printf("Received UDP cmd pack on server port for FIFO %i (len %i): ",iFifo, (int)len);
	
	//this is from cew.c; this is necessary only for printf'ing the command string with %s, see default branch below -tb-
	buffer[len]=0;

	
	//debug output, add a debug level -tb-
	//in hex
	printf("Cmd in hex:");
	for(i=0; i<(int)len; i++){
	    printf(" 0x%x",buffer[i]);
	}
	printf("\n");
	//as int (and char if possible)
	for(i=0; i<(int)len; i++){
	    printf(" %i",buffer[i]);
	    if(buffer[i]>=' ' &&  buffer[i]!=127) printf(" (%c)",buffer[i]);
	}
	printf("\n");
	
	//comment from cew.c:
    //*********						0		1		2		3		4		5
    //***  horloge OPERA			H		255		cpt_x(short)	retard(short)
    //***  demande port				P		??		port(short)		bolo(short)
    //***	BoiteBolo				W		240		adr		s-adr	data(short)
    //***	mise a jour etrax		Q		1	
    //***	mise a jour FPGA		Q		2	
	
	// handle the command
	
    switch(buffer[0]){
		case 'K' :	printf("  command K : KIT-IPE-Crate command -->");
		            {
		            FIFOREADER &fr=FIFOREADER::FifoReader[iFifo];
		            struct sockaddr_in *sockaddr_from=0;
		            //TODO: fill sockaddr_from
		            sockaddr_from=&fr.servaddr;
					handleKCommand((char*)buffer,len,sockaddr_from);
					}
					break;
			
		case 'C' :	printf("  command code C : commande directe -->");
					sendCommandFifo(buffer,len);
					break;
			
		case 'W' :  printf("  command code W : commande Edelweiss -->"); // W stands for 'write'
					//emission_status_commande(servaddr.sin_addr.s_addr,InBuffer,status);
					sendCommandFifo(buffer,len);
					break;
					
		case 'h' :	//  commande Edelweiss vers l'horloge de la boite OPERA
					//emission_status_commande(servaddr.sin_addr.s_addr,InBuffer,status);

					X = inBuf_mot[1];		//  sur 16 bit 
					// und buffer[3]? immer 255? -tb-
					Retard=buffer[4];
					Masque_BB=buffer[5];
					Code_acqui=buffer[6];
					Code_synchro=buffer[7];
					envoie_commande_horloge();  //TODO: use function parameters to hand over arguments !!! rewrite envoie_commande_horloge()  -tb-
					break;
                    // if( _code_acqui_simple(Code_acqui) == code_acqui_veto )	while(1)	lecture_data_FIFO_veto();
					break;
			
		case 'P' :      // Changement du port UDP pour l'emission
                    printf("  demande P %d blocs port=%d  \n",buffer[1],inBuf_mot[1]);
					//printf("P");
					FIFOREADER::FifoReader[iFifo].addUDPClient(inBuf_mot[1],buffer[1]);//= port, num requested packets, //TODO: inBuf_mot[2]=bolo is ignored -tb-
					//nouveau_client_udp( servaddr.sin_addr.s_addr,inBuf_mot[1],InBuffer[1]);
					break;
	    #if 0
		case 'P' :      // Changement du port UDP pour l'emission
                    // printf("  demande P %d blocs port=%d  \n",InBuffer[1],inBuf_mot[1]);
					printf("P");
					//nouveau_client_udp( servaddr.sin_addr.s_addr,inBuf_mot[1],InBuffer[1]);
					break;

		case 'S' :      // demande des status uniquement avec time out 
                    // printf("  demande S %d status sur  port=%d  \n",InBuffer[1],inBuf_mot[1]);
					printf("S");
					nouveau_client_udp_status( servaddr.sin_addr.s_addr,inBuf_mot[1],InBuffer[1]);
					break;

		case 'h' :	//  commande Edelweiss vers l'horloge de la boite OPERA
					emission_status_commande(servaddr.sin_addr.s_addr,InBuffer,status);

					X = inBuf_mot[1];		//  sur 16 bit 
					Retard=InBuffer[4];
					Masque_BB=InBuffer[5];
					Code_acqui=InBuffer[6];
					Code_synchro=InBuffer[7];
					envoie_commande_horloge();
					break;
                    // if( _code_acqui_simple(Code_acqui) == code_acqui_veto )	while(1)	lecture_data_FIFO_veto();
					break;
		#endif
		
		case 'Q' :      // commande de   mise a jour
					printf("code Q  redemarrage  ( code=%d ) ",buffer[1]);
					printf("Restart command not yet supported! -tb-\n ");
					printf("Experimantal: starting mise_a_jour_bbv2(0) -tb-\n ");
					mise_a_jour_bbv2(0 /* if second command byte was 3, see below*/);
					//sauve_config is a QPushButton defined in ui_commande.h which calls sauve_config() -tb-
					
					#if 0
					switch(InBuffer[1])
							{
							case 0	:	sauve_config();mise_a_jour_et_redemarrage("/mnt/flash/startup","-0");		break;  //-tb- mise a jour=Aktualisierung/Update ; redemarrage=Neustart
							case 1	:	sauve_config();mise_a_jour_et_redemarrage("/mnt/flash/startup","-1");		break;
							case 2	:	sauve_config();mise_a_jour_bbv2(1);		break;
							case 3	:	sauve_config();mise_a_jour_bbv2(0);		break;
							case 4	:	sauve_config();mise_a_jour_et_redemarrage("/mnt/flash/startup","-a");		break;
							case 5	:	sauve_config();		break;
							case 7	:	max_print_time = 1;print_data = 1;	printf("toutes les data\n");	break;
							case 8	:	max_print_time = 1;	printf("bavard\n");	break;
							case 9	:	max_print_time = 100;print_data=0;	printf("discret\n");	break;
							case 10 :	erreur_corrige=0;erreur_synchro_cew=0;erreur_timestamp=0;erreur_synchro_bbv2=0;	break;
							default	:	break;
							}
					#endif
					break;

		case 'R' :     
					//redemande_trames(inBuf_mot[1]);
					//printf("\n");
					{  
					    short inBuf_mot2= ((short*)buffer)[1];
					    printf("requested redemande_trames(%i), not supported!\n", inBuf_mot2);
					}
					break;

		case 'X' :  
		            printf("Received exit command: not supported!\n");   
					//exit(3);
					break;

		default : 	printf("received unknown command : %s \n",buffer);	    	// autres commandes
           		    break;
	}

	
	//printf("COMMAND IGNORED\n");
	return 0;
}

/*--------------------------------------------------------------------
  globals: scan string (line of a file)
  --------------------------------------------------------------------*/

int searchIndexAndUInt32InString(char *mystring, const char *pattern, int *index, uint32_t *retval)
{
    //searching 'pattern(XXX):   YYY', returns index=XXX or index=XXX-1 if XXX is preceeded by '#', returns retval=YYY (YYY may be decimal or hex)
    //returns 1 on success, otherwise 0; possible errors: pattern not found OR conversion of YYY not successful
	char *pch,*endptr;
	pch = strstr(mystring,pattern);
	if(pch == NULL) return 0;
	pch += strlen(pattern);
    if(*pch=='#'){
        pch++;
	    sscanf(pch,"%i",index);
        (*index)--;//index = #ID - 1
    }else
    	sscanf(pch,"%i",index);
    //continue parsing after "):"
	pch = strstr(mystring,"):");
    pch +=2;
	//sscanf(pch,"%x",retval);  //this cannot scan decimal values
    //fprintf(stdout,"retval %i\n",*retval);
        //test  fprintf(stdout,"sizeof(strtoul) is %i\n",   sizeof(strtoul(pch,&endptr,0)));  ->result: 4 (32-bit machine), 8 (64 bit machine)
    *retval = strtoul(pch,&endptr,0);  //this scans decimal or hex integers (returns 64 bit integer on 64-bit machines, 32 bit integer on 32-bit machines!!!, but there is no strtoui)
        //fprintf(stdout,"retval after strtoul %i\n",*retval);
        if(endptr==pch) fprintf(stdout,"searchIndexAndUInt32InString: config file PARSER ERROR! endptr==pch, NO= SUCCESS, retval %i\n",*retval);
    if(endptr==pch) return 0;
	return 1; //success
}



int searchIntInString(char *mystring, const char *pattern, int *retval)
{
	char *pch;
	pch = strstr(mystring,pattern); //TODO: use strnstr (not available for SUSE 10.3) -tb-
	if(pch == NULL) return 0;
	pch += strlen(pattern);
	sscanf(pch,"%i",retval);
	return 1; //success
}

int searchHex32InString(char *mystring, const char *pattern, uint32_t *retval)
{
	char *pch;
	pch = strstr(mystring,pattern);
	if(pch == NULL) return 0;
	pch += strlen(pattern);
	sscanf(pch,"%x",retval);
	return 1; //success
}

int searchStringInString(char *mystring, const char *pattern, char *retval)
{
	char *pch;
	pch = strstr(mystring,pattern);
	if(pch == NULL) return 0;
	pch += strlen(pattern);
	sscanf(pch,"%s",retval);
	return 1; //success
}


/*--------------------------------------------------------------------
 *    function:     readConfigFile
 *    purpose:      read ascii config file 'filename'
 *                  into global variables
 *    arguments:    'filename'
 *    return value: 0 --> OK, != 0  --> ERROR
 *
 *    header files: stdio.h, string.h
 *    libraries:    -
 *    author:       Till Bergmann, 2011
 *
 *--------------------------------------------------------------------*/ //-tb-
int readConfigFile(char *filename)
{
    FILE * pFile;
    char mystring [30000];
    //int notEOF,bytecounter=0;
    int numread,nLines=0;

    pFile = fopen (filename , "r");
    if (pFile == NULL){
        perror ("Error opening file");
	    return 1;
    }
    else 
    {
        while (!feof(pFile)) {
	        //read line by line
            fgets (mystring , 30000 , pFile);
	        numread=strlen(mystring);
	        if(numread>0){
	            parseConfigFileLine(mystring);
	        }
            nLines++;
	    }
	    fclose (pFile);
	    //OUTPUT printf ("Total number of lines: %i\n", nLines);
    }
    return 0;
}


int parseConfigFileLine(char *line)
{
    int wasFound=0;
    char *mystring=line;
    
	      if(mystring[0]!='#'){//skip comment lines
		      //print the line
		      //OUTPUT fputs (mystring,stdout); //puts(...) prints a additional newline!
              //OUTPUT               printf("%s",mystring); //is OK, too
			  //scan the line
			  
			  
			  //global crate/readout loop settings 
			  wasFound = searchIntInString(mystring,"GLOBAL_UDP_SERVER_PORT:",&GLOBAL_UDP_SERVER_PORT);
			  if(wasFound) printf("GLOBAL_UDP_SERVER_PORT: %i\n",GLOBAL_UDP_SERVER_PORT);
			  if(wasFound) return wasFound;
			  
			  wasFound = searchStringInString(mystring,"GLOBAL_UDP_SERVER_IP_ADDR:",GLOBAL_UDP_SERVER_IP_ADDR);
			  if(wasFound) printf("GLOBAL_UDP_SERVER_IP_ADDR: %s\n",GLOBAL_UDP_SERVER_IP_ADDR);
			  if(wasFound) return wasFound;
			  
			  wasFound = searchIntInString(mystring,"GLOBAL_UDP_CLIENT_PORT:",&GLOBAL_UDP_CLIENT_PORT);
			  if(wasFound) printf("GLOBAL_UDP_CLIENT_PORT: %i\n",GLOBAL_UDP_CLIENT_PORT);
			  if(wasFound) return wasFound;
			  
			  //SLT settings
			  SLTSETTINGS &slt = *SLTSETTINGS::SLT;
			  
			  wasFound = searchHex32InString(mystring,"PixbusEnable:",&slt.PixbusEnable);
			  if(wasFound) printf("PixbusEnable: 0x%x\n",slt.PixbusEnable);
			  
			  
			  
    #if 0// now per FIFO (see below)
			  //RECEIVER_PORT = searchIntInString(mystring,"receiver_port:");
			  wasFound = searchHex32InString(mystring,"udp_server_ip:",&MY_UDP_SERVER_IP);
			  if(wasFound) printf("udp_server_ip: 0x%x\n",MY_UDP_SERVER_IP);
			  
			  wasFound = searchIntInString(mystring,"udp_server_port:",&MY_UDP_SERVER_PORT);
			  if(wasFound) printf("udp_server_port: %i\n",MY_UDP_SERVER_PORT);
			  
			  wasFound = searchIntInString(mystring,"use_static_udp_client:",&use_static_udp_client);
			  if(wasFound) printf("use_static_udp_client:  %i\n",use_static_udp_client);
			  
			  wasFound = searchIntInString(mystring,"udp_client_port:",&MY_UDP_CLIENT_PORT);
			  if(wasFound) printf("udp_client_port:  %i\n",MY_UDP_CLIENT_PORT);
			  
			  wasFound = searchStringInString(mystring,"udp_client_ip:",MY_UDP_CLIENT_IP);
			  if(wasFound) printf("udp_client_ip:  %s\n",MY_UDP_CLIENT_IP);
    #endif
			  
			  wasFound = searchIntInString(mystring,"start_recording_adc_to_file_sec:",&RECORDING_SEC);
			  if(wasFound) printf("start_recording_adc_to_file_sec:  %i\n",RECORDING_SEC);
			  if(wasFound) return wasFound;
			  
			  wasFound = searchIntInString(mystring,"simulation_send_dummy_udp:",&simulation_send_dummy_udp);
			  if(wasFound) printf("simulation_send_dummy_udp:  %i\n",simulation_send_dummy_udp);
			  if(wasFound) return wasFound;
			  
    #if 0
			  wasFound = searchIntInString(mystring,"num_fifo:",&numfifo);
			  if(wasFound) printf("num_fifo:  %i\n",numfifo);
			  
			  wasFound = searchIntInString(mystring,"send_status_udp_packet:",&send_status_udp_packet);
			  if(wasFound) printf("send_status_udp_packet:  %i\n",send_status_udp_packet);
			  
			  wasFound = searchIntInString(mystring,"skip_num_status_bits:",&skip_num_status_bits);
			  if(wasFound) printf("skip_num_status_bits:  %i\n",skip_num_status_bits);
			  wasFound = searchIntInString(mystring,"use_dummy_status_bits:",&use_dummy_status_bits);
			  if(wasFound) printf("use_dummy_status_bits:  %i\n",use_dummy_status_bits);
    #endif			  
			  
			  wasFound = searchIntInString(mystring,"run_main_readout_loop:",&run_main_readout_loop);
			  if(wasFound) printf("run_main_readout_loop:  %i\n",run_main_readout_loop);
			  if(wasFound) return wasFound;
			  
    #if 0
			  wasFound = searchIntInString(mystring,"write2file:",&write2file);
			  if(wasFound) printf("write2file:  %i\n",write2file);
			  
			  wasFound = searchIntInString(mystring,"write2file_len_sec:",&write2file_len_sec);
			  if(wasFound) printf("write2file_len_sec:  %i\n",write2file_len_sec);
			  
			  wasFound = searchIntInString(mystring,"write2file_format:",&write2file_format);
			  if(wasFound) printf("write2file_format:  %i (%s)\n",write2file_format, write2file_format?"binary":"ascii");
    #endif
			  wasFound = searchIntInString(mystring,"show_debug_info:",&show_debug_info);
			  if(wasFound) printf("show_debug_info:  %i\n",show_debug_info);
			  if(wasFound) return wasFound;
			  
			  wasFound = searchIntInString(mystring,"use_spike_finder:",&use_spike_finder);
			  if(wasFound) printf("use_spike_finder:  %i\n",use_spike_finder);
			  if(wasFound) return wasFound;
			  
			  //OUTPUT fprintf(stdout,"\n");
			  
			  //scan with FIFO indices:
	          char pattern[2000];
			  int iFifo;
			  for(iFifo=0; iFifo<FIFOREADER::maxNumFIFO; iFifo++){
			      FIFOREADER &fr = FIFOREADER::FifoReader[iFifo];
				  
				  //this is obsolete since we have one FIFO for all FLTs and this FIFO is always on!
				  //config file line example:
				  //readfifo(0): 1                       # switches reading of this FIFO on (1) or off (0)
				  sprintf(pattern,"readfifo(%i):",iFifo);
				  wasFound = searchIntInString(mystring,pattern,&fr.readfifo);
				  if(wasFound) printf("%s 0x%x\n",pattern,fr.readfifo);
				  if(wasFound) return wasFound;


				  sprintf(pattern,"udp_server_ip(%i):",iFifo);
				  wasFound = searchHex32InString(mystring,pattern,&fr.MY_UDP_SERVER_IP);
				  if(wasFound) printf("%s 0x%x\n",pattern,fr.MY_UDP_SERVER_IP);
				  if(wasFound) return wasFound;
				  
				  sprintf(pattern,"udp_server_ip_addr(%i):",iFifo);
				  wasFound = searchStringInString(mystring,pattern,fr.MY_UDP_SERVER_IP_ADDR);
				  if(wasFound){
				      printf("%s %s\n",pattern,fr.MY_UDP_SERVER_IP_ADDR);
				      //TODO:
				      //TODO:
				      //TODO:   <---- is this OK? -tb-
				      //TODO:
				      //TODO:
				      //fr.MY_UDP_SERVER_IP = fr.MY_UDP_SERVER_IP_ADDR
	       //int retval=inet_aton(fr.MY_UDP_SERVER_IP_ADDR,&fr.MY_UDP_SERVER_IP);
	//GLOBAL_UDP_SERVER_IP=GLOBAL_servaddr.sin_addr.s_addr;//this is already in network byte order!!!
	//printf("  inet_aton: retval: %i,IP_ADDR: %s, IP %i (0x%x)\n",retval,GLOBAL_UDP_SERVER_IP_ADDR,GLOBAL_UDP_SERVER_IP,GLOBAL_UDP_SERVER_IP);
				  }
				  
				  if(wasFound) return wasFound;
				  
				  sprintf(pattern,"udp_server_port(%i):",iFifo);
				  wasFound = searchIntInString(mystring,pattern,&fr.MY_UDP_SERVER_PORT);
				  if(wasFound) printf("%s %i\n",pattern,fr.MY_UDP_SERVER_PORT);
				  if(wasFound) return wasFound;
				  
				  wasFound = searchIntInString(mystring,"use_static_udp_client:",&use_static_udp_client);
				  if(wasFound) printf("use_static_udp_client:  %i\n",use_static_udp_client);
				  if(wasFound) return wasFound;
				  
				  wasFound = searchIntInString(mystring,"udp_client_port:",&MY_UDP_CLIENT_PORT);
				  if(wasFound) printf("udp_client_port:  %i\n",MY_UDP_CLIENT_PORT);
				  if(wasFound) return wasFound;
				  
				  wasFound = searchStringInString(mystring,"udp_client_ip:",MY_UDP_CLIENT_IP);
				  if(wasFound) printf("udp_client_ip:  %s\n",MY_UDP_CLIENT_IP);
				  if(wasFound) return wasFound;
				  
				  #if 0
				  wasFound = searchIntInString(mystring,"start_second:",&startSecond);
				  if(wasFound) printf("start_second: %i\n",startSecond);
				  
				  
				  wasFound = searchIntInString(mystring,"start_recording_adc_to_file_sec:",&RECORDING_SEC);
				  if(wasFound) printf("start_recording_adc_to_file_sec:  %i\n",RECORDING_SEC);
				  
				  wasFound = searchIntInString(mystring,"simulation_send_dummy_udp:",&simulation_send_dummy_udp);
				  if(wasFound) printf("simulation_send_dummy_udp:  %i\n",simulation_send_dummy_udp);
				  
				  #endif
				  
				  
				  sprintf(pattern,"num_fifo(%i):",iFifo);
				  wasFound = searchIntInString(mystring,pattern,&fr.numfifo);
				  if(wasFound) printf("%s %i\n",pattern,fr.numfifo);
				  if(fr.numfifo != iFifo) printf("WARNING! YOU CHANGED numfifo from %i to %i - ARE YOU SURE? WARNING!\n",iFifo,fr.numfifo);
				  if(wasFound) return wasFound;
				  
				  sprintf(pattern,"send_status_udp_packet(%i):",iFifo);
				  wasFound = searchIntInString(mystring,pattern,&fr.send_status_udp_packet);
				  if(wasFound) printf("%s %i\n",pattern,fr.send_status_udp_packet);
				  if(wasFound) return wasFound;
				  
				  sprintf(pattern,"skip_num_status_bits(%i):",iFifo);
				  wasFound = searchIntInString(mystring,pattern,&fr.skip_num_status_bits);
				  if(wasFound) printf("%s %i\n",pattern,fr.skip_num_status_bits);
				  if(wasFound) return wasFound;
				  
				  sprintf(pattern,"use_dummy_status_bits(%i):",iFifo);
				  wasFound = searchIntInString(mystring,pattern,&fr.use_dummy_status_bits);
				  if(wasFound) printf("%s %i\n",pattern,fr.use_dummy_status_bits);
				  if(wasFound) return wasFound;
				  
				  
				  
				  
				  
				  
				  sprintf(pattern,"write2file(%i):",iFifo);
				  wasFound = searchIntInString(mystring,pattern,&fr.write2file);
				  if(wasFound) printf("%s %i\n",pattern,fr.write2file);
				  if(wasFound) return wasFound;
				  
				  sprintf(pattern,"write2file_len_sec(%i):",iFifo);
				  wasFound = searchIntInString(mystring,pattern,&fr.write2file_len_sec);
				  if(wasFound) printf("%s %i\n",pattern,fr.write2file_len_sec);
				  if(wasFound) return wasFound;
				  
				  sprintf(pattern,"write2file_format(%i):",iFifo);
				  wasFound = searchIntInString(mystring,pattern,&fr.write2file_format);
				  if(wasFound) printf("%s %i\n",pattern,fr.write2file_format);
				  if(wasFound) printf("%s %s\n",pattern,fr.write2file_format?"binary":"ascii");
				  if(wasFound) return wasFound;
				  
				  //TODO: make configurable for each single FIFO?
				  //sprintf(pattern,"show_debug_info(%i):",iFifo);
				  //wasFound = searchIntInString(mystring,pattern,&fr.show_debug_info);
				  //if(wasFound) printf("%s %i\n",pattern,fr.show_debug_info);
				  
				  				  
			  }
			  
			  
			  
			  //scan with FLT indices: (2013-01: started scanning the index/FLT# from string; loop will be obsolete after some time -tb- 2013-01-08)
              //two methods (1) and (2)
              //(1)    try to read FLT index (new 2013)
	          //char pattern[2000];
              int index=0;
              uint32_t value=0;
              
			  sprintf(pattern,"FLTcontrolVetoFlag(");
              wasFound = searchIndexAndUInt32InString(mystring,pattern,&index,&value);
              if(wasFound){
                  FLTSETTINGS::FLT[index].controlVetoFlag = value;
                  printf("%s%i): 0x%x\n",pattern,index,FLTSETTINGS::FLT[index].controlVetoFlag);
                  return wasFound;
              }
              
              //(2)   scan loop over FLT index (old)
	          //char pattern[2000];
			  int id;
			  for(id=0; id<FLTSETTINGS::maxNumFLT; id++){
			      FLTSETTINGS &flt = FLTSETTINGS::FLT[id];
			      
				  sprintf(pattern,"FLTfiberEnable(%i):",id);
				  wasFound = searchHex32InString(mystring,pattern,&flt.fiberEnable);
				  if(wasFound) printf("%s 0x%x\n",pattern,flt.fiberEnable);
				  if(wasFound) return wasFound;
				  
				  sprintf(pattern,"FLTmode(%i):",id);
				  wasFound = searchHex32InString(mystring,pattern,&flt.mode);
				  if(wasFound) printf("%s 0x%08x\n",pattern,flt.mode);
				  if(wasFound) return wasFound;
				  
				  sprintf(pattern,"FLTBBversionMask(%i):",id);
				  wasFound = searchHex32InString(mystring,pattern,&flt.BBversionMask);
				  if(wasFound) printf("%s 0x%08x\n",pattern,flt.BBversionMask);
				  if(wasFound) return wasFound;
				  
			      
			      
				  sprintf(pattern,"FLTfiberSet1(%i):",id);
				  wasFound = searchHex32InString(mystring,pattern,&flt.fiberSet1);
				  if(wasFound) printf("%s 0x%08x\n",pattern,flt.fiberSet1);
				  if(wasFound) return wasFound;
				  
				  sprintf(pattern,"FLTfiberSet2(%i):",id);
				  wasFound = searchHex32InString(mystring,pattern,&flt.fiberSet2);
				  if(wasFound) printf("%s 0x%08x\n",pattern,flt.fiberSet2);
				  if(wasFound) return wasFound;
				  

				  sprintf(pattern,"FLTstreamMask1(%i):",id);
				  wasFound = searchHex32InString(mystring,pattern,&flt.streamMask1);
				  if(wasFound) printf("%s 0x%08x\n",pattern,flt.streamMask1);
				  if(wasFound) return wasFound;
				  
				  sprintf(pattern,"FLTstreamMask2(%i):",id);
				  wasFound = searchHex32InString(mystring,pattern,&flt.streamMask2);
				  if(wasFound) printf("%s 0x%08x\n",pattern,flt.streamMask2);
				  if(wasFound) return wasFound;
				  
				  
				  sprintf(pattern,"FLTtriggerMask1(%i):",id);
				  wasFound = searchHex32InString(mystring,pattern,&flt.triggerMask1);
				  if(wasFound) printf("%s 0x%08x\n",pattern,flt.triggerMask1);
				  if(wasFound) return wasFound;
				  
				  sprintf(pattern,"FLTtriggerMask2(%i):",id);
				  wasFound = searchHex32InString(mystring,pattern,&flt.triggerMask2);
				  if(wasFound) printf("%s 0x%08x\n",pattern,flt.triggerMask2);
				  if(wasFound) return wasFound;
				  

				  sprintf(pattern,"FLTsendBBstatusMask(%i):",id);
				  wasFound = searchHex32InString(mystring,pattern,&flt.sendBBstatusMask);
				  if(wasFound) printf("%s 0x%08x\n",pattern,flt.sendBBstatusMask);
				  if(wasFound) return wasFound;
				  


			  }

		  }else{
              //printf("Comment.\n");	  
		  }
		  
	  return wasFound;
}

/*--------------------------------------------------------------------
 *    function:     readFileToBuf
 *    purpose:      read ascii file 'filename' containing hex values in the form 0xUUUUUUUU (each representing one byte! higher bits are cutted!)
 *                  into byte array 'buf'; reads until end of file or maximum of 'maxbuflen' bytes;
 *    arguments:    'filename', 'buf' char array, 'maxbuflen' should be length of 'buf'
 *    return value: number of read bytes
 *
 *    header files: stdio.h, string.h
 *    libraries:    -
 *    author:       Till Bergmann, 2011
 *
 *--------------------------------------------------------------------*/ //-tb-
int readFileToBuf(const char *filename, char *buf, int maxbuflen)
{
   FILE * pFile;
   char mystring [30000];
   //int notEOF;
   int numread,nLines=0,bytecounter=0;

   pFile = fopen (filename , "r");
   if (pFile == NULL) perror ("Error opening file");
   else {
    while (!feof(pFile)) {
      fgets (mystring , 30000 , pFile);
	  numread=strlen(mystring);
	  if(numread>0){
	      if(mystring[0]!='#'){
		      //print the line
		      //OUTPUT fputs (mystring,stdout); //puts(...) prints a additional newline!
              //OUTPUT printf("%s",mystring); //is OK, too
			  //scan the line
			  char *pch;
			  unsigned int val;
			  pch = strstr(mystring,"0x");
				  //OUTPUT fprintf(stdout,"pch %p  mystring %p \n",pch, mystring);
			  while(pch != NULL){
			      sscanf(pch,"%x",&val);
				  if(buf) buf[bytecounter]=val;
				  //OUTPUT fprintf(stdout,"%i ",val);
				  bytecounter++;
				  pch  = strstr(pch+1,"0x");
			  }
			  //OUTPUT fprintf(stdout,"\n");
		  }
	  }
      nLines++;
	}
	fclose (pFile);
	//OUTPUT printf ("Total number of lines: %i\n", nLines);
   }
   return bytecounter;
}


/*--------------------------------------------------------------------
 *    function:     runSpikeFinderOnUDPPacket
 *    purpose:      search spikes in ADC data
 *    author:       Till Bergmann, 2011
 *
 *--------------------------------------------------------------------*/ //-tb-
int runSpikeFinderOnUDPPacket(char *buffer, size_t length)
{
    static int pnr=0;//UDP packet number
    //buffer is the UDP data packet = 4 bytes header + rest = data
	int retval=0;
	uint16_t *data = (uint16_t*) (&buffer[4]);
	int datalen = (length-4) / 2;
	int i,iadc;
	int32_t val, val1, val2;
	int Nb_mots16_lecture = Nb_mots_lecture *2;//is 4 or 6 (Nb_mots_lecture is 2 or 3)
	retval = 0;
    if(secCountSpikes==0) return retval;
    
	for(i=0; i<datalen-Nb_mots16_lecture; i+=Nb_mots16_lecture){
	    for(iadc=0; iadc<Nb_mots16_lecture;iadc++){
	        val1 = data[i+iadc];
	        val2 = data[i+iadc+Nb_mots16_lecture];
	        val = abs( val2 - val1);
	        if(val > 250 && val < 32000){
	            countSpikes++;
	            countSpikesChan[iadc]++;
	            if(val<401) countSpikesVal[0]++;
	            if(val>400 && val<1001) countSpikesVal[1]++;
	            if(val>1000) countSpikesVal[2]++;
	            if(use_spike_finder>=2){//verbose output
	                printf("SPIKE:pnr.%3i(dlast:%3i),chan:%i,val1:0x%x (%li),  val2:0x%x (%li)  , diff:%i   ,   index1:%i    index2:%i\n",data[-2],data[-2]-pnr,iadc,(unsigned int)val1,val1,(unsigned int)val2,val2,(int)val,i+iadc,i+iadc+Nb_mots16_lecture);
	                pnr=data[-2];
	            }
	        }
	    }
	}
    return retval;
}
















/*--------------------------------------------------------------------
  FIFOREADER::openAsciiFile
  --------------------------------------------------------------------*/
int FIFOREADER::openAsciiFile(int udpdataSec, int write2file_len_sec)
{
	    static char mystring [10000];
	    //open the file
	    //sprintf(mystring,"%s","CEW_controle_interrupt.c.bb21.sec21xx.txt");
	    sprintf(mystring,"ipe4reader5-sec%i-fifo%i-len%i.txt",udpdataSec,numfifo,write2file_len_sec);//TODO: use exe name as name stem -tb-
	    printf("writeToAsciiFile: open file %s\n",mystring);
    	pFile = fopen (mystring , "w");
	    if (pFile == NULL){
	        perror ("Error opening file");
	        return 1;
	    }
	    return 0;
}

/*--------------------------------------------------------------------
  FIFOREADER::openBinaryFile
  --------------------------------------------------------------------*/
int FIFOREADER::openBinaryFile(int utc, int write2file_len_sec)
{
	    static char mystring [10000];
	    //open the file
	    //sprintf(mystring,"%s","CEW_controle_interrupt.c.bb21.sec21xx.txt");
	    sprintf(mystring,"ipe4reader5-utc%i-fifo%i-len%i.binary",utc,numfifo,write2file_len_sec);//TODO: use exe name as name stem -tb-
	    printf("writeToBinaryFile: open file %s\n",mystring);
    	pFile = fopen (mystring , "wb");
	    if (pFile == NULL){
	        perror ("Error opening file");
	        return 1;
	    }
	    return 0;
}

/*--------------------------------------------------------------------
  FIFOREADER::writeToAsciiFile
  --------------------------------------------------------------------*/
int FIFOREADER::writeToAsciiFile(const char *buf, size_t n, int udpdataSec)
{
	int retval=0;
	int col;
	unsigned int printval=0;
	
	
	if(n>0 && pFile!=NULL ){
		fprintf(pFile,"# Comment: n is %i, sec is %i\n",(int)n,udpdataSec);
		//print in HEX
		fprintf(pFile,"   ");
		for(col=0; col<n; col++){
			*((char*)(&printval))=buf[col];
		    fprintf(pFile,"0x%02x ",printval);
		}
		fprintf(pFile,"\n");
		#if 0  //TODO: skip writing decimal -tb-
		//print in DECIMAL
		fprintf(pFile,"#  ");
		for(col=0; col<n; col++){
		    fprintf(pFile,"%4i ",buf[col]);
		}
		fprintf(pFile,"\n");
		#endif
	}

	//retval = sendto(MY_UDP_CLIENT_SOCKET, buffer, length, 0 /*flags*/, (struct sockaddr *)&si_other, si_other_len);
    return retval;
}






/*--------------------------------------------------------------------
 *    macro used in:     FIFOREADER::scanFIFObuffer
 *    purpose:      scan scan status bits in ADC data
 *    author:       Till Bergmann, 2011
 *
 *--------------------------------------------------------------------*/ //-tb-
// moved to other globals -tb-    ----->
//make it global: is 3 for BB2, 2 for BBv21 mode!!!!!!!!!! -tb-
//int	Nb_mots_lecture=3;					//marche pour un seul bolo	// nombre de mots total relut dans les data de la fifo:   -tb- d.h. Anzahl 32-bit-Worte(FIFO-Worte) pro (Time-)Sample (Sample=alle ADC-Kanaele

//Funktionsweise: (Abkuerzung mon_i = mon_indice_status_bbv2)
//    mon_i startet mit: mon_i = _nb_mots_status_bbv2 * 16 + 1  -2 = 911; Zeile unten: mot_status=... ergibt dann = (57-1) - (57*16-1)/16 = (57-1) - 911/16 = 56-int(56.93...)=0
//    falls mon_i = 912, dann ist mot_status=56-int(57)=-1, d.h. ein Wort wird uebersprungen; will man x Worte (x Statusbits) ueberspringen, so muss 
//            mon_i = _nb_mots_status_bbv2 * 16 + 1  -2 + x  gesetzt werden

 	#define		my2nd_ecrit_status_bbv2(adc_data32,i,status_bbv2_1)	\
	if(mon_indice_status_bbv2 &&  ( (i%Nb_mots_lecture) == (Nb_mots_lecture-1) ) )		/* ne marche que pour une seule boite: le bit 0 du dernier mot  */ \
	{ int mot_status = _nb_mots_status_bbv2 -1 - mon_indice_status_bbv2/16; mon_indice_status_bbv2--;\
	/*if(mot_status>=0   &&  ((&udpdata32[1])+2 == &adc_data32[i])) printf("Next read is first ADCch6(BB2) sample!\n"); */ \
	/*if (1 || mot_status>=0) printf(" adc_data32(%p)[i is %i]&0x1))  bit0 %1x     mon_indice_status_bbv2 %i    mot_status %i\n",&adc_data32[i] ,i,adc_data32[i ]&0x1  ,   mon_indice_status_bbv2, mot_status); */  \
	if (mot_status>=0) status_bbv2_1[mot_status] = ((adc_data32[i]&0x0001)<<15) | ((status_bbv2_1[mot_status]>>1)&0x7fff);}

/*--------------------------------------------------------------------
 *    function:     FIFOREADER::scanFIFObuffer
 *    purpose:      scan data in FIFO buffer; search for header word; send UDP packets
 *    author:       Till Bergmann, 2011
 *
 *--------------------------------------------------------------------*/ //-tb-
	int32_t		temp_status_bbv2_1[_nb_mots_status_bbv2 + 10];	//_nb_mots_status_bbv2 = 57 -tb-
	int16_t	*	temp_status_bbv2_1_16=(int16_t	*)temp_status_bbv2_1;

void FIFOREADER::scanFIFObuffer(void)
{
    if(FIFObuf32avail < 360 ) return;// we need at most 360 words to build a standard UDP packet; only the last before header word may be shorter
    
    //TODO: if globalHeaderWordCounter==0 don't send UDP packets: we are maybe in the middle of FIFO -tb-
	
    //vars for scanning status bits
    int nb_mots_trame32    = 0;
	//static int mon_indice_status_bbv2 = 0;// <----   each FIFO (in multi-FIFO readout) needs own counter!
    int32_t *adcdataptr32;
	int	nb_mots_trame;
	
	
    int udpPacketLen   = 0;
    int headerWordFoundFlag = 0;
    uint32_t i;
    int32_t val;
    
    //1. start building a UDP packet in array udpdata32/udpdata ;    we have at least 360 words in FIFO: 
	//     a) full packet with 360 samples or 
	//     b) less, then we will have the header word somewhere -tb-
    udpdata16[0] = udpdataCounter;
    udpdata16[1] = udpdataSec;  //TODO cut to 14 bit as in cew.c?  -tb-
    udpPacketLen +=4;
    if(show_debug_info>2) printf("scanFIFObuffer: start udp packet with sec %i, counter %i\n",udpdataSec ,udpdataCounter);//TODO: DEBUG output -tb-
    for(i=0; i<360; i++){  //TODO: 360 = 1440 / 4 ---> must be configurable (FIFOREADER variable) -tb-
        val = FIFObuf32[popIndexFIFObuf32];
        if( val == 0x00003117){
            headerWordFoundFlag=1 ;  
            if(show_debug_info>2) printf("scanFIFObuffer: found header word at i= %i (popIndexFIFObuf32 %i)\n",i, popIndexFIFObuf32);//TODO: DEBUG output -tb-
            break;//stop for-loop: keep headerWord in buffer and proceed to step 2.a)
        }
        //else
        udpdata32[1+i] = val;
        udpPacketLen +=4;//TODO: variable dataPacketLen=4 -tb-
        popIndexFIFObuf32 += 1;
        FIFObuf32avail = pushIndexFIFObuf32 - popIndexFIFObuf32; // or FIFObuf32avail--
    }
    
	
	//2. a.) send the UDP data paket and b.) scan the status bits
    if(udpPacketLen > 4){// contains more than only the UDP header (if udpPacketLen==1->contains packet header, but no data) -> ADC data
	    //a.) send data
        if(show_debug_info>2) printf("send udp packet with size %i \n",udpPacketLen);//TODO: DEBUG output -tb-
        if(use_static_udp_client){
		    numSent = sendtoClient(udpdata,udpPacketLen);   //TODO:    senden von UDP paketen konfigurierbar machen, Wunsch von Bernhard   <<<--------------------
            if(numSent != udpPacketLen) printf("scanFIFObuffer: ERROR sendtoClient(): packet size %i, sent bytes %i\n",udpPacketLen,numSent);
		}
		//TODO: status clients not supported  -tb-  for (i=0;i<NB_CLIENT_UDP;i++){  if (numPacketsClientStatus[i]) numPacketsClientStatus[i]--;  }
		sendtoUDPClients(1,udpdata,udpPacketLen);

        if(show_debug_info>1 && udpdataCounter<1){
            if(udpPacketLen>=16) printf("adc0,1:0x%x adc2,3:0x%x adc4,5:0x%x \n",udpdata32[1],udpdata32[2],udpdata32[3]);//TODO: DEBUG output -tb-
            else if(udpPacketLen>=12) printf("adc0,1:0x%x adc2,3:0x%x  \n",udpdata32[1],udpdata32[2]);//TODO: DEBUG output -tb-
            else printf("adc0,1:0x%x \n",udpdata32[1]);//TODO: DEBUG output -tb-
        }
        
        udpdataCounter++; 
		udpdataByteCounter += (udpPacketLen - 4);//TODO: variable dataPacketLen=4 -tb-

        //write UDP data packet to file (status packet: see below)
        if(pFile  &&  write2file_format == ascii  &&  globalHeaderWordCounter>0 ){
            //NO, open for status packet ... if(pFile == NULL) openAsciiFile(udpdataSec);//open file
            writeToAsciiFile((char*)(udpdata),udpPacketLen,udpdataSec);
        }
		
		//TODO: DEBUG: run spike finder on UDP packets
		if(use_spike_finder) runSpikeFinderOnUDPPacket(udpdata,udpPacketLen);
		
		
		#if 0
		//TODO: remove all this - the FLT is now scanning the status packets -tb-
		//b.) now scan status bits (I could scan them immediately after reading from FIFO; but here we don't need to care about header word) -tb-
		nb_mots_trame  = (udpPacketLen/4)-1 ; //nb_mots_trame is in 32bit bunches and the first skipped (?)-tb-
		//void scanFIFObuffer(void)
		//mon_indice_status_bbv2 is set below, i.e. when header word found, so scanning status bits starts in next call of printf("mon_indice_status_bbv2 %i\n",mon_indice_status_bbv2);
		if(mon_indice_status_bbv2){
		    //DEBUG printf("Nb_mots_lecture %i\n",Nb_mots_lecture);
			//printf("SCANNING STATUS BITS mon_indice_status_bbv2 %i  nb_mots_trame  %i\n",mon_indice_status_bbv2,nb_mots_trame);
			//adcdataptr32=udpdata32-5;    // worked 2011-11-15 with -5
			adcdataptr32=udpdata32+1;    // worked 2011-11-15 with -5
			for(i=0;i<nb_mots_trame;i++){		// sur les premieres trames, boucle de decodage du status bbv2
				//_corrige_erreur_bit31 
				//_recupere_bit_31
				//_ecrit_status_bbv2(i);
				my2nd_ecrit_status_bbv2(adcdataptr32,i,Trame_status_udp.status_bbv2_1);
			}
			//debug output -> add debug level
			if(mon_indice_status_bbv2==0){
				//printf("WRITE STATUS BITS %i\n",mon_indice_status_bbv2);
				fprintf(stdout," Nbits:");
				for(i=0; i< _nb_mots_status_bbv2; i++){
						fprintf(stdout,"%04x.",((unsigned int)Trame_status_udp.status_bbv2_1[i] & 0xffff));
				}
				fprintf(stdout,"... \n");
			}
		}else
			for(i=0;i<nb_mots_trame;i++){
				//_corrige_erreur_bit31
				//_recupere_bit_31
			}
		#endif
		
    }
	
	//3. send status when header word found; flag scanning status bits in next ADC data
    if(headerWordFoundFlag){
        headerWordFoundFlag=0;
        //move FIFObuf content to index 0 --> header word at index 0
        if(show_debug_info>1) printf("scanFIFObuffer: Move FIFO by %i indices down\n",popIndexFIFObuf32);
        for(i=0; i<FIFObuf32avail; i++) FIFObuf32[i] = FIFObuf32[popIndexFIFObuf32+i];//TODO: memcpy might be faster? -tb-
        popIndexFIFObuf32 = 0;
        pushIndexFIFObuf32 = FIFObuf32avail;
        
        //DEBUGKRAM
        if(1){
            if(FIFObuf32avail >= 8){
                printf("   ADCs: ");
                int i;
                for(i=0; i<8; i++){
                    printf("0x%08x, ",FIFObuf32[i]);
                }
                printf("\n");
            }
        }
        
        //DEBUG: show spike finder results
        if(use_spike_finder ){
        int k;
        printf("------->Spike finder: %li (",countSpikes);
        for(k=0; k<Nb_mots_lecture *2;k++) printf("%li,",countSpikesChan[k]);
        printf("), sec. %li    <------\n",secCountSpikes);
        if(use_spike_finder>=2) printf("Spikebit - 256er:%li , 512er:%li, larger:%li \n",countSpikesVal[0], countSpikesVal[1],countSpikesVal[2]);
        secCountSpikes++;
        }





        if(FIFObuf32avail>=4){//we need all 4 words of the header 'sentence' to extract the time stamp
		
		    //TODO: move "send code" to this location???? -tb-
		

            //print num of sent bytes
			//if(show_debug_info) 
			printf("scanFIFObuffer: numfifo %i: read bytes: %i\n", numfifo, udpdataByteCounter);

            //prepare next UDP packet header
            udpdataCounter = 0; //restart counting at 0
			udpdataByteCounter = 0;
            //    extract timestamp (sec) from header
            uint32_t pd_fort=0, pd_faible=0;
            pd_fort   = FIFObuf32[3] & 0x3ffff ;    // 18 bits
            pd_faible = FIFObuf32[2] & 0x3fffffff;  // 30 bit
            udpdataSec = 	(     (((pd_fort%125)<<25) + (pd_faible>>5)) /125       +     ((pd_fort/125)<<25)     )     /25;
            globalHeaderWordCounter++; //TODO: for testing/debugging -tb-
            if(show_debug_info) printf("scanFIFObuffer: HEADER word # %u, t= %i\n", globalHeaderWordCounter,udpdataSec);
//TODO: remove it, for DEBUGGING -tb-
//udpdataSec= globalHeaderWordCounter;
            //now 'remove' header from FIFObuff32
            popIndexFIFObuf32 += 4;
            FIFObuf32avail =  pushIndexFIFObuf32 - popIndexFIFObuf32;



            //****************************************************
            //*    BEGIN - OPERA status packet (deprecated)      *
            //****************************************************
			//FORMAT DEFNITION: see cew.c, macro _ecrit_trame_status(pt) as a example; or above at init of Opera Status -tb-
            Trame_status_udp.identifiant = 0x0000ffff;
            Trame_status_udp.status_opera.temps_seconde = udpdataSec;
			
            Trame_status_udp.status_opera.temps_pd_fort       = pd_fort;
            Trame_status_udp.status_opera.temps_pd_faible     = pd_faible;
			
			//get Opera status
            uint32_t OperaStatus0 =  pbus->read(OperaStatusReg0);
            uint32_t OperaStatus1 =  pbus->read(OperaStatusReg1);
            printf("OperaStatusReg0: 0x%08x\n",OperaStatus0);
            printf("OperaStatusReg1: 0x%08x\n",OperaStatus1);
			Code_acqui   =  OperaStatus0      & 0xff;
			Masque_BB    = (OperaStatus0>> 8) & 0xff;
			Code_synchro = (OperaStatus0>>16) & 0xff;
			Retard       = (OperaStatus0>>24) & 0xff;
			X            =  OperaStatus1      & 0xfff;
            Trame_status_udp.status_opera.code_acqui       = Code_acqui;
                 //Trame_status_udp.status_opera.code_acqui       = 3       & 0xff;
            Trame_status_udp.status_opera.masque_BB        = Masque_BB;
            Trame_status_udp.status_opera.code_synchro     = Code_synchro;
            Trame_status_udp.status_opera.registre_retard  = Retard;
            Trame_status_udp.status_opera.registre_x       = X;
            Trame_status_udp.status_opera.version_cew      = VERSION_IPE4READOUT;
            
            switch( Trame_status_udp.status_opera.code_acqui ){
                case 0: printf("   OperaStatus0 code acqi %i: test mode\n",Trame_status_udp.status_opera.code_acqui); break;
                case 3: printf("   OperaStatus0 code acqi %i: BBv21\n",Trame_status_udp.status_opera.code_acqui); break;
                case 8: printf("   OperaStatus0 code acqi %i: BB2\n",Trame_status_udp.status_opera.code_acqui); break;
                default: printf("   OperaStatus0 code acqi %i: unsupported\n", Trame_status_udp.status_opera.code_acqui); break;
            }
            switch( Trame_status_udp.status_opera.code_acqui ){
                case 0: printf("   OperaStatus0 code acqi %i: test mode\n",Trame_status_udp.status_opera.code_acqui); break;
                case 3: Nb_mots_lecture=2; break;
                case 8: Nb_mots_lecture=3; break;
                default: Nb_mots_lecture=3; 
				         printf("WARNING: Unknown OperaStatus0 code acqi %i: using fallback Nb_mots_lecture=%i - status packet may be corrupt!\n", Trame_status_udp.status_opera.code_acqui,Nb_mots_lecture); 
						 break;
            }
			
			//			others
/*
#define		_ecrit_trame_status(pt)			\
Trame_status_udp.status_opera.version_cew			= (int)(1000.*_version_cew + 1 ); \
Trame_status_udp.status_opera.temps_pd_fort			= _temps_poid_fort(pt);\
Trame_status_udp.status_opera.temps_pd_faible		= _temps_poid_faible(pt);\
Trame_status_udp.status_opera.temps_seconde			= _temps_seconde(Trame_status_udp.status_opera.temps_pd_fort,Trame_status_udp.status_opera.temps_pd_faible);\
Trame_status_udp.status_opera.code_acqui			= _code_acqui(pt); \
Trame_status_udp.status_opera.micro_bbv2			= _micro_trame(pt); \
Trame_status_udp.status_opera.masque_BB				= _masque_BB(pt); \
Trame_status_udp.status_opera.code_synchro			= _code_synchro(pt);\
Trame_status_udp.status_opera.registre_x			= _reg_x_trame(pt); \
Trame_status_udp.status_opera.registre_retard		= _retard_trame(pt); \
Trame_status_udp.status_opera.nb_erreurs_synchro_cew	= erreur_synchro_cew; \
Trame_status_udp.status_opera.nb_erreurs_timestamp	= erreur_timestamp; \
Trame_status_udp.status_opera.erreurs_synchro_opera	= _erreur_synchro_opera(pt); \
erreur_synchro_opera	= _erreur_synchro_opera(pt);
*/
			



			//led_B(_rouge); 
//TODO: ===>   KEEP THIS FOR NON-OPERA PACKETS! -tb-
			for(i=0;i<NB_CLIENT_UDP;i++){
			    status_client[i]=numPacketsClient[i]; 
                //printf("DUMMYTEXT-DUMMYTEXT-DUMMYTEXT-DUMMYTEXT-DUMMYTEXT-DUMMYTEXT-DUMMYTEXT-DUMMYTEXT-\n");
					    printf("  ... index  %i status_client(%i) \n",i,status_client[i]);
			    if(numPacketsClient[i]){
				    numPacketsClient[i]--;
					//led_B(_vert); 
					if(show_debug_info>1){ 
					    printf("index  %d status_client(%d) \n",i,status_client[i]);
					}
				}
			    if(show_debug_info>1)
    				printf("  data: %x , %x , %x , %x ",(FIFObuf32[4]>>16)&0xffff,FIFObuf32[4]&0xffff,(FIFObuf32[5]>>16)&0xffff,FIFObuf32[5]&0xffff);
    				//printf("err=%d/%d/%d/%d   data: %lx , %lx , %lx , %lx ",erreur_synchro_opera,erreur_synchro_cew,erreur_timestamp,erreur_synchro_bbv2,
					//					(FIFObuf32[4]>>16)&0xffff,FIFObuf32[4]&0xffff,(FIFObuf32[5]>>16)&0xffff,FIFObuf32[5]&0xffff);
			}

			//send UDP status packet  //TODO: send it before reading the next status????? -tb-
			  //dummy status bits
			if(use_dummy_status_bits){//dedicated for BBv1 with all status bits == 0; replaces status bits by dummy status of previously recorded status (for BBv2)
			    //in main(): buf_status284_len = readFileToBuf("bb21-udp284.txt",buf_status284
				printf("Warning: DUMMY STATUS BITS for FIFO %i\n",numfifo);
				if(buf_status284_len==0) printf("ERROR: CANNOT READ DUMMY STATUS BITS, FILE NOT FOUND: bb21-udp284.txt or udp284.txt\n");
				int i;
				Structure_trame_status *dummystatus=(Structure_trame_status *)buf_status284;
				for(i=0; i<_nb_mots_status_bbv2;i++){
				    Trame_status_udp.status_bbv2_1[i] = dummystatus->status_bbv2_1[i];
				    if(i==0) Trame_status_udp.status_bbv2_1[0] = use_dummy_status_bits + 0x200;//0x0000020c;//this "fakes" BB#12=0xc;
					printf("%x.",Trame_status_udp.status_bbv2_1[i]);
				}
			    printf("\n");
                if(send_status_udp_packet) sendtoUDPClients(0,(&Trame_status_udp),sizeof(Trame_status_udp));
			}
            //****************************************************
            //*    END - OPERA status packet (deprecated)      *
            //****************************************************
			
            
            #if 0
            //*    CRATE status packet (deprecated)      *
            //****************************************************
			UDPPacketScheduler crateStatusScheduler(this);
            //prepare header
            TypeCrateStatusHeader crateStatusHeader;
            crateStatusHeader.identifiant = 0x0000ffe0;
            crateStatusHeader.stamp_msb = pd_fort;
            crateStatusHeader.stamp_lsb = pd_faible;
            crateStatusHeader.PPS_count = udpdataSec;
            crateStatusScheduler.setHeader(&crateStatusHeader,sizeof(crateStatusHeader));
            //payload
            TypeCrateStatusBlock crateStatusBlock;
	        crateStatusBlock.size_bytes = sizeof(TypeCrateStatusPayload);            // 
	        crateStatusBlock.d0 = 20;             // previously in cew: registre_x, =20  
	        crateStatusBlock.prog_status = 0;     // previously in cew: micro_bbv2,   for BBv2/2.3/3 programming
	        crateStatusBlock.pixbus_enable = 	pbus->read(SLTPixbusEnableReg);

	        crateStatusBlock.internal_error_info;
	        crateStatusBlock.version;        // _may_ be useful in some particular cases (version of C code/firmware/hardware?)
            #endif
            
            //****************************************************
            //*         BB status packet(s)                      *
            //****************************************************
			UDPPacketScheduler BBStatusScheduler(this);
            //prepare header
            TypeBBStatusHeader BBStatusHeader;
            BBStatusHeader.identifiant = 0x0000fffe;
            BBStatusHeader.PPS_count = udpdataSec;
            BBStatusHeader.version   = VERSION_IPE4READOUT;
            BBStatusHeader.spare1 = 1;
            BBStatusHeader.spare2 = 2;
            BBStatusScheduler.setHeader((char*)&BBStatusHeader,sizeof(BBStatusHeader));
            //payload
            TypeBBStatusBlock BBStatusPayload;
            BBStatusPayload.size_bytes = sizeof(TypeBBStatusBlock);
            BBStatusPayload.fltIndex = 0;
            BBStatusPayload.fiberIndex = 0;
            BBStatusPayload.spare = 0;
            
			//read status bits from FLT memory
			if(send_status_udp_packet){
			    int idx;//index, not ID
			    for(idx=0; idx<FLTSETTINGS::maxNumFLT; idx++){
			        FLTSETTINGS &flt = FLTSETTINGS::FLT[idx];
					//FLTSETTINGS &FLT = FLTSETTINGS::FLT[numfifo]; //TODO: each FLT has its own SLT FIFO; move status packet sending elsewhere? -tb-
					if(flt.isPresent)
					{
						int numFLT = flt.fltID;
						int fiber;
						for(fiber=0;fiber<6;fiber++){
							if(flt.sendBBstatusMask & bit[fiber]){
								//printf("Status bits fiber %i read from FLT %i with ID %i:\n",fiber,idx,numFLT);
								int i;
								uint32_t status;
								uint16_t *status16 = (uint16_t *)(&status);
								int numChan =fiber;
								for(i=0; i<32; i++){
									status = pbus->read(FLTBBStatusReg(numFLT, numChan)+i);
									temp_status_bbv2_1[i]=status;//TODO: immediately copy it! see below ... -tb-
									//printf("0x%08x ",status);
									//dbg printf("%04x.%04x.",status16[0],status16[1]);
								}
                                //build BB status packet
                                BBStatusPayload.fltIndex = idx;
                                BBStatusPayload.fiberIndex = fiber;
								for(i=0; i<_nb_mots_status_bbv2; i++){
                                    BBStatusPayload.bb_status[i] = temp_status_bbv2_1_16[i];//TODO: immediately copy it when OPERA status is removed! -tb-
									//printf("bb_status %i: 0x%08x ",i,BBStatusPayload.bb_status[i]);
								}
							   //dbg printf("\n");
								  //printf("   Reading status bits of fiber %i  from FLT#  %i (idx %i): BBv# 0x%04x\n",fiber,numFLT,idx,temp_status_bbv2_1_16[0]);
                                BBStatusScheduler.appendData((char*)&BBStatusPayload,sizeof(TypeBBStatusBlock));

                                #if 1
                                //****************************************************
                                //*    BEGIN - OPERA status packet (deprecated)      *
                                //****************************************************
							    //TODO: buffer and send them all -tb-
								//printf("Send UDP Packet with BB status bits read from FLT# %i (BBv# 0x%04x). \n",numFLT,temp_status_bbv2_1_16[0]);
								for(i=0; i<_nb_mots_status_bbv2;i++){
									Trame_status_udp.status_bbv2_1[i] = temp_status_bbv2_1_16[i]; //expand 16 bit array to 32 bit array
									//dbg printf("%04x.",Trame_status_udp.status_bbv2_1[i] & 0xffff);
								}
			                    if(show_debug_info>=1)
								    printf("   Reading status bits of fiber %i  from FLT#  %i (idx %i): BBv# 0x%08x\n",fiber,numFLT,idx,Trame_status_udp.status_bbv2_1[0]);
								//dbg printf("\n");
							       //TODO: use old or new status packet format (currently: only old/Opera format) -tb-
							       //TODO: use old or new status packet format 
							       //TODO: use old or new status packet format 
								sendtoUDPClients(0,(&Trame_status_udp),sizeof(Trame_status_udp));
                                //****************************************************
                                //*    END - OPERA status packet (deprecated)      *
                                //****************************************************
                                #endif
							}
						}
					}
								
					  //send it  -  the last status will be sent, but use_static_udp_client is obsolete 2012-10 -tb-
					if(use_static_udp_client && send_status_udp_packet){
						numSent = sendtoClient((&Trame_status_udp),sizeof(Trame_status_udp));
						if(numSent != sizeof(Trame_status_udp)) printf("ERROR sendtoClient(): packet size %li, sent bytes %i\n",sizeof(Trame_status_udp),numSent);
					}
					//if(send_status_udp_packet) sendtoUDPClients(0,(&Trame_status_udp),sizeof(Trame_status_udp));
					
					//TODO: TEST: this sends a second UDP packet with a faked BB number -tb-
					//    printf("Change Trame_status_udp 0x%x ...\n",Trame_status_udp.status_bbv2_1[0]);
					//Trame_status_udp.status_bbv2_1[0]=0x214;
					//sendtoUDPClients(0,(&Trame_status_udp),sizeof(Trame_status_udp));

					//write UDP status packet to file
					//TODO: now I maybe send several status packets - move to for-fiber-loop above -tb-
					if(write2file && write2file_format == ascii){
						if(  globalHeaderWordCounter>0 && globalHeaderWordCounter < write2file_len_sec){
							if(pFile == NULL) openAsciiFile(udpdataSec,write2file_len_sec);//open file
							writeToAsciiFile((char*)(&Trame_status_udp),sizeof(Trame_status_udp),udpdataSec);
						}else
						if( pFile){//close file
							fclose(pFile);
							pFile = NULL;
							printf("STOP writing To Ascii File at sec: %i\n",udpdataSec);
							run_main_readout_loop = 0; //TODO: set flag to finish main loop - leave it? -tb-
						}
					}
				}//for(idx ...
                BBStatusScheduler.sendScheduledData();
				
			}//if(send_status_udp_packet ...
			
			
            #if 0   //remove it - legacy -tb-
            //now set flag/values for starting to scan status bits in next call of printf("mon_indice_status_bbv2 %i\n",mon_indice_status_bbv2)
			//  --> start reading the bits in 2., see below
			mon_indice_status_bbv2 = _nb_mots_status_bbv2 * 16 + 1  -2 + //from cew.c, is 57*16+1 = 913  // prepare pour la lecture du status bbv2 dans les trames (a ne faire qu'en mode BBv2 ou BB21)
                                     skip_num_status_bits;               //default: 911 (will start with first bit, cew.c default 913 will skip 2 bits/skip_num_status_bits=2)
            #endif

        }else{
            //go back to outer loop, we need to wait for more data from HW FIFO
            //TODO: this is a error as all pakets have a size multiple of 16 bytes -tb-    !!!!!!!!!!!!!!!!!!!
            printf("WARNING: FIFObuf32avail<4 - status packet may be corrupt!\n");
        }
    }
    //exit(23);
    
}












 /*--------------------------------------------------------------------
 *    function:     FIFOREADER::readFIFOtoFIFObuffer
 *    purpose:      scan data in FIFO buffer; search for header word; send UDP packets
 *    author:       Till Bergmann, 2011
 *
 *--------------------------------------------------------------------*/ //-tb-
void FIFOREADER::readFIFOtoFIFObuffer(void)
{
    uint32_t FIFOavail=0, FIFOMode=0, FIFOStatus=0, FIFOStatusTSPtr=0;
    
    // check FIFO size
    FIFOMode  =  pbus->read(FIFOModeReg(numfifo));
    FIFOavail = FIFOMode & 0x00ffffff;
    if(show_debug_info>1) printf("readFIFOtoFIFObuffer: read FIFOavail(FIFO #%i): %i (FIFOBlockSize is %i)\n",numfifo,FIFOavail,FIFOBlockSize);//DEBUG output -tb-
    
    //do it below ...if(FIFOavail < FIFOBlockSize) return; //wait for more data in FIFO
    
    //if buffer is 'too full', we must have lost several header words ->drop buffer in memory
    if( pushIndexFIFObuf32 > (FIFObuf32len/2) ){
        printf("readFIFOtoFIFObuffer: WARNING: danger of buffer memory overflow, clear buffer, pushIndexFIFObuf32 is  : %i  \n",pushIndexFIFObuf32);//DEBUG output -tb-
        popIndexFIFObuf32=0;
        pushIndexFIFObuf32=0;
        FIFObuf32avail=0;
    }
    
    //TODO: when FIFO full, we should reset it and restart? -tb-
    
    if(FIFOavail >= FIFOBlockSize){
	    FIFOStatus = pbus->read(FIFOStatusReg(numfifo));
		FIFOStatusTSPtr = (FIFOStatus >> 8) & 0xfffff;
		if(FIFOStatusTSPtr)
		         if(show_debug_info>=1) printf("   ***FIFOStatusTSPtr: %i ***\n",FIFOStatusTSPtr);//DEBUG output -tb-

        if(show_debug_info>2) printf("readFIFOtoFIFObuffer: read  block of FIFOBlockSize   %i, to pushIndexFIFObuf32 %i\n",FIFOBlockSize,pushIndexFIFObuf32);//DEBUG output -tb-
        #if 1
        //use DMA
        pbus->readBlock(FIFOAddr(numfifo), (unsigned long*)&FIFObuf32[pushIndexFIFObuf32], FIFOBlockSize);
		//TODO: change readBlock signature in fdhwlib !!!!! -tb-
		//TODO: change readBlock signature in fdhwlib !!!!! -tb-
		//TODO: change readBlock signature in fdhwlib !!!!! -tb-
		//TODO: change readBlock signature in fdhwlib !!!!! -tb-
        //pbus->readBlock(FIFOAddr(numfifo), (uint32_t*)&FIFObuf32[pushIndexFIFObuf32], FIFOBlockSize);
		//pseudo block mode
        //pbus->readBlock(FIFOAddr(numfifo) | 0x80000000, (unsigned long*)&FIFObuf32[pushIndexFIFObuf32], FIFOBlockSize);//pseudo block read 
        #else
        //use single access
        int i; 
        uint32_t val;
        for(i=0; i<FIFOBlockSize; i++){
            val = pbus->read(FIFOAddr(numfifo));
            FIFObuf32[pushIndexFIFObuf32 +i] = val;
        }
        #endif
        //exit(23);//TODO: DEBUGGING -tb-;
        pushIndexFIFObuf32 += FIFOBlockSize;
        FIFObuf32avail = pushIndexFIFObuf32 - popIndexFIFObuf32;
		FIFObuf32counter += FIFOBlockSize;
		
        //write raw/binary data to file (we have exactly FIFOBlockSize new words in buffer->write them to file)
        if(write2file && write2file_format == binary){
            if(pFile==NULL){
                  struct timeval currenttime;//    struct timezone tz; is obsolete ... -tb-
                  gettimeofday(&currenttime,NULL);
                  uint32_t currentSec = currenttime.tv_sec;  
                  printf("Open file: UTC sec is %i\n",currentSec);
                  openBinaryFile(currentSec, write2file_len_sec);
            }else{
                fwrite( &FIFObuf32[pushIndexFIFObuf32-FIFOBlockSize], sizeof(uint32_t), FIFOBlockSize, pFile);
            }
            if(globalHeaderWordCounter > write2file_len_sec) run_main_readout_loop = 0; //TODO: set flag to finish main loop - leave it? -tb-
        }

    }
    
    if(show_debug_info>1) printf("readFIFOtoFIFObuffer: after readFIFOtoFIFObuffer FIFObuf32avail: %i  \n",FIFObuf32avail);//DEBUG output -tb-

}

 /*--------------------------------------------------------------------
 *    function:     RunSomeHardwareTests
 *    purpose:      
 *    author:       Till Bergmann, 2012
 *
 *--------------------------------------------------------------------*/ //-tb-
void RunSomeHardwareTests()
{
	uint32_t version;
	int i;

	//1.
	//check version
    printf("\n");
    printf("check version\n");
    printf("----------------------------\n");
	version = pbus->read(SLTVersionReg);
    printf("FPGA version: 0x%08x\n",version);
    if((version >> 28) == 0x4){
        printf("  This is a EDELWEISS FPGA configuration!\n");
    }else{
        printf("  This is NOT EDELWEISS FPGA configuration! Terminating!\n");
        exit(2);
    }
    if(((version >> 16) & 0x0fff) >= 0x130){
        printf("  SLT supports single FIFO: OK\n");
    }else{
        printf("  SLT DOESNT supports single FIFO: ERROR\n");
        exit(2);
    }

	//2.
	//check more registers
    printf("\n");
    printf("check more registers\n");
    printf("----------------------------\n");
	uint32_t PAEOffset=0, PAFOffset;
	for(i=0;i<FIFOREADER::maxNumFIFO;i++)if(FIFOREADER::FifoReader[i].readfifo){
	    PAEOffset = pbus->read(PAEOffsetReg(i));
	    PAFOffset = pbus->read(PAFOffsetReg(i));
        printf("Fifo(%i): PAEOffset: 0x%08x, PAFOffset: 0x%08x\n", i,  PAEOffset, PAFOffset);
	}

}

 /*--------------------------------------------------------------------
 *    function:     InitFLTs
 *    purpose:      cold start of FLTs (=write stored settings to FLT registers)
 *                  (omit at warm start ... )
 *    author:       Till Bergmann, 2012
 *
 *--------------------------------------------------------------------*/ //-tb-

//TODO: remove debug output (or use debg level) -tb-

uint32_t InitFLTs()
{
    uint32_t retval = 0;
    int i;
    //begin-----INIT FLT SETTINGS---------------------------------------
	int fltID;

	for(int i=0; i<FLTSETTINGS::maxNumFLT; i++){
		//
		FLTSETTINGS &FLT = FLTSETTINGS::FLT[i];
	    if(! (presentFLTMap & bit[i])) continue;
	    //if(FLT.fiberEnable==0) continue;
	    fltID = FLT.fltID;
	    printf("Init FLT # %i (index %i)\n",fltID,i);
	    
        uint32_t FLTcontrol;
	    FLTcontrol =  pbus->read(FLTControlReg(fltID));
        printf("------FLTcontrol: 0x%08x\n",FLTcontrol);
        FLTcontrol = FLTcontrol & ~(kVetoFlagMask);  //disable veto flag
        FLTcontrol = FLTcontrol & ~(kFiberEnableMask);  //disable all fiber bits
        FLTcontrol = FLTcontrol & ~(kBBversionMask);  //disable all BBversion bits
        FLTcontrol = FLTcontrol & ~(kFLTModeMask);  //disable all mode bits
        FLTcontrol = FLTcontrol & ~(kFLTtpixMask);  //disable tpix bit
        FLTcontrol = FLTcontrol | (FLT.controlVetoFlag << 31) | (FLT.fiberEnable << 16) | (FLT.BBversionMask << 8)  | (FLT.mode << 4);
        pbus->write(FLTControlReg(fltID),FLTcontrol);
        //read back
	    FLTcontrol =  pbus->read(FLTControlReg(fltID));
        printf("------FLTcontrol: 0x%08x\n",FLTcontrol);



        uint32_t FLTStreamMask_1;
        uint32_t FLTStreamMask_2;
	    FLTStreamMask_1 =  pbus->read(FLTStreamMask_1Reg(fltID));
        printf("------FLTStreamMask_1: 0x%08x\n",FLTStreamMask_1);

	    FLTStreamMask_2 =  pbus->read(FLTStreamMask_2Reg(fltID));
        printf("------FLTStreamMask_2: 0x%08x\n",FLTStreamMask_2);
    
        FLTStreamMask_1= FLT.streamMask1;
        FLTStreamMask_2= FLT.streamMask2;;
        pbus->write(FLTStreamMask_1Reg(fltID),FLTStreamMask_1); // 0x0000003f);
        pbus->write(FLTStreamMask_2Reg(fltID),FLTStreamMask_2); // 0x00000000);
        //read back

	    FLTStreamMask_1 =  pbus->read(FLTStreamMask_1Reg(fltID));
        printf("------FLTStreamMask_1: 0x%08x\n",FLTStreamMask_1);

	    FLTStreamMask_2 =  pbus->read(FLTStreamMask_2Reg(fltID));
        printf("------FLTStreamMask_2: 0x%08x\n",FLTStreamMask_2);



        pbus->write(FLTFiberSet_1Reg(fltID),FLT.fiberSet1); 
        pbus->write(FLTFiberSet_2Reg(fltID),FLT.fiberSet2);  
        printf("------FLTFiberSet_1Reg: 0x%08x\n",pbus->read(FLTFiberSet_1Reg(fltID)));
        printf("------FLTFiberSet_2Reg: 0x%08x\n",pbus->read(FLTFiberSet_2Reg(fltID)));
        
        pbus->write(FLTTriggerMask_1Reg(fltID),FLT.triggerMask1); 
        pbus->write(FLTTriggerMask_2Reg(fltID),FLT.triggerMask2);  
        printf("------FLTTriggerMask_1Reg: 0x%08x\n",pbus->read(FLTTriggerMask_1Reg(fltID)));
        printf("------FLTTriggerMask_2Reg: 0x%08x\n",pbus->read(FLTTriggerMask_2Reg(fltID)));
        
	}
	
	return retval;
}


 /*--------------------------------------------------------------------
 *    function:     testFLTs
 *    purpose:      
 *    author:       Till Bergmann, 2012
 *
 *--------------------------------------------------------------------*/ //-tb-

//TODO: testFLTs - remove it? -tb-
void testFLTs()
{
    int i;
//FLT tests ----  FLT tests ----  FLT tests ----  FLT tests ----  FLT tests ----  
    int numFLT=4;//<----------------------numFLT
    #if 0
    uint32_t  reg=0;
	reg =  pbus->read(SLTVersionReg);
    printf("------val: 0x%08x\n",reg);
    
    
    uint32_t FLTversion;
	FLTversion =  pbus->read(FLTVersionReg(numFLT));
    printf("------FLTversion: 0x%08x\n",FLTversion);
    
    uint32_t FLTstatus;
	FLTstatus =  pbus->read(FLTStatusReg(numFLT));
    printf("------FLTstatus: 0x%08x\n",FLTstatus);
    
    int fiberEnable = 0x3f;
    //int kFiberEnableMask = 0x003f0000;
    uint32_t FLTcontrol;
	FLTcontrol =  pbus->read(FLTControlReg(numFLT));
    printf("------FLTcontrol: 0x%08x\n",FLTcontrol);
    FLTcontrol = FLTcontrol & ~(kFiberEnableMask);  //disable all fiber bits
    FLTcontrol = FLTcontrol | (fiberEnable << 16);
    
  //FLTcontrol = 0x02010000;//fiber 1, Normal
  //FLTcontrol = 0x02010020;//fiber 1, TM-Ramp
//FLTcontrol = 0x02000000   | (fiberEnable << 16);// 
    pbus->write(FLTControlReg(numFLT),FLTcontrol);
	FLTcontrol =  pbus->read(FLTControlReg(numFLT));
    printf("------FLTcontrol: 0x%08x\n",FLTcontrol);
    
    uint32_t FLTAccessTest;
	FLTAccessTest =  pbus->read(FLTAccessTestReg(numFLT));//default is 0x8080bbbb
    printf("------FLTAccessTest: 0x%08x\n",FLTAccessTest);
    pbus->write(FLTAccessTestReg(numFLT),FLTAccessTest+1);
	FLTAccessTest =  pbus->read(FLTAccessTestReg(numFLT));//default is 0x8080bbbb
    printf("------TEST: increased FLTAccessTest: 0x%08x\n",FLTAccessTest);
    
    
    uint32_t FLTStreamMask_1;
    uint32_t FLTStreamMask_2;
	FLTStreamMask_1 =  pbus->read(FLTStreamMask_1Reg(numFLT));
    printf("------FLTStreamMask_1: 0x%08x\n",FLTStreamMask_1);

	FLTStreamMask_2 =  pbus->read(FLTStreamMask_2Reg(numFLT));
    printf("------FLTStreamMask_2: 0x%08x\n",FLTStreamMask_2);
    
    pbus->write(FLTStreamMask_1Reg(numFLT),0x0000003f);
    pbus->write(FLTStreamMask_2Reg(numFLT),0x00000000);

	FLTStreamMask_1 =  pbus->read(FLTStreamMask_1Reg(numFLT));
    printf("------FLTStreamMask_1: 0x%08x\n",FLTStreamMask_1);

	FLTStreamMask_2 =  pbus->read(FLTStreamMask_2Reg(numFLT));
    printf("------FLTStreamMask_2: 0x%08x\n",FLTStreamMask_2);
    #endif

}


 /*--------------------------------------------------------------------
 *    function:     InitHardwareFIFOs
 *    purpose:      
 *    author:       Till Bergmann, 2012
 *
 *--------------------------------------------------------------------*/ //-tb-
void InitHardwareFIFOs()
{
    int i;
	
    //SLT registers
	uint32_t FIFO0Status;
	uint32_t FIFOMode;
    uint32_t SLTControl;
    uint32_t BB0csr;
    uint32_t SLTPixbusEnable;
	
	
	//0.
	// init/reset
	//read FIFO length
	for(i=0;i<FIFOREADER::maxNumFIFO;i++)
	    if(FIFOREADER::FifoReader[i].readfifo){
			FIFOMode =  pbus->read(FIFOModeReg(i));
			printf("FIFOMode(%i): 0x%08x (length %u)\n",i,FIFOMode, FIFOMode & 0x00ffffff);
		}
	
	//SLT control register
	SLTControl =  pbus->read(SLTControlReg);
	printf("SLTControl: 0x%08x (OnLine: %i)\n",SLTControl, (SLTControl & 0x4000)>>14);
	//switch to OffLine (test mode)
	if((SLTControl & 0x4000)>>14){
		SLTControl = SLTControl & ~(0x4000);
		pbus->write(SLTControlReg,SLTControl);
		//pbus->write(SLTControlReg,0x4000);
	}
	SLTControl =  pbus->read(SLTControlReg);
	printf("SLTControl: 0x%08x (OnLine: %i)\n",SLTControl, (SLTControl & 0x4000)>>14);
	
	//reset Pixbus Enable mask
	printf("SLTPixbusEnableReg: 0x%08x \n",pbus->read(SLTPixbusEnableReg));
	pbus->write(SLTPixbusEnableReg,0x0);
	printf("After reset: SLTPixbusEnableReg: 0x%08x \n",pbus->read(SLTPixbusEnableReg));
	
	//read FIFO length
	for(i=0;i<FIFOREADER::maxNumFIFO;i++)
	    if(FIFOREADER::FifoReader[i].readfifo){
			FIFOMode =  pbus->read(FIFOModeReg(i));
			printf("FIFOMode(%i): 0x%08x (length %u)\n",i,FIFOMode, FIFOMode & 0x00ffffff);
			//try to reset FIFO
			BB0csr =  pbus->read(BBcsrReg(i));
			printf("Reset FIFO:\n");
			printf("BBcsrReg(%i): 0x%08x (BBEn: %i)\n",i,BB0csr, (BB0csr & 0x2)>>1);
			//pbus->write(BBcsrReg(numfifo) ,BB0csr | 0x4 | 0x8);
			pbus->write(BBcsrReg(i) ,  0xc);  //reset flags
			usleep(10);
			//read FIFO length
			//test pbus->write(FIFOAddr(numfifo), 13);
			
			FIFOMode =  pbus->read(FIFOModeReg(i));
			printf("FIFOMode(%i): 0x%08x (length %u)\n",i,FIFOMode, FIFOMode & 0x00ffffff);
			
		}


    //begin-----INIT HARDWARE (SLT/FLT REGISTERS)---------------------------------------
    printf("\n");
    printf("INIT HARDWARE (SLT/FLT REGISTERS)\n");
    printf("---------------------------------\n");
    
	printf("SLT Control: set 'OnLine' to 1.\n");
	pbus->write(SLTControlReg, 0x4000);
			
	//SLT control register
	SLTControl =  pbus->read(SLTControlReg);
	printf("SLTControl: 0x%08x (OnLine: %i)\n",SLTControl, (SLTControl & 0x4000)>>14);
			
	for(i=0;i<FIFOREADER::maxNumFIFO;i++)
	    if(FIFOREADER::FifoReader[i].readfifo){
			//SLT csr register
			BB0csr =  pbus->read(BBcsrReg(i));
			printf("BBcsrReg(%i): 0x%08x (BBEn: %i)\n",i,BB0csr, (BB0csr & 0x2)>>1);
			//now enable BB
			printf("Send 'BBEn' flag.\n");
			pbus->write(BBcsrReg(i), 0x2);
			
			//FIFO status and mode
			FIFO0Status =  pbus->read(FIFOStatusReg(i));
			printf("FIFO0Status: 0x%08x\n",FIFO0Status);
			FIFOMode =  pbus->read(FIFOModeReg(i));
			printf("FIFOMode: 0x%08x (length %u)\n",FIFOMode, FIFOMode & 0x00ffffff);
			
		}
		
		
	//reset Pixbus Enable mask
	printf("SLTPixbusEnableReg: 0x%08x \n",pbus->read(SLTPixbusEnableReg));
	pbus->write(SLTPixbusEnableReg,0x0);
	printf("After reset: SLTPixbusEnableReg: 0x%08x \n",pbus->read(SLTPixbusEnableReg));
	
	
	// set Pixbus Enable mask
    SLTSETTINGS &slt = *SLTSETTINGS::SLT;
	//SLTPixbusEnable=pbus->read(SLTPixbusEnableReg);
	SLTPixbusEnable = slt.PixbusEnable;
	pbus->write(SLTPixbusEnableReg,SLTPixbusEnable);
	printf("Set SLTPixbusEnableReg to: 0x%08x \n",pbus->read(SLTPixbusEnableReg));

    //end-----INIT HARDWARE (SLT/FLT REGISTERS)---------------------------------------
	
}


/*--------------------------------------------------------------------
  printUsage:
  --------------------------------------------------------------------*/
void printUsage(char *argv[]){
		printf("Usage:   %s  \n",argv[0]);
		printf("      '%s [<config_filename>]' start %s and init with given config file \n",argv[0],argv[0]);
		printf("      '%s' start with default config file %s.config\n",argv[0],argv[0]);
		printf("      '%s h' show this help text\n",argv[0]);
		printf("      '%s n' start without config file\n",argv[0]);
}


/*--------------------------------------------------------------------
  main:
  --------------------------------------------------------------------*/
int32_t main(int32_t argc, char *argv[])
{
    int32_t i;
    int iFifo;
	
    #define MY_UDP_LISTEN_MAX_PACKET_SIZE   1500
    char InBuffer[MY_UDP_LISTEN_MAX_PACKET_SIZE];	// took buffer size from CEW_controle,but char instead of unsigned char -tb-
    unsigned char UInBuffer[MY_UDP_LISTEN_MAX_PACKET_SIZE];	// took buffer size from CEW_controle,but char instead of unsigned char -tb-


    printf("KIT-IPE EDELWEISS stream loop\n");
    printf("=============================\n");
    


    //----------------------------------------------------------- 
    //pre run checks
    printf("Running pre run checks ...\n");
    if(runPreRunChecks() != 0){
        printf("==========  Pre run checks failed!  ============\n");
        exit(123);
    }
    //check sizeof long 
      //TODO: move to preRunChecks -tb-
    printf("Must be equal:  sizeof(unsigned long) is %i, sizeof(uint32_t) is %i\n", sizeof(unsigned long), sizeof(uint32_t));
    if(sizeof(unsigned long) != sizeof(uint32_t)){
        printf("WARNING: sizeof(unsigned long) not equal to sizeof(uint32_t), this software should work correctly, but fdhwlib needs redesign ... \n");
        //exit(666);
		usleep(700000);
    }
    //----------------------------------------------------------- 



    


	//init buffers etc.
	FIFOREADER::initFIFOREADERList();
	
	//init SLT settings 
	SLTSETTINGS::initSLTSETTINGS();
    
	//init SLT settings 
	FLTSETTINGS::initFLTSETTINGSList();
    
    




    //TODO move to function -tb-
    //----------------------------------------------------------- 
    //init buffers,flt settings class etc. before!-tb-
    printf("-----------------load config file  -----------------\n");
    
	char defaultconfigfilename[]="ipe4ewstreamer.config";  // <------------------change this to your default filename!!!
	char configfilename[2*4096+10];
	
    //handle command line options
	if(argc>2){
		printf("ERROR: %s expects 0 or 1 argument!\n",argv[0]);
		printUsage(argv);
		exit(1);
	}
	if(argc==1){
	    strncpy(configfilename, basename(argv[0]), 2*4096);//default is: executable name +".config"
		strcat(configfilename,".config");
		printf("%s: no config file specified, using default config file '%s'\n",argv[0],configfilename);
		//sprintf(configfilename,"%s",defaultconfigfilename);
	    //sec_arg = atoi(argv[1]);
		//printf("Commandline argument #1: %i\n",sec_arg);
	} 
    
	if(argc==2){
	    if(argv[1][0]=='h'){
	    	printUsage(argv);
		    exit(1);
        }
        else
	    if(argv[1][0]=='n'){ //start without config file
		    printf("%s: start without config file\n",argv[0]);
		    configfilename[0]=0;
        }
        else
        {
		    printf("%s: using config file '%s'\n",argv[0],argv[1]);
		    sprintf(configfilename,"%s",argv[1]);
		}
	}
		if(configfilename[0] != 0){
		if(readConfigFile(configfilename) != 0){
		   perror ("ERROR: Could NOT read config file!\n");
		   perror ("ERROR: Could NOT read config file!\n");
		   perror ("ERROR: Could NOT read config file!\n");
		   printf("Try to load default config file '%s'!\n",defaultconfigfilename);
		   if(readConfigFile(defaultconfigfilename) != 0){
			   perror ("ERROR: Could NOT read default config file!\n");
			   return 1;
		   }
		}else{
			// take over config file arguments
			//   -> is already done in readConfigFile(.)
		}
	}
    //----------------------------------------------------------- 
	



	    
    //----------------------------------------------------------- 
    printf("-----------------INIT PBus  ----------------------\n");
    InitSLTPbus();  //initialize PBus
    


    
    
    
    //begin-----INIT Crate K Command UDP COMMUNICATION---------------------------------------
    printf("-----------------INIT K command sockets   --------\n");
    initKCommandSockets();
    //end-------INIT Crate K Command UDP COMMUNICATION---------------------------------------
    
    //----------------------------------------------------------- 



    //--------- State machine:  go to idle state  ------------------ 
    //as we are now able to listen for K commands 
    FIFOREADER::State =  frIDLE;
    //-------------------------------------------------------------- 
    



    //start timer -------TIMER------------
    struct timeval starttime, stoptime, currtime;//    struct timezone tz; is obsolete ... -tb-
    struct timezone	timeZone;
	double currDiffTime=0.0, lastDiffTime=0.0;
    //timing
    //gettimeofday(&starttime,NULL);
    gettimeofday(&starttime,&timeZone);
    //start timer -------TIMER------------







    
    
    
    
    //----------------------------------------------------------- 
    printf("----------- load legacy status packet  ------------ \n");
   
    //----------------------------------------------------------- 
    // for debugging: load recorded UDP packets
    //----------------------------------------------------------- 
    //printf("-----------------read recorded UDP packets ----------------------\n");
    
	/*made global to be used in scanFIFObuffer(.)
	int buflen=30000;
	char buf_status284[buflen];
	int buf_status284_len=0;
	*/
	char buf_adc1444[buflen];
	int buf_adc1444_len=0;
	char buf_adc484[buflen];
	int buf_adc484_len=0;
	
    
    //prepare simulation mode (we can simulate BB21 and BB2 mode)
	int num_udp1444_packets = 0;//BB2: 0x341 = 833; BB21: 0x22b = 555
    #if 1
	//this is BB21 mode:
	//read status byte block
	num_udp1444_packets = 0x22b;//0x341 = 833; BB21: 0x22b = 555
	buf_status284_len = readFileToBuf("bb21-udp284.txt",buf_status284,buflen);
		//printf ("Total number of bytes: buf_status284_len %i\n", buf_status284_len);
	//read adc date byte block
	buf_adc1444_len = readFileToBuf("bb21-udp1444-1.txt",buf_adc1444,buflen);
		//printf ("Total number of bytes: buf_adc1444_len %i\n", buf_adc1444_len);
	//read short adc date byte block
	buf_adc484_len = readFileToBuf("bb21-udp804-022b.txt",buf_adc484,buflen);
		//printf ("Total number of bytes: buf_adc484_len %i\n", buf_adc484_len);
    #else
	//this is BB2 mode:
	num_udp1444_packets = 0x341;//0x341 = 833; BB21: 0x22b = 555
	buf_status284_len = readFileToBuf("udp284.txt",buf_status284,buflen);
		//printf ("Total number of bytes: buf_status284_len %i\n", buf_status284_len);
	//read adc date byte block
	buf_adc1444_len = readFileToBuf("udp1444-0-13f3.txt",buf_adc1444,buflen);
		//printf ("Total number of bytes: buf_adc1444_len %i\n", buf_adc1444_len);
	//read short adc date byte block
	buf_adc484_len = readFileToBuf("udp484-0341.txt",buf_adc484,buflen);
		//printf ("Total number of bytes: buf_adc484_len %i\n", buf_adc484_len);
	#endif
    if(buf_status284_len==0 || buf_adc1444_len==0 || buf_adc484_len==0)
        printf("WARNING: readFileToBuf: read 0 bytes!!!\n");
    //now we have a prev. recorded UDP status packet in buf_status284 (of len buf_status284_len)
    printf("----------- load legacy status packet  - DONE ----- \n");
    //----------------------------------------------------------- 







    //----------------------------------------------------------- 
    printf("-----------------INIT hardware  ----------------------\n");



    //=======================   FLT  ==============================
//TODO: EDITING: FLT_INIT <----------  this is a mark for editing

    //begin-----INIT FLT SETTINGS---------------------------------------
	printf("----------------- Init FLTs--------------------\n");
	InitFLTs();
    //end-----INIT FLT SETTINGS---------------------------------------








    //----------------------------------------------------------- 
    printf("-----------------BASIC SETTINGS for run loop (SLT+FLTs)----------------------\n");



    //----------------------------------------------------------- 


    //begin-------TEST HARDWARE CONFIGURATION---------------------------------------

    //check and init hardware
	RunSomeHardwareTests();
    InitHardwareFIFOs();

    //SLT registers
	uint32_t FIFO0Status;
	uint32_t FIFOMode;
    uint32_t SLTControl;
    uint32_t BB0csr;
    uint32_t OperaStatus0;
    uint32_t OperaStatus1;


	// vars
    uint32_t val=0, rval=0;
    int num_diff=0;
    num_diff=0;

	//talk with hardware


	//Legacy Opera  status  
	//--------------------
	FIFOREADER *fr = FIFOREADER::FifoReader;
	#if 1 //we init the Trame_status_udp with prev. recorded UDP status packet in buf_status284 (of len buf_status284_len)
        //TODO: fake Opera status
	for(iFifo=0; iFifo<FIFOREADER::maxNumFIFO; iFifo++){

        for(i=0; i< buf_status284_len; i++){
            ((char*)(  &FIFOREADER::FifoReader[iFifo].Trame_status_udp ))[i] = buf_status284[i];
        }
	}
    #endif
    OperaStatus0 =  pbus->read(OperaStatusReg0);
    printf("OperaStatusReg0: 0x%08x\n",OperaStatus0);
	for(iFifo=0; iFifo<FIFOREADER::maxNumFIFO; iFifo++){
		FIFOREADER &fr = FIFOREADER::FifoReader[iFifo];
		if(fr.readfifo){
		    printf(" FIFO %i set status:\n",iFifo);
			fr.Trame_status_udp.status_opera.code_acqui       = OperaStatus0       & 0xff;
			//fr.Trame_status_udp.status_opera.code_acqui       = 3       & 0xff;
			fr.Trame_status_udp.status_opera.masque_BB        = (OperaStatus0>> 8) & 0xff;
			fr.Trame_status_udp.status_opera.code_synchro     = (OperaStatus0>>16) & 0xff;
			fr.Trame_status_udp.status_opera.registre_retard  = (OperaStatus0>>24) & 0xff;
			fr.Trame_status_udp.status_opera.version_cew      = VERSION_IPE4READOUT;
			switch( fr.Trame_status_udp.status_opera.code_acqui ){
				case 0: printf("   OperaStatus code acqi %i: test mode\n",fr.Trame_status_udp.status_opera.code_acqui); break;
				case 3: printf("   OperaStatus code acqi %i: BBv21\n",fr.Trame_status_udp.status_opera.code_acqui); break;
				case 8: printf("   OperaStatus code acqi %i: BB2\n",fr.Trame_status_udp.status_opera.code_acqui); break;
				default: printf("   OperaStatus code acqi %i: unsupported\n", fr.Trame_status_udp.status_opera.code_acqui); break;
			}
			OperaStatus1 =  pbus->read(OperaStatusReg1);
			fr.Trame_status_udp.status_opera.registre_x       =  OperaStatus1      & 0xfff;
			fr.Trame_status_udp.status_opera.version_cew      = VERSION_IPE4READOUT;
		}
	}
   

    
    

    printf("END OF HW TEST\n");
    printf("\n");
    //end-------TEST HARDWARE CONFIGURATION---------------------------------------




    //begin-----INIT FIFO UDP COMMUNICATION---------------------------------------
    FIFOREADER::initAllUDPServerSockets();
    #if 0
	for(iFifo=0; iFifo<FIFOREADER::maxNumFIFO; iFifo++) if(FIFOREADER::FifoReader[iFifo].readfifo){
		FIFOREADER &fr=FIFOREADER::FifoReader[iFifo];
		
		
		#if 0
		//TODO: initUDPClientSocket --->  DEPRECATED!!! -tb-
		//init static UDP client socket (DEPRECATED)
		if(use_static_udp_client){
            if(fr.initUDPClientSocket() != 0){
			    printf("ERROR: initUDPClientSocket() for FIFO %i failed!\n", iFifo);
			    exit(1);
		    }else printf("OK: initUDPClientSocket() for FIFO %i \n", iFifo);
		}
		#endif
		
		//init UDP server socket
		if(fr.initUDPServerSocket() != 0){
			printf("ERROR: initUDPServerSocket() for FIFO %i failed!\n", iFifo);
			exit(1);
		}else printf("OK: initUDPServerSocket() for FIFO %i\n", iFifo);
	}
	#endif
    //end-------INIT FIFO UDP COMMUNICATION---------------------------------------










    //--------- State machine:  go to initialized state  ------------------ 
    //as we are now able to listen for K commands 
    FIFOREADER::State =  frINITIALIZED;
    //-------------------------------------------------------------- 
    

    //--------- State machine:  go to streaming state  ------------------ 
    //as we are now able to listen for K commands 
    FIFOREADER::State =  frSTREAMING;
    //-------------------------------------------------------------- 
    





//TESTING:
    //now request a test pattern
    //  printf("Send 'Request test pattern' command.\n");
	//  pbus->write(SLTCommandReg, 0x80);usleep(100);

    //BEGIN-------MAIN READOUT LOOP-----------------------------------------------
    //----------------------------------------------------------------------------
    //TODO: MAIN LOOP
    printf("STARTING MAIN READOUT LOOP\n");
    printf("--------------------------\n");
    int continueLoop=1;// continueLoop is local flag,  run_main_readout_loop  is global flag (may be set to 0 from any function)

    FIFOREADER	* FifoReader = FIFOREADER::FifoReader;
    
    while(continueLoop){
        
        //if in streaming state
        //-----------------------
        if(FIFOREADER::State == frSTREAMING){
			for(iFifo=0; iFifo<FIFOREADER::maxNumFIFO; iFifo++) if(FIFOREADER::FifoReader[iFifo].readfifo){
				//check FIFObuf
				if(show_debug_info>1) printf("main: FIFObuf32avail(%i): %i\n",iFifo, FifoReader[iFifo].FIFObuf32avail);//DEBUG output -tb-
				#if 1
				//scan and read UDP packets in while loop until buffer empty
				while(FifoReader[iFifo].FIFObuf32avail >= 360 ){
					FifoReader[iFifo].scanFIFObuffer();
				}
				#else
				//scan and send *one* UDP packet
				FifoReader[iFifo].scanFIFObuffer();//sends a UDP data packet if enough data available
				#endif
				
				#if 0
				//TODO: for tests REMOVE IT LATER  -tb-
				else{
					printf("Send 'Request test pattern' command.\n");
					pbus->write(SLTCommandReg, 0x80);usleep(1);
				}
				#endif
				
				//read data from SLT FIFOs
				FifoReader[iFifo].readFIFOtoFIFObuffer();
			}// end of for(iFifo=0
        }
        
        
        //TIMER - do something every second:
        //-----------------------
		//gettimeofday(&starttime,NULL);
        gettimeofday(&currtime,&timeZone);
        currDiffTime =      (  (double)(currtime.tv_sec  - starttime.tv_sec)  ) +
                    ( ((double)(currtime.tv_usec - starttime.tv_usec)) * 0.000001 );
        double elapsedTime = currDiffTime - lastDiffTime;
		if(elapsedTime >= 1.0){
		    //code to be executed every second -BEGIN
		    //
		    // 1.
		    //./
	        for(iFifo=0; iFifo<FIFOREADER::maxNumFIFO; iFifo++) if(FIFOREADER::FifoReader[iFifo].readfifo){
			    //check FIFObuf
			   if(show_debug_info>1) printf("main: FIFObuf32avail(%i): %i\n",iFifo, FifoReader[iFifo].FIFObuf32avail);//DEBUG output -tb-
			   
			   if(currDiffTime!=0.0)printf("Average datarate FIFO %i: %9.3g KB/sec; ",FifoReader[iFifo].numfifo, (FifoReader[iFifo].FIFObuf32counter*0.004)/currDiffTime);
			   printf("current rate: %9.3g KB/sec; ", ((FifoReader[iFifo].FIFObuf32counter-FifoReader[iFifo].FIFObuf32counterlast)*0.004)/elapsedTime);//elapsedTime is larger 0.0
			   printf(" (%lli word32s in %g seconds) ",FifoReader[iFifo].FIFObuf32counter,currDiffTime);
			   printf("\n");
               FifoReader[iFifo].FIFObuf32counterlast = FifoReader[iFifo].FIFObuf32counter;
			}
			
			//
			// 2.
			//
			//TODO: for DEBUGGING - might be removed any time -tb-
	        //if in streaming state
            if(FIFOREADER::State == frSTREAMING){
				for(iFifo=0; iFifo<FIFOREADER::maxNumFIFO; iFifo++){
					if(FifoReader[iFifo].readfifo){
						uint32_t FIFOMode =  pbus->read(FIFOModeReg(iFifo));
						printf("    FIFOMode%i: 0x%08x (length %u)\n",iFifo, FIFOMode, FIFOMode & 0x00ffffff);
					}
				}
				//TODO: this was for debugging the status bit FIFOs - remove it -tb-
				if(0){ //moved to 'scanFIFOBuffer ... -tb-
					int numFLT=4;//<----------------------numFLT
					printf("Status bits read from FLT:\n");
					int i;
					uint32_t status;
					uint16_t *status16 = (uint16_t *)(&status);
					int numChan =0;
					for(i=0; i<32; i++){
						status = pbus->read(FLTBBStatusReg(numFLT, numChan)+i);
						temp_status_bbv2_1[i]=status;
						printf("0x%08x ",status);
						printf("%04x.%04x.",status16[0],status16[1]);
					}
					printf("\n");
				}
				if(0){
					//FIFO status and mode of FIFO 0
					uint32_t FIFO0Status =  pbus->read(FIFOStatusReg(0));
					printf("FIFO0Status: 0x%08x\n",FIFO0Status);
					uint32_t FIFOMode =  pbus->read(FIFOModeReg(0));
					printf("FIFOMode: 0x%08x (length %u)\n",FIFOMode, FIFOMode & 0x00ffffff);
	
				}
	        }
		    //code to be executed every second -END
		    lastDiffTime = currDiffTime;
		}
		
		
        //other jobs during loop:
        //-----------------------
        //listen for UDP packets (K commands) on global server socket
        {
			int numRead=0;
			while( (   numRead = recvfromGlobalServer(InBuffer,sizeof(InBuffer)) ) >0 ){
				fprintf(stderr,"main: recvfromGlobalServer(...), received UDP command packet (%i bytes)\n", numRead );
				fprintf(stderr,"------------------------------------------------------------ (%i bytes)\n", numRead );
				fprintf(stderr,"------------------------------------------------------------ (%i bytes)\n", numRead );
				fprintf(stderr,"------------------------------------------------------------ (%i bytes)\n", numRead );
				fprintf(stderr,"------------------------------------------------------------ (%i bytes)\n", numRead );
				fprintf(stderr,"------------------------------------------------------------ (%i bytes)\n", numRead );
				fprintf(stderr,"------------------------------------------------------------ (%i bytes)\n", numRead );
				fprintf(stderr,"------------------------------------------------------------ (%i bytes)\n", numRead );
				//handleUDPCommandPacket(InBuffer, numRead, iFifo);
				if(goToState != frUNDEF){
				    //there was a state change request, leave loop as we cannot buffer commands and
				    //the state change will be performed below/outside this loop -tb-
				    break;
				}
			}
        }
        //listen for UDP packets (commands) on server socket
	    for(iFifo=0; iFifo<FIFOREADER::maxNumFIFO; iFifo++) if(FIFOREADER::FifoReader[iFifo].readfifo){
		    FIFOREADER &fr=FIFOREADER::FifoReader[iFifo];
			int numRead=0;
			while( (   numRead = fr.recvfromServer(UInBuffer,sizeof(UInBuffer)) ) >0 ){
				fprintf(stderr,"main: recvfromServer(...), received UDP command packet (%i bytes)\n", numRead );
				handleUDPCommandPacket(UInBuffer, numRead, iFifo);
			}
			//TODO: DEBUG fprintf(stderr,"CALLED: recvfromServer(...), received no data (%i bytes)\n", numRead );
        }


        //check for requests to change the state (from K command)
        //-----------------------
        if(goToState != frUNDEF){
            //DEBUG fprintf(stderr,"-------------requested state change!!!---- -- (%i , FIFOREADER::State %i)\n", goToState ,FIFOREADER::State);
            if(goToState == frIDLE){//reset command
                if(FIFOREADER::State == frINITIALIZED){
                    //TODO: send a reply (UDP packet)? better: let ask for current state -tb- 
                    printf("ERROR: Requested IDLE state from init state!\n");
                    //reset sockets
                    FIFOREADER::endAllUDPClientSockets();
                    FIFOREADER::endAllUDPServerSockets();
                    //stop hardware
                    //TODO under construction -tb-
                    //TODO under construction -tb-
                    //TODO under construction -tb-
                    //TODO under construction -tb-
                    
                    
                    FIFOREADER::State = frIDLE;
                }
                if(FIFOREADER::State == frSTREAMING){
                    //TODO: send a reply (UDP packet)? better: let ask for current state -tb- 
                    printf("ERROR: Requested IDLE state while in streaming state! Stop stream mode first!\n");		    
                }
            }
            if(goToState == frINITIALIZED){
                if(FIFOREADER::State == frIDLE){//start streaming command (startStreamLoop)
                    FIFOREADER::initAllUDPServerSockets();
                    //TODO: under construction -tb-
                    //TODO: what else to initialize? -tb-
                    //start hardware
                    //...
                    FIFOREADER::State = frINITIALIZED;
                }
                if(FIFOREADER::State == frSTREAMING){//stop streaming command (stopStreamLoop)
                    FIFOREADER::State = frINITIALIZED;
                }
            }
            if(goToState == frSTREAMING){
                if(FIFOREADER::State == frINITIALIZED){//start streaming command (startStreamLoop)
                    FIFOREADER::State = frSTREAMING;
                    //TODO: clear buffers + FIFOs? -tb-
                }
                if(FIFOREADER::State == frIDLE){//start streaming command (coldStart command)
                    //TODO: cold start -tb-
                    FIFOREADER::initAllUDPServerSockets();
                    //TODO: under construction -tb-
                    //TODO: what else to initialize? -tb-
                    //start hardware
                    FIFOREADER::State = frSTREAMING;
                }
            }
            
            goToState = frUNDEF;
        }
		
		
        //quit main loop when key pressed
        //-----------------------
		if(kbhit()){
		    int key = getchar();
		    continueLoop=0;
            printf("You pressed %i = '%c'!\n", key, key);		    
            if(kbhit()){key = getchar();printf("2 You pressed %i = '%c'!\n", key, key);	}	    
		}
    
    
        //read from config file (->run loop only once) or set from 'file writer' (->end writing after x seconds -> end loop)
        if(run_main_readout_loop==0) continueLoop=0;
        //usleep(10000);
        
        
        
    }//end of while-loop
    printf("STOPPED MAIN READOUT LOOP\n");
    //END---------MAIN READOUT LOOP-----------------------------------------------


    //stop timer -------TIMER------------
    gettimeofday(&stoptime,NULL);
    double diffTime;
    diffTime =      (  (double)(stoptime.tv_sec  - starttime.tv_sec)  ) +
                    ( ((double)(stoptime.tv_usec - starttime.tv_usec)) * 0.000001 );
    //printf("Timer: starttime: %i   ,  %i\n", (int)starttime.tv_sec ,(int)starttime.tv_usec);
    //printf("Timer: stoptime:  %i   ,  %i\n", (int)stoptime.tv_sec  ,(int)stoptime.tv_usec);
    //printf("Timer: diff usec:  %i  \n", (int)(stoptime.tv_usec -starttime.tv_usec));
    //printf("Timer: diff usec:  %g  \n", (double)(stoptime.tv_usec -starttime.tv_usec));
    printf("Run time of this run was %12.8g seconds.\n",diffTime);
    //stop timer -------TIMER------------



        
        
        
        printf(" ...\n");


        //------here take data from crate--- END
    printf("-----------------stop----------------------\n");
    //========================================================================================
    
    
    ReleaseSLTPbus();// = pbusFree();          TODO: dont use libpbusaccess ... -tb-
    
    
    //TODO: RELEASE ALL SOCKETS -tb-
    
    
    //begin-----end Crate K Command UDP COMMUNICATION---------------------------------------
    printf("-----------------END K command sockets   --------\n");
    endKCommandSockets();
    //end-------end Crate K Command UDP COMMUNICATION---------------------------------------
    
    return 0;
}
