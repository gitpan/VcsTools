# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..4\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk ;
use Tk::ObjScanner ;
use ExtUtils::testlib;
use VcsTools::DataSpec::HpTnd;
require Tk::ErrorDialog; 
my $idx = 1;
print "ok ",$idx++,"\n";
$loaded = 1;

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

package main ;

use Tk::Multi::Manager ;
use Tk::ROText ;

use strict ;

my $mw = MainWindow-> new ;

my $w_menu = $mw->Frame(-relief => 'raised', -borderwidth => 2);
$w_menu->pack(-fill => 'x');

my $f = $w_menu->Menubutton(-text => 'File', -underline => 0) 
  -> pack(side => 'left' );

$mw->Label(text => 'double click on "info" in the object scanner')->pack;
my $t = $mw->Scrolled(qw/ROText wrap none/) ->pack ;

my $ds = new VcsTools::DataSpec::HpTnd ;

print "ok ",$idx++,"\n";

my @log = <DATA>;
my $info = $ds->analyseLog(\@log) ;

print "ok ",$idx++,"\n";

my $scan = $mw->Toplevel->ObjScanner('caller' => $ds )->pack;

$f->command(-label => 'Pile',  -command => sub
            {
              $t -> delete('1.0','end');
              my $str = $ds->buildLogString
                (
                 $ds->pileLog('pile test',
                              [
                               ['3.10', $info->{'3.10'}],
                               ['3.11', $info->{'3.11'}],
                               ['3.12', $info->{'3.12'}],
                               ['3.13', $info->{'3.13'}],
                              ]
                             )
                );
              $t->insert('end',$str);
            } 
           );

$f->command(-label => 'Quit',  -command => sub{$mw->destroy;} );

MainLoop ; # Tk's

print "ok ",$idx++,"\n";

__DATA__

file:  /7UP/code/tcap/FileRevList
type:  RCS
head: 5.0
symbolic names:
keyword substitution: kv
total revisions: 91;	selected revisions: 91
description:
----------------------------
revision 5.0
date: 1998/03/04 17:04:22;  author: rgachet;  state: Exp;  lines: +2 -2
Author: rgachet
bugs fixed :

 - GREhp12347   :  Prepare source module for NT
----------------------------
revision 4.15
date: 1998/02/11 11:40:54;  author: pierres;  state: Exp;  lines: +5 -2
Author: pierres
bugs fixed :

 - GREhp12347   :  Prepare source module for NT
----------------------------
revision 4.14
date: 1998/02/06 14:24:09;  author: herve;  state: Exp;  lines: +2 -2
Author: herve
bugs fixed :

 - GREhp12065   :  HPSS7 stack killed when application sends a SCCP_N_COORD primitive
----------------------------
revision 4.13
date: 1998/01/22 15:13:49;  author: herve;  state: Exp;  lines: +2 -2
Author: herve
bugs fixed :

 - GREhp12262   :  TCAP cannot connect to GDI stack.
----------------------------
revision 4.12
date: 1998/01/13 14:58:20;  author: cilou;  state: Exp;  lines: +1 -1
Author: cilou
bugs fixed :

 - GREhp12216   :  Incomplete NOTICE-Indication not accepted by Tcap layer

   In TmgrIncomingNoticeSccp, don't abort the transaction on decoding
   error when transaction id has been recognized.
----------------------------
revision 4.11
date: 1998/01/08 10:26:02;  author: herve;  state: Exp;  lines: +1 -1
Author: herve
bugs fixed :

 - GREhp12157   :  Slee cannot anylonger handle traffic even if platform is active/hot
----------------------------
revision 4.10
date: 1998/01/06 15:02:38;  author: cilou;  state: Exp;  lines: +1 -1
Author: cilou
bugs fixed :
 none

   Trace enhancement
----------------------------
revision 4.9
date: 1997/12/11 11:46:05;  author: domi;  state: Exp;  lines: +3 -3
Author: domi
bugs fixed :
 none

   - also include TCAP_ext.h instead of TCAP_ext_ansi.h or TCAP_ext_ccitt.h
   This time in CCITT version as well...
