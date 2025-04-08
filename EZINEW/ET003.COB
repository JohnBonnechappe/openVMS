IDENTIFICATION DIVISION.
*
*******************************************************************************
*                                                                             *
*   Program ID   : EZITRAK003                                                 *
*   Program Name : Problem Search and browse                                  *
*   Summary      : On startup the search parameters screen is displayed. When *
*                  parameters are entered, the program searches the           *
*                  PROBLEM_DETAILS table in the EZITRAK database and          *
*                  displays the problem browse screen with the found problem  *
*                  details.                                                   *
*                                                                             *
*   SCREENS USED : EZITRAK031                                                 *
*                : EZITRAK032                                                 *
*                                                                             *
*   TABLES  USED : PROBLEM_DETAILS      (Input-output)                        *
*                  PERSON_DETAILS       (Input)                               *
*                  APPLICATION_DETAILS  (Input)                               *
*                  STATUS_DETAILS       (Input)                               *
*                  PRIORITY_DETAILS     (Input)                               *
*                                                                             *
*******************************************************************************
*
/
PROGRAM-ID. EZITRAK003.
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
    copy "EZITRAK_CDD.EZITRAK031_REC"  from dictionary.
    copy "EZITRAK_CDD.EZITRAK032_REC"  from dictionary.
    copy "EZITRAK_CDD.EZITRAK031_REC"  from dictionary
          replacing EZITRAK031_REC BY OLD-EZITRAK031-REC.

    copy "EZITRAK_CDD.PROBLEM_DETAILS_REC"      from dictionary.
    copy "EZITRAK_CDD.PERSON_DETAILS_REC"       from dictionary.
    copy "EZITRAK_CDD.STATUS_DETAILS_REC"       from dictionary.
    copy "EZITRAK_CDD.PRIORITY_DETAILS_REC"     from dictionary.
    copy "EZITRAK_CDD.APPLICATION_DETAILS_REC"  from dictionary.
/
 01  SESSION-ID                                  PIC X(16) GLOBAL.
 01  DEVICE-NAME                                 PIC X(9)  VALUE "SYS$INPUT".
 01  FORM-FILE                                   PIC X(10) VALUE
                                                    "EZITRAK031".
 01  FORMS-STATUS                                PIC S9(9) COMP GLOBAL.
 01  SINGLE_REC_COUNT                            PIC S9(5) COMP VALUE 1 GLOBAL.
 01  NO-TIMEOUT                                  PIC S9(9) COMP VALUE 0 GLOBAL.
 01  ORIGINAL_REQ                                PIC S9(9) COMP VALUE 0 GLOBAL.
 01  NO-OPTIONS                                  PIC S9(9) COMP VALUE 0 GLOBAL.
 01  NO-SHAD                                     PIC S9(9) COMP VALUE 0 GLOBAL.

 01  SEND_REC_NAME                               PIC X(14).
 01  RECE-REC-NAME                               PIC X(14).

 01  HEADER_REC_NAME                             PIC X(14) VALUE
                                                    "EZITRAK031_REC".

 01  MAIN_REC_NAME                               PIC X(14) VALUE
                                                    "EZITRAK032_REC".

 01  INP_CTL_STRING                              PIC X(25) GLOBAL.
 01  OUT_CTL_STRING                              PIC X(25) GLOBAL.
 01  INP_CTL_COUNT                               PIC S9(9) COMP GLOBAL.
 01  OUT_CTL_COUNT                               PIC S9(9) COMP GLOBAL.
