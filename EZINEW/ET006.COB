IDENTIFICATION DIVISION.
*
*******************************************************************************
*                                                                             *
*   Program ID   : EZITRAK006                                                 *
*   Program Name : Application Details Table                                  *
*   Summary      : On startup the search parameters screen is displayed. When *
*                  parameters are entered, the program searches the           *
*                  APPLICATION_DETAILS table in the EZITRAK database and      *
*                  displays the problem browse screen with the found problem  *
*                  details.                                                   *
*                                                                             *
*   SCREENS USED : EZITRAK051                                                 *
*                : EZITRAK052                                                 *
*                                                                             *
*   TABLES  USED : PERSON_DETAILS       (Input-Output                         *
*                                                                             *
*******************************************************************************
*
/
PROGRAM-ID. EZITRAK006.
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

    copy "EZITRAK_CDD.APPLICATION_DETAILS_REC"       from dictionary.
/
 01  SESSION-ID                                  PIC X(16) GLOBAL.
 01  DEVICE-NAME                                 PIC X(9)  VALUE "SYS$INPUT".
 01  FORM-FILE                                   PIC X(10) VALUE
                                                    "EZITRAK061".
 01  FORMS-STATUS                                PIC S9(9) COMP GLOBAL.
 01  SINGLE_REC_COUNT                            PIC S9(5) COMP VALUE 1 GLOBAL.
 01  NO-TIMEOUT                                  PIC S9(9) COMP VALUE 0 GLOBAL.
 01  ORIGINAL_REQ                                PIC S9(9) COMP VALUE 0 GLOBAL.
 01  NO-OPTIONS                                  PIC S9(9) COMP VALUE 0 GLOBAL.
 01  NO-SHAD                                     PIC S9(9) COMP VALUE 0 GLOBAL.

 01  SEND_REC_NAME                               PIC X(14).
 01  RECE-REC-NAME                               PIC X(14).

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

 01  ERR_RET                                     PIC S9(9) COMP.
 01  ERR_SUB                                     PIC  9(9) COMP.
 01  ERR_FLAGS                                   PIC  9(9) COMP.
 01  ERR_LENGTH                                  PIC  9(9) COMP.
 01  ERR_BUFFER                                  PIC  X(80).
 01  SS$_NORMAL                                  PIC S9(9) COMP
     VALUE IS EXTERNAL SS$_NORMAL.

 01  JPI_USERNAME                                PIC S9(9) COMP VALUE 514.

 01  FORMS$AR_FORM_TABLE                         PIC S9(9) COMP
                                            VALUE EXTERNAL FORMS$AR_FORM_TABLE.

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

*    PERFORM DISTRIBUTOR-PARA UNTIL STAGE-OF-PROCESSING = 99.

    PERFORM 8000-FINALISATION.

    GO TO 9900-EXIT.
*
DISTRIBUTOR-PARA.
    IF STAGE-OF-PROCESSING = 10
        PERFORM 2000-PERSON_HEADER-SCREEN.

    ADD 1 TO TEMP-COUNTER.
    IF TEMP-COUNTER > 10
        DISPLAY "TEMP COUNTER EXCEEDED"
        GO TO 9900-EXIT.
*
1000-INITIALISATION.
    MOVE 10      TO STAGE-OF-PROCESSING.
    MOVE ZERO    TO TEMP-COUNTER.
    MOVE "N"     TO TRANSACTION_BEGUN_FLAG.   

    PERFORM 1100-FORM-INIT.
*
1100-FORM-INIT.
    CALL "FORMS$ENABLE"
    USING
      BY VALUE       FORMS$AR_FORM_TABLE
      BY DESCRIPTOR  DEVICE_NAME
      BY DESCRIPTOR  SESSION_ID
      BY DESCRIPTOR  FORM-FILE,
    GIVING           FORMS-STATUS.

    IF FORMS-STATUS IS FAILURE 
        PERFORM 8200-FORMS-ERROR
        GO TO   9900-EXIT
    END-IF.
/
2000-PERSON-HEADER-SCREEN.
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

    STOP RUN.
*
* **************** END OF SOURCE EZITRAK006 ****************
