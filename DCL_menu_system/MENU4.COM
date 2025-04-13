$begin:
$ aaag	  == "C"
$ mtype	   = "J"
$ mes1	   = "   "
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
$ mes1 = "   "
$ show time
$ write sys$output " "
$ write sys$output " "
$ write sys$output ESC, "#3" , "   Johno's MISC Menu"
$ write sys$output ESC, "#4" , "   Johno's MISC Menu"
$ write sys$output " "
$ write sys$output " "
$ write sys$output "1.  Easy Guides (pending)"
$ write sys$output "2.  Not used"
$ write sys$output "3.  Not used"
$ write sys$output "99. Exit Menu"
$ write sys$output "999. Exit "
$ write sys$output " "
$ inquire aaa1 "Make a choice sucker then press RETURN"
$ goto pretest
$
$pretest:
$ write sys$output ESC + "[H" + ESC + "[2J"
$ if aaa1 .eqs. 99 then goto menuend
$ if aaa1 .eqs. 999 
$ then
$   aaag == "E"
$   goto menuend
$ endif
$ if mtype .nes. "M" then write sys$output "SQL in progress please wait"
$ goto menutest
$
$menutest:
!$ if aaa1 .eqs. 1 then @ <FRSDEV.JXB.MENU>MENU41.COM
!$ if aaa1 .eqs. 2 then @ <FRSDEV.JXB.SQL>SQLA2.COM
!$ if aaa1 .eqs. 3 then @ <FRSDEV.JXB.SQL>SQLA3.COM
$
$afttest:
$ if aaag .eqs. "E" then goto menuend
$ if mtype .nes. "M" then inquire aaa1 "''BEL Press RETURN to continue bozo"
$ goto menu
$
$menuend:
$ exit