/
 01  TMP-FLAG                                    PIC X.
 01  STAGE-OF-PROCESSING                         PIC 99.
 01  PERSON-FOUND-FLAG                           PIC X.
 01  PROB-NUMBER-SCREEN-LITERAL                  PIC X(14) VALUE "EZITRAK031_REQ".
 01  PROB-CREATE-MOD-SCREEN-LITERAL              PIC X(14) VALUE "EZITRAK032_REQ".
 01  PROB-NUMBER-RECORD-LITERAL                  PIC X(14) VALUE "EZITRAK031_REC".
 01  PROB-CREATE-MOD-RECORD-LITERAL              PIC X(14) VALUE "EZITRAK032_REC".

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
    IF STAGE-OF-PROCESSING = 10
        PERFORM 2000-PROB-SEARCH-SCREEN.

    IF STAGE-OF-PROCESSING = 15
        PERFORM 3000-READ-PROBLEM-TABLES.

    IF STAGE-OF-PROCESSING = 20 OR 21
        PERFORM 4000-PROB-BROWSE-SCREEN.

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
*
1100-FORM-INIT.
    CALL "FORMS$ENABLE"
    USING
      OMITTED
      BY DESCRIPTOR  DEVICE_NAME
      BY DESCRIPTOR  SESSION_ID
      BY DESCRIPTOR  FORM-FILE,
    GIVING           FORMS-STATUS.

    IF FORMS-STATUS IS FAILURE 
        PERFORM 8200-FORMS-ERROR
        GO TO   9900-EXIT
    END-IF.
/
2000-PROB-SEARCH-SCREEN.
    INITIALIZE EZITRAK031-REC.
    MOVE EZITRAK031-REC                 TO OLD-EZITRAK031-REC.

    MOVE SPACE TO KEY_PRESSED OF EZITRAK031_REC.
    PERFORM 8100-REQUEST-01.
    MOVE SPACES  TO ERROR_MESSAGE OF EZITRAK031_REC.

    EVALUATE KEY_PRESSED OF EZITRAK031_REC
    WHEN "E"
        MOVE 99 TO STAGE-OF-PROCESSING
    WHEN OTHER
        IF EZITRAK031_REC = OLD_EZITRAK031_REC
            MOVE "MUST ENTER PARAMETERS"
              TO ERROR_MESSAGE OF EZITRAK031_REC
            MOVE 10 TO STAGE-OF-PROCESSING
            Display "same"
        ELSE
            MOVE 15 TO STAGE-OF-PROCESSING
        END-IF
    END-EVALUATE.
/
3000-READ-PROBLEM_TABLES.
    INITIALIZE             EZITRAK032-REC.

    PERFORM 7000_START_TRAN_RO.

    IF CONTACT-DATE OF EZITRAK031-REC NOT = ZERO
        PERFORM 3100_SEARCH_1
    ELSE
        IF PROBLEM_STATUS OF EZITRAK031-REC NOT = SPACE
            PERFORM 3200_SEARCH_2
        ELSE
            IF APPLICATION_ID OF EZITRAK031-REC NOT = SPACE
                PERFORM 3300_SEARCH_3
            ELSE
                IF PRIORITY_ID OF EZITRAK031-REC NOT = SPACE
                    PERFORM 3400_SEARCH_4
                ELSE
                    IF OTHER_SYSTEM_CODE OF EZITRAK031-REC NOT = SPACE
                        PERFORM 3500_SEARCH_5
                    ELSE
                        MOVE "SEARCH PARAMETERS NOT RECOGNISED"
                          TO ERROR_MESSAGE OF EZITRAK031_REC
                        MOVE 10      TO STAGE-OF-PROCESSING
                    END-IF
                END-IF
            END-IF
        END-IF
    END-IF.

    IF TMP-FLAG = "N"
        MOVE 10 TO STAGE-OF-PROCESSING
    ELSE
        MOVE 20 TO STAGE-OF-PROCESSING
    END-IF.

    PERFORM 7800_CMT_TRAN.
/
3100_SEARCH_1.
    MOVE CONTACT-DATE OF EZITRAK031-REC
      TO CONTACT-DATE OF PROBLEM_DETAILS_REC.

    CALL "ET_OC1_PROBLEM_DETAILS" USING SQLCA
                                  CONTACT-DATE OF PROBLEM_DETAILS_REC.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN OTHER
        DISPLAY "ERROR OF PROBLEM_OC CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR ON OC" TO ERROR_MESSAGE OF EZITRAK031_REC
        GO TO 9900_EXIT
    END-EVALUATE.

    PERFORM 3150_FETCH VARYING SUB1 FROM 1 BY 1
                               UNTIL NOT SQL_SUCCESS
                               OR SUB1 > SUB1_MAX.

    CALL "ET_CC1_PROBLEM_DETAILS" USING SQLCA.
                  
    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN OTHER
        DISPLAY "ERROR OF CC CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR ON CC" TO ERROR_MESSAGE OF EZITRAK031_REC
        GO TO 9900_EXIT
    END-EVALUATE.

