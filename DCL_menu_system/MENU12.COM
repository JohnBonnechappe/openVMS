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
$ write sys$output ESC, "#3" , "   Johno's SQL INSERT Menu"
$ write sys$output ESC, "#4" , "   Johno's SQL INSERT Menu"
$ write sys$output " "
$ write sys$output " "
$ write sys$output "1.  ORDER SELL and SUPPLIER_ITEM (1)"
$ write sys$output "2.  ITEM_ID deleted records (2)"
$ write sys$output "3.  GENERICS  (3)"
$ write sys$output "4.  ITEM_ID range records (4)"
$ write sys$output "5.  PLUs (5)"
$ write sys$output "99. Exit Menu"
$ write sys$output "999. Exit "
$ write sys$output " "
$ inquire aaa1 "Make a choice then press RETURN"
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
$ if aaa1 .eqs. 1 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLI1.COM
$ if aaa1 .eqs. 2 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLI2.COM
$ if aaa1 .eqs. 3 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLI3.COM
$ if aaa1 .eqs. 4 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLI4.COM
$ if aaa1 .eqs. 5 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLI5.COM
$
$afttest:
$ if aaag .eqs. "E" then goto menuend
$ if mtype .nes. "M" then inquire aaa1 "''BEL Press RETURN to continue"
$ goto menu
$
$menuend:
$ exit
