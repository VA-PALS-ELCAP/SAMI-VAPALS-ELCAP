SAMIVSTS ;;ven/arc/lgc - M2M Broker to build TIU for VA-PALS ; 12/27/18 11:09am
 ;;18.0;SAMI;;
 ;
 ; VA-PALS will be using Sam Habiel's [KBANSCAU] broker
 ;   to pull information from the VA server into the
 ;   VA-PALS client and, to push TIU notes generated by
 ;   VA-PALS forms onto the VA server.
 ; Using this broker between VistA instances requires
 ;   not only the IP and Port for the server be known,
 ;   but also, that the Access and Verify of the user
 ;   on the server be sent across as well.  This is
 ;   required as the user on the server must have the
 ;   necessary Context menu(s) allowing use of the
 ;   Remote Procedure(s).
 ; Six parameters have been added to the client
 ;   VistA to prevent the necessity of hard coding
 ;   certain values and to allow for default values for others.
 ;   SAMI PORT
 ;   SAMI IP ADDRESS
 ;   SAMI ACCVER
 ;   SAMI DEFAULT PROVIDER
 ;   SAMI DEFAULT STATION NUMBER
 ;   SAMI TIU NOTE PRINT NAME
 ;   SAMI DEFAULT CLINIC IEN
 ;   SAMI SYSTEM TEST PATIENT DFN
 ; Note that the user selected must have active
 ;   credentials on both the Client and Server systems
 ;   and the following Broker context menu.
 ;      OR CPRS GUI CHART
 ;
 ;
 ;@routine-credits
 ;@primary development organization: Vista Expertise Network
 ;@primary-dev: Larry G. Carlson (lgc)
 ;@primary-dev: Alexis R. Carlson (arc)
 ;@copyright:
 ;@license: Apache 2.0
 ; https://www.apache.org/licenses/LICENSE-2.0.html
 ;
 ;@last-updated: 2018-09-26
 ;@application: VA-PALS
 ;@version: 1.0
 ;
 ;
 ;@sac-exemption
 ; sac 2.2.8 Vendor specific subroutines may not be called directly
 ;  except by Kernel, Mailman, & VA Fileman.
 ; sac 2.3.3.2 No VistA package may use the following intrinsic
 ;  (system) variables unless they are accessed using Kernel or VA
 ;  FileMan supported references: $D[EVICE], $I[O], $K[EY],
 ;  $P[RINCIPAL], $ROLES, $ST[ACK], $SY[STEM], $Z*.
 ;  (Exemptions: Kernel & VA Fileman)
 ; sac 2.9.1: Application software must use documented Kernel
 ;  supported references to perform all platform specific functions.
 ;  (Exemptions: Kernel & VA Fileman)
 ;
START I $T(^%ut)="" W !,"*** UNIT TEST NOT INSTALLED ***" Q
 D EN^%ut($T(+0),2)
 Q
 ;
 ;@API-code: D ALLPTS^SAMIVSTS
 ;@API-called-by: Option : SAMI PULL VA-PALS PATIENTS
 ;@API-Context menu : HMP UI CONTEXT
 ;@API-Remote Procedure : HMP PATIENT SELECT
 ;
ALLPTS ; Get all patients from a server by sequentially calling
 ;  for last names beginning with each letter of the
 ;  alphabet, building a complete array of patient names
 ;  in the ^KBAP("ALLPTS") global.  Once all the patient
 ;  names and demographics are pulled into this global,
 ;  the information is parsed into the 'patient-information'
 ;  graph in VA-PALS graph store database.
 ; Note : call directly or schedule option
 ;  SAMI PULL VA-PALS PATIENTS
 ;
 ;multi-dev;API;Procedure;clean;silent;sac exemption;0% tests
 ;
 D ALLPTS1("ALLPTS")
 ; Now build a new 'patient-lookup' graph
 D MKGPH
 Q
 ;
 ;ENTER
 ;  SAMISS = Subscript name within ^KBAP global
 ;           to use for patient array
 ;           Specifically designed for UNIT TEST where
 ;           we don't wish to corrupt existing data set
