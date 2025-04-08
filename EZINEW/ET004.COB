IDENTIFICATION DIVISION.
*
*******************************************************************************
*                                                                             *
*   Program ID   : EZITRAK004                                                 *
*   Program Name : Problem solution update screen                             *
*   Summary      : On startup the problem number screen is displayed. When a  *
*                  problem number is entered, the program searches the        *
*                  PROBLEM_DETAILS table in the EZITRAK database and          *
*                  displays the problem progress/solution screen with the     *
*                  problem details. The record must exist.                    *
*                                                                             *
*                  The PROBLEM_SOLUTION_DETAILS table is also read to see if  *
*                  any records exist.                                         *
*                                                                             *
*                  All changed details on the screen are validated.           *
*                  Valid data from each screen is written to a record in the  *
*                  PROBLEM_DETAILS table. If a description of the solution is * 
*                  entered or changed it is written to the solution table.    *
*                                                                             *
*   SCREENS USED : EZITRAK041                                                 *
*                : EZITRAK042                                                 *
*                                                                             *
*   TABLES  USED : PROBLEM_DETAILS          (Input-output)                    *
*                  PROBLEM_SOLUTION_DETAILS (Input-output)                    *
*                  PERSON_DETAILS           (Input)                           *
*                  APPLICATION_DETAILS      (Input)                           *
*                  STATUS_DETAILS           (Input)                           *
*                  PRIORITY_DETAILS         (Input)                           *
*                                                                             *
*******************************************************************************
*
/
PROGRAM-ID. EZITRAK004.
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
    copy "EZITRAK_CDD.EZITRAK041_REC"  from dictionary.
    copy "EZITRAK_CDD.EZITRAK042_REC"  from dictionary.
    copy "EZITRAK_CDD.EZITRAK042_REC"  from dictionary
          replacing EZITRAK042_REC BY OLD-EZITRAK042-REC.

    copy "EZITRAK_CDD.PROBLEM_DETAILS_REC"          from dictionary.
    copy "EZITRAK_CDD.PROBLEM_SOLUTION_DETAILS_REC" from dictionary.
    copy "EZITRAK_CDD.PERSON_DETAILS_REC"           from dictionary.
/
 01  SESSION-ID                                  PIC X(16) GLOBAL.
 01  DEVICE-NAME                                 PIC X(9)  VALUE "SYS$INPUT".
 01  FORM-FILE                                   PIC X(10) VALUE
                                                    "EZITRAK041".
 01  FORMS-STATUS                                PIC S9(9) COMP GLOBAL.
 01  SINGLE_REC_COUNT                            PIC S9(5) COMP VALUE 1 GLOBAL.
 01  NO-TIMEOUT                                  PIC S9(9) COMP VALUE 0 GLOBAL.
 01  ORIGINAL_REQ                                PIC S9(9) COMP VALUE 0 GLOBAL.
 01  NO-OPTIONS                                  PIC S9(9) COMP VALUE 0 GLOBAL.
 01  NO-SHAD                                     PIC S9(9) COMP VALUE 0 GLOBAL.
 01  SEND_REC_NAME                               PIC X(14).
 01  RECE-REC-NAME                               PIC X(14).

 01  HEADER_REC_NAME                             PIC X(14) VALUE
                                                    "EZITRAK041_REC".

 01  MAIN_REC_NAME                               PIC X(14) VALUE
                                                    "EZITRAK042_REC".

 01  INP_CTL_STRING                              PIC X(25) GLOBAL.
 01  OUT_CTL_STRING                              PIC X(25) GLOBAL.
 01  INP_CTL_COUNT                               PIC S9(9) COMP GLOBAL.
 01  OUT_CTL_COUNT                               PIC S9(9) COMP GLOBAL.

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
 01  SAVED_PROBLEM_TMSTAMP                       PIC S9(11)V9(7) COMP.
 01  TRANSACTION_BEGUN_FLAG                      PIC X.

 01  SUB1                                        PIC S9(4) COMP.
 01  SUB1_MAX                                    PIC S9(4) COMP VALUE 20.
 
*  this is the array af timestamps corresponding to every screen line in the
*  solution_desc table.
 01  WS_PS_TMSTAMP_ARRAY.
     03  WS_PS_TMSTAMP                           PIC S9(11)V9(7) COMP
                                                 OCCURS 20.