----------------------------
revision 4.8
date: 1997/12/09 17:24:00;  author: domi;  state: Exp;  lines: +3 -3
Author: domi
fix: GREhp12024
From MsgTransaction_ANSI.m v4.2:
- include TCAP_ext.h instead of TCAP_ext_ansi.h or TCAP_ext_ccitt.h
----------------------------
revision 4.7
date: 1997/11/06 15:57:04;  author: cilou;  state: Exp;  lines: +10 -10
Author: cilou
bugs fixed :
 none

   As 'class' is a reserved C++ keyword, the 'class' field of sccp structures
   SC_UNITDATA_PARMS and sccp_xunitdata_parms have been renamed
   Suppress private comments
----------------------------
revision 4.6
date: 1997/11/04 10:32:54;  author: cilou;  state: Exp;  lines: +1 -1
branches:  4.6.1;
Author: cilou
bugs fixed :
 none

   Constant SCCP_OLD_MODE was renamed in SCCP_REGULAR_MODE in sccpTypes.h
----------------------------
revision 4.5
date: 1997/10/29 17:22:30;  author: herve;  state: Exp;  lines: +1 -1
Author: herve
bugs fixed :
 none

   remove #ifdef GDI_BUILD. GDI is part of MARS release
----------------------------
revision 4.4
date: 1997/10/28 11:57:49;  author: herve;  state: Exp;  lines: +1 -1
Author: herve
bugs fixed :
 none

   previous version doesn't compile in ANSI
----------------------------
revision 4.3
date: 1997/10/28 09:52:15;  author: herve;  state: Exp;  lines: +5 -2
Author: herve
bugs fixed :
 none

   Now, tcapIncludes module is no longer needed.
   All the code specific to the tcap API is located in this module and in
   tcapExtLibs for the extended API.
   The Encoding/Decoding of the component layer is located in MsgComponent files.
   The common code to Stack and tcap API is now only located in tcapEnvironment
   module.
   This module is linked to tcapEnvironment 4.1 (at least)
   tcapLibs        4.2 (at least)
----------------------------
revision 4.2
date: 1997/10/23 15:40:41;  author: herve;  state: Exp;  lines: +4 -4
Author: herve
bugs fixed :
 none

   add serviceDef.h inclusion
----------------------------
revision 4.1
date: 1997/10/20 17:07:53;  author: herve;  state: Exp;  lines: +7 -7
Author: herve
bugs fixed :
 none

   merge sys.tcap and sys.tcap.gdi
----------------------------
revision 4.0
date: 1997/10/14 16:42:34;  author: herve;  state: Exp;  lines: +25 -22
Author: herve
Use TimerLib instead of TcapTimers
FOR MARS RELEASE ONLY
----------------------------
revision 3.19
date: 1997/09/26 15:46:25;  author: domi;  state: Exp;  lines: +3 -3
Author: domi
fix: default_class
From SccpAP.m v3.6:
- in SendToNet: set sccp class parameter when using default values
----------------------------
revision 3.18
date: 1997/09/25 11:09:06;  author: herve;  state: Exp;  lines: +4 -5
Author: herve
merged from: 3.4.1.6
writer: herve
keywords: SS7
fix: GREhp11677
bugs fixed :

 - GREhp11677   :  SS7 stack memory leak when TCAP transaction failed leads to a core dump
----------------------------
revision 3.17
date: 1997/09/23 16:13:47;  author: cilou;  state: Exp;  lines: +2 -1
Author: domi
writer: cilou
keywords: bug_fix
fix:
bugs fixed :
 none

   In SccpAP, fill sccp_use_extended_data field of tcx_sccp_service_quality
   structure. Even if this information should be reserved for LNP applications
   and is only significant for UNITDATA request, it gives the information if
   data has been received within UDT or XUDT and it prevents to display
   incoherent value if application wants to trace this structure.
