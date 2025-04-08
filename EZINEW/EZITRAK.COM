! Johno's modular menu system
! Version 05-02-91
!
$begin:
$ set noverify
$ aaag	      == "C"               !C=continue  E=exit
$ mtype	       = " "               ! menu has not been seen yet
$ mes1	       = "   "
$ ESC[0,8]     = 27
$ BEL[0,8]     = 7
$ BOLD_ON      = ESC + "[1m"
$ BOLD_OFF     = ESC + "[0m"
$ MARGIN_TOP   = ESC + "[1;1H"                 !cursor to line 1 in margin
$ ERASE_TO_BOT = ESC + "[?0J"                  !erase to end of display
$ TOP_CLR      = MARGIN_TOP + ERASE_TO_BOT     !clear & top
$ HOM_CLR      = ESC + "[H" + ESC + "[2J"      !home then clear screen
$ UP_1_LINE    = ESC + "[1A"                   !up one line
$ UP_2_LINE    = ESC + "[2A"                   !up two line
$ UP_3_LINE    = ESC + "[3A"                   !up three line
$ UP_4_LINE    = ESC + "[4A"                   !up four line
$ !these three symbols should be set up globally for all menus to use
$ REPLY_EXIT   = "999"                         !enter this to exit
$ REPLY_PREV   = "99"                          !enter this to go to prev menu
$ REPLY_HELP   = "?"                           !enter this to go to help
$
$! Logicals
$
$ on control_y then goto menu:
$ goto paramtest
$
$paramtest:
$ if p1 .nes. ""
$ then
$     aaa1 = p1
$     goto pretest
$ else
$     goto menu
$ endif
$
$menu:
$ mtype	       = "M"               !have seen menu
$ write sys$output HOM_CLR
$ write sys$output mes1
$ mcount = 0
$ mes1 = "   "
$ show time
$ write sys$output " "
$ write sys$output ESC, "#3" , "   EZITRAK Menu"
$ write sys$output ESC, "#4" , "   EZITRAK Menu"
$ write sys$output " "
$ mcount = mcount + 1
$ write sys$output mcount, ".  Create/Modify a Problem"
$ mcount = mcount + 1
$ write sys$output mcount, ".  Browse Problems"
$ mcount = mcount + 1
$ write sys$output mcount, ".  Solve/Progress a Problem"
$ mcount = mcount + 1
$ write sys$output mcount, ".  Update Person Table"
$ mcount = mcount + 1
$ write sys$output mcount, ".  Update Application Table"
$ write sys$output " "
$ write sys$output ESC + "[4m" + "                                       " -
  + "                                       " + ESC + "[0m"
$ goto margins
$
$margins:
$ margin_top_line = 10 + mcount
$ if margin_top_line .lt. 12 then margin_top_line = 12
$ if margin_top_line .gt. 22 then margin_top_line = 22
$ write sys$output ESC + "[" + "'' margin_top_line';24r" !set top & bot margins
$ write sys$output ESC + "[" + "?6h"             !move only within margin
$ goto quiz
$
$quiz:
$ write sys$output TOP_CLR + REPLY_PREV + ". Exit Menu     " + REPLY_EXIT -
                          + ". Exit        " + REPLY_HELP + ".  Help"
$ inquire aaa1 "Make a choice then press RETURN"
$ goto pretest
$
$pretest:
$ if aaa1 .eqs. ""         then goto quiz
$ if aaa1 .eqs. REPLY_HELP then goto menuhelp
$ if aaa1 .eqs. REPLY_PREV then goto menuend
$ if aaa1 .eqs. REPLY_EXIT
$ then
$   aaag == "E"
$   goto menuend
$ endif
$ goto calls
$
$immediates :
$ write sys$output TOP_CLR
$ write sys$output UP_3_LINE
$ if aaa1 .eqs. 3 then dir
$ if aaa1 .eqs. 4 then dir/size/prot
$ inquire aaa1 "''BOLD_ON' Press RETURN to continue ''BOLD_OFF'"
$
$ if mtype .eqs. "M"
$ then
$     goto quiz
$ else
$     goto menuend
$ endif
$
$calls:
$!! write sys$output "work in progress please wait"
$    DEFINE/NOLOG EZITRAK_VMS   SN_FRS_DISK:<MBS.JBRADDOC.EZITRAK>
$    DEFINE/NOLOG EZITRAK_DATABASE SN_FRS_DISK:[MBS.JBRADDOC.EZITRAK]EZITRAK
$    DEFINE/NOLOG EZITRAK011 EZITRAK_VMS:EZITRAK011
$    DEFINE/NOLOG EZITRAK031 EZITRAK_VMS:EZITRAK031
$    DEFINE/NOLOG EZITRAK041 EZITRAK_VMS:EZITRAK041
$    DEFINE/NOLOG EZITRAK051 EZITRAK_VMS:EZITRAK051
$    DEFINE/NOLOG EZITRAK061 EZITRAK_VMS:EZITRAK061
$ write sys$output ESC + "[" + "1;24r"        !set top and bot margins
$ write sys$output HOM_CLR
$ DEFINE/USER/NOLOG SYS$INPUT SYS$COMMAND
$ if aaa1 .eqs. 1 then RUN EZITRAK_VMS:EZITRAK001
$ if aaa1 .eqs. 2 then RUN EZITRAK_VMS:EZITRAK003
$ if aaa1 .eqs. 3 then RUN EZITRAK_VMS:EZITRAK004
$ if aaa1 .eqs. 4 then RUN EZITRAK_VMS:EZITRAK005
$ if aaa1 .eqs. 5 then RUN EZITRAK_VMS:EZITRAK006
$!! inquire aaa1 "''BOLD_ON' Press RETURN to continue ''BOLD_OFF'"
$ goto afttest
$
$afttest:
$ if aaag .eqs. "E" then goto menuend
$
$ if mtype .eqs. "M"
$ then
$     goto menu
$ else
$     goto menuend
$ endif
$
$menuhelp:
$ write sys$output TOP_CLR + "Welcome to JMM (John's Modular Menus) - EZITRAK"
$ write sys$output "Make a choice and then press return"
$ write sys$output "Choose " , REPLY_PREV , " to go to the previous menu"
$ write sys$output "      " , REPLY_EXIT , " to go to DCL"
$ write sys$output "Or you may type your option after $EZITRAK at DCL level"
$ write sys$output "Eg. $EZITRAK 1 takes you directly to the Problem Entry screen"
$ write sys$output " "
$ write sys$output "Function Keys are :"
$ write sys$output "  PF7 - Exit to Menu"
$ write sys$output "  PF8 - Previous Screen (Usually the header)"
$ write sys$output "  PF5 - The list of function keys"
$ write sys$output "  Warning - various other function keys do funny things too"
$ write sys$output "            I think PF4 brings up a hints panel on most panels"
$ write sys$output " "
$ inquire/nopunc aaa1 "''BOLD_ON' press RETURN ''BOLD_OFF'"
$ goto quiz
$
$menuend:
$ write sys$output ESC + "[" + "1;24r"        !set top and bot margins
$ write sys$output HOM_CLR
$ exit