*
* ************ TEMP ITEM -- REMOVE AFTER PROG IS OK ***************
 01  TEMP-COUNTER                                PIC S9(9) COMP.
/
PROCEDURE DIVISION.
MAIN-PARA.
    PERFORM 1000-INITIALISATION.

    PERFORM DISTRIBUTOR-PARA UNTIL STAGE-OF-PROCESSING = 99.

    PERFORM 8000-FINALISATION.

    GO TO 9900-EXIT.
*
DISTRIBUTOR-PARA.
    IF STAGE-OF-PROCESSING = 10 OR 11
        PERFORM 2000-PROB-NUMBER-SCREEN.

    IF STAGE-OF-PROCESSING = 15
        PERFORM 3000-READ-PROBLEM-TABLES.

    IF STAGE-OF-PROCESSING = 30 OR 31
        PERFORM 6000-PROB-MODIFY-SCREEN.

    IF STAGE-OF-PROCESSING = 35
        PERFORM 6500-REWRITE-PROB-RECORD.

    ADD 1 TO TEMP-COUNTER.
    IF TEMP-COUNTER > 10
        DISPLAY "TEMP COUNTER EXCEEDED - PROGRAM MAY BE LOOPING"
        GO TO 9900-EXIT.
*
1000-INITIALISATION.
    MOVE 10      TO STAGE-OF-PROCESSING.
    MOVE ZERO    TO TEMP-COUNTER.
    MOVE ZERO    TO SQLCODE.
    MOVE "N"     TO TRANSACTION_BEGUN_FLAG.   

    PERFORM 1100-FORM-INIT.

1100-FORM-INIT.
    CALL "FORMS$ENABLE"
    USING
      OMITTED
      BY DESCRIPTOR  DEVICE_NAME
      BY DESCRIPTOR  SESSION_ID
      BY DESCRIPTOR  FORM-FILE,
    GIVING           FORMS-STATUS.

    IF FORMS-STATUS IS FAILURE 
        PERFORM 8300-FORMS-ERROR
        GO TO   9900-EXIT
    END-IF.
/
2000-PROB-NUMBER-SCREEN.
    IF STAGE_OF_PROCESSING = 10
        INITIALIZE EZITRAK041-REC
    END-IF.

    MOVE SPACE TO KEY_PRESSED OF EZITRAK041_REC.
    PERFORM 8100-REQUEST-01.
    MOVE SPACES  TO ERROR_MESSAGE OF EZITRAK041_REC.

    EVALUATE KEY_PRESSED OF EZITRAK041_REC
    WHEN "E"
        MOVE 99 TO STAGE-OF-PROCESSING
    WHEN OTHER
        IF PROBLEM_NUMBER OF EZITRAK041_REC = ZERO
            MOVE "A PROB NUMBER MUST BE ENTERED"
              TO ERROR_MESSAGE OF EZITRAK041_REC
            MOVE 11 TO STAGE-OF-PROCESSING
        ELSE
            MOVE 15 TO STAGE-OF-PROCESSING
        END-IF
    END-EVALUATE.
/
3000-READ-PROBLEM_TABLES.
    PERFORM 7000_START_TRAN_RO.

    MOVE PROBLEM-NUMBER OF EZITRAK041-REC
      TO PROBLEM-NUMBER OF PROBLEM_DETAILS_REC.

    PERFORM 7400_PROBLEM_SS.
    IF TMP-FLAG = "N"
        MOVE "THE PROB NUMBER IS NOT ON FILE"
          TO ERROR_MESSAGE OF EZITRAK041_REC
        MOVE 11 TO STAGE-OF-PROCESSING
    ELSE
        IF PROBLEM_STATUS OF PROBLEM_DETAILS_REC = "C"
            MOVE "THIS PROBLEM IS CLOSED - REOPEN IT IF YOU WANT TO MODIFY IT"
              TO ERROR_MESSAGE OF EZITRAK041_REC
            MOVE 11 TO STAGE-OF-PROCESSING
        ELSE
            MOVE 30 TO STAGE-OF-PROCESSING
            PERFORM 3100_GET_SOLUTION_DESC
            PERFORM 3500_GET_OTHER_DETAILS
        END-IF
    END-IF.

    PERFORM 7800_CMT_TRAN.