----------------------------
revision 3.16
date: 1997/09/16 13:23:42;  author: cilou;  state: Exp;  lines: +1 -1
Author: cilou
writer: cilou
keywords: qualityParm
bugs fixed :
 none

   In sendToNet, don't use qualityParm input parameter to fill
   UNITDATA Request parameters as the qualityParm structure does
   not contain the application parameters. Get all tcx_sccp_service_quality
   parameters from TCAPMessage
----------------------------
revision 3.15
date: 1997/07/22 14:27:00;  author: herve;  state: Exp;  lines: +1 -1
Author: herve
bugs fixed :

 - GREhp11165   :  itmi Q787:A412, A422, TA4226, TA4228 failed: transaction with XX_W_PERM refused
 - GREhp10825   :  Pb when sending a TC_END after receiving a TC_BEGIN without setting orig addr.
----------------------------
revision 3.14
date: 1997/07/17 11:27:13;  author: cilou;  state: Exp;  lines: +10 -10
Author: domi
writer: cilou
keywords: fast_track, SCCP-WB-FT
bugs fixed :
 none

   Intermediate delivery for WB SCCP Fast Track with new SCCP service
----------------------------
revision 3.13
date: 1997/05/23 16:22:52;  author: domi;  state: Exp;  lines: +1 -1
Author: domi
writer: domi
keywords:
bugs fixed :
 none

   - previous version does not compile in ANSI
----------------------------
revision 3.12
date: 1997/04/22 11:26:47;  author: domi;  state: Exp;  lines: +3 -3
Author: domi
writer: domi
keywords: GT_adr
fix: GREhp10979, GREhp11029
bugs fixed :

 - GREhp10979   :  With option PreferRoutOnGt in sys.tcap, RoutInd is not RoutOnGt in P-Abort
 - GREhp11029   :  Specific SSN in specficic GT in sys.tcap is not taken in account

   - coupled with tcapIncludes
   - does not compile in ANSI
----------------------------
revision 3.11
date: 1997/04/16 16:06:02;  author: domi;  state: Exp;  lines: +3 -3
Author: domi
writer: domi
keywords: BB_vs_WB
fix: GREhp10971
bugs fixed :

 - GREhp10971   :  TC_P_ABORT address format doesn't respect addr option in sys.tcap (case WB - BB)
----------------------------
revision 3.10
date: 1997/04/15 10:53:37;  author: domi;  state: Exp;  lines: +3 -4
Author: domi
bugs fixed :

 - GREhp10945   :  Stack stuck when a string is made of number in sys.* files
----------------------------
revision 3.9
date: 1997/03/28 16:22:13;  author: domi;  state: Exp;  lines: +6 -5
Author: domi
writer: domi
keywords: no_PC_in_GT
fix: GREhp10767
bugs fixed :

 - GREhp10767   :  Allow PC to be removed from calling address when routing on GT

   - sys.tcap parameters must be modified to enable the fix to work
   - must also use GREhp10420's fix

 FORCED ARCHIVE because :
WARNING : There are locked files...
file AP.h
rev:  3.0;  locked by: herve
   TMgr.m is OUT-OF-DATE
     (Your revision: 3.12, RCS/HMS revision: 3.12.1.1.)
----------------------------
revision 3.8
date: 1997/03/07 16:51:10;  author: domi;  state: Exp;  lines: +2 -2
Author: domi
merged from: 3.4.1.3
writer: domi
keywords: BB_vs_WB
fix: GREhp10739
bugs fixed :

 - GREhp10739   :  Incorrect P_ABORT cause when operating WB vs BB

   - fix handling of ABORTS and dialog portion in white book mode

   - coupled with tcapIncludes
----------------------------
revision 3.7
date: 1997/03/04 10:39:30;  author: herve;  state: Exp;  lines: +13 -10
Author: domi
writer: herve
keywords: GDI
bugs fixed :
 none

   now TCAP can be compile to access GDI with the GDI_BUILD compile option
