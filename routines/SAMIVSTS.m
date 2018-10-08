SAMIVSTS ;;ven/arc/lgc - M2M Broker to build TIU for VA-PALS ; 10/5/18 8:56am
 ;;1.0;;**LOCAL**; APR 22, 2018
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
ALLPTS1(SAMISS) N CNTXT,RMPRC,CONSOLE,CNTNOPEN,XARRAY
 S CNTXT="HMP UI CONTEXT"
 S RMPRC="HMP PATIENT SELECT"
 S (CONSOLE,CNTNOPEN)=0
 S:'$L($G(SAMISS)) SAMISS="ALLPTS"
 ;
 K ^KBAP(SAMISS)
 F I=65:1:90 D
 . S FINI=$C(I)
 . K XARRAY
 . S XARRAY(1)="NAME"
 . S XARRAY(2)=FINI
 . D M2M^KBAPM2M(.XDATA,CNTXT,RMPRC,CONSOLE,CNTNOPEN,.XARRAY)
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
 n si s si=$$ClearGraphstore("patient-lookup")
 Q:'$G(si)
 n root s root=$$setroot^%wd("patient-lookup")
 N gien,NODE,PTDATA,root
 s root=$$setroot^%wd("patient-lookup")
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
Reminders() ;
 N CNTXT,RMPRC,CONSOLE,CNTNOPEN,XARRAY
 S CNTXT="OR CPRS GUI CHART"
 S RMPRC="PXRM REMINDERS AND CATEGORIES"
 S (CONSOLE,CNTNOPEN)=0
 D M2M^KBAPM2M(.XDATA,CNTXT,RMPRC,CONSOLE,CNTNOPEN,.XARRAY)
 ; if successful continue
 I '$L(XDATA,$C(13,10)) Q:$Q 0  Q
 n si s si=$$ClearGraphstore("reminders")
 I '$G(si) Q:$Q 0  Q
 n root s root=$$setroot^%wd("reminders")
 n gien s gien=0
 N I,RCNT,TYPE,IEN,NAME,PRINTNAME,RMDR
 S RCNT=0
 F I=1:1:$L(XDATA,$C(13,10)) D
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
Providers() ;
 N CNTXT,RMPRC,CONSOLE,CNTNOPEN,XARRAY
 S CNTXT="OR CPRS GUI CHART"
 S RMPRC="ORQPT PROVIDERS"
 S (CONSOLE,CNTNOPEN)=0
 D M2M^KBAPM2M(.XDATA,CNTXT,RMPRC,CONSOLE,CNTNOPEN,.XARRAY)
 ; if successful continue
 I '$L(XDATA,$C(13,10)) Q:$Q 0  Q
 n si s si=$$ClearGraphstore("providers")
 I '$G(si) Q:$Q 0  Q
 n root s root=$$setroot^%wd("providers")
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
Clinics() ;
 N CNTXT,RMPRC,CONSOLE,CNTNOPEN,XARRAY
 S CNTXT="OR CPRS GUI CHART"
 S RMPRC="ORWU1 NEWLOC"
 S (CONSOLE,CNTNOPEN)=0
 K XARRAY
 S XARRAY(1)=" "
 S XARRAY(2)=1
 D M2M^KBAPM2M(.XDATA,CNTXT,RMPRC,CONSOLE,CNTNOPEN,.XARRAY)
 ; if successful continue
 I '$L(XDATA,$C(13,10)) Q:$Q 0  Q
 n si s si=$$ClearGraphstore("clinics")
 I '$G(si) Q:$Q 0  Q
 n root s root=$$setroot^%wd("clinics")
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
HealthFactors() ; Clear the M Web Server files cache
 ;VEN/arc;test;function/procedure;dirty;silent;non-sac
 N CNTXT,RMPRC,CONSOLE,CNTNOPEN,XARRAY
 S CNTXT="OR CPRS GUI CHART"
 S RMPRC="ORWPCE GET HEALTH FACTORS TY"
 S (CONSOLE,CNTNOPEN)=0
 D M2M^KBAPM2M(.XDATA,CNTXT,RMPRC,CONSOLE,CNTNOPEN,.XARRAY)
 ; if successful continue
 I '$L(XDATA,$C(13,10)) Q:$Q 0  Q
 n si s si=$$ClearGraphstore("health-factors")
 I '$G(si) Q:$Q 0  Q
 n root s root=$$setroot^%wd("health-factors")
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
 ;@API-code: $$ClearGraphstore^SAMIVSTS
 ;
 ; Clear a Graphstore global of data
 ;Enter
 ;   name = name of the Graphstore to clear
 ;Return
 ; if called as extrinsic function
 ;   0 = failure to find named Graphstore
 ;   ien (si) of the Graphstore in ^%wd(17.040801,
ClearGraphstore(name) ;
 I '$l($g(name)) Q:$Q 0  Q
 n si s si=$O(^%wd(17.040801,"B",name,0))
 i $g(si) K ^%wd(17.040801,si) s ^%wd(17.040801,si,0)=name
 e  d purgegraph^%wd(name)
 Q:$Q $g(si)  Q
 ;
 ;
STARTUP N PORT,HOST,AV
 S KBAPFAIL=0
 S PORT=$$GET^XPAR("SYS","SAMI PORT",,"Q")
 S HOST=$$GET^XPAR("SYS","SAMI IP ADDRESS",,"Q")
 S:($G(HOST)="") HOST="127.0.0.1"
 S AV=$$GET^XPAR("SYS","SAMI ACCVER",,"Q")
 I ('$G(PORT))!('($L($G(AV),";")=2)) D  G SHUTDOWN
 . D FAIL^%ut("SAMI PARAMETERS MUST BE SET UP FOR UNIT TESTING")
 Q
 ;
SHUTDOWN ; ZEXCEPT: KBAPFAIL - defined in STARTUP
 K KBAPFAIL
 I $D(^KBAP("ALLPTS UNITTEST")) M ^KBAP("ALLPTS")=^KBAP("ALLPTS UNITTEST") K ^KBAP("ALLPTS UNITTEST")
 I $D(^KBAP("UNIT TEST PROVIDERS")) D
 . n root s root=$$setroot^%wd("providers")
 . D ClearGraphstore("providers")
 . m @root=^KBAP("UNIT TEST PROVIDERS") K ^KBAP("UNIT TEST PROVIDERS")
 I $D(^KBAP("UNIT TEST REMINDERS")) D
 . n root s root=$$setroot^%wd("reminders")
 . D ClearGraphstore("reminders")
 . m @root=^KBAP("UNIT TEST REMINDERS") K ^KBAP("UNIT TEST REMINDERS")
 I $D(^KBAP("UNIT TEST CLINICS")) D
 . n root s root=$$setroot^%wd("clinics")
 . D ClearGraphstore("clinics")
 . m @root=^KBAP("UNIT TEST CLINICS") K ^KBAP("UNIT TEST CLINICS")
 I $D(^KBAP("UNIT TEST HEALTH FACTORS")) D
 . n root s root=$$setroot^%wd("health-factors")
 . D ClearGraphstore("health-factors")
 . m @root=^KBAP("UNIT TEST HEALTH FACTORS") K ^KBAP("UNIT TEST HEALTH FACTORS")
 Q
 ;
 ; ============== UNIT TESTS ======================
 ; NOTE: Unit tests will pull data using the local
 ;       client VistA files rather than risk degrading
 ;       large datasets in use.  NEVERTHELESS, it is 
 ;       recommended that UNIT TESTS be run when 
 ;       VA-PALS is not in use as some Graphstore globals
 ;       are temporarily moved while testing is running.
UTMGPH ; @TEST - Test making 'patient-information' Graphstore
 I '$D(^KBAP("ALLPTS")) D  Q
 .  D FAIL^%ut("^KBAP(""ALLPTS"") must exist for TESTING")
 ;
 D MKGPH ; Rebuild 'patient-lookup' Graphstore
 ; Check that the Graphstore was built
 n si s si=$O(^%wd(17.040801,"B","patient-lookup",0))
 I '$G(si) D  Q
 . D FAIL^%ut("MKGPH entry did not build 'patient-lookup' Graphstore")
 ;
 n NODE,SNODE,RSLT,root,gien,dfn
 s root=$$setroot^%wd("patient-lookup")
 S NODE=$NA(^KBAP("ALLPTS")),SNODE=$P(NODE,")")
 N KBAPFAIL S KBAPFAIL=0
 F  S NODE=$Q(@NODE) Q:NODE'[SNODE  D  Q:$G(KBAPFAIL)
 . S PTDATA=@NODE
 . S dfn=$P(PTDATA,"^",12)
 . s gien=$O(@root@("dfn",dfn,0))
 . I '$G(gien) D  S KBAPFAIL=1 Q
 .;
 .; Now compare the entries in this Graphstore node with 
 .;  the information in the respective ^KBAP("ALLPTS" node
 . S KBAPFAIL=1
 . I '$O(@root@("last5",$P(PTDATA,"^",9),0)) Q
 . I '$L($P(PTDATA,"^")) Q
 . I '$O(@root@("name",$P(PTDATA,"^"),0)) Q
 . I '$L($P(PTDATA,"^",4)) Q
 . I '$O(@root@("name",$P(PTDATA,"^",4),0)) Q
 . I '$O(@root@("saminame",$P(PTDATA,"^",4),0)) Q
 . S KBAPFAIL=0
 ;
 I $G(KBAPFAIL) D  Q
 . D FAIL^%ut("'patient-lookup' Graphstore incorrectly built")
 D CHKEQ^%ut(KBAPFAIL,0,"Testing Complete Graphstore build  FAILED!")
 Q
 ;
UTAPTS ; @TEST - Test pulling patient data through broker
 K ^KBAP("ALLPTS UNITTEST")
 D ALLPTS1("ALLPTS UNITTEST")
 ;                in file 2         in ALLPTS
 ;  name            piece 1          piece 1
 ;  sex             piece 2          piece 6
 ;  birthdate       piece 3 fmdt     piece 10 (yyyymmdd)
 ;
 ; Pull name from file 2 B cross
 ;   Get name,sex,birthdate,build last5
 ; Pull entry in Graphstore using last5
 ;   Knowing gien get name,sex,birthdate
 ; Compare
 N name2,sex2,dob2,last52,dfn2,nameG,sexG,dobG,last5G,dfnG
 N node2,nodeG,gien
 n root s root=$$setroot^%wd("patient-lookup")
 S (KBAPFAIL,dfn2)=0
 f  s dfn2=$O(^DPT(dfn2)) Q:'dfn2  D  Q:KBAPFAIL
 . s node2=$G(^DPT(dfn2,0))
 . s name2=$P(node2,"^")
 . s sex2=$$UP^XLFSTR($E($P(node2,"^",2)))
 . s dob2=$$FMTHL7^XLFDT($P(node2,"^",3))
 . s dob2=$E(dob2,1,4)_"-"_$E(dob2,5,6)_"-"_$E(dob2,7,8)
 . s gien=$O(@root@("dfn",dfn2,0))
 . s last52=$$UP^XLFSTR($E(name2))_$E($P(node2,"^",9),6,9)
 . I '$G(gien) S KBAPFAIL=1 Q
 . I '$D(@root@("name",name2,gien)) S KBAPFAIL=1 Q
 . I '($P($G(@root@(gien,"gender")),"^")=sex2) D  Q
 .. S KBAPFAIL=1
 . I '$D(@root@("last5",last52,gien)) S KBAPFAIL=1 Q
 . I '($G(@root@(gien,"sbdob"))=dob2) S KBAPFAIL=1 Q
 K ^KBAP("ALLPTS UNITTEST")
 I $G(KBAPFAIL) D  Q
 . D FAIL^%ut("KBAP(""ALLPTS UNITTEST"") incorrectly built")
 D CHKEQ^%ut(KBAPFAIL,0,"Testing pulling patients through broker FAILED!")
 Q
 ;   
UTPRVDS ; @TEST - Pulling Providers through the broker
 K ^KBAP("UNIT TEST PROVIDERS")
 n root s root=$$setroot^%wd("providers")
 m ^KBAP("UNIT TEST PROVIDERS")=@root
 N KBAPPVDS,KBAPFAIL S KBAPFAIL=0
 S KBAPPVDS=$$Providers
 I '$G(KBAPPVDS) D  Q
 . M @root=^KBAP("UNIT TEST PROVIDERS") K ^KBAP("UNIT TEST PROVIDERS")
 . D FAIL^%ut("No providers pulled through broker")
 n ien,duzG,nameG
 f ien=1:1:$G(KBAPPVDS) D  Q:$G(KBAPFAIL)
 . s duzG=@root@(ien,"duz")
 . s nameG=@root@(ien,"name")
 . I '$D(^XUSEC("PROVIDER",duzG)) S KBAPFAIL=1 Q
 .; I '$$ACTIVE^XUSER(duzG) S KBAPFAIL=1 Q
 . I '($$UP^XLFSTR(nameG))=($$UP^XLFSTR($P($G(^VA(200,duzG,0)),"^"))) D  Q
 .. S KBAPFAIL=1
 m @root=^KBAP("UNIT TEST PROVIDERS") K ^KBAP("UNIT TEST PROVIDERS")
 D CHKEQ^%ut(KBAPFAIL,0,"Testing pulling Providers through broker FAILED!")
 Q
 ;
UTRMDRS ; @TEST - Pulling Reminders through the broker
 K ^KBAP("UNIT TEST REMINDERS")
 n root s root=$$setroot^%wd("reminders")
 m ^KBAP("UNIT TEST REMINDERS")=@root
 N KBAPRMDR,KBAPFAIL S KBAPFAIL=0
 S KBAPRMDR=$$Reminders
 I '$G(KBAPRMDR) D  Q
 . M @root=^KBAP("UNIT TEST REMINDERS")
 . K ^KBAP("UNIT TEST REMINDERS")
 . D FAIL^%ut("No reminders pulled through broker")
 n ienV,ienG,nameG,pnameG,typeG
 f ienG=1:1:$G(KBAPRMDR) D  Q:$G(KBAPFAIL)
 . s nameG=@root@(ienG,"name") ; Mixed case
 . s pnameG=@root@(ienG,"printname") ; All caps
 . s typeG=@root@(ienG,"type")
 . s ienV=@root@(ienG,"ien")
 . I typeG="R" D  Q:$G(KBAPFAIL)
 .. I '$D(^PXD(811.9,"B",pnameG,ienV)) S KBAPFAIL=1 Q
 .. I '$D(^PXD(811.9,"D",nameG,ienV)) S KBAPFAIL=1 Q
 . I typeG="C" D  Q:$G(KBAPFAIL)
 .. I '($G(^PXRMD(811.7,ienV,0))=nameG) S KBAPFAIL=1 Q
 m @root=^KBAP("UNIT TEST REMINDERS")
 K ^KBAP("UNIT TEST REMINDERS")
 D CHKEQ^%ut(KBAPFAIL,0,"Testing pulling Reminders through broker FAILED!")
 Q
 ;
 ;
UTCLNC ; @TEST - Pulling Clinics through the broker
 K ^KBAP("UNIT TEST CLINICS")
 n root s root=$$setroot^%wd("clinics")
 m ^KBAP("UNIT TEST CLINICS")=@root
 N KBAPCLNC,KBAPFAIL S KBAPFAIL=0
 S KBAPCLNC=$$Clinics
 I '$G(KBAPCLNC) D  Q
 . M @root=^KBAP("UNIT TEST CLINICS")
 . K ^KBAP("UNIT TEST CLINICS")
 . D FAIL^%ut("No clinics pulled through broker")
 n ienG,ienV,nameG
 f ienG=1:1:$G(KBAPCLNC) D  Q:$G(KBAPFAIL)
 . s nameG=@root@(ienG,"name")
 . s ienV=@root@(ienG,"ien")
 . I '$D(^SC("B",nameG,ienV)) S KBAPFAIL=1 Q
 m @root=^KBAP("UNIT TEST CLINICS")
 K ^KBAP("UNIT TEST CLINICS")
 D CHKEQ^%ut(KBAPFAIL,0,"Testing pulling Clinics through broker FAILED!")
 Q
 ;
 ;
UTHF ; @TEST - Pulling Health Factors through the broker
 K ^KBAP("UNIT TEST HEALTH FACTORS")
 n root s root=$$setroot^%wd("health-factors")
 m ^KBAP("UNIT TEST HEALTH FACTORS")=@root
 N KBAPHF,KBAPFAIL S KBAPFAIL=0
 S KBAPHF=$$HealthFactors
 I '$G(KBAPHF) D  Q
 . M @root=^KBAP("UNIT TEST HEALTH FACTORS")
 . K ^KBAP("UNIT TEST HEALTH FACTORS")
 . D FAIL^%ut("No health factors pulled through broker")
 n ienV,ienG,nameG
 f ienG=1:1:$G(KBAPHF) D  Q:$G(KBAPFAIL)
 . s nameG=@root@(ienG,"name")
 . s ienV=@root@(ienG,"ien")
 . I '($P($G(^AUTTHF(ienV,0)),"^")=nameG) S KBAPFAIL=1 Q
 m @root=^KBAP("UNIT TEST HEALTH FACTORS")
 K ^KBAP("UNIT TEST HEALTH FACTORS")
 D CHKEQ^%ut(KBAPFAIL,0,"Testing pulling Health Factors through broker FAILED!")
 Q
 ;
UTCLRG ; @TEST - Clear a Graphstore of entries
 n root s root=$$setroot^%wd("providers")
 K ^KBAP("UNIT TEST CLRGRPH") M ^KBAP("UNIT TEST CLRGRPH")=@root
 n cnt s cnt=$O(@root@("A"),-1)
 I 'cnt D  Q
 . D FAIL^%ut("No 'providers found' entry")
 s cnt=$$ClearGraphstore("providers"),cnt=$O(@root@("A"),-1)
 M @root=^KBAP("UNIT TEST CLRGRPH") K ^KBAP("UNIT TEST CLRGRPH")
 D CHKEQ^%ut(cnt,0,"Clear Graphstore FAILED!")
 Q
 ;
EOR ; End of routine SAMIVSTS