SAMIUTS2 ;ven/lgc - UNIT TEST for SAMICAS2 ; 10/25/18 5:02pm
 ;;18.0;SAMI;;
 ;
 ;
START I $T(^%ut)="" W !,"*** UNIT TEST NOT INSTALLED ***" Q
 D EN^%ut($T(+0),2)
 Q
 ;
 ;
STARTUP n utsuccess
 Q
SETUP Q
 ;
SHUTDOWN ; ZEXCEPT: utsuccess
 K utsuccess
 Q
 ;
 ;
UTGTMPL ; @TEST - get html template
 ;getTemplate(return,form)
 n temp,poou
 d getTemplate^SAMICAS2("temp","vapals:casereview")
 d PullUTdata^SAMIUTST(.poou,"vapals:casereview")
 s utsuccess=1 n cnt s cnt=0
 f  s cnt=$O(poou(cnt)) q:'cnt  d
 . I '(poou(cnt)=temp(cnt)) s utsuccess=0 d
 .. s ^KBAP("SAMIUTS2",cnt)=""
 i '($o(poou("A",-1))=$o(temp("A",-1))) s utsuccess=0
 D CHKEQ^%ut(utsuccess,1,"Testing getting vapals:casereview template FAILED!")
 q
 ;
UTHMNY ; @TEST - extrinsic returns how many forms the patient has used before deleting a patient
 ;countItems(sid)
 n rootut,rootvp,gienut,dfn,gienvp,studyid,uforms,forms
 ; get test patient
 s rootut=$$setroot^%wd("vapals unit tests")
 s gienut=$O(@rootut@("B","patient-lookup test patient",0))
 s dfn=@rootut@(gienut,"dfn")
 ; get studyid on patient
 set rootvp=$$setroot^%wd("vapals-patients")
 s gienvp=$O(@rootvp@("dfn",dfn,0))
 i '$g(gienvp) d  q
 . D FAIL^%ut("Test patient not found in vapals-patients Graphstore")
 s studyid=$G(@rootvp@(gienvp,"sisid"))
 i '$l($g(studyid)) d  q
 . D FAIL^%ut("Test patient did not have studyid in vapals-patients Graphstore")
 ; get number of forms on test patient
 n uforms,forms,zi s uforms=0,zi=""
 f  s zi=$o(@rootvp@("graph",studyid,zi)) q:zi=""  d
 . s uforms=uforms+1
 s forms=$$countItems^SAMICAS2(studyid)
 s utsuccess=(uforms=forms)
 D CHKEQ^%ut(utsuccess,1,"Testing getting how many forms for patient FAIL!")
 q
UTCNTITM ; @TEST - get items available for studyid
 ;getItems(ary,sid)
 n rootut,rootvp,gienut,dfn,gienvp,studyid,uforms,forms
 ; get test patient
 s rootut=$$setroot^%wd("vapals unit tests")
 s gienut=$O(@rootut@("B","patient-lookup test patient",0))
 s dfn=@rootut@(gienut,"dfn")
 ; get studyid on patient
 set rootvp=$$setroot^%wd("vapals-patients")
 s gienvp=$O(@rootvp@("dfn",dfn,0))
 i '$g(gienvp) d  q
 . D FAIL^%ut("Test patient not found in vapals-patients Graphstore")
 s studyid=$G(@rootvp@(gienvp,"sisid"))
 i '$l($g(studyid)) d  q
 . D FAIL^%ut("Test patient did not have studyid in vapals-patients Graphstore")
 ; get number of forms on test patient
 n uforms,forms,zi s uforms=0,zi=""
 f  s zi=$o(@rootvp@("graph",studyid,zi)) q:zi=""  d
 . s uforms(zi)=""
 d getItems^SAMICAS2("poo",studyid)
 s utsuccess=1
 s zi="" f  s zi=$o(uforms(zi)) q:zi=""  d
 . i '$d(poo(zi)) s utsuccess=0
 D CHKEQ^%ut(utsuccess,1,"Testing getting available forms for patient FAILED!")
 q
UTGDTK ; @TEST - date portion of form key
 ;getDateKey(formid)
 n fdtkey s fdtkey=$$getDateKey^SAMICAS2("MYFORM-2018-10-03")
 D CHKEQ^%ut(fdtkey,"2018-10-03","Testing get date portion of form  FAILED!")
 q
UTK2DDT ; @TEST - date in elcap format from key date
 ;key2dispDate(zkey)
 n ecpdt s ecpdt=$$key2dispDate^SAMICAS2("2018-10-03")
 D CHKEQ^%ut(ecpdt,"10/3/2018","Testing date in elcap form  FAILED!")
 q
UTVPLSD ; @TEST - extrinsic which return the vapals format for dates
 ;vapalsDate(fmdate)
 n vpdate s vpdate=$$vapalsDate^SAMICAS2("3181003")
 D CHKEQ^%ut(vpdate,"10/3/2018","Testing fmdate to elcap date form  FAILED!")
 q