----------------------------
revision 3.6
date: 1996/12/16 11:59:09;  author: domi;  state: Exp;  lines: +3 -3
Author: domi
writer: domi
keywords: mem_leak
fix: GREhp10170, GREhp10337
bugs fixed :

 - GREhp10170   :  HPSS7 Stack memory leak
 - GREhp10337   :  "dialog portion absent" is not an error

   - coupled with proxys v3.8.
----------------------------
revision 3.5
date: 1996/06/20 18:41:01;  author: hmgr;  state: Exp;  lines: +6 -6
Author: domi
bugs fixed :

 - GREhp00021   :  Calling address should be taken from TC-CONTINUE upon request

   - enable address change on the first TC_CONTINUE comming from the user
   (This features is standard in white book mode and is authorized in
   blue book mode by the "enableAddressChange" parameter in sys.tcap)
----------------------------
revision 3.4
date: 1996/06/05 13:15:27;  author: hmgr;  state: Exp;  lines: +4 -4
branches:  3.4.1;
Author: eric
bugs fixed : 
  
 - GREhp03732   :  Under stress, active transaction number increase all the time  
 
    
----------------------------
revision 3.3
date: 1996/04/26 13:30:39;  author: hmgr;  state: Exp;  lines: +5 -5
Author: domi
bugs fixed : 
  
 - GREhp07855   :  half traffic is lost for 45s after switchover (Nokia)  
 
   - changed tc_service_parms to tc_private_service_parms (fix GREhp07855)
   - When a new connection is made :
   Check for other connection with same applicationId or instanceId
   (i.e a ghost connection) and deactivate the associated user if
   necessary (i.e. with non NULL ids)
   reset the other variables of the table 
----------------------------
revision 3.2
date: 1996/01/12 11:37:58;  author: hmgr;  state: Exp;  lines: +1 -1
Author: domi
bugs fixed : 
  
 - GREhp06376   :  In switching slee phase, P_ABORT generated increase the transactions Nb.  
  
----------------------------
revision 3.1
date: 1995/12/20 16:53:03;  author: hmgr;  state: Exp;  lines: +7 -7
Author: domi
bugs fixed : 
 none  
 
   - Added a lot of traces in case of protocol errors (at the COM_E_LL_ERROR
   level) to help debug problem (Was needed for GREHp04971). 
----------------------------
revision 3.0
date: 1995/10/17 03:27:54;  author: hmgr;  state: Exp;  lines: +19 -19
Author: rey
First Revision for OC1.2
----------------------------
revision 2.28
date: 1995/09/18 04:54:22;  author: hmgr;  state: Exp;  lines: +1 -1
branches:  2.28.1;
Author: domi
bugs fixed : 
  
 - GREhp04802   :  tcap 2.27 doesn't compile in CCITT mode  
  
----------------------------
revision 2.27
date: 1995/09/11 11:21:41;  author: hmgr;  state: Exp;  lines: +1 -1
Author: domi
bugs fixed : 
  
 - GREhp04698   :  Behaviour non conformant with ANSI specification on XX_WO_PERM  
 
   The ansi norm specifies that under special condition a tcap user may
   terminate the transaction by sending a message of the response package type
   See ANSI T1.114-1992 section 3.2.1.5 
----------------------------
revision 2.26
date: 1995/09/05 12:34:49;  author: hmgr;  state: Exp;  lines: +1 -1
Author: anmarie
bugs fixed : 
  
 - GREhp04579   :  Bad Calling address in 1st TC_CONTINUE (WB only )  
  
----------------------------
revision 2.25
date: 1995/08/09 05:41:28;  author: hmgr;  state: Exp;  lines: +1 -1
Author: anmarie
bugs fixed : 
  
 - GREhp04270   :  setTrace and setLog primitives should no more be available  
  
----------------------------
revision 2.24
date: 1995/07/26 06:06:04;  author: hmgr;  state: Exp;  lines: +1 -1
Author: domi

   - added traces on creation/deletion of object TcapIf. 
 bugs fixed : 
 none 