3150_FETCH.
    CALL "ET_FC1_PROBLEM_DETAILS" USING SQLCA
                                 PROBLEM_NUMBER       OF PROBLEM_DETAILS_REC
                                 PROBLEM_STATUS       OF PROBLEM_DETAILS_REC
                                 PRIORITY_ID          OF PROBLEM_DETAILS_REC
                                 APPLICATION_ID       OF PROBLEM_DETAILS_REC
                                 PROBLEM_DESC         OF PROBLEM_DETAILS_REC
                                 CONTACT_DATE         OF PROBLEM_DETAILS_REC
                                 CONTACT_PERSON_ID    OF PROBLEM_DETAILS_REC
                                 CONTACT_DEVICE       OF PROBLEM_DETAILS_REC
    END-CALL.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        MOVE "Y" TO TMP_FLAG
        PERFORM 7700_SETUP_REC
    WHEN SQL_NOT_FOUND
        CONTINUE
    WHEN OTHER
        DISPLAY "ERROR OF FC CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR FC" TO ERROR_MESSAGE OF EZITRAK031_REC
        GO TO 9900_EXIT
    END-EVALUATE.
/
3200_SEARCH_2.
    MOVE PROBLEM_STATUS OF EZITRAK031-REC
      TO PROBLEM_STATUS OF PROBLEM_DETAILS_REC.

    CALL "ET_OC2_PROBLEM_DETAILS" USING SQLCA
                                  PROBLEM_STATUS OF PROBLEM_DETAILS_REC.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN OTHER
        DISPLAY "ERROR OF PROBLEM_OC CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR ON OC" TO ERROR_MESSAGE OF EZITRAK031_REC
        GO TO 9900_EXIT
    END-EVALUATE.

    PERFORM 3250_FETCH VARYING SUB1 FROM 1 BY 1
                               UNTIL NOT SQL_SUCCESS
                               OR SUB1 > SUB1_MAX.

    CALL "ET_CC2_PROBLEM_DETAILS" USING SQLCA.
                  
    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN OTHER
        DISPLAY "ERROR OF CC CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR ON CC" TO ERROR_MESSAGE OF EZITRAK031_REC
        GO TO 9900_EXIT
    END-EVALUATE.

3250_FETCH.

    CALL "ET_FC2_PROBLEM_DETAILS" USING SQLCA
                                 PROBLEM_NUMBER       OF PROBLEM_DETAILS_REC
                                 PROBLEM_STATUS       OF PROBLEM_DETAILS_REC
                                 PRIORITY_ID          OF PROBLEM_DETAILS_REC
                                 APPLICATION_ID       OF PROBLEM_DETAILS_REC
                                 PROBLEM_DESC         OF PROBLEM_DETAILS_REC
                                 CONTACT_DATE         OF PROBLEM_DETAILS_REC
                                 CONTACT_PERSON_ID    OF PROBLEM_DETAILS_REC
                                 CONTACT_DEVICE       OF PROBLEM_DETAILS_REC
    END-CALL.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        MOVE "Y" TO TMP_FLAG
        PERFORM 7700_SETUP_REC
    WHEN SQL_NOT_FOUND
        CONTINUE
    WHEN OTHER
        GO TO 9900_EXIT
    END-EVALUATE.
/
3300_SEARCH_3.
    MOVE APPLICATION_ID OF EZITRAK031-REC
      TO APPLICATION_ID OF PROBLEM_DETAILS_REC.

    CALL "ET_OC3_PROBLEM_DETAILS" USING SQLCA
                                  APPLICATION_ID OF PROBLEM_DETAILS_REC.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN OTHER
        DISPLAY "ERROR OF PROBLEM_OC CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR ON OC" TO ERROR_MESSAGE OF EZITRAK031_REC
        GO TO 9900_EXIT
    END-EVALUATE.

    PERFORM 3350_FETCH VARYING SUB1 FROM 1 BY 1
                               UNTIL NOT SQL_SUCCESS
                               OR SUB1 > SUB1_MAX.

    CALL "ET_CC3_PROBLEM_DETAILS" USING SQLCA.
                  
    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN OTHER
        DISPLAY "ERROR OF CC CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR ON CC" TO ERROR_MESSAGE OF EZITRAK031_REC
        GO TO 9900_EXIT
    END-EVALUATE.