*
3100-GET_SOLUTION_DESC.
    INITIALIZE SOLUTION_DESC_TABLE OF EZITRAK042-REC.

    MOVE PROBLEM_NUMBER OF EZITRAK041-REC
      TO PROBLEM_NUMBER OF PROBLEM_SOLUTION_DETAILS_REC.

    CALL "ET_OC_PROBLEM_SOLUTION_DETAILS" USING SQLCA
                                 PROBLEM_NUMBER OF PROBLEM_SOLUTION_DETAILS_REC.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN SQL_LOCKED_RECORD
        MOVE 11 TO STAGE-OF-PROCESSING
        MOVE "RECORD IS LOCKED BY ANOTHER USER, PLEASE TRY AGAIN"
          TO ERROR_MESSAGE OF EZITRAK041_REC
    WHEN OTHER
        DISPLAY "ERROR OF PROBLEM_SOL_OC CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR ON OC" TO ERROR_MESSAGE OF EZITRAK041_REC
        GO TO 9900_EXIT
    END-EVALUATE.

    PERFORM 3150_FETCH UNTIL NOT SQL_SUCCESS.

    CALL "ET_CC_PROBLEM_SOLUTION_DETAILS" USING SQLCA.
                  
    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN OTHER
        DISPLAY "ERROR OF CC CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR ON CC" TO ERROR_MESSAGE OF EZITRAK041_REC
        GO TO 9900_EXIT
    END-EVALUATE.

3150_FETCH.
    CALL "ET_FC_PROBLEM_SOLUTION_DETAILS" USING SQLCA
                                 LINE_NUMBER          OF PROBLEM_SOLUTION_DETAILS_REC
                                 SOLUTION_DESC        OF PROBLEM_SOLUTION_DETAILS_REC
                                 REC_USER             OF PROBLEM_SOLUTION_DETAILS_REC
                                 REC_TMSTAMP          OF PROBLEM_SOLUTION_DETAILS_REC
    END-CALL.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        MOVE "Y" TO TMP_FLAG
        IF LINE_NUMBER OF PROBLEM_SOLUTION_DETAILS_REC <= SUB1_MAX
            MOVE SOLUTION_DESC OF PROBLEM_SOLUTION_DETAILS_REC
              TO SOLUTION_DESC OF EZITRAK042_REC
                          ( LINE_NUMBER OF PROBLEM_SOLUTION_DETAILS_REC )
            MOVE REC_TMSTAMP   OF PROBLEM_SOLUTION_DETAILS_REC
              TO WS_PS_TMSTAMP
                          ( LINE_NUMBER OF PROBLEM_SOLUTION_DETAILS_REC )
        ELSE
            DISPLAY "ERROR OF LINE NBR =" LINE_NUMBER OF PROBLEM_SOLUTION_DETAILS_REC WITH CONVERSION
        END-IF
    WHEN SQL_NOT_FOUND
        CONTINUE
    WHEN SQL_LOCKED_RECORD
        MOVE 11 TO STAGE-OF-PROCESSING
        MOVE "RECORD IS LOCKED BY ANOTHER USER, PLEASE TRY AGAIN"
          TO ERROR_MESSAGE OF EZITRAK041_REC
    WHEN OTHER
        DISPLAY "ERROR OF FC CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR FC" TO ERROR_MESSAGE OF EZITRAK041_REC
        GO TO 9900_EXIT
    END-EVALUATE.
*
3500-GET_OTHER_DETAILS.
    IF PERSON-ASSIGNED_ID OF PROBLEM_DETAILS-REC NOT = SPACES
        MOVE PERSON-ASSIGNED-ID OF EZITRAK042-REC
          TO PERSON-ID          OF PERSON_DETAILS_REC
        PERFORM 8500-READ-PERSON-TABLE
    END-IF.