UTWSNF ; @TEST - select new form for patient (get service)
 ;wsNuForm(rtn,filter)
 q
UTNFPST ; @TEST - post new form selection (post service)
 ;wsNuFormPost(ARGS,BODY,RESULT)
 q
UTMKSBF ; @TEST - create background form
 ;makeSbform(sid,key)
 q
UTMKCEF ; @TEST - create ct evaluation form
 ;makeCeform(sid,key)
 d CheckForm^SAMIUTS2("ceform","makeCeform",.utsuccess)
 D CHKEQ^%ut(utsuccess,1,"Testing create ct eval form FAILED!")
 q
 ;
UTMKFUF ; @TEST - create Follow-up form
 ;makeFuform(sid,key)
 d CheckForm^SAMIUTS2("fuform","makeFuform",.utsuccess)
 D CHKEQ^%ut(utsuccess,1,"Testing create followup  form FAILED!")
 q
 ;
UTMKPTF ; @TEST - create ct evaluation form
 ;makePtform(sid,key)
 d CheckForm^SAMIUTS2("ptform","makePtform",.utsuccess)
 D CHKEQ^%ut(utsuccess,1,"Testing create followup  form FAILED!")
 q
 ;
UTMKITF ; @TEST - create intervention form
 ;makeItform(sid,key)
 d CheckForm^SAMIUTS2("itform","makeItform",.utsuccess)
 D CHKEQ^%ut(utsuccess,1,"Testing create intervention form FAILED!")
 q
 ;
UTMKBXF ; @TEST - create ct evaluation form
 ;makeBxform(sid,key)
 d CheckForm^SAMIUTS2("bxform","makeBxform",.utsuccess)
 D CHKEQ^%ut(utsuccess,1,"Testing create bx ct eval form FAILED!")
 q
 ;
UTWSCAS ; @TEST - generate case review page
 ;wsCASE(rtn,filter)
 n filter s filter("studyid")="XXX00001"
 n temp D wsCASE^SAMICAS2(.temp,.filter)
 n poou D PullUTdata^SAMIUTST(.poou,"wsCase-SAMICAS2")
 s utsuccess=1 n cnt s cnt=0
 f  s cnt=$O(poou(cnt)) q:'cnt  d
 . I '(poou(cnt)=temp(cnt)) s utsuccess=0 d
 .. s ^KBAP("SAMIUTS2",cnt)=""
 i '($o(poou("A",-1))=$o(temp("A",-1))) s utsuccess=0
 D CHKEQ^%ut(utsuccess,1,"Testing generating case review page FAILED!")
 q
 ;
UTGSAMIS ; @TEST - sets 'samistatus' to val in form
 ;setSamiStatus(sid,form,val)
 q
UTDELFM ; @TEST - deletes a form if it is incomplete
 ;deleteForm(RESULT,ARGS)
 q
UTINITS ; @TEST - set all forms to 'incomplete'
 ;initStatus
 q
UTCSRT ; @TEST - generates case review table
 ;casetbl(ary)
 n poo,pooc,arc,arcc
 D casetbl^SAMICAS2("poo")
 d PullUTarr^SAMIUTST(.arc,"casetbl-SAMICAS2")
 s utsuccess=1
 n pnode,anode
 s pnode=$na(poo),anode=$na(arc)
 f  s pnode=$q(@pnode),anode=$q(@anode) q:pnode=""  d
 . I '(@pnode=@anode) s utsuccess=0
 S:'(anode="") utsuccess=0
 q
 ;
CheckForm(form,label,utsuccess) ;
 n sid s sid="XXX00001"
 n rootvp s rootvp=$$setroot^%wd("vapals-patients")
 n datekey s datekey="2018-10-21"
 n key set key=form_"-"_datekey
 ; delete existing entry
 k @rootvp@("graph",sid,key)
 set ARGS("key")=key
 set ARGS("studyid")=sid
 set ARGS("form")="vapals:"_form
 do @label^SAMICAS2(sid,key)
 ; ^%wd(17.040801,23,"graph","XXX00001",form_"-2018-10-21","active duty")="N and others
 ;
 ; fail if nodes not set in vapals-patients Graphstore
 i '$d(@rootvp@("graph",sid,key)) d  q
 . s utsuccess=0
 . D FAIL^%ut(form_" not set in vapals-patients Graphstore")
 ;
 ; Check that the vapals-patients node created is correct
 ;
 n temp,poou
 d PullUTdata^SAMIUTST(.poou,label)
 m temp=@rootvp@("graph",sid,key)
 s utsuccess=1
 n ss s ss=""
 f  s ss=$O(poou(ss)) q:ss=""  d  q:'utsuccess
 . i '$d(temp(ss)) s utsuccess=0
 . i '($g(poou(ss))=$g(temp(ss))) s utsuccess=0
 q
 ;
EOR ;End of routine SAMIUTS2