ALLPTS1(SAMISS) ; Build ^KBAP("ALLPTS" global
 N XDATA,FINI,CNTXT,RMPRC,CONSOLE,CNTNOPEN,XARRAY
 S CNTXT="HMP UI CONTEXT"
 S RMPRC="HMP PATIENT SELECT"
 S (CONSOLE,CNTNOPEN)=0
 S:'$L($G(SAMISS)) SAMISS="ALLPTS"
 ;
 K ^KBAP(SAMISS)
 N I,J F I=65:1:90 D
 . S FINI=$C(I)
 . K XARRAY
 . S XARRAY(1)="NAME"
 . S XARRAY(2)=FINI
 . D M2M^SAMIM2M(.XDATA,CNTXT,RMPRC,CONSOLE,CNTNOPEN,.XARRAY)
 . F J=1:1:$L(XDATA,$C(13,10)) D
 .. Q:'$L($P(XDATA,$C(13,10),J))
 .. S ^KBAP(SAMISS,FINI,J)=$P(XDATA,$C(13,10),J)
 ;
 Q
 ;
 ;
 ; Make Graph Store patient-lookup global from
 ;  ^KBAP("ALLPTS")
 ; e.g.
 ;   D MKGPH^KBAPUTL
MKGPH Q:'$D(^KBAP("ALLPTS"))
 n si s si=$$CLRGRPS("patient-lookup")
 Q:'$G(si)
 N gien,NODE,PTDATA,root
 ;s root=$$setroot^%wd("patient-lookup")
 s root=$$SETROOT("patient-lookup")
 s gien=0
 N NODE S NODE=$NA(^KBAP("ALLPTS"))
 N SNODE S SNODE=$P(NODE,")")
 F  S NODE=$Q(@NODE) Q:NODE'[SNODE  D
 . S PTDATA=@NODE
 . S gien=gien+1
 . S @root@(gien,"saminame")=$P(PTDATA,"^",4)
 . S @root@(gien,"sinamef")=$P($P($P(PTDATA,"^",4),",",2)," ")
 . S @root@(gien,"sinamel")=$P($P(PTDATA,"^",4),",")
 . S @root@(gien,"sbdob")=$E($P(PTDATA,"^",10),1,4)_"-"_$E($P(PTDATA,"^",10),5,6)_"-"_$E($P(PTDATA,"^",10),7,8)
 . S @root@(gien,"last5")=$P(PTDATA,"^",9)
 . S @root@(gien,"dfn")=$P(PTDATA,"^",12)
 . S @root@(gien,"gender")=$P($P($P(PTDATA,"pat-gender",2),"^",1,2),":",2)
 . S:($L($P(PTDATA,"^",12))) @root@("dfn",$P(PTDATA,"^",12),gien)=""
 . S:($L($P(PTDATA,"^",9))) @root@("last5",$P(PTDATA,"^",9),gien)=""
 .; Mixed case
 . S:($L($P(PTDATA,"^",4))) @root@("name",$P(PTDATA,"^",4),gien)=""
 .; Upper case
 . S:($L($P(PTDATA,"^",1))) @root@("name",$P(PTDATA,"^",1),gien)=""
 . I $L($P(PTDATA,"^",4)) D
 .. S @root@("saminame",$P(PTDATA,"^",4),gien)=""
 . I $L($P($P($P(PTDATA,"^",4),",",2)," ")) D
 .. S @root@("sinamef",$P($P($P(PTDATA,"^",4),",",2)," "),gien)=""
 . I $L($P($P(PTDATA,"^",4),",")) D
 .. S @root@("sinamel",$P($P(PTDATA,"^",4),","),gien)=""
 S @root@("Date Last Updated")=$$HTE^XLFDT($H)
 Q
 ;
 ;
 ;
 ;@API-code: $$Reminders^SAMIVSTS -or- D Reminders^SAMIVSTS
 ;@API-called-by: Option : SAMI PULL REMINDERS
 ;@API-Context menu : OR CPRS GUI CHART
 ;@API-Remote Procedure : PXRM REMINDERS AND CATEGORIES
 ;
 ; Pull Remiders off the server and build the
 ;    'reminders' Graphstore
 ;Enter
 ;   nothing required
 ;Return
 ;   If called as extrinsic
 ;      0 = rebuild of "reminders" Graphstore failed
 ;      n = number of reminders filed
RMDRS() ;
 N CNTXT,RMPRC,CONSOLE,CNTNOPEN,XARRAY
 S CNTXT="OR CPRS GUI CHART"
 S RMPRC="PXRM REMINDERS AND CATEGORIES"
 S (CONSOLE,CNTNOPEN)=0
 D M2M^SAMIM2M(.XDATA,CNTXT,RMPRC,CONSOLE,CNTNOPEN,.XARRAY)
 ; if successful continue
 I '$L(XDATA,$C(13,10)) Q:$Q 0  Q
 n si s si=$$CLRGRPS("reminders")
 I '$G(si) Q:$Q 0  Q
 ;n root s root=$$setroot^%wd("reminders")
 n root s root=$$SETROOT("reminders")
 n gien s gien=0
 N I,RCNT,TYPE,IEN,NAME,PRNTNAME,RMDR
 S RCNT=0
 N I F I=1:1:$L(XDATA,$C(13,10)) D
 . S RMDR=$P(XDATA,$C(13,10),I)
 . Q:($L(RMDR,"^")<3)
 . S RCNT=$G(RCNT)+1
 . S TYPE=$P(RMDR,U)
 . S IEN=$P(RMDR,U,2)
 . S NAME=$P(RMDR,U,3)
 . S PRNTNAME=$P(RMDR,U,4)
 . ;
 . S gien=gien+1
 . S @root@(gien,"type")=TYPE
 . S @root@(gien,"ien")=IEN
 . S @root@(gien,"name")=NAME
 . S @root@(gien,"printname")=PRNTNAME
 S @root@("Date Last Updated")=$$HTE^XLFDT($H)
 Q:$Q RCNT  Q
 ;
 ;
 ;
 ;@API-code: $$Providers^SAMIVSTS -or- D Providers^SAMIVSTS
 ;@API-called-by: Option : SAMI PULL PROVIDERS
 ;@API-Context menu : OR CPRS GUI CHART
 ;@API-Remote Procedure : ORQPT PROVIDERS
 ;
 ; Pull Providers off the server and build the
 ;    'providers' Graphstore
 ;Enter
 ;   nothing required
 ;Return
 ;   If called as extrinsic
 ;      0 = rebuild of "providers" Graphstore failed
 ;      n = number of providers filed
PRVDRS() ;
 N CNTXT,RMPRC,CONSOLE,CNTNOPEN,XARRAY
 S CNTXT="OR CPRS GUI CHART"
 S RMPRC="ORQPT PROVIDERS"
 S (CONSOLE,CNTNOPEN)=0
 D M2M^SAMIM2M(.XDATA,CNTXT,RMPRC,CONSOLE,CNTNOPEN,.XARRAY)
 ; if successful continue
 I '$L(XDATA,$C(13,10)) Q:$Q 0  Q
 n si s si=$$CLRGRPS("providers")
 I '$G(si) Q:$Q 0  Q
 ;n root s root=$$setroot^%wd("providers")
 n root s root=$$SETROOT("providers")
 n gien s gien=0
 N I,PCNT,PROVDUZ,NAME,PRVDR
 S PCNT=0
 F I=1:1:$L(XDATA,$C(13,10)) D
 . S PRVDR=$P(XDATA,$C(13,10),I)
 . Q:($L(PRVDR,"^")<2)
 . S PCNT=$G(PCNT)+1
 . S PROVDUZ=$P(PRVDR,U)
 . S NAME=$P(PRVDR,U,2)
 . ;
 . S gien=gien+1
 . S @root@(gien,"duz")=PROVDUZ
 . S @root@(gien,"name")=NAME
 S @root@("Date Last Updated")=$$HTE^XLFDT($H)
 Q:$Q PCNT  Q
 ;
 ;
 ;
 ;@API-code: $$Clinics^SAMIVSTS -or- D Clinics^SAMIVSTS
 ;@API-called-by: Option : SAMI PULL CLINICS
 ;@API-Context menu : OR CPRS GUI CHART
 ;@API-Remote Procedure : ORWU1 NEWLOC
 ;
 ; Pull Clinics off the server and build the
 ;    'clinics' Graphstore
 ;Enter
 ;   nothing required
 ;Return
 ;   If called as extrinsic
 ;      0 = rebuild of "clinics" Graphstore failed
 ;      n = number of clinics filed
CLINICS() ;
 N CNTXT,RMPRC,CONSOLE,CNTNOPEN,XARRAY
 S CNTXT="OR CPRS GUI CHART"
 S RMPRC="ORWU1 NEWLOC"
 S (CONSOLE,CNTNOPEN)=0
 K XARRAY
 S XARRAY(1)=" "
 S XARRAY(2)=1
 D M2M^SAMIM2M(.XDATA,CNTXT,RMPRC,CONSOLE,CNTNOPEN,.XARRAY)
 ; if successful continue
 I '$L(XDATA,$C(13,10)) Q:$Q 0  Q
 n si s si=$$CLRGRPS("clinics")
 I '$G(si) Q:$Q 0  Q
 ;n root s root=$$setroot^%wd("clinics")
 n root s root=$$SETROOT("clinics")
 n gien s gien=0
 N I,CCNT,CLINIEN,NAME,CNC
 S CCNT=0
 F I=1:1:$L(XDATA,$C(13,10)) D
 . S CNC=$P(XDATA,$C(13,10),I)
 . Q:($L(CNC,"^")<2)
 . S CCNT=$G(CCNT)+1
 . S CLINIEN=$P(CNC,U)
 . S NAME=$P(CNC,U,2)
 . ;
 . S gien=gien+1
 . S @root@(gien,"ien")=CLINIEN
 . S @root@(gien,"name")=NAME
 S @root@("Date Last Updated")=$$HTE^XLFDT($H)
 Q:$Q CCNT  Q
 ;
 ;
 ;@API-code: $$HealthFactors^SAMIVSTS -or- D HealthFactors^SAMIVSTS
 ;@API-called-by: Option : SAMI PULL HEALTH FACTORS
 ;@API-Context menu : OR CPRS GUI CHART
 ;@API-Remote Procedure : ORWPCE GET HEALTH FACTORS TY
 ;
 ; Pull Health Factors  off the server and build the
 ;    'health-factors' Graphstore
 ;Enter
 ;   nothing required
 ;Return
 ;   If called as extrinsic
 ;      0 = rebuild of "health-factors" Graphstore failed
 ;      n = number of health factors filed
HLTHFCT() ; Clear the M Web Server files cache
 ;VEN/arc;test;function/procedure;dirty;silent;non-sac
 N CNTXT,RMPRC,CONSOLE,CNTNOPEN,XARRAY
 S CNTXT="OR CPRS GUI CHART"
 S RMPRC="ORWPCE GET HEALTH FACTORS TY"
 S (CONSOLE,CNTNOPEN)=0
 D M2M^SAMIM2M(.XDATA,CNTXT,RMPRC,CONSOLE,CNTNOPEN,.XARRAY)
 ; if successful continue
 I '$L(XDATA,$C(13,10)) Q:$Q 0  Q
 n si s si=$$CLRGRPS("health-factors")
 I '$G(si) Q:$Q 0  Q
 ;n root s root=$$setroot^%wd("health-factors")
 n root s root=$$SETROOT("health-factors")
 n gien s gien=0
 N I,HCNT,IEN,NAME,HFCT
 S HCNT=0
 F I=1:1:$L(XDATA,$C(13,10)) D
 . S HFCT=$P(XDATA,$C(13,10),I)
 . Q:($L(HFCT,"^")<2)
 . S HCNT=$G(HCNT)+1
 . S IEN=$P(HFCT,U)
 . S NAME=$P(HFCT,U,2)
 . ;
 . S gien=gien+1
 . S @root@(gien,"ien")=IEN
 . S @root@(gien,"name")=NAME
 . S:$L(NAME) @root@("name",NAME,gien)=""
 S @root@("Date Last Updated")=$$HTE^XLFDT($H)
 Q:$Q HCNT  Q
 ;
 ;
 ;@API-code: $$CLRGRPS^SAMIVSTS
 ;
 ; Clear a Graphstore global of data
 ;Enter
 ;   name = name of the Graphstore to clear
 ;Return
 ; if called as extrinsic function
 ;   0 = failure to find named Graphstore
 ;   ien (si) of the Graphstore in ^%wd(17.040801,
CLRGRPS(name) ;
 I '$l($g(name)) Q:$Q 0  Q
 n siglb s siglb="^%wd(17.040801,""B"","""_name_""",0)"
 n si s si=$o(@siglb)
 i $g(si) d
 . s siglb="^%wd(17.040801,"_si_")"
 . k @siglb
 . s siglb="^%wd(17.040801,"_si_",0)"
 . s @siglb=name
 e  d
 . s siglb="setroot^%wd("""_name_""")"
 . d @siglb
 . s siglb="^%wd(17.040801,""B"","""_name_""",0)"
 . s si=$o(@siglb)
 Q:$Q $g(si)  Q
 ;
SETROOT(name) ;
 n siglb s siglb="setroot^%wd("""_name_""")"
 d @siglb
 s siglb="^%wd(17.040801,""B"","""_name_""",0)"
 n si s si=$o(@siglb)
 n root s root="^%wd(17.040801,"_si_")"
 q root
 ;
EOR ; End of routine SAMIVSTS