/
6000-PROB-MODIFY-SCREEN.
    IF STAGE-OF-PROCESSING = 30
        INITIALIZE SOLUTION_DESC_HEADER OF EZITRAK042-REC
        MOVE CORRESPONDING
             PROBLEM_DETAILS_REC TO SOLUTION_DESC_HEADER OF EZITRAK042-REC
    END-IF.

    MOVE PERSON-DESC         OF PERSON_DETAILS_REC
      TO PERSON-ASSIGNED_DESC OF EZITRAK042-REC.

    MOVE EZITRAK042-REC                 TO OLD-EZITRAK042-REC.

    MOVE SPACE TO KEY_PRESSED OF EZITRAK042_REC.
    PERFORM 8100-REQUEST-02.
    MOVE SPACES  TO ERROR_MESSAGE OF EZITRAK042_REC.

    EVALUATE KEY_PRESSED OF EZITRAK042_REC
    WHEN "E"
        MOVE 99 TO STAGE-OF-PROCESSING
    WHEN "B"
        MOVE "RECORD NOT UPDATED" TO ERROR_MESSAGE OF EZITRAK041_REC
        MOVE 10 TO STAGE-OF-PROCESSING
    WHEN OTHER
        IF EZITRAK042-REC NOT = OLD-EZITRAK042-REC
            MOVE 35 TO STAGE-OF-PROCESSING
        ELSE
            MOVE "RECORD NOT UPDATED" TO ERROR_MESSAGE OF EZITRAK042_REC
            MOVE 31 TO STAGE-OF-PROCESSING
        END-IF
    END-EVALUATE.
/
6500-REWRITE-PROB-RECORD.
    PERFORM 7100_START_TRAN_RW.

    MOVE PROBLEM-NUMBER OF EZITRAK041-REC
      TO PROBLEM-NUMBER OF PROBLEM_DETAILS_REC.

    PERFORM 7400-PROBLEM_SS.

    IF TMP_FLAG = "Y"
        IF REC_TMSTAMP OF PROBLEM_DETAILS_REC = SAVED_PROBLEM_TMSTAMP
            PERFORM 7300-REWRITE-PROBLEM-RECORD
            MOVE "RECORD MODIFIED PLEASE CHECK THE SCREEN"
              TO ERROR_MESSAGE OF EZITRAK042_REC
            MOVE 31 TO STAGE-OF-PROCESSING
        ELSE
            MOVE "RECORD MODIFIED BY ANOTHER USER"
              TO ERROR_MESSAGE OF EZITRAK041_REC
            MOVE 10 TO STAGE-OF-PROCESSING
        END-IF
    ELSE
        MOVE "RECORD DELETED BY ANOTHER USER" TO ERROR_MESSAGE OF EZITRAK041_REC
        MOVE 10 TO STAGE-OF-PROCESSING
    END-IF.

    IF SOLUTION_DESC_TABLE OF EZITRAK042_REC
    =  SOLUTION_DESC_TABLE OF OLD_EZITRAK042_REC
        CONTINUE
    ELSE
        MOVE "Y" TO TMP_FLAG
        PERFORM 6550_UPDATE_SOLUTION_DESC VARYING SUB1
                                          FROM 1 BY 1
                                          UNTIL SUB1 > SUB1_MAX
                                          OR STAGE_OF_PROCESSING = 99
                                          OR TMP_FLAG = "N"
    END-IF.


    PERFORM 7800_CMT_TRAN.
/
6550_UPDATE_SOLUTION_DESC.
    IF SOLUTION_DESC_ELEMENT OF EZITRAK042_REC     ( SUB1 )
    =  SOLUTION_DESC_ELEMENT OF OLD_EZITRAK042_REC ( SUB1 )
        CONTINUE
    ELSE
        IF SOLUTION_DESC_ELEMENT OF OLD_EZITRAK042_REC ( SUB1 ) = SPACES
            PERFORM 6552_INSERT_SOL_DESC
        ELSE
            IF SOLUTION_DESC_ELEMENT OF EZITRAK042_REC ( SUB1 ) = SPACES
                PERFORM 7500_SELECT_SOL_DESC
                IF TMP_FLAG = "Y"
                    PERFORM 6554_DELETE_SOL_DESC
                END-IF
            ELSE
                PERFORM 7500_SELECT_SOL_DESC
                IF TMP_FLAG = "Y"
                    PERFORM 6556_UPDATE_SOL_DESC
                END-IF
            END-IF
        END-IF
    END-IF.
