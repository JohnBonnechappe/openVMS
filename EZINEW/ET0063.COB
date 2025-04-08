IDENTIFICATION DIVISION.
*
*******************************************************************************
*                                                                             *
*   Program ID   : EZITRAK0063                                                *
*   Program Name : Application Details Table                                  *
*   Summary      : On startup the search parameters screen is displayed. When *
*                  parameters are entered, the program searches the           *
*                  APPLICATION_DETAILS table in the EZITRAK database and      *
*                  displays the application browse screen with the found appl *
*                  details.                                                   *
*                                                                             *
*   SCREENS USED : EZITRAK061                                                 *
*                : EZITRAK062                                                 *
*                                                                             *
*   TABLES  USED : APPLICATION_DETAILS       (Input-Output)                   *
*                                                                             *
*******************************************************************************
*
/
PROGRAM-ID. EZITRAK0063.
ENVIRONMENT DIVISION.
* DATE-WRITTEN. 16-02-92
* AUTHOR. JOHN
CONFIGURATION SECTION.
    SOURCE-COMPUTER. VAX-8650.
    OBJECT-COMPUTER. VAX-8650.
/
DATA DIVISION.
/
WORKING-STORAGE SECTION.
    copy "EZITRAK_CDD.EZITRAK061_REC"  from dictionary
          replacing EZITRAK061_REC BY OLD-EZITRAK061-REC.

    copy "EZITRAK_CDD.APPLICATION_DETAILS_REC"       from dictionary.
/
 01  TMP-FLAG                                    PIC X.
 01  STAGE-OF-PROCESSING                         PIC 99.
 01  PERSON-FOUND-FLAG                           PIC X.

 01  SQLCA.
     03  SQLCAID                                 PIC X(8) VALUE "SQLCA   ".
     03  SQLCABC                                 PIC S9(9) COMP  VALUE 128.
     03  SQLCODE                                 PIC S9(9) COMP.
         88  SQL_SUCCESS                         VALUE 0.
         88  SQL_NOT_FOUND                       VALUE 100.
         88  SQL_DUPLICATE_IDX                   VALUE -803.
         88  SQL_LOCKED_RECORD                   VALUE -1003.
     03  SQLERRML                                PIC S9(4) COMP VALUE 0.
     03  SQLERRMC                                PIC X(70).
     03  SQLERRD                                 PIC S9(9) COMP OCCURS 6.
     03  SQLWARN                                 PIC X(8).
     03  SQLEXT                                  PIC X(8).

 01 Rdb$MESSAGE_VECTOR EXTERNAL GLOBAL.
     03 Rdb$LU_NUM_ARGUMENTS                     PIC S9(9) COMP.
     03 Rdb$LU_STATUS                            PIC S9(9) COMP.
     03 Rdb$ALU_ARGUMENTS                        OCCURS 18.
         05 Rdb$LU_ARGUMENTS                     PIC S9(9) COMP.

 01  ERR_RET                                     PIC S9(9) COMP.
 01  ERR_SUB                                     PIC  9(9) COMP.
 01  ERR_FLAGS                                   PIC  9(9) COMP.
 01  ERR_LENGTH                                  PIC  9(9) COMP.
 01  ERR_BUFFER                                  PIC  X(80).
 01  SS$_NORMAL                                  PIC S9(9) COMP
     VALUE IS EXTERNAL SS$_NORMAL.

 01  JPI_USERNAME                                PIC S9(9) COMP VALUE 514.

 01  CURRENT_USER_ID                             PIC X(8).
 01  CURRENT_DATE_BIN                            PIC S9(11)V9(7) COMP.
 01  SAVED_PERSON_TMSTAMP                        PIC S9(11)V9(7) COMP.
 01  TRANSACTION_BEGUN_FLAG                      PIC X.

 01  EXIT_STATUS                                 PIC S9(9) COMP.

 01  SUB1                                        PIC S9(4) COMP.
 01  SUB1_MAX                                    PIC S9(4) COMP VALUE 20.
*
* ************ TEMP ITEM -- REMOVE AFTER PROG IS OK ***************
 01  TEMP-COUNTER                                PIC S9(9) COMP.


/
LINKAGE SECTION.
    copy "EZITRAK_CDD.EZITRAK062_REC"  from dictionary.

PROCEDURE DIVISION USING  EZITRAK062_REC
                   GIVING EXIT_STATUS.
MAIN-PARA.
    PERFORM 1000-INITIALISATION.

    PERFORM 5000_UPDATE_APPLICATION_RECORDS.

*    PERFORM 8000-FINALISATION.

    GO TO 9900-EXIT.
*
1000-INITIALISATION.
    MOVE ZERO    TO SQLCODE.
    MOVE ZERO    TO EXIT_STATUS.
    MOVE "N"     TO TRANSACTION_BEGUN_FLAG.   
/
5000_UPDATE_APPLICATION_RECORDS.
    PERFORM 7100_START_TRAN_RW.

    MOVE "Y" TO TMP_FLAG.
    PERFORM 6550_UPDATE_APPLICATION_DESC VARYING SUB1
                                      FROM 1 BY 1
                                      UNTIL SUB1 > SUB1_MAX
                                      OR STAGE_OF_PROCESSING = 99
                                      OR TMP_FLAG = "N".


    PERFORM 7800_CMT_TRAN.
