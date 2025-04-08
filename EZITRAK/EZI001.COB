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
*                  problem details.                                           *
*                                                                             *
*                  If no record is found, the program displays the            *
*                  empty problem create/modify screen with the problem number *
*                  from the first screen so a new problem can be created.     *
*                                                                             *
*                  All changed details on the screen are validated.           *
*                  Valid data from each screen is written to a record in the  *
*                  PROBLEM_DETAILS table.                                     * 
*                                                                             *
*   SCREENS USED : EZITRAK041                                                 *
*                : EZITRAK042                                                 *
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
 01  EZITRAK041_rec.
     03  PROBLEM_NUMBER                          PIC S9(4) COMP.

 01  EZITRAK041_SAV_rec.
     03  PROBLEM_NUMBER                          PIC S9(4) COMP.

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
 01  SEND_REC_NAME                               PIC X(14) VALUE
                                                    "EZITRAK041_REC".
 01  RECE-REC-NAME                               PIC X(14) VALUE
                                                    "EZITRAK041_REC".

 01  INP_CTL_STRING                              PIC X(25) GLOBAL.
 01  OUT_CTL_STRING                              PIC X(25) GLOBAL.
 01  INP_CTL_COUNT                               PIC S9(9) COMP GLOBAL.
 01  OUT_CTL_COUNT                               PIC S9(9) COMP GLOBAL.
/
PROCEDURE DIVISION.
MAIN-PARA.
    PERFORM 1000-INITIALISATION.

    PERFORM 2000-PROB-NUMBER-SCREEN.

    PERFORM 8000-FINALISATION.

    GO TO 9900-EXIT.
*
1000-INITIALISATION.
    PERFORM 1100-FORM-INIT.

1100-FORM-INIT.
    DISPLAY "Enabling".

    CALL "FORMS$ENABLE"
    USING
      OMITTED
      BY DESCRIPTOR  DEVICE_NAME
      BY DESCRIPTOR  SESSION_ID
      BY DESCRIPTOR  FORM-FILE,
    GIVING           FORMS-STATUS.

    DISPLAY "Enabled".
     
    IF FORMS-STATUS IS FAILURE 
        PERFORM 8200-FORMS-ERROR
        GO TO   9900-EXIT
    END-IF.
/
2000-PROB-NUMBER-SCREEN.
    DISPLAY "Transceiving".
    MOVE 1 TO PROBLEM_NUMBER OF EZITRAK041_REC.

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
      BY DESCRIPTOR  EZITRAK041_REC
      BY VALUE       NO_SHAD
      BY DESCRIPTOR  EZITRAK041_REC
      BY VALUE       NO_SHAD
    GIVING           FORMS-STATUS.

    DISPLAY PROBLEM_NUMBER OF EZITRAK041_REC WITH CONVERSION.

    IF FORMS-STATUS IS FAILURE 
        PERFORM 8200-FORMS-ERROR
        GO TO   9900-EXIT
    END-IF.
/
8000-FINALISATION.
    DISPLAY "Disabling".

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
*    MOVE PROB-NUMBER-RECORD-LITERAL TO REC-NAME.
*    MOVE PROB-NUMBER-SCREEN-LITERAL TO REQUEST-NAME.
*
*    CALL            "TSS$REQUEST" 
*    USING
*      BY REFERENCE   CHANNEL,
*      BY REFERENCE   LIBRARY-ID,
*      BY DESCRIPTOR  REQUEST-NAME
*      BY REFERENCE   EZITRAK011_REC
*      BY REFERENCE   EZITRAKCOM_REC
*    GIVING           FORMS-STATUS.
*
*    IF FORMS-STATUS IS FAILURE 
*        PERFORM 8200-FORMS-ERROR
*        GO TO   9900-EXIT
*    END-IF.
/
*
8200-FORMS-ERROR.
    DISPLAY "Found error".

    CALL "LIB$SIGNAL" USING BY VALUE FORMS-STATUS.
*
9900-EXIT.

    STOP RUN.
*
* **************** END OF SOURCE EZITRAK001 ****************