*
6552_INSERT_SOL_DESC.
    MOVE PROBLEM_NUMBER OF EZITRAK041-REC
      TO PROBLEM_NUMBER OF PROBLEM_SOLUTION_DETAILS_REC.

    MOVE SOLUTION_DESC  OF EZITRAK042-REC ( SUB1 )
      TO SOLUTION_DESC  OF PROBLEM_SOLUTION_DETAILS_REC.

    MOVE SUB1
      TO LINE_NUMBER OF PROBLEM_SOLUTION_DETAILS_REC.

    PERFORM 8600-GET-TIME.
    MOVE CURRENT_DATE_BIN TO REC_TMSTAMP OF PROBLEM_SOLUTION_DETAILS_REC.
    MOVE CURRENT_DATE_BIN TO WS_PS_TMSTAMP ( SUB1 ).

    PERFORM 8700-GET-USER.
    MOVE CURRENT_USER_ID TO REC_USER     OF PROBLEM_SOLUTION_DETAILS_REC.

    CALL "ET_IR_PROBLEM_SOLUTION_DETAILS" USING SQLCA
                                PROBLEM_NUMBER   OF PROBLEM_SOLUTION_DETAILS_REC
                                LINE_NUMBER      OF PROBLEM_SOLUTION_DETAILS_REC
                                SOLUTION_DESC    OF PROBLEM_SOLUTION_DETAILS_REC
                                REC_USER         OF PROBLEM_SOLUTION_DETAILS_REC
                                REC_TMSTAMP      OF PROBLEM_SOLUTION_DETAILS_REC.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN SQL_DUPLICATE_IDX
        MOVE 31 TO STAGE-OF-PROCESSING
        MOVE "LINE INSERTED BY ANOTHER USER" TO ERROR_MESSAGE OF EZITRAK042_REC
        MOVE "N" TO TMP_FLAG
    WHEN OTHER
        DISPLAY "ERROR OF PROBLEM_SOL_IR CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR ON SOL_IR" TO ERROR_MESSAGE OF EZITRAK041_REC
        GO TO 9900_EXIT
    END-EVALUATE.
*
6554_DELETE_SOL_DESC.
    MOVE PROBLEM_NUMBER OF EZITRAK041-REC
      TO PROBLEM_NUMBER OF PROBLEM_SOLUTION_DETAILS_REC.

    MOVE SUB1
      TO LINE_NUMBER OF PROBLEM_SOLUTION_DETAILS_REC.

    CALL "ET_DR_PROBLEM_SOLUTION_DETAILS" USING SQLCA
                                PROBLEM_NUMBER   OF PROBLEM_SOLUTION_DETAILS_REC
                                LINE_NUMBER      OF PROBLEM_SOLUTION_DETAILS_REC

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN SQL_NOT_FOUND
        MOVE 31 TO STAGE-OF-PROCESSING
        MOVE "N" TO TMP_FLAG
        MOVE "LINE DELETED BY ANOTHER USER" TO ERROR_MESSAGE OF EZITRAK042_REC
    WHEN SQL_LOCKED_RECORD
        MOVE 31 TO STAGE-OF-PROCESSING
        MOVE "N" TO TMP_FLAG
        MOVE "RECORD IS LOCKED BY ANOTHER USER, PLEASE TRY AGAIN"
          TO ERROR_MESSAGE OF EZITRAK042_REC
    WHEN OTHER
        DISPLAY "ERROR OF PROBLEM_SOL_DR CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR ON SOL_DR" TO ERROR_MESSAGE OF EZITRAK041_REC
        GO TO 9900_EXIT
    END-EVALUATE.