/
6550_UPDATE_APPLICATION_DESC.
    EVALUATE UPDATE_IND OF EZITRAK062_REC ( SUB1 )
    WHEN "I"
        PERFORM 6552_INSERT_APPLICATION_DESC
    WHEN "D"
        PERFORM 7500_SELECT_APPLICATION_DESC
        IF TMP_FLAG = "Y"
            PERFORM 6554_DELETE_APPLICATION_DESC
        END-IF
    WHEN "M"
        PERFORM 7500_SELECT_APPLICATION_DESC
        IF TMP_FLAG = "Y"
            PERFORM 6556_UPDATE_APPLICATION_DESC
        END-IF
    WHEN OTHER
        CONTINUE
    END-EVALUATE.
*
6552_INSERT_APPLICATION_DESC.
    MOVE APPLICATION_ID     OF EZITRAK062-REC ( SUB1 )
      TO APPLICATION_ID     OF APPLICATION_DETAILS_REC.

    MOVE APPLICATION_DESC   OF EZITRAK062-REC ( SUB1 )
      TO APPLICATION_DESC   OF APPLICATION_DETAILS_REC.

    PERFORM 8600-GET-TIME.
    MOVE CURRENT_DATE_BIN TO REC_TMSTAMP OF APPLICATION_DETAILS_REC.

    PERFORM 8700-GET-USER.
    MOVE CURRENT_USER_ID TO REC_USER     OF APPLICATION_DETAILS_REC.

    CALL "ET_IR_APPLICATION_DETAILS" USING SQLCA
                                APPLICATION_ID        OF APPLICATION_DETAILS_REC
                                APPLICATION_DESC      OF APPLICATION_DETAILS_REC
                                REC_USER         OF APPLICATION_DETAILS_REC
                                REC_TMSTAMP      OF APPLICATION_DETAILS_REC.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN SQL_DUPLICATE_IDX
        MOVE 31 TO STAGE-OF-PROCESSING
        MOVE "LINE INSERTED BY ANOTHER USER" TO ERROR_MESSAGE OF EZITRAK062_REC
        MOVE "N" TO TMP_FLAG
    WHEN OTHER
        DISPLAY "ERROR OF APPLICATION_SOL_IR CODE=" SQLCODE WITH CONVERSION
        MOVE 100  TO EXIT_STATUS
        GO TO 9900_EXIT
    END-EVALUATE.
*
6554_DELETE_APPLICATION_DESC.
    MOVE APPLICATION_ID OF EZITRAK062-REC ( SUB1 )
      TO APPLICATION_ID OF APPLICATION_DETAILS_REC.

    CALL "ET_DR_APPLICATION_DETAILS" USING SQLCA
                                APPLICATION_ID        OF APPLICATION_DETAILS_REC


    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN SQL_NOT_FOUND
        MOVE 31 TO STAGE-OF-PROCESSING
        MOVE "N" TO TMP_FLAG
        MOVE "LINE DELETED BY ANOTHER USER" TO ERROR_MESSAGE OF EZITRAK062_REC
    WHEN SQL_LOCKED_RECORD
        MOVE 31 TO STAGE-OF-PROCESSING
        MOVE "N" TO TMP_FLAG
        MOVE "RECORD IS LOCKED BY ANOTHER USER, PLEASE TRY AGAIN"
          TO ERROR_MESSAGE OF EZITRAK062_REC
    WHEN OTHER
        DISPLAY "ERROR OF APPLICATION_DR CODE=" SQLCODE WITH CONVERSION
        MOVE 100  TO EXIT_STATUS
        GO TO 9900_EXIT
    END-EVALUATE.
*
6556_UPDATE_APPLICATION_DESC.
    MOVE APPLICATION_ID     OF EZITRAK062-REC ( SUB1 )
      TO APPLICATION_ID     OF APPLICATION_DETAILS_REC.

    MOVE APPLICATION_DESC   OF EZITRAK062-REC ( SUB1 )
      TO APPLICATION_DESC   OF APPLICATION_DETAILS_REC.

    PERFORM 8600-GET-TIME.
    MOVE CURRENT_DATE_BIN TO REC_TMSTAMP OF APPLICATION_DETAILS_REC.

    PERFORM 8700-GET-USER.
    MOVE CURRENT_USER_ID TO REC_USER     OF APPLICATION_DETAILS_REC.

    CALL "ET_UR_APPLICATION_DETAILS" USING SQLCA
                                APPLICATION_ID        OF APPLICATION_DETAILS_REC
                                APPLICATION_DESC      OF APPLICATION_DETAILS_REC
                                REC_USER         OF APPLICATION_DETAILS_REC
                                REC_TMSTAMP      OF APPLICATION_DETAILS_REC.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN SQL_NOT_FOUND
        MOVE 31 TO STAGE-OF-PROCESSING
        MOVE "LINE DELETED BY ANOTHER USER" TO ERROR_MESSAGE OF EZITRAK062_REC
        MOVE "N" TO TMP_FLAG
    WHEN SQL_DUPLICATE_IDX
        MOVE 31 TO STAGE-OF-PROCESSING
        MOVE "N" TO TMP_FLAG
        MOVE "LINE INSERTED BY ANOTHER USER" TO ERROR_MESSAGE OF EZITRAK062_REC
    WHEN SQL_LOCKED_RECORD
        MOVE 31 TO STAGE-OF-PROCESSING
        MOVE "N" TO TMP_FLAG
        MOVE "RECORD IS LOCKED BY ANOTHER USER, PLEASE TRY AGAIN"
          TO ERROR_MESSAGE OF EZITRAK062_REC
    WHEN OTHER
        DISPLAY "ERROR OF APPLICATION_UR CODE=" SQLCODE WITH CONVERSION
        MOVE 100  TO EXIT_STATUS
        GO TO 9900_EXIT
    END-EVALUATE.
