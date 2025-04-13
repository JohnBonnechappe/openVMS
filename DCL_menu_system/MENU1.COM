$begin:
$ aaag	  == "C"
$ mtype	   = "M"
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
$ write sys$output ESC, "#3" , "   Johno's SQL Menu"
$ write sys$output ESC, "#4" , "   Johno's SQL Menu"
$ write sys$output " "
$ write sys$output " "
$ write sys$output "1.   SELECTS"
$ write sys$output "2.   INSERTS"
$ write sys$output "3.   UPDATES"
$ write sys$output "4.   MISC"
$ write sys$output "5.   NEW RELEASES"
$ write sys$output "90.  LSE"
$ write sys$output "99.  Exit Menu"
$ write sys$output "999. Exit "
$ write sys$output " "
$ inquire aaa1 "Make a choice then press RETURN"
$ goto pretest
$
$pretest:
$ write sys$output ESC + "[H" + ESC + "[2J"
$ if aaa1 .eqs. 99  then goto menuend
$ if aaa1 .eqs. 999 
$ then
$   aaag == "E"
$   goto menuend
$ endif
$ if mtype .nes. "M" then write sys$output "SQL in progress please wait"
$ goto menutest
$
$menutest:
$ if aaa1 .eqs. 1 then @ SN_CNW_USER:<JBRADDOC.MENU>MENU11.COM
$ if aaa1 .eqs. 2 then @ SN_CNW_USER:<JBRADDOC.MENU>MENU12.COM
$ if aaa1 .eqs. 3 then @ SN_CNW_USER:<JBRADDOC.MENU>MENU13.COM
$ if aaa1 .eqs. 4 then @ SN_CNW_USER:<JBRADDOC.MENU>MENU14.COM
$ if aaa1 .eqs. 5 then @ SN_CNW_USER:<JBRADDOC.MENU>MENU15.COM
$ if aaa1 .eqs. 90 then L
$
$afttest:
$ if aaag .eqs. "E" then goto menuend
$ if mtype .nes. "M" then inquire aaa1 "''BEL Press RETURN to continue"
$ goto menu
$
$menuend:
$ exit
