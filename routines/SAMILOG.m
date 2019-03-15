SAMILOG ;ven/lgc - APIs to toggle password identification ; 3/14/19 7:15pm
 ;;18.0;SAMI;;
 ;
 ; @section 0 primary development
 ;
 ; @routine-credits
 ; @primary-dev: Larry Carlson (lgc)
 ;  larry@fiscientific.com
 ; @primary-dev-org: Vista Expertise Network (ven)
 ;  http://vistaexpertise.net
 ; @copyright: 2012/2018, ven, all rights reserved
 ; @license: Apache 2.0
 ;  https://www.apache.org/licenses/LICENSE-2.0.html
 ;
 ; @application: SAMI
 ; @version: 18.0
 ; @patch-list: none yet
 ;
 ; @to-do
 ;
 ; @section 1 code
 ;
 ; ^%W(17.6001,"B","GET","vapals","WSHOME^SAMIHOM3",20)
 ;   ^%W(17.6001,20,0) = GET                 (.01)
 ;   ^%W(17.6001,20,1) = vapals              (1) F
 ;   ^%W(17.6001,20,2) = WSHOME^SAMIHOM3     (2) F
 ;   ^%W(17.6001,20,"AUTH") = 1              (11)S
 ; ^%W(17.6001,"B","POST","vapals","WSVAPALS^SAMIHOM3",22)
 ;   ^%W(17.6001,22,0) = POST                (.01)
 ;   ^%W(17.6001,22,1) = vapals              (1) F
 ;   ^%W(17.6001,22,2) = WSVAPALS^SAMIHOM3   (2) F
 ;   ^%W(17.6001,22,"AUTH") = 1              (11)S
 ;
STONOFF ;
 n ienget,ienpost,DIR,X,Y,%,DTOUT,DUOUT,ONOFF
 s ienget=$O(^%W(17.6001,"B","GET","vapals","WSHOME^SAMIHOM3",0))
 s ienpost=$O(^%W(17.6001,"B","POST","vapals","WSVAPALS^SAMIHOM3",0))
 i $g(^%W(17.6001,ienget,"AUTH")) d
 . w !,"VAPALS password ID is presently ON",!
 . w !," would you like to turn *** OFF *** VAPALS password ID."
 . s ONOFF="ON"
 e  d
 . w !,"VAPALS password ID is presently OFF",!
 . w !," would you like to turn *** ON *** VAPALS password ID."
 . s ONOFF="OFF"
 ;
 w !
 ; check if running unit test on this routine
 I $data(%ut) goto STONOFF1
 ;
 S %=2 D YN^DICN q:$d(DTOUT)  q:$d(DUOUT)  q:%=2
 ;
STONOFF1 if ONOFF="OFF" d TOGON W !,"VAPALS password ID is now turned ON",!,!
 if ONOFF="ON" d TOGOFF W !,"VAPALS password ID is now turned OFF",!,!
 q
 ;
 ; Toggle password identification OFF
TOGOFF n DIERR,FDA,ienget,ienpost,IENS
 s ienget=$o(^%W(17.6001,"B","GET","vapals","WSHOME^SAMIHOM3",0))
 s ienpost=$o(^%W(17.6001,"B","POST","vapals","WSVAPALS^SAMIHOM3",0))
 q:'ienget  q:'ienpost
 s IENS=ienget_","
 s FDA(3,17.6001,IENS,11)=0
 D UPDATE^DIE("","FDA(3)")
 ;
 s IENS=ienpost_","
 s FDA(3,17.6001,IENS,11)=0
 D UPDATE^DIE("","FDA(3)")
 q
 ;
 ; Toggle password identification ON
TOGON n DIERR,FDA,ienget,ienpost,IENS
 s ienget=$o(^%W(17.6001,"B","GET","vapals","WSHOME^SAMIHOM3",0))
 s ienpost=$o(^%W(17.6001,"B","POST","vapals","WSVAPALS^SAMIHOM3",0))
 q:'ienget  q:'ienpost
 S IENS=ienget_","
 s FDA(3,17.6001,IENS,11)=1
 D UPDATE^DIE("","FDA(3)")
 ;
 s IENS=ienpost_","
 s FDA(3,17.6001,IENS,11)=1
 D UPDATE^DIE("","FDA(3)")
 q
 ;
EOR ;End of routine SAMILOG