/
7000-START_TRAN_RO.
    CALL "ET_ST_RO_APPLICATION" USING SQLCA.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        MOVE "Y" TO TRANSACTION_BEGUN_FLAG
    WHEN OTHER
        DISPLAY "ST_RO NG CODE=" SQLCODE WITH CONVERSION
        MOVE 100  TO EXIT_STATUS
        GO TO   9900-EXIT
    END-EVALUATE.
/
7100-START_TRAN_RW.
    CALL "ET_ST_RW_APPLICATION" USING SQLCA.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        MOVE "Y" TO TRANSACTION_BEGUN_FLAG
    WHEN SQL_LOCKED_RECORD
        MOVE 31 TO STAGE-OF-PROCESSING
        MOVE "RECORD IS LOCKED BY ANOTHER USER, PLEASE TRY AGAIN"
          TO ERROR_MESSAGE OF EZITRAK062_REC
    WHEN OTHER
        DISPLAY "ST_RW NG CODE=" SQLCODE WITH CONVERSION
        MOVE 100  TO EXIT_STATUS
        GO TO   9900-EXIT
    END-EVALUATE.
/
7500_SELECT_APPLICATION_DESC.
    MOVE APPLICATION_ID  OF EZITRAK062-REC ( SUB1 )
      TO APPLICATION_ID  OF APPLICATION_DETAILS_REC.

    CALL "ET_SS_APPLICATION_DETAILS" USING SQLCA
                                APPLICATION_ID        OF APPLICATION_DETAILS_REC
                                APPLICATION_DESC      OF APPLICATION_DETAILS_REC
                                REC_USER         OF APPLICATION_DETAILS_REC
                                REC_TMSTAMP      OF APPLICATION_DETAILS_REC.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN SQL_NOT_FOUND
        MOVE 31 TO STAGE-OF-PROCESSING
        MOVE "LINE DELETED BY ANOTHER USER" TO ERROR_MESSAGE OF EZITRAK062_REC
        MOVE "N" TO TMP_FLAG
    WHEN OTHER
        DISPLAY "ERROR OF APPLICATION_SOL_SS CODE=" SQLCODE WITH CONVERSION
        MOVE 100  TO EXIT_STATUS
        GO TO 9900_EXIT
    END-EVALUATE.
/
7800-CMT_TRAN.
    CALL "ET_CMT_TRN" USING SQLCA.

    MOVE "N" TO TRANSACTION_BEGUN_FLAG.
    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN OTHER
        DISPLAY "CMT_TRN NG CODE=" SQLCODE WITH CONVERSION
        GO TO   9900-EXIT
    END-EVALUATE.
/
7900-RLB_TRAN.
    CALL "ET_RLB_TRN" USING SQLCA.

    MOVE "N" TO TRANSACTION_BEGUN_FLAG.
    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN OTHER
        DISPLAY "RLB_TRN NG CODE=" SQLCODE WITH CONVERSION
        GO TO   9900-EXIT
    END-EVALUATE.
*
8600-GET-TIME.
    CALL "SYS$GETTIM" USING BY REFERENCE CURRENT_DATE_BIN.
*
8700-GET-USER.
    CALL "LIB$GETJPI" USING BY REFERENCE JPI_USERNAME
                             OMITTED
                             OMITTED
                             OMITTED
                             BY DESCRIPTOR CURRENT_USER_ID.
*
9900-EXIT.
    IF NOT SQL_SUCCESS
        MOVE 15 TO ERR_FLAGS
        PERFORM 9910_ERROR VARYING ERR_SUB FROM 1 BY 1
                           UNTIL ERR_SUB > Rdb$LU_NUM_ARGUMENTS.

    IF TRANSACTION_BEGUN_FLAG = "Y"
        PERFORM 7900_RLB_TRAN.

    EXIT PROGRAM.

9910_ERROR.
        call "sys$getmsg" using
                                 by value      Rdb$LU_ARGUMENTS(ERR_SUB)
                                 by reference  err_length
                                 by descriptor err_buffer
                                 by value      err_flags
                                 omitted
                          GIVING               ERR_RET.

         DISPLAY ERR_BUFFER.
*
* **************** END OF SOURCE EZITRAK0063 ****************
