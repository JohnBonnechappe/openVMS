$begin:
$ set noverify
$ aaag == "C"
$ mtype	   = " " !menu not seen yet
$ mes1 = "   "
$ ESC[0,8] = 27
$ BEL[0,8] = 7
$ on control_y then goto menu:
$ goto paramtest
$
$paramtest:
$ if p1 .nes. ""
$ then
$     aaa1 = p1
$     goto menutest
$ else
$     goto menu
$ endif
$
$menu:
$ write sys$output ESC + "[H" + ESC + "[2J"
$ write sys$output mes1
$ mcount = 0
$ mtype    = "M" !menu seen
$ mes1 = "   "
$ show time
$ write sys$output " "
$ write sys$output " "
$ write sys$output ESC, "#3" , "   Johno's EZITRAK development Menu"
$ write sys$output ESC, "#4" , "   Johno's EZITRAK development Menu"
$ write sys$output " "
$ write sys$output " "
$ write sys$output "1.  LOGICALS"
$ write sys$output "2.  ALL"
$ write sys$output "5.  CREATE DATABASE"
$ write sys$output "6.  LOAD DATABASE"
$ write sys$output "8.  RECORDS"
$ write sys$output "9.  COBOLS"
$ write sys$output "10. SQLMODS"
$ write sys$output "12. REQUESTS"
$ write sys$output "13. REPLACE LIBRARY"
$ write sys$output "14. BUILD LIBRARY"
$ write sys$output "20. RUN  ENTER PROBLEM DETAILS"
$ write sys$output "21. RUN  SEARCH PROBLEMS"
$ write sys$output "22. RUN  PERSON DETAILS"
$ write sys$output "99. Exit Menu "
$ write sys$output "999. Exit "
$ write sys$output " "
$ inquire aaa1 "Make a choice then press RETURN"
$ goto pretest
$
$pretest:
$ write sys$output ESC + "[H" + ESC + "[2J"
$ if aaa1 .eqs. 99 then goto exit
$ if aaa1 .eqs. 999 
$ then
$   aaag == "E"
$   goto exit
$ endif
$ goto menutest
$
$menutest:
$ if aaa1 .eqs. 1  then gosub logicals
$ if aaa1 .eqs. 2  then gosub all
$ if aaa1 .eqs. 5  then gosub database
$ if aaa1 .eqs. 6  then gosub load_database
$ if aaa1 .eqs. 8  then gosub records
$ if aaa1 .eqs. 9  then gosub cobols
$ if aaa1 .eqs. 10 then gosub sqlmods
$ if aaa1 .eqs. 12 then gosub requests
$ if aaa1 .eqs. 13 then gosub library
$ if aaa1 .eqs. 14 then gosub build
$ if aaa1 .eqs. 20 then gosub run_enter_problem
$ if aaa1 .eqs. 21 then gosub run_search_problem
$ if aaa1 .eqs. 22 then gosub run_person
$
$afttest:
$ if aaag .eqs. "E" then goto exit
$ if mtype .eqs. "M"
$ then
$     goto menu
$else
$     goto exit
$endif
$
$LOGICALS :
$    DEFINE/NOLOG EZITRAK_VMS   SN_FRS_DISK:<MBS.JBRADDOC.EZITRAK>
$    DEFINE/NOLOG EZITRAK_CDD  "CDD$TOP.USERS.USER_JBRADDOC.EZITRAK"
$    DEFINE/NOLOG EZITRAK_DATABASE SN_FRS_DISK:[MBS.JBRADDOC.EZITRAK]EZITRAK
$    DEFINE/NOLOG/J EZITRAK_DATABASE SN_FRS_DISK:[MBS.JBRADDOC.EZITRAK]EZITRAK
$    RETURN
$
$ALL :
$    GOSUB RECORDS
$    GOSUB COBOLS
$    GOSUB REQUESTS
$    GOSUB LIBRARY
$    GOSUB BUILD
$    RETURN
$
$DATABASE :
$ if mtype .nes. "M" then  write sys$output "Install in progress please wait"
$    @EZITRAK_VMS:EZITRAK_DB_CREATE.COM
$    RETURN
$ if mtype .nes. "M" then inquire aaa1 "''BEL Press RETURN to continue bozo"
$
$LOAD_DATABASE :
$ if mtype .nes. "M" then  write sys$output "Install in progress please wait"
$    @EZITRAK_VMS:EZITRAK_LOAD.COM
$    RETURN
$ if mtype .nes. "M" then inquire aaa1 "''BEL Press RETURN to continue bozo"
$
$RECORDS :
$ if mtype .nes. "M" then  write sys$output "Install in progress please wait"
$    CDDL/REPL EZITRAK_DB_RECS.DDL
$    CDDL/REPL EZITRAKCOM_REC.DDL
$    CDDL/REPL EZITRAK011_REC.DDL
$    CDDL/REPL EZITRAK012_REC.DDL
$!    CDDL/REPL JBSC21.DDL
$!    CDDL/REPL JBSC22.DDL
$    RETURN
$ if mtype .nes. "M" then inquire aaa1 "''BEL Press RETURN to continue bozo"
$
$COBOLS :
$    COB JB001
$    COB JB021
$    LINK JB001
$    LINK JB021
$    RETURN
$
$SQLMODS :
$    SQLMOD EZITRAK_VMS:EZITRAK01_SQL.SQLMOD
$    SQLMOD EZITRAK_VMS:EZITRAK05_SQL.SQLMOD
$    SQLMOD EZITRAK_VMS:EZITRAK03_SQL.SQLMOD
$    RETURN
$
$REQUESTS :
$    SET VER
$    RDU @EZITRAK011.RDF
$    RDU @EZITRAK012.RDF
$!    RDU @JBSC21.RDF
$!    RDU @JBSC22.RDF
$    SET NOVER
$    RETURN
$
$LIBRARY :
$    RDU @EZITRAKLIB.LDF
$    RETURN
$
$BUILD :
$    SET VER
$    RDU BUILD LIBRARY EZITRAK_CDD.EZITRAK_RLB EZITRAK.RLB
$    SET NOVER
$    RETURN
$
$RUN_ENTER_PROBLEM :
$    RUN EZITRAK_VMS:EZITRAK001
$    RETURN
$
$RUN_SEARCH_PROBLEM :
$    RUN EZITRAK_VMS:JB021
$    RETURN
$
$RUN_PERSON :
$    RUN EZITRAK_VMS:JB021
$    RETURN
$
$EXIT :
$    EXIT