*
6556_UPDATE_SOL_DESC.
    MOVE PROBLEM_NUMBER OF EZITRAK041-REC
      TO PROBLEM_NUMBER OF PROBLEM_SOLUTION_DETAILS_REC.

    MOVE SOLUTION_DESC  OF EZITRAK042-REC ( SUB1 )
      TO SOLUTION_DESC  OF PROBLEM_SOLUTION_DETAILS_REC.

    MOVE SUB1
      TO LINE_NUMBER OF PROBLEM_SOLUTION_DETAILS_REC.

    PERFORM 8600-GET-TIME.
    MOVE CURRENT_DATE_BIN TO REC_TMSTAMP OF PROBLEM_SOLUTION_DETAILS_REC.
    MOVE CURRENT_DATE_BIN TO WS_PS_TMSTAMP ( SUB1 ).

    PERFORM 8700-GET-USER.
    MOVE CURRENT_USER_ID TO REC_USER     OF PROBLEM_SOLUTION_DETAILS_REC.

    CALL "ET_UR_PROBLEM_SOLUTION_DETAILS" USING SQLCA
                                PROBLEM_NUMBER   OF PROBLEM_SOLUTION_DETAILS_REC
                                LINE_NUMBER      OF PROBLEM_SOLUTION_DETAILS_REC
                                SOLUTION_DESC    OF PROBLEM_SOLUTION_DETAILS_REC
                                REC_USER         OF PROBLEM_SOLUTION_DETAILS_REC
                                REC_TMSTAMP      OF PROBLEM_SOLUTION_DETAILS_REC.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN SQL_NOT_FOUND
        MOVE 31 TO STAGE-OF-PROCESSING
        MOVE "LINE DELETED BY ANOTHER USER" TO ERROR_MESSAGE OF EZITRAK042_REC
        MOVE "N" TO TMP_FLAG
    WHEN SQL_DUPLICATE_IDX
        MOVE 31 TO STAGE-OF-PROCESSING
        MOVE "N" TO TMP_FLAG
        MOVE "LINE INSERTED BY ANOTHER USER" TO ERROR_MESSAGE OF EZITRAK042_REC
    WHEN SQL_LOCKED_RECORD
        MOVE 31 TO STAGE-OF-PROCESSING
        MOVE "N" TO TMP_FLAG
        MOVE "RECORD IS LOCKED BY ANOTHER USER, PLEASE TRY AGAIN"
          TO ERROR_MESSAGE OF EZITRAK042_REC
    WHEN OTHER
        DISPLAY "ERROR OF PROBLEM_SOL_UR CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR ON SOL_UR" TO ERROR_MESSAGE OF EZITRAK041_REC
        GO TO 9900_EXIT
    END-EVALUATE.
/
7000-START_TRAN_RO.
    CALL "ET_ST_RO_PROBLEM" USING SQLCA.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        MOVE "Y" TO TRANSACTION_BEGUN_FLAG
    WHEN SQL_LOCKED_RECORD
        MOVE 11 TO STAGE-OF-PROCESSING
        MOVE "RECORD IS LOCKED BY ANOTHER USER, PLEASE TRY AGAIN"
          TO ERROR_MESSAGE OF EZITRAK041_REC
    WHEN OTHER
        DISPLAY "ST_RO NG CODE=" SQLCODE WITH CONVERSION
        GO TO   9900-EXIT
    END-EVALUATE.
/
7100-START_TRAN_RW.
    CALL "ET_ST_RW_PROBLEM" USING SQLCA.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        MOVE "Y" TO TRANSACTION_BEGUN_FLAG
    WHEN SQL_LOCKED_RECORD
        MOVE 31 TO STAGE-OF-PROCESSING
        MOVE "RECORD IS LOCKED BY ANOTHER USER, PLEASE TRY AGAIN"
          TO ERROR_MESSAGE OF EZITRAK042_REC
    WHEN OTHER
        DISPLAY "ST_RW NG CODE=" SQLCODE WITH CONVERSION
        GO TO   9900-EXIT
    END-EVALUATE.
*
7300-REWRITE-PROBLEM-RECORD.
    MOVE CORRESPONDING
       SOLUTION_DESC_HEADER OF EZITRAK042-REC TO PROBLEM_DETAILS_REC.

    PERFORM 8600-GET-TIME.
    MOVE CURRENT_DATE_BIN TO REC_TMSTAMP OF PROBLEM_DETAILS_REC.

    PERFORM 8700-GET-USER.
    MOVE CURRENT_USER_ID TO REC_USER     OF PROBLEM_DETAILS_REC.

    CALL "ET_UR_PROBLEM_DETAILS" USING SQLCA
                                 PROBLEM_NUMBER       OF PROBLEM_DETAILS_REC
                                 PROBLEM_STATUS       OF PROBLEM_DETAILS_REC
                                 PERSON_ASSIGNED_ID   OF PROBLEM_DETAILS_REC
                                 PERSON_REDIRECTED_ID OF PROBLEM_DETAILS_REC
                                 EST_TO_COMPLETE_DAYS OF PROBLEM_DETAILS_REC
                                 PROGRESS_DESC        OF PROBLEM_DETAILS_REC
                                 SOLVED_DATE          OF PROBLEM_DETAILS_REC
                                 REF_PROBLEM_NUMBER   OF PROBLEM_DETAILS_REC
                                 REC_USER             OF PROBLEM_DETAILS_REC
                                 REC_TMSTAMP          OF PROBLEM_DETAILS_REC
    END-CALL.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN SQL_NOT_FOUND
        MOVE "RECORD HAS BEEN DELETED" TO ERROR_MESSAGE OF EZITRAK042_REC
        MOVE 31 TO STAGE-OF-PROCESSING
    WHEN OTHER
        DISPLAY "ERROR OF PROBLEM_UR CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR REWRITING PROB" TO ERROR_MESSAGE OF EZITRAK042_REC
        GO TO 9900_EXIT
    END-EVALUATE.