3350_FETCH.

    CALL "ET_FC3_PROBLEM_DETAILS" USING SQLCA
                                 PROBLEM_NUMBER       OF PROBLEM_DETAILS_REC
                                 PROBLEM_STATUS       OF PROBLEM_DETAILS_REC
                                 PRIORITY_ID          OF PROBLEM_DETAILS_REC
                                 APPLICATION_ID       OF PROBLEM_DETAILS_REC
                                 PROBLEM_DESC         OF PROBLEM_DETAILS_REC
                                 CONTACT_DATE         OF PROBLEM_DETAILS_REC
                                 CONTACT_PERSON_ID    OF PROBLEM_DETAILS_REC
                                 CONTACT_DEVICE       OF PROBLEM_DETAILS_REC
    END-CALL.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        MOVE "Y" TO TMP_FLAG
        PERFORM 7700_SETUP_REC
    WHEN SQL_NOT_FOUND
        CONTINUE
    WHEN OTHER
        DISPLAY "ERROR OF FC CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR FC" TO ERROR_MESSAGE OF EZITRAK031_REC
        GO TO 9900_EXIT
    END-EVALUATE.
/
3400_SEARCH_4.
    MOVE PRIORITY_ID OF EZITRAK031-REC
      TO PRIORITY_ID OF PROBLEM_DETAILS_REC.

    CALL "ET_OC4_PROBLEM_DETAILS" USING SQLCA
                                  PRIORITY_ID OF PROBLEM_DETAILS_REC.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN OTHER
        DISPLAY "ERROR OF PROBLEM_OC CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR ON OC" TO ERROR_MESSAGE OF EZITRAK031_REC
        GO TO 9900_EXIT
    END-EVALUATE.

    PERFORM 3450_FETCH VARYING SUB1 FROM 1 BY 1
                               UNTIL NOT SQL_SUCCESS
                               OR SUB1 > SUB1_MAX.

    CALL "ET_CC4_PROBLEM_DETAILS" USING SQLCA.
                  
    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN OTHER
        DISPLAY "ERROR OF CC CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR ON CC" TO ERROR_MESSAGE OF EZITRAK031_REC
        GO TO 9900_EXIT
    END-EVALUATE.

3450_FETCH.

    CALL "ET_FC4_PROBLEM_DETAILS" USING SQLCA
                                 PROBLEM_NUMBER       OF PROBLEM_DETAILS_REC
                                 PROBLEM_STATUS       OF PROBLEM_DETAILS_REC
                                 PRIORITY_ID          OF PROBLEM_DETAILS_REC
                                 APPLICATION_ID       OF PROBLEM_DETAILS_REC
                                 PROBLEM_DESC         OF PROBLEM_DETAILS_REC
                                 CONTACT_DATE         OF PROBLEM_DETAILS_REC
                                 CONTACT_PERSON_ID    OF PROBLEM_DETAILS_REC
                                 CONTACT_DEVICE       OF PROBLEM_DETAILS_REC
    END-CALL.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        MOVE "Y" TO TMP_FLAG
        PERFORM 7700_SETUP_REC
    WHEN SQL_NOT_FOUND
        CONTINUE
    WHEN OTHER
        DISPLAY "ERROR OF FC CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR FC" TO ERROR_MESSAGE OF EZITRAK031_REC
        GO TO 9900_EXIT
    END-EVALUATE.