----------------------------
revision 2.23
date: 1995/06/22 06:06:43;  author: hmgr;  state: Exp;  lines: +2 -2
Author: domi

   - corrected some warnings (may be created others also :-( ).
----------------------------
revision 2.22
date: 1995/06/20 10:57:17;  author: hmgr;  state: Exp;  lines: +4 -3
Author: domi

   - changed printf to TTL_log or TTL_M_TRACE
   - added message catalog
----------------------------
revision 2.21
date: 1995/06/14 11:33:45;  author: hmgr;  state: Exp;  lines: +5 -5
Author: domi

   - changed TLOG and LOGs to TTL_M_TRACE
----------------------------
revision 2.20
date: 1995/06/01 08:14:45;  author: hmgr;  state: Exp;  lines: +2 -1
Author: domi

   - added sys.tcap
----------------------------
revision 2.19
date: 1995/02/23 03:03:12;  author: hmgr;  state: Exp;  lines: +1 -1
Author: pierre

   fix SCP problem under congestion: CONTINUE from user/ P_ABORT from tcap
----------------------------
revision 2.18
date: 1995/02/07 10:53:14;  author: hmgr;  state: Exp;  lines: +2 -2
Author: anmarie

   Fix for GREhp02363 : Nokia problem
   Nokia switch is unable to reply to message with only SSN in calling party address
----------------------------
revision 2.17
date: 1995/02/03 10:24:36;  author: hmgr;  state: Exp;  lines: +1 -1
Author: pierre

   fix to avoid multiple creation of SCCP AP with the same SSN
----------------------------
revision 2.16
date: 1995/01/31 10:45:21;  author: hmgr;  state: Exp;  lines: +1 -1
branches:  2.16.1;
Author: pierre

   problem with multiple send (and free) of one message in IncomingStatusFromSCCP
----------------------------
revision 2.15
date: 1995/01/11 04:43:15;  author: hmgr;  state: Exp;  lines: +3 -3
Author: pierre

   GREhp01819: core dump in TcapIF
----------------------------
revision 2.14
date: 1995/01/04 10:25:18;  author: hmgr;  state: Exp;  lines: +1 -1
Author: pierre

   GREhp01792:  tests Q1421 and Q1422
----------------------------
revision 2.13
date: 1994/11/30 04:42:03;  author: hmgr;  state: Exp;  lines: +3 -3
Author: pierre

   liste incoherente corrected in TMgr.m GREhp01579
   unsigned int used for IDs GREhp01309
----------------------------
revision 2.12
date: 1994/10/26 11:43:08;  author: hmgr;  state: Exp;  lines: +1 -1
Author: pierre

   change the default value of max transaction aborted
----------------------------
revision 2.11
date: 1994/10/26 06:02:10;  author: hmgr;  state: Exp;  lines: +9 -9
Author: anmarie

   implementation of segmented ABORT
   implementation of ACTIVATE command and segmented ABORT
   Fix for GREhp01269 : pb with TCAP connection to an unconfigured SSN
----------------------------
revision 2.10
date: 1994/10/11 09:54:31;  author: hmgr;  state: Exp;  lines: +2 -2
Author: pierre

   GREhp01126     core dump when >16 tc-users or > MAX SSN
----------------------------
revision 2.9
date: 1994/09/08 10:37:34;  author: hmgr;  state: Exp;  lines: +1 -1
Author: anmarie

   Handling of sccp connection failure (fix related to SQEsr00622)
----------------------------
revision 2.8
date: 1994/08/23 12:32:23;  author: hmgr;  state: Exp;  lines: +1 -1
Author: pierre

   use of get and setTimestamp for timestamping
----------------------------
revision 2.7
date: 1994/07/27 10:56:53;  author: hmgr;  state: Exp;  lines: +1 -1
Author: pierre

   #include problem corrected
----------------------------
revision 2.6
date: 1994/07/26 10:13:04;  author: hmgr;  state: Exp;  lines: +1 -1
Author: pierre

   GREhp00162
----------------------------
revision 2.5
date: 1994/07/05 12:11:52;  author: hmgr;  state: Exp;  lines: +1 -1
Author: pierre

   correction of the nmakefile
----------------------------
revision 2.4
date: 1994/06/23 18:03:53;  author: hmgr;  state: Exp;  lines: +1 -1
Author: pierre

   SccpAP problem with timestamp is corrected
----------------------------
revision 2.3
date: 1994/06/23 13:01:33;  author: hmgr;  state: Exp;  lines: +9 -9
Author: pierre

   archive to test CM
----------------------------
revision 2.2
date: 1994/06/23 12:59:47;  author: hmgr;  state: Exp;  lines: +4 -4
Author: pierre
no comment
----------------------------
revision 2.1
date: 1994/06/07 20:51:10;  author: hmgr;  state: Exp;  lines: +17 -17
Author: pierres

   7UP/SS7 merge
----------------------------
revision 2.0
date: 1994/06/07 20:49:36;  author: hmgr;  state: Exp;  lines: +15 -14
Author: pierres
7UP/SS7 merge
----------------------------
revision 1.13
date: 1994/02/01 10:38:17;  author: hmgr;  state: Exp;  lines: +1 -1
Author: pierre

stop stat timer before start another one for the same statistic
----------------------------
revision 1.12
date: 1994/01/18 14:48:49;  author: hmgr;  state: Exp;  lines: +1 -1
Author: pierre

bug fixing: address type was wrong in certain case using GT (SccpAP)
----------------------------
revision 1.11
date: 1994/01/13 18:26:16;  author: hmgr;  state: Exp;  lines: +1 -1
Author: pierre

correction of the problem with ssn in called or calling address
----------------------------
revision 1.10
date: 1993/12/29 18:00:49;  author: hmgr;  state: Exp;  lines: +5 -5
Author: olivier

Implements new TCAP primitives to support Replicated subsystems
> see SCCP_N_COORD, SCCP_N_COORD_RES
----------------------------
revision 1.9
date: 1993/12/28 10:51:57;  author: hmgr;  state: Exp;  lines: +2 -2
Author: pierre

add no incoming dialogue in tc_control
----------------------------
revision 1.8
date: 1993/12/03 10:35:29;  author: hmgr;  state: Exp;  lines: +1 -1
Author: pierre

adds user dialogue ID in TC_NOTICE indication : VODAFONE expectation
----------------------------
revision 1.7
date: 1993/11/25 18:45:47;  author: hmgr;  state: Exp;  lines: +1 -1
Author: pierre

correction of the problem with o and d addresses
----------------------------
revision 1.6
date: 1993/11/24 16:16:45;  author: hmgr;  state: Exp;  lines: +3 -3
Author: pierre

trace level correction
----------------------------
revision 1.5
date: 1993/11/18 16:49:00;  author: hmgr;  state: Exp;  lines: +1 -1
Author: pierre

includes bug fix for tcap CCITT
----------------------------
revision 1.4
date: 1993/11/10 12:18:13;  author: hmgr;  state: Exp;  lines: +3 -3
Author: pierre

new version containing WHITE BOOK bugs correction and GT features
----------------------------
revision 1.3
date: 1993/11/05 17:27:18;  author: hmgr;  state: Exp;  lines: +3 -3
Author: pierre

correction of some protocol bugs for WHITE BOOK TCAP
----------------------------
revision 1.2
date: 1993/10/29 15:52:44;  author: hmgr;  state: Exp;  lines: +16 -21
Author: pierre

Merged version of tcap (ANSI/WHITE/BLUE)
----------------------------
revision 1.1
date: 1993/10/29 15:51:11;  author: hmgr;  state: Exp;
Author: pierre
Initial revision
----------------------------
revision 2.16.1.1
date: 1995/02/14 07:19:00;  author: hmgr;  state: Exp;  lines: +1 -1
Author: pierre

   special for HK tel: avoid P_ABORT sent to the user when message with underivable IDs
   is received from the user.
----------------------------
revision 2.28.1.1
date: 1996/04/11 18:54:00;  author: hmgr;  state: Exp;  lines: +4 -4
Author: domi
bugs fixed : 
  
 - GREhp07855   :  half traffic is lost for 45s after switchover (Nokia)  
 
   - changed tc_service_parms to tc_private_service_parms (fix GREhp07855)
   - When a new connection is made :
   Check for other connection with same applicationId or instanceId
   (i.e a ghost connection) and deactivate the associated user if
   necessary (i.e. with non NULL ids)
   reset the other variables of the table 
----------------------------
revision 3.4.1.6
date: 1997/09/24 16:57:03;  author: herve;  state: Exp;  lines: +4 -4
Author: herve
bugs fixed :

 - GREhp11677   :  SS7 stack memory leak when TCAP transaction failed leads to a core dump

merged from: 3.4.1.2.1.1
writer: herve
keywords: SS7
fix: GREhp11677
----------------------------
revision 3.4.1.5
date: 1997/07/22 10:15:38;  author: herve;  state: Exp;  lines: +1 -1
Author: herve
bugs fixed :

 - GREhp10825   :  Pb when sending a TC_END after receiving a TC_BEGIN without setting orig addr.
 - GREhp11165   :  itmi Q787:A412, A422, TA4226, TA4228 failed: transaction with XX_W_PERM refused
----------------------------
revision 3.4.1.4
date: 1997/07/16 10:04:24;  author: herve;  state: Exp;  lines: +1 -1
Author: herve
bugs fixed :

 - GREhp09922   :  total service lost when tcap user table full
----------------------------
revision 3.4.1.3
date: 1997/03/10 11:55:09;  author: domi;  state: Exp;  lines: +1 -1
Author: domi
writer: domi
keywords: BB_vs_WB
fix: GREhp10739
bugs fixed :

 - GREhp10739   :  Incorrect P_ABORT cause when operating WB vs BB

   - coupled with tcapIncludes
----------------------------
revision 3.4.1.2
date: 1997/02/28 16:50:19;  author: domi;  state: Exp;  lines: +1 -1
branches:  3.4.1.2.1;
Author: domi
writer: domi
keywords: mem_leak
fix: GREhp10170
bugs fixed :

 - GREhp10170   :  HPSS7 Stack memory leak

   - the previous leaf in this branch did not feature the complete fix.
   Do NOT use it.
----------------------------
revision 3.4.1.1
date: 1997/01/22 16:18:46;  author: domi;  state: Dead;  lines: +1 -1
Author: domi
writer: domi
keywords:
fix: GREhp10170
bugs fixed :

 - GREhp10170   :  HPSS7 Stack memory leak

 - branched for #75
 - This version is kaput, DO NOT USE
----------------------------
revision 3.4.1.2.1.1
date: 1997/09/24 13:34:02;  author: herve;  state: Exp;  lines: +4 -4
Author: herve
writer: herve
keywords: mem_leak(#728)
fix: GREhp11677
bugs fixed :

 - GREhp11677   :  SS7 stack memory leak when TCAP transaction failed leads to a core dump

   PATCH_SIEMENS memory leak
----------------------------
revision 4.6.1.3
date: 1997/11/07 16:54:19;  author: herve;  state: Exp;  lines: +1 -1
Author: herve
bugs fixed :
 none

   missing TimerInit, TimerCheck function in TcapMgr
----------------------------
revision 4.6.1.2
date: 1997/11/06 16:06:24;  author: cilou;  state: Exp;  lines: +1 -1
Author: cilou
bugs fixed :
 none

   As 'class' is a reserved C++ keyword, the 'class' field of structures
   SC_UNITDATA_PARMS and sccp_xunitdata_parms have been renamed
----------------------------
revision 4.6.1.1
date: 1997/11/05 11:26:38;  author: herve;  state: Exp;  lines: +2 -2
Author: herve
bugs fixed :
 none

   remove TimerLib because it will be part of MARS#2 not #1
=================================================