/
7400-PROBLEM_SS.
    CALL "ET_SS_PROBLEM_DETAILS" USING SQLCA
                                 PROBLEM_NUMBER       OF PROBLEM_DETAILS_REC
                                 PROBLEM_STATUS       OF PROBLEM_DETAILS_REC
                                 PRIORITY_ID          OF PROBLEM_DETAILS_REC
                                 APPLICATION_ID       OF PROBLEM_DETAILS_REC
                                 SITE_ID              OF PROBLEM_DETAILS_REC
                                 PROBLEM_DESC         OF PROBLEM_DETAILS_REC
                                 RECORDING_PERSON_ID  OF PROBLEM_DETAILS_REC
                                 CONTACT_DATE         OF PROBLEM_DETAILS_REC
                                 CONTACT_PERSON_ID    OF PROBLEM_DETAILS_REC
                                 CONTACT_DEVICE       OF PROBLEM_DETAILS_REC
                                 PERSON_ASSIGNED_ID   OF PROBLEM_DETAILS_REC
                                 PERSON_REDIRECTED_ID OF PROBLEM_DETAILS_REC
                                 OTHER_SYSTEM_CODE    OF PROBLEM_DETAILS_REC
                                 EST_TO_COMPLETE_DAYS OF PROBLEM_DETAILS_REC
                                 PROGRESS_DESC        OF PROBLEM_DETAILS_REC
                                 SOLVED_DATE          OF PROBLEM_DETAILS_REC
                                 REF_PROBLEM_NUMBER   OF PROBLEM_DETAILS_REC
                                 REC_USER             OF PROBLEM_DETAILS_REC
                                 REC_TMSTAMP          OF PROBLEM_DETAILS_REC
    END-CALL.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        MOVE "Y" TO TMP_FLAG
        MOVE REC_TMSTAMP OF PROBLEM_DETAILS_REC TO SAVED_PROBLEM_TMSTAMP
    WHEN SQL_NOT_FOUND
        MOVE "N" TO TMP_FLAG
    WHEN OTHER
        DISPLAY "SS PROBLEM NG CODE=" SQLCODE WITH CONVERSION
        GO TO   9900-EXIT
    END-EVALUATE.
/
7500_SELECT_SOL_DESC.
    MOVE PROBLEM_NUMBER OF EZITRAK041-REC
      TO PROBLEM_NUMBER OF PROBLEM_SOLUTION_DETAILS_REC.

    MOVE SUB1
      TO LINE_NUMBER OF PROBLEM_SOLUTION_DETAILS_REC.

    CALL "ET_SS_PROBLEM_SOLUTION_DETAILS" USING SQLCA
                                PROBLEM_NUMBER   OF PROBLEM_SOLUTION_DETAILS_REC
                                LINE_NUMBER      OF PROBLEM_SOLUTION_DETAILS_REC
                                SOLUTION_DESC    OF PROBLEM_SOLUTION_DETAILS_REC
                                REC_USER         OF PROBLEM_SOLUTION_DETAILS_REC
                                REC_TMSTAMP      OF PROBLEM_SOLUTION_DETAILS_REC.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        IF REC-TMSTAMP OF PROBLEM_SOLUTION_DETAILS_REC = WS_PS_TMSTAMP ( SUB1 )
            CONTINUE
        ELSE
            MOVE 31 TO STAGE-OF-PROCESSING
            MOVE "LINE MODIFIED BY ANOTHER USER" TO ERROR_MESSAGE OF EZITRAK042_REC
            MOVE "N" TO TMP_FLAG
        END-IF
    WHEN SQL_NOT_FOUND
        MOVE 31 TO STAGE-OF-PROCESSING
        MOVE "LINE DELETED BY ANOTHER USER" TO ERROR_MESSAGE OF EZITRAK042_REC
        MOVE "N" TO TMP_FLAG
    WHEN OTHER
        DISPLAY "ERROR OF PROBLEM_SOL_SS CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR ON SOL_SS" TO ERROR_MESSAGE OF EZITRAK041_REC
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
/
8000-FINALISATION.
    CALL            "FORMS$DISABLE"
    USING
      BY DESCRIPTOR  SESSION_ID,
    GIVING           FORMS-STATUS.
     
    IF FORMS-STATUS IS FAILURE 
        PERFORM 8300-FORMS-ERROR
        GO TO   9900-EXIT
    END-IF.
     
