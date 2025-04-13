$begin:
$ aaag == "C"
$ mtype	   = "J"
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
$ mes1 = "   "
$ show time
$ write sys$output " "
$ write sys$output " "
$ write sys$output ESC, "#3" , "   Johno's SQL SELECT Menu"
$ write sys$output ESC, "#4" , "   Johno's SQL SELECT Menu"
$ write sys$output " "
$ write sys$output " "
$ write sys$output "1.  CODES (5)"
$ write sys$output "2.  CODES TYPES (6)"
$ write sys$output "3.  GENERICS > 11 (4)"
$ write sys$output "4.  NEXT ITEM (2)"
$ write sys$output "5.  ORD ITEM - NAME (7)"
$ write sys$output "6.  ORD ITEM - DEPT PRV-LAB EXP (9)"
$ write sys$output "7.  SELL ITEM - SIZE UNITS (10)"
$ write sys$output "8.  SUPPLIER (3)"
$ write sys$output "9.  SUPLIER ITEM (8)"
$ write sys$output "10. ORD SELL & SUPL (1)"
$ write sys$output "11. PLUs (11)"
$ write sys$output "12. DCs (12)"
$ write sys$output "13. BUS RGN ORD ITM (13)          14. BUS RGN SELL ITM (14)"
$ write sys$output "15. DC ORD ITM (15)               16. CR ORD ITM (16)"
$ write sys$output "99. Exit Menu "
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
$ if mtype .nes. "M" then  write sys$output "SQL in progress please wait"
$ goto menutest
$
$menutest:
$ if aaa1 .eqs. 1 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLS5.COM
$ if aaa1 .eqs. 2 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLS6.COM
$ if aaa1 .eqs. 3 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLS4.COM
$ if aaa1 .eqs. 4 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLS2.COM
$ if aaa1 .eqs. 5 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLS7.COM
$ if aaa1 .eqs. 6 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLS9.COM
$ if aaa1 .eqs. 7 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLS10.COM
$ if aaa1 .eqs. 8 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLS3.COM
$ if aaa1 .eqs. 9 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLS8.COM
$ if aaa1 .eqs. 10 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLS1.COM
$ if aaa1 .eqs. 11 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLS11.COM
$ if aaa1 .eqs. 12 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLS12.COM
$ if aaa1 .eqs. 13 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLS13.COM
$ if aaa1 .eqs. 14 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLS14.COM
$ if aaa1 .eqs. 15 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLS15.COM
$ if aaa1 .eqs. 16 then @ SN_FRS_DISK:<FRSDEV.JXB.SQL>SQLS16.COM
$
$afttest:
$ if aaag .eqs. "E" then goto menuend
$ if mtype .nes. "M" then inquire aaa1 "''BEL Press RETURN to continue"
$ goto menu
$
$menuend:
$ exit