/
3500_SEARCH_5.
    MOVE OTHER_SYSTEM_CODE OF EZITRAK031-REC
      TO OTHER_SYSTEM_CODE OF PROBLEM_DETAILS_REC.

    MOVE 1 TO SUB1.

    CALL "ET_SS_PROBLEM_DETAILS" USING SQLCA
                                 PROBLEM_NUMBER       OF PROBLEM_DETAILS_REC
                                 PROBLEM_STATUS       OF PROBLEM_DETAILS_REC
                                 PRIORITY_ID          OF PROBLEM_DETAILS_REC
                                 APPLICATION_ID       OF PROBLEM_DETAILS_REC
                                 PROBLEM_DESC         OF PROBLEM_DETAILS_REC
                                 CONTACT_DATE         OF PROBLEM_DETAILS_REC
                                 CONTACT_PERSON_ID    OF PROBLEM_DETAILS_REC
                                 CONTACT_DEVICE       OF PROBLEM_DETAILS_REC
                                 OTHER_SYSTEM_CODE    OF PROBLEM_DETAILS_REC
    END-CALL.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        MOVE "Y" TO TMP_FLAG
        PERFORM 7700_SETUP_REC
    WHEN SQL_NOT_FOUND
        CONTINUE
    WHEN OTHER
        DISPLAY "ERROR OF SS CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR SS" TO ERROR_MESSAGE OF EZITRAK031_REC
        GO TO 9900_EXIT
    END-EVALUATE.
/
4000-PROB-BROWSE-SCREEN.
    MOVE SPACE TO KEY_PRESSED OF EZITRAK032_REC.
    PERFORM 8100-REQUEST-02.
    MOVE SPACES  TO ERROR_MESSAGE OF EZITRAK032_REC.

    EVALUATE KEY_PRESSED OF EZITRAK032_REC
    WHEN "E"
        MOVE 99 TO STAGE-OF-PROCESSING
    WHEN "B"
        MOVE 10 TO STAGE-OF-PROCESSING
    WHEN OTHER
            MOVE 21 TO STAGE-OF-PROCESSING
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
          TO ERROR_MESSAGE OF EZITRAK031_REC
    WHEN OTHER
        DISPLAY "ST_RO NG CODE=" SQLCODE WITH CONVERSION
        GO TO   9900-EXIT
    END-EVALUATE.

7700_SETUP_REC.
        MOVE PROBLEM_NUMBER       OF PROBLEM_DETAILS_REC
          TO PROBLEM_NUMBER       OF EZITRAK032_REC (SUB1).
        MOVE PROBLEM_STATUS       OF PROBLEM_DETAILS_REC
          TO PROBLEM_STATUS       OF EZITRAK032_REC (SUB1).
        MOVE PRIORITY_ID          OF PROBLEM_DETAILS_REC
          TO PRIORITY_ID          OF EZITRAK032_REC (SUB1).
        MOVE APPLICATION_ID       OF PROBLEM_DETAILS_REC
          TO APPLICATION_ID       OF EZITRAK032_REC (SUB1).
        MOVE PROBLEM_DESC         OF PROBLEM_DETAILS_REC
          TO PROBLEM_DESC         OF EZITRAK032_REC (SUB1).
        MOVE CONTACT_DATE         OF PROBLEM_DETAILS_REC
          TO CONTACT_DATE         OF EZITRAK032_REC (SUB1).
        MOVE CONTACT_PERSON_ID    OF PROBLEM_DETAILS_REC
          TO CONTACT_PERSON_ID    OF EZITRAK032_REC (SUB1).
        MOVE CONTACT_DEVICE       OF PROBLEM_DETAILS_REC
          TO CONTACT_DEVICE       OF EZITRAK032_REC (SUB1).
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
        PERFORM 8200-FORMS-ERROR
        GO TO   9900-EXIT
    END-IF.
/
8100-REQUEST-01.
    MOVE HEADER_REC_NAME TO SEND_REC_NAME.
    MOVE HEADER_REC_NAME TO RECE_REC_NAME.

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
      BY DESCRIPTOR  EZITRAK031_REC
      BY VALUE       NO_SHAD
      BY DESCRIPTOR  EZITRAK031_REC
      BY VALUE       NO_SHAD
    GIVING           FORMS-STATUS.

    IF FORMS-STATUS IS FAILURE 
        PERFORM 8200-FORMS-ERROR
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
      BY DESCRIPTOR  EZITRAK032_REC
      BY VALUE       NO_SHAD
      BY DESCRIPTOR  EZITRAK032_REC
      BY VALUE       NO_SHAD
    GIVING           FORMS-STATUS.


    IF FORMS-STATUS IS FAILURE 
        PERFORM 8200-FORMS-ERROR
        GO TO   9900-EXIT
    END-IF.
*
8200-FORMS-ERROR.
    CALL "LIB$SIGNAL" USING BY VALUE FORMS_STATUS.
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