/
8100-REQUEST-01.
    MOVE HEADER-REC-NAME TO SEND_REC-NAME.
    MOVE HEADER-REC-NAME TO RECE_REC-NAME.

    CALL            "FORMS$TRANSCEIVE" 
    USING
      BY DESCRIPTOR  SESSION_ID
      BY DESCRIPTOR  SEND_REC_NAME,
      BY REFERENCE   SINGLE_REC_COUNT
      BY DESCRIPTOR  RECE_REC_NAME
      BY REFERENCE   SINGLE_REC_COUNT
      BY DESCRIPTOR  INP_CTL_STRING
      BY REFERENCE   INP_CTL_COUNT
      BY DESCRIPTOR  OUT_CTL_STRING
      BY REFERENCE   OUT_CTL_COUNT
      BY VALUE       NO_TIMEOUT
                     ORIGINAL_REQ
                     NO_OPTIONS
      BY DESCRIPTOR  EZITRAK041_REC
      BY VALUE       NO_SHAD
      BY DESCRIPTOR  EZITRAK041_REC
    GIVING           FORMS-STATUS.

    IF FORMS-STATUS IS FAILURE 
        PERFORM 8300-FORMS-ERROR
        GO TO   9900-EXIT
    END-IF.
/
8100-REQUEST-02.
    MOVE MAIN_REC_NAME TO SEND_REC_NAME.
    MOVE MAIN_REC_NAME TO RECE_REC_NAME.

    CALL "FORMS$TRANSCEIVE"
    USING
      BY DESCRIPTOR  SESSION_ID
      BY DESCRIPTOR  SEND_REC_NAME
      BY REFERENCE   SINGLE_REC_COUNT
      BY DESCRIPTOR  RECE_REC_NAME
      BY REFERENCE   SINGLE_REC_COUNT
      BY DESCRIPTOR  INP_CTL_STRING
      BY REFERENCE   INP_CTL_COUNT
      BY DESCRIPTOR  OUT_CTL_STRING
      BY REFERENCE   OUT_CTL_COUNT
      BY VALUE       NO_TIMEOUT
                     ORIGINAL_REQ
                     NO_OPTIONS
      BY DESCRIPTOR  EZITRAK042_REC
      BY VALUE       NO_SHAD
      BY DESCRIPTOR  EZITRAK042_REC
      BY VALUE       NO_SHAD
    GIVING           FORMS-STATUS.

    IF FORMS-STATUS IS FAILURE 
        PERFORM 8300-FORMS-ERROR
        GO TO   9900-EXIT
    END-IF.
*
8300-FORMS-ERROR.
    CALL "LIB$SIGNAL" USING BY VALUE FORMS-STATUS.
*
8500-READ-PERSON-TABLE.
    IF TRANSACTION_BEGUN_FLAG = "N"
        PERFORM 7000_START_TRAN_RO
    END-IF.

    CALL "ET_SS_PERSON_DETAILS" USING SQLCA
                                      PERSON_ID   OF PERSON_DETAILS_REC
                                      PERSON_DESC OF PERSON_DETAILS_REC
    END-CALL.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        MOVE "Y" TO PERSON-FOUND-FLAG
    WHEN SQL_NOT_FOUND
        MOVE "N" TO PERSON-FOUND-FLAG
        MOVE "*** NOT ON FILE ****" TO PERSON-DESC OF PERSON_DETAILS_REC
    WHEN OTHER
        DISPLAY "ERROR OF PERSON_SS CODE=" SQLCODE WITH CONVERSION
        MOVE "N" TO PERSON-FOUND-FLAG
        GO TO 9900_EXIT
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

    STOP RUN.
*
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
* **************** END OF SOURCE EZITRAK001 ****************
