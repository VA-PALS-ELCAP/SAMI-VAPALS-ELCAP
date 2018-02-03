%wful ;ven/toad-write form: development log ;2018-01-22T23:51Z
 ;;1.8;Mash;
 ;
 ; %wful is the Write Form Library's primary-development log.
 ; It contains no executable software.
 ;
 quit  ; no entry from top
 ;
 ;
 ;
 ;@section 0 primary development
 ;
 ;
 ;
 ;@primary-dev: George P. Lilly (gpl)
 ;   gpl@vistaexpertise.net
 ;@primary-dev-org: Vista Expertise Network (ven)
 ;   http://vistaexpertise.net
 ;@copyright: 2017/2018, ven, all rights reserved
 ;@license: Apache 2.0
 ;   https://www.apache.org/licenses/LICENSE-2.0.html
 ;
 ;@last-updated: 2018-01-22T23:51Z
 ;@application: Mumps Advanced Shell (Mash)
 ;@module: Write Form - %wf
 ;@version: 1.8T04
 ;@release-date: not yet released
 ;@patch-list: none yet
 ;
 ;@funding-org: 2017/2018, Bristol-Myers Squibb Foundation (bmsf)
 ;   https://www.bms.com/about-us/responsibility/bristol-myers-squibb-foundation.html
 ;
 ;@additional-dev: Frederick D. S. Marshall (toad)
 ;
 ; 2017-02-27/09-18 ven/gpl %*1.7t03 %yottaq: original routine developed
 ;
 ; 2017-09-25 ven/gpl %*1.7t03 %yottaq: split lines containing >1
 ; <input> tag to aid parsing; replace quotes with &quot; to aid
 ; parsing; in wsGetForm.
 ;
 ; 2017-10-02 ven/gpl %*1.7t03 %wfhform: renamespace under %wf and move
 ; all subroutines related to wsGetForm & wsPostForm to this new
 ; routine; all other subroutines went elsewhere, including under %wd;
 ; begin spelling out mumps language elements; remove dead code; new
 ; subroutines initforms & initform1.
 ;
 ; 2017-10-04 ven/gpl %*1.7t03 %wfhform: r/initforms & initform1
 ; w/validate, dateValid, textValid, numValid.
 ;
 ; 2017-10-07 ven/gpl %*1.7t03 %wfhform: in wsGetForm r/postform w/form
 ; action, r/.5 w/.001 in <input> split, insert new validation block,
 ; insert debugging line after validation; new insError; in wsPostForm
 ; add validation block; in validate & dateValid add mew msg param.
 ;
 ; 2017-10-24 ven/gpl %*1.7t03 %wfhform: in wsGetForm r/id, handle
 ; temporary values, call $$replaceSrc to fix css & js href values, call
 ; debugFld as needed; add debugFld, replaceSrc, replaceAll; in replaceHref
 ; add conds sami2.js, jquery-3.2.1.min.js, jquery-ui.min.js; in insError
 ; expand to append error inserts to more than just </input>; in setVals
 ; clear old graph before merging new one in.
 ;
 ; 2017-10-30 ven/gpl %*1.7t03 %wfhform: in wsGetForm add param post to
 ; support posting w/o retrieving; in wsPostForm use new param, after
 ; validation block add filing into Fileman & returning the record.
 ;
 ; 2017-10-31 ven/gpl %*1.7t03 %wfhform: in wsGetForm comment out fixing
 ; css & js values, reformat if date; add dateFormat.
 ;
 ; 2017-11-15 ven/gpl %*1.7t03 %wfhform: in wsGetForm preserve graph
 ; variables not saved in fileman, remove error section, support new debug
 ; flags for form, support 2nd error method; add redactErr, redactErr2,
 ; testRedactErr2, putErrMsg2, delText; in dateFormat be more flexible;
 ; move replaceSrc & replaceHref to end; in wsPostForm use new status
 ; param in call to fileForm^%wffiler; in validate make default type free
 ; text to support weeding out bad characters.
 ;
 ; 2017-12-20 ven/gpl %*1.7t03 %wfhform: in wsGetForm add special handling
 ; for sbform2, chg default form handling to call $$getTemplate, add temp
 ; hack for elcap forms (gpl), introduce use of form label in form action,
 ; restore fixes of css & js values, skip table lines, improve handling of
 ; option selected, stop adding crlf; add formLabel, getTemplate;
 ; in putErrMsg2 don't insert errors if nowhere to put them, refine
 ; insError; in unvalue & value handle missing value=; in wsPostForm don't
 ; quit on error for sbform2; in replaceSrc skip inserting see service if
 ; href is javascript.
 ;
 ; 2018-01-03 ven/gpl %*1.8t04 %wfhform: in wsGetForm call SAMISUBS^SAMIFRM
 ; & replace line, comment out post action; in wsPostForm only return fm
 ; record & set status if sbform.
 ;
 ; 2018-01-17 ven/gpl %*1.8t04 %wfhform: in wsGetForm use filter("fvalue")
 ; if present to set sid, combine handling of sbform & sbform2, comment
 ; out temp elcap forms hack, overhaul processing of action, struggle w/
 ; checkboxes & radio buttons; in getTemplate comment out special handling
 ; of sbform & sbform2; in uncheck & check wrestle with radio buttons &
 ; checkboxes; in wsPostForm generalize handling of sbforms; in replaceSrc
 ; handle quotes.
 ;
 ; 2018-01-22 ven/toad %1.8t04 %wful: create development-log routine.
 ; %wf: convert entry points to ppi/api style & routine to mash style,
 ;   rearrange subroutines.
 ; %wfhform: passim add header comments, r/all local calls w/calls through
 ;   ^%wf, spell out mumps language elements, add do-dot quits, white space,
 ; rearrange subroutines.
 ;
 ;@contents
 ; %wf: write form ppi & api library
 ; %wffiler: fileman-to-form interfaces
 ; %wffmap: fileman-to-form maps
 ; %wfhform: graph-to-form interfaces
 ; %wful: primary-development log
 ; %wfut: unit tests [tbd]
 ;
 ;
 ;
eor ; end of routine %wful